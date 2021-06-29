locals {
  inception_sa_name = "${local.name_prefix}-inception-tf"
}

resource "google_service_account" "inception" {
  account_id   = local.inception_sa_name
  display_name = local.inception_sa_name
  description  = "Account for running inception phase for ${local.project}"
}

resource "google_project_iam_custom_role" "bootstrap" {
  role_id     = replace("${local.name_prefix}-bootstrap", "-", "_")
  title       = "Bootstrap"
  description = "Role for bootstrapping inception tf files"
  permissions = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "iam.roles.create",
    "iam.roles.get",
    "iam.roles.update",
    "iam.roles.undelete",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
  ]
}

resource "google_project_iam_member" "inception_boostrap" {
  role   = google_project_iam_custom_role.bootstrap.id
  member = "serviceAccount:${google_service_account.inception.email}"
}
