resource "aws_instance" "web" {
  count = length(var.private_subnet_ids)

  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "Hello World from $(hostname -f)" > /var/www/html/index.html
              chown apache:apache /var/www/html/index.html
              chmod 644 /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.instance_name_prefix}-${count.index + 1}"
  }
}
