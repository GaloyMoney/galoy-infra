variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "primary_zone" {
  default = "b"
}
variable "cluster_zone" {
  default = ""
}
variable "bastion_machine_type" {
  default = "e2-micro"
}
variable "bastion_image" {
  default = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
}
variable "bastion_revoke_on_exit" {
  default = true
}
variable "network_prefix" {
  default = "10.0"
}
variable "objects_list_role_name" {
  default = "objects-list"
}

variable "inception_sa" {}
variable "tf_state_bucket_name" {}
variable "buckets_location" {}
variable "tf_state_bucket_policy" { default = null }
variable "backups_bucket_location" {}

variable "users" {
  type = list(object({
    id        = string
    bastion   = bool
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
  backups_bucket_location  = var.backups_bucket_location
  project                  = var.gcp_project
  inception_sa             = var.inception_sa
  log_viewers              = [for user in var.users : user.id if user.logs]
  inception_admins         = [for user in var.users : user.id if user.inception]
  platform_admins          = concat([for user in var.users : user.id if user.platform], ["serviceAccount:${var.inception_sa}"])
  bastion_users            = toset(concat([for user in var.users : user.id if user.bastion], local.platform_admins))

  region                 = var.region
  network_prefix         = var.network_prefix
  objects_list_role_name = replace("${local.name_prefix}-${var.objects_list_role_name}", "-", "_")

  cluster_location       = var.cluster_zone == "" ? local.region : "${local.region}-${var.cluster_zone}"
  bastion_zone           = "${local.region}-${var.primary_zone}"
  bastion_machine_type   = var.bastion_machine_type
  bastion_image          = var.bastion_image
  bastion_revoke_on_exit = var.bastion_revoke_on_exit
  tf_state_bucket_policy = var.tf_state_bucket_policy
}
