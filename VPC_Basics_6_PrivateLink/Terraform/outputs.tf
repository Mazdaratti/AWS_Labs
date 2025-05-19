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
