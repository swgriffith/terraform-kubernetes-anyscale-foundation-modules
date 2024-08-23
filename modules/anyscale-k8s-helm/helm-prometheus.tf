# Description: This file contains the terraform configuration to deploy the prometheus helm chart.
resource "helm_release" "prometheus" {
  count = local.module_enabled && var.anyscale_prometheus_chart.enabled ? 1 : 0

  name       = var.anyscale_prometheus_chart.name
  repository = var.anyscale_prometheus_chart.repository
  chart      = var.anyscale_prometheus_chart.chart
  namespace  = var.anyscale_prometheus_chart.namespace
  version    = var.anyscale_prometheus_chart.chart_version

  create_namespace = true

  dynamic "set" {
    for_each = var.anyscale_prometheus_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }

  timeout = 900
}
