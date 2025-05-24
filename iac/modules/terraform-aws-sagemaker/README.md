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
| [aws_iam_policy.sagemaker_ecr_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.sagemaker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.s3_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_ecr_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.sagemaker_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_sagemaker_domain.studio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_domain) | resource |
| [aws_sagemaker_model_package_group.model_package_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_model_package_group) | resource |
| [aws_sagemaker_pipeline.mlops_pipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_pipeline) | resource |
| [aws_sagemaker_user_profile.user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_user_profile) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for the SageMaker training job | `string` | n/a | yes |
| <a name="input_model_approval_status"></a> [model\_approval\_status](#input\_model\_approval\_status) | Model approval status | `string` | `"Approved"` | no |
| <a name="input_model_data_bucket"></a> [model\_data\_bucket](#input\_model\_data\_bucket) | S3 bucket where model datas are stored | `string` | n/a | yes |
| <a name="input_preprocessing_instance_type"></a> [preprocessing\_instance\_type](#input\_preprocessing\_instance\_type) | EC2 instance type for preprocessing | `string` | `"ml.t3.medium"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"california-housing-regression"` | no |
| <a name="input_s3_data_bucket_name"></a> [s3\_data\_bucket\_name](#input\_s3\_data\_bucket\_name) | S3 bucket name where parquet datas are stored | `string` | n/a | yes |
| <a name="input_scripts_bucket"></a> [scripts\_bucket](#input\_scripts\_bucket) | S3 bucket where scripts are stored | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs for the SageMaker training job | `set(string)` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for the SageMaker training job | `set(string)` | n/a | yes |
| <a name="input_training_instance_type"></a> [training\_instance\_type](#input\_training\_instance\_type) | Number of EC2 instances for training | `string` | `"ml.m5.xlarge"` | no |
| <a name="input_user_profile_name"></a> [user\_profile\_name](#input\_user\_profile\_name) | User profile name for the SageMaker training job | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for the SageMaker training job | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sagemaker_pipeline_arn"></a> [sagemaker\_pipeline\_arn](#output\_sagemaker\_pipeline\_arn) | n/a |
