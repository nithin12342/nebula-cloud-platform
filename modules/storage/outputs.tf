# Storage Module - Outputs
output "storage_account_id" { value = azurerm_storage_account.storage.id }
output "storage_account_name" { value = azurerm_storage_account.storage.name }
output "storage_account_primary_endpoints" { value = azurerm_storage_account.storage.primary_endpoints }
output "storage_account_primary_access_key" { value = azurerm_storage_account.storage.primary_access_key; sensitive = true }
output "container_ids" { value = { for c in azurerm_storage_container.containers : c.name => c.id } }
