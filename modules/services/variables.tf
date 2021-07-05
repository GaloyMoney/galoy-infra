variable "name_prefix" {}
variable "ingress_nginx_version" {
  default    = "3.34.0"
}
variable "cert_manager_version" {
  default    = "v1.4.0"
}

locals {
  ingress_namespace = "${var.name_prefix}-ingress"
  ingress_nginx_version = var.ingress_nginx_version
  cert_manager_version = var.cert_manager_version
}
