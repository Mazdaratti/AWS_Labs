output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "ID of the created private subnet"
  value       = aws_subnet.private.id
}

output "route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}
