output "smoketest_kubeconfig" {
  value = base64encode(templatefile("${path.module}/kubeconfig.tmpl.yml",
    { name : "smoketest",
      namespace : local.smoketest_namespace,
      cert : local.cluster_ca_cert,
      endpoint : local.cluster_endpoint,
      token = data.kubernetes_secret.smoketest_token.data.token
  }))
}
