output "lb_hostnames" {
  value = try(data.kubernetes_service.ingress[0].status.0.load_balancer.0.ingress.*.hostname, [])
}

output "lb_ips" {
  value = try(data.kubernetes_service.ingress[0].status.0.load_balancer.0.ingress.*.ip, [])
}

output "helm_ingress_status" {
  value = try(helm_release.ingress[0].status, "")
}

output "helm_nvidia_status" {
  value = try(helm_release.nvidia[0].status, "")
}

output "helm_autoscaler_status" {
  value = try(helm_release.anyscale_cluster_autoscaler[0].status, "")
}
