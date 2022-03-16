resource "google_project_iam_custom_role" "bastion_access" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-bastion-access", "-", "_")
  title       = "Bastion Access"
  description = "Role for bastion access"
  permissions = [
    "compute.projects.get",
    "compute.instances.list",
    "iap.tunnelInstances.accessViaIAP"
  ]
}

resource "google_project_iam_member" "bastion_access" {
  for_each = toset(local.bastion_users)

  project = local.project
  role    = google_project_iam_custom_role.bastion_access.id
  member  = each.key
}
