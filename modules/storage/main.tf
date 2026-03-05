# Azure Storage Module
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 3.100" }
  }
}
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier            = var.account_tier
  account_replication_type = var.replication_type
  account_kind            = var.account_kind
  enable_https_traffic_only = var.enable_https_only
  min_tls_version         = "TLS1_2"
  allow_blob_public_access = var.allow_public_blob
  is_hns_enabled          = var.enable_hns
  nfsv3_enabled           = var.enable_nfsv3
  tags                    = var.tags
}
resource "azurerm_storage_container" "containers" {
  for_each = { for c in var.containers : c.name => c }
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = each.value.access_type
}
resource "azurerm_storage_queue" "queues" {
  for_each = { for q in var.queues : q => q }
  name                 = each.value
  storage_account_name = azurerm_storage_account.storage.name
}
resource "azurerm_storage_table" "tables" {
  for_each = { for t in var.tables : t => t }
  name                 = each.value
  storage_account_name = azurerm_storage_account.storage.name
}
resource "azurerm_storage_account_network_rules" "network_rules" {
  count = length(var.vnet_subnet_ids) > 0 ? 1 : 0
  storage_account_id = azurerm_storage_account.storage.id
  default_action     = "Deny"
  virtual_network_subnet_ids = var.vnet_subnet_ids
  ip_rules           = var.ip_rules
}
