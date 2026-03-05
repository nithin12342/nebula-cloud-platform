# Azure Kubernetes Service (AKS) Module

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

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.cluster_name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days  = var.log_analytics_retention
  
  tags = var.tags
}

resource "azurerm_log_analytics_solution" "aks" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_name        = azurerm_log_analytics_workspace.aks.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier           = var.sku_tier
  
  default_node_pool {
    name            = var.default_node_pool.name
    node_count      = var.default_node_pool.node_count
    vm_size         = var.default_node_pool.vm_size
    availability_zones = var.availability_zones
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count       = var.default_node_pool.min_count
    max_count       = var.default_node_pool.max_count
    vnet_subnet_id  = var.subnet_id
    
    # Node labels and taints
    node_labels = var.default_node_pool.node_labels
    
    # OS disk
    os_disk_size_gb         = var.default_node_pool.os_disk_size_gb
    os_disk_type           = var.default_node_pool.os_disk_type
    os_cache_size_gb       = var.default_node_pool.os_cache_size_gb
    
    # Networking
    outbound_type          = var.outbound_type
    load_balancer_sku      = "standard"
    
    # Autoscaling
    scale_down_mode        = var.default_node_pool.scale_down_mode
    
    # Tags
    tags = var.tags
  }
  
  # Azure AD Integration
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = var.azure_rbac_enabled
    admin_group_object_ids = var.admin_group_object_ids
  }
  
  # Network Profile
  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    load_balancer_sku  = "standard"
    outbound_type      = var.outbound_type
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    docker_bridge_cidr = var.docker_bridge_cidr
  }
  
  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled = var.secret_rotation_enabled
  }
  
  # Oms Agent
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }
  
  # Azure Policy
  azure_policy_enabled = var.azure_policy_enabled
  
  # HTTP Application Routing
  http_application_routing_enabled = var.http_application_routing_enabled
  
  # Identity
  identity {
    type = "SystemAssigned"
  }
  
  # Maintenance Window
  maintenance_window {
    allowed {
      day   = var.maintenance_window_day
      hours = var.maintenance_window_hours
    }
  }
  
  # RBAC
  role_based_access_control_enabled = true
  
  # Tags
  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "additional_pools" {
  for_each = { for pool in var.additional_node_pools : pool.name => pool }
  
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count           = each.value.node_count
  vm_size             = each.value.vm_size
  availability_zones = var.availability_zones
  enable_auto_scaling = each.value.enable_auto_scaling
  min_count          = each.value.min_count
  max_count          = each.value.max_count
  vnet_subnet_id     = var.subnet_id
  
  # OS settings
  os_disk_size_gb   = each.value.os_disk_size_gb
  os_disk_type      = each.value.os_disk_type
  os_type          = each.value.os_type
  
  # Node labels and taints
  node_labels = each.value.node_labels
  node_taints = each.value.node_taints
  
  # Tags
  tags = var.tags
}

# Kubernetes Provider for manifest deployments
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
}
