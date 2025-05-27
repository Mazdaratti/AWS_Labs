variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into public EC2"
  type        = string
}

variable "vpc_id" {
  description = "VPC to associate security groups with"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}
