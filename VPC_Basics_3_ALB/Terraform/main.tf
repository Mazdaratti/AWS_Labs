# =================
# AWS PROVIDER CONFIG
# =================
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


# ================
# NETWORK MODULE
# ================
# Creates VPC, subnets, route tables, NAT and internet gateway
module "network" {
  source = "./modules/network"  # Path to the network module

  # Pass configuration values to the module
  vpc_name            = var.vpc_name            # Name tag for the VPC
  vpc_cidr            = var.vpc_cidr            # IP range for the entire VPC
  public_subnet_cidrs = var.public_subnet_cidrs # CIDRs for public subnets (ALB)
  private_subnet_cidrs = var.private_subnet_cidrs # CIDRs for private subnets (EC2)
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)  # Automatically use 2 available AZs from the data source
}

# ===================
# SECURITY GROUPS MODULE
# ===================
# Defines firewall rules for ALB and EC2 instances
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.network.vpc_id  # Get VPC ID from network module
  my_ip  = var.my_ip              # Your public IP for SSH access
  name_prefix = "alb-tutorial"    # Prefix for all security group names and tags
}

# =================
# WEB SERVERS MODULE
# =================
# Creates EC2 instances with Apache web server
module "web_servers" {
  source = "./modules/web_servers"

  instance_count     = var.instance_count     # Number of instances to launch
  ami_id            = data.aws_ami.amazon_linux_2023.id  # Latest Amazon Linux 2 AMI
  instance_type     = var.instance_type     # Instance size (t2.micro is free tier)
  key_name          = aws_key_pair.alb_key.key_name  # SSH key for access
  subnet_ids        = module.network.private_subnet_ids  # Place in private subnets
  security_group_id = module.security_groups.web_server_sg_id  # Attach security group
}

# =========
# ALB MODULE
# =========
# Creates Application Load Balancer and related resources
module "alb" {
  source = "./modules/alb"

  name               = var.alb_name               # Name for the ALB
  vpc_id             = module.network.vpc_id      # VPC to deploy in
  subnet_ids         = module.network.public_subnet_ids  # Public subnets for ALB
  security_group_id  = module.security_groups.alb_sg_id  # ALB security group
  target_instance_ids = module.web_servers.instance_ids  # EC2 instances to target
}

# =====================
# DATA SOURCES
# =====================
# Get available AZs in current region
data "aws_availability_zones" "available" {
  state = "available"  # Only show AZs that are available
}

# Data source to find the latest Amazon Linux 2023 AMI
# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]  # Matches the exact naming pattern
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

# =====================
# RESOURCES
# =====================
# Create an SSH key pair for EC2 instance access
resource "tls_private_key" "alb_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "alb_key" {
  key_name   = "${var.alb_name}-key"  # Name for the key pair
  public_key = tls_private_key.alb_key.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.alb_key.private_key_openssh
  filename = "${path.module}/${var.alb_name}-key.pem"
  file_permission = "0400" # Read-only for owner
}

