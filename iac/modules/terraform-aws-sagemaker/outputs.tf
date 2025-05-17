output "sagemaker_endpoint" {
  value = aws_sagemaker_endpoint.endpoint.name
}

output "sagemaker_pipeline_arn" {
  value = aws_sagemaker_pipeline.mlops_pipeline.arn
}
