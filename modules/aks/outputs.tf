# AKS Module - Outputs

output "cluster_id" {
  description = "The AKS cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "cluster_fqdn" {
  description = "The AKS cluster FQDN"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "kube_config" {
  description = "The AKS cluster kubeconfig"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive  = true
}

output "node_resource_group" {
  description = "The node resource group name"
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "default_node_pool_id" {
  description = "The default node pool ID"
  value       = azurerm_kubernetes_cluster.aks.default_node_pool.0.id
}

output "additional_node_pool_ids" {
  description = "Map of additional node pool names to IDs"
  value       = { for pool in azurerm_kubernetes_cluster_node_pool.additional_pools : pool.name => pool.id }
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.aks.id
}

output "identity_principal_id" {
  description = "The managed identity principal ID"
  value       = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}
