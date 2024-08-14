[![Build Status][badge-build]][build-status]
[![Terraform Version][badge-terraform]](https://github.com/hashicorp/terraform/releases)
[![Kubernetes Provider Version][badge-tf-kubernetes]](https://github.com/terraform-providers/terraform-provider-kubernetes/releases)

# Terraform Modules for Anyscale Kubernetes Foundations
[Terraform] modules to manage Kubernetes infrastructure for Anyscale. This builds the foundational cloud resources needed to run Anyscale on Kubernetes and should be paired with the [Anyscale AWS]() and [Anyscale GCP]() Terraform Modules.

**THIS IS PROVIDED AS A STARTING POINT**

**USE AT YOUR OWN RISK**

## Kubernetes Resources


To streamline long-term management and to enable customization, we've modularized the resources into the following Terraform sub-modules:
* anyscale-k8s-helm - Required Helm Charts for Anyscale on Kubernetes

### Customization

These modules are designed with best practices in mind, ensuring a secure, efficient, and scalable Anyscale deployment. Each module is standalone, allowing you the flexibility to disable any you don't need. This is handy if you're looking to incorporate custom solutions for specific resources.


### Examples
The examples folder has a couple common use cases that have been tested. These include:
* Anyscale - AWS & EKS
  * [Build everything - use a common name for all resources](./examples/anyscale-v2-aws/)
* Anyscale - GCP & GKE
  * [Build everything - use a common name for all resources](./examples/anyscale-v2-gcp/)

Additional examples can be requested via an [issues] ticket.

### Specific Module Notes


## Reporting Issues

We use GitHub [Issues] to track community reported issues and missing features.

## Known Issues/Untested

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- References -->
[Terraform]: https://www.terraform.io
[Anyscale]: https://www.anyscale.com
[Issues]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/issues
[badge-build]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/workflows/CI/CD%20Pipeline/badge.svg
[badge-terraform]: https://img.shields.io/badge/terraform-1.x%20-623CE4.svg?logo=terraform
[badge-tf-kubernetes]: https://img.shields.io/badge/KUBERNETES-2.+-F8991D.svg?logo=terraform
[build-status]: https://github.com/anyscale/terraform-aws-anyscale-cloudfoundation-modules/actions
