variable "gcp_project" {}
variable "vpc_name" {}
variable "instance_name" {}
variable "instance_admin_password" {}
variable "region" {
  default = "us-east1"
}
variable "destroyable" {
  default = false
}
variable "user_can_create_db" {
  default = false
}
variable "highly_available" {
  default = true
}
variable "tier" {
  default = "db-custom-1-3840"
}
variable "max_connections" { default = 0 }
variable "database_version" {
  default = "POSTGRES_14"
}
variable "databases" {
  type = list(string)
}

locals {
  gcp_project             = var.gcp_project
  vpc_name                = var.vpc_name
  region                  = var.region
  instance_name           = var.instance_name
  instance_admin_password = var.instance_admin_password
  database_version        = var.database_version
  destroyable             = var.destroyable
  highly_available        = var.highly_available
  tier                    = var.tier
  max_connections         = var.max_connections
  databases               = var.databases
}
