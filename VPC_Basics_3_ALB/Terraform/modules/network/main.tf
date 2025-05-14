# Create the Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr  # The IP range for the entire network
  enable_dns_support   = true          # Required for DNS resolution
  enable_dns_hostnames = true          # Required for DNS hostnames

  tags = {
    Name = var.vpc_name  # Resource tag for identification
  }
}

# Internet Gateway for public subnet internet access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id  # Attach to our VPC

  tags = {
    Name = "${var.vpc_name}-igw"  # Descriptive name
  }
}

# Public subnets (for resources that need direct internet access)
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)  # Create one subnet per CIDR

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]  # Assign CIDR
  availability_zone = var.availability_zones[count.index]   # Distribute across AZs
  map_public_ip_on_launch = false  # We control public IP assignment

  tags = {
    Name = "${var.vpc_name}-public-${count.index + 1}"  # Numbered name
  }
}

# Private subnets (for resources that shouldn't be directly internet-accessible)
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${count.index + 1}"
  }
}

# Elastic IP for NAT Gateway (required for stable public IP)
resource "aws_eip" "nat" {
  domain = "vpc"  # Allocate in VPC scope

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# NAT Gateway allows private subnets to access internet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id  # Attach the Elastic IP
  subnet_id     = aws_subnet.public[0].id  # Must be in a public subnet

  tags = {
    Name = "${var.vpc_name}-nat-gw"
  }

  # Explicit dependency - must wait for IGW to be created
  depends_on = [aws_internet_gateway.igw]
}

# Public route table (routes traffic to Internet Gateway)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Default route for internet traffic
  route {
    cidr_block = "0.0.0.0/0"       # All traffic
    gateway_id = aws_internet_gateway.igw.id  # Route to IGW
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Private route table (routes traffic to NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"    # All traffic
    nat_gateway_id = aws_nat_gateway.nat.id  # Route to NAT
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}