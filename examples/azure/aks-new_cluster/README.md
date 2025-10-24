[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![AWS Provider Version][badge-tf-aws]](https://github.com/terraform-providers/terraform-provider-aws/releases)

# Anyscale Azure AKS Example - Public Networking
This example creates the resources to run Anyscale on Azure AKS with either public or private networking.

The content of this module should be used as a starting point and modified to your own security and infrastructure
requirements.

## Getting Started

### Prerequisites

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
  * [Sign into the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli#sign-into-the-azure-cli)
* [kubectl CLI](https://kubernetes.io/docs/tasks/tools/)
* [helm CLI](https://helm.sh/docs/intro/install/)
* [Anyscale CLI](https://docs.anyscale.com/reference/quickstart-cli/) (> v0.26.24)

### Creating Anyscale Resources

Steps for deploying Anyscale resources via Terraform:

* Review variables.tf and (optionally) create a `terraform.tfvars` file to override any of the defaults.
* Apply the terraform

```shell
# Variables
SUBSCRIPTION_ID=12345678-1234-1234-1234-123456789012
RESOURCE_GROUP=anyscale-lab-rg
LOCATION=northcentralus
CLUSTER_NAME=anyscale-aks
STORAGE_ACCOUNT_NAME=anyscale$RANDOM
STORAGE_CONTAINER_NAME=anyscale-container
ANYSCALE_NAMESPACE=anyscale-operator
ANYSCALE_CLOUD_INSTANCE_NAME=anyscale-cloud-instance

# Generate a tfvars file using the variables above
cat << EOF > values.tfvars
# Required Variables
# Your Azure subscription ID
azure_subscription_id = "${SUBSCRIPTION_ID}"

# Name of the resource group
resource_group_name = "${RESOURCE_GROUP}"

# Azure region where resources will be created
azure_location = "${LOCATION}"

# Name of the AKS cluster and related resources
aks_cluster_name = "${CLUSTER_NAME}"

# Storage Account Name
storage_account_name = "${STORAGE_ACCOUNT_NAME}"

# Storage Container Name
storage_container_name = "${STORAGE_CONTAINER_NAME}"

# Kubernetes namespace for the Anyscale operator
anyscale_operator_namespace = "${ANYSCALE_NAMESPACE}"

# GPU types for the node groups
# Available options: T4, A10, A100, H100
node_group_gpu_types = ["A10"]
EOF

terraform init
terraform plan -var-file values.tfvars
terraform apply -var-file values.tfvars
```

Note the output from Terraform which includes example cloud registration and helm commands you will use below.

### Install the Kubernetes Requirements

The Anyscale Operator requires the following components:
* [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/) (other ingress controllers may be possible but are untested)
* (Optional) [Nvidia device plugin](https://github.com/NVIDIA/k8s-device-plugin/tree/main?tab=readme-ov-file#deployment-via-helm) (required if utilizing GPU nodes)

**Note:** Ensure that you are authenticated to the AKS cluster for the remaining steps:

```shell
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --overwrite-existing
```

#### Install the Nginx ingress controller

A sample file, `sample-values_nginx.yaml` has been provided in this repo. Please review for your requirements before using.

Run:

```shell
helm repo add nginx https://kubernetes.github.io/ingress-nginx
helm upgrade ingress-nginx nginx/ingress-nginx \
  --version 4.12.1 \
  --namespace ingress-nginx \
  --values sample-values_nginx.yaml \
  --create-namespace \
  --install
```

#### (Optional) Install the Nvidia device plugin

A sample file, `sample-values_nvdp.yaml` has been provided in this repo. Please review for your requirements before using.

1. Create a YAML values file named: `values_nvdp.yaml`
2. Update the content with the following:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        # We allow a GPU deployment to be forced by setting the following label to "true"
        - key: "nvidia.com/gpu.product"
          operator: Exists
tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
  - key: node.anyscale.com/capacity-type
    operator: Exists
    effect: NoSchedule
  - key: node.anyscale.com/accelerator-type
    operator: Exists
    effect: NoSchedule
```

3. Run:

```shell
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm upgrade nvdp nvdp/nvidia-device-plugin \
  --namespace nvidia-device-plugin \
  --version 0.17.1 \
  --values sample-values_nvdp.yaml \
  --create-namespace \
  --install
```

### Register the Anyscale Cloud

Ensure that you are logged into Anyscale with valid CLI credentials. (`anyscale login`)

You will need an Anyscale platform API Key for the helm chart installation. You can generate one from the [Anyscale Web UI](https://console.anyscale.com/api-keys).

1. Using the output from the Terraform modules, register the Anyscale Cloud. It should look sonething like:

```shell
# Anyscale API Key from the portal link above
ANYSCALE_CLI_TOKEN=

anyscale cloud register \
  --name $ANYSCALE_CLOUD_INSTANCE_NAME \
  --region $LOCATION \
  --provider azure \
  --compute-stack k8s \
  --cloud-storage-bucket-name "azure://${STORAGE_CONTAINER_NAME}" \
  --cloud-storage-bucket-endpoint "https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net"
```

2. Note the Cloud Deployment ID which will be used in the next step. The Anyscale CLI will return it as one of the outputs. Example:
```shell
Output
(anyscale +22.5s) For registering this cloud's Kubernetes Manager, use cloud deployment ID 'cldrsrc_12345abcdefgh67890ijklmnop'.
```

### Install the Anyscale Operator

Using the output from the Terraform modules, install the Anyscale Operator on the AKS Cluster. It should look someting like:

```shell

helm repo add anyscale https://anyscale.github.io/helm-charts
helm repo update

# Use the cloudDeploymentId from the output of the anyscale register command you ran above
helm upgrade anyscale-operator anyscale/anyscale-operator \
--set-string global.cloudDeploymentId= \
--set-string global.cloudProvider=azure \
--set-string global.auth.anyscaleCliToken=$ANYSCALE_CLI_TOKEN \
--set-string workloads.serviceAccount.name=anyscale-operator \
--namespace ${ANYSCALE_NAMESPACE} \
--create-namespace \
--wait \
-i

```

The above will likely fail due to some updates still in progress. We need to fix the service account used by the anyscale operator.

```shell
# Get the managed identity client id
MI_CLIENT_ID=$(az identity show -g $RESOURCE_GROUP -n $CLUSTER_NAME-anyscale-operator-mi -o tsv --query clientId)

kubectl patch sa anyscale-operator -n $ANYSCALE_NAMESPACE --type='json' -p="[{"op": "add", "path": "/metadata/annotations/azure.workload.identity~1client-id", "value": "$MI_CLIENT_ID"}]"

kubectl patch sa anyscale-operator -n $ANYSCALE_NAMESPACE --type='json' -p='[{"op": "add", "path": "/metadata/labels/azure.workload.identity~1use", "value": "true"}]'

kubectl rollout restart deploy/anyscale-operator -n $ANYSCALE_NAMESPACE
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.26.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.26.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_federated_identity_credential.anyscale_operator_fic](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/federated_identity_credential) | resource |
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.gpu_ondemand](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.gpu_spot](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.ondemand_cpu](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_cluster_node_pool.spot_cpu](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.anyscale_blob_contrib](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.sa](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/storage_account) | resource |
| [azurerm_storage_container.blob](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/storage_container) | resource |
| [azurerm_subnet.nodes](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/subnet) | resource |
| [azurerm_user_assigned_identity.anyscale_operator](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/user_assigned_identity) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/resources/virtual_network) | resource |
| [azurerm_location.example](https://registry.terraform.io/providers/hashicorp/azurerm/4.26.0/docs/data-sources/location) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | (Required) Azure subscription ID | `string` | n/a | yes |
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | (Optional) Name of the AKS cluster (and related resources). | `string` | `"anyscale-demo"` | no |
| <a name="input_anyscale_operator_namespace"></a> [anyscale\_operator\_namespace](#input\_anyscale\_operator\_namespace) | (Optional) Kubernetes namespace for the Anyscale operator. | `string` | `"anyscale-operator"` | no |
| <a name="input_azure_location"></a> [azure\_location](#input\_azure\_location) | (Optional) Azure region for all resources. | `string` | `"West US"` | no |
| <a name="input_node_group_gpu_types"></a> [node\_group\_gpu\_types](#input\_node\_group\_gpu\_types) | (Optional) The GPU types of the AKS nodes.<br/>Possible values: ["T4", "A10", "A100", "H100"] | `list(string)` | <pre>[<br/>  "T4"<br/>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags applied to all taggable resources. | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Test": "true"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_anyscale_operator_client_id"></a> [anyscale\_operator\_client\_id](#output\_anyscale\_operator\_client\_id) | Client ID of the Azure User Assigned Identity created for the cluster. |
| <a name="output_anyscale_registration_command"></a> [anyscale\_registration\_command](#output\_anyscale\_registration\_command) | The Anyscale registration command. |
| <a name="output_azure_aks_cluster_name"></a> [azure\_aks\_cluster\_name](#output\_azure\_aks\_cluster\_name) | Name of the Azure AKS cluster created for the cluster. |
| <a name="output_azure_resource_group_name"></a> [azure\_resource\_group\_name](#output\_azure\_resource\_group\_name) | Name of the Azure Resource Group created for the cluster. |
| <a name="output_azure_storage_account_name"></a> [azure\_storage\_account\_name](#output\_azure\_storage\_account\_name) | Name of the Azure Storage Account created for the cluster. |
| <a name="output_helm_upgrade_command"></a> [helm\_upgrade\_command](#output\_helm\_upgrade\_command) | The helm upgrade command. |
<!-- END_TF_DOCS -->
