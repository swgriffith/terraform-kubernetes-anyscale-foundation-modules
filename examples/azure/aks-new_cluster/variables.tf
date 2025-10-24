variable "azure_subscription_id" {
  description = "(Required) Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "(Optional) Name of the resource group."
  type        = string
  default     = "anyscale-lab-rg"
}

variable "azure_location" {
  description = "(Optional) Azure region for all resources."
  type        = string
  default     = "West US"
}

variable "storage_account_name" {
  description = "(Optional) Name of the Azure Storage Account."
  type        = string
  default     = "anyscaleaksstorage"
}

variable "storage_container_name" {
  description = "(Optional) Name of the Azure Storage Container."
  type        = string
  default     = "anyscaleaksstorage"
}

variable "tags" {
  description = "(Optional) Tags applied to all taggable resources."
  type        = map(string)
  default = {
    Test        = "true"
    Environment = "dev"
  }
}

variable "aks_cluster_name" {
  description = "(Optional) Name of the AKS cluster (and related resources)."
  type        = string
  default     = "anyscale-demo"
}

variable "anyscale_operator_namespace" {
  description = "(Optional) Kubernetes namespace for the Anyscale operator."
  type        = string
  default     = "anyscale-operator"
}

variable "node_group_gpu_types" {
  description = <<-EOT
    (Optional) The GPU types of the AKS nodes.
    Possible values: ["T4", "A10", "A100", "H100"]
  EOT
  type        = list(string)
  default     = ["T4"]

  validation {
    condition = alltrue(
      [for g in var.node_group_gpu_types : contains(["T4", "A10", "A100", "H100"], g)]
    )
    error_message = "GPU type must be one of: T4, A10, A100, H100."
  }
}
