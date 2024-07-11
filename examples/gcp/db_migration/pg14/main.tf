variable "name_prefix" {}
variable "gcp_project" {}
variable "vpc_name_prefix" {}
variable "database_version" {}
variable "destroyable_postgres" {
  default = false
}

output "instance_name" {
  value = module.postgresql.instance_name
}

output "private_ip" {
  value = module.postgresql.private_ip
}

output "instance_creds" {
  value     = module.postgresql.instance_creds
  sensitive = true
}

output "creds" {
  value     = module.postgresql.creds
  sensitive = true
}

module "postgresql" {
  # source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=1eb536b"
  source = "../../../../modules/postgresql/gcp"

  instance_name          = "${var.name_prefix}-pg"
  vpc_name               = "${var.vpc_name_prefix}-vpc"
  gcp_project            = var.gcp_project
  destroyable            = var.destroyable_postgres
  user_can_create_db     = true
  databases              = ["test", "test2"]
  replication            = true
  provision_read_replica = false
  database_version       = var.database_version
}
