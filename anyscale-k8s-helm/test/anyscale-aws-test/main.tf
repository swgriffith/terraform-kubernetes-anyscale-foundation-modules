# ---------------------------------------------------------------------------------------------------------------------
# CREATE Anyscale K8s Helm Resources
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
  source = "../../../aws-anyscale-vpc"

  anyscale_vpc_name = "anyscale-tftest-eks"
  cidr_block        = "172.24.0.0/16"

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets
}
locals {
  # Because subnet ID may not be known at plan time, we cannot use it as a key
  anyscale_subnet_count = length(local.private_subnets)
}

module "eks_securitygroup" {
  source = "../../../aws-anyscale-securitygroups"

  vpc_id = module.eks_vpc.vpc_id

  security_group_name_prefix = "anyscale-tftest-eks-"

  ingress_with_self = [
    { rule = "all-all" }
  ]
}

module "eks_iam_roles" {
  source = "../../../aws-anyscale-iam"

  module_enabled                       = true
  create_anyscale_access_role          = false
  create_cluster_node_instance_profile = false
  create_iam_s3_policy                 = false

  create_anyscale_eks_cluster_role = true
  anyscale_eks_cluster_role_name   = "anyscale-tftest-eks-cluster-role"
  create_anyscale_eks_node_role    = true
  anyscale_eks_node_role_name      = "anyscale-tftest-eks-node-role"

  tags = local.full_tags
}

module "eks_cluster" {
  source = "../../../aws-anyscale-eks-cluster"

  module_enabled = true

  anyscale_subnet_ids        = module.eks_vpc.public_subnet_ids
  anyscale_subnet_count      = local.anyscale_subnet_count
  anyscale_security_group_id = module.eks_securitygroup.security_group_id
  eks_role_arn               = module.eks_iam_roles.iam_anyscale_eks_cluster_role_arn

  tags = local.full_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Create Helm Resources with no optional parameters
# ---------------------------------------------------------------------------------------------------------------------
module "all_defaults" {
  source = "../../"

  module_enabled = true
  cloud_provider = "aws"

  kubernetes_cluster_name     = module.eks_cluster.eks_cluster_name
  kubernetes_endpoint_address = module.eks_cluster.eks_cluster_endpoint
  kubernetes_cluster_ca_data  = module.eks_cluster.eks_cluster_ca_data
}

# ---------------------------------------------------------------------------------------------------------------------
# Do not create any resources
# ---------------------------------------------------------------------------------------------------------------------
module "test_no_resources" {
  source = "../.."

  module_enabled = false
  cloud_provider = "aws"
}
