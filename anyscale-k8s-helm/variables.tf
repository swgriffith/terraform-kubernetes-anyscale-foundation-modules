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


# ------------------------------------------------------------------------------
# Helm Chart Variables
# ------------------------------------------------------------------------------
variable "anyscale_cluster_autoscaler_chart" {
  description = <<-EOT
    (Optional) The Helm chart to install the Cluster Autoscaler.

    ex:
    ```
    anyscale_cluster_autoscaler_chart = {
      enabled       = true
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
    enabled       = bool
    name          = string
    repository    = string
    chart         = string
    chart_version = string
    namespace     = string
    values        = map(string)
  })
  default = {
    enabled       = true
    name          = "anyscale-cluster-autoscaler"
    repository    = "https://kubernetes.github.io/autoscaler"
    chart         = "cluster-autoscaler"
    chart_version = "9.37.0"
    namespace     = "kube-system"
    values        = {}
  }
}

variable "anyscale_ingress_chart" {
  description = <<-EOT
    (Optional) The Helm chart to install the Cluster Ingress.

    ex:
    ```
    anyscale_ingress_chart = {
      enabled       = true
      name          = "anyscale-ingress"
      respository   = "https://kubernetes.github.io/ingress-nginx"
      chart         = "ingress-nginx"
      chart_version = "4.11.1"
      namespace     = "ingress-nginx"
      values        = {
        "some.other.config" = "value"
      }
    }
    ```
  EOT
  type = object({
    enabled       = bool
    name          = string
    repository    = string
    chart         = string
    chart_version = string
    namespace     = string
    values        = map(string)
  })
  default = {
    enabled       = true
    name          = "anyscale-ingress"
    repository    = "https://kubernetes.github.io/ingress-nginx"
    chart         = "ingress-nginx"
    chart_version = "4.11.1"
    namespace     = "ingress-nginx"
    values = {
      "controller.service.type"                                                                = "LoadBalancer"
      "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type" = "nlb"
      "controller.allowSnippetAnnotations"                                                     = "true"
      "controller.autoscaling.enabled"                                                         = "true"
    }
  }
}

variable "anyscale_nvidia_device_plugin_chart" {
  description = <<-EOT
    (Optional) The Helm chart to install the NVIDIA Device Plugin.

    Valid settings can be found in the [nvidia documentation](https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file#deploying-with-gpu-feature-discovery-for-automatic-node-labels)

    ex:
    ```
    anyscale_nvidia_device_plugin_chart = {
      enabled       = true
      name          = "nvidia-device-plugin"
      respository   = "https://nvidia.github.io/k8s-device-plugin"
      chart         = "nvidia-device-plugin"
      chart_version = "0.16.2"
      namespace     = "nvidia-device-plugin"
      values        = {
        "some.other.config" = "value"
      }
    }
    ```
  EOT
  type = object({
    enabled       = bool
    name          = string
    repository    = string
    chart         = string
    chart_version = string
    namespace     = string
    values        = map(string)
  })
  default = {
    enabled       = true
    name          = "anyscale-nvidia-device-plugin"
    repository    = "https://nvidia.github.io/k8s-device-plugin"
    chart         = "nvidia-device-plugin"
    chart_version = "0.16.2"
    namespace     = "nvidia-device-plugin"
    values = {
      "gfd.enabled" = "true"
    }
  }
}
