package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestRedisCreation tests the Redis cache can be created successfully
func TestRedisCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/redis",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"redis_cache_name":    "test-redis",
			"sku":                 "Premium",
			"family":              "P",
			"capacity":            1,
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Redis cache should be created without errors")
}

// TestRedisOutputs tests that Redis outputs are correctly returned
func TestRedisOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/redis",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"redis_cache_name":    "output-redis",
			"sku":                 "Standard",
			"family":              "C",
			"capacity":            1,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	hostname := terraform.Output(t, terraformOptions, "redis_host_name")
	port := terraform.Output(t, terraformOptions, "redis_port")

	assert.NotEmpty(t, hostname, "Redis hostname should not be empty")
	assert.Equal(t, "6380", port, "Redis SSL port should be 6380")
}

// TestRedisClustering tests Redis with clustering enabled
func TestRedisClustering(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/redis",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"redis_cache_name":    "clustered-redis",
			"sku":                 "Premium",
			"family":              "P",
			"capacity":            1,
			"enable_clustering":   true,
			"shard_count":         3,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Redis with clustering should be created")
}

// TestRedisFirewallRules tests Redis with firewall rules
func TestRedisFirewallRules(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/redis",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"redis_cache_name":    "fw-redis",
			"sku":                 "Premium",
			"family":              "P",
			"capacity":            1,
			"firewall_rules": []map[string]interface{}{
				{
					"name":             "office-ip",
					"start_ip_address": "203.0.113.0",
					"end_ip_address":   "203.0.113.255",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Redis with firewall rules should be created")
}

// TestRedisPersistence tests Redis with persistence enabled
func TestRedisPersistence(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/redis",
		Vars: map[string]interface{}{
			"resource_group_name":           "test-rg",
			"location":                      "eastus",
			"redis_cache_name":              "persist-redis",
			"sku":                           "Premium",
			"family":                        "P",
			"capacity":                      1,
			"rdb_backup_enabled":            true,
			"rdb_backup_frequency":          60,
			"rdb_backup_max_snapshot_count": 2,
			"rdb_storage_connection_string": "DefaultEndpointsProtocol=https;AccountName=test;AccountKey=xxx;EndpointSuffix=core.windows.net",
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "Redis with persistence should be created")
}
