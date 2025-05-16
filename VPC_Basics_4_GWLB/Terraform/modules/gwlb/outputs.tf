output "gwlb_arn" {
  description = "ARN of the Gateway Load Balancer"
  value       = aws_lb.gwlb.arn
}

output "endpoint_service_name" {
  description = "Service name for the Endpoint Service (for PrivateLink)"
  value       = aws_vpc_endpoint_service.endpoint_service.service_name
}

output "endpoint_service_id" {
  description = "Service id for the Endpoint Service (for PrivateLink)"
  value       = aws_vpc_endpoint_service.endpoint_service.id
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.appliance_tg.arn
}
