# Nebula Cloud Platform - Root Module
# This is the main Terraform configuration that composes all modules

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# VNet Module
module "vnet" {
  source = "./modules/vnet"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  vnet_name         = var.vnet_name
  address_space     = var.vnet_address_space
  subnets           = var.subnets
  dns_servers       = var.dns_servers
  tags              = var.tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  cluster_name       = var.aks_cluster_name
  dns_prefix         = var.aks_dns_prefix
  kubernetes_version = var.kubernetes_version
  subnet_id          = module.vnet.subnet_ids["aks-subnet"]
  
  default_node_pool = var.default_node_pool
  additional_node_pools = var.additional_node_pools
  
  tags = var.tags
}

# SQL Module
module "sql" {
  source = "./modules/sql"
  
  count = var.enable_sql ? 1 : 0
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  sql_server_name   = var.sql_server_name
  admin_login       = var.sql_admin_login
  admin_password    = var.sql_admin_password
  
  databases = var.databases
  firewall_rules = var.sql_firewall_rules
  
  tags = var.tags
}

# Redis Module
module "redis" {
  source = "./modules/redis"
  
  count = var.enable_redis ? 1 : 0
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  redis_cache_name  = var.redis_cache_name
  
  sku     = var.redis_sku
  capacity = var.redis_capacity
  family   = var.redis_family
  
  tags = var.tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  storage_account_name = var.storage_account_name
  
  account_tier            = var.storage_account_tier
  replication_type       = var.storage_replication_type
  containers              = var.storage_containers
  
  tags = var.tags
}

# Key Vault Module
module "keyvault" {
  source = "./modules/keyvault"
  
  count = var.enable_keyvault ? 1 : 0
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  keyvault_name     = var.keyvault_name
  
  tenant_id = var.azure_tenant_id
  
  sku_name = var.keyvault_sku
  
  tags = var.tags
}

# Functions Module
module "functions" {
  source = "./modules/functions"
  
  count = var.enable_functions ? 1 : 0
  
  resource_group_name   = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  function_app_name    = var.function_app_name
  app_service_plan_name = var.function_app_plan_name
  storage_account_name = module.storage.storage_account_name
  
  sku_name = var.function_sku_name
  
  tags = var.tags
}
