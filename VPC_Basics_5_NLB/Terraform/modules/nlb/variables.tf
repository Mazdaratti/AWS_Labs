variable "vpc_id" {
  description = "VPC ID for target group"
  type        = string
}

variable "vpc_name" {
  description = "Prefix for tagging"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to register with target group"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the NLB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to assign to the NLB"
  type        = string
}
