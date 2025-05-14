# DNS name of the ALB - use this to access your application
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer - use this URL to access your application"
  value       = module.alb.alb_dns_name
}

# Private IPs of the web servers (for troubleshooting)
output "web_server_private_ips" {
  description = "Private IP addresses of the EC2 instances (for debugging purposes)"
  value       = module.web_servers.instance_private_ips
}

output "key_pair_name" {
  description = "Name of the created AWS key pair"
  value       = aws_key_pair.alb_key.key_name
}

output "private_key_saved_location" {
  description = "Path where the private key was saved locally"
  value       = local_file.private_key.filename
  sensitive   = true
}

output "latest_al2023_ami" {
  value = {
    id      = data.aws_ami.amazon_linux_2023.id
    name    = data.aws_ami.amazon_linux_2023.name
    version = regex("al2023-ami-(.*)-x86_64", data.aws_ami.amazon_linux_2023.name)[0]
  }
}