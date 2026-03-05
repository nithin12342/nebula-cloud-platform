# Azure Redis Cache Module

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_redis_cache" "redis" {
  name                = var.redis_cache_name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.capacity
  family              = var.family
  sku_name            = var.sku
  ssl_port            = 6380
  timeout             = var.timeout
  
  # Redis version
  redis_version = var.redis_version
  
  # Shard count for clustering
  shard_count = var.enable_clustering ? var.shard_count : 0
  
  # Enable non-SSL port
  non_ssl_port_enabled = var.non_ssl_port_enabled
  
  # Connectivity
  public_network_access_enabled = var.public_network_access_enabled
  
  # Minimum TLS version
  minimum_tls_version = var.minimum_tls_version
  
  # Memory
  memory = var.memory
  
  # Persistence
  rdb_backup_enabled = var.rdb_backup_enabled
  rdb_backup_frequency = var.rdb_backup_frequency
  rdb_backup_max_snapshot_count = var.rdb_backup_max_snapshot_count
  rdb_storage_connection_string = var.rdb_storage_connection_string
  
  # AOF persistence
  aof_backup_enabled = var.aof_backup_enabled
  aof_storage_connection_string = var.aof_storage_connection_string
  
  # Patch schedule
  patch_schedule {
    day_of_week = var.patch_schedule_day
    start_hour_utc = var.patch_schedule_hour
  }
  
  # Private endpoint
  dynamic "private_endpoint" {
    for_each = var.private_endpoint_subnet_id != "" ? [1] : []
    content {
      subnet_id = var.private_endpoint_subnet_id
    }
  }
  
  # Tags
  tags = var.tags
}

resource "azurerm_redis_firewall_rule" "firewall_rules" {
  for_each = { for rule in var.firewall_rules : rule.name => rule }
  
  name                = each.value.name
  redis_cache_name   = azurerm_redis_cache.redis.name
  resource_group_name = var.resource_group_name
  start_ip_address   = each.value.start_ip_address
  end_ip_address     = each.value.end_ip_address
}

resource "azurerm_redis_enterprise_cluster" "enterprise" {
  count = var.enable_enterprise ? 1 : 0
  
  name                = "${var.redis_cache_name}-enterprise"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.enterprise_sku
  
  minimum_tls_version = var.minimum_tls_version
  
  tags = var.tags
}
