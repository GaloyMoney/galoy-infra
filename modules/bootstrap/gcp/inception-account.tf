locals {
  inception_sa_name = "${local.name_prefix}-inception-tf"
}

resource "google_service_account" "inception" {
  project      = local.project
  account_id   = local.inception_sa_name
  display_name = local.inception_sa_name
  description  = "Account for running inception phase for ${local.name_prefix}"
}

resource "google_project_iam_custom_role" "bootstrap" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-bootstrap", "-", "_")
  title       = "Bootstrap for ${local.name_prefix}"
  description = "Role for bootstrapping inception tf files"
  permissions = [
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "compute.instances.getIamPolicy",
    "compute.instances.setIamPolicy",
    "iam.roles.create",
    "iam.roles.get",
    "iam.roles.update",
    "iam.roles.undelete",
    "iam.roles.delete",
    "storage.buckets.get",
    "compute.projects.get",
    "compute.addresses.delete",
    "compute.firewalls.delete",
    "compute.instances.delete",
    "compute.instances.deleteAccessConfig",
    "compute.networks.delete",
    "compute.subnetworks.delete",
    "iam.serviceAccounts.delete",
    "iam.roles.delete",
    "storage.buckets.delete",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
  ]
}

resource "google_project_iam_member" "inception_boostrap" {
  project = local.project
  role    = google_project_iam_custom_role.bootstrap.id
  member  = "serviceAccount:${google_service_account.inception.email}"
}
