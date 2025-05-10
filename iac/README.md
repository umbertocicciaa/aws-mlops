## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_amazon_eventbridge"></a> [amazon\_eventbridge](#module\_amazon\_eventbridge) | ./modules/terraform-aws-eventbridge | n/a |
| <a name="module_aws_glue_etl_job"></a> [aws\_glue\_etl\_job](#module\_aws\_glue\_etl\_job) | ./modules/terraform-aws-glue/modules/glue-job | n/a |
| <a name="module_aws_lambda"></a> [aws\_lambda](#module\_aws\_lambda) | ./modules/terraform-aws-lambda | n/a |
| <a name="module_aws_sagemaker"></a> [aws\_sagemaker](#module\_aws\_sagemaker) | ./modules/terraform-aws-sagemaker | n/a |
| <a name="module_backend"></a> [backend](#module\_backend) | ./modules/terraform-aws-s3-bucket | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ./modules/terraform-aws-s3-bucket | n/a |

## Resources

| Name | Type |
|------|------|
| [random_id.server](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eventbridge_config"></a> [eventbridge\_config](#input\_eventbridge\_config) | S3 bucket configurations. | `map(object({}))` | `{}` | no |
| <a name="input_glue_job_config"></a> [glue\_job\_config](#input\_glue\_job\_config) | Glue job configurations. | `object({})` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy the resources in. | `string` | `"eu-west-3"` | no |
| <a name="input_s3_config"></a> [s3\_config](#input\_s3\_config) | S3 bucket configurations. | `map(object({}))` | `{}` | no |
| <a name="input_sagemaker_config"></a> [sagemaker\_config](#input\_sagemaker\_config) | SageMaker configurations. | `object({})` | `{}` | no |

## Outputs

No outputs.
