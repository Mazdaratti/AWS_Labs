resource "aws_vpc" "consumer" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "app" {
  vpc_id                  = aws_vpc.consumer.id
  cidr_block              = var.app_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.vpc_name}-app-subnet"
  }
}

resource "aws_subnet" "gwlbe" {
  vpc_id            = aws_vpc.consumer.id
  cidr_block        = var.gwlbe_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "${var.vpc_name}-gwlbe-subnet"
  }
}

resource "aws_internet_gateway" "consumer" {
  vpc_id = aws_vpc.consumer.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.consumer.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.consumer.id
}

resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.app.id
  route_table_id = aws_route_table.public.id
}

# Security group for App EC2
resource "aws_security_group" "app_sg" {
  name        = "${var.vpc_name}-app-sg"
  description = "Allow SSH access from a specific IP"
  vpc_id      = aws_vpc.consumer.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-app-sg"
  }
}

resource "aws_instance" "app" {
  ami                    = var.app_ami
  instance_type          = var.app_instance_type
  subnet_id              = aws_subnet.app.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "${var.vpc_name}-app-ec2"
  }
}
