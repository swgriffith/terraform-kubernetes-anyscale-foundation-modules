locals {
  module_enabled                        = var.module_enabled
  helm_termination_grace_period_seconds = 300 # 5 minutes to allow connection draining
}

# Helm chart destruction will return immediately, we need to wait until the pods are fully evicted
# https://github.com/hashicorp/terraform-provider-helm/issues/593
resource "time_sleep" "wait_helm_termination" {
  count = local.module_enabled ? 1 : 0

  destroy_duration = "${local.helm_termination_grace_period_seconds}s"
}
