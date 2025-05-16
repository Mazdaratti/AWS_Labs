# 🚀 AWS Network Load Balancer (NLB) Lab

## 🧠 Goal of the Lab

This lab is designed to help you understand and practice how to:

* Deploy an **AWS Network Load Balancer** (NLB)
* Distribute traffic across backend EC2 instances in **private subnets**
* Use **Elastic IPs** and **static targets** for high availability
* Implement a **simple web server** using **User Data**
* Expose private instances to the public internet via the NLB only
* Test and verify traffic forwarding

The initial setup is performed **manually through the AWS Console** to reinforce foundational understanding, and is later reimplemented using **Terraform Infrastructure as Code (IaC)** using reusable modules.

---

## 🏗️ What You Will Learn

* How to manually provision a **high-availability NLB**
* VPC/subnet design with **public and private zones**
* Why NAT Gateways are used for package installations from private EC2s
* How to assign **Elastic IPs** to ensure predictable entry points
* Use of **User Data scripts** for auto-installing web servers
* Testing with `curl` and public NLB DNS names

---

## 📦 Architecture Overview

### 🧰 Key Components

| Component                   | Purpose                                                |
|-----------------------------|--------------------------------------------------------|
| VPC                         | Isolated networking environment for the lab            |
| Public Subnets              | For NAT Gateway (egress) and NLB Elastic IPs           |
| Private Subnets             | Where web servers run (not internet-facing)            |
| NAT Gateway                 | Allows private EC2s to reach internet (for updates)    |
| Elastic IPs                 | Attached to the NLB to ensure fixed external IPs       |
| Network Load Balancer (NLB) | Distributes traffic to private EC2s at TCP level       |
| EC2 Instances               | Simple web servers running Apache (httpd)              |
| Security Groups             | Controls inbound (NLB → EC2) and SSH access (optional) |

---

## 📊 Architecture Diagram

```text
                            ┌────────────┐
                            │   Client   │
                            └─────┬──────┘
                                  │
      AZ-A               ┌────────▼─────────┐             AZ-B
         ┌───────────────│ Internet Gateway │──────────────┐             
         │               └────────┬─────────┘              │
         │                        │                        │
  ┌──────┴───────┐       ┌────────▼─────────┐     ┌────────┴──────┐
  │ Public Sub B │       │   Network Load   │     │ Public Sub B  │
  │ NAT Gateway  │       │     Balancer     │     │ NAT Gateway   │
  └──────▲───────┘       └────────┬─────────┘     └────────▲──────┘
         │                        │                        │
         │      ┌─────────────────┴─────────────────┐      │
         │      │                                   │      │
  ┌──────┴──────▼──┐                             ┌──▼──────┴──────┐
  │ Private Sub A  │                             │ Private Sub B  │
  │  EC2 Web App   │                             │  EC2 Web App   │
  └────────────────┘                             └────────────────┘
```

---

## 🔧 Manual Setup (AWS Console)

We'll now walk step-by-step through manual provisioning of each component in the AWS Console.

---

## 🔧 Step 1: Prepare Networking for the Network Load Balancer

This step walks you through setting up the foundational network infrastructure for your NLB architecture using the AWS Console. You will:

* Create a custom VPC
* Set up public and private subnets across two Availability Zones
* Attach an Internet Gateway
* Set up route tables for internet access

We'll use consistent and reusable names for all resources, which you'll later reference in Terraform.

---

### ✅ 1.1 Create the VPC

1. Go to the AWS Console → **Search: "VPC"** → Open the **VPC dashboard**
2. Choose **Create VPC**
3. Select **“VPC only”**
4. Enter the following values:

    | Field     | Value              |
    |-----------|--------------------|
    | Name tag  | `NLB-Tutorial-VPC` |
    | IPv4 CIDR | `10.0.0.0/16`      |
    | IPv6 CIDR | No IPv6 CIDR Block |
    | Tenancy   | Default            |

5. Click **Create VPC**

---

### ✅ 1.2 Create and Attach an Internet Gateway

1. In the VPC navigation pane, choose **Internet Gateways**
2. Click **Create Internet Gateway**
3. Name it: `NLB-Tutorial-VPC-IGW`
4. Click **Create Internet Gateway**
5. After creation, select it → **Actions > Attach to VPC**
6. Choose `NLB-Tutorial-VPC` and click **Attach**

