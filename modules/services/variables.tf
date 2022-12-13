variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}
variable "secrets" {
  description = "Optionally you can inject all secrets as a JSON blob"
  default     = ""
  sensitive   = true
}

variable "ingress_nginx_version" {
  default = "4.0.18"
}
variable "cert_manager_version" {
  default = "v1.5.3"
}
variable "letsencrypt_issuer_email" {}
variable "local_deploy" { default = false }
variable "small_footprint" { default = false }
variable "smoketest_cronjob" { default = false }
variable "enable_tracing" { default = "true" }

locals {
  local_deploy             = var.local_deploy
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
  ingress_namespace        = "${local.name_prefix}-ingress"
  ingress_nginx_version    = var.ingress_nginx_version
  cert_manager_version     = var.cert_manager_version
  letsencrypt_issuer_email = var.letsencrypt_issuer_email
  jaeger_host              = "opentelemetry-collector.${local.otel_namespace}.svc.cluster.local"
  ingress_service_name     = "${var.name_prefix}-ingress"
  small_footprint          = var.small_footprint
  enable_tracing           = var.enable_tracing
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
