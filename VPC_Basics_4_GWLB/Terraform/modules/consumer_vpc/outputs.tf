output "vpc_id" {
  description = "ID of the Consumer VPC"
  value       = aws_vpc.consumer.id
}

output "app_subnet_id" {
  description = "ID of the public App subnet"
  value       = aws_subnet.app.id
}

output "gwlbe_subnet_id" {
  description = "ID of the private GWLBe subnet"
  value       = aws_subnet.gwlbe.id
}

output "app_instance_id" {
  description = "ID of the App EC2 instance"
  value       = aws_instance.app.id
}

output "app_instance_public_ip" {
  description = "Public IP of the App EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_security_group_id" {
  description = "Security Group ID of the App EC2"
  value       = aws_security_group.app_sg.id
}
