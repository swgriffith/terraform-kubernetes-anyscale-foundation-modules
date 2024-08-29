# ---------------------------------------------------------------------------------------------------------------------
# Example Anyscale K8s Resources - Public Networking
#   This template creates EKS resources for Anyscale
#   It creates:
#     - VPC
#     - Security Group
#     - S3 Bucket
#     - IAM Roles
#     - EKS Cluster
#     - EKS Nodegroups
#     - Helm Charts
# ---------------------------------------------------------------------------------------------------------------------
locals {
  # azs = slice(data.aws_availability_zones.available.names, 0, 3)

  full_tags = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.tags
  )
}

locals {
  public_subnets  = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
  private_subnets = ["172.24.20.0/24", "172.24.21.0/24", "172.24.22.0/24"]
}
module "anyscale_vpc" {
  #checkov:skip=CKV_TF_1: Test code should use the latest version of the module
  source = "../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-vpc"

  anyscale_vpc_name = "anyscale-eks-public"
  cidr_block        = "172.24.0.0/16"

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}
locals {
  # Because subnet ID may not be known at plan time, we cannot use it as a key
  anyscale_subnet_count = length(local.private_subnets)
}

module "anyscale_securitygroup" {
  #checkov:skip=CKV_TF_1: Test code should use the latest version of the module
  source = "../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-securitygroups"

  vpc_id = module.anyscale_vpc.vpc_id

  security_group_name_prefix = "anyscale-eks-public-"

  ingress_with_self = [
    { rule = "all-all" }
  ]
}


module "anyscale_s3" {
  source = "../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-s3"

  module_enabled = true

  anyscale_bucket_name = "anyscale-eks-public-${var.aws_region}"
  force_destroy        = true
  cors_rule            = var.anyscale_s3_cors_rule

  tags = local.full_tags
}

module "anyscale_iam_roles" {
  #checkov:skip=CKV_TF_1: Test code should use the latest version of the module
  source = "../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-iam"

  module_enabled = true

  create_anyscale_access_role          = true
  anyscale_trusted_role_arns           = var.anyscale_trusted_role_arns
  create_cluster_node_instance_profile = false

  create_iam_s3_policy   = true
  anyscale_s3_bucket_arn = module.anyscale_s3.s3_bucket_arn

  create_anyscale_eks_cluster_role = true
  anyscale_eks_cluster_role_name   = "anyscale-eks-public-cluster-role"

  create_anyscale_eks_node_role = true
  anyscale_eks_node_role_name   = "anyscale-eks-public-node-role"
  anyscale_eks_cluster_name     = module.anyscale_eks_cluster.eks_cluster_name

  create_eks_ebs_csi_driver_role = true
  eks_ebs_csi_role_name          = "anyscale-eks-public-ebs-csi-role"
  anyscale_eks_cluster_oidc_arn  = module.anyscale_eks_cluster.eks_cluster_oidc_provider_arn
  anyscale_eks_cluster_oidc_url  = module.anyscale_eks_cluster.eks_cluster_oidc_provider_url

  tags = local.full_tags
}

locals {
  coredns_config = jsonencode({
    affinity = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [
                {
                  key      = "node-type"
                  operator = "In"
                  values   = ["management"]
                }
              ]
            }
          ]
        }
      }
    },
    nodeSelector = {
      "node-type" = "management"
    },
    tolerations = [
      {
        key      = "CriticalAddonsOnly"
        operator = "Exists"
      },
      {
        effect = "NoSchedule"
        key    = "node-role.kubernetes.io/control-plane"
      }
    ],
    replicaCount = 2
  })

}

module "anyscale_eks_cluster" {
  source = "../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-eks-cluster"

  module_enabled = true

  anyscale_subnet_ids        = module.anyscale_vpc.public_subnet_ids
  anyscale_subnet_count      = local.anyscale_subnet_count
  anyscale_security_group_id = module.anyscale_securitygroup.security_group_id
  eks_role_arn               = module.anyscale_iam_roles.iam_anyscale_eks_cluster_role_arn
  anyscale_eks_name          = "anyscale-eks-public"

  enabled_cluster_log_types = ["api", "authenticator", "audit", "scheduler", "controllerManager"]

