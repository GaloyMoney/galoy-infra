data "azurerm_subnet" "dmz" {
  name                 = "${local.name_prefix}-dmz"
  virtual_network_name = local.vnet_name
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_kubernetes_cluster" "primary" {
  name                = local.cluster_name
  location            = local.cluster_location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  dns_prefix          = local.name_prefix
  kubernetes_version  = local.kube_version

  default_node_pool {
    name                 = "default"
    auto_scaling_enabled = true
    min_count            = local.min_default_node_count
    max_count            = local.max_default_node_count
    vm_size              = local.node_default_machine_type
    vnet_subnet_id       = azurerm_subnet.cluster.id
    temporary_name_for_rotation = "rotation"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "192.168.64.0/18"
    dns_service_ip = "192.168.64.10"
  }

  private_cluster_enabled = true
  private_dns_zone_id     = "System"

  identity {
    type = "SystemAssigned"
  }
}
