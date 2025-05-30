# AWS region where resources will be deployed
variable "aws_region" {
  description = "AWS region where resources will be created (e.g., us-east-1)"
  type        = string
  default     = "us-east-1"  # Default to North Virginia region
}

# Your public IP for SSH access (in CIDR format)
variable "my_ip" {
  description = "Your public IP address in CIDR notation (e.g., '123.45.67.89/32') for SSH access"
  type        = string
}

# VPC configuration
variable "vpc_name" {
  description = "Name tag for the VPC (e.g., 'alb-tutorial-vpc')"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., '10.0.0.0/16')"
  type        = string
}

# Subnet configuration
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (e.g., ['10.0.1.0/24', '10.0.2.0/24'])"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (e.g., ['10.0.3.0/24', '10.0.4.0/24'])"
  type        = list(string)
}

# EC2 instance configuration
variable "instance_count" {
  description = "Number of EC2 instances to create (recommend 2 for high availability)"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type (t2.micro is free tier eligible)"
  type        = string
  default     = "t2.micro"
}

# ALB configuration
variable "alb_name" {
  description = "Name prefix for ALB resources (e.g., 'alb-tutorial')"
  type        = string
  default     = "alb-tutorial"
}

