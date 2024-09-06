locals {
  module_enabled = var.module_enabled
}

resource "kubernetes_namespace" "anyscale" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name = var.anyscale_kubernetes_namespace
  }
}
