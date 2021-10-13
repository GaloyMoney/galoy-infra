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
variable "buckets_location" {}
variable "users" {
  type = list(object({
    id        = string
    inception = bool
    platform  = bool
    logs      = bool
  }))
}

locals {
  name_prefix              = var.name_prefix
  tf_state_bucket_name     = var.tf_state_bucket_name
  tf_state_bucket_location = var.buckets_location
  backups_bucket_name      = "${local.name_prefix}-backups"
  backups_bucket_location  = var.buckets_location
  project                  = var.gcp_project
  inception_sa             = var.inception_sa
  log_viewers              = [for user in var.users : user.id if user.logs]
  inception_admins         = [for user in var.users : user.id if user.inception]

  platform_admins = concat([for user in var.users : user.id if user.platform], ["serviceAccount:${var.inception_sa}"])

  region         = var.region
  network_prefix = var.network_prefix

  bastion_zone         = "${local.region}-${var.primary_zone}"
  bastion_machine_type = var.bastion_machine_type
  bastion_image        = var.bastion_image
}
