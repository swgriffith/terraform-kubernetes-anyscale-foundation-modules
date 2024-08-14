resource "helm_release" "nvidia" {
  count            = local.module_enabled ? 1 : 0
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  namespace        = "nvidia-device-plugin"
  create_namespace = true
  version          = "0.16.2"

  # https://github.com/NVIDIA/k8s-device-plugin?tab=readme-ov-file#deploying-with-gpu-feature-discovery-for-automatic-node-labels
  set {
    name  = "gfd.enabled"
    value = true
  }
}
