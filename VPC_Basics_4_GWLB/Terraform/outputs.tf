output "provider_vpc_id" {
  description = "Provider VPC ID"
  value       = module.provider_vpc.vpc_id
}

output "appliance_instance_id" {
  description = "ID of the Security Appliance EC2 instance"
  value       = module.provider_vpc.appliance_instance_id
}

output "appliance_subnet_id" {
  description = "Provider appliance subnet ID"
  value       = module.provider_vpc.appliance_subnet_id
}

output "gwlb_subnet_id" {
  description = "Provider GWLB subnet ID"
  value       = module.provider_vpc.gwlb_subnet_id
}

output "public_subnet_id" {
  description = "Provider public subnet ID"
  value       = module.provider_vpc.public_subnet_id
}

output "consumer_vpc_id" {
  description = "Consumer VPC ID"
  value       = module.consumer_vpc.vpc_id
}

output "app_instance_id" {
  description = "App EC2 instance ID"
  value       = module.consumer_vpc.app_instance_id
}

output "app_instance_public_ip" {
  description = "App EC2 public IP (use to SSH)"
  value       = module.consumer_vpc.app_instance_public_ip
}

output "gwlb_arn" {
  description = "Gateway Load Balancer ARN"
  value       = module.gwlb.gwlb_arn
}

output "endpoint_service_name" {
  description = "Gateway Load Balancer Endpoint Service Name"
  value       = module.gwlb.endpoint_service_name
}

output "gwlbe_endpoint_id" {
  description = "Gateway Load Balancer Endpoint ID"
  value       = module.gwlbe.gwlbe_endpoint_id
}

output "flow_logs_log_group" {
  description = "VPC Flow Logs Log Group"
  value       = module.flow_logs.log_group_name
}
