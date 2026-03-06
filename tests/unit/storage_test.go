package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestStorageCreation tests the Storage module can be created successfully
func TestStorageCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/storage",
		Vars: map[string]interface{}{
			"resource_group_name":  "test-rg",
			"location":             "eastus",
			"storage_account_name": "teststgacct",
			"account_tier":         "Standard",
			"replication_type":     "LRS",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Storage account should be created without errors")
}

// TestStorageWithContainers tests Storage account with blob containers
func TestStorageWithContainers(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/storage",
		Vars: map[string]interface{}{
			"resource_group_name":  "test-rg",
			"location":             "eastus",
			"storage_account_name": "teststgwithcontainers",
			"account_tier":         "Standard",
			"replication_type":     "LRS",
			"containers": []map[string]interface{}{
				{
					"name":        "blob-container",
					"access_type": "private",
				},
				{
					"name":        "public-container",
					"access_type": "blob",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Storage with containers should be created")
}

// TestStorageOutputs tests that Storage outputs are correctly returned
func TestStorageOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/storage",
		Vars: map[string]interface{}{
			"resource_group_name":  "test-rg",
			"location":             "eastus",
			"storage_account_name": "teststgoutputs",
			"account_tier":         "Standard",
			"replication_type":     "LRS",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	// Test outputs
	storageName := terraform.Output(t, terraformOptions, "storage_account_name")
	assert.NotEmpty(t, storageName, "Storage account name should not be empty")
}

// TestStorageNetworkRules tests Storage with VNet rules
func TestStorageNetworkRules(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/storage",
		Vars: map[string]interface{}{
			"resource_group_name":  "test-rg",
			"location":             "eastus",
			"storage_account_name": "teststgnetwork",
			"account_tier":         "Standard",
			"replication_type":     "LRS",
			"vnet_subnet_ids":      []string{"/subscriptions/xxx/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"},
			"ip_rules":             []string{"1.2.3.4"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Storage with network rules should be created")
}

// TestStorageValidation tests terraform validation
func TestStorageValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/storage",
		Vars: map[string]interface{}{
			"resource_group_name":  "test-rg",
			"location":             "eastus",
			"storage_account_name": "validatetest",
			"account_tier":         "Standard",
			"replication_type":     "LRS",
		},
	}

	err := terraform.InitAndApplyE(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	assert.NoError(t, err, "Terraform validation should pass")
}
