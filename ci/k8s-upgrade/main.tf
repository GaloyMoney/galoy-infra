locals {
  version_prefix = "1.28."
  project        = "galoy-infra-testflight"
}

data "google_container_engine_versions" "euwest6" {
  provider       = google-beta
  location       = "europe-west6"
  version_prefix = local.version_prefix
  project        = local.project
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
  euwest6_versions = toset(data.google_container_engine_versions.euwest6.valid_master_versions)
  uscentral1_versions = toset(data.google_container_engine_versions.uscentral1.valid_master_versions)
  useast1_versions = toset(data.google_container_engine_versions.useast1.valid_master_versions)

  # Find the intersection of all sets, i.e., common versions
  common_versions = setintersection(local.euwest6_versions, local.uscentral1_versions, local.useast1_versions)
}

output "latest_version" {
  # Convert the set back to a list, sort it, and get the last element which is the highest version
  value = length(local.common_versions) > 0 ? sort(tolist(local.common_versions))[length(local.common_versions) - 1] : ""
}
