package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var (
	expectedTags = map[string]interface{}{
		"Name":  "Flugel",
		"Owner": "InfraTeam",
	}

	resourceIDs = []string{"aws_instance.ec2_manager_service", "aws_s3_bucket.bucketinstance"}
)

func TestTerraformPlan(t *testing.T) {
	t.Parallel()

	awsRegion := aws.GetRandomStableRegion(t, nil, nil)
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../terraform",
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	})
	plan := terraform.InitAndPlanAndShowWithStructNoLogTempPlanFile(t, terraformOptions)

	for _, id := range resourceIDs {
		terraform.RequirePlannedValuesMapKeyExists(t, plan, id)
		resource := plan.ResourcePlannedValuesMap[id]
		tags := resource.AttributeValues["tags"].(map[string]interface{})
		assert.Equal(t, expectedTags, tags)
	}
}
