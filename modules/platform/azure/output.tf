output "client_certificate" {
  value     = azurerm_kubernetes_cluster.primary.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.primary.kube_config_raw
  sensitive = true
}
