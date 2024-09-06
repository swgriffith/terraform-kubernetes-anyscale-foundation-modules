locals {
  module_enabled = var.module_enabled
}

resource "kubernetes_persistent_volume" "anyscale" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name = var.kubernetes_persistent_volume_name
  }

  spec {
    capacity = {
      storage = var.kubernetes_persistent_volume_size
    }

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"

    storage_class_name = var.cloud_provider == "aws" ? "efs-sc" : "filestore-sc"
    persistent_volume_source {
      csi {
        driver        = var.cloud_provider == "aws" ? "efs.csi.aws.com" : "filestore.csi.storage.gke.io"
        volume_handle = var.cloud_provider == "aws" ? var.aws_efs_file_system_id : "${var.gcp_filestore_ip}/${var.gcp_filestore_share_name}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "anyscale" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name      = var.kubernetes_persistent_volume_claim_name
    namespace = var.anyscale_kubernetes_namespace
  }

  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = var.kubernetes_persistent_volume_size
      }
    }
    storage_class_name = var.cloud_provider == "aws" ? "efs-sc" : "filestore-sc"
  }
}
