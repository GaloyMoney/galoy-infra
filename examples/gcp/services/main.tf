variable "name_prefix" {}
variable "gcp_project" {}
variable "cluster_name" {}
variable "cluster_locatin" {}

data "google_client_config" "default" {
  provider = google-beta
}

data "google_container_cluster" "primary" {
  project  = var.gcp_project
  name     = module.shared.cluster_name
  location = module.shared.gcp_region
}

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

module "services" {
  # source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/services?ref=094e04f"
  source = "../../../modules/services"

  name_prefix              = var.name_prefix
  gcp_project              = var.gcp_project
  letsencrypt_issuer_email = var.letsencrypt_issuer_email
  cluster_endpoint         = module.platform.master_endpoint
  cluster_ca_cert          = module.platform.cluster_ca_cert
  honeycomb_api_key        = module.platform.cluster_name
  small_footprint          = true
  postgres_instance_name   = module.platform.postgres_instance_name

  depends_on = [
    module.platform
  ]
}
