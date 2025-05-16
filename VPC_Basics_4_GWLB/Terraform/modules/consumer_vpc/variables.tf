variable "vpc_name" {
  description = "Name of the Consumer VPC"
  type        = string
  default     = "consumer-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the Consumer VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "CIDR for the App subnet (public)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "gwlbe_subnet_cidr" {
  description = "CIDR for the GWLBe subnet (private)"
  type        = string
  default     = "10.0.2.0/24"
}


variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into App EC2"
  type        = string
}

variable "app_instance_type" {
  description = "Instance type for App EC2"
  type        = string
  default     = "t3.micro"
}

variable "availability_zone" {
  description = "AZ to deploy the subnets into (injected from root data source)"
  type        = string
}

variable "app_ami" {
  description = "AMI ID for the App EC2 instance (injected from root data source)"
  type        = string
}