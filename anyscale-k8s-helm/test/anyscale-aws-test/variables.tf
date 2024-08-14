# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
  default     = "us-east-2"
}

variable "anyscale_cloud_id" {
  description = "(Optional) Anyscale Cloud ID. Default is `null`."
  type        = string
  default     = null
  validation {
    condition = (
      var.anyscale_cloud_id == null ? true : (
        length(var.anyscale_cloud_id) > 4 &&
        substr(var.anyscale_cloud_id, 0, 4) == "cld_"
      )
    )
    error_message = "The anyscale_cloud_id value must start with \"cld_\"."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables have defaults, but may be overridden.
# ------------------------------------------------------------------------------
variable "anyscale_deploy_env" {
  description = "(Optional) Anyscale deploy environment. Used in resource names and tags."
  type        = string
  default     = "production"
  validation {
    condition = (
      var.anyscale_deploy_env == "production" || var.anyscale_deploy_env == "development" || var.anyscale_deploy_env == "test"
    )
    error_message = "The anyscale_deploy_env only allows `production`, `test`, or `development`"
  }
}

variable "tags" {
  description = "(Optional) A map of tags to all resources that accept tags."
  type        = map(string)
  default = {
    "test" : true,
    "environment" : "test"
  }
}

variable "kubernetes_cluster_name" {
  description = <<-EOT
    (Optional) The name of the Kubernetes cluster.

    ex:
    ```
    kubernetes_cluster_name = "anyscale-cluster"
    ```
  EOT
  type        = string
  default     = null
}

variable "kubernetes_endpoint_address" {
  description = <<-EOT
    (Optional) The address of the Kubernetes API server.

    ex:
    ```
    kubernetes_endpoint_address = "https://anyscale-cluster.eks.us-east-2.amazonaws.com"
    ```
  EOT
  type        = string
  default     = null
}

variable "kubernetes_cluster_ca_data" {
  description = <<-EOT
    (Optional) The base64 encoded certificate data required to communicate with the Kubernetes cluster.

    ex:
    ```
    kubernetes_cluster_ca_data = "LS0txxxxx"
    ```
  EOT
  type        = string
  default     = null
}
