data "google_iam_policy" "external_users" {
  binding {
    role    = "roles/compute.osLoginExternalUser"
    members = local.external_users
  }
}

resource "google_organization_iam_policy" "external_users" {
  count       = local.organization_id ? 1 : 0
  policy_data = data.google_iam_policy.external_users.policy_data
}
