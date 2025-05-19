output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.private_ec2.id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.private_ec2.private_ip
}
