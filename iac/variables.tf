variable "region" {
  description = "The AWS region to deploy the resources in."
  type        = string
  default     = "eu-west-3"
}

variable "s3_configs" {
  description = "s3 bucket configurations."
  type = map(object({
    name = string
  }))
}