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