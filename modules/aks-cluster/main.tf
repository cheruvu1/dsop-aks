resource "azurerm_kubernetes_cluster" "cluster" {
  # ignore node_count in case we are using auto scaling
  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name            = var.default_pool_name
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.vnet_subnet_id
    max_pods        = var.max_pods
    type            = var.default_pool_type

    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling == true ? var.min_count : null
    max_count           = var.enable_auto_scaling == true ? var.max_count : null
  }

  role_based_access_control {
    azure_active_directory {
      managed = var.managed_identity
      admin_group_object_ids = var.aad_group_ids
    }
    enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
    service_cidr       = var.service_cidr
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }
}