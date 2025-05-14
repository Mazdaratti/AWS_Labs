# ALB DNS name
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer - use this to access your application"
  value       = aws_lb.alb.dns_name
}

# Target group ARN
output "target_group_arn" {
  description = "ARN of the target group (useful for attaching additional listeners)"
  value       = aws_lb_target_group.web.arn
}

# ALB zone ID
output "alb_zone_id" {
  description = "Canonical hosted zone ID of the load balancer (for Route 53 alias records)"
  value       = aws_lb.alb.zone_id
}