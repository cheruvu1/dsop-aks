output "azurerm_kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.cluster.id
}

output "azurerm_kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.cluster.fqdn
}

output "azurerm_kubernetes_cluster_node_resource_group" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.cluster.node_resource_group
  description = "The name of resource group where the AKS Nodes are created"
}

output "username" {
  value = azurerm_kubernetes_cluster.cluster.kube_admin_config.0.username
}

output "password" {
  value = azurerm_kubernetes_cluster.cluster.kube_admin_config.0.password
}

output "host" {
  value = azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
}

output "client_key" {
  value = azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.cluster.kube_config_raw
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.cluster.kube_config.0.cluster_ca_certificate
}