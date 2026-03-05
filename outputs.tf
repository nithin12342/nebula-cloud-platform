# Nebula Cloud Platform - Outputs

output "resource_group_name" { value = azurerm_resource_group.main.name }
output "resource_group_id" { value = azurerm_resource_group.main.id }
output "location" { value = azurerm_resource_group.main.location }

output "vnet_id" { value = module.vnet.vnet_id }
output "vnet_name" { value = module.vnet.vnet_name }
output "subnet_ids" { value = module.vnet.subnet_ids }

output "aks_cluster_id" { value = module.aks.cluster_id }
output "aks_cluster_name" { value = module.aks.cluster_name }
output "aks_cluster_fqdn" { value = module.aks.cluster_fqdn }
output "aks_node_resource_group" { value = module.aks.node_resource_group }

output "sql_server_fqdn" { value = try(module.sql[0].sql_server_fqdn, "") }
output "redis_cache_hostname" { value = try(module.redis[0].redis_host_name, "") }
output "storage_account_name" { value = module.storage.storage_account_name }
output "keyvault_uri" { value = try(module.keyvault[0].keyvault_uri, "") }
output "function_app_hostname" { value = try(module.functions[0].function_app_default_hostname, "") }
