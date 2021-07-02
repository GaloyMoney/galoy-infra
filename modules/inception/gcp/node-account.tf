resource "google_service_account" "cluster_service_account" {
  project      = local.project
  account_id   = "${local.name_prefix}-cluster"
  display_name = "${local.name_prefix} Cluster"
}

resource "google_service_account_iam_member" "nodes_account_iam" {
  service_account_id = google_service_account.cluster_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "cluster_service_account-log_writer" {
  project = local.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-metric_writer" {
  project = local.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-monitoring_viewer" {
  project = local.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-resourceMetadata-writer" {
  project = local.project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

resource "google_project_iam_member" "cluster_service_account-gcr" {
  project = local.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cluster_service_account.email}"
}

