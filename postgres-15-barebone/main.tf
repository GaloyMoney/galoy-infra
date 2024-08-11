variable "name_prefix" {}
variable "gcp_project" {}
variable "instance_admin_password" {}
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

module "postgresql" {
  source = "../modules/postgresql/gcp-postgres-15"

  instance_name           = "${var.name_prefix}-pg"
  vpc_name                = "${var.name_prefix}-vpc"
  gcp_project             = var.gcp_project
  instance_admin_password = var.instance_admin_password
  destroyable             = var.destroyable_postgres
  databases               = []
  database_version        = var.database_version
}
