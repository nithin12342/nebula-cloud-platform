# Azure Key Vault Module
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.100" }
  }
}
resource "azurerm_key_vault" "kv" {
  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  sku_name                  = var.sku_name
  tenant_id                 = var.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization = var.enable_rbac_authorization
  enable_deletion_protection = var.deletion_protection
  network_acls {
    default_action = var.network_default_action
    ip_rules       = var.ip_rules
    virtual_network_subnet_ids = var.vnet_subnet_ids
  }
  tags = var.tags
}
resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = var.service_principal_object_id
  key_permissions    = var.key_permissions
  secret_permissions = var.secret_permissions
  certificate_permissions = var.cert_permissions
}
resource "azurerm_key_vault_secret" "secrets" {
  for_each = { for s in var.secrets : s.name => s }
  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.kv.id
  content_type = each.value.content_type
  tags         = each.value.tags
}
resource "azurerm_key_vault_key" "keys" {
  for_each = { for k in var.keys : k.name => k }
  name         = each.value.name
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = each.value.key_type
  key_size     = each.value.key_size
  key_opts     = each.value.key_opts
  tags         = each.value.tags
}
