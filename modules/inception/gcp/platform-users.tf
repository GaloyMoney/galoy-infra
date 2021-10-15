resource "google_project_iam_member" "platform_make" {
  for_each = toset(local.platform_admins)
  project  = local.project
  role     = google_project_iam_custom_role.platform_make.id
}

resource "google_project_iam_member" "platform_destroy" {
  for_each = toset(local.platform_admins)
  project  = local.project
  role     = google_project_iam_custom_role.platform_destroy.id
  member   = each.key
}

resource "google_project_iam_member" "container_admin" {
  for_each = toset(local.platform_admins)
  project  = local.project
  role     = "roles/container.admin"
  member   = each.key
}

resource "google_service_account_iam_member" "nodes_account_iam" {
  for_each           = toset(local.platform_admins)
  service_account_id = google_service_account.cluster_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.key
}
