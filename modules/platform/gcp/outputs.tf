output "cluster_ca_cert" {
  value = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

output "master_endpoint" {
  value = "https://${google_container_cluster.primary.private_cluster_config.0.private_endpoint}"
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster.primary.location
}

output "lnd1_ip" {
  value = google_compute_address.lnd1.address
}

output "lnd2_ip" {
  value = google_compute_address.lnd2.address
}

output "shared_pg_host" {
  value = local.deploy_shared_pg ? google_sql_database_instance.shared.0.private_ip_address : ""
}

output "shared_pg_admin_username" {
  value = local.deploy_shared_pg ? google_sql_user.shared.0.name : ""
}

output "shared_pg_admin_password" {
  value     = local.deploy_shared_pg ? google_sql_user.shared.0.password : ""
  sensitive = true
}
