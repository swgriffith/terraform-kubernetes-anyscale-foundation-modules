data "google_client_config" "provider" {}

data "google_container_cluster" "anyscale" {
  name     = var.existing_gke_cluster_name
  location = var.existing_gke_cluster_region
}
