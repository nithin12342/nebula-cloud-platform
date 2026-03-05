# SQL Module - Outputs

output "sql_server_id" {
  description = "SQL Server ID"
  value       = azurerm_sql_server.sql.id
}

output "sql_server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_sql_server.sql.fqdn
}

output "sql_server_name" {
  description = "SQL Server name"
  value       = azurerm_sql_server.sql.name
}

output "database_ids" {
  description = "Map of database names to IDs"
  value       = { for db in azurerm_sql_database.databases : db.name => db.id }
}

output "database_connection_strings" {
  description = "Map of database connection strings"
  value       = { for db in azurerm_sql_database.databases : db.name => db.connection_string }
  sensitive   = true
}

output "elastic_pool_ids" {
  description = "Map of elastic pool names to IDs"
  value       = { for pool in azurerm_sql_elasticpool.elastic_pools : pool.name => pool.id }
}
