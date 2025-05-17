variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC (used in naming resources)"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where NAT Gateway will be placed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to associate with the private route table"
  type        = list(string)
}
