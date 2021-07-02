variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "primary_zone" {
  default = "b"
}
variable "bastion_machine_type" {
  default = "e2-micro"
}
variable "bastion_image" {
  default = "ubuntu-os-cloud/ubuntu-1804-lts"
}
variable "network_prefix" {
  default = "10.0"
}
variable "inception_sa" {}
variable "tf_state_bucket_name" {}
variable "tf_state_bucket_location" {}
variable "users" {
  type = list(object({
    id = string
    inception = bool
    platform = bool
  }))
}

locals {
  name_prefix          = var.name_prefix
  tf_state_bucket_name = var.tf_state_bucket_name
  tf_state_bucket_location = var.tf_state_bucket_location
  project              = var.gcp_project
  inception_sa         = var.inception_sa
  inception_admins = [for user in var.users : user.id if user.inception]

  platform_admins = [for user in var.users : user.id if user.platform]

  region = var.region
  network_prefix = var.network_prefix

  bastion_zone = "${local.region}-${var.primary_zone}"
  bastion_machine_type = var.bastion_machine_type
  bastion_image = var.bastion_image
}
