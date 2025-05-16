provider "aws" {
  region = var.aws_region
}

# --- Provider VPC module ---
module "provider_vpc" {
  source = "./modules/provider_vpc"

  vpc_name                = "provider-vpc"
  vpc_cidr                = var.provider_vpc_cidr
  appliance_subnet_cidr   = var.provider_appliance_subnet_cidr
  gwlb_subnet_cidr        = var.provider_gwlb_subnet_cidr
  public_subnet_cidr      = var.provider_public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0]
  appliance_ami           = data.aws_ami.amazon_linux_2023.id
  appliance_instance_type = var.appliance_instance_type
  key_name                = var.key_name
}