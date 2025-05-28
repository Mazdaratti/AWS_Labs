output "s3_gateway_id" {
  description = "ID of S3 Gateway endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "ec2_endpoint_id" {
  description = "ID of SSM interface endpoint"
  value       = aws_vpc_endpoint.ec2_interface.id
}


