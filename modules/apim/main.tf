# Azure API Management Configuration
# Nebula Cloud Platform - API Gateway

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Resource Group
resource "azurerm_resource_group" "apim_rg" {
  name     = "rg-nebula-apim-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project    = "nebula-cloud-platform"
  }
}

# Virtual Network for APIM
resource "azurerm_virtual_network" "apim_vnet" {
  name                = "vnet-nebula-apim-${var.environment}"
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name  = azurerm_resource_group.apim_rg.name
  address_space       = ["10.1.0.0/24"]

  tags = {
    Environment = var.environment
    Project    = "nebula-cloud-platform"
  }
}

# Subnet for APIM
resource "azurerm_subnet" "apim_subnet" {
  name                 = "snet-apim"
  resource_group_name  = azurerm_resource_group.apim_rg.name
  virtual_network_name = azurerm_virtual_network.apim_vnet.name
  address_prefixes    = ["10.1.0.0/26"]

  delegation {
    name = "Microsoft.ApiManagement/service"
    service_delegation {
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      name    = "Microsoft.ApiManagement/service"
    }
  }
}

# Public IP for APIM
resource "azurerm_public_ip" "apim_ip" {
  name                = "pip-nebula-apim-${var.environment}"
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name  = azurerm_resource_group.apim_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project    = "nebula-cloud-platform"
  }
}

# API Management Service
resource "azurerm_api_management" "apim" {
  name                = "apim-nebula-${var.environment}"
  location            = azurerm_resource_group.apim_rg.location
  resource_group_name  = azurerm_resource_group.apim_rg.name
  publisher_name      = "Dulux Tech"
  publisher_email     = "api-support@dulux.tech"
  sku_name            = "Developer_1"
  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim_subnet.id
  }

  tags = {
    Environment = var.environment
    Project    = "nebula-cloud-platform"
  }
}

# API Management Custom Domain
resource "azurerm_api_management_custom_domain" "apim_domain" {
  api_management_id = azurerm_api_management.apim.id

  proxy {
    default_ssl_binding = true
    host_name          = "api.nebula.dulux.tech"
    certificate {
      password = ""
      pfx      = filebase64("${path.module}/certs/api-nebula.pfx")
    }
  }

  developer_portal {
    host_name    = "portal.nebula.dulux.tech"
    certificate {
      password = ""
      pfx      = filebase64("${path.module}/certs/portal-nebula.pfx")
    }
  }

  management {
    host_name = "management.nebula.dulux.tech"
  }
}

# API - Orders Service
resource "azurerm_api_management_api" "orders_api" {
  name                = "orders-api"
  resource_group_name  = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "Orders API"
  description         = "Order management service API"
  revision           = "1"
  service_url        = "http://order-service:8080"
  protocols          = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/apis/orders-api.yaml")
  }

  subscription_required = true
}

# API - Products Service
resource "azurerm_api_management_api" "products_api" {
  name                = "products-api"
  resource_group_name  = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "Products API"
  description         = "Product catalog service API"
  revision           = "1"
  service_url        = "http://product-service:8080"
  protocols          = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/apis/products-api.yaml")
  }

  subscription_required = true
}

# API - Users Service
resource "azurerm_api_management_api" "users_api" {
  name                = "users-api"
  resource_group_name  = azurerm_resource_group.apim_rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "Users API"
  description         = "User management service API"
  revision           = "1"
  service_url        = "http://user-service:8080"
  protocols          = ["https"]

  import {
    content_format = "openapi"
    content_value  = file("${path.module}/apis/users-api.yaml")
  }

  subscription_required = true
}

# Rate Limiting Policy
resource "azurerm_api_management_policy" "rate_limit" {
  api_management_id = azurerm_api_management.apim.id
  api_name          = azurerm_api_management_api.orders_api.name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <rate-limit-by-key calls="100" renewal-period="60" counter-key="@(context.Request.IpAddress)" />
    <quota-by-key calls="10000" renewal-period="86400" counter-key="@(context.Subscription.Id)" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
</policies>
XML
}

# OAuth2 Configuration
resource "azurerm_api_management_authorization_server" "oauth2" {
  name                         = "nebula-oauth2"
  api_management_name          = azurerm_api_management.apim.name
  resource_group_name          = azurerm_resource_group.apim_rg.name
  display_name                = "Nebula OAuth2"
  authorization_endpoint      = "https://auth.nebula.dulux.tech/oauth2/authorize"
  token_endpoint             = "https://auth.nebula.dulux.tech/oauth2/token"
  grant_types                = ["authorization_code", "client_credentials"]
  client_authentication_method = ["Body"]

  client_id            = "apim-nebula"
  client_secret        = "@@SECRET@@"
  bearer_token_sending = "authorization_header"
}

# API Product - Premium
resource "azurerm_api_management_product" "premium" {
  product_id            = "premium"
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.apim_rg.name
  display_name         = "Premium API"
  description          = "Premium tier API access"
  subscription_required = true
  approval_required    = true

  APIs {
    api_id = azurerm_api_management_api.orders_api.id
  }
}

# Outputs
output "apim_gateway_url" {
  value = azurerm_api_management.apim.gateway_url
}

output "apim_portal_url" {
  value = azurerm_api_management.apim.portal_url
}
