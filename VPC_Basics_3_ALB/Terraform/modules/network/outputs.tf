# VPC ID output
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

# VPC CIDR block output
output "vpc_cidr_block" {
  description = "The CIDR block of the created VPC"
  value       = aws_vpc.main.cidr_block
}

# Internet Gateway ID output
output "igw_id" {
  description = "The ID of the Internet Gateway attached to the VPC"
  value       = aws_internet_gateway.igw.id
}

# Public subnet IDs output
output "public_subnet_ids" {
  description = "List of IDs of the created public subnets"
  value       = aws_subnet.public[*].id
}

# Private subnet IDs output
output "private_subnet_ids" {
  description = "List of IDs of the created private subnets"
  value       = aws_subnet.private[*].id
}

# NAT Gateway ID output
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway created in the public subnet"
  value       = aws_nat_gateway.nat.id
}

# Public route table ID output
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

# Private route table ID output
output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}

# Availability zones used output
output "availability_zones" {
  description = "List of availability zones where subnets were actually created"
  value       = aws_subnet.public[*].availability_zone
}

# Complete subnet details (for debugging)
output "public_subnets" {
  description = "Complete details of the created public subnets"
  value = [for s in aws_subnet.public : {
    id               = s.id
    cidr_block       = s.cidr_block
    availability_zone = s.availability_zone
  }]
}

output "private_subnets" {
  description = "Complete details of the created private subnets"
  value = [for s in aws_subnet.private : {
    id               = s.id
    cidr_block       = s.cidr_block
    availability_zone = s.availability_zone
  }]
}