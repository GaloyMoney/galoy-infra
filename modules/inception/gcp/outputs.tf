output "bastion_ip" {
  description = "The public IP of the bastion host."
  value       = google_compute_address.bastion.address
}

output "bastion_zone" {
  value = google_compute_instance.bastion.zone
}
