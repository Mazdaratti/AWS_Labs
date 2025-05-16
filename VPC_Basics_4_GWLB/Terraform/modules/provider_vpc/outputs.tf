output "vpc_id" {
  description = "Provider VPC ID"
  value       = aws_vpc.provider.id
}

output "appliance_subnet_id" {
  description = "Subnet ID for appliance"
  value       = aws_subnet.appliance.id
}

output "gwlb_subnet_id" {
  description = "Subnet ID for GWLB"
  value       = aws_subnet.gwlb.id
}

output "public_subnet_id" {
  description = "Subnet ID for public subnet"
  value       = aws_subnet.public.id
}

output "appliance_sg_id" {
  description = "Security Group ID for appliance"
  value       = aws_security_group.appliance_sg.id
}

output "appliance_instance_id" {
  description = "EC2 Instance ID of the appliance"
  value       = aws_instance.appliance.id
}
