output "nginx_ingress_lb_hostnames" {
  description = "Hostnames of the nginx load balancer"
  value       = try(data.kubernetes_service.nginx_ingress[0].status[0].load_balancer[0].ingress[*].hostname, [])
}

output "nginx_ingress_lb_ips" {
  description = "IPs of the nginx load balancer"
  value       = try(data.kubernetes_service.nginx_ingress[0].status[0].load_balancer[0].ingress[*].ip, [])
}

output "helm_nginx_ingress_status" {
  description = "Status of the Ingress Helm release"
  value       = try(helm_release.nginx_ingress[0].status, "")
}

output "helm_nvidia_status" {
  description = "Status of the Nvidia Helm release"
  value       = try(helm_release.nvidia[0].status, "")
}

output "helm_autoscaler_status" {
  description = "Status of the Cluster Autoscaler Helm release"
  value       = try(helm_release.anyscale_cluster_autoscaler[0].status, "")
}
