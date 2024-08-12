variable "name_prefix" {}
variable "gcp_project" {}
variable "destroyable_postgres" {
  default = false
}

module "postgresql" {
  #source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=127af28"
  source = "../../../modules/postgresql/gcp"

  instance_name          = "${var.name_prefix}-pg"
  vpc_name               = "${var.name_prefix}-vpc"
  gcp_project            = var.gcp_project
  destroyable            = var.destroyable_postgres
  user_can_create_db     = true
  databases              = ["test"]
  replication            = true
  provision_read_replica = true
  database_version       = "POSTGRES_14"
  source_db_upgradable   = true
}

module "postgresql" {
  # source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=127af28"
  source = "../../../modules/postgresql/gcp"

  instance_name             = "${var.name_prefix}-pg"
  vpc_name                  = "${var.name_prefix}-vpc"
  gcp_project               = var.gcp_project
  destroyable               = var.destroyable_postgres
  user_can_create_db        = true
  databases                 = []
  replication               = false
  provision_read_replica    = false
  destination_db_upgradable = true
  database_version          = "POSTGRES_15"
}
