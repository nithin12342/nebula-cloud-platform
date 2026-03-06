#!/bin/bash
# Cost Report Script
# Generates daily cost reports for the Nebula Cloud Platform

set -e

echo "========================================"
echo "Nebula Cloud Platform - Cost Report"
echo "========================================"

# Configuration
SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-}"
TENANT_ID="${AZURE_TENANT_ID:-}"
RESOURCE_GROUPS="${RESOURCE_GROUPS:-nebula-prod-rg,nebula-staging-rg,nebula-dev-rg}"
REPORT_DATE="${REPORT_DATE:-$(date +%Y-%m-%d)}"
OUTPUT_DIR="${OUTPUT_DIR:-./cost-reports}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Function to get costs for a resource group
get_resource_group_cost() {
    local rg_name=$1
    local start_date=$2
    local end_date=$3
    
    az cost management query \
        --scope "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$rg_name" \
        --type ActualCost \
        --time-period "{\"start\":\"$start_date\",\"end\":\"$end_date\"}" \
        --dataset "{\"aggregation\":{\"totalCost\":{\"name\":\"Cost\",\"function\":\"Sum\"}},\"grouping\":[{\"name\":\"ResourceGroup\",\"type\":\"Dimension\"}]}" \
        --query "properties.rows[0][0]" \
        2>/dev/null || echo "0"
}

# Function to format currency
format_currency() {
    local amount=$1
    printf "%.2f" "$amount"
}

echo ""
echo "Generating cost report for: $REPORT_DATE"
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Groups: $RESOURCE_GROUPS"
echo ""

# Calculate date range (last 30 days)
END_DATE=$(date +%Y-%m-%d)
START_DATE=$(date -d "30 days ago" +%Y-%m-%d)

# Initialize totals
TOTAL_COST=0

# Generate report
REPORT_FILE="$OUTPUT_DIR/cost-report-$REPORT_DATE.txt"

echo "========================================" > "$REPORT_FILE"
echo "Nebula Cloud Platform - Cost Report" >> "$REPORT_FILE"
echo "Date: $REPORT_DATE" >> "$REPORT_FILE"
echo "Period: $START_DATE to $END_DATE" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Resource Group Costs:" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

# Loop through resource groups
IFS=',' read -ra RG_ARRAY <<< "$RESOURCE_GROUPS"
for rg in "${RG_ARRAY[@]}"; do
    rg=$(echo "$rg" | xargs)  # Trim whitespace
    
    echo "Processing: $rg"
    
    cost=$(get_resource_group_cost "$rg" "$START_DATE" "$END_DATE")
    cost_formatted=$(format_currency "$cost")
    
    echo "$rg: $$cost_formatted USD" >> "$REPORT_FILE"
    
    TOTAL_COST=$(echo "$TOTAL_COST + $cost" | bc)
done

echo "" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"
TOTAL_FORMATTED=$(format_currency "$TOTAL_COST")
echo "TOTAL: $TOTAL_FORMATTED USD" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Add recommendations
echo "Cost Optimization Recommendations:" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"
echo "1. Review auto-scaling settings for AKS node pools" >> "$REPORT_FILE"
echo "2. Consider using Reserved Instances for stable workloads" >> "$REPORT_FILE"
echo "3. Implement lifecycle policies for Storage blobs" >> "$REPORT_FILE"
echo "4. Review Redis cache sizing" >> "$REPORT_FILE"
echo "5. Enable cost alerts for budget thresholds" >> "$REPORT_FILE"

# Display report
echo ""
cat "$REPORT_FILE"

echo ""
echo "Report saved to: $REPORT_FILE"
echo "========================================"
