variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

data "google_client_config" "default" {
  provider = google-beta
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  host                   = var.cluster_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = var.cluster_ca_cert
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = var.cluster_ca_cert
  }
}

module "smoketest" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/smoketest/gcp?ref=5cef6f5"
  # source = "../../../modules/smoketest"

  name_prefix      = var.name_prefix
  cluster_endpoint = var.cluster_endpoint
  cluster_ca_cert  = var.cluster_ca_cert
}

terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.65.2"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.65.2"
    }
  }
}
