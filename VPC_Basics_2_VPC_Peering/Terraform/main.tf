provider "aws" {
  region = "us-east-1"
}

# Existing VPC-1 from previous lab (must be deployed first)
# CIDR: 10.0.0.0/24

# Task 1: Create VPC-2
resource "aws_vpc" "vpc_2" {
  cidr_block           = "192.168.0.0/24" # Provides 256 IP addresses
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-2"
  }
}

# Task 2: Create Public Subnet in VPC-2
resource "aws_subnet" "vpc_2_public_subnet" {
  vpc_id                  = aws_vpc.vpc_2.id
  cidr_block              = "192.168.0.0/28" # Provides 16 IP addresses
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "VPC-2 PublicSubnet"
  }
}

# Task 3: Create Internet Gateway for VPC-2
resource "aws_internet_gateway" "vpc_2_igw" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name = "VPC-2 InternetGateway"
  }
}

# Task 4: Create Route Table for VPC-2
resource "aws_route_table" "vpc_2_public_route_table" {
  vpc_id = aws_vpc.vpc_2.id
  tags = {
    Name = "VPC-2 PublicRouteTable"
  }
}

resource "aws_route" "vpc_2_internet_route" {
  route_table_id         = aws_route_table.vpc_2_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc_2_igw.id
}

resource "aws_route_table_association" "vpc_2_subnet_association" {
  subnet_id      = aws_subnet.vpc_2_public_subnet.id
  route_table_id = aws_route_table.vpc_2_public_route_table.id
}

# Task 5: Security Groups Configuration
# Security Group for VPC-2 Instance
resource "aws_security_group" "vpc_2_sg" {
  name        = "VPC-2 SG"
  description = "Allows ICMP ping from VPC-1 Instance and SSH"
  vpc_id      = aws_vpc.vpc_2.id

  # Allow ICMP from VPC-1
  ingress {
    description = "ICMP from VPC-1"
    from_port   = -1 # ICMP type (all)
    to_port     = -1 # ICMP code (all)
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/24"] # VPC-1 CIDR
  }

  # Allow SSH from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC-2 SG"
  }
}

# Update Security Group for VPC-1 Instance (from previous lab)
resource "aws_security_group" "vpc_1_sg" {
  name        = "VPC-1 SG"
  description = "Allows HTTP access and ICMP from VPC-2"
  vpc_id      = aws_vpc.vpc_1.id # Assuming vpc_1 is defined in previous lab

  # HTTP from anywhere (from previous lab)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add ICMP from VPC-2
  ingress {
    description = "ICMP from VPC-2"
    from_port   = -1 # ICMP type (all)
    to_port     = -1 # ICMP code (all)
    protocol    = "icmp"
    cidr_blocks = ["192.168.0.0/24"] # VPC-2 CIDR
  }

  # Add SSH from anywhere
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC-1 SG"
  }
}

# Task 6: Launch Instance in VPC-2
resource "aws_instance" "vpc_2_instance" {
  ami                    = "ami-06d4d7b82ed5acff1" # Amazon Linux 2 AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.vpc_2_public_subnet.id
  vpc_security_group_ids = [aws_security_group.vpc_2_sg.id]
  key_name               = "VirginiaKeyPair" # From previous lab

  tags = {
    Name = "VPC-2 Instance"
  }
}

# Task 7: Create VPC Peering Connection
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id = aws_vpc.vpc_1.id # From previous lab
  vpc_id      = aws_vpc.vpc_2.id
  auto_accept = true # Automatically accept the peering (since same account)

  tags = {
    Name = "VPC-Peering"
  }
}

# Task 8: Configure Routing for Peering Connection
# Add route to VPC-1's route table pointing to VPC-2
resource "aws_route" "vpc_1_to_vpc_2" {
  route_table_id            = aws_route_table.vpc_1_public_route_table.id # From previous lab
  destination_cidr_block    = "192.168.0.0/24" # VPC-2 CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Add route to VPC-2's route table pointing to VPC-1
resource "aws_route" "vpc_2_to_vpc_1" {
  route_table_id            = aws_route_table.vpc_2_public_route_table.id
  destination_cidr_block    = "10.0.0.0/24" # VPC-1 CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Outputs for testing
output "vpc_1_instance_private_ip" {
  value = aws_instance.vpc_1_instance.private_ip # From previous lab
}

output "vpc_2_instance_private_ip" {
  value = aws_instance.vpc_2_instance.private_ip
}

output "vpc_1_instance_public_ip" {
  value = aws_instance.vpc_1_instance.public_ip # From previous lab
}

output "vpc_2_instance_public_ip" {
  value = aws_instance.vpc_2_instance.public_ip
}