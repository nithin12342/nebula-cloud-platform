# Virtual Network Module - Variables

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure location"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "List of subnet configurations"
  type = list(object({
    name                  = string
    address_prefix        = string
    address_prefixes      = optional(list(string))
    service_endpoints     = optional(list(string))
    delegate_to           = optional(string)
    private_endpoint_policies = optional(bool)
  }))
  default = []
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
  default     = []
}

variable "network_security_groups" {
  description = "Network security group configurations"
  type = list(object({
    name = string
    rules = list(object({
      name                       = string
      priority                   = number
      direction                   = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  default = []
}

variable "route_tables" {
  description = "Route table configurations"
  type = list(object({
    name                   = string
    disable_bgp_propagation = optional(bool)
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), [])
  }))
  default = []
}

variable "subnet_route_table_associations" {
  description = "Associations between subnets and route tables"
  type = list(object({
    subnet_name      = string
    route_table_name = string
  }))
  default = []
}

variable "subnet_nsg_associations" {
  description = "List of subnet names to associate with NSGs"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
