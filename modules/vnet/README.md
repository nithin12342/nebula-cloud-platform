# Virtual Network Module

This module creates a virtual network with subnets for Azure.

## Usage

```hcl
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  vnet_name          = "main-vnet"
  address_space      = ["10.0.0.0/16"]
  
  subnets = [
    {
      name           = "aks-subnet"
      address_prefix = "10.0.1.0/24"
    },
    {
      name           = "app-subnet"
      address_prefix = "10.0.2.0/24"
    }
  ]
}
```

## Resources

| Type | Description |
|------|-------------|
| azurerm_virtual_network | Virtual network resource |
| azurerm_subnet | Subnet resources |
| azurerm_network_security_group | NSG for subnets |
| azurerm_route_table | Route table for subnets |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| resource_group_name | Resource group name | string | - |
| location | Azure region | string | - |
| vnet_name | Virtual network name | string | - |
| address_space | VNet address space | list(string) | - |
| subnets | List of subnet configurations | list(object) | [] |
| tags | Resource tags | map(string) | {} |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | Virtual network ID |
| vnet_name | Virtual network name |
| vnet_address_space | Virtual network address space |
| subnet_ids | Map of subnet names to IDs |
