variable "gcp_project" {}
variable "vpc_name" {}
variable "instance_name" {}
variable "region" {
  default = "us-east1"
}
variable "destroyable" {
  default = false
}
variable "highly_available" {
  default = true
}
variable "tier" {
  default = "db-f1-micro"
}
variable "max_connections" { default = 0 }

variable "databases" {
  type = list(string)
}

locals {
  gcp_project      = var.gcp_project
  vpc_name         = var.vpc_name
  region           = var.region
  instance_name    = var.instance_name
  destroyable      = var.destroyable
  highly_available = var.highly_available
  tier             = var.tier
  max_connections  = var.max_connections
  databases        = var.databases
}
