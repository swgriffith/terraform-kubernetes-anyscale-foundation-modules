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

variable "ingress_namespace" {
  type        = string
  description = <<-EOT
    (Optional) Namespace to place the ingress-nginx chart into.

    ex:
    ```
    ingress_namespace = "ingress-nginx"
    ```
  EOT
  default     = "ingress-nginx"
}



# ------------------------------------------------------------------------------
# Helm Chart Variables
# ------------------------------------------------------------------------------
variable "anyscale_cluster_autoscaler_chart" {
  description = <<-EOT
    (Optional) The Helm chart to install the Cluster Autoscaler.

    ex:
    ```
    anyscale_cluster_autoscaler_chart = {
      name          = "cluster-autoscaler"
      respository   = "https://kubernetes.github.io/autoscaler"
      chart         = "cluster-autoscaler"
      chart_version = "9.37.0"
      namespace     = "kube-system"
      values        = {
        "some.other.config" = "value"
      }
    }
    ```
  EOT
  type = object({
    name          = string
    repository    = string
    chart         = string
    chart_version = string
    namespace     = string
    values        = map(string)
  })
  default = {
    name          = "anyscale-cluster-autoscaler"
    repository    = "https://kubernetes.github.io/autoscaler"
    chart         = "cluster-autoscaler"
    chart_version = "9.37.0"
    namespace     = "kube-system"
    values        = {}
  }
}
