variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}

variable "ingress_nginx_version" {
  default = "3.37.0"
}
variable "cert_manager_version" {
  default = "v1.5.3"
}
variable "letsencrypt_issuer_email" {}

locals {
  smoketest_namespace      = "${var.name_prefix}-smoketest"
  smoketest_name           = "smoketest"
  cluster_endpoint         = var.cluster_endpoint
  cluster_ca_cert          = var.cluster_ca_cert
  ingress_namespace        = "${var.name_prefix}-ingress"
  ingress_nginx_version    = var.ingress_nginx_version
  cert_manager_version     = var.cert_manager_version
  letsencrypt_issuer_email = var.letsencrypt_issuer_email
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
