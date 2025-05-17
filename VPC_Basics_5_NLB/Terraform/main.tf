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

# =====================
# NAT Gateway Module
# =====================
module "nat_gateway" {
  source              = "./modules/nat_gateway"
  vpc_id              = module.vpc.vpc_id
  vpc_name            = var.vpc_name
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  private_subnet_ids  = module.vpc.private_subnet_ids
}
