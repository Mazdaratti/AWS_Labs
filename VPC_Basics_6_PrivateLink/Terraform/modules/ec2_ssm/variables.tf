variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch (Amazon Linux 2023)"
  type        = string
}

variable "vpc_name" {
  description = "Prefix for naming resources"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the EC2 into"
  type        = string
}

variable "ec2_sg_id" {
  description = "Security Group ID to associate with EC2"
  type        = string
}
