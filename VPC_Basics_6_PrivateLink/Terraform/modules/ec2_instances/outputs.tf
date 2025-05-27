# Public EC2 instance ID
output "public_instance_id" {
  description = "ID of the public EC2 instance"
  value       = aws_instance.public.id
}

# Private EC2 instance ID
output "private_instance_id" {
  description = "ID of the private EC2 instance"
  value       = aws_instance.private.id
}

# Public IP of the public EC2 instance (used for SSH from your machine)
output "public_instance_public_ip" {
  description = "Public IP address of the public EC2 instance"
  value       = aws_instance.public.public_ip
}

# Private IP of the private EC2 instance (used for SSH via the public EC2 or internal communication)
output "private_instance_private_ip" {
  description = "Private IP address of the private EC2 instance"
  value       = aws_instance.private.private_ip
}
