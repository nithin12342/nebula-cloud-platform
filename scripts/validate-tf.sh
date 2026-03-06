#!/bin/bash
# Validate Terraform Configuration

set -e

echo "========================================"
echo "Terraform Validation Script"
echo "========================================"

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "Terraform is required but not installed."; exit 1; }

# Get directory
TERRAFORM_DIR="${1:-.}"

echo "Validating Terraform in: $TERRAFORM_DIR"
cd "$TERRAFORM_DIR"

# Format check
echo ""
echo "Running terraform fmt..."
terraform fmt -check -recursive -diff || true

# Validate
echo ""
echo "Running terraform validate..."
terraform validate

# Init if needed
echo ""
echo "Checking terraform init..."
terraform init -backend=false

# Run tflint if available
if command -v tflint >/dev/null 2>&1; then
    echo ""
    echo "Running TFLint..."
    tflint --init
    tflint
fi

# Run checkov if available
if command -v checkov >/dev/null 2>&1; then
    echo ""
    echo "Running Checkov security scan..."
    checkov -d . --framework terraform
fi

echo ""
echo "========================================"
echo "Validation complete!"
echo "========================================"
