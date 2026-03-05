# Azure Kubernetes Service (AKS) Module

This module creates an AKS cluster with node pools, add-ons, and ingress configurations.

## Usage

```hcl
module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  cluster_name       = "production-aks"
  
  vnet_id            = module.vnet.vnet_id
  subnet_id          = module.vnet.subnet_ids["aks-subnet"]
  
  kubernetes_version = "1.29"
  
  default_node_pool = {
    name                = "default"
    node_count          = 3
    vm_size            = "Standard_D4s_v3"
    min_count          = 2
    max_count          = 5
  }
  
  additional_node_pools = [
    {
      name                = "memory-optimized"
      node_count          = 2
      vm_size            = "Standard_E4s_v3"
      min_count          = 1
      max_count          = 4
    }
  ]
}
```

## Resources Created

| Type | Description |
|------|-------------|
| azurerm_kubernetes_cluster | Main AKS cluster |
| azurerm_kubernetes_cluster_node_pool | Additional node pools |
| azurerm_log_analytics_workspace | Log analytics for AKS |
| azurerm_kubernetes_cluster_trusted_access | Trusted access for Azure services |

## Features

- Azure AD integration
- Azure Key Vault secrets provider
- Network policy (Azure Network Policy)
- Azure Monitor for containers
- AAD Pod identity
- Ingress with Application Gateway
