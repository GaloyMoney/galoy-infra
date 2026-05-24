output "instance_name" {
  value = google_sql_database_instance.instance.name
}

output "private_ip" {
  value = google_sql_database_instance.instance.private_ip_address
}

output "read_replica_private_ip" {
  value = local.provision_read_replica ? google_sql_database_instance.replica[0].private_ip_address : ""
}

output "admin_user" {
  value = google_sql_user.admin.name
}

output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}
