data "google_container_engine_versions" "central1b" {
  provider       = google-beta
  location       = "us-central1"
  version_prefix = "1.26."
  project        = "*"
}

output "latest_version" {
  value = data.google_container_engine_versions.central1b.latest_node_version
}
