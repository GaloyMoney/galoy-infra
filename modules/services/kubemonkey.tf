locals {
  whitelisted_namespaces = [
    "${var.name_prefix}-galoy",
    "${var.name_prefix}-bitcoin",
    "${var.name_prefix}-monitoring",
    "${var.name_prefix}-addons",
  ]
}

resource "helm_release" "kube_monkey" {
  name       = "kubemonkey"
  chart      = "kube-monkey"
  repository = "https://asobti.github.io/kube-monkey/charts/repo"
  namespace  = kubernetes_namespace.addons.metadata[0].name

  values = [
    templatefile("${path.module}/kubemonkey-values.yml.tmpl", {
      timeZone : local.kubemonkey_time_zone
      whitelistedNamespaces : local.whitelisted_namespaces
      notificationUrl : local.kubemonkey_notification_url
    })
  ]
}
