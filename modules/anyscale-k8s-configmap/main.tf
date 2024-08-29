locals {
  module_enabled = var.module_enabled

  aws_enabled = local.module_enabled && var.cloud_provider == "aws"
  gcp_enabled = local.module_enabled && var.cloud_provider == "gcp"

  create_anyscale_instance_types = local.module_enabled && var.create_anyscale_instance_types_map

}

resource "kubernetes_config_map" "instance_type" {
  count = local.module_enabled && var.create_anyscale_instance_types_map ? 1 : 0
  metadata {
    name      = "instance-types"
    namespace = var.anyscale_kubernetes_namespace
  }

  data = {
    version = var.anyscale_instance_types_version
    "instance_types.json" = jsonencode(
      [for instance in var.anyscale_instance_types : {
        instanceType = instance.instanceType
        resources = merge(
          {
            CPU    = instance.CPU
            memory = instance.memory
          },
          instance.GPU != null ? { GPU = instance.GPU } : {},
          instance.accelerator_type != null ? { for key, value in instance.accelerator_type : "accelerator_type:${key}" => value } : {}
        )
      }]
    )
  }
}
