# Basic VNet Example
# This example creates a simple virtual network with subnets

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "basic-vnet-rg"
  location = "eastus"
}

module "vnet" {
  source = "../../modules/vnet"
  
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  vnet_name         = "basic-vnet"
  address_space     = ["10.0.0.0/24"]
  
  subnets = [
    {
      name           = "web-subnet"
      address_prefix = "10.0.1.0/24"
      delegate_to    = ""
    },
    {
      name           = "data-subnet"
      address_prefix = "10.0.2.0/24"
      delegate_to    = ""
    }
  ]
  
  tags = {
    Environment = "example"
    Project     = "Nebula Examples"
  }
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}
