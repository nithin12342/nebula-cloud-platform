# Multi-Region Deployment Example
# This example creates a multi-region deployment with Traffic Manager

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
  alias = "primary"
  
  subscription_id = "primary-subscription-id"
}

provider "azurerm" {
  features {}
  alias = "secondary"
  
  subscription_id = "secondary-subscription-id"
}

# Primary Region Resources
module "primary_vnet" {
  source = "../../modules/vnet"
  
  providers = {
    azurerm = azurerm.primary
  }
  
  resource_group_name = "multi-region-primary-rg"
  location           = "eastus"
  vnet_name         = "primary-vnet"
  address_space     = ["10.1.0.0/16"]
  
  subnets = [
    {
      name           = "web-subnet"
      address_prefix = "10.1.1.0/24"
      delegate_to    = ""
    }
  ]
  
  tags = {
    Region = "primary"
    Environment = "production"
  }
}

module "primary_aks" {
  source = "../../modules/aks"
  
  providers = {
    azurerm = azurerm.primary
  }
  
  resource_group_name = "multi-region-primary-rg"
  location           = "eastus"
  cluster_name       = "primary-aks"
  dns_prefix        = "primary"
  kubernetes_version = "1.29"
  subnet_id         = module.primary_vnet.subnet_ids["web-subnet"]
  
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
  
  tags = {
    Region = "primary"
    Environment = "production"
  }
}

# Secondary Region Resources
module "secondary_vnet" {
  source = "../../modules/vnet"
  
  providers = {
    azurerm = azurerm.secondary
  }
  
  resource_group_name = "multi-region-secondary-rg"
  location           = "westus2"
  vnet_name         = "secondary-vnet"
  address_space     = ["10.2.0.0/16"]
  
  subnets = [
    {
      name           = "web-subnet"
      address_prefix = "10.2.1.0/24"
      delegate_to    = ""
    }
  ]
  
  tags = {
    Region = "secondary"
    Environment = "production"
  }
}

module "secondary_aks" {
  source = "../../modules/aks"
  
  providers = {
    azurerm = azurerm.secondary
  }
  
  resource_group_name = "multi-region-secondary-rg"
  location           = "westus2"
  cluster_name       = "secondary-aks"
  dns_prefix        = "secondary"
  kubernetes_version = "1.29"
  subnet_id         = module.secondary_vnet.subnet_ids["web-subnet"]
  
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
  
  tags = {
    Region = "secondary"
    Environment = "production"
  }
}

# Traffic Manager Profile
resource "azurerm_traffic_manager_profile" "main" {
  name                   = "multi-region-tm"
  resource_group_name    = "multi-region-primary-rg"
  location              = "global"
  
  traffic_routing_method = "Priority"
  
  dns_config {
    relative_name = "multi-region-app"
    ttl           = 30
  }
  
  monitor_config {
    protocol = "https"
    port    = 443
    path    = "/healthz"
    interval_in_seconds = 30
    timeout_seconds    = 10
    tolerated_failures  = 3
  }
}

# Traffic Manager Endpoints
resource "azurerm_traffic_manager_endpoint" "primary" {
  name                = "primary"
  resource_group_name = "multi-region-primary-rg"
  profile_name       = azurerm_traffic_manager_profile.main.name
  type               = "azureEndpoints"
  target_resource_id = module.primary_aks.cluster_id
  priority           = 1
  enabled            = true
}

resource "azurerm_traffic_manager_endpoint" "secondary" {
  name                = "secondary"
  resource_group_name = "multi-region-secondary-rg"
  profile_name       = azurerm_traffic_manager_profile.main.name
  type               = "azureEndpoints"
  target_resource_id = module.secondary_aks.cluster_id
  priority           = 2
  enabled            = true
}

output "traffic_manager_fqdn" {
  value = azurerm_traffic_manager_profile.main.fqdn
}

output "primary_aks_fqdn" {
  value = module.primary_aks.cluster_fqdn
}

output "secondary_aks_fqdn" {
  value = module.secondary_aks.cluster_fqdn
}
