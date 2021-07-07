variable "name_prefix" {}
variable "gcp_project" {}
variable "node_service_account" {}
variable "node_default_machine_type" {
  default = "e2-standard-2"
}
variable "letsencrypt_issuer_email" {}

module "platform" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/platform/gcp?ref=dd82ecd"
  # source = "../../../modules/platform/gcp"

  name_prefix               = var.name_prefix
  gcp_project               = var.gcp_project
  node_service_account      = var.node_service_account
  node_default_machine_type = var.node_default_machine_type
}


data "google_client_config" "default" {
  provider = google-beta
}

provider "kubernetes" {
  host                   = module.platform.master_endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = module.platform.cluster_ca_cert
}

provider "kubernetes-alpha" {
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
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=dd82ecd"
  # source = "../../../modules/services"

  name_prefix              = var.name_prefix
  letsencrypt_issuer_email = var.letsencrypt_issuer_email

  depends_on = [
    module.platform
  ]
}
