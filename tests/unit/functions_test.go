package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestFunctionsCreation tests the Functions module can be created successfully
func TestFunctionsCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/functions",
		Vars: map[string]interface{}{
			"resource_group_name":   "test-rg",
			"location":              "eastus",
			"function_app_name":     "testfuncapp",
			"app_service_plan_name": "testfuncplan",
			"storage_account_name":  "teststgacct",
			"sku_name":              "Y1",
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Function app should be created without errors")
}

// TestFunctionsWithAppSettings tests Function app with app settings
func TestFunctionsWithAppSettings(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/functions",
		Vars: map[string]interface{}{
			"resource_group_name":   "test-rg",
			"location":              "eastus",
			"function_app_name":     "testfuncsettings",
			"app_service_plan_name": "testfuncplan2",
			"storage_account_name":  "teststgacct2",
			"sku_name":              "Y1",
			"app_settings": map[string]interface{}{
				"WEBSITE_TIME_ZONE":           "Pacific Standard Time",
				"FUNCTIONS_EXTENSION_VERSION": "~4",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Function app with settings should be created")
}

// TestFunctionsOutputs tests that Functions outputs are correctly returned
func TestFunctionsOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/functions",
		Vars: map[string]interface{}{
			"resource_group_name":   "test-rg",
			"location":              "eastus",
			"function_app_name":     "testfuncoutputs",
			"app_service_plan_name": "testfuncplan3",
			"storage_account_name":  "teststgacct3",
			"sku_name":              "Y1",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	// Test outputs
	hostname := terraform.Output(t, terraformOptions, "function_app_default_hostname")
	assert.NotEmpty(t, hostname, "Function app hostname should not be empty")
}

// TestFunctionsPremium tests Premium tier Function app
func TestFunctionsPremium(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/functions",
		Vars: map[string]interface{}{
			"resource_group_name":   "test-rg",
			"location":              "eastus",
			"function_app_name":     "testfuncpremium",
			"app_service_plan_name": "testfuncplanprem",
			"storage_account_name":  "teststgacctprem",
			"sku_name":              "EP1",
			"kind":                  "functionapp,linux",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Premium Function app should be created")
}

// TestFunctionsValidation tests terraform validation
func TestFunctionsValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/functions",
		Vars: map[string]interface{}{
			"resource_group_name":   "test-rg",
			"location":              "eastus",
			"function_app_name":     "validatetestfunc",
			"app_service_plan_name": "validatetestplan",
			"storage_account_name":  "validateteststg",
			"sku_name":              "Y1",
		},
	}

	err := terraform.InitAndApplyE(t, terraformOptions)
	defer terraform.Destroy(t, terraformOptions)

	assert.NoError(t, err, "Terraform validation should pass")
}
