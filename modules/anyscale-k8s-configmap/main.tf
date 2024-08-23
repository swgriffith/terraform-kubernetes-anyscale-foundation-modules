locals {
  module_enabled = var.module_enabled

  aws_enabled = local.module_enabled && var.cloud_provider == "aws"
  gcp_enabled = local.module_enabled && var.cloud_provider == "gcp"

  aws_auth_configmap_data = {
    mapRoles = yamlencode([
      {
        rolearn = var.aws_controlplane_role_arn
        groups  = ["system:masters"]
      },
      {
        rolearn  = var.aws_dataplane_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }
}

resource "kubernetes_config_map" "aws_auth" {
  count = local.aws_enabled && var.create_aws_auth_configmap ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    # We are ignoring the data here since we will manage it with the resource below
    # This is only intended to be used in scenarios where the configmap does not exist
    ignore_changes = [data, metadata[0].labels, metadata[0].annotations]
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = local.aws_enabled ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true

  data       = local.aws_auth_configmap_data
  depends_on = [kubernetes_config_map.aws_auth]
}
