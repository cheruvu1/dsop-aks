output "aks_subnet_id" {
  value = var.use_external_vnet ? null : azurerm_subnet.aks_subnet.*.id[0]
}
output "aks_vnet_id" {
  value = var.use_external_vnet ? null : azurerm_virtual_network.aks_vnet.*.id[0]
}