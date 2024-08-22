locals {
  module_enabled = var.module_enabled

  aws_enabled = local.module_enabled && var.cloud_provider == "aws"
  gcp_enabled = local.module_enabled && var.cloud_provider == "gcp"
}

resource "kubernetes_config_map" "aws_auth" {
  count = local.aws_enabled ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = var.aws_controlplane_role_arn
        username = "bk_user"
        groups   = ["system:masters"]
      },
      {
        rolearn  = var.aws_dataplane_role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }
}
