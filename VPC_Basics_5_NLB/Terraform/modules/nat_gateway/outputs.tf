output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.nat.id
}

output "nat_eip" {
  description = "Elastic IP attached to the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}

output "private_route_table_id" {
  description = "Route table ID used by private subnets"
  value       = aws_route_table.private_rt.id
}
