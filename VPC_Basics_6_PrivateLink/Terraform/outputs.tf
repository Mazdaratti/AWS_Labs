output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = module.vpc.private_subnet_id
}

output "route_table_id" {
  description = "Private Route Table ID"
  value       = module.vpc.route_table_id
}

output "ec2_sg_id" {
  description = "EC2 instance SG"
  value       = module.security_groups.ec2_sg_id
}

output "endpoint_sg_id" {
  description = "Endpoint SG"
  value       = module.security_groups.endpoint_sg_id
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_endpoint_id" {
  description = "Gateway endpoint for S3"
  value       = module.endpoints.s3_endpoint_id
}

output "ssm_endpoint_id" {
  description = "Interface endpoint for SSM"
  value       = module.endpoints.ssm_endpoint_id
}

output "ssmmessages_endpoint_id" {
  description = "Interface endpoint for SSM Messages"
  value       = module.endpoints.ssmmessages_endpoint_id
}
