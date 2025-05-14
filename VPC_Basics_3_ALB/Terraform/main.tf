
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

# Data source to find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true   # Get the newest AMI
  owners      = ["amazon"]  # Only official Amazon AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # AMI naming pattern
  }
}

# Create an SSH key pair for EC2 instance access
resource "aws_key_pair" "alb_key" {
  key_name   = "${var.alb_name}-key"  # Name for the key pair
  public_key = file("~/.ssh/id_rsa.pub")  # Path to your public key file
}

# Web Servers module creates EC2 instances running Apache
module "web_servers" {
  source = "./modules/web_servers"

  instance_count     = var.instance_count     # Number of instances to launch
  ami_id            = data.aws_ami.amazon_linux.id  # Latest Amazon Linux 2 AMI
  instance_type     = var.instance_type     # Instance size (t2.micro is free tier)
  key_name          = aws_key_pair.alb_key.key_name  # SSH key for access
  subnet_ids        = module.network.private_subnet_ids  # Place in private subnets
  security_group_id = module.security_groups.web_server_sg_id  # Attach security group
}