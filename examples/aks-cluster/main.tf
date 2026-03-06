# AKS Cluster Example
# This example creates a basic AKS cluster

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "aks-cluster-rg"
  location = "eastus"
}

module "vnet" {
  source = "../../modules/vnet"
  
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  vnet_name         = "aks-vnet"
  address_space     = ["10.1.0.0/16"]
  
  subnets = [
    {
      name           = "aks-subnet"
      address_prefix = "10.1.1.0/24"
      delegate_to    = "Microsoft.ContainerService/managedClusters"
    }
  ]
  
  tags = {
    Environment = "example"
    Project     = "Nebula Examples"
  }
}

module "aks" {
  source = "../../modules/aks"
  
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  cluster_name       = "example-aks"
  dns_prefix         = "example"
  kubernetes_version = "1.29"
  subnet_id          = module.vnet.subnet_ids["aks-subnet"]
  
  default_node_pool = {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    enable_auto_scaling = true
    min_count           = 2
    max_count           = 5
    os_disk_size_gb     = 100
    os_disk_type        = "Managed"
    node_labels         = {}
    scale_down_mode     = "Deallocate"
  }
  
  additional_node_pools = [
    {
      name                = "memory-optimized"
      node_count          = 2
      vm_size             = "Standard_E4s_v3"
      enable_auto_scaling = true
      min_count           = 1
      max_count           = 3
      os_disk_size_gb     = 100
      os_disk_type        = "Managed"
      os_type             = "Linux"
      node_labels         = { "workload" = "memory-intensive" }
      node_taints         = []
    }
  ]
  
  tags = {
    Environment = "example"
    Project     = "Nebula Examples"
  }
}

output "cluster_name" {
  value = module.aks.cluster_name
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

output "node_resource_group" {
  value = module.aks.node_resource_group
}
