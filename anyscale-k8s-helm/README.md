[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# anyscale-k8s-helm
This module creates Kubernetes helm charts for Anyscale applications and workloads.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.63.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.15.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.32.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.anyscale_cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nginx_ingress](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.nvidia](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [time_sleep.wait_helm_termination](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubernetes_service.nginx_ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | (Required) The cloud provider (aws or gcp)<br><br>ex:<pre>cloud_provider = "aws"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_cluster_autoscaler_chart"></a> [anyscale\_cluster\_autoscaler\_chart](#input\_anyscale\_cluster\_autoscaler\_chart) | (Optional) The Helm chart to install the Cluster Autoscaler.<br><br>ex:<pre>anyscale_cluster_autoscaler_chart = {<br>  name          = "cluster-autoscaler"<br>  respository   = "https://kubernetes.github.io/autoscaler"<br>  chart         = "cluster-autoscaler"<br>  chart_version = "9.37.0"<br>  namespace     = "kube-system"<br>  values        = {<br>    "some.other.config" = "value"<br>  }<br>}</pre> | <pre>object({<br>    name          = string<br>    repository    = string<br>    chart         = string<br>    chart_version = string<br>    namespace     = string<br>    values        = map(string)<br>  })</pre> | <pre>{<br>  "chart": "cluster-autoscaler",<br>  "chart_version": "9.37.0",<br>  "name": "anyscale-cluster-autoscaler",<br>  "namespace": "kube-system",<br>  "repository": "https://kubernetes.github.io/autoscaler",<br>  "values": {}<br>}</pre> | no |
| <a name="input_anyscale_ingress_chart"></a> [anyscale\_ingress\_chart](#input\_anyscale\_ingress\_chart) | (Optional) The Helm chart to install the Cluster Ingress.<br><br>ex:<pre>anyscale_ingress_chart = {<br>  name          = "anyscale-ingress"<br>  respository   = "https://kubernetes.github.io/ingress-nginx"<br>  chart         = "ingress-nginx"<br>  chart_version = "4.11.1"<br>  namespace     = "ingress-nginx"<br>  values        = {<br>    "some.other.config" = "value"<br>  }<br>}</pre> | <pre>object({<br>    name          = string<br>    repository    = string<br>    chart         = string<br>    chart_version = string<br>    namespace     = string<br>    values        = map(string)<br>  })</pre> | <pre>{<br>  "chart": "ingress-nginx",<br>  "chart_version": "4.11.1",<br>  "name": "anyscale-ingress",<br>  "namespace": "ingress-nginx",<br>  "repository": "https://kubernetes.github.io/ingress-nginx",<br>  "values": {<br>    "controller.allowSnippetAnnotations": "true",<br>    "controller.autoscaling.enabled": "true",<br>    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type": "nlb",<br>    "controller.service.type": "LoadBalancer"<br>  }<br>}</pre> | no |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | (Optional) The name of the Kubernetes cluster.<br><br>ex:<pre>kubernetes_cluster_name = "my-cluster"</pre> | `string` | `null` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_autoscaler_status"></a> [helm\_autoscaler\_status](#output\_helm\_autoscaler\_status) | Status of the Cluster Autoscaler Helm release |
| <a name="output_helm_nginx_ingress_status"></a> [helm\_nginx\_ingress\_status](#output\_helm\_nginx\_ingress\_status) | Status of the Ingress Helm release |
| <a name="output_helm_nvidia_status"></a> [helm\_nvidia\_status](#output\_helm\_nvidia\_status) | Status of the Nvidia Helm release |
| <a name="output_nginx_ingress_lb_hostnames"></a> [nginx\_ingress\_lb\_hostnames](#output\_nginx\_ingress\_lb\_hostnames) | Hostnames of the nginx load balancer |
| <a name="output_nginx_ingress_lb_ips"></a> [nginx\_ingress\_lb\_ips](#output\_nginx\_ingress\_lb\_ips) | IPs of the nginx load balancer |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
