output "sagemaker_endpoint" {
  value = aws_sagemaker_endpoint.endpoint.name
}

output "sagemaker_pipeline_arn" {
  value = aws_sagemaker_pipeline.mlops_pipeline.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sagemaker_bucket.bucket
}