---

### ✅ 1.3 Create Public Subnets

Create two public subnets in different Availability Zones:

#### Public Subnet 1

1. Go to **Subnets** → Click **Create Subnet**
2. VPC: `NLB-Tutorial-VPC`
3. Name: `NLB-Tutorial-Public-subnet1`
4. AZ: `us-east-1a`
5. CIDR block: `10.0.1.0/24`
6. Click **Create subnet**

#### Public Subnet 2

Repeat the above with:

* Name: `NLB-Tutorial-Public-subnet2`
* AZ: `us-east-1b`
* CIDR: `10.0.2.0/24`

> ℹ️ You do **not** need to enable public IP auto-assign — NAT Gateway and NLB will receive **Elastic IPs** explicitly.

---

### ✅ 1.4 Create Public Route Table and Associate Public Subnets

1. In the VPC console, go to **Route Tables**
2. Click **Create route table**
3. Name: `NLB-Tutorial-Public-RT`
4. VPC: `NLB-Tutorial-VPC`
5. Click **Create**

#### Add Internet Gateway Route

1. Select `NLB-Tutorial-Public-RT`
2. Go to **Routes > Edit routes**
3. Add new route:
   * Destination: `0.0.0.0/0`
   * Target: Select the Internet Gateway `NLB-Tutorial-VPC-IGW`
4. Click **Save changes**

#### Associate with Public Subnets

1. Under **Subnet associations > Edit subnet associations**
2. Select:
   * `NLB-Tutorial-Public-subnet1`
   * `NLB-Tutorial-Public-subnet2`
3. Click **Save associations**

---

### ✅ 1.5 Create Private Subnets

Repeat similar steps for private subnets:

#### Private Subnet 1

* Name: `NLB-Tutorial-Private-subnet1`
* AZ: `us-east-1a`
* CIDR: `10.0.3.0/24`

#### Private Subnet 2

* Name: `NLB-Tutorial-Private-subnet2`
* AZ: `us-east-1b`
* CIDR: `10.0.4.0/24`

---

✅ Your network foundation is now ready:

* 1 VPC with 4 subnets (2 public, 2 private)
* Public subnets are internet-routable
* Private subnets are isolated for backend EC2s

---

## 🔧 Step 2: Set Up NAT Gateway and Private Route Table

In this step, you will:

* Create a NAT Gateway to provide **outbound internet access** for EC2 instances in private subnets
* Allocate and associate an **Elastic IP** to it
* Create a private route table and associate it with the **private subnets**
* Route traffic from private subnets through the NAT Gateway

---

### ✅ 2.1 Create a NAT Gateway

1. Go to **VPC Dashboard** → In the left pane, choose **NAT Gateways**
2. Click **Create NAT Gateway**
3. Fill in the details:

   | Field             | Value                         |
   |-------------------|-------------------------------|
   | Name              | `NLB-Tutorial-NATGW`          |
   | Subnet            | `NLB-Tutorial-Public-subnet1` |
   | Connectivity Type | Public (default)              |
   | Elastic IP        | Click **Allocate Elastic IP** |

4. Click **Create NAT Gateway**

> ✅ NAT Gateways require a public subnet and an Elastic IP. This NAT Gateway will allow EC2 instances in private subnets to install packages and update themselves.

---

### ✅ 2.2 Create a Private Route Table

1. In the **VPC Console**, go to **Route Tables**
2. Click **Create route table**
3. Use the following values:

   | Field    | Value                     |
   |----------|---------------------------|
   | Name tag | `NLB-Tutorial-Private-RT` |
   | VPC      | `NLB-Tutorial-VPC`        |

4. Click **Create route table**

---

### ✅ 2.3 Add Default Route to NAT Gateway

1. Select `NLB-Tutorial-Private-RT`
2. Go to the **Routes** tab → Click **Edit routes**
3. Add a route:

   | Destination | Target                                      |
   |-------------|---------------------------------------------|
   | `0.0.0.0/0` | `NLB-Tutorial-NATGW` (select from dropdown) |

4. Click **Save changes**

---

### ✅ 2.4 Associate Private Subnets to the Private Route Table

