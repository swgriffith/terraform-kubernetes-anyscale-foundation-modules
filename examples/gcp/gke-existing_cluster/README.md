[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![Google Provider Version][badge-tf-google]](https://github.com/terraform-providers/terraform-provider-google/releases)

# Anyscale GCP GKE Example - Existing Cluster
This example creates the resources to run Anyscale on GCP GKE with an existing cluster

## Needs to Create:
- filestore
- IAM Service Accounts for ControlPlane
- IAM Service Accounts for Dataplane (?)
- storage bucket
- namespace
- helm charts
- configmap

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anyscale_cloudstorage"></a> [anyscale\_cloudstorage](#module\_anyscale\_cloudstorage) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-cloudstorage | n/a |
| <a name="module_anyscale_filestore"></a> [anyscale\_filestore](#module\_anyscale\_filestore) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-filestore | n/a |
| <a name="module_anyscale_firewall"></a> [anyscale\_firewall](#module\_anyscale\_firewall) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-vpc-firewall | n/a |
| <a name="module_anyscale_iam"></a> [anyscale\_iam](#module\_anyscale\_iam) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-iam | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_org_id"></a> [anyscale\_org\_id](#input\_anyscale\_org\_id) | (Required) Anyscale Organization ID | `string` | n/a | yes |
| <a name="input_customer_ingress_cidr_ranges"></a> [customer\_ingress\_cidr\_ranges](#input\_customer\_ingress\_cidr\_ranges) | The IPv4 CIDR blocks that allows access Anyscale clusters.<br>These are added to the firewall and allows port 443 (https) and 22 (ssh) access.<br>ex: `52.1.1.23/32,10.1.0.0/16'<br>` | `string` | n/a | yes |
| <a name="input_existing_subnet_cidr"></a> [existing\_subnet\_cidr](#input\_existing\_subnet\_cidr) | The CIDR range of the existing subnet | `string` | n/a | yes |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | The ID of the existing VPC | `string` | n/a | yes |
| <a name="input_existing_vpc_name"></a> [existing\_vpc\_name](#input\_existing\_vpc\_name) | The name of the existing VPC | `string` | n/a | yes |
| <a name="input_google_project_id"></a> [google\_project\_id](#input\_google\_project\_id) | ID of the Project to put these resources in | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | The Google region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Optional) Anyscale deploy environment. Used in resource names and tags.<br><br>ex:<pre>anyscale_deploy_env = "production"</pre> | `string` | `"production"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) A map of labels to all resources that accept labels. | `map(string)` | <pre>{<br>  "environment": "test",<br>  "test": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_registration_command"></a> [anyscale\_registration\_command](#output\_anyscale\_registration\_command) | The Anyscale registration command. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-terraform-google-cloudfoundation-modules/issues
[badge-build]: https://github.com/anyscale/sa-terraform-google-cloudfoundation-modules/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-google]: https://img.shields.io/badge/GCP-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-terraform-google-cloudfoundation-modules/actions
