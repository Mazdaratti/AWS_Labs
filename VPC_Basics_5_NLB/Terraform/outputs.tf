output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the created VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "nat_gateway_id" {
  value       = module.nat_gateway.nat_gateway_id
  description = "NAT Gateway ID"
}

output "nat_eip" {
  value       = module.nat_gateway.nat_eip
  description = "Public IP of the NAT Gateway"
}
