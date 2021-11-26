
resource "google_project_iam_custom_role" "platform_make" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-platform-make", "-", "_")
  title       = "Create Platform"
  description = "Role for executing platform tf files for ${local.name_prefix}"
  permissions = [
    "logging.logMetrics.create",
    "logging.logMetrics.get",
    "logging.logMetrics.list",
    "logging.logMetrics.update",
    "compute.backendBuckets.create",
    "compute.backendBuckets.get",
    "compute.backendBuckets.use",
    "compute.addresses.create",
    "compute.addresses.get",
    "compute.globalAddresses.createInternal",
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
    "compute.networks.use",
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
    "servicenetworking.services.addPeering",
    "servicenetworking.services.get",
    "cloudsql.instances.create",
    "cloudsql.instances.get",
    "cloudsql.users.create",
    "cloudsql.users.list",
  ]
}

resource "google_project_iam_custom_role" "platform_destroy" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-platform-destroy", "-", "_")
  title       = "Create Platform"
  description = "Role for destroying the platform ${local.name_prefix}"
  permissions = [
    "logging.logMetrics.delete",
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
    "compute.networks.removePeering",
    "cloudsql.instances.delete",
    "cloudsql.users.delete",
  ]
}
