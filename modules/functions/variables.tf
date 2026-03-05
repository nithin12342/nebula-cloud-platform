# Functions Module - Variables
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "function_app_name" { type = string }
variable "app_service_plan_name" { type = string }
variable "storage_account_name" { type = string }
variable "os_type" { type = string; default = "Linux" }
variable "sku_name" { type = string; default = "Y1" }
variable "worker_count" { type = number; default = 1 }
variable "storage_tier" { type = string; default = "Standard" }
variable "storage_replication_type" { type = string; default = "LRS" }
variable "https_only" { type = bool; default = true }
variable "enabled" { type = bool; default = true }
variable "client_affinity_enabled" { type = bool; default = false }
variable "use_linux_fx" { type = bool; default = false }
variable "python_version" { type = string; default = "3.11" }
variable "always_on" { type = bool; default = false }
variable "app_settings" { type = map(string); default = {} }
variable "tags" { type = map(string); default = {} }
