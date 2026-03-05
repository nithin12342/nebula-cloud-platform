# Redis Module - Outputs
output "redis_cache_id" { value = azurerm_redis_cache.redis.id }
output "redis_cache_name" { value = azurerm_redis_cache.redis.name }
output "redis_host_name" { value = azurerm_redis_cache.redis.hostname }
output "redis_port" { value = azurerm_redis_cache.redis.ssl_port }
output "redis_primary_key" { value = azurerm_redis_cache.redis.primary_access_key; sensitive = true }
output "redis_secondary_key" { value = azurerm_redis_cache.redis.secondary_access_key; sensitive = true }
output "redis_connection_string" { value = azurerm_redis_cache.redis.connection_string; sensitive = true }
