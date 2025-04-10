variable "name_prefix" {}
variable "network_prefix" {
  default = "10.0"
}
variable "node_default_machine_type" {
  default = "Standard_DS2_v2"
}
variable "vnet_name" {}
variable "cluster_location" {
  default = "eastus"
}

module "platform" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=ee2c99a"
  source = "../../../modules/platform/azure"

  name_prefix               = var.name_prefix
  network_prefix            = var.network_prefix
  node_default_machine_type = var.node_default_machine_type
  vnet_name                 = var.vnet_name
  cluster_location          = var.cluster_location
}

output "client_certificate" {
  value     = module.platform.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = module.platform.kube_config
  sensitive = true
}

output "cluster_name" {
  value = module.platform.cluster_name
}
