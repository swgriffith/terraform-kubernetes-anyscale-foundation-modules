# ---------------------------------------------------------------------------------------------------------------------# Example Anyscale K8s Resources - Public Networking
#   This template cretes resources for Anyscale with existing GKE Cluster
#   It creates:
#     - Storage Bucket
#     - Filestore
#     - IAM Service Accounts
#     - Firewall Policy
#     - Helm Charts
#   It expects the following to be already created:
#     - GCP Project
#     - GKE Cluster
#     - GKE Node Pool
#     - VPC
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_labels = merge(tomap({
    anyscale-cloud-id           = var.anyscale_cloud_id,
    anyscale-deploy-environment = var.anyscale_deploy_env
    }),
    var.labels
  )
}

module "anyscale_cloudstorage" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-cloudstorage"
  module_enabled = true

  anyscale_project_id = var.google_project_id
  labels              = local.full_labels
}

module "anyscale_iam" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-iam"
  module_enabled = true

  anyscale_org_id                           = var.anyscale_org_id
  create_anyscale_access_role               = true
  create_anyscale_cluster_node_service_acct = false

  anyscale_project_id = var.google_project_id
}

module "anyscale_filestore" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-filestore"
  module_enabled = true

  filestore_vpc_name = var.existing_vpc_name
  filestore_tier     = "STANDARD"
  filestore_location = "us-central1-b"

  anyscale_project_id = var.google_project_id
  labels              = local.full_labels
}

module "anyscale_firewall" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-vpc-firewall"
  module_enabled = true

  vpc_name = var.existing_vpc_name
  vpc_id   = var.existing_vpc_id

  ingress_with_self_cidr_range = [var.existing_subnet_cidr]
  ingress_from_cidr_map = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = var.customer_ingress_cidr_ranges
    },
    {
      rule        = "ssh-tcp"
      cidr_blocks = var.customer_ingress_cidr_ranges
    }
  ]

  anyscale_project_id = var.google_project_id
}
