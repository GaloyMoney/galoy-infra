resource "google_storage_bucket" "tf_state" {
  name     = "${local.name_prefix}-tf-state"
  project  = local.project
  location = local.tf_state_bucket_location
  versioning {
    enabled = true
  }
  force_destroy = local.tf_state_bucket_force_destroy
}

resource "google_storage_bucket_iam_member" "inception" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.inception.email}"
}
