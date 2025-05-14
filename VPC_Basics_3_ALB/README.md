# 🏗️ Amazon Application Load Balancer (ALB) Setup — VPC, EC2, and Load Balancing Lab

This lab guides you through creating a full-stack web architecture using Amazon VPC, subnets, NAT, EC2 instances, and an Application Load Balancer (ALB). You’ll first do it manually via the AWS Console, then replicate the architecture using Terraform.

---

## 🧠 Topics Covered

1. Create a custom VPC with public/private subnets
2. Set up Internet Gateway, NAT Gateway, and Route Tables
3. Deploy EC2 instances in private subnets
4. Create a Target Group and Application Load Balancer (ALB)
5. Test ALB functionality with EC2s behind it
6. Clean up all resources

---

## 🔧 Manual Steps (Console)

This step-by-step tutorial will guide you through creating an Application Load Balancer in AWS, perfect for beginners with no prior AWS experience.

## Table of Contents
1. [Before You Begin](#before-you-begin)
2. [Step 1: Create Your VPC](#step-1-create-your-vpc)
3. [Step 2: Set Up Subnets](#step-2-set-up-subnets)
4. [Step 3: Configure Internet Access](#step-3-configure-internet-access)
5. [Step 4: Launch Web Servers](#step-4-launch-web-servers)
6. [Step 5: Create Target Group](#step-5-create-target-group)
7. [Step 6: Deploy Load Balancer](#step-6-deploy-load-balancer)
8. [Step 7: Test Your Setup](#step-7-test-your-setup)
9. [Step 8: Clean Up](#step-8-clean-up)

## Before You Begin
- You'll need an AWS account (free tier is sufficient)
- Recommended browser: Chrome or Firefox
- Estimated time: 45-60 minutes
- All resources created qualify for AWS Free Tier

## Step 1: Create Your VPC

1. **Log in to AWS Console**: Go to https://aws.amazon.com/ and click "Sign In to the Console"
2. **Navigate to VPC Service**:
   - Click the "Services" dropdown at the top
   - Type "VPC" in the search box
   - Click "VPC" in the results

3. **Create VPC**:
   - Click "Your VPCs" in the left sidebar
   - Click "Create VPC" button
   - Configure these settings:
     - **Resources to create**: VPC only
     - **Name tag**: `ALB-Tutorial-VPC`
     - **IPv4 CIDR block**: `10.0.0.0/16` (this creates 65,536 IP addresses)
     - Leave all other settings as default
   - Click "Create VPC"

## Step 2: Set Up Subnets

### Create Public Subnets
1. In the VPC Dashboard, click "Subnets" in the left sidebar
2. Click "Create subnet"
   - **VPC ID**: Select `ALB-Tutorial-VPC`
   - **Subnet name**: `ALB-Public-Subnet-1`
   - **Availability Zone**: Select the first available zone (e.g., us-east-1a)
   - **IPv4 CIDR block**: `10.0.1.0/24`
   - Click "Create subnet"

3. Repeat to create second public subnet:
   - **Subnet name**: `ALB-Public-Subnet-2`
   - **Availability Zone**: Select a different zone (e.g., us-east-1b)
   - **IPv4 CIDR block**: `10.0.2.0/24`

### Create Private Subnets
1. Create first private subnet:
   - **Subnet name**: `ALB-Private-Subnet-1`
   - **Availability Zone**: Same as first public subnet (e.g., us-east-1a)
   - **IPv4 CIDR block**: `10.0.3.0/24`

2. Create second private subnet:
   - **Subnet name**: `ALB-Private-Subnet-2`
   - **Availability Zone**: Same as second public subnet (e.g., us-east-1b)
   - **IPv4 CIDR block**: `10.0.4.0/24`

## Step 3: Configure Internet Access

### Create Internet Gateway
1. In VPC Dashboard, click "Internet Gateways"
2. Click "Create internet gateway"
   - **Name tag**: `ALB-IGW`
   - Click "Create internet gateway"
3. Select the new IGW, click "Actions" > "Attach to VPC"
   - Select `ALB-Tutorial-VPC`
   - Click "Attach internet gateway"

### Configure Route Tables
1. **Public Route Table**:
   - Click "Route Tables"
   - Find the route table automatically created with your VPC
   - Click "Actions" > "Edit routes"
   - Add route:
     - **Destination**: `0.0.0.0/0`
     - **Target**: Select the Internet Gateway (`ALB-IGW`)
   - Click "Save changes"
   - Go to "Subnet associations" tab
   - Associate both public subnets

2. **Private Route Table**:
   - Create new route table:
     - **Name**: `ALB-Private-RT`
     - **VPC**: `ALB-Tutorial-VPC`
   - Edit routes and add:
     - **Destination**: `0.0.0.0/0`
     - **Target**: Will be NAT Gateway (created next)
   - Associate both private subnets

### Create NAT Gateway
1. Click "NAT Gateways" > "Create NAT Gateway"
   - **Name**: `ALB-NAT-GW`
   - **Subnet**: Select `ALB-Public-Subnet-1`
   - Click "Allocate Elastic IP"
   - Click "Create NAT Gateway"
2. Wait 2-3 minutes for status to change to "Available"
3. Go back to private route table and update the `0.0.0.0/0` route target to this NAT Gateway

## Step 4: Launch Web Servers

1. **Go to EC2 Dashboard**:
   - Click "Services" > Search "EC2" > Click "EC2"

2. **Launch First Instance**:
   - Click "Launch Instances"
   - **Name**: `Web-Server-1`
   - **AMI**: Amazon Linux 2023 AMI (free tier eligible)
   - **Instance type**: t2.micro (free tier eligible)
   - **Key pair**: Create new key pair named `alb-tutorial-key`
   - **Network settings**:
     - VPC: `ALB-Tutorial-VPC`
     - Subnet: `ALB-Private-Subnet-1`
     - Auto-assign Public IP: Disable
     - Security group: Create new security group named `Web-Server-SG`
       - Add rule: SSH (port 22) - My IP
       - Add rule: HTTP (port 80) - Anywhere
   - **Advanced Details**:
     - Paste this in User Data:
       ```bash
       #!/bin/bash
       yum update -y
       yum install -y httpd
       systemctl start httpd
       systemctl enable httpd
       echo "<html><body><h1>Hello from $(hostname -f)</h1></body></html>" > /var/www/html/index.html
       ```
   - Click "Launch Instance"

3. **Launch Second Instance**:
   - Repeat same steps but:
     - Name: `Web-Server-2`
     - Subnet: `ALB-Private-Subnet-2`
     - Use existing security group `Web-Server-SG`

## Step 5: Create Target Group

1. In EC2 Dashboard, click "Target Groups" under Load Balancing
2. Click "Create target group"
   - **Target type**: Instances
   - **Name**: `ALB-Target-Group`
   - **Protocol**: HTTP
   - **Port**: 80
   - **VPC**: `ALB-Tutorial-VPC`
   - Health checks: Leave defaults
3. Click "Next"
4. Select both web server instances
5. Click "Include as pending below"
6. Click "Create target group"

## Step 6: Deploy Load Balancer

1. In EC2 Dashboard, click "Load Balancers"
2. Click "Create Load Balancer"
   - Select "Application Load Balancer"
3. Configure:
   - **Name**: `ALB-Tutorial`
   - **Scheme**: Internet-facing
   - **IP address type**: IPv4
   - **VPC**: `ALB-Tutorial-VPC`
   - **Mappings**: Select both public subnets
4. Security groups:
   - Create new security group `ALB-SG`
   - Add rule: HTTP (port 80) - Anywhere
5. Listeners and routing:
   - Protocol: HTTP
   - Port: 80
   - Default action: Forward to `ALB-Target-Group`
6. Click "Create load balancer"

## Step 7: Test Your Setup

1. Wait 2-3 minutes for the ALB to become active
2. In Load Balancers section, select your ALB
3. Copy the DNS name (e.g., `ALB-Tutorial-1234567890.us-east-1.elb.amazonaws.com`)
4. Test using:
   - Web browser: Paste DNS name in address bar
   - Command line: Run `curl your-dns-name` multiple times
5. You should see responses alternating between your two web servers

## Step 8: Clean Up

To avoid ongoing charges, delete all resources:

1. **Delete Load Balancer**:
   - EC2 Dashboard > Load Balancers
   - Select ALB > Actions > Delete
   - Confirm deletion

2. **Delete Target Group**:
   - Target Groups > Select group > Actions > Delete

3. **Terminate EC2 Instances**:
   - Instances > Select both > Instance State > Terminate

4. **Delete NAT Gateway**:
   - VPC Dashboard > NAT Gateways
   - Select NAT GW > Actions > Delete
   - Confirm

5. **Delete VPC**:
   - VPC Dashboard > Your VPCs
   - Select your VPC > Actions > Delete VPC
   - Check all boxes to delete associated resources
   - Confirm

Congratulations! You've successfully created and tested an Application Load Balancer in AWS.

---

## 🧱 AWS ALB Terraform Deployment

**Overview**

This Terraform project deploys a highly available web application architecture on AWS with:
- Virtual Private Cloud (VPC) with public and private subnets
- NAT Gateway for outbound internet access from private subnets
- EC2 instances running Apache web server in private subnets
- Application Load Balancer (ALB) in public subnets
- Proper security groups restricting access

**Structure**
```bash
Terraform/
├── main.tf                 # Primary configuration (calls modules)
├── variables.tf            # Input variables for root module
├── outputs.tf              # Output values for root module
├── terraform.tfvars.example # Example variable values
├── .gitignore             # Files to exclude from version control
├── README.md              # Project documentation
│
└── modules/               # Reusable components
    ├── network/
    │   ├── main.tf        # VPC, subnets, routing
    │   ├── variables.tf   # Network module inputs
    │   └── outputs.tf     # Network module outputs
    ├── security_groups/
    │   ├── main.tf        # Security group definitions
    │   ├── variables.tf
    │   └── outputs.tf
    ├── web_servers/
    │   ├── main.tf        # EC2 instances configuration
    │   ├── variables.tf
    │   └── outputs.tf
    └── alb/
        ├── main.tf        # Load balancer resources
        ├── variables.tf
        └── outputs.tf
```
**Prerequisites:**

1. AWS Account: With programmatic access configured
2. AWS CLI: Installed and configured with credentials
3. Terraform: Version 1.3.0 or newer

**Deployment steps:**

1. Clone the repository.
2. Configure variables:

   - Copy terraform.tfvars.example to terraform.tfvars
   - Edit with your specific values:

    ```bash
    aws_region = "us-east-1"
    my_ip      = "your.public.ip"
    ```
3. Initialize Terraform:
    ```bash
    terraform init
    ```
4. Review execution plan:
    ```bash
    terraform plan
    ```
5. Deploy infrastructure:
    ```bash
    terraform apply
    ```
6. Access your application:

    - After deployment completes, Terraform will output the ALB DNS name
    - Open this URL in your web browser

**Accessing Web Servers**

Since instances are in private subnets:
 1. Recommended: Use AWS Systems Manager Session Manager
 2. Alternative: Set up a bastion host in a public subnet  

**Cleaning up:**
```bash
terraform destroy
```
**Troubleshooting**

    - ALB health checks failing: Verify web servers are running Apache

    - No internet access from instances: Check NAT Gateway configuration

    - SSH access issues: Verify your IP is correctly set in my_ip
---

## ✅ Summary

You've manually and programmatically built a production-grade load-balanced environment using:
- VPC and subnet architecture
- Public/private routing and NAT
- EC2-based web tier
- ALB with health checks and target group

This is a foundation for real-world scalable web apps.