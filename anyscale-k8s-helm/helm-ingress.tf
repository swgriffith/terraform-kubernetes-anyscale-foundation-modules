# --------------------------------------------------------------------------------
# Description: This file contains the terraform configuration to deploy the ingress controller using helm.
# --------------------------------------------------------------------------------

resource "helm_release" "nginx_ingress" {
  count = local.module_enabled ? 1 : 0

  name             = var.anyscale_ingress_chart.name
  repository       = var.anyscale_ingress_chart.repository
  chart            = var.anyscale_ingress_chart.chart
  namespace        = var.anyscale_ingress_chart.namespace
  version          = var.anyscale_ingress_chart.chart_version
  create_namespace = true
  wait             = true

  dynamic "set" {
    for_each = var.anyscale_ingress_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [
    time_sleep.wait_helm_termination
  ]
}



data "kubernetes_service" "nginx_ingress" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name      = "${helm_release.nginx_ingress[0].name}-${helm_release.nginx_ingress[0].chart}-controller"
    namespace = var.anyscale_ingress_chart.namespace
  }
}