1. Go to the **Subnet associations** tab for `NLB-Tutorial-Private-RT`
2. Click **Edit subnet associations**
3. Select:
   * `NLB-Tutorial-Private-subnet1`
   * `NLB-Tutorial-Private-subnet2`
4. Click **Save associations**

---

✅ At this point, EC2 instances in the private subnets can access the internet (e.g., to `dnf install httpd`) via the NAT Gateway.

---

## 🔧 Step 3: Launch EC2 Instances in Private Subnets (Web Tier)

In this step, you will:

* Launch **two Amazon Linux 2023 EC2 instances** in **private subnets**
* Use a **User Data script** to install and configure the Apache web server
* Create and apply a **Security Group** allowing HTTP (port 80) and SSH (restricted to your IP)
* Create a **Key Pair** for future SSH access (optional but recommended)

---

### ✅ 3.1 Launch EC2 Instance #1 in Private Subnet

1. Go to **EC2 Console** → Click **Launch Instance**
2. Set these values:

   | Field                 | Value                                |
   |-----------------------|--------------------------------------|
   | Name                  | `NLB-Tutorial-EC2-1`                 |
   | AMI                   | **Amazon Linux 2023 AMI**            |
   | Instance Type         | `t2.micro` (free tier)               |
   | Key Pair              | Create new or use existing (see 3.4) |
   | Network               | `NLB-Tutorial-VPC`                   |
   | Subnet                | `NLB-Tutorial-Private-subnet1`       |
   | Auto-assign Public IP | Disabled (grayed out by default)     |

3. Scroll down to **Advanced Details** → Expand **User Data**
4. Paste the following script:

```bash
#!/bin/bash
# Update the system
dnf update -y

# Install Apache (httpd)
dnf install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create simple web page
echo "Hello from $(hostname -f)" > /var/www/html/index.html

# Adjust permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html
```

5. Leave storage as default → Click **Next: Add Tags**, then **Next: Configure Security Group**

---

### ✅ 3.2 Create a Security Group for EC2 Instances

1. Name: `NLB-Tutorial-EC2-SG`
2. Description: `Allow HTTP for NLB + restricted SSH`
3. Inbound Rules:

   | Type | Protocol | Port | Source              |
   |------|----------|------|---------------------|
   | HTTP | TCP      | 80   | `0.0.0.0/0`         |
   | SSH  | TCP      | 22   | `My IP` (auto-fill) |

    > 💡 Only the NLB will send traffic on port 80. SSH is only for manual inspection.

4. Click **Review and Launch** → **Launch**

---

### ✅ 3.3 Launch EC2 Instance #2 in Second Private Subnet

1. Repeat steps for **EC2 instance #2** with the following changes:

    | Field          | Value                          |
    |----------------|--------------------------------|
    | Name           | `NLB-Tutorial-EC2-2`           |
    | Subnet         | `NLB-Tutorial-Private-subnet2` |
    | Key Pair       | Same as used above             |
    | Security Group | `NLB-Tutorial-EC2-SG`          |

2. Use the **same User Data script** for both instances.

---

### ✅ 3.4 (Optional) Create EC2 Key Pair

If you didn’t already:

1. In the EC2 dashboard, go to **Key Pairs > Create Key Pair**
2. Name: `NLB-Tutorial-Key`
3. Format: `.pem` (for Linux/macOS) or `.ppk` (for PuTTY on Windows)
4. Download and **save it securely**

---

✅ You now have two EC2 instances in private subnets with Apache running, ready to serve traffic through the NLB.

---

## 🔧 Step 4: Create Target Group and Register EC2 Instances

In this step, you will:

* Create a **Target Group** configured for TCP on port 80
* Register your **two private EC2 instances** as targets
* Prepare for traffic forwarding from the NLB

---

### ✅ 4.1 Create Target Group

1. In the AWS Console, search for **EC2** and open the EC2 Dashboard
2. In the left navigation, scroll to **Load Balancing** → Choose **Target Groups**
3. Click **Create target group**
4. Fill in the details:

   | Field                  | Value                           |
   |------------------------|---------------------------------|
   | Target type            | `Instances`                     |
   | Target group name      | `NLB-Tutorial-Target-Group`     |
   | Protocol               | `TCP`                           |
   | Port                   | `80`                            |
   | VPC                    | `NLB-Tutorial-VPC`              |
   | Health checks protocol | `TCP` (default is fine for now) |

