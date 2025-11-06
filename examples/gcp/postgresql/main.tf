variable "name_prefix" {}
variable "gcp_project" {}
variable "destroyable_postgres" {
  default = false
}

module "postgresql" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=c12cebd"
  # source = "../../../modules/postgresql/gcp"

  instance_name          = "${var.name_prefix}-pg"
  vpc_name               = "${var.name_prefix}-vpc"
  gcp_project            = var.gcp_project
  destroyable            = var.destroyable_postgres
  user_can_create_db     = true
  databases              = ["test"]
  replication            = true
  provision_read_replica = true
}

module "postgresql_migration_source" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=c12cebd"
  # source = "../../../modules/postgresql/gcp"

  instance_name             = "${var.name_prefix}-pg"
  vpc_name                  = "${var.name_prefix}-vpc"
  gcp_project               = var.gcp_project
  destroyable               = var.destroyable_postgres
  user_can_create_db        = true
  databases                 = ["test"]
  replication               = true
  provision_read_replica    = true
  database_version          = "POSTGRES_14"
  prep_upgrade_as_source_db = true
}

module "postgresql_migration_destination" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=c12cebd"
  # source = "../../../modules/postgresql/gcp"

  instance_name          = "${var.name_prefix}-pg"
  vpc_name               = "${var.name_prefix}-vpc"
  gcp_project            = var.gcp_project
  destroyable            = var.destroyable_postgres
  user_can_create_db     = true
  databases              = []
  replication            = false
  provision_read_replica = false
  pre_promotion          = true
  database_version       = "POSTGRES_15"
}
