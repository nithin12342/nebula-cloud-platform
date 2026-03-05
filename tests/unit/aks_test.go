package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestAKSCreation tests the AKS cluster can be created successfully
func TestAKSCreation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aks",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"cluster_name":        "test-aks",
			"dns_prefix":          "test",
			"kubernetes_version":  "1.29",
			"subnet_id":           "/subscriptions/xxx/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aks-subnet",
			"default_node_pool": map[string]interface{}{
				"name":                "default",
				"node_count":          2,
				"vm_size":             "Standard_D4s_v3",
				"enable_auto_scaling": false,
				"min_count":           1,
				"max_count":           3,
				"os_disk_size_gb":    100,
				"os_disk_type":        "Managed",
				"node_labels":         map[string]string{},
				"scale_down_mode":    "Deallocate",
			},
			"sku_tier":              "Standard",
			"azure_rbac_enabled":   true,
			"azure_policy_enabled": false,
		},
		MaxRetries:         3,
		TimeBetweenRetries: 10,
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "AKS cluster should be created without errors")
}

// TestAKSAutoScaling tests AKS with auto-scaling enabled
func TestAKSAutoScaling(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aks",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"cluster_name":        "autoscale-aks",
			"dns_prefix":          "autoscale",
			"kubernetes_version":  "1.29",
			"subnet_id":           "/subscriptions/xxx/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aks-subnet",
			"default_node_pool": map[string]interface{}{
				"name":                "default",
				"node_count":          3,
				"vm_size":             "Standard_D4s_v3",
				"enable_auto_scaling": true,
				"min_count":           2,
				"max_count":           5,
				"os_disk_size_gb":    100,
				"os_disk_type":        "Managed",
				"node_labels":         map[string]string{},
				"scale_down_mode":    "Deallocate",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "AKS with auto-scaling should be created")
}

// TestAKSOutputs tests that AKS outputs are correctly returned
func TestAKSOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aks",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"cluster_name":        "output-test-aks",
			"dns_prefix":          "output",
			"kubernetes_version":  "1.29",
			"subnet_id":           "/subscriptions/xxx/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aks-subnet",
			"default_node_pool": map[string]interface{}{
				"name":                "default",
				"node_count":          2,
				"vm_size":             "Standard_D4s_v3",
				"enable_auto_scaling": false,
				"min_count":           1,
				"max_count":           3,
				"os_disk_size_gb":    100,
				"os_disk_type":        "Managed",
				"node_labels":         map[string]string{},
				"scale_down_mode":    "Deallocate",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err)

	// Test outputs
	clusterID := terraform.Output(t, terraformOptions, "cluster_id")
	clusterName := terraform.Output(t, terraformOptions, "cluster_name")
	clusterFQDN := terraform.Output(t, terraformOptions, "cluster_fqdn")

	assert.NotEmpty(t, clusterID, "Cluster ID should not be empty")
	assert.Equal(t, "output-test-aks", clusterName, "Cluster name should match")
	assert.NotEmpty(t, clusterFQDN, "Cluster FQDN should not be empty")
}

// TestAKSMultipleNodePools tests AKS with multiple node pools
func TestAKSMultipleNodePools(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aks",
		Vars: map[string]interface{}{
			"resource_group_name": "test-rg",
			"location":            "eastus",
			"cluster_name":        "multi-pool-aks",
			"dns_prefix":          "multipool",
			"kubernetes_version":  "1.29",
			"subnet_id":           "/subscriptions/xxx/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aks-subnet",
			"default_node_pool": map[string]interface{}{
				"name":                "default",
				"node_count":          2,
				"vm_size":             "Standard_D4s_v3",
				"enable_auto_scaling": false,
				"min_count":           1,
				"max_count":           3,
				"os_disk_size_gb":    100,
				"os_disk_type":        "Managed",
				"node_labels":         map[string]string{},
				"scale_down_mode":    "Deallocate",
			},
			"additional_node_pools": []map[string]interface{}{
				{
					"name":                "memory-pool",
					"node_count":          2,
					"vm_size":             "Standard_E4s_v3",
					"enable_auto_scaling": false,
					"min_count":           1,
					"max_count":           3,
					"os_disk_size_gb":    100,
					"os_disk_type":        "Managed",
					"os_type":            "Linux",
					"node_labels": map[string]string{
						"workload": "memory-intensive",
					},
					"node_taints": []string{"workload=memory:NoSchedule"},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "AKS with multiple node pools should be created")
}

// TestAKSAzureAD tests AKS with Azure AD integration
func TestAKSAzureAD(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aks",
		Vars: map[string]interface{}{
			"resource_group_name":    "test-rg",
			"location":               "eastus",
			"cluster_name":            "aad-aks",
			"dns_prefix":              "aad",
			"kubernetes_version":      "1.29",
			"subnet_id":              "/subscriptions/xxx/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/aks-subnet",
			"azure_rbac_enabled":     true,
			"admin_group_object_ids":  []string{"xxx-xxx-xxx"},
			"default_node_pool": map[string]interface{}{
				"name":                "default",
				"node_count":          2,
				"vm_size":             "Standard_D4s_v3",
				"enable_auto_scaling": false,
				"min_count":           1,
				"max_count":           3,
				"os_disk_size_gb":    100,
				"os_disk_type":        "Managed",
				"node_labels":         map[string]string{},
				"scale_down_mode":    "Deallocate",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	_, err := terraform.InitAndApplyE(t, terraformOptions)

	assert.NoError(t, err, "AKS with Azure AD should be created")
}
