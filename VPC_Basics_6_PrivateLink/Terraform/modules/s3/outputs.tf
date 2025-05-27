output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.test_bucket.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.test_bucket.arn
}
