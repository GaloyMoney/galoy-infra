resource "google_service_account" "grafana_service_account" {
  project      = local.project
  account_id   = "${local.name_prefix}-grafana"
  display_name = "${local.name_prefix} Grafana"
}

resource "google_project_iam_member" "grafana_service_account_monitoring_viewer" {
  project = local.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.grafana_service_account.email}"
}