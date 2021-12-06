variable "dry_run" { default = true }
variable "run_hour" { default = 0 }
variable "start_hour" { default = 3 }
variable "end_hour" { default = 5 }
variable "time_zone" { default = "Etc/UTC" }
variable "kubemonkey_notification_url" { sensitive = true }

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
      dryRun : var.dry_run
      runHour : var.run_hour
      startHour : var.start_hour
      endHour : var.end_hour
      timeZone : var.time_zone
      whitelistedNamespaces : local.whitelisted_namespaces
      notificationUrl : var.kubemonkey_notification_url
    })
  ]
}
