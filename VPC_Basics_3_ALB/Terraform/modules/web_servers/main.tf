# Create EC2 instances that will serve our web application
resource "aws_instance" "web" {
  count = var.instance_count  # Create multiple instances based on variable

  # Basic instance configuration
  ami           = var.ami_id            # Amazon Machine Image (Amazon Linux 2)
  instance_type = var.instance_type     # Instance size (t2.micro is free tier)
  key_name      = var.key_name          # SSH key pair for access

  # Networking configuration
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]  # Distribute across subnets
  vpc_security_group_ids = [var.security_group_id]  # Attach the security group

  # User data script that runs on first launch
  # This installs Apache and creates a simple homepage
  user_data = <<-EOF
              #!/bin/bash
              # Update package lists
              yum update -y

              # Install Apache web server
              yum install -y httpd

              # Start and enable Apache
              systemctl start httpd
              systemctl enable httpd

              # Create simple homepage showing server info
              echo "<html><body><h1>Server ${count.index + 1}</h1>" > /var/www/html/index.html
              echo "<p>Hostname: $(hostname -f)</p></body></html>" >> /var/www/html/index.html
              EOF

  # Resource tags for identification
  tags = {
    Name = "${var.name_prefix}-web-server${count.index + 1}"  # Numbered instance names
  }
}