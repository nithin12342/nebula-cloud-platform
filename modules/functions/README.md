# Azure Functions Module

This module creates Azure Functions app with App Service Plan and storage.

## Usage
```hcl
module "functions" {
  source              = "./modules/functions"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  
  function_app_name = "nebula-api"
  app_service_plan_name = "func-plan"
}
```

## Resources
| Type | Description |
|------|-------------|
| azurerm_service_plan | App Service Plan |
| azurerm_function_app | Function App |
| azurerm_storage_account | Storage Account |
