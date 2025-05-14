# Number of EC2 instances to create
variable "instance_count" {
  description = "Number of identical web server instances to launch (recommend 2 for high availability)"
  type        = number
}

# Amazon Machine Image ID
variable "ami_id" {
  description = "ID of the AMI to use for the instances (e.g., Amazon Linux 2)"
  type        = string
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type (t2.micro is free tier eligible)"
  type        = string
  default     = "t2.micro"
}

# SSH key pair name
variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
}

# List of subnet IDs for instance placement
variable "subnet_ids" {
  description = "List of subnet IDs where instances should be launched (should be private subnets)"
  type        = list(string)
}

# Security group ID to attach
variable "security_group_id" {
  description = "ID of the security group to attach to instances"
  type        = string
}

# Naming prefix
variable "name_prefix" {
  description = "Prefix for resource names (e.g., 'prod', 'dev')"
  type        = string
  default     = "Web"
}