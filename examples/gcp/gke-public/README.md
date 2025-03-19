[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![Google Provider Version][badge-tf-google]](https://github.com/terraform-providers/terraform-provider-google/releases)

# Anyscale GKE Public

This example creates the resources to run Anyscale on GKE cluster.

## Known Issues on GKE

- Autopilot GKE clusters are not supported.
- Node auto-provisioning for GKE failing with GPU nodes: https://github.com/GoogleCloudPlatform/container-engine-accelerators/issues/407

## Getting Started

### Prerequisites

* [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
* [Google Cloud Authentication](https://cloud.google.com/docs/authentication/getting-started)
* [kubectl CLI](https://kubernetes.io/docs/tasks/tools/)
* [helm CLI](https://helm.sh/docs/intro/install/)
* [Anyscale CLI](https://docs.anyscale.com/reference/quickstart-cli/)

### Creating Anyscale Resources

Steps for deploying Anyscale resources via Terraform:

* Review variables.tf and create a `terraform.tfvars` file with required variables:

```tf
cluster_name = "anyscale-demo"
anyscale_org_id = "..."
google_project_id = "..."
google_region = "us-central1"
```

* Apply the terraform:

```shell
terraform init
# Create service account first to avoid dependency issues
terraform apply -target google_service_account.gke_nodes -auto-approve
terraform apply -auto-approve
```

Note the output from Terraform which includes an example cloud registration command you will use below.

### Install the Kubernetes Requirements

The Anyscale Operator requires the following components:
* [Cluster autoscaler](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler) (enabled by default in GKE)
* [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) (other ingress controllers may be possible but are untested)
* (Optional) [Nvidia device plugin](https://github.com/NVIDIA/k8s-device-plugin) (enabled by default in GKE if utilizing GPU nodes)

**Note:** Ensure that you are [authenticated to the GKE cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl) for the remaining steps.

#### Install the Nginx ingress controller

1. Create a YAML values file named `values_nginx_gke.yaml`:

```yaml
controller:
  service:
    type: LoadBalancer
    annotations:
      cloud.google.com/load-balancer-type: "External"
  allowSnippetAnnotations: true
  autoscaling:
    enabled: true
```

2. Run:

```shell
helm repo add nginx https://kubernetes.github.io/ingress-nginx
helm upgrade ingress-nginx nginx/ingress-nginx \
  --version 4.12.0 \
  --namespace ingress-nginx \
  --values values_nginx_gke.yaml \
  --create-namespace \
  --install
```

### Register the Anyscale Cloud

Ensure that you are logged into Anyscale with valid CLI credentials. (`anyscale login`)

1. Using the output from the Terraform modules, register the Anyscale Cloud. It should look something like:

```shell
anyscale cloud register --name <cloud-name> \
  --provider gcp \
  --region us-central1 \
  --compute-stack k8s \
  --kubernetes-zones us-central1-a,us-central1-b \
  --anyscale-operator-iam-identity <service-account-email> \
  --cloud-storage-bucket-name <bucket> \
  --project-id <project-id> \
  --vpc-name <vpc-name> \
  --file-storage-id <filestore-name> \
  --filestore-location us-central1-a
```

**Please note:** You must change the cloud name to a name that you choose. You will not be able to register a cloud with a name of `<CUSTOMER_DEFINED_NAME>`.

2. Note the Cloud Deployment ID which will be used in the next step. The Anyscale CLI will return it as one of the outputs.

### Install the Anyscale Operator

1. Install the Anyscale Operator using the cloud deployment ID from the previous step:

```shell
helm repo add anyscale https://anyscale.github.io/helm-charts
helm upgrade anyscale-operator anyscale/anyscale-operator \
  --set-string cloudDeploymentId=<cloud-deployment-id> \
  --set-string cloudProvider=gcp \
  --set-string region=us-central1 \
  --set-string operatorIamIdentity=<service-account-email> \
  --set-string workloadServiceAccountName=anyscale-operator \
  --namespace anyscale-operator \
  --create-namespace \
  --install
```

2. Configure workload identity binding:

```shell
gcloud iam service-accounts add-iam-policy-binding <service-account-email> \
    --project <project-id> \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:<project-id>.svc.id.goog[anyscale-operator/anyscale-operator]"
```

3. (Optional) For L4 GPU to work, modify `instance-types` ConfigMap:
```
  instance_types.yaml: |-
    ...
    8CPU-32GB-1xL4:
      resources:
        CPU: 8
        GPU: 1
        accelerator_type:L4: 1
        memory: 32Gi
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.45.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_anyscale_cloudstorage"></a> [anyscale\_cloudstorage](#module\_anyscale\_cloudstorage) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-cloudstorage | n/a |
| <a name="module_anyscale_filestore"></a> [anyscale\_filestore](#module\_anyscale\_filestore) | github.com/anyscale/terraform-google-anyscale-cloudfoundation-modules//modules/google-anyscale-filestore | n/a |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | ~>34.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow-common-ingress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-internal](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.anyscale](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.anyscale](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_project_iam_member.gke_nodes_roles](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.gke_nodes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_anyscale_org_id"></a> [anyscale\_org\_id](#input\_anyscale\_org\_id) | (Required) Anyscale Organization ID | `string` | n/a | yes |
| <a name="input_google_project_id"></a> [google\_project\_id](#input\_google\_project\_id) | ID of the Project to put these resources in | `string` | n/a | yes |
| <a name="input_google_region"></a> [google\_region](#input\_google\_region) | The Google region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_anyscale_cloud_id"></a> [anyscale\_cloud\_id](#input\_anyscale\_cloud\_id) | (Optional) Anyscale Cloud ID | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Required) GKE Cluster Name | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | (Optional) A map of labels to all resources that accept labels. | `map(string)` | <pre>{<br>  "environment": "test",<br>  "test": true<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_operator_service_account_email"></a> [anyscale\_operator\_service\_account\_email](#output\_anyscale\_operator\_service\_account\_email) | The Anyscale operator service account email. |
| <a name="output_anyscale_registration_command"></a> [anyscale\_registration\_command](#output\_anyscale\_registration\_command) | The Anyscale registration command. |
<!-- END_TF_DOCS -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Issues]: https://github.com/anyscale/sa-terraform-google-cloudfoundation-modules/issues
[badge-build]: https://github.com/anyscale/sa-terraform-google-cloudfoundation-modules/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-google]: https://img.shields.io/badge/GCP-5.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/sa-terraform-google-cloudfoundation-modules/actions
