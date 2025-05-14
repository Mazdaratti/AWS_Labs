# Security group for the Application Load Balancer
resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"  # Descriptive name
  description = "Allow HTTP traffic to ALB"  # Purpose documentation
  vpc_id      = var.vpc_id                   # Attach to our VPC

  # Allow HTTP (port 80) from anywhere
  ingress {
    description = "HTTP from anywhere"  # Rule description
    from_port   = 80                    # Start port range
    to_port     = 80                    # End port range
    protocol    = "tcp"                 # TCP protocol
    cidr_blocks = ["0.0.0.0/0"]         # Allow from all IPs
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0       # All ports
    to_port     = 0       # All ports
    protocol    = "-1"    # All protocols
    cidr_blocks = ["0.0.0.0/0"]  # All destinations
  }

  tags = {
    Name = "${var.name_prefix}-alb-sg"  # Resource tag
  }
}

# Security group for web servers
resource "aws_security_group" "web_server" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow HTTP from ALB and SSH from my IP"
  vpc_id      = var.vpc_id

  # Allow HTTP traffic only from the ALB security group
  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # Restricted source
  }

  # Allow SSH only from a specific IP (your IP)
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]  # Very restricted access
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-web-sg"
  }
}