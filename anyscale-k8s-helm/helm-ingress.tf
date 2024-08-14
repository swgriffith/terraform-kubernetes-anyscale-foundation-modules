resource "helm_release" "ingress" {
  count = local.module_enabled ? 1 : 0

  name             = "anyscale-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = var.ingress_namespace
  version          = "4.11.1"
  create_namespace = true
  wait             = true
  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "controller.allowSnippetAnnotations"
    value = true
  }

  set {
    name  = "controller.autoscaling.enabled"
    value = true
  }
}
