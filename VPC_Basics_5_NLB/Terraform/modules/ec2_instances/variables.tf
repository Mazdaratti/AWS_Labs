variable "ami_id" {
  description = "AMI ID to launch (Amazon Linux 2023)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group to attach to EC2 instances"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name to access instances"
  type        = string
}

variable "instance_name_prefix" {
  description = "Prefix for instance Name tag"
  type        = string
}
