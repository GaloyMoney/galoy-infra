variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}
variable "secrets" {
  description = "Optionally you can inject all secrets as a JSON blob"
  default     = ""
  sensitive   = true
}
variable "honeycomb_api_key" {
  default   = ""
  sensitive = true
}
variable "trace_sample_pct" {
  default = 100
}

variable "small_footprint" { default = false }
variable "smoketest_cronjob" { default = false }

locals {
  name_prefix              = var.name_prefix
  smoketest_namespace      = "${local.name_prefix}-smoketest"
  otel_namespace           = "${local.name_prefix}-otel"
  galoy_namespace          = "${local.name_prefix}-galoy"
  bitcoin_namespace        = "${var.name_prefix}-bitcoin"
  monitoring_namespace     = "${var.name_prefix}-monitoring"
  addons_namespace         = "${var.name_prefix}-addons"
  smoketest_cronjob        = var.smoketest_cronjob
  smoketest_name           = "smoketest"
  smoketest_cronjob_name   = "${local.smoketest_name}-cronjob"
  cluster_endpoint         = var.cluster_endpoint
  cluster_ca_cert          = var.cluster_ca_cert
  trace_sample_pct         = var.trace_sample_pct
  small_footprint          = var.small_footprint
  honeycomb_api_key        = var.honeycomb_api_key != "" ? var.honeycomb_api_key : jsondecode(var.secrets).honeycomb_api_key
}

output "smoketest_kubeconfig" {
  value = base64encode(templatefile("${path.module}/kubeconfig.tmpl.yml",
    { name : "smoketest",
      namespace : local.smoketest_namespace,
      cert : local.cluster_ca_cert,
      endpoint : local.cluster_endpoint,
      token = data.kubernetes_secret.smoketest_token.data.token
  }))
}
