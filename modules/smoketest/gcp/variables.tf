variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

variable "smoketest_cronjob" { default = false }
variable "k8s_secret_reader_enabled" { default = false }

locals {
  name_prefix      = var.name_prefix
  cluster_endpoint = var.cluster_endpoint
  cluster_ca_cert  = var.cluster_ca_cert

  galoy_namespace        = "${local.name_prefix}-galoy"
  concourse_namespace    = "${local.name_prefix}-concourse"
  bitcoin_namespace      = "${local.name_prefix}-bitcoin"
  smoketest_namespace    = "${local.name_prefix}-smoketest"
  smoketest_name         = "smoketest"
  smoketest_cronjob      = var.smoketest_cronjob
  smoketest_cronjob_name = "${local.smoketest_name}-cronjob"

  k8s_secret_reader_enabled = var.k8s_secret_reader_enabled
}
