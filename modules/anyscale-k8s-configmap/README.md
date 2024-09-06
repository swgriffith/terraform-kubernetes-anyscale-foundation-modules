[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![OpenTofu Version][badge-opentofu]](https://github.com/opentofu/opentofu/releases)
[![Kubernetes Provider Version][badge-tf-kubernetes]](https://github.com/terraform-providers/terraform-provider-kubernetes/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)
[![Google Provider Version][badge-tf-google]](https://github.com/terraform-providers/terraform-provider-google/releases)

# anyscale-k8s-configmap
This module creates Kubernetes Configmaps for Anyscale applications and workloads.

The `instance-types` ConfigMap defines the instance types that you wish to run on Anyscale. This ConfigMap can also be created
via the Anyscale Helm Chart.

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
| [kubernetes_config_map.instance_type](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_kubernetes_namespace"></a> [anyscale\_kubernetes\_namespace](#input\_anyscale\_kubernetes\_namespace) | (Optional) The namespace to install the Anyscale resources.<br><br>ex:<pre>anyscale_kubernetes_namespace = "anyscale-k8s"</pre> | `string` | n/a | yes |
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | (Required) The cloud provider (aws or gcp)<br><br>ex:<pre>cloud_provider = "aws"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_instance_types"></a> [anyscale\_instance\_types](#input\_anyscale\_instance\_types) | (Optional) A list of instance types to create in the instance-types configmap.<br><br>ex:<pre>anyscale_instance_types = [<br>  {<br>    instanceType = "8CPU-32GB"<br>    CPU          = 8<br>    memory       = 32Gi # 32gb<br>  },<br>  {<br>    instanceType = "4CPU-16GB-1xA10"<br>    CPU          = 4<br>    GPU          = 1<br>    memory       = 17179869184 # 16gb converted to bytes<br>    accelerator_type = {"A10G" = 1}<br>  },<br>  {<br>    instanceType = "8CPU-32GB-1xA10"<br>    CPU          = 8<br>    GPU          = 1<br>    memory       = 32Gi # 32gb<br>    accelerator_type = {"A10G" = 1}<br>  },<br>  {<br>    instanceType = "8CPU-32GB-1xT4"<br>    CPU          = 8<br>    GPU          = 1<br>    memory       = 32Gi # 32gb<br>    accelerator_type = {"T4" = 1}<br>  }<br>]</pre> | <pre>list(object({<br>    instanceType     = string<br>    CPU              = number<br>    GPU              = optional(number)<br>    memory           = string<br>    accelerator_type = optional(map(number)) # accelerator_type should be a map of key-value pairs<br>  }))</pre> | <pre>[<br>  {<br>    "CPU": 8,<br>    "instanceType": "8CPU-32GB",<br>    "memory": "32Gi"<br>  }<br>]</pre> | no |
| <a name="input_anyscale_instance_types_version"></a> [anyscale\_instance\_types\_version](#input\_anyscale\_instance\_types\_version) | (Optional) The version of the instance-types configmap.<br><br>ex:<pre>anyscale_instance_types_version = "v1"</pre> | `string` | `"v1"` | no |
| <a name="input_create_anyscale_instance_types_map"></a> [create\_anyscale\_instance\_types\_map](#input\_create\_anyscale\_instance\_types\_map) | (Optional) Determines if the instance-types configmap should be created.<br><br>ex:<pre>create_anyscale_instance_types_map = true</pre> | `bool` | `true` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `false` | no |

## Outputs

No outputs.
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
