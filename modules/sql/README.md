# Azure SQL Database Module

This module creates Azure SQL Database with elastic pools, server, and firewall rules.

## Usage

```hcl
module "sql" {
  source              = "./modules/sql"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  
  sql_server_name = "nebula-sql"
  admin_login     = "sqladmin"
  
  databases = [
    {
      name                = "appdb"
      collation          = "SQL_Latin1_General_CP1_CI_AS"
      sku_name           = "S0"
      max_size_gb        = 10
    }
  ]
}
```

## Resources Created

| Type | Description |
|------|-------------|
| azurerm_sql_server | SQL Server |
| azurerm_sql_database | SQL Databases |
| azurerm_sql_elasticpool | Elastic pools (optional) |
| azurerm_sql_firewall_rule | Firewall rules |
| azurerm_sql_virtual_network_rule | VNet rules |
