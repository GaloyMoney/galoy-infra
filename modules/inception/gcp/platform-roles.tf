resource "google_project_iam_member" "bastion_platform_make" {
  project = local.project
  role    = google_project_iam_custom_role.platform_make.id
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "bastion_platform_destroy" {
  project = local.project
  role    = google_project_iam_custom_role.platform_destroy.id
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_member" "bastion_container_admin" {
  project = local.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.bastion.email}"
}

resource "google_project_iam_custom_role" "platform_make" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-platform-make", "-", "_")
  title       = "Create Platform"
  description = "Role for executing platform tf files for ${local.name_prefix}"
  permissions = [
    "compute.backendBuckets.create",
    "compute.backendBuckets.get",
    "compute.backendBuckets.use",
    "compute.addresses.create",
    "compute.addresses.get",
    "compute.globalAddresses.create",
    "compute.globalAddresses.get",
    "compute.globalAddresses.use",
    "compute.globalForwardingRules.create",
    "compute.globalForwardingRules.get",
    "compute.globalOperations.get",
    "compute.firewalls.create",
    "compute.firewalls.get",
    "compute.firewalls.update",
    "compute.instanceGroupManagers.get",
    "compute.networks.get",
    "compute.networks.updatePolicy",
    "compute.routers.create",
    "compute.routers.get",
    "compute.routers.update",
    "compute.regionOperations.get",
    "compute.sslCertificates.create",
    "compute.sslCertificates.get",
    "compute.subnetworks.get",
    "compute.subnetworks.create",
    "compute.targetHttpsProxies.create",
    "compute.targetHttpsProxies.get",
    "compute.targetHttpsProxies.use",
    "compute.targetHttpProxies.create",
    "compute.targetHttpProxies.get",
    "compute.targetHttpProxies.use",
    "compute.urlMaps.create",
    "compute.urlMaps.get",
    "compute.urlMaps.use",
    "compute.zones.get",
    "compute.zones.list",
  ]
}

resource "google_project_iam_custom_role" "platform_destroy" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-platform-destroy", "-", "_")
  title       = "Create Platform"
  description = "Role for destroying the platform ${local.name_prefix}"
  permissions = [
    "compute.backendBuckets.delete",
    "compute.addresses.delete",
    "compute.globalAddresses.delete",
    "compute.globalForwardingRules.delete",
    "compute.firewalls.delete",
    "compute.routers.delete",
    "compute.sslCertificates.delete",
    "compute.subnetworks.delete",
    "compute.targetHttpsProxies.delete",
    "compute.targetHttpProxies.delete",
    "compute.urlMaps.delete",
  ]
}
