provider "aws" {
  region = var.region
}

# =====================
# VPC Module
# =====================
module "vpc" {
  source              = "./modules/vpc"
  vpc_name            = var.vpc_name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = data.aws_availability_zones.available.names
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
