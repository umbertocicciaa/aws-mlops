variable "pipeline_name" {
  type        = string
  description = "Name of the SageMaker pipeline."
}

variable "pipeline_display_name" {
  type        = string
  description = "Display name of the SageMaker pipeline."
  default     = ""
}