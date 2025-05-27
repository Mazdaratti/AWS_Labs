output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Private Subnet ID"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "Private Subnet ID"
  value       = module.vpc.private_subnet_id
}

output "private_ec2_sg_id" {
  description = "Private EC2 instance SG"
  value       = module.security_groups.private_ec2_sg_id
}

output "public_ec2_sg_id" {
  description = "Public EC2 instance SG"
  value       = module.security_groups.public_ec2_sg_id
}

output "endpoint_sg_id" {
  description = "Endpoint SG"
  value       = module.security_groups.endpoint_sg_id
}

output "public_ec2_role_name" {
  description = "Name of the IAM role for the public EC2 instance"
  value       = module.iam.public_ec2_role_name
}

output "public_ec2_instance_profile" {
  description = "Instance profile ARN for the public EC2 instance"
  value       = module.iam.public_ec2_instance_profile
}

output "private_ec2_role_name" {
  description = "Name of the IAM role for the private EC2 instance"
  value       = module.iam.private_ec2_role_name
}

output "private_ec2_instance_profile" {
  description = "Instance profile ARN for the private EC2 instance"
  value       = module.iam.private_ec2_instance_profile
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

output "instance_id" {
  description = "SSM-managed EC2 instance ID"
  value       = module.ec2_ssm.instance_id
}

output "instance_private_ip" {
  description = "Private IP of EC2"
  value       = module.ec2_ssm.instance_private_ip
}
