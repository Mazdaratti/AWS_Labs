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

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 Gateway VPC endpoint"
  value       = module.endpoints.s3_gateway_endpoint_id
}

output "ec2_interface_endpoint_id" {
  description = "ID of the EC2 API Interface VPC endpoint"
  value       = module.endpoints.ec2_interface_endpoint_id
}

output "s3_endpoint_id" {
  description = "Gateway endpoint for S3"
  value       = module.endpoints.s3_endpoint_id
}

output "ec2_endpoint_id" {
  description = "Interface endpoint for SSM"
  value       = module.endpoints.ec2_endpoint_id
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "public_instance_id" {
  description = "SSM-managed EC2 instance ID"
  value       = module.ec2_instances.public_instance_id
}

output "private_instance_id" {
  description = "SSM-managed EC2 instance ID"
  value       = module.ec2_instances.private_instance_id
}

output "private_instance_ip" {
  description = "Private IP of private EC2"
  value       = module.ec2_instances.private_instance_private_ip
}

output "public_instance_public_ip" {
  description = "Public IP of the public EC2"
  value       = module.ec2_instances.public_instance_public_ip
}

output "private_instance_private_ip" {
  description = "Private IP of the private EC2"
  value       = module.ec2_instances.private_instance_private_ip
}