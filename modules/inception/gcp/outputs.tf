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