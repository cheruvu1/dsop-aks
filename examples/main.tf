# Cluster Resource Group

resource "azurerm_resource_group" "aks" {
  count    = var.use_external_vnet ? 0 : 1
  name     = var.resource_group_name
  location = var.location
}

# AKS Cluster Network

module "aks_network" {
  source              = "../modules/aks-network"
  subnet_name         = var.subnet_name
  vnet_name           = var.vnet_name
  resource_group_name = var.use_external_vnet ? var.external_vnet_resource_group : azurerm_resource_group.aks.*.name[0]
  subnet_cidr         = var.subnet_cidr
  location            = var.location
  address_space       = var.address_space
  use_external_vnet   = var.use_external_vnet
}

# use existing virtual network
data "azurerm_subnet" "external" {
  count                = var.use_external_vnet ? 1 : 0
  name                 = var.external_vnet_subnet_name
  virtual_network_name = var.external_vnet_name
  resource_group_name  = var.external_vnet_resource_group
}

# AKS Cluster

module "aks_cluster" {
  source                   = "../modules/aks-cluster"
  cluster_name             = var.cluster_name
  location                 = var.location
  dns_prefix               = var.dns_prefix
  resource_group_name      = var.use_external_vnet ? var.external_vnet_resource_group : azurerm_resource_group.aks.*.name[0]
  kubernetes_version       = var.kubernetes_version
  private_cluster_enabled  = var.private_cluster_enabled
  managed_identity         = var.managed_identity
  aad_group_ids           = var.aad_group_ids
  enable_auto_scaling      = var.enable_auto_scaling
  node_count               = var.node_count
  min_count                = var.min_count
  max_count                = var.max_count
  os_disk_size_gb          = "1028"
  max_pods                 = "110"
  vm_size                  = var.vm_size
  vnet_subnet_id           = var.use_external_vnet ? data.azurerm_subnet.external.*.id[0] : module.aks_network.aks_subnet_id
  depends_on               = [module.aks_network]
}