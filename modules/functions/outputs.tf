# Functions Module - Outputs
output "function_app_id" { value = azurerm_function_app.func_app.id }
output "function_app_name" { value = azurerm_function_app.func_app.name }
output "function_app_default_hostname" { value = azurerm_function_app.func_app.default_hostname }
output "function_app_identity_principal_id" { value = azurerm_function_app.func_app.identity.0.principal_id }
output "storage_account_id" { value = azurerm_storage_account.func_storage.id }
output "storage_account_name" { value = azurerm_storage_account.func_storage.name }
output "app_service_plan_id" { value = azurerm_service_plan.func_plan.id }
