resource "azurerm_virtual_network" "aks_vnet" {
  count               = var.use_external_vnet ? 0 : 1
  name                = var.vnet_name
  address_space       = [var.address_space]
  resource_group_name = var.resource_group_name
  location            = var.location
}
resource "azurerm_subnet" "aks_subnet" {
  count                = var.use_external_vnet ? 0 : 1
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.*.name[0]
  address_prefixes     = [var.subnet_cidr]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}