#!/bin/bash
# Terraform Destroy Script

set -e

echo "========================================"
echo "Terraform Destroy Script"
echo "========================================"

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed."; exit 1; }

# Get directory
TERRAFORM_DIR="${1:-.}"

echo "Destroying Terraform resources in: $TERRAFORM_DIR"
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Get var-file
VAR_FILE="${2:-terraform.tfvars}"

# Confirmation prompt
echo ""
echo "WARNING: This will destroy all resources!"
echo "Using var-file: $VAR_FILE"
echo ""

if [ "$AUTO_APPROVE" = "true" ]; then
    echo "AUTO_APPROVE is set, proceeding with destroy..."
    terraform destroy -var-file="$VAR_FILE" -auto-approve
else
    read -p "Are you sure you want to destroy? (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        terraform destroy -var-file="$VAR_FILE"
    else
        echo "Destroy cancelled."
        exit 0
    fi
fi

echo ""
echo "========================================"
echo "Destroy complete!"
echo "========================================"
