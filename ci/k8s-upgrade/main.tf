locals {
  version_prefix = "1.30."
  project        = "infra-testflight"
}

data "google_container_engine_versions" "uscentral1" {
  provider       = google-beta
  location       = "us-central1"
  version_prefix = local.version_prefix
  project        = local.project
}

data "google_container_engine_versions" "useast1" {
  provider       = google-beta
  location       = "us-east1"
  version_prefix = local.version_prefix
  project        = local.project
}

locals {
  # Convert outputs to sets
  uscentral1_versions = data.google_container_engine_versions.uscentral1.valid_master_versions
  useast1_versions    = data.google_container_engine_versions.useast1.valid_master_versions

  # Find the intersection of all sets, i.e., common versions
  common_versions = [for version in local.useast1_versions : version if contains(local.uscentral1_versions, version)]
}

output "latest_version" {
  value = local.common_versions[0]
}
