output "anyscale_registration_command" {
  description = "The Anyscale registration command."
  value       = <<-EOT
    anyscale cloud register --provider gcp \
    --name <anyscale_cloud_name> \
    --compute-stack k8s \
    --project-id ${var.google_project_id} \
    --vpc-name ${var.existing_vpc_name} \
    --region ${var.google_region} \
    --cloud-storage-bucket-name ${module.anyscale_cloudstorage.cloudstorage_bucket_name} \
    --filestore-instance-id ${module.anyscale_filestore.anyscale_filestore_name} \
    --filestore-location ${module.anyscale_filestore.anyscale_filestore_location} \
    --anyscale-service-account-email ${module.anyscale_iam.iam_anyscale_access_service_acct_email} \
    --provider-name ${module.anyscale_iam.iam_workload_identity_provider_name} \
    --kubernetes-namespaces ${var.anyscale_k8s_namespace} \
    --kubernetes-ingress-external-address ${module.anyscale_k8s_helm.nginx_ingress_lb_ips[0]} \
    --kubernetes-zones ${join(",", data.google_container_cluster.anyscale.node_locations)} \
    --anyscale-operator-iam-identity ${module.anyscale_iam.iam_anyscale_cluster_node_service_acct_email}
  EOT
}
