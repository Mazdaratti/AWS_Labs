# EC2 instance type (e.g., t2.micro)
variable "instance_type" {
  description = "EC2 instance type for both public and private instances"
  type        = string
}

# The AMI ID to launch (Amazon Linux 2023 or similar)
variable "ami_id" {
  description = "AMI ID to use for launching the EC2 instances"
  type        = string
}

# Name of the EC2 Key Pair to enable SSH access
variable "key_pair_name" {
  description = "Name of the key pair for SSH access"
  type        = string
}

# Subnet ID for the public EC2 instance (has internet access)
variable "public_subnet_id" {
  description = "Subnet ID where the public EC2 instance will be launched"
  type        = string
}

# Subnet ID for the private EC2 instance (no internet access)
variable "private_subnet_id" {
  description = "Subnet ID where the private EC2 instance will be launched"
  type        = string
}

# Security Group ID for the public EC2
variable "public_sg_id" {
  description = "Security group ID for the public EC2 instance"
  type        = string
}

# Security Group ID for the private EC2
variable "private_sg_id" {
  description = "Security group ID for the private EC2 instance"
  type        = string
}

# Instance profile name for public EC2 (used for IAM role attachment)
variable "public_instance_profile_name" {
  description = "IAM instance profile name for the public EC2"
  type        = string
}

# Instance profile name for private EC2 (used for IAM role attachment)
variable "private_instance_profile_name" {
  description = "IAM instance profile name for the private EC2"
  type        = string
}