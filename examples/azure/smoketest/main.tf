provider "azurerm" {
  features {}
}

variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

data "azurerm_kubernetes_cluster" "primary" {
  name                = "${var.name_prefix}-cluster"
  resource_group_name = "${var.name_prefix}"
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.primary.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.primary.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.primary.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.primary.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.primary.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.primary.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.primary.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.primary.kube_config.0.cluster_ca_certificate)
  }
}

module "smoketest" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/smoketest?ref=5985c33"
  # source = "../../../modules/smoketest"

  name_prefix      = var.name_prefix
  cluster_endpoint = var.cluster_endpoint
  cluster_ca_cert  = var.cluster_ca_cert
}
