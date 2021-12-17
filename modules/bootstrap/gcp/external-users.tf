resource "google_organization_iam_member" "external_users" {
  for_each = local.organization_id != "" ? toset(local.external_users) : toset([])

  org_id = local.organization_id
  role   = "roles/compute.osLoginExternalUser"
  member = "user:${each.key}"
}