  eks_addons = [
    {
      addon_name           = "coredns"
      addon_version        = "v1.11.1-eksbuild.8"
      configuration_values = local.coredns_config
    },
    # Add EBS volume support for EKS
    {
      addon_name               = "aws-ebs-csi-driver"
      addon_version            = "v1.33.0-eksbuild.1"
      service_account_role_arn = module.anyscale_iam_roles.iam_anyscale_eks_csi_driver_role_arn
    },
    # Add EFS mount
    # {
    #   addon_name               = "aws-efs-csi-driver"
    #   addon_version            = "v2.0.7-eksbuild.1"
    #   service_account_role_arn = module.anyscale_iam_roles.iam_anyscale_efs_csi_driver_role_arn
    # }
  ]
  eks_addons_depends_on = module.anyscale_eks_nodegroups

  tags = local.full_tags

  depends_on = [module.anyscale_vpc, module.anyscale_securitygroup]
}

module "anyscale_eks_nodegroups" {
  source = "../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-eks-nodegroups"

  module_enabled = true

  eks_node_role_arn = module.anyscale_iam_roles.iam_anyscale_eks_node_role_arn
  eks_cluster_name  = module.anyscale_eks_cluster.eks_cluster_name
  subnet_ids        = module.anyscale_vpc.private_subnet_ids

  tags = local.full_tags

  eks_anyscale_node_groups = [
    {
      name = "anyscale-ondemand-cpu-8CPU-32GB"
      instance_types = [
        "m6a.2xlarge",
        "m5a.2xlarge",
        "m6i.2xlarge",
        "m5.2xlarge"
      ]
      capacity_type = "ON_DEMAND"
      ami_type      = "AL2_x86_64_GPU"
      tags          = {}
      scaling_config = {
        desired_size = 1 # Settng to 1 to prime the autoscaler cache with the instance types and GPU availability
        max_size     = 50
        min_size     = 0
      }
      taints = []
    },

    {
      name = "anyscale-ondemand-cpu-16CPU-64GB"
      instance_types = [
        "m6a.4xlarge",
        "m5a.4xlarge",
        "m6i.4xlarge",
        "m5.4xlarge",
      ]
      capacity_type = "ON_DEMAND"
      ami_type      = "AL2_x86_64_GPU"
      tags          = {}
      scaling_config = {
        desired_size = 1 # Settng to 1 to prime the autoscaler cache with the instance types and GPU availability
        max_size     = 50
        min_size     = 0
      }
      taints = []
    },

    {
      name = "anyscale-spot-cpu-16CPU-64GB"
      instance_types = [
        "m6a.4xlarge",
        "m5a.4xlarge",
        "m6i.4xlarge",
        "m5.4xlarge",
      ]
      capacity_type = "SPOT"
      ami_type      = "AL2_x86_64_GPU"
      tags          = {}
      scaling_config = {
        desired_size = 1 # Settng to 1 to prime the autoscaler cache with the instance types and GPU availability
        max_size     = 50
        min_size     = 0
      }
      taints = []
    },

    {
      name = "anyscale-ondemand-gpu-16CPU-64GB-1xT4"
      instance_types = [
        "g4dn.4xlarge"
      ]
      capacity_type = "ON_DEMAND"
      ami_type      = "AL2_x86_64_GPU"
      tags          = {}
      scaling_config = {
        desired_size = 1 # Settng to 1 to prime the autoscaler cache with the instance types and GPU availability
        max_size     = 50
        min_size     = 0
      }
      taints = []
    },
    {
      name = "anyscale-ondemand-gpu-16CPU-64GB-1xA10G"
      instance_types = [
        "g5.4xlarge"
      ]
      capacity_type = "ON_DEMAND"
      ami_type      = "AL2_x86_64_GPU"
      tags          = {}
      scaling_config = {
        desired_size = 1 # Settng to 1 to prime the autoscaler cache with the instance types and GPU availability
        max_size     = 50
        min_size     = 0
      }
      taints = []
    }
  ]
}

module "anyscale_k8s_helm" {
  source = "../../../modules/anyscale-k8s-helm"

  module_enabled = true
  cloud_provider = "aws"

  kubernetes_cluster_name = module.anyscale_eks_cluster.eks_cluster_name

  depends_on = [module.anyscale_eks_nodegroups]
}

module "anyscale_k8s_namespace" {
  source = "../../../modules/anyscale-k8s-namespace"

  module_enabled = true
  cloud_provider = "aws"

  kubernetes_cluster_name = module.anyscale_eks_cluster.eks_cluster_name

  depends_on = [module.anyscale_eks_cluster]
}

module "anyscale_k8s_configmap" {
  source = "../../../modules/anyscale-k8s-configmap"

  module_enabled = true
  cloud_provider = "aws"

  anyscale_kubernetes_namespace = module.anyscale_k8s_namespace.anyscale_kubernetes_namespace_name

  depends_on = [module.anyscale_eks_cluster, module.anyscale_k8s_helm]
}
