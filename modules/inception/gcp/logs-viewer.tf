resource "google_project_iam_member" "dev_read_log" {
  project  = local.project
  for_each = toset(local.log_viewers)
  role     = "roles/logging.viewer"
  member   = each.key
}