5. Click **Next**

---

### ✅ 4.2 Register EC2 Targets

1. Select your two EC2 instances:
   * `NLB-Tutorial-EC2-1`
   * `NLB-Tutorial-EC2-2`
2. Click **Include as pending below**
3. Confirm the targets are listed under **Pending**
4. Click **Create target group**

> ✅ You now have a TCP target group with both EC2s registered. The NLB will later use this to route traffic.

🧠 **Tip:** Health checks will automatically begin. They may take a couple of minutes to show "healthy" depending on your setup.

---

✅ Target group is ready!

---

## 🔧 Step 5: Create the Network Load Balancer

In this step, you will create a **Network Load Balancer (NLB)** that distributes TCP traffic to your EC2 web servers in private subnets. You'll also attach a **security group**, select subnets in multiple Availability Zones, and forward traffic to the **existing target group**.

---

### ✅ 5.1 Open the Load Balancer Wizard

1. Go to the **EC2 Console**
2. In the left navigation pane, under **Load Balancing**, select **Load Balancers**
3. Click **Create Load Balancer**
4. Under **Network Load Balancer**, click **Create**

---

### ✅ 5.2 Step 1 – Basic Configuration

| Field           | Value              |
|-----------------|--------------------|
| Name            | `NLB-Tutorial`     |
| Scheme          | `Internet-facing`  |
| IP address type | `IPv4`             |
| VPC             | `NLB-Tutorial-VPC` |

---

### ✅ 5.3 Step 2 – Network Mapping

1. Under **Availability Zones**, select:

| Availability Zone | Subnet Name                   |
|-------------------|-------------------------------|
| `us-east-1a`      | `NLB-Tutorial-Public-subnet1` |
| `us-east-1b`      | `NLB-Tutorial-Public-subnet2` |

> ✅ These public subnets will allow your NLB to receive traffic from the internet.

---

### ✅ 5.4 Step 3 – Security Groups

1. Select **Create new security group**
2. Name it: **NLB-Tutorial-NLB-SG**

    > This security group should allow public traffic on TCP port 80:

3. Add an inbound rule for:

| Type | Protocol | Port | Source      |
|------|----------|------|-------------|
| TCP  | TCP      | 80   | `0.0.0.0/0` |

---

### ✅ 5.5 Step 4 – Listeners and Routing

1. Protocol: `TCP`
2. Port: `80`
3. **Forward to:**

   * Choose **existing target group**
   * Select: `NLB-Tutorial-Target-Group` we have created in Step 4.

---

### ✅ 5.6 Step 5 – Review and Create

1. Review all configuration settings
2. Confirm selected subnets, security group, and target group
3. Click **Create Load Balancer**

You will be redirected to the Load Balancers dashboard.

---

### ✅ 5.7 Enable Cross-Zone Load Balancing

1. In **EC2 Console > Load Balancers**, select `NLB-Tutorial`
2. Go to the **Description** tab
3. Click **Edit attributes**
4. Enable **Cross-zone load balancing**
5. Click **Save**

> This ensures the NLB can send traffic to instances in either AZ, regardless of which subnet receives the request.

---

### ✅ 5.8 (Optional) Assign Static Elastic IPs

To assign Elastic IPs to the NLB’s network interfaces:

1. Go to **EC2 Console > Network Interfaces**
2. Filter:

   * **Type**: `network load balancer`
   * **VPC**: `NLB-Tutorial-VPC`
3. For each ENI:

   * Click **Actions > Manage IP addresses**
   * Click **Assign new IP**
   * Choose **Allocate Elastic IP**
   * Click **Save**

This step is optional, but recommended if you want fixed public IPs for firewall rules or DNS records.

---

✅ Your Network Load Balancer is now ready and forwarding traffic to EC2 instances in private subnets.

---

## 🔧 Step 6: Test the Network Load Balancer

In this final step, you’ll verify that the NLB is distributing traffic to your EC2 instances as expected.

---

### ✅ 6.1 Get the NLB DNS Name

