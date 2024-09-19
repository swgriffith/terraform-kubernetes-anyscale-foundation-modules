terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}


provider "helm" {
  kubernetes {
    host                   = module.anyscale_eks_cluster.eks_kubeconfig.endpoint
    cluster_ca_certificate = base64decode(module.anyscale_eks_cluster.eks_kubeconfig.cluster_ca_certificate)

    # https://registry.terraform.io/providers/hashicorp/helm/latest/docs#exec-plugins
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.anyscale_eks_cluster.eks_cluster_name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.anyscale_eks_cluster.eks_kubeconfig.endpoint
  cluster_ca_certificate = base64decode(module.anyscale_eks_cluster.eks_kubeconfig.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.anyscale_eks_cluster.eks_cluster_name]
    command     = "aws"
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}
