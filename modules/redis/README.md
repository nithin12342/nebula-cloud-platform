# Azure Redis Cache Module

This module creates Azure Cache for Redis with clustering and persistence.

## Usage

```hcl
module "redis" {
  source              = "./modules/redis"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  
  redis_cache_name = "nebula-redis"
  
  sku    = "Premium"
  family = "P"
  capacity = 1
  
  enable_clustering = true
  shard_count     = 3
}
```

## Resources Created

| Type | Description |
|------|-------------|
| azurerm_redis_cache | Redis Cache |
| azurerm_redis_firewall_rule | Firewall rules |
| azurerm_redis_patch_schedule | Patch schedule |
