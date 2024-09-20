[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![OpenTofu Version][badge-opentofu]](https://github.com/opentofu/opentofu/releases)
[![Kubernetes Provider Version][badge-tf-kubernetes]](https://github.com/terraform-providers/terraform-provider-kubernetes/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)
[![Google Provider Version][badge-tf-google]](https://github.com/terraform-providers/terraform-provider-google/releases)

# anyscale-k8s-namespace

This module creates a Kubernetes Namespace for Anyscale.

The Anyscale Namespace can also be created via the Anycsale Helm Chart.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_namespace.anyscale](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | (Required) The cloud provider (aws or gcp)<br><br>ex:<pre>cloud_provider = "aws"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_kubernetes_namespace"></a> [anyscale\_kubernetes\_namespace](#input\_anyscale\_kubernetes\_namespace) | (Optional) The name of the Kubernetes namespace.<br><br>ex:<pre>anyscale_kubernetes_namespace = "anyscale-k8s"</pre> | `string` | `"anyscale-k8s"` | no |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | (Optional) The name of the Kubernetes cluster.<br><br>ex:<pre>kubernetes_cluster_name = "my-cluster"</pre> | `string` | `null` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_kubernetes_namespace_name"></a> [anyscale\_kubernetes\_namespace\_name](#output\_anyscale\_kubernetes\_namespace\_name) | The name of the Kubernetes namespace. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-sandbox-terraform/issues
[badge-build]: https://github.com/anyscale/sa-sandbox-terraform/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-aws]: https://img.shields.io/badge/AWS-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-sandbox-terraform/actions
[badge-opentofu]: https://img.shields.io/badge/opentofu-1.x%20-623CE4.svg?logo=terraform
[badge-tf-google]: https://img.shields.io/badge/Google-5.+-F8991D.svg?logo=terraform
[badge-tf-kubernetes]: https://img.shields.io/badge/KUBERNETES-2.+-F8991D.svg?logo=terraform
