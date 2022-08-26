data "azurerm_subnet" "dmz" {
  name                 = "${local.name_prefix}-bastionSubnet"
  virtual_network_name = "${local.vnet_name}"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
}

resource "azurerm_kubernetes_cluster" "primary" {
  name                = local.cluster_name
  location            = local.cluster_location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  dns_prefix          = local.name_prefix

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    vnet_subnet_id = data.azurerm_subnet.dmz.id
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr = "10.0.4.0/24"
    dns_service_ip = "10.0.4.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

}
