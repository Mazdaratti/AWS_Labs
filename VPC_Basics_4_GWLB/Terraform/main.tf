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

# --- Consumer VPC module ---
module "consumer_vpc" {
  source = "./modules/consumer_vpc"

  vpc_name              = "consumer-vpc"
  vpc_cidr              = var.consumer_vpc_cidr
  app_subnet_cidr       = var.consumer_app_subnet_cidr
  gwlbe_subnet_cidr     = var.consumer_gwlbe_subnet_cidr

  availability_zone     = data.aws_availability_zones.available.names[0]
  app_ami               = data.aws_ami.amazon_linux_2023.id
  app_instance_type     = var.app_instance_type
  key_name              = var.key_name
  ssh_allowed_cidr      = var.ssh_allowed_cidr
}

# --- GWLB module ---
module "gwlb" {
  source = "./modules/gwlb"

  vpc_name             = "provider-vpc"
  vpc_id               = module.provider_vpc.vpc_id
  gwlb_subnet_id       = module.provider_vpc.gwlb_subnet_id
  appliance_instance_id = module.provider_vpc.appliance_instance_id
  allowed_principals   = [] # Optionally add ARNs that can create endpoints
}

# --- GWLBE module ---
module "gwlbe" {
  source = "./modules/gwlbe"

  vpc_name             = "consumer-vpc"
  consumer_vpc_id      = module.consumer_vpc.vpc_id
  gwlbe_subnet_id      = module.consumer_vpc.gwlbe_subnet_id
  endpoint_service_name = module.gwlb.endpoint_service_name
  endpoint_service_id  = module.gwlb.endpoint_service_id
}

# --- Flow Logs module ---
module "flow_logs" {
  source     = "./modules/flow_logs"
  vpc_name   = "provider-vpc"
  subnets = {
    consumer_app    = { id = module.consumer_vpc.app_subnet_id }
    consumer_gwlbe = { id = module.consumer_vpc.gwlbe_subnet_id }
    provider_app    = { id = module.provider_vpc.appliance_subnet_id }
    provider_gwlb   = { id = module.provider_vpc.gwlb_subnet_id }
    provider_public = { id = module.provider_vpc.public_subnet_id }
  }
}