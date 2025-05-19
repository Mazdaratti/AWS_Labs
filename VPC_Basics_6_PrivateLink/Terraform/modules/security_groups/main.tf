# =====================
# Security Group for EC2 Instance
# =====================
resource "aws_security_group" "ec2_sg" {
  name        = "${var.vpc_name}-ec2-sg"
  description = "Allow HTTPS from endpoint subnet (for SSM traffic)"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTPS (SSM) from within VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-ec2-sg"
  }
}

# =====================
# Security Group for Interface Endpoints
# =====================
resource "aws_security_group" "endpoint_sg" {
  name        = "${var.vpc_name}-endpoint-sg"
  description = "Allow HTTPS from EC2 for PrivateLink"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from EC2 subnet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-endpoint-sg"
  }
}
