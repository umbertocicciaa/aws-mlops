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
  default     = "ml.m5.xlarge"
}

variable "model_approval_status" {
  description = "Model approval status"
  type        = string
  default     = "PendingManualApproval"
}