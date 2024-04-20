variable "name_prefix" {}
variable "gcp_project" {}
variable "destroyable_postgres" {
  default = false
}

module "postgresql" {
  source = "git::https://github.com/GaloyMoney/galoy-infra.git//modules/postgresql/gcp?ref=caa0cd8"
  # source = "../../../modules/postgresql/gcp"

  instance_name      = "${var.name_prefix}-pg"
  vpc_name           = "${var.name_prefix}-vpc"
  gcp_project        = var.gcp_project
  destroyable        = var.destroyable_postgres
  user_can_create_db = true
  databases          = ["stablesats"]
  replication        = true
}
