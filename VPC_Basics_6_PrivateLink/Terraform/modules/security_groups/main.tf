# ==============================
# Security Group for public EC2
# ==============================
resource "aws_security_group" "public_ec2" {
  name        = "public-ec2-sg"
  description = "Allow SSH from admin IP and HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin workstation"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

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
    Name = "public-ec2-sg"
  }
}

# ===============================
# Security Group for private EC2
# ===============================
resource "aws_security_group" "private_ec2" {
  name        = "private-ec2-sg"
  description = "Allow SSH from public EC2 and HTTPS from interface endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from public EC2 SG"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }

  ingress {
    description = "HTTPS from private subnet (interface endpoint)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-ec2-sg"
  }
}


# ==========================================
# Security Group for EC2 Interface Endpoints
# ==========================================
resource "aws_security_group" "endpoint_sg" {
  name        = "ec2-endpoint-sg"
  description = "Allow HTTPS from private EC2 for Interface Endpoint"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from private EC2 SG"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.private_ec2.id]
  }

  ingress {
    description = "HTTPS from public EC2 SG"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-endpoint-sg"
  }
}
