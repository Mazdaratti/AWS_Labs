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

# =====================
# Security Groups Module
# =====================
module "security_groups" {
  source             = "./modules/security_groups"
  vpc_id             = module.vpc.vpc_id
  vpc_name           = var.vpc_name
  ssh_allowed_cidr   = var.ssh_allowed_cidr
}

# =====================
# EC2 Instances Module
# =====================
module "ec2_instances" {
  source              = "./modules/ec2_instances"
  ami_id              = data.aws_ami.amazon_linux_2023.id
  instance_type       = var.instance_type
  private_subnet_ids  = module.vpc.private_subnet_ids
  security_group_id   = module.security_groups.ec2_sg_id
  key_name            = var.key_name
  instance_name_prefix = "${var.vpc_name}-web"
}

# =====================
# NLB Module
# =====================
module "nlb" {
  source             = "./modules/nlb"
  vpc_id             = module.vpc.vpc_id
  vpc_name           = var.vpc_name
  instance_ids       = module.ec2_instances.instance_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  security_group_id  = module.security_groups.nlb_sg_id
}
