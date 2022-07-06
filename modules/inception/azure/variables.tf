variable "name_prefix" {
  default = "test18"
}
variable "network_prefix" {
  default = "10.0"
}
variable "resource_group_name" {
}
locals {
  name_prefix              = var.name_prefix
  network_prefix         = var.network_prefix
  resource_group_name   = var.resource_group_name
}
