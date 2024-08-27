resource "google_project_iam_custom_role" "inception_make" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-inception-make", "-", "_")
  title       = "Create Inception"
  description = "Role for executing inception tf files for ${local.name_prefix}"
  permissions = [
    "compute.addresses.create",
    "compute.addresses.createInternal",
    "compute.addresses.get",
    "compute.addresses.use",
    "compute.disks.create",
    "compute.firewalls.create",
    "compute.firewalls.get",
    "compute.instances.addAccessConfig",
    "compute.instances.create",
    "compute.instances.get",
    "compute.instances.setLabels",
    "compute.instances.setMetadata",
    "compute.instances.setServiceAccount",
    "compute.instances.setTags",
    "compute.instances.getIamPolicy",
    "compute.instances.setIamPolicy",
    "compute.globalAddresses.setLabels",
    "compute.routers.get",
    "compute.routers.create",
    "compute.routers.update",
    "compute.networks.create",
    "compute.networks.get",
    "compute.networks.updatePolicy",
    "compute.regionOperations.get",
    "compute.zoneOperations.get",
    "compute.subnetworks.create",
    "compute.subnetworks.get",
    "compute.subnetworks.use",
    "compute.subnetworks.useExternalIp",
    "compute.zones.get",
    "iam.serviceAccounts.actAs",
    "iam.serviceAccounts.create",
    "iam.serviceAccounts.get",
    "iam.serviceAccounts.getIamPolicy",
    "iam.serviceAccounts.setIamPolicy",
    "resourcemanager.projects.getIamPolicy",
    "resourcemanager.projects.setIamPolicy",
    "storage.buckets.create",
    "storage.buckets.update",
    "storage.buckets.get",
    "storage.buckets.getIamPolicy",
    "storage.buckets.setIamPolicy",
  ]
}

resource "google_project_iam_custom_role" "inception_destroy" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-inception-destroy", "-", "_")
  title       = "Destroy Inception"
  description = "Role for destroying inception environment for ${local.name_prefix}"
  permissions = [
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.firewalls.delete",
    "compute.instances.delete",
    "compute.instances.deleteAccessConfig",
    "compute.routers.delete",
    "compute.networks.delete",
    "compute.subnetworks.delete",
    "compute.globalAddresses.deleteInternal",
    "iam.serviceAccounts.delete",
    "iam.roles.delete",
    "storage.buckets.delete",
    "resourcemanager.projects.get",
    "servicenetworking.services.get",
    "servicenetworking.services.deleteConnection",
    "serviceusage.operations.get"
  ]
}

resource "google_project_iam_member" "inception_make" {
  project = local.project
  role    = google_project_iam_custom_role.inception_make.id
  member  = "serviceAccount:${var.inception_sa}"
}
resource "google_project_iam_member" "inception_destroy" {
  project = local.project
  role    = google_project_iam_custom_role.inception_destroy.id
  member  = "serviceAccount:${var.inception_sa}"
}

resource "google_project_iam_member" "inception_platform_make" {
  project = local.project
  role    = google_project_iam_custom_role.platform_make.id
  member  = "serviceAccount:${local.inception_sa}"
}

resource "google_project_iam_member" "inception_platform_destroy" {
  project = local.project
  role    = google_project_iam_custom_role.platform_destroy.id
  member  = "serviceAccount:${local.inception_sa}"
}

resource "google_project_iam_member" "inception_container_admin" {
  project = local.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${local.inception_sa}"
}
