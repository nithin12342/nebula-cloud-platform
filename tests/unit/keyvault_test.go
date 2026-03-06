package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestKeyVaultCreation tests the KeyVault module can be created successfully
func TestKeyVaultCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/keyvault",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"keyvault_name":       "testkeyvault",
			"tenant_id":           "00000000-0000-0000-0000-000000000000",
			"sku_name":            "standard",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "KeyVault should be created without errors")
}

// TestKeyVaultWithSecrets tests KeyVault with secrets
func TestKeyVaultWithSecrets(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/keyvault",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"keyvault_name":       "testkvwithsecrets",
			"tenant_id":           "00000000-0000-0000-0000-000000000000",
			"sku_name":            "standard",
			"secrets": []map[string]interface{}{
				{
					"name":         "db-password",
					"value":        "secretvalue123",
					"content_type": "string",
				},
				{
					"name":         "api-key",
					"value":        "apikey456",
					"content_type": "string",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "KeyVault with secrets should be created")
}

// TestKeyVaultOutputs tests that KeyVault outputs are correctly returned
func TestKeyVaultOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/keyvault",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"keyvault_name":       "testkvoutputs",
			"tenant_id":           "00000000-0000-0000-0000-000000000000",
			"sku_name":            "standard",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	// Test outputs
	kvURI := terraform.Output(t, terraformOptions, "keyvault_uri")
	assert.NotEmpty(t, kvURI, "KeyVault URI should not be empty")
}

// TestKeyVaultWithNetworkRules tests KeyVault with network rules
func TestKeyVaultWithNetworkRules(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/keyvault",
		Vars: map[string]interface{}{
			"resource_group_name":    "test-rg",
			"location":               "eastus",
			"keyvault_name":          "testkvnetwork",
			"tenant_id":              "00000000-0000-0000-0000-000000000000",
			"sku_name":               "standard",
			"network_default_action": "Deny",
			"ip_rules":               []string{"1.2.3.4"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "KeyVault with network rules should be created")
}

// TestKeyVaultValidation tests terraform validation
func TestKeyVaultValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/keyvault",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"keyvault_name":       "validatetest",
			"tenant_id":           "00000000-0000-0000-0000-000000000000",
			"sku_name":            "standard",
		},
	}

	err := terraform.InitAndApplyE(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	assert.NoError(t, err, "Terraform validation should pass")
}
