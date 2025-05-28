# ===============================================
# EC2 Instances Module - public and private EC2
# ===============================================

# -------------------------------
# Public EC2 Instance (Bastion)
# -------------------------------
resource "aws_instance" "public" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  associate_public_ip_address = true
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.public_sg_id]
  iam_instance_profile   = var.public_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from PUBLIC EC2" > /home/ec2-user/public-upload.txt
              chmod 644 /home/ec2-user/public-upload.txt
              EOF

  tags = {
    Name = "public-ec2"
  }
}

# -----------------------------------
# Private EC2 Instance (Test Target)
# -----------------------------------
resource "aws_instance" "private" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id
  associate_public_ip_address = false
  key_name               = var.key_pair_name
  vpc_security_group_ids = [var.private_sg_id]
  iam_instance_profile   = var.private_instance_profile_name

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from PRIVATE EC2" > /home/ec2-user/private-upload.txt
              chmod 644 /home/ec2-user/private-upload.txt
              EOF

  tags = {
    Name = "private-ec2"
  }
}

