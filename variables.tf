# Nebula Cloud Platform - Root Variables

variable "resource_group_name" { type = string; default = "nebula-rg" }
variable "location" { type = string; default = "eastus" }
variable "tags" { type = map(string); default = { Environment = "production" } }

# VNet variables
variable "vnet_name" { type = string; default = "nebula-vnet" }
variable "vnet_address_space" { type = list(string); default = ["10.0.0.0/16"] }
variable "subnets" {
  type = list(object({ name = string; address_prefix = string; delegate_to = string }));
  default = [
    { name = "aks-subnet", address_prefix = "10.0.1.0/24", delegate_to = "Microsoft.ContainerService/managedClusters" },
    { name = "app-subnet", address_prefix = "10.0.2.0/24", delegate_to = "" }
  ]
}
variable "dns_servers" { type = list(string); default = [] }

# AKS variables
variable "aks_cluster_name" { type = string; default = "nebula-aks" }
variable "aks_dns_prefix" { type = string; default = "nebula" }
variable "kubernetes_version" { type = string; default = "1.29" }
variable "default_node_pool" {
  type = object({ name = string; node_count = number; vm_size = string; enable_auto_scaling = bool; min_count = number; max_count = number; os_disk_size_gb = number; os_disk_type = string; node_labels = map(string); scale_down_mode = string });
  default = { name = "default", node_count = 3, vm_size = "Standard_D4s_v3", enable_auto_scaling = true, min_count = 2, max_count = 5, os_disk_size_gb = 100, os_disk_type = "Managed", node_labels = {}, scale_down_mode = "Deallocate" }
}
variable "additional_node_pools" { type = list(any); default = [] }

# SQL variables
variable "enable_sql" { type = bool; default = true }
variable "sql_server_name" { type = string; default = "nebula-sql" }
variable "sql_admin_login" { type = string; default = "sqladmin" }
variable "sql_admin_password" { type = string; sensitive = true }
variable "databases" { type = list(any); default = [] }
variable "sql_firewall_rules" { type = list(any); default = [] }

# Redis variables
variable "enable_redis" { type = bool; default = true }
variable "redis_cache_name" { type = string; default = "nebula-redis" }
variable "redis_sku" { type = string; default = "Premium" }
variable "redis_capacity" { type = number; default = 1 }
variable "redis_family" { type = string; default = "P" }

# Storage variables
variable "storage_account_name" { type = string; default = "nebulastg" }
variable "storage_account_tier" { type = string; default = "Standard" }
variable "storage_replication_type" { type = string; default = "LRS" }
variable "storage_containers" { type = list(any); default = [] }

# Key Vault variables
variable "enable_keyvault" { type = bool; default = true }
variable "keyvault_name" { type = string; default = "nebula-kv" }
variable "azure_tenant_id" { type = string }
variable "keyvault_sku" { type = string; default = "standard" }

# Functions variables
variable "enable_functions" { type = bool; default = false }
variable "function_app_name" { type = string; default = "nebula-api" }
variable "function_app_plan_name" { type = string; default = "nebula-func-plan" }
variable "function_sku_name" { type = string; default = "Y1" }
