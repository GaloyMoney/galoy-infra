variable "name_prefix" {}
variable "tf_state_bucket_name" {}
variable "tf_state_bucket_location" {
  default = "US"
}
variable "gcp_project" {}
variable "inception_sa" {}
variable "users" {
  type = list(object({
    id        = string
    inception = bool
    platform  = bool
  }))
}

module "inception" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/inception/gcp?ref=a29205f"
  # source = "../../../modules/inception/gcp"

  name_prefix              = var.name_prefix
  gcp_project              = var.gcp_project
  inception_sa             = var.inception_sa
  tf_state_bucket_name     = var.tf_state_bucket_name
  tf_state_bucket_location = var.tf_state_bucket_location

  users = var.users
}

output "bastion_ip" {
  value = module.inception.bastion_ip
}

output "bastion_name" {
  value = module.inception.bastion_name
}

output "bastion_zone" {
  value = module.inception.bastion_zone
}

output "cluster_sa" {
  value = module.inception.cluster_sa
}
