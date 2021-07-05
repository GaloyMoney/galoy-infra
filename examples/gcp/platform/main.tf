variable "name_prefix" {}
variable "gcp_project" {}
variable "node_service_account" {}

module "platform" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=3fed2ac"
  # source = "../../../modules/platform/gcp"

  name_prefix          = var.name_prefix
  gcp_project          = var.gcp_project
  node_service_account = var.node_service_account
}


data "google_client_config" "default" {
  provider = google-beta
}

provider "kubernetes" {
  load_config_file       = false
  host                   = module.platform.master_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.platform.cluster_ca_cert
}


provider "helm" {
  kubernetes {
    load_config_file       = false
    host                   = module.platform.master_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.platform.cluster_ca_cert
  }
}

module "services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=3fed2ac"
  # source = "../../../modules/platform/gcp"

  name_prefix          = var.name_prefix

  depends_on = [
    module.platform
  ]
}
