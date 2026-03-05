# Storage Module - Variables
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "storage_account_name" { type = string }
variable "account_tier" { type = string; default = "Standard" }
variable "replication_type" { type = string; default = "LRS" }
variable "account_kind" { type = string; default = "StorageV2" }
variable "enable_https_only" { type = bool; default = true }
variable "allow_public_blob" { type = bool; default = false }
variable "enable_hns" { type = bool; default = false }
variable "enable_nfsv3" { type = bool; default = false }
variable "containers" { type = list(object({ name = string; access_type = string })); default = [] }
variable "queues" { type = list(string); default = [] }
variable "tables" { type = list(string); default = [] }
variable "vnet_subnet_ids" { type = list(string); default = [] }
variable "ip_rules" { type = list(string); default = [] }
variable "tags" { type = map(string); default = {} }
