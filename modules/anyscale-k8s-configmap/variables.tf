# ------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables must be set when using this module.
# ------------------------------------------------------------------------------
variable "cloud_provider" {
  description = <<-EOT
    (Required) The cloud provider (aws or gcp)

    ex:
    ```
    cloud_provider = "aws"
    ```
  EOT
  type        = string
  validation {
    condition = (
      var.cloud_provider == "aws" || var.cloud_provider == "gcp"
    )
    error_message = "The cloud_provider only allows `aws` or `gcp`"
  }
}

variable "kubernetes_cluster_name" {
  type        = string
  description = <<-EOT
    (Optional) The name of the Kubernetes cluster.

    ex:
    ```
    kubernetes_cluster_name = "my-cluster"
    ```
  EOT
  default     = null
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "module_enabled" {
  description = <<-EOT
    (Optional) Determines if this module should create resources.

    If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.
    ex:
    ```
    module_enabled = true
    ```
  EOT
  type        = bool
  default     = false
}

# ------------------
# AWS Related
# ------------------
variable "create_aws_auth_configmap" {
  description = <<-EOT
    (Optional) Determines if the aws-auth configmap should be created.

    Only applies if `cloud_provider` is set to `aws`.

    ex:
    ```
    create_aws_auth_configmap = true
    ```
  EOT
  type        = bool
  default     = false
}


variable "aws_controlplane_role_arn" {
  description = <<-EOT
    (Optional) The ARN of the AWS IAM role that will be used by the EKS cluster to access AWS services.

    Required if `cloud_provider` is set to `aws`.

    ex:
    ```
    aws_controlplane_role_arn = "arn:aws:iam::123456789012:role/my-eks-controlplane-role"
    ```
  EOT
  type        = string
  default     = null
}
variable "aws_dataplane_role_arn" {
  description = <<-EOT
    (Optional) The ARN of the AWS IAM role that will be used by the EKS cluster to access AWS services.

    Required if `cloud_provider` is set to `aws`.

    ex:
    ```
    aws_dataplane_role_arn = "arn:aws:iam::123456789012:role/my-eks-dataplane-role"
    ```
  EOT
  type        = string
  default     = null
}
