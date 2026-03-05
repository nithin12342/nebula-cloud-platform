# Virtual Network Module - Outputs

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the virtual network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "vnet_location" {
  description = "The location of the virtual network"
  value       = azurerm_virtual_network.vnet.location
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for subnet in azurerm_subnet.subnets : subnet.name => subnet.id }
}

output "subnet_names" {
  description = "List of subnet names"
  value       = [for subnet in azurerm_subnet.subnets : subnet.name]
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for nsg in azurerm_network_security_group.nsg : nsg.name => nsg.id }
}

output "route_table_ids" {
  description = "Map of route table names to IDs"
  value       = { for rt in azurerm_route_table.route_table : rt.name => rt.id }
}
