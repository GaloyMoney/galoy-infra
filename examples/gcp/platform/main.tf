variable "name_prefix" {}
variable "gcp_project" {}
variable "node_service_account" {}
variable "node_default_machine_type" {
  default = "e2-medium"
}
variable "letsencrypt_issuer_email" {
  default = "bot@galoy.io"
}
variable "destroyable_cluster" {
  default = false
}

module "platform" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=5fbfd2b"
  # source = "../../../modules/platform/gcp"

  name_prefix               = var.name_prefix
  gcp_project               = var.gcp_project
  node_service_account      = var.node_service_account
  node_default_machine_type = var.node_default_machine_type
  destroyable_cluster       = var.destroyable_cluster
}

output "cluster_endpoint" {
  value = module.platform.master_endpoint
}
output "cluster_ca_cert" {
  value = module.platform.cluster_ca_cert
}
