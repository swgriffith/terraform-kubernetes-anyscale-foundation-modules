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

variable "anyscale_kubernetes_namespace" {
  description = <<-EOT
    (Optional) The namespace to install the Anyscale resources.

    ex:
    ```
    anyscale_kubernetes_namespace = "anyscale-k8s"
    ```
  EOT
  type        = string
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
# Instance Types
# ------------------
variable "create_anyscale_instance_types_map" {
  description = <<-EOT
    (Optional) Determines if the instance-types configmap should be created.

    ex:
    ```
    create_anyscale_instance_types_map = true
    ```
  EOT
  type        = bool
  default     = true
}

variable "anyscale_instance_types_version" {
  description = <<-EOT
    (Optional) The version of the instance-types configmap.

    ex:
    ```
    anyscale_instance_types_version = "v1"
    ```
  EOT
  type        = string
  default     = "v1"
}

variable "anyscale_instance_types" {
  description = <<-EOT
    (Optional) A list of instance types to create in the instance-types configmap.

    ex:
    ```
    anyscale_instance_types = [
      {
        instanceType = "8CPU-32GB"
        CPU          = 8
        memory       = 32Gi # 32gb
      },
      {
        instanceType = "4CPU-16GB-1xA10"
        CPU          = 4
        GPU          = 1
        memory       = 17179869184 # 16gb converted to bytes
        accelerator_type = {"A10G" = 1}
      },
      {
        instanceType = "8CPU-32GB-1xA10"
        CPU          = 8
        GPU          = 1
        memory       = 32Gi # 32gb
        accelerator_type = {"A10G" = 1}
      },
      {
        instanceType = "8CPU-32GB-1xT4"
        CPU          = 8
        GPU          = 1
        memory       = 32Gi # 32gb
        accelerator_type = {"T4" = 1}
      }
    ]
    ```
  EOT
  type = list(object({
    instanceType     = string
    CPU              = number
    GPU              = optional(number)
    memory           = string
    accelerator_type = optional(map(number)) # accelerator_type should be a map of key-value pairs
  }))
  default = [
    {
      instanceType = "8CPU-32GB"
      CPU          = 8
      memory       = "32Gi"
    }
  ]
}
