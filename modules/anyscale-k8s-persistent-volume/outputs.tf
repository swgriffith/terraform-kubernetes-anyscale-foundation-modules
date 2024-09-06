output "kubernetes_persistent_volume_name" {
  description = "The name of the Kubernetes persistent volume."
  value       = try(kubernetes_persistent_volume.anyscale[0].metadata[0].name, "")
}

output "kubernetes_persistent_volume_claim_name" {
  description = "The name of the Kubernetes persistent volume claim."
  value       = try(kubernetes_persistent_volume_claim.anyscale[0].metadata[0].name, "")
}

output "kubernetes_persistent_volume_claim_namespace" {
  description = "The namespace of the Kubernetes persistent volume claim."
  value       = try(kubernetes_persistent_volume_claim.anyscale[0].metadata[0].namespace, "")
}

output "kubernetes_persistent_volume_claim_volumename" {
  description = "The volume name of the Kubernetes persistent volume claim."
  value       = try(kubernetes_persistent_volume_claim.anyscale[0].spec[0].volume_name, "")
}

output "kubernetes_persistent_volume_claim_storageclassname" {
  description = "The storage class name of the Kubernetes persistent volume claim."
  value       = try(kubernetes_persistent_volume_claim.anyscale[0].spec[0].storage_class_name, "")
}
