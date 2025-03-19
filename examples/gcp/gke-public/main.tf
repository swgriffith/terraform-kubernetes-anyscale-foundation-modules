# ---------------------------------------------------------------------------------------------------------------------# Example Anyscale K8s Resources - Public Networking
#   This template cretes resources for Anyscale.
#
#   It creates:
#     - IAM Service Accounts
#     - Storage Bucket
#     - Filestore
# ---------------------------------------------------------------------------------------------------------------------
locals {
  full_labels = merge(tomap({
    anyscale-cloud-id = var.anyscale_cloud_id,
    }),
    var.labels
  )
}

module "anyscale_cloudstorage" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-cloudstorage"
  module_enabled = true

  bucket_iam_members = [
    "serviceAccount:${google_service_account.gke_nodes.email}"
  ]

  bucket_force_destroy = true
  anyscale_project_id  = var.google_project_id
  labels               = local.full_labels
}

# Get available zones in the region
data "google_compute_zones" "available" {
  project = var.google_project_id
  region  = var.google_region
  status  = "UP"
}

module "anyscale_filestore" {
  #checkov:skip=CKV_TF_1: Example code should use the latest version of the module
  #checkov:skip=CKV_TF_2: Example code should use the latest version of the module
  source         = "github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-filestore"
  module_enabled = true

  filestore_vpc_name = google_compute_network.anyscale.name
  filestore_tier     = "STANDARD"
  filestore_location = data.google_compute_zones.available.names[0]

  anyscale_project_id = var.google_project_id
  labels              = local.full_labels
}

# Create GKE node service account
resource "google_service_account" "gke_nodes" {
  account_id   = "${var.cluster_name}-gke-nodes"
  display_name = "Service Account for GKE nodes"
  project      = var.google_project_id
}

# Grant necessary roles to the service account
#trivy:ignore:avd-gcp-0011
resource "google_project_iam_member" "gke_nodes_roles" {
  #checkov:skip=CKV_GCP_41: "assigned the Service Account User or Service Account Token Creator roles at project level"
  #checkov:skip=CKV_GCP_49: "impersonate or manage Service Accounts used at project level"

  for_each = toset([
    "roles/storage.objectViewer",           # Access to GCS buckets
    "roles/file.editor",                    # Access to Filestore
    "roles/iam.serviceAccountTokenCreator", # Generate presigned URL for GCS
    "roles/logging.logWriter",              # Write logs
    "roles/monitoring.metricWriter",        # Write metrics
    "roles/monitoring.viewer",              # Read metrics
    "roles/artifactregistry.reader"         # Pull container images
  ])

  project = var.google_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}
