terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

# =====================
# --- VPC Module ---
# =====================
module "vpc" {
  source              = "./modules/vpc"
  availability_zone   = data.aws_availability_zones.available.names[0]
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# =====================
# -- Security Groups --
# =====================
module "security_groups" {
  source       = "./modules/security_groups"
  vpc_id       = module.vpc.vpc_id
  private_subnet_cidr  = var.private_subnet_cidr
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# =====================
# ------- IAM  --------
# =====================
module "iam" {
  source       = "./modules/iam"

  private_ec2_role_name = "private-ec2-role"
  public_ec2_role_name  = "public-ec2-role"
}

# =====================
# --- Endpoints ---
# =====================
module "endpoints" {
  source          = "./modules/endpoints"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = [module.vpc.private_subnet_id]
  route_table_id  = module.vpc.private_route_table_id
  endpoint_sg_id  = module.security_groups.endpoint_sg_id
  region          = var.region
}

# =====================
# -------- S3 ---------
# =====================
module "s3" {
  source          = "./modules/s3"
  deployer_arn = var.deployer_arn
  bucket_name     = var.bucket_name
  vpc_endpoint_id = module.endpoints.s3_endpoint_id
}

# =====================
# --- EC2_Instances ---
# =====================
module "ec2_instances" {
  source        = "./modules/ec2_instances"
  ami_id        = data.aws_ami.amazon_linux_2023.id
  vpc_name      = var.vpc_name
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnet_id
  ec2_sg_id     = module.security_groups.ec2_sg_id
}


