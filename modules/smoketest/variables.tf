variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

variable "k8s_secret_reader_enabled" { default = false }

locals {
  name_prefix      = var.name_prefix
  cluster_endpoint = var.cluster_endpoint
  cluster_ca_cert  = var.cluster_ca_cert

  concourse_namespace = "${local.name_prefix}-concourse"
  smoketest_namespace = "${local.name_prefix}-smoketest"
  smoketest_name      = "smoketest"

  k8s_secret_reader_enabled = var.k8s_secret_reader_enabled
}
