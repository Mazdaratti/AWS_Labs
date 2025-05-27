variable "public_ec2_role_name" {
  description = "Name of the IAM role to assign to the public EC2 instance"
  type        = string
}

variable "private_ec2_role_name" {
  description = "Name of the IAM role to assign to the private EC2 instance"
  type        = string
}