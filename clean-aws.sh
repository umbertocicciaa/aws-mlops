# Scripts to clean up AWS Model's resources created by the sagemaker.
# You cant delete AWS Model's resources with terraform destroy because are not part ot the infrastructure.
MODEL_PACKAGE_GROUP_NAME=""

for arn in $(aws sagemaker list-model-packages \
    --model-package-group-name "$MODEL_PACKAGE_GROUP_NAME" \
    --query 'ModelPackageSummaryList[].ModelPackageArn' \
    --output text); do
  echo "Deleting model package: $arn"
  aws sagemaker delete-model-package --model-package-name "$arn"
done

aws sagemaker delete-model-package-group \
  --model-package-group-name "$MODEL_PACKAGE_GROUP_NAME"
