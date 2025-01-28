# Description: This file contains the terraform configuration to deploy the autoscaler helm chart.
#   https://aws.github.io/eks-charts
locals {
  helm_awsloadbalancer_enabled = local.module_enabled && var.cloud_provider == "aws" && var.anyscale_aws_loadbalancer_chart.enabled
}

# Description: This file contains the terraform configuration to deploy the NVIDIA device plugin helm chart.
resource "helm_release" "aws_loadbalancer" {
  count      = local.helm_awsloadbalancer_enabled ? 1 : 0
  name       = var.anyscale_aws_loadbalancer_chart.name
  repository = var.anyscale_aws_loadbalancer_chart.repository
  chart      = var.anyscale_aws_loadbalancer_chart.chart
  namespace  = var.anyscale_aws_loadbalancer_chart.namespace
  version    = var.anyscale_aws_loadbalancer_chart.chart_version

  create_namespace = true

  dynamic "set" {
    for_each = var.anyscale_aws_loadbalancer_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }

  set {
    name  = "clusterName"
    value = var.kubernetes_cluster_name
  }
}
