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
