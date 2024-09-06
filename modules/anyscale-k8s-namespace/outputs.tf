output "anyscale_kubernetes_namespace_name" {
  description = "The name of the Kubernetes namespace."
  value       = try(kubernetes_namespace.anyscale[0].metadata[0].name, "")
}
