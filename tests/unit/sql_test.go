package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestSQLCreation tests the SQL database can be created successfully
func TestSQLCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/sql",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"sql_server_name":     "test-sql",
			"admin_login":         "sqladmin",
			"admin_password":      "TestPassword123!",
			"databases": []map[string]interface{}{
				{
					"name":        "testdb",
					"sku_name":    "S0",
					"max_size_gb": 10,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
					"tde_enabled": true,
				},
			},
			"public_network_access_enabled": false,
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "SQL database should be created without errors")
}

// TestSQLMultipleDatabases tests SQL with multiple databases
func TestSQLMultipleDatabases(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/sql",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"sql_server_name":     "multi-db-sql",
			"admin_login":         "sqladmin",
			"admin_password":      "TestPassword123!",
			"databases": []map[string]interface{}{
				{
					"name":        "appdb",
					"sku_name":    "S1",
					"max_size_gb": 20,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
				},
				{
					"name":        "auditdb",
					"sku_name":    "S0",
					"max_size_gb": 10,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "SQL with multiple databases should be created")
}

// TestSQLOutputs tests that SQL outputs are correctly returned
func TestSQLOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/sql",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"sql_server_name":     "output-sql",
			"admin_login":         "sqladmin",
			"admin_password":      "TestPassword123!",
			"databases": []map[string]interface{}{
				{
					"name":        "testdb",
					"sku_name":    "S0",
					"max_size_gb": 10,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	// Test outputs
	serverFQDN := terraform.Output(t, terraformOptions, "sql_server_fqdn")
	serverName := terraform.Output(t, terraformOptions, "sql_server_name")

	assert.NotEmpty(t, serverFQDN, "Server FQDN should not be empty")
	assert.Equal(t, "output-sql", serverName, "Server name should match")
}

// TestSQLFirewallRules tests SQL with firewall rules
func TestSQLFirewallRules(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/sql",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"sql_server_name":     "fw-sql",
			"admin_login":         "sqladmin",
			"admin_password":      "TestPassword123!",
			"databases": []map[string]interface{}{
				{
					"name":        "testdb",
					"sku_name":    "S0",
					"max_size_gb": 10,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
				},
			},
			"firewall_rules": []map[string]interface{}{
				{
					"name":             "allow-office",
					"start_ip_address": "203.0.113.0",
					"end_ip_address":   "203.0.113.255",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "SQL with firewall rules should be created")
}

// TestSQLElasticPool tests SQL with elastic pools
func TestSQLElasticPool(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/sql",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"sql_server_name":     "elastic-sql",
			"admin_login":         "sqladmin",
			"admin_password":      "TestPassword123!",
			"elastic_pools": []map[string]interface{}{
				{
					"name":       "epool1",
					"edition":    "Standard",
					"dtu":        50,
					"db_dtu_min": 10,
					"db_dtu_max": 20,
					"storage_mb": 51200,
				},
			},
			"databases": []map[string]interface{}{
				{
					"name":        "testdb",
					"sku_name":    "S0",
					"max_size_gb": 10,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "SQL with elastic pool should be created")
}

// TestSQLAudit tests SQL with auditing enabled
func TestSQLAudit(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/sql",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"sql_server_name":     "audit-sql",
			"admin_login":         "sqladmin",
			"admin_password":      "TestPassword123!",
			"databases": []map[string]interface{}{
				{
					"name":        "testdb",
					"sku_name":    "S0",
					"max_size_gb": 10,
					"collation":   "SQL_Latin1_General_CP1_CI_AS",
				},
			},
			"audit_enabled":        true,
			"audit_retention_days": 90,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "SQL with auditing should be created")
}
