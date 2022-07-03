variable "name_prefix" {}
variable "network_prefix" {
  default = "10.0"
}
locals {
  name_prefix              = var.name_prefix
  network_prefix         = var.network_prefix
}
