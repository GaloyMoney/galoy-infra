
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
    "logging.sinks.create",
    "logging.sinks.delete",
    "logging.sinks.get",
    "logging.sinks.list",
    "logging.sinks.update",
    "compute.backendBuckets.create",
    "compute.backendBuckets.get",
    "compute.backendBuckets.use",
    "compute.addresses.create",
    "compute.addresses.createInternal",
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
    "compute.regionOperations.get",
    "compute.sslCertificates.create",
    "compute.sslCertificates.get",
    "compute.subnetworks.get",
    "compute.subnetworks.use",
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
    "cloudsql.instances.update",
    "cloudsql.users.create",
    "cloudsql.users.list",
    "cloudsql.instances.list",
    "bigquery.connections.create",
    "bigquery.connections.get",
    "bigquery.connections.getIamPolicy",
    "bigquery.connections.setIamPolicy",
    "monitoring.timeSeries.list",
    "monitoring.notificationChannels.create",
    "monitoring.notificationChannels.update",
    "apikeys.keys.create",
    "apikeys.keys.get",
    "apikeys.keys.getKeyString",
    "apikeys.keys.update"
  ]
}

resource "google_project_iam_custom_role" "platform_destroy" {
  project     = local.project
  role_id     = replace("${local.name_prefix}-platform-destroy", "-", "_")
  title       = "Destroy Platform"
  description = "Role for destroying the platform ${local.name_prefix}"
  permissions = [
    "logging.logMetrics.delete",
    "compute.backendBuckets.delete",
    "compute.addresses.delete",
    "compute.addresses.deleteInternal",
    "compute.globalAddresses.delete",
    "compute.globalForwardingRules.delete",
    "compute.firewalls.delete",
    "compute.sslCertificates.delete",
    "compute.subnetworks.delete",
    "compute.targetHttpsProxies.delete",
    "compute.targetHttpProxies.delete",
    "compute.urlMaps.delete",
    "compute.networks.removePeering",
    "compute.globalAddresses.deleteInternal",
    "cloudsql.instances.delete",
    "cloudsql.users.delete",
    "bigquery.connections.delete",
    "apikeys.keys.delete",
    "monitoring.notificationChannels.delete"
  ]
}
