locals {
  kubernetes_zones = join(",", module.anyscale_vpc.availability_zones)
}

data "aws_iam_role" "default_nodegroup" {
  name = module.eks.eks_managed_node_groups["default"].iam_role_name
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster. This is used for Helm chart values."
  value       = var.eks_cluster_name
}

output "aws_region" {
  description = "The AWS region. This is used for Helm chart values."
  value       = var.aws_region
}

output "anyscale_register_command" {
  description = <<-EOF
    Anyscale register command.
    This output can be used with the Anyscale CLI to register a new Anyscale Cloud.
    You will need to replace `<CUSTOMER_DEFINED_NAME>` with a name of your choosing before running the Anyscale CLI command.
  EOF
  value       = <<-EOT
    anyscale cloud register --provider aws \
      --name <CUSTOMER_DEFINED_NAME> \
      --compute-stack k8s \
      --region ${var.aws_region} \
      --s3-bucket-id ${module.anyscale_s3.s3_bucket_id} \
      --efs-id ${module.anyscale_efs.efs_id} \
      --kubernetes-zones ${local.kubernetes_zones} \
      --anyscale-operator-iam-identity ${data.aws_iam_role.default_nodegroup.arn}
  EOT
}
