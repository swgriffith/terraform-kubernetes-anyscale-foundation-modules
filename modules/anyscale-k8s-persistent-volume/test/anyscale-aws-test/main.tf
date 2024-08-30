# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale K8s ConfigMap Resources
#   This template creates EKS resources for Anyscale
#   Requires:
#     - VPC
#     - Security Group
#     - IAM Roles
#     - EKS Cluster
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

# ---------------------------------------------------------------------------------------------------------------------
# Create resources for EKS TF Module
#   Creates a VPC
#   Creates a Security Group
#   Creates IAM Roles
# ---------------------------------------------------------------------------------------------------------------------
locals {
  public_subnets  = ["172.24.101.0/24", "172.24.102.0/24", "172.24.103.0/24"]
  private_subnets = ["172.24.20.0/24", "172.24.21.0/24", "172.24.22.0/24"]
}
module "eks_vpc" {
  #checkov:skip=CKV_TF_1: Test code should use the latest version of the module
  source = "../../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-vpc"

  anyscale_vpc_name = "tftest-k8s-persistentvol"
  cidr_block        = "172.24.0.0/16"

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}
locals {
  # Because subnet ID may not be known at plan time, we cannot use it as a key
  anyscale_subnet_count = length(local.private_subnets)
}

module "eks_securitygroup" {
  #checkov:skip=CKV_TF_1: Test code should use the latest version of the module
  source = "../../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-securitygroups"

  vpc_id = module.eks_vpc.vpc_id

  security_group_name_prefix = "tftest-k8s-persistentvol-"

  ingress_with_self = [
    { rule = "all-all" }
  ]
}

module "eks_iam_roles" {
  #checkov:skip=CKV_TF_1: Test code should use the latest version of the module
  source = "../../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-iam"

  module_enabled                       = true
  create_anyscale_access_role          = true
  anyscale_access_role_name            = "tftest-k8s-persistentvol-controlplane-role"
  create_cluster_node_instance_profile = false
  create_iam_s3_policy                 = false

  create_anyscale_eks_cluster_role = true
  anyscale_eks_cluster_role_name   = "tftest-k8s-persistentvol-cluster-role"
  create_anyscale_eks_node_role    = true
  anyscale_eks_node_role_name      = "tftest-k8s-persistentvol-node-role"

  anyscale_eks_cluster_oidc_arn = module.eks_cluster.eks_cluster_oidc_provider_arn
  anyscale_eks_cluster_oidc_url = module.eks_cluster.eks_cluster_oidc_provider_url

  create_eks_efs_csi_driver_role = true
  eks_efs_csi_role_name          = "anyscale-eks-public-efs-csi-role"
  efs_file_system_arn            = module.anyscale_efs.efs_arn

  tags = local.full_tags
}

module "anyscale_efs" {
  source = "../../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-efs"

  module_enabled = true

  anyscale_efs_name             = "anyscale-eks-public-efs"
  mount_targets_subnet_count    = local.anyscale_subnet_count
  mount_targets_subnets         = module.eks_vpc.private_subnet_ids
  associated_security_group_ids = [module.eks_securitygroup.security_group_id]

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

module "eks_cluster" {
  source = "../../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-eks-cluster"

  module_enabled = true

  anyscale_subnet_ids        = module.eks_vpc.public_subnet_ids
  anyscale_subnet_count      = local.anyscale_subnet_count
  anyscale_security_group_id = module.eks_securitygroup.security_group_id
  eks_role_arn               = module.eks_iam_roles.iam_anyscale_eks_cluster_role_arn
  anyscale_eks_name          = "tftest-k8s-persistentvol"

  tags = local.full_tags

  eks_addons = [
    # Add EFS mount
    {
      addon_name               = "aws-efs-csi-driver"
      addon_version            = "v2.0.7-eksbuild.1"
      service_account_role_arn = module.eks_iam_roles.iam_anyscale_eks_efs_csi_driver_role_arn
    }
  ]
  eks_addons_depends_on = module.anyscale_eks_nodegroups

  depends_on = [module.eks_vpc, module.eks_securitygroup]
}

module "anyscale_eks_nodegroups" {
  source = "../../../../../terraform-aws-anyscale-cloudfoundation-modules/modules/aws-anyscale-eks-nodegroups"

  module_enabled = true

  eks_node_role_arn = module.eks_iam_roles.iam_anyscale_eks_node_role_arn
  eks_cluster_name  = module.eks_cluster.eks_cluster_name
  subnet_ids        = module.eks_vpc.private_subnet_ids

  tags = local.full_tags
}


# ---------------------------------------------------------------------------------------------------------------------
# Create Resources with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../../"

  module_enabled = true
  cloud_provider = "aws"


  depends_on = [module.eks_cluster]

}

# ---------------------------------------------------------------------------------------------------------------------
# Create Resources with as many optional parameters as possible
# ---------------------------------------------------------------------------------------------------------------------
# module "kitchen_sink" {
#   source = "../../"

#   module_enabled = true
#   cloud_provider = "aws"

#   anyscale_kubernetes_namespace = "tftest-k8s-persistentvol"
#   depends_on                    = [module.eks_cluster]

# }

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  module_enabled = false
  cloud_provider = "aws"
}
