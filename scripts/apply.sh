#!/bin/bash
# Terraform Apply Script

set -e

echo "========================================"
echo "Terraform Apply Script"
echo "========================================"

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed."; exit 1; }

# Get directory
TERRAFORM_DIR="${1:-.}"

echo "Applying Terraform in: $TERRAFORM_DIR"
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Get var-file
VAR_FILE="${2:-terraform.tfvars}"

# Run apply
echo ""
echo "Running terraform apply..."
echo "Using var-file: $VAR_FILE"
echo ""

if [ "$AUTO_APPROVE" = "true" ]; then
    terraform apply -var-file="$VAR_FILE" -auto-approve
else
    terraform apply -var-file="$VAR_FILE"
fi

echo ""
echo "========================================"
echo "Apply complete!"
echo "========================================"
