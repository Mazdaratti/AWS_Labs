variable "vpc_name" {
  description = "Prefix for SG naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC to associate security groups with"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}
