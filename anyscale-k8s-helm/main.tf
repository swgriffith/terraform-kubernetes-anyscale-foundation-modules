locals {
  module_enabled = var.module_enabled
}


data "kubernetes_service" "ingress" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name      = "${helm_release.ingress[0].name}-${helm_release.ingress[0].chart}-controller"
    namespace = var.ingress_namespace
  }
}
