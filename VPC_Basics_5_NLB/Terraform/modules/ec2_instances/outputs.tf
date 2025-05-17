output "instance_ids" {
  description = "IDs of launched EC2 instances"
  value       = aws_instance.web[*].id
}

output "private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = aws_instance.web[*].private_ip
}
