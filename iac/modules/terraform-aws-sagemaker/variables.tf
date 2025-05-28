variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "california-housing-regression"
}

variable "s3_data_bucket_name" {
  description = "S3 bucket name where parquet datas are stored"
  type        = string
}

variable "scripts_bucket" {
  description = "S3 bucket where scripts are stored"
  type        = string
}

variable "model_data_bucket" {
  description = "S3 bucket where model datas are stored"
  type        = string
}

variable "preprocessing_instance_type" {
  description = "EC2 instance type for preprocessing"
  type        = string
  default     = "ml.t3.medium"
}

variable "training_instance_type" {
  description = "Number of EC2 instances for training"
  type        = string
  default     = "ml.m5.xlarge"
}

variable "deploy_instance_type" {
  description = "EC2 instance type for deployment"
  type        = string
  default     = "ml.t2.medium"
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