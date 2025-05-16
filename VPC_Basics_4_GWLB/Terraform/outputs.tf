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