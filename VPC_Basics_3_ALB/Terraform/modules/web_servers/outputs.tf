# Output the instance IDs
output "instance_ids" {
  description = "List of EC2 instance IDs that were created"
  value       = aws_instance.web[*].id
}

# Output the private IP addresses
output "instance_private_ips" {
  description = "List of private IP addresses assigned to the instances"
  value       = aws_instance.web[*].private_ip
}

# Output the availability zones
output "instance_azs" {
  description = "List of availability zones where instances were launched"
  value       = aws_instance.web[*].availability_zone
}