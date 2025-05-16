resource "aws_vpc" "provider" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Subnets
resource "aws_subnet" "appliance" {
  vpc_id            = aws_vpc.provider.id
  cidr_block        = var.appliance_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.vpc_name}-appliance-subnet"
  }
}

resource "aws_subnet" "gwlb" {
  vpc_id            = aws_vpc.provider.id
  cidr_block        = var.gwlb_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.vpc_name}-gwlb-subnet"
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.provider.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "provider" {
  vpc_id = aws_vpc.provider.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

# NAT Gateway in Public Subnet
resource "aws_nat_gateway" "provider" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

# Route table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.provider.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.provider.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route table for appliance subnet (private subnet routing via NAT)
resource "aws_route_table" "appliance" {
  vpc_id = aws_vpc.provider.id
  tags = {
    Name = "${var.vpc_name}-appliance-rt"
  }
}

resource "aws_route" "appliance_nat_route" {
  route_table_id         = aws_route_table.appliance.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.provider.id
}

resource "aws_route_table_association" "appliance_assoc" {
  subnet_id      = aws_subnet.appliance.id
  route_table_id = aws_route_table.appliance.id
}

# Route table for GWLB subnet (no default route needed since traffic is forwarded by GWLB)
resource "aws_route_table" "gwlb" {
  vpc_id = aws_vpc.provider.id
  tags = {
    Name = "${var.vpc_name}-gwlb-rt"
  }
}

resource "aws_route_table_association" "gwlb_assoc" {
  subnet_id      = aws_subnet.gwlb.id
  route_table_id = aws_route_table.gwlb.id
}

# Security Group for Appliance EC2 allowing GENEVE (UDP 6081)
resource "aws_security_group" "appliance_sg" {
  name        = "${var.vpc_name}-appliance-sg"
  description = "Allow GENEVE (UDP 6081) inbound and outbound"
  vpc_id      = aws_vpc.provider.id

  ingress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"] # For lab simplicity; restrict in production
  }

  egress {
    from_port   = 6081
    to_port     = 6081
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-appliance-sg"
  }
}

# Appliance EC2 Instance (dummy firewall)
resource "aws_instance" "appliance" {
  ami                    = var.appliance_ami
  instance_type          = var.appliance_instance_type
  subnet_id              = aws_subnet.appliance.id
  vpc_security_group_ids = [aws_security_group.appliance_sg.id]
  associate_public_ip_address = false
  key_name               = var.key_name
  tags = {
    Name = "${var.vpc_name}-security-appliance"
  }
}
