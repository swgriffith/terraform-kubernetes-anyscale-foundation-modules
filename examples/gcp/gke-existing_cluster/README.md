[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![Google Provider Version][badge-tf-google]](https://github.com/terraform-providers/terraform-provider-google/releases)

# Anyscale GCP GKE Example - Existing Cluster

This example creates the resources to run Anyscale on GCP GKE with an existing GKE cluster.

## Known Issues on GKE

- Autopilot GKE clusters are not supported.
- Node auto-provisioning for GKE failing with GPU nodes: https://github.com/GoogleCloudPlatform/container-engine-accelerators/issues/407
- When choosing "GPU Driver installation", select "Google-managed".

## terraform.tfvars

```hcl
anyscale_deploy_env = "..."
anyscale_org_id     = "..." # Troubleshooting Org Id

google_region     = "..."
google_project_id = "..."
existing_vpc_name            = "..."
existing_subnet_name         = "..."
customer_ingress_cidr_ranges = "0.0.0.0/0"
gke_endpoint       = "..."
gke_ca_certificate = "..."
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.44.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.15.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anyscale_cloudstorage"></a> [anyscale\_cloudstorage](#module\_anyscale\_cloudstorage) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-cloudstorage | n/a |
| <a name="module_anyscale_filestore"></a> [anyscale\_filestore](#module\_anyscale\_filestore) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-filestore | n/a |
| <a name="module_anyscale_firewall"></a> [anyscale\_firewall](#module\_anyscale\_firewall) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-vpc-firewall | n/a |
| <a name="module_anyscale_iam"></a> [anyscale\_iam](#module\_anyscale\_iam) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-iam | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.ingress_nginx](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [google_client_config.provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_network.existing_vpc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.exising_subnet](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_org_id"></a> [anyscale\_org\_id](#input\_anyscale\_org\_id) | (Required) Anyscale Organization ID | `string` | n/a | yes |
| <a name="input_customer_ingress_cidr_ranges"></a> [customer\_ingress\_cidr\_ranges](#input\_customer\_ingress\_cidr\_ranges) | The IPv4 CIDR blocks that allows access Anyscale clusters.<br>These are added to the firewall and allows port 443 (https) and 22 (ssh) access.<br>ex: `52.1.1.23/32,10.1.0.0/16'<br>` | `string` | n/a | yes |
| <a name="input_existing_subnet_name"></a> [existing\_subnet\_name](#input\_existing\_subnet\_name) | The name of the existing Subnet | `string` | n/a | yes |
| <a name="input_existing_vpc_name"></a> [existing\_vpc\_name](#input\_existing\_vpc\_name) | The name of the existing VPC | `string` | n/a | yes |
| <a name="input_gke_ca_certificate"></a> [gke\_ca\_certificate](#input\_gke\_ca\_certificate) | Base64 encoded PEM certificate for the cluster | `string` | n/a | yes |
| <a name="input_gke_endpoint"></a> [gke\_endpoint](#input\_gke\_endpoint) | The endpoint for the GKE cluster | `string` | n/a | yes |
| <a name="input_google_project_id"></a> [google\_project\_id](#input\_google\_project\_id) | ID of the Project to put these resources in | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | The Google region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID | `string` | `null` | no |
| <a name="input_anyscale_deploy_env"></a> [anyscale\_deploy\_env](#input\_anyscale\_deploy\_env) | (Optional) Anyscale deploy environment. Used in resource names and tags.<br><br>ex:<pre>anyscale_deploy_env = "production"</pre> | `string` | `"production"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) A map of labels to all resources that accept labels. | `map(string)` | <pre>{<br>  "environment": "test"<br>}</pre> | no |

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
