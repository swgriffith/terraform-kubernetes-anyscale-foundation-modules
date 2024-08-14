locals {
  module_enabled = var.module_enabled
}

# AWS Data Sources
data "aws_caller_identity" "current" {
  count = var.cloud_provider == "aws" ? 1 : 0
}
data "aws_region" "current" {
  count = var.cloud_provider == "aws" ? 1 : 0
}

# GCP Data Sources
data "google_client_config" "current" {
  count = var.cloud_provider == "gcp" ? 1 : 0
}

data "kubernetes_service" "ingress" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name      = "${helm_release.ingress[0].name}-${helm_release.ingress[0].chart}-controller"
    namespace = var.ingress_namespace
  }
}
