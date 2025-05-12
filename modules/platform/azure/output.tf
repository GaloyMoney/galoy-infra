output "client_certificate" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.primary.kube_config_raw
  sensitive = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.primary.name
}

output "master_endpoint" {
  value       = azurerm_kubernetes_cluster.primary.private_fqdn
  description = "The private FQDN of the AKS cluster's API server"
}

output "cluster_ca_cert" {
  value       = base64decode(azurerm_kubernetes_cluster.primary.kube_config.0.cluster_ca_certificate)
  sensitive   = true
  description = "The base64-decoded CA certificate for the AKS cluster"
}
