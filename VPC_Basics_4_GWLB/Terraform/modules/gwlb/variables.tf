variable "vpc_name" {
  description = "Name for tagging resources"
  type        = string
  default     = "provider-vpc"
}

variable "vpc_id" {
  description = "Provider VPC ID"
  type        = string
}

variable "gwlb_subnet_id" {
  description = "Subnet ID where GWLB will be placed"
  type        = string
}

variable "appliance_instance_id" {
  description = "Instance ID of the Security Appliance EC2"
  type        = string
}

variable "allowed_principals" {
  description = "List of ARNs allowed to connect to the endpoint service"
  type        = list(string)
  default     = []
}
