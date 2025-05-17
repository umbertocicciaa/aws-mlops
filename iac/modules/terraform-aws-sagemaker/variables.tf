variable "pipeline_name" {
  type        = string
  description = "Name of the SageMaker pipeline."
  default     = "MlOps-Pipeline"
}

variable "pipeline_display_name" {
  type        = string
  description = "Display name of the SageMaker pipeline."
  default     = "MlOps-Pipeline"
}

variable "input_data" {
  type        = string
  description = "Input data for the pipeline."
  default     = "s3://your-bucket/input-data/"
}

variable "model_artifact_bucket" {
  type        = string
  description = "S3 bucket for the model artifacts."
  default     = "s3://your-bucket/model-artifacts/"
}

variable "mse_threshold" {
  type        = number
  description = "Mean Squared Error threshold for the pipeline."
  default     = 10
}

variable "preprocess_script_bucket" {
  type        = string
  description = "S3 bucket for the preprocessing script."
  default     = "s3://your-bucket/preprocess-script.py"
}

variable "mode_training_script_bucket" {
  type        = string
  description = "S3 bucket for the model artifacts."
  default     = "s3://your-bucket/train.py"
}

variable "model_evaluate_script_bucket" {
  type        = string
  description = "S3 path for the model artifacts."
  default     = "s3://your-bucket/evaluate.py"
}

variable "evaluation_output_bucket" {
  type        = string
  description = "Output bucket for the evaluation results."
  default     = "s3://your-bucket/evaluation-results/"
}

variable "model_package_group_name" {
  description = "Name of the SageMaker Model Package Group"
  type        = string
  default = "mlops-regression-model-group"
}