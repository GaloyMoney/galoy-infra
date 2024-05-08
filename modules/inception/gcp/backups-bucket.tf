resource "google_storage_bucket" "backups" {
  name                        = local.backups_bucket_name
  project                     = local.project
  location                    = local.backups_bucket_location
  uniform_bucket_level_access = true

  retention_policy {
    is_locked        = true
    retention_period = 2592000
  }
}

resource "google_service_account" "backups" {
  project      = local.project
  account_id   = "${local.name_prefix}-backups"
  display_name = "Account for uploading ${local.name_prefix} backups"
}

data "google_iam_policy" "backups_access" {
  binding {
    role    = "roles/storage.admin"
    members = concat(local.platform_admins, ["serviceAccount:${local.inception_sa}"])
  }

  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "serviceAccount:${google_service_account.backups.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "backups" {
  bucket      = google_storage_bucket.backups.name
  policy_data = data.google_iam_policy.backups_access.policy_data
}
