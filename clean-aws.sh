#!/bin/bash

# Scripts to clean up AWS Model's resources created by SageMaker.
# Terraform can't destroy these because they are managed outside the IaC scope.

MODEL_PACKAGE_GROUP_NAME="<your-model-package-group-name>"
ENDPOINT_NAME="<your-endpoint-name>"
ENDPOINT_CONFIG_NAME="<your-endpoint-config-name>"

for arn in $(aws sagemaker list-model-packages \
    --model-package-group-name "$MODEL_PACKAGE_GROUP_NAME" \
    --query 'ModelPackageSummaryList[].ModelPackageArn' \
    --output text); do
  echo "Deleting model package: $arn"
  aws sagemaker delete-model-package --model-package-name "$arn"
done

echo "Deleting model package group: $MODEL_PACKAGE_GROUP_NAME"
aws sagemaker delete-model-package-group \
  --model-package-group-name "$MODEL_PACKAGE_GROUP_NAME"

echo "Deleting endpoint: $ENDPOINT_NAME"
aws sagemaker delete-endpoint \
  --endpoint-name "$ENDPOINT_NAME"

echo "Waiting for endpoint deletion to complete..."
aws sagemaker wait endpoint-deleted \
  --endpoint-name "$ENDPOINT_NAME"

echo "Deleting endpoint configuration: $ENDPOINT_CONFIG_NAME"
aws sagemaker delete-endpoint-config \
  --endpoint-config-name "$ENDPOINT_CONFIG_NAME"