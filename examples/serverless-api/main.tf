# Serverless API Example
# This example creates Azure Functions with API Management

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
  name     = "serverless-api-rg"
  location = "eastus"
}

# Storage Account for Functions
resource "azurerm_storage_account" "func_storage" {
  name                     = "serverlessapistg"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
}

# App Service Plan (Consumption)
resource "azurerm_app_service_plan" "func_plan" {
  name                = "serverless-api-plan"
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

# Function App
resource "azurerm_function_app" "api" {
  name                = "serverless-api"
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  app_service_plan_id = azurerm_app_service_plan.func_plan.id
  storage_account_name = azurerm_storage_account.func_storage.name
  
  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "WEBSITE_TIME_ZONE"          = "UTC"
  }
  
  site_config {
    cors {
      allowed_origins = ["https://portal.azure.com"]
      enabled         = true
    }
  }
}

# API Management
resource "azurerm_api_management" "api_mgmt" {
  name                = "serverless-api-mgmt"
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  publisher_name      = "Dulux Tech"
  publisher_email    = "platform@duluxtech.com"
  
  sku_name = "Developer_1"
}

# API Management API
resource "azurerm_api_management_api" "func_api" {
  name                = "serverless-func-api"
  resource_group_name = azurerm_resource_group.example.name
  api_management_name = azurerm_api_management.api_mgmt.name
  revision           = "1"
  display_name       = "Serverless Function API"
  path               = "api"
  protocols          = ["https"]
  
  import {
    content_format = "openapi"
    content_value  = <<EOF
openapi: 3.0.0
info:
  title: Serverless API
  version: 1.0.0
paths:
  /hello:
    get:
      summary: Hello World
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                  timestamp:
                    type: string
EOF
  }
}

output "function_app_url" {
  value = azurerm_function_app.api.default_hostname
}

output "api_management_url" {
  value = azurerm_api_management.api_mgmt.gateway_url
}
