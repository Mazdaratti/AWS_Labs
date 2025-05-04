# 🚀 Amazon VPC + Web Server Lab with Terraform

This lab walks you through the process of creating a basic Amazon Virtual Private Cloud (VPC) and deploying a web server inside it using Terraform. It’s designed for beginners who want hands-on practice with AWS networking and infrastructure-as-code principles.

---

## 📘 Lab Overview

In this lab, you will:

- Create a basic VPC manually (without using the AWS VPC Wizard)
- Build subnets, route tables, and an Internet Gateway
- Configure networking to allow external traffic to a web server
- Launch a public EC2 instance running a simple web server

**Amazon Virtual Private Cloud (Amazon VPC)** lets you create a logically isolated network in the AWS Cloud, where you can launch AWS resources under your own defined network settings (IP ranges, subnets, route tables, etc.).

---

## ✅ Topics Covered

- Create an Amazon Virtual Private Cloud (VPC)
- Create a public subnet
- Create an Internet Gateway
- Create a Route Table and add a route to the internet
- Create a Security Group to allow HTTP traffic
- Launch an EC2 instance as a web server

---

## 📦 Prerequisites

Before starting, ensure you have:

- An AWS account with IAM permissions to create VPCs and EC2
- AWS CLI configured with your credentials
- Terraform installed on your system

---

## 🛠 Terraform Implementation

Save the following code into a file named `main.tf`:

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc_1" {
  cidr_block           = "10.0.0.0/24" # Provides 256 IP addresses
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC-1"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc_1.id
  cidr_block              = "10.0.0.0/28" # Provides 16 IP addresses
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
  ami                    = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
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
```

---

## 🚀 How to Deploy

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Preview the Changes

```bash
terraform plan
```

### 3. Apply the Configuration

```bash
terraform apply
```

Confirm with `yes` when prompted.

### 4. Access Your Web Server

Open a browser and go to:

```
http://<your-ec2-public-ip>
```

You should see: **Hello World, This is a WebServer**

---

## 🧹 Clean Up Resources

```bash
terraform destroy
```

---

## 📚 Appendix: Subnetting Basics

- VPC CIDR block: between `/16` and `/28`
- Subnet CIDR block: also between `/16` and `/28`
- AWS reserves the first 4 and last 1 IP addresses per subnet
- Use RFC 1918 private IP ranges:
  - `10.0.0.0/8`
  - `172.16.0.0/12`
  - `192.168.0.0/16`

---

## ✅ Summary

You’ve now successfully:

- Created a VPC manually with subnets and internet access
- Launched a public EC2 instance as a web server
- Used Terraform to define infrastructure as code

Happy building! ☁️🛠