1. In the AWS Console, go to **EC2 > Load Balancers**
2. Select your load balancer `NLB-Tutorial`
3. Under the **Description** tab, find the **DNS name**
4. Copy the DNS name (something like `nlb-tutorial-xxxxxxxx.elb.amazonaws.com`)

---

### ✅ 6.2 Test Using curl

From your terminal (local machine or any machine with internet access), run:

```bash
curl http://<NLB-DNS-NAME>
```

Example:

```bash
curl http://nlb-tutorial-xxxxxxxx.elb.amazonaws.com
```

---

### ✅ 6.3 Repeat to See Load Balancing in Action

Run the curl command multiple times. You should see:

* Different responses from each EC2 instance (because each serves a page with its hostname)
* Output like:
  `Hello from ip-10-0-3-12.ec2.internal`
  `Hello from ip-10-0-4-15.ec2.internal`

---

## 🔒 Optional Step: Restrict EC2 Security Group to Accept Traffic Only from NLB

For better security, instead of allowing HTTP (port 80) from anywhere (`0.0.0.0/0`), you can restrict it to accept traffic **only from the Network Load Balancer’s security group**.

This reduces exposure of your backend EC2 instances by ensuring only the NLB can send HTTP traffic to them.

---

### How to update the EC2 security group:

1. Go to **EC2 Console > Security Groups**
2. Select the security group used by your EC2 instances (e.g., `NLB-Tutorial-EC2-SG`)
3. Edit **Inbound Rules** for HTTP (TCP port 80)
4. Change **Source** from `0.0.0.0/0` to **Custom** and enter the **NLB security group ID** (e.g., `sg-xxxxxxxx`)
5. Save the changes

---

### Important Notes:

* Make sure your NLB was created with a security group (e.g., `NLB-Tutorial-NLB-SG`) and note its ID.
* This setup assumes the NLB is the only authorized source of HTTP traffic to your EC2 instances.
* You can keep the SSH rule (`port 22`) as-is or restrict it similarly if you are planning to use bastion or SSM.

---

### Result:

| Before                          | After                                      |
|---------------------------------|--------------------------------------------|
| HTTP (port 80) from `0.0.0.0/0` | HTTP (port 80) from `sg-xxxxxxxx` (NLB SG) |

This improves your network security posture without impacting functionality.

---

### ✅ 7 Cleanup

When done, remember to terminate your EC2 instances, delete the NAT Gateway, NLB, target group, elastic ips and other resources to avoid ongoing charges.

---

Congrats! You’ve successfully deployed and tested an **internet-facing Network Load Balancer** routing TCP traffic to EC2 web servers in private subnets.

---

Great, Andrey — let’s begin with the Terraform layout and module structure for your **Network Load Balancer (NLB) Lab**.

Below is the section you can directly add to your `README.md` under the **Terraform Implementation** part:

---

## 🧱 Terraform Project Structure – NLB Lab

This Terraform project mirrors the manual setup of a **Network Load Balancer architecture** with private EC2 instances. It follows **modular best practices**, promoting reuse and maintainability.

---

### 📁 Project Directory Layout

```bash
Terraform/
├── main.tf                      # Root module: orchestrates all submodules
├── variables.tf                 # Input variables for the root module
├── outputs.tf                   # Outputs from root module
├── data.tf                      # Dynamic values (AZs, AMI)
├── terraform.tfvars.example     # Example variable values
├── README.md                    # Project documentation
│
└── modules/                     # Reusable infrastructure components
    ├── vpc/
    │   ├── main.tf              # VPC + public/private subnets + IGW
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── nat_gateway/
    │   ├── main.tf              # NAT Gateway + EIP + route table
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2_instances/
    │   ├── main.tf              # EC2s in private subnets with Apache + user_data
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security_groups/
    │   ├── main.tf              # SGs for EC2 and NLB
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── nlb/
        ├── main.tf              # Network Load Balancer + target group + listener
        ├── variables.tf
        └── outputs.tf
```

---

### 📂 Root Module (Orchestration)

The root module is responsible for:

* Calling all submodules in the correct order
* Supplying input variables (via `terraform.tfvars`)
* Fetching dynamic data (AZs, latest AMI) using `data.tf`
* Managing outputs

---




