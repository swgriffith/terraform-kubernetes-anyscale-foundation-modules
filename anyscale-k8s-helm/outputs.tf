output "lb_hostnames" {
  description = "Hostnames of the Load Balancer"
  value       = try(data.kubernetes_service.ingress[0].status[0].load_balancer[0].ingress[*].hostname, [])
}

output "lb_ips" {
  description = "IPs of the Load Balancer"
  value       = try(data.kubernetes_service.ingress[0].status[0].load_balancer[0].ingress[*].ip, [])
}

output "helm_ingress_status" {
  description = "Status of the Ingress Helm release"
  value       = try(helm_release.ingress[0].status, "")
}

output "helm_nvidia_status" {
  description = "Status of the Nvidia Helm release"
  value       = try(helm_release.nvidia[0].status, "")
}

output "helm_autoscaler_status" {
  description = "Status of the Cluster Autoscaler Helm release"
  value       = try(helm_release.anyscale_cluster_autoscaler[0].status, "")
}
