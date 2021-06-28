resource "google_storage_bucket" "tf_state" {
  name     = "${local.name_prefix}-tf-state"
  location = local.tf_state_bucket_location
  versioning {
    enabled = true
  }
}
