
output "eks_cluster_name" {
  description = "The name of the anyscale resource."
  value       = module.eks_cluster.eks_cluster_name
}

output "eks_cluster_arn" {
  description = "The arn of the anyscale resource."
  value       = module.eks_cluster.eks_cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the anyscale resource."
  value       = module.eks_cluster.eks_cluster_endpoint
}

output "eks_kubeconfig" {
  description = "The kubeconfig of the anyscale resource."
  value       = module.eks_cluster.eks_kubeconfig
}
