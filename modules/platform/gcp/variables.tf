variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "primary_zone" {
  default = "b"
}
variable "network_prefix" {
  default = "10.1"
}

locals {
  name_prefix              = var.name_prefix
  project                  = var.gcp_project
  region         = var.region
  network_prefix = var.network_prefix
}
