data "google_container_engine_versions" "central1b" {
  provider       = google-beta
  location       = "europe-west6"
  version_prefix = "1.28."
  project        = "galoy-infra-testflight"
}

output "latest_version" {
  value = data.google_container_engine_versions.central1b.latest_node_version
}
