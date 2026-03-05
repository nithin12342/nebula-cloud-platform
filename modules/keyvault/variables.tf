# Key Vault Module - Variables
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "keyvault_name" { type = string }
variable "tenant_id" { type = string }
variable "sku_name" { type = string; default = "standard" }
variable "soft_delete_retention_days" { type = number; default = 90 }
variable "purge_protection_enabled" { type = bool; default = false }
variable "enable_rbac_authorization" { type = bool; default = true }
variable "deletion_protection" { type = bool; default = true }
variable "network_default_action" { type = string; default = "Allow" }
variable "ip_rules" { type = list(string); default = [] }
variable "vnet_subnet_ids" { type = list(string); default = [] }
variable "service_principal_object_id" { type = string; default = "" }
variable "key_permissions" { type = list(string); default = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"] }
variable "secret_permissions" { type = list(string); default = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"] }
variable "cert_permissions" { type = list(string); default = ["Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"] }
variable "secrets" { type = list(object({ name = string; value = string; content_type = string; tags = map(string) })); default = [] }
variable "keys" { type = list(object({ name = string; key_type = string; key_size = number; key_opts = list(string); tags = map(string) })); default = [] }
variable "tags" { type = map(string); default = {} }
