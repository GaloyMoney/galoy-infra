variable "name_prefix" {}
variable "cluster_endpoint" {}
variable "cluster_ca_cert" {}
variable "secrets" {
  description = "Optionally you can inject all secrets as a JSON blob"
  default     = ""
  sensitive   = true
}

variable "smoketest_cronjob" { default = false }

locals {
  name_prefix            = var.name_prefix
  smoketest_namespace    = "${local.name_prefix}-smoketest"
  galoy_namespace        = "${local.name_prefix}-galoy"
  smoketest_cronjob      = var.smoketest_cronjob
  smoketest_name         = "smoketest"
  smoketest_cronjob_name = "${local.smoketest_name}-cronjob"
  cluster_endpoint       = var.cluster_endpoint
  cluster_ca_cert        = var.cluster_ca_cert
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
