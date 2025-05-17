output "pipeline_name" {
  description = "The name of the SageMaker pipeline."
  value       = aws_sagemaker_pipeline.example.pipeline_name
}

output "pipeline_display_name" {
  description = "The name displayed of the SageMaker pipeline."
  value       = aws_sagemaker_pipeline.example.pipeline_display_name
}