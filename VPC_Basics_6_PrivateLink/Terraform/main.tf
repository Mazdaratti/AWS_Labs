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
  source            = "./modules/vpc"
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_name          = var.vpc_name
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
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

# =====================
# --- Endpoints ---
# =====================
module "endpoints" {
  source          = "./modules/endpoints"
  vpc_name        = var.vpc_name
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.private_subnet_id
  route_table_id  = module.vpc.route_table_id
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
# ------ EC2_SSM ------
# =====================
module "ec2_ssm" {
  source        = "./modules/ec2_ssm"
  ami_id        = data.aws_ami.amazon_linux_2023.id
  vpc_name      = var.vpc_name
  instance_type = var.instance_type
  subnet_id     = module.vpc.private_subnet_id
  ec2_sg_id     = module.security_groups.ec2_sg_id
}

# =====================
# ---Automated Test----
# =====================
resource "null_resource" "s3_upload_test" {
  triggers = {
    instance_id = module.ec2_ssm.instance_id
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ssm start-session \
        --target ${module.ec2_ssm.instance_id} \
        --document-name "AWS-StartInteractiveCommand" \
        --parameters command='["aws s3 cp /home/ec2-user/private-upload.txt s3://${module.s3.bucket_name}/private-upload.txt"]'
    EOT
  }
}
