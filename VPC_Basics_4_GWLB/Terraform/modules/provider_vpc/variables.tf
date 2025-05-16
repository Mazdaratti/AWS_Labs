variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

# Provider VPC Variables
variable "key_name" {
  description = "Name of the existing AWS EC2 key pair for SSH"
  type        = string
}

variable "provider_vpc_cidr" {
  description = "CIDR block for the provider VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "provider_appliance_subnet_cidr" {
  description = "CIDR block for provider appliance subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "provider_gwlb_subnet_cidr" {
  description = "CIDR block for provider GWLB subnet"
  type        = string
  default     = "192.168.2.0/24"
}

variable "provider_public_subnet_cidr" {
  description = "CIDR block for provider public (NAT/IGW) subnet"
  type        = string
  default     = "192.168.3.0/24"
}

variable "appliance_instance_type" {
  description = "EC2 instance type for security appliance"
  type        = string
  default     = "t2.micro"
}
