output "s3_endpoint_id" {
  description = "ID of S3 Gateway endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "ssm_endpoint_id" {
  description = "ID of SSM interface endpoint"
  value       = aws_vpc_endpoint.ssm_interface.id
}

output "ssmmessages_endpoint_id" {
  description = "ID of SSM messages endpoint"
  value       = aws_vpc_endpoint.ssmmessages_interface.id
}
