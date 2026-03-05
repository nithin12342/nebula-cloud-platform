# SQL Module - Variables

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure location"
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL server"
  type        = string
}

variable "admin_login" {
  description = "SQL server admin login"
  type        = string
}

variable "admin_password" {
  description = "SQL server admin password"
  type        = string
  sensitive   = true
}

variable "sql_version" {
  description = "SQL Server version"
  type        = string
  default     = "12.0"
}

variable "aad_admin_login" {
  description = "Azure AD admin login"
  type        = string
  default     = ""
}

variable "aad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = ""
}

variable "aad_tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = ""
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "databases" {
  description = "List of database configurations"
  type = list(object({
    name           = string
    sku_name       = string
    max_size_gb    = number
    collation      = string
    license_type   = optional(string)
    tde_enabled    = optional(bool)
  }))
  default = []
}

variable "elastic_pools" {
  description = "Elastic pool configurations"
  type = list(object({
    name         = string
    edition      = string
    dtu          = number
    db_dtu_min   = number
    db_dtu_max   = number
    storage_mb   = number
  }))
  default = []
}

variable "firewall_rules" {
  description = "Firewall rules"
  type = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

variable "vnet_rules" {
  description = "Virtual network rules"
  type = list(object({
    name      = string
    subnet_id = string
  }))
  default = []
}

variable "audit_enabled" {
  description = "Enable auditing"
  type        = bool
  default     = true
}

variable "audit_retention_days" {
  description = "Audit retention in days"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
