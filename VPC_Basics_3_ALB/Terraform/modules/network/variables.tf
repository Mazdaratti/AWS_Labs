

# Name tag for the VPC
variable "vpc_name" {
  description = "Name tag that will be assigned to the VPC and used as a prefix for related resources"
  type        = string
  default     = "alb-tutorial-vpc"
}

# CIDR block for the VPC
variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC in CIDR notation (e.g., '10.0.0.0/16')"
  type        = string
  default     = "10.0.0.0/16"
}

# List of CIDR blocks for public subnets
variable "public_subnet_cidrs" {
  description = <<EOT
List of CIDR blocks for public subnets where internet-facing resources (like ALB) will be deployed.
Should have one CIDR per availability zone.
Example: ["10.0.1.0/24", "10.0.2.0/24"]
EOT
  type        = list(string)
}

# List of CIDR blocks for private subnets
variable "private_subnet_cidrs" {
  description = <<EOT
List of CIDR blocks for private subnets where backend resources (like EC2 instances) will be deployed.
Should have one CIDR per availability zone.
Example: ["10.0.3.0/24", "10.0.4.0/24"]
EOT
  type        = list(string)
}

# List of availability zones to use
variable "availability_zones" {
  description = <<EOT
List of availability zones where subnets should be created.
Should match the number of CIDR blocks provided for subnets.
Example: ["us-east-1a", "us-east-1b"]
EOT
  type        = list(string)
}

# Optional tags for all resources
variable "tags" {
  description = "A map of tags to assign to all network resources"
  type        = map(string)
  default     = {}
}