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

variable "kubernetes_persistent_volume_name" {
  description = <<-EOT
    (Optional) The name of the Kubernetes persistent volume.

    ex:
    ```
    kubernetes_persistent_volume_name = "anyscale-nfs"
    ```
  EOT
  type        = string
  default     = "anyscale-nfs"
}

variable "kubernetes_persistent_volume_size" {
  description = <<-EOT
    (Optional) The size of the Kubernetes persistent volume.

    When using AWS EFS, this is just a placeholder. The actual size is elastically built, making this just a placeholder

    ex:
    ```
    kubernetes_persistent_volume_size = "20Gi"
    ```
  EOT
  type        = string
  default     = "20Gi"
}

variable "kubernetes_persistent_volume_claim_name" {
  description = <<-EOT
    (Optional) The name of the Kubernetes persistent volume claim.

    ex:
    ```
    kubernetes_persistent_volume_claim_name = "anyscale-nfs-claim"
    ```
  EOT
  type        = string
  default     = "anyscale-nfs-claim"
}

variable "anyscale_kubernetes_namespace" {
  description = <<-EOT
    (Optional) The name of the Kubernetes namespace.

    ex:
    ```
    anyscale_kubernetes_namespace = "anyscale-k8s"
    ```
  EOT
  type        = string
  default     = "anyscale-k8s"
}

variable "aws_efs_file_system_id" {
  description = <<-EOT
    (Optional) The ID of the EFS file system.

    Required if `cloud_provider` is `aws`.

    ex:
    ```
    aws_efs_file_system_id = "fs-12345678"
    ```
  EOT
  type        = string
  default     = null
}

variable "gcp_filestore_ip" {
  description = <<-EOT
    (Optional) The Filestore IP address.

    Required if `cloud_provider` is `gcp`.

    ex:
    ```
    gcp_filestore_ip = "172.16.0.12"
    ```
  EOT
  type        = string
  default     = null
}

variable "gcp_filestore_share_name" {
  description = <<-EOT
    (Optional) The Filestore share name.

    Required if `cloud_provider` is `gcp`.

    ex:
    ```
    gcp_filestore_share_name = "my-share"
    ```
  EOT
  type        = string
  default     = null
}
