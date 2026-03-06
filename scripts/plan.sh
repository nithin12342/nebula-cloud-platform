#!/bin/bash
# Terraform Plan Script

set -e

echo "========================================"
echo "Terraform Plan Script"
echo "========================================"

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed."; exit 1; }

# Get directory
TERRAFORM_DIR="${1:-.}"

echo "Planning Terraform in: $TERRAFORM_DIR"
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Get plan file name
PLAN_FILE="tfplan-$(date +%Y%m%d-%H%M%S)"

# Run plan
echo ""
echo "Running terraform plan..."
terraform plan -out="$PLAN_FILE" -var-file="terraform.tfvars"

echo ""
echo "Plan saved to: $PLAN_FILE"
echo ""
echo "To view the plan:"
echo "  terraform show $PLAN_FILE"
echo ""
echo "========================================"
echo "Plan complete!"
echo "========================================"
