# Azure SQL Database Module

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_sql_server" "sql" {
  name                         = var.sql_server_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  version                      = var.sql_version
  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password
  
  # Azure AD Authentication
  azure_ad_administrator {
    login                    = var.aad_admin_login
    object_id                = var.aad_admin_object_id
    tenant_id                = var.aad_tenant_id
  }
  
  # Network
  public_network_access_enabled = var.public_network_access_enabled
  
  # Tags
  tags = var.tags
}

resource "azurerm_sql_database" "databases" {
  for_each = { for db in var.databases : db.name => db }
  
  name                = each.value.name
  server_name        = azurerm_sql_server.sql.name
  resource_group_name = var.resource_group_name
  location           = var.location
  
  # SKU
  sku_name = each.value.sku_name
  
  # Storage
  max_size_gb = each.value.max_size_gb
  collation   = each.value.collation
  
  # License
  license_type = each.value.license_type
  
  # Transparent Data Encryption
  transparent_data_encryption_enabled = each.value.tde_enabled
  
  # Tags
  tags = var.tags
  
  lifecycle {
    ignore_changes = [sku_name]
  }
}

resource "azurerm_sql_elasticpool" "elastic_pools" {
  for_each = { for pool in var.elastic_pools : pool.name => pool }
  
  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  location             = var.location
  server_name          = azurerm_sql_server.sql.name
  edition             = each.value.edition
  dtu                 = each.value.dtu
  db_dtu_min          = each.value.db_dtu_min
  db_dtu_max          = each.value.db_dtu_max
  storage_mb          = each.value.storage_mb
  
  tags = var.tags
}

resource "azurerm_sql_firewall_rule" "firewall_rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }
  
  name                = each.value.name
  server_name        = azurerm_sql_server.sql.name
  resource_group_name = var.resource_group_name
  start_ip_address   = each.value.start_ip_address
  end_ip_address     = each.value.end_ip_address
}

resource "azurerm_sql_virtual_network_rule" "vnet_rules" {
  for_each = { for rule in var.vnet_rules : rule.name => rule }
  
  name                = each.value.name
  server_name        = azurerm_sql_server.sql.name
  resource_group_name = var.resource_group_name
  subnet_id          = each.value.subnet_id
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  count = var.audit_enabled ? 1 : 0
  
  server_id   = azurerm_sql_server.sql.id
  enabled     = true
  retention_days = var.audit_retention_days
}
