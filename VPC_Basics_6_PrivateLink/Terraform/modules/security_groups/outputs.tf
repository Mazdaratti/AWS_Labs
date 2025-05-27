output "public_ec2_sg_id" {
  description = "Security Group ID for public EC2 instance"
  value       = aws_security_group.public_ec2.id
}

output "private_ec2_sg_id" {
  description = "Security Group ID for public EC2 instance"
  value       = aws_security_group.private_ec2.id
}

output "endpoint_sg_id" {
  description = "Security Group ID for interface endpoints"
  value       = aws_security_group.endpoint_sg.id
}
