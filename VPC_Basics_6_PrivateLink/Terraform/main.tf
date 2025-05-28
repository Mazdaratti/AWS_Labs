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
  bucket_name     = var.bucket_name
  vpc_endpoint_id = module.endpoints.s3_gateway_id
  public_ec2_role_arn = module.iam.public_ec2_role_arn
}

# =====================
# --- EC2_Instances ---
# =====================
module "ec2_instances" {
  source = "./modules/ec2_instances"

  public_subnet_id              = module.vpc.public_subnet_id
  private_subnet_id             = module.vpc.private_subnet_id
  public_sg_id                  = module.security_groups.public_ec2_sg_id
  private_sg_id                 = module.security_groups.private_ec2_sg_id
  public_instance_profile_name  = module.iam.public_ec2_instance_profile
  private_instance_profile_name = module.iam.private_ec2_instance_profile
  key_pair_name                 = var.key_pair_name
  ami_id                        = data.aws_ami.amazon_linux_2023.id
  instance_type                 = var.instance_type
}


