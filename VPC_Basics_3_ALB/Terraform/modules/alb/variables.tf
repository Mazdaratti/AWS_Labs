# ALB name
variable "name" {
  description = "Name of the Application Load Balancer and associated resources"
  type        = string
}

# VPC ID
variable "vpc_id" {
  description = "ID of the VPC where the ALB should be created"
  type        = string
}

# Subnet IDs
variable "subnet_ids" {
  description = "List of subnet IDs where the ALB should be deployed (should be public subnets)"
  type        = list(string)
}

# Security group ID
variable "security_group_id" {
  description = "ID of the security group to attach to the ALB"
  type        = string
}

# Target instance IDs
variable "target_instance_ids" {
  description = "List of EC2 instance IDs that should be registered as targets"
  type        = list(string)
}