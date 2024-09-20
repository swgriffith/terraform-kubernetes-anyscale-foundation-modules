# ---------------------------------------------------------------------------------------------------------------------# Example Anyscale K8s Resources - Public Networking
#   This template cretes resources for Anyscale with existing GKE Cluster
#   It creates:
#     - Storage Bucket
#     - Filestore
#     - IAM Service Accounts
#     - Firewall Policy
#     - Nginx ingress controller (Helm Chart)
#   It expects the following to be already created:
#     - GCP Project
#     - GKE cluster
#     - VPC and Subnet
#     - Dataplane service account: See https://docs.anyscale.com/administration/cloud-deployment/deploy-gcp-cloud
#     - Workload Identity Provider
#
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

  bucket_force_destroy = true
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

data "google_compute_network" "existing_vpc" {
  name = var.existing_vpc_name
}

data "google_compute_subnetwork" "exising_subnet" {
  name   = var.existing_subnet_name
  region = var.google_region
}

module "anyscale_firewall" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-vpc-firewall"
  module_enabled = true

  vpc_name = var.existing_vpc_name
  vpc_id   = data.google_compute_network.existing_vpc.id

  ingress_with_self_cidr_range = [data.google_compute_subnetwork.exising_subnet.ip_cidr_range]
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

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.11.2"
  namespace  = "ingress-nginx"

  create_namespace = true
  wait             = false

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.service.annotations.cloud\\.google\\.com/load-balancer-type"
    value = "External"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}
