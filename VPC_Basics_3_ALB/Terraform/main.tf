# Terraform block specifies required providers and backend configuration
terraform {
  # Minimum Terraform version required
  required_version = ">= 1.8.0"

  # Define required providers and their versions
  required_providers {
    aws = {
      source  = "hashicorp/aws"  # Official AWS provider from HashiCorp
      version = "~> 5.0"         # Use AWS provider version 5.x
    }
  }

  # Remote backend configuration to store Terraform state
  # This enables team collaboration and state locking
  backend "s3" {
    bucket         = "my-alb-tf-state"       # S3 bucket to store state
    key            = "alb-tutorial/terraform.tfstate"  # Path to state file
    region         = "us-east-1"             # AWS region for the bucket
    dynamodb_table = "tf-lock-table"         # For state locking (prevent conflicts)
    encrypt        = true                    # Encrypt state file at rest
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region  # Use the region specified in variables

  # Default tags to apply to all resources
  default_tags {
    tags = {
      Environment = "tutorial"  # Identifies this as a tutorial environment
      Project     = "alb-demo"  # Project name for billing/resource tracking
      ManagedBy   = "Terraform" # Indicates infrastructure is code-managed
    }
  }
}

# Get available AZs in current region
data "aws_availability_zones" "available" {
  state = "available"  # Only show AZs that are available
}

# Network module creates the foundational networking components
module "network" {
  source = "./modules/network"  # Path to the network module

  # Pass configuration values to the module
  vpc_name            = var.vpc_name            # Name tag for the VPC
  vpc_cidr            = var.vpc_cidr            # IP range for the entire VPC
  public_subnet_cidrs = var.public_subnet_cidrs # CIDRs for public subnets (ALB)
  private_subnet_cidrs = var.private_subnet_cidrs # CIDRs for private subnets (EC2)
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)  # Automatically use 2 available AZs from the data source
}

# Security Groups module defines firewall rules
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.network.vpc_id  # Get VPC ID from network module
  my_ip  = var.my_ip              # Your public IP for SSH access
  name_prefix = "alb-tutorial"    # Prefix for all security group names and tags
}