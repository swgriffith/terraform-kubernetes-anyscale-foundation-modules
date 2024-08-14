# Description: This file contains the terraform configuration to deploy the autoscaler helm chart.
#   https://github.com/kubernetes/autoscaler

resource "helm_release" "anyscale_cluster_autoscaler" {
  count = local.module_enabled && var.cloud_provider == "aws" ? 1 : 0

  name             = var.anyscale_cluster_autoscaler_chart.name
  repository       = var.anyscale_cluster_autoscaler_chart.repository
  chart            = var.anyscale_cluster_autoscaler_chart.chart
  namespace        = var.anyscale_cluster_autoscaler_chart.namespace
  version          = var.anyscale_cluster_autoscaler_chart.chart_version
  create_namespace = true
  wait             = true

  set {
    name  = "autoDiscovery.clusterName"
    value = var.kubernetes_cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current[0].name
  }

  dynamic "set" {
    for_each = var.anyscale_cluster_autoscaler_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }
}
