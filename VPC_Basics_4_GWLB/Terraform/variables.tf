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

# Consumer VPC vars
variable "consumer_vpc_cidr" {
  description = "CIDR block for the Consumer VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "consumer_app_subnet_cidr" {
  description = "CIDR block for the App subnet in Consumer VPC"
  type        = string
  default     = "10.0.1.0/24"
}

variable "consumer_gwlbe_subnet_cidr" {
  description = "CIDR block for the GWLBe subnet in Consumer VPC"
  type        = string
  default     = "10.0.2.0/24"
}

variable "app_instance_type" {
  description = "Instance type for the App EC2"
  type        = string
  default     = "t2.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into App EC2"
  type        = string
}

variable "allowed_principals" {
  description = "List of ARNs allowed to connect to the Gateway Load Balancer Endpoint Service"
  type        = list(string)
  default     = []
}