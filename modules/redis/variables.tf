# Redis Module - Variables

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "redis_cache_name" { type = string }
variable "sku" { type = string; default = "Premium" }
variable "family" { type = string; default = "P" }
variable "capacity" { type = number; default = 1 }
variable "redis_version" { type = string; default = "6" }
variable "enable_clustering" { type = bool; default = false }
variable "shard_count" { type = number; default = 3 }
variable "non_ssl_port_enabled" { type = bool; default = false }
variable "public_network_access_enabled" { type = bool; default = false }
variable "minimum_tls_version" { type = string; default = "1.2" }
variable "timeout" { type = number; default = 5 }
variable "memory" { type = string; default = null }
variable "rdb_backup_enabled" { type = bool; default = false }
variable "rdb_backup_frequency" { type = number; default = 60 }
variable "rdb_backup_max_snapshot_count" { type = number; default = 1 }
variable "rdb_storage_connection_string" { type = string; default = "" }
variable "aof_backup_enabled" { type = bool; default = false }
variable "aof_storage_connection_string" { type = string; default = "" }
variable "patch_schedule_day" { type = string; default = "Sunday" }
variable "patch_schedule_hour" { type = number; default = 22 }
variable "private_endpoint_subnet_id" { type = string; default = "" }
variable "enable_enterprise" { type = bool; default = false }
variable "enterprise_sku" { type = string; default = "Enterprise_E20" }
variable "firewall_rules" { type = list(object({ name = string; start_ip_address = string; end_ip_address = string })); default = [] }
variable "tags" { type = map(string); default = {} }
