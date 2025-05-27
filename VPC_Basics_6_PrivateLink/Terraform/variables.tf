variable "region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into public EC2"
  type        = string
}

variable "public_ec2_role_name" {
  description = "Name of the IAM role for the public EC2 instance"
  type        = string
  default     = "public-ec2-role"
}

variable "private_ec2_role_name" {
  description = "Name of the IAM role for the private EC2 instance"
  type        = string
  default     = "private-ec2-role"
}
variable "bucket_name" {
  description = "Globally unique name for the S3 bucket"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "SSH key pair name to use for EC2 instances"
  type        = string
}