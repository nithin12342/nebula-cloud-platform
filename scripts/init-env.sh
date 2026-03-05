#!/bin/bash
# Initialize Terraform environment

set -e

echo "Initializing Terraform environment..."

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed."; exit 1; }
command -v az >/dev/null 2>&1 || { echo "Azure CLI is required but not installed."; exit 1; }

# Login to Azure
echo "Logging into Azure..."
az login --tenant ${AZURE_TENANT_ID}

# Set subscription
az account set --subscription ${AZURE_SUBSCRIPTION_ID}

# Initialize Terraform
echo "Running Terraform init..."
terraform init

echo "Environment initialized successfully!"
