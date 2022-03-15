resource "google_service_account" "bastion" {
  project      = local.project
  account_id   = "${local.name_prefix}-bastion"
  display_name = "Bastion account for ${local.name_prefix}"
}

resource "google_service_account_iam_member" "bastion_account" {
  for_each = toset(local.bastion_users)

  service_account_id = google_service_account.bastion.name
  role               = "roles/iam.serviceAccountUser"
  member             = each.key
}
