package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestVNetCreation tests the VNet module can be created successfully
func TestVNetCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/vnet",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"vnet_name":           "test-vnet",
			"address_space":       []string{"10.0.0.0/16"},
			"subnets": []map[string]interface{}{
				{
					"name":           "test-subnet",
					"address_prefix": "10.0.1.0/24",
				},
			},
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "VNet should be created without errors")
}

// TestVNetMultipleSubnets tests VNet with multiple subnets
func TestVNetMultipleSubnets(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/vnet",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"vnet_name":           "multi-subnet-vnet",
			"address_space":       []string{"10.0.0.0/16"},
			"subnets": []map[string]interface{}{
				{
					"name":           "subnet1",
					"address_prefix": "10.0.1.0/24",
				},
				{
					"name":           "subnet2",
					"address_prefix": "10.0.2.0/24",
				},
				{
					"name":           "subnet3",
					"address_prefix": "10.0.3.0/24",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "VNet with multiple subnets should be created")
}

// TestVNetOutputs tests that VNet outputs are correctly returned
func TestVNetOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/vnet",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"vnet_name":           "output-test-vnet",
			"address_space":       []string{"10.0.0.0/16"},
			"subnets": []map[string]interface{}{
				{
					"name":           "test-subnet",
					"address_prefix": "10.0.1.0/24",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	// Test outputs
	vnetID := terraform.Output(t, terraformOptions, "vnet_id")
	vnetName := terraform.Output(t, terraformOptions, "vnet_name")

	assert.NotEmpty(t, vnetID, "VNet ID should not be empty")
	assert.Equal(t, "output-test-vnet", vnetName, "VNet name should match")
}

// TestVNetNSG tests VNet with Network Security Groups
func TestVNetNSG(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/vnet",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"vnet_name":           "nsg-test-vnet",
			"address_space":       []string{"10.0.0.0/16"},
			"subnets": []map[string]interface{}{
				{
					"name":           "test-subnet",
					"address_prefix": "10.0.1.0/24",
				},
			},
			"network_security_groups": []map[string]interface{}{
				{
					"name": "test-nsg",
					"rules": []map[string]interface{}{
						{
							"name":                       "allow-https",
							"priority":                   100,
							"direction":                  "Inbound",
							"access":                     "Allow",
							"protocol":                   "Tcp",
							"source_port_range":          "*",
							"destination_port_range":     "443",
							"source_address_prefix":      "*",
							"destination_address_prefix": "*",
						},
					},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "VNet with NSG should be created")
}

// TestVNetValidation tests terraform validation
func TestVNetValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/vnet",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"vnet_name":           "validation-test",
			"address_space":       []string{"10.0.0.0/16"},
			"subnets":             []map[string]interface{}{},
		},
	}

	err := terraform.InitAndApplyE(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	// Validation should succeed
	assert.NoError(t, err)
}
