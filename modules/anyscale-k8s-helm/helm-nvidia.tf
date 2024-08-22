resource "helm_release" "nvidia" {
  count      = local.module_enabled && var.anyscale_nvidia_device_plugin_chart.enabled ? 1 : 0
  name       = var.anyscale_nvidia_device_plugin_chart.name
  repository = var.anyscale_nvidia_device_plugin_chart.repository
  chart      = var.anyscale_nvidia_device_plugin_chart.chart
  namespace  = var.anyscale_nvidia_device_plugin_chart.namespace
  version    = var.anyscale_nvidia_device_plugin_chart.chart_version

  create_namespace = true

  dynamic "set" {
    for_each = var.anyscale_nvidia_device_plugin_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }
}
