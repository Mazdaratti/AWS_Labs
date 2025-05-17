variable "vpc_id" {
  description = "ID of the VPC where SGs will be created"
  type        = string
}

variable "vpc_name" {
  description = "Name prefix for tagging"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into EC2"
  type        = string
}
