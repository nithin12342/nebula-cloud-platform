# Azure Cost Management Configuration
# Nebulla Cloud Platform - FinOps

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

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rg-nebula"
}

# Resource Group
resource "azurerm_resource_group" "cost_mgmt" {
  name     = var.resource_group_name
  location = "eastus"

  tags = {
    Environment = var.environment
    Project    = "nebula-cloud-platform"
  }
}

# Cost Analysis Export Storage Account
resource "azurerm_storage_account" "cost_export" {
  name                     = "stnebula${var.environment}cost"
  location                 = azurerm_resource_group.cost_mgmt.location
  resource_group_name      = azurerm_resource_group.cost_mgmt.name
  account_tier            = "Standard"
  account_replication_type = "LRS"
  account_kind            = "StorageV2"

  tags = {
    Environment = var.environment
    Project    = "nebula-cloud-platform"
  }
}

# Storage Container for Exports
resource "azurerm_storage_container" "cost_exports" {
  name                  = "cost-reports"
  storage_account_name = azurerm_storage_account.cost_export.name
  container_access_type = "private"
}

# Budget Alert - Monthly
resource "azurerm_consumption_budget_resource_group" "monthly_budget" {
  name                = "nebula-monthly-budget-${var.environment}"
  resource_group_id   = azurerm_resource_group.cost_mgmt.id
  amount              = 10000
  time_grain          = "Monthly"

  notification {
    operator = "GreaterThan"
    threshold = 80
    contact_emails = ["finance@dulux.tech", "cfo@dulux.tech"]
  }

  notification {
    operator = "GreaterThan"
    threshold = 100
    contact_emails = ["finance@dulux.tech"]
  }
}

# Budget Alert - Weekly
resource "azurerm_consumption_budget_resource_group" "weekly_budget" {
  name                = "nebula-weekly-budget-${var.environment}"
  resource_group_id   = azurerm_resource_group.cost_mgmt.id
  amount              = 2500
  time_grain          = "Weekly"

  notification {
    operator = "GreaterThan"
    threshold = 90
    contact_emails = ["finops@dulux.tech"]
  }
}

# Cost Alert - by Service
resource "azurerm_monitor_action_group" "cost_alerts" {
  name                = "nebula-cost-alerts-${var.environment}"
  resource_group_name = azurerm_resource_group.cost_mgmt.name
  short_name          = "cost"

  email_receiver {
    name          = "Finance Team"
    email_address = "finance@dulux.tech"
  }

  email_receiver {
    name          = "FinOps Team"
    email_address = "finops@dulux.tech"
  }

  webhook_receiver {
    name        = "CostWebhook"
    service_uri = "https://hooks.slack.com/services/XXX"
  }
}

# Cost Analysis View - Development
resource "azurerm_cost_management_view" "dev_costs" {
  name                = "dev-costs-view"
  resource_group_id   = azurerm_resource_group.cost_mgmt.id
  scope              = "/subscriptions/${var.subscription_id}"

  category         = "Cost"
  display_name    = "Development Costs"
  chart_type      = "StackedColumn"

  data_query {
    columns {
      name     = "Cost"
      type     = "Sum"
    }
    columns {
      name     = "ResourceGroup"
      type     = "GroupBy"
    }

    filter {
      dimension {
        name     = "ResourceGroup"
        operator = "In"
        values   = ["rg-nebula-dev"]
      }
    }

    filter {
      dimension {
        name     = "ServiceName"
        operator = "In"
        values   = ["Virtual Machines", "Storage", "SQL Database", "Kubernetes Service"]
      }
    }

    grouping {
      dimension {
        name = "ResourceGroup"
      }
    }

    time_grain     = "Monthly"
    time_frame     = "CurrentMonthToDate"
  }
}

# Cost Analysis View - Production
resource "azurerm_cost_management_view" "prod_costs" {
  name                = "prod-costs-view"
  resource_group_id   = azurerm_resource_group.cost_mgmt.id
  scope              = "/subscriptions/${var.subscription_id}"

  category         = "Cost"
  display_name    = "Production Costs"
  chart_type      = "StackedColumn"

  data_query {
    columns {
      name     = "Cost"
      type     = "Sum"
    }
    columns {
      name     = "ServiceName"
      type     = "GroupBy"
    }

    filter {
      dimension {
        name     = "ResourceGroup"
        operator = "In"
        values   = ["rg-nebula-prod"]
      }
    }

    grouping {
      dimension {
        name = "ServiceName"
      }
    }

    time_grain     = "Monthly"
    time_frame     = "CurrentMonthToDate"
  }
}

# Recommendations - Right-sizing
resource "azurerm_cost_management_report" "right_sizing" {
  name                = "nebula-right-sizing-report"
  subscription_id     = var.subscription_id
  collection_period {
    start = "2024-01-01"
    end   = "2024-12-31"
  }

  destination {
    container_name = azurerm_storage_container.cost_exports.name
    resource_id    = azurerm_storage_account.cost_export.id
    folder_name    = "right-sizing"
  }

  specification {
    dataset_format = "Csv"

    dataset_configuration {
      columns {
        name = "InstanceId"
      }
      columns {
        name = "ResourceGroup"
      }
      columns {
        name = "MeterCategory"
      }
      columns {
        name = "Cost"
      }
      columns {
        name = "RecommendedSKU"
      }
    }
  }
}

# Outputs
output "cost_storage_account" {
  value = azurerm_storage_account.cost_export.name
}

output "monthly_budget" {
  value = azurerm_consumption_budget_resource_group.monthly_budget.amount
}
