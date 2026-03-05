# AKS Module - Variables

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure location"
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "The DNS prefix for the cluster"
  type        = string
  default     = "nebula"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "sku_tier" {
  description = "AKS tier (Free or Standard)"
  type        = string
  default     = "Standard"
}

variable "vnet_id" {
  description = "The ID of the virtual network"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "The ID of the subnet for AKS nodes"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for nodes"
  type        = list(number)
  default     = [1, 2, 3]
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                = string
    node_count          = number
    vm_size            = string
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    os_disk_size_gb    = number
    os_disk_type       = string
    node_labels        = map(string)
    scale_down_mode    = string
  })
  default = {
    name                = "default"
    node_count          = 3
    vm_size            = "Standard_D4s_v3"
    enable_auto_scaling = true
    min_count          = 2
    max_count          = 5
    os_disk_size_gb    = 100
    os_disk_type       = "Managed"
    node_labels        = {}
    scale_down_mode    = "Deallocate"
  }
}

variable "additional_node_pools" {
  description = "Additional node pool configurations"
  type = list(object({
    name                = string
    node_count          = number
    vm_size            = string
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    os_disk_size_gb    = number
    os_disk_type       = string
    os_type           = string
    node_labels        = map(string)
    node_taints        = list(string)
  }))
  default = []
}

variable "network_plugin" {
  description = "Network plugin (azure, kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy (calico, azure)"
  type        = string
  default     = "azure"
}

variable "outbound_type" {
  description = "Outbound type (loadBalancer, userDefinedRouting)"
  type        = string
  default     = "loadBalancer"
}

variable "service_cidr" {
  description = "Service CIDR for Kubernetes services"
  type        = string
  default     = "10.96.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP"
  type        = string
  default     = "10.96.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR"
  type        = string
  default     = "172.17.0.1/16"
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC"
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "Azure AD group object IDs for cluster admin"
  type        = list(string)
  default     = []
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy"
  type        = bool
  default     = true
}

variable "http_application_routing_enabled" {
  description = "Enable HTTP application routing"
  type        = bool
  default     = false
}

variable "secret_rotation_enabled" {
  description = "Enable Key Vault secret rotation"
  type        = bool
  default     = true
}

variable "log_analytics_sku" {
  description = "Log Analytics SKU"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention" {
  description = "Log Analytics retention in days"
  type        = number
  default     = 30
}

variable "maintenance_window_day" {
  description = "Maintenance window day (0-6, 0=Sunday)"
  type        = number
  default     = 0
}

variable "maintenance_window_hours" {
  description = "Maintenance window hours"
  type        = list(number)
  default     = [22, 23]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
