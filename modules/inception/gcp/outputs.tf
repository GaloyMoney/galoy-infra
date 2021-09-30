output "bastion_ip" {
  description = "The public IP of the bastion host."
  value       = google_compute_address.bastion.address
}

output "bastion_name" {
  value = google_compute_address.bastion.name
}

output "bastion_zone" {
  value = google_compute_instance.bastion.zone
}

output "cluster_sa" {
  description = "Service Account for cluster nodes."
  value       = google_service_account.cluster_service_account.email
}

output "grafana_sa" {
  description = "Service Account for grafana."
  value       = google_service_account.grafana_service_account.email
}

output "backups_bucket_name" {
  description = "The name of the bucket where backups shall be stored"
  value = google_storage_bucket.backups.name
}

output "backups_sa" {
  description = "Service Account for for the backups bucket."
  value       = google_service_account.backups.email
}
