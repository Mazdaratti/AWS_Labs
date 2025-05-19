output "ec2_sg_id" {
  description = "Security Group ID for EC2 instance"
  value       = aws_security_group.ec2_sg.id
}

output "endpoint_sg_id" {
  description = "Security Group ID for interface endpoints"
  value       = aws_security_group.endpoint_sg.id
}
