# Description: This file contains the terraform configuration to deploy the autoscaler helm chart.
#   https://github.com/kubernetes/autoscaler
locals {
  helm_autoscaler_enabled = local.module_enabled && var.cloud_provider == "aws" && var.anyscale_cluster_autoscaler_chart.enabled
}
resource "helm_release" "anyscale_cluster_autoscaler" {
  count = local.helm_autoscaler_enabled ? 1 : 0

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

  dynamic "set" {
    for_each = local.helm_autoscaler_enabled ? [
      {
        name  = "awsRegion"
        value = var.eks_cluster_region
      }
    ] : []
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  dynamic "set" {
    for_each = local.helm_autoscaler_enabled ? var.anyscale_cluster_autoscaler_chart.values : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
