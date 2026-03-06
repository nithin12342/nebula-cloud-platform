# CI/CD Test Results Guide

## How to Run Tests via GitHub Actions

### Option 1: Automatic Tests (On Push)

Tests run automatically when you push to `main` or `develop` branch:

1. **Push to GitHub**:
   ```bash
   git push origin master
   ```

2. **View Results**:
   - Go to: https://github.com/nithin12342/nebula-cloud-platform/actions
   - Click on the latest workflow run
   - Check the **Validate**, **Security Scan**, and **Unit Tests** jobs

### Option 2: Manual Tests (workflow_dispatch)

Run tests manually with custom parameters:

1. **Go to**: https://github.com/nithin12342/nebula-cloud-platform/actions/workflows/terraform.yml

2. Click **"Run workflow"** button

3. Select:
   - **Test modules**: `vnet,aks,sql,redis,storage,keyvault,functions` or `all`
   - **Environment**: `staging` or `production`

4. Click **"Run workflow"**

### Option 3: Pull Request Tests

When you create a PR against `main`:
- `terraform validate` runs automatically
- `terraform plan` posts to PR comments
- Security scans (Checkov, tfsec) run automatically

---

## Understanding Test Results

### Job Statuses

| Status | Meaning |
|--------|---------|
| ✅ Success | All tests passed |
| ❌ Failed | Tests failed - check logs |
| ⏳ In Progress | Tests running |
| ⚠️ Skipped | Tests skipped (normal for plan/apply on non-main branches) |

### Jobs in Pipeline

1. **Validate** - Terraform syntax and config validation
2. **Security Scan** - Checkov & tfsec security scanning  
3. **Unit Tests** - Terratest integration tests (requires Azure credentials)
4. **Plan** - Terraform plan (PR only)
5. **Apply** - Terraform apply (main branch push only)

---

## Required Secrets

For tests to run, configure these GitHub Secrets:

| Secret | Description |
|--------|-------------|
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| `AZURE_CLIENT_ID` | Service Principal Client ID |
| `AZURE_CLIENT_SECRET` | Service Principal Client Secret |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |

### How to Configure Secrets

1. Go to: https://github.com/nithin12342/nebula-cloud-platform/settings/secrets/actions
2. Click **"New repository secret"**
3. Add each secret above

---

## Local Test Results

To run tests locally:

```bash
# Install prerequisites
# - Terraform 1.6.0+
# - Go 1.21+
# - Azure CLI

# Set environment variables
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="your-tenant-id"

# Run tests
cd tests
go test -v -cover ./...
```

---

## Test Coverage

| Module | Tests | Status |
|--------|-------|--------|
| VNet | 5 tests | ✅ |
| AKS | 10+ tests | ✅ |
| SQL | 5+ tests | ✅ |
| Redis | 5 tests | ✅ |
| Storage | 5 tests | ✅ |
| KeyVault | 5 tests | ✅ |
| Functions | 5 tests | ✅ |

**Total**: 40+ unit tests covering all Terraform modules
