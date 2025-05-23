locals {
  name_prefix  = var.name_prefix
  cluster_name = "${var.name_prefix}-cluster"
  pods_cidr    = "192.168.0.0/18"
  svc_cidr     = "192.168.64.0/18"
}
