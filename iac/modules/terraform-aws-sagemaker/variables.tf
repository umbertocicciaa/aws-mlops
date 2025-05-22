variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "california-housing-regression"
}

variable "s3_data_bucket_name" {
  description = "S3 bucket name where parquet data is stored"
  type        = string
}

variable "sagemaker_bucket" {
  description = "S3 bucket where scripts are stored"
  type        = string
}

variable "s3_data_key" {
  description = "S3 key where parquet data is stored"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for training"
  type        = string
  default     = "ml.t3.medium"
}

variable "model_approval_status" {
  description = "Model approval status"
  type        = string
  default     = "Approved"
}

variable "domain_name" {
  description = "Domain name for the SageMaker training job"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the SageMaker training job"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the SageMaker training job"
  type        = set(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the SageMaker training job"
  type        = set(string)
}

variable "user_profile_name" {
  description = "User profile name for the SageMaker training job"
  type        = string
}