provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_1" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-1"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = "10.0.0.0/28"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "VPC-1 PublicSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "VPC-1 InternetGateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_1.id
  tags = {
    Name = "VPC-1 PublicRouteTable"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "web_sg" {
  name        = "VPC-1 SG"
  description = "Allows HTTP access"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_instance" "web_server" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              service httpd start
              chkconfig on
              cd /var/www/html
              echo "<html><body><h1>Hello World, This is a WebServer<h1></body></html>" > index.html
              EOF

  tags = {
    Name = "VPC-1 Instance"
  }
}

output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}