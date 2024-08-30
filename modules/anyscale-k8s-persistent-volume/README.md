[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![OpenTofu Version][badge-opentofu]](https://github.com/opentofu/opentofu/releases)
[![Kubernetes Provider Version][badge-tf-kubernetes]](https://github.com/terraform-providers/terraform-provider-kubernetes/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)
[![Google Provider Version][badge-tf-google]](https://github.com/terraform-providers/terraform-provider-google/releases)

# anyscale-k8s-persistent-volume - UNUSED

!!! Unused sub-module !!!

This module creates the resources for a persistent volume NFS mount and persistent volume claim.


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
| [kubernetes_persistent_volume.anyscale](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume) | resource |
| [kubernetes_persistent_volume_claim.anyscale](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/persistent_volume_claim) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_provider"></a> [cloud\_provider](#input\_cloud\_provider) | (Required) The cloud provider (aws or gcp)<br><br>ex:<pre>cloud_provider = "aws"</pre> | `string` | n/a | yes |
| <a name="input_anyscale_kubernetes_namespace"></a> [anyscale\_kubernetes\_namespace](#input\_anyscale\_kubernetes\_namespace) | (Optional) The name of the Kubernetes namespace.<br><br>ex:<pre>anyscale_kubernetes_namespace = "anyscale-k8s"</pre> | `string` | `"anyscale-k8s"` | no |
| <a name="input_aws_efs_file_system_id"></a> [aws\_efs\_file\_system\_id](#input\_aws\_efs\_file\_system\_id) | (Optional) The ID of the EFS file system.<br><br>Required if `cloud_provider` is `aws`.<br><br>ex:<pre>aws_efs_file_system_id = "fs-12345678"</pre> | `string` | `null` | no |
| <a name="input_gcp_filestore_ip"></a> [gcp\_filestore\_ip](#input\_gcp\_filestore\_ip) | (Optional) The Filestore IP address.<br><br>Required if `cloud_provider` is `gcp`.<br><br>ex:<pre>gcp_filestore_ip = "172.16.0.12"</pre> | `string` | `null` | no |
| <a name="input_gcp_filestore_share_name"></a> [gcp\_filestore\_share\_name](#input\_gcp\_filestore\_share\_name) | (Optional) The Filestore share name.<br><br>Required if `cloud_provider` is `gcp`.<br><br>ex:<pre>gcp_filestore_share_name = "my-share"</pre> | `string` | `null` | no |
| <a name="input_kubernetes_cluster_name"></a> [kubernetes\_cluster\_name](#input\_kubernetes\_cluster\_name) | (Optional) The name of the Kubernetes cluster.<br><br>ex:<pre>kubernetes_cluster_name = "my-cluster"</pre> | `string` | `null` | no |
| <a name="input_kubernetes_persistent_volume_claim_name"></a> [kubernetes\_persistent\_volume\_claim\_name](#input\_kubernetes\_persistent\_volume\_claim\_name) | (Optional) The name of the Kubernetes persistent volume claim.<br><br>ex:<pre>kubernetes_persistent_volume_claim_name = "anyscale-nfs-claim"</pre> | `string` | `"anyscale-nfs-claim"` | no |
| <a name="input_kubernetes_persistent_volume_name"></a> [kubernetes\_persistent\_volume\_name](#input\_kubernetes\_persistent\_volume\_name) | (Optional) The name of the Kubernetes persistent volume.<br><br>ex:<pre>kubernetes_persistent_volume_name = "anyscale-nfs"</pre> | `string` | `"anyscale-nfs"` | no |
| <a name="input_kubernetes_persistent_volume_size"></a> [kubernetes\_persistent\_volume\_size](#input\_kubernetes\_persistent\_volume\_size) | (Optional) The size of the Kubernetes persistent volume.<br><br>When using AWS EFS, this is just a placeholder. The actual size is elastically built, making this just a placeholder<br><br>ex:<pre>kubernetes_persistent_volume_size = "20Gi"</pre> | `string` | `"20Gi"` | no |
| <a name="input_module_enabled"></a> [module\_enabled](#input\_module\_enabled) | (Optional) Determines if this module should create resources.<br><br>If set to true, `eks_role_arn`, `anyscale_subnet_ids`, and `anyscale_security_group_id` must be provided.<br>ex:<pre>module_enabled = true</pre> | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubernetes_persistent_volume_claim_name"></a> [kubernetes\_persistent\_volume\_claim\_name](#output\_kubernetes\_persistent\_volume\_claim\_name) | The name of the Kubernetes persistent volume claim. |
| <a name="output_kubernetes_persistent_volume_claim_namespace"></a> [kubernetes\_persistent\_volume\_claim\_namespace](#output\_kubernetes\_persistent\_volume\_claim\_namespace) | The namespace of the Kubernetes persistent volume claim. |
| <a name="output_kubernetes_persistent_volume_claim_storageclassname"></a> [kubernetes\_persistent\_volume\_claim\_storageclassname](#output\_kubernetes\_persistent\_volume\_claim\_storageclassname) | The storage class name of the Kubernetes persistent volume claim. |
| <a name="output_kubernetes_persistent_volume_claim_volumename"></a> [kubernetes\_persistent\_volume\_claim\_volumename](#output\_kubernetes\_persistent\_volume\_claim\_volumename) | The volume name of the Kubernetes persistent volume claim. |
| <a name="output_kubernetes_persistent_volume_name"></a> [kubernetes\_persistent\_volume\_name](#output\_kubernetes\_persistent\_volume\_name) | The name of the Kubernetes persistent volume. |
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
