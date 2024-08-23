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
  wait             = true

  dynamic "set" {
    for_each = var.anyscale_ingress_chart.values
    content {
      name  = set.key
      value = set.value
    }
  }

  dynamic "set" {
    for_each = var.cloud_provider == "aws" ? [
      {
        name  = "controller.service.annotations.service.beta.kubernetes.io/aws-load-balancer-type"
        value = "nlb"
      },
      {
        name  = "controller.service.annotations.service.beta.kubernetes.io/aws-load-balancer-name"
        value = "anyscale-ingress-nginx"
      }
    ] : []
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [
    kubernetes_namespace.ingress_nginx,
    time_sleep.wait_helm_termination[0]
  ]

  timeout = 600

}



data "kubernetes_service" "nginx_ingress" {
  count = local.module_enabled ? 1 : 0
  metadata {
    name      = "${helm_release.nginx_ingress[0].name}-${helm_release.nginx_ingress[0].chart}-controller"
    namespace = var.anyscale_ingress_chart.namespace
  }
}
