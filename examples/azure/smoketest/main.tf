provider "azurerm" {
  features {}
}

variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

data "azurerm_client_config" "current" {}

provider "kubernetes" {
  host                   = var.cluster_endpoint
  token                  = data.azurerm_client_config.current.access_token
  cluster_ca_certificate = var.cluster_ca_cert
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    token                  = data.azurerm_client_config.current.access_token
    cluster_ca_certificate = var.cluster_ca_cert
  }
}

module "smoketest" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/smoketest?ref=7005338"
  # source = "../../../modules/smoketest"

  name_prefix      = var.name_prefix
  cluster_endpoint = var.cluster_endpoint
  cluster_ca_cert  = var.cluster_ca_cert
}
