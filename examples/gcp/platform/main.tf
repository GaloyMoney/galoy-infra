variable "name_prefix" {}
variable "gcp_project" {}
variable "node_service_account" {}
variable "node_default_machine_type" {
  default = "e2-medium"
}
variable "letsencrypt_issuer_email" {
  default = "bot@galoy.io"
}
variable "destroyable_postgres" {
  default = false
}

module "platform" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=094e04f"
  # source = "../../../modules/platform/gcp"

  name_prefix               = var.name_prefix
  gcp_project               = var.gcp_project
  node_service_account      = var.node_service_account
  node_default_machine_type = var.node_default_machine_type
  destroyable_postgres      = var.destroyable_postgres
}


data "google_client_config" "default" {
  provider = google-beta
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  host                   = module.platform.master_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.platform.cluster_ca_cert
}

provider "helm" {
  kubernetes {
    host                   = module.platform.master_endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.platform.cluster_ca_cert
  }
}

module "services" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=094e04f"
  # source = "../../../modules/services"

  name_prefix              = var.name_prefix
  letsencrypt_issuer_email = var.letsencrypt_issuer_email
  cluster_endpoint         = module.platform.master_endpoint
  cluster_ca_cert          = module.platform.cluster_ca_cert
  honeycomb_api_key        = "dummy"
  small_footprint          = true
  postgres_instance_name   = module.platform.postgres_instance_name
}
