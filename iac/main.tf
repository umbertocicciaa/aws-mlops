module "s3" {
  source = "./modules/terraform-aws-s3-bucket"
  for_each = var.s3_config
}

module "aws_glue_etl_job" {
  source = "./modules/terraform-aws-glue/modules/glue-job"
  command = var.glue_job_config.command
  role_arn = var.glue_job_config.role_arn
}   

module "amazon_eventbridge" {
  source = "./modules/terraform-aws-eventbridge"
  for_each = var.eventbridge_config
}

module "aws_lambda" {
  source = "./modules/terraform-aws-lambda"
}

module "aws_sagemaker" {
  source = "./modules/terraform-aws-sagemaker"
}