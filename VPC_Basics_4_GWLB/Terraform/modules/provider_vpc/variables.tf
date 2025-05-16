variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
  default     = "provider-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for Provider VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "appliance_subnet_cidr" {
  description = "CIDR block for Appliance subnet"
  type        = string
  default     = "192.168.1.0/24"
}

variable "gwlb_subnet_cidr" {
  description = "CIDR block for GWLB subnet"
  type        = string
  default     = "192.168.2.0/24"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "192.168.3.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for all subnets"
  type        = string
  default     = "us-east-1a"
}

variable "appliance_ami" {
  description = "AMI ID for the appliance EC2 instance"
  type        = string
  default     = "ami-0abcdef1234567890" # placeholder, update with Amazon Linux 2023 AMI in your region
}

variable "appliance_instance_type" {
  description = "Instance type for the appliance EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = null
}
