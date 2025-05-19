# =====================
# Data Sources
# =====================

# Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Current AWS caller identity (for bucket naming)
#data "aws_caller_identity" "current" {}

# AWS region (for endpoint configuration)
#data "aws_region" "current" {}