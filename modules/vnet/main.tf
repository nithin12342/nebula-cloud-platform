# Virtual Network Module
# Creates VNet with subnets, NSGs, and route tables

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
  
  dns_servers = var.dns_servers
}

resource "azurerm_subnet" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }
  
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes != null ? each.value.address_prefixes : [each.value.address_prefix]
  
  # Service endpoints for Azure services
  service_endpoints = each.value.service_endpoints != null ? each.value.service_endpoints : ["Microsoft.Storage", "Microsoft.Sql", "Microsoft.KeyVault"]
  
  # Delegate for AKS
  delegation = each.value.delegate_to != null ? [{
    name = each.value.name
    service_delegation {
      name    = each.value.delegate_to
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }] : []
  
  # Private endpoint network policies
  private_endpoint_network_policies_enabled = each.value.private_endpoint_policies != null ? each.value.private_endpoint_policies : true
  
  lifecycle {
    ignore_changes = [address_prefixes]
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each = { for nsg in var.network_security_groups : nsg.name => nsg }
  
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = { for rule in flatten([for nsg_name, nsg in var.network_security_groups : [for rule in nsg.rules : merge(rule, {nsg_name = nsg_name})]]) : "${each.value.nsg_name}-${each.value.name}" => each.value }
  
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range          = each.value.source_port_range
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = each.value.destination_address_prefix
  network_security_group_name = azurerm_network_security_group.nsg[each.value.nsg_name].name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_route_table" "route_table" {
  for_each = { for rt in var.route_tables : rt.name => rt }
  
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  
  disable_bgp_route_propagation = each.value.disable_bgp_propagation
  
  lifecycle {
    ignore_changes = [route]
  }
}

resource "azurerm_subnet_route_table_association" "subnet_routes" {
  for_each = { for assoc in var.subnet_route_table_associations : "${assoc.subnet_name}-${assoc.route_table_name}" => assoc }
  
  subnet_id      = azurerm_subnet.subnets[each.value.subnet_name].id
  route_table_id = azurerm_route_table.route_table[each.value.route_table_name].id
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  for_each = { for assoc in var.subnet_nsg_associations : assoc.subnet_name => assoc }
  
  subnet_id                 = azurerm_subnet.subnets[each.value].id
  network_security_group_id = azurerm_network_security_group.nsg[var.network_security_groups[0].name].id
}
