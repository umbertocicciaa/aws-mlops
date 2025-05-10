variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "eu-west-3"
}

variable "s3_config" {
  description = "S3 bucket configurations."
  type = map(object({}))
  default = {}
}

variable "eventbridge_config" {
  description = "S3 bucket configurations."
  type = map(object({}))
  default = {}
}

variable "sagemaker_config" {
  description = "SageMaker configurations."
  type = object({})
  default = {}
}

variable "glue_job_config" {
  default = {}
  description = "Glue job configurations."
  type = object({})
}