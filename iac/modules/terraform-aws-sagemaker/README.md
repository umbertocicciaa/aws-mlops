## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.sagemaker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.s3_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sagemaker_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint) | resource |
| [aws_sagemaker_endpoint_config.endpoint_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_endpoint_config) | resource |
| [aws_sagemaker_model.model](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model) | resource |
| [aws_sagemaker_model_package_group.model_package_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model_package_group) | resource |
| [aws_sagemaker_pipeline.mlops_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_pipeline) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for training | `string` | `"ml.m5.xlarge"` | no |
| <a name="input_model_approval_status"></a> [model\_approval\_status](#input\_model\_approval\_status) | Model approval status | `string` | `"PendingManualApproval"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"california-housing-regression"` | no |
| <a name="input_s3_data_bucket_name"></a> [s3\_data\_bucket\_name](#input\_s3\_data\_bucket\_name) | S3 bucket name where parquet data is stored | `string` | n/a | yes |
| <a name="input_s3_data_key"></a> [s3\_data\_key](#input\_s3\_data\_key) | S3 key where parquet data is stored | `string` | n/a | yes |
| <a name="input_sagemaker_bucket"></a> [sagemaker\_bucket](#input\_sagemaker\_bucket) | S3 bucket where scripts are stored | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | n/a |
| <a name="output_sagemaker_endpoint"></a> [sagemaker\_endpoint](#output\_sagemaker\_endpoint) | n/a |
| <a name="output_sagemaker_pipeline_arn"></a> [sagemaker\_pipeline\_arn](#output\_sagemaker\_pipeline\_arn) | n/a |
