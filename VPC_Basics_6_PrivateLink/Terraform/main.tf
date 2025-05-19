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
  source       = "./modules/vpc"
  vpc_name     = var.vpc_name
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
}

# =====================
# -- Security Groups --
# =====================
module "security_groups" {
  source       = "./modules/security_groups"
  vpc_name     = var.vpc_name
  vpc_id       = module.vpc.vpc_id
  subnet_cidr  = var.subnet_cidr
}
