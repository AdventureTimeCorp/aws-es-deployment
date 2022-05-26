terraform {
  required_version = "= 0.14.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.72"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    } 
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "kubernetes" {
  config_path    = "./kubeconfig_aws-dev-es-cloud"
  config_context = "eks_aws-dev-es-cloud"

  host                   = "https://B3688F32201C7462F415AEA0105DD15A.gr7.eu-central-1.eks.amazonaws.com"
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
}
