# Azure Functions Module
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.100" }
  }
}
resource "azurerm_service_plan" "func_plan" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type            = var.os_type
  sku_name           = var.sku_name
  worker_count       = var.worker_count
  tags               = var.tags
}
resource "azurerm_storage_account" "func_storage" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier            = var.storage_tier
  account_replication_type = var.storage_replication_type
  enable_https_traffic_only = true
  min_tls_version         = "TLS1_2"
  tags                    = var.tags
}
resource "azurerm_function_app" "func_app" {
  name                = var.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.func_plan.id
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  storage_account_name   = azurerm_storage_account.func_storage.name
  https_only           = var.https_only
  enabled              = var.enabled
  client_affinity_enabled = var.client_affinity_enabled
  identity {
    type = "SystemAssigned"
  }
  app_settings = var.app_settings
  tags         = var.tags
}
resource "azurerm_linux_function_app" "func_app_v4" {
  count = var.use_linux_fx ? 1 : 0
  name                = var.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.func_plan.id
  storage_account_access_key = azurerm_storage_account.func_storage.primary_access_key
  storage_account_name   = azurerm_storage_account.func_storage.name
  https_only           = var.https_only
  identity { type = "SystemAssigned" }
  site_config {
    application_stack { python_version = var.python_version }
    always_on = var.always_on
    ftps_state = "Disabled"
    http2_enabled = true
  }
  tags = var.tags
}
