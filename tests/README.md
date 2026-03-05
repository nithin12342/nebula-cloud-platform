# Nebula Cloud Platform - Testing Guide

## Overview

This directory contains comprehensive tests for the Nebula Cloud Platform Terraform modules using [Terratest](https://terratest.gruntwork.io/).

## Prerequisites

- Go 1.21 or later
- Terraform 1.5.0 or later
- Azure subscription
- Azure CLI configured

## Test Structure

```
tests/
├── unit/
│   ├── vnet_test.go      # VNet module tests
│   ├── aks_test.go       # AKS module tests
│   ├── sql_test.go       # SQL module tests
│   └── redis_test.go    # Redis module tests
├── go.mod               # Go module dependencies
└── README.md            # This file
```

## Running Tests

### Run All Tests

```bash
cd tests
go test -v ./...
```

### Run Specific Module Tests

```bash
# VNet tests
go test -v ./unit -run TestVNet

# AKS tests
go test -v ./unit -run TestAKS

# SQL tests
go test -v ./unit -run TestSQL

# Redis tests
go test -v ./unit -run TestRedis
```

### Run Tests in Parallel

```bash
go test -v -parallel 4 ./...
```

### Run Tests with Coverage

```bash
go test -v -cover ./...
```

## Test Categories

### Unit Tests

| Test | Description |
|------|-------------|
| `TestVNetCreation` | Tests basic VNet creation |
| TestVNetMultipleSubnets | Tests VNet with multiple subnets |
| TestVNetOutputs | Tests VNet output values |
| TestVNetNSG | Tests VNet with Network Security Groups |
| TestAKSCreation | Tests AKS cluster creation |
| TestAKSAutoScaling | Tests AKS with auto-scaling |
| TestAKSOutputs | Tests AKS output values |
| TestAKSMultipleNodePools | Tests AKS with multiple node pools |
| TestAKSAzureAD | Tests AKS with Azure AD integration |
| TestSQLCreation | Tests SQL database creation |
| TestSQLMultipleDatabases | Tests SQL with multiple databases |
| TestSQLOutputs | Tests SQL output values |
| TestSQLFirewallRules | Tests SQL with firewall rules |
| TestSQLElasticPool | Tests SQL with elastic pools |
| TestSQLAudit | Tests SQL with auditing |
| TestRedisCreation | Tests Redis cache creation |
| TestRedisOutputs | Tests Redis output values |
| TestRedisClustering | Tests Redis with clustering |
| TestRedisFirewallRules | Tests Redis with firewall rules |
| TestRedisPersistence | Tests Redis with persistence |

## Environment Variables

Set the following environment variables before running tests:

```bash
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"
```

## Test Configuration

Tests use the following Azure regions by default:
- Primary: `eastus`
- Secondary: `eastus2`

## Cleanup

Tests automatically clean up resources using `defer terraform.Destroy()`. 

To manually clean up:

```bash
terraform destroy -auto-approve
```

## Best Practices

1. **Parallel Execution**: Run tests in parallel to reduce execution time
2. **Resource Naming**: Use unique names to avoid conflicts
3. **Cleanup**: Always defer cleanup to prevent resource leaks
4. **Assertions**: Use descriptive assertion messages
5. **Idempotency**: Tests should be idempotent (can run multiple times)

## Troubleshooting

### Test Failures

If tests fail, check:
1. Azure credentials are valid
2. Subscription has sufficient quotas
3. Required providers are installed

### Timeout Issues

If tests timeout, increase retry settings:
```go
terraformOptions := &terraform.Options{
    MaxRetries:         5,
    TimeBetweenRetries: 10,
}
```

## CI/CD Integration

Tests can be run in CI/CD pipelines. See `.github/workflows/terraform.yml` for GitHub Actions configuration.
