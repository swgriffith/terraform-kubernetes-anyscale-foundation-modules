# --------------------------------------------------------------------------------
# Description: This file contains the terraform configuration to deploy the ingress controller using helm.
# --------------------------------------------------------------------------------

resource "kubernetes_namespace" "ingress_nginx" {
  count = local.module_enabled && var.anyscale_ingress_chart.enabled ? 1 : 0

  metadata {
    name = try(var.anyscale_ingress_chart.namespace, "ingress-nginx")
  }

}

resource "helm_release" "nginx_ingress" {
  count = local.module_enabled && var.anyscale_ingress_chart.enabled ? 1 : 0

  name             = var.anyscale_ingress_chart.name
  repository       = var.anyscale_ingress_chart.repository
  chart            = var.anyscale_ingress_chart.chart
  namespace        = kubernetes_namespace.ingress_nginx[0].metadata[0].name
  version          = var.anyscale_ingress_chart.chart_version
  create_namespace = false
  wait             = false

  dynamic "set" {
    for_each = var.anyscale_ingress_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }

  # Configure the ingress controller for AWS NLB
  dynamic "set" {
    for_each = var.cloud_provider == "aws" ? [
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
        value = "nlb"
      },
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
        value = "true"
      }
    ] : []
    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

  dynamic "set" {
    for_each = var.cloud_provider == "aws" && var.anyscale_ingress_internal_lb ? [
      {
        name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-internal"
        value = "true"
      }
    ] : []
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  # Configure the ingress controller for GCP Internal Load Balancer
  dynamic "set" {
    for_each = var.cloud_provider == "gcp" && var.anyscale_ingress_internal_lb ? [
      {
        name  = "controller.service.annotations.networking\\.gke\\.io/load-balancer-type"
        value = "Internal"
      }
    ] : []
    content {
      name  = set.value["name"]
      value = set.value["value"]
    }
  }

  depends_on = [
    kubernetes_namespace.ingress_nginx,
    time_sleep.wait_helm_termination[0]
  ]

  timeout = 600

}

resource "time_sleep" "wait_ingress" {
  count = local.module_enabled && var.anyscale_ingress_chart.enabled && var.cloud_provider == "gcp" ? 1 : 0

  depends_on      = [helm_release.nginx_ingress]
  create_duration = "30s"
}


data "kubernetes_service" "nginx_ingress" {
  count = local.module_enabled && var.anyscale_ingress_chart.enabled ? 1 : 0
  metadata {
    name      = "${helm_release.nginx_ingress[0].name}-${helm_release.nginx_ingress[0].chart}-controller"
    namespace = var.anyscale_ingress_chart.namespace
  }

  depends_on = [time_sleep.wait_ingress]
}
