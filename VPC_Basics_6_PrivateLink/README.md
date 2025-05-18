## 🔒 PrivateLink & VPC Endpoints Lab

This hands-on lab demonstrates how to securely access AWS services (like **S3** and **EC2 APIs**) from an **EC2 instance in a private subnet**, **without using a NAT Gateway or Internet Gateway**.

We’ll simulate both failure and success scenarios by testing connectivity:

* 🔴 When no VPC endpoints are configured (access fails)
* ✅ After adding the correct VPC **Interface** and **Gateway** Endpoints (access succeeds)
* ✅ Bonus: Use **SSM Interface Endpoint** to access private EC2 without SSH or bastion

---

### 🎯 Goal of This Lab

* Understand how VPC **interface endpoints** and **gateway endpoints** work
* See the behavior of a **private EC2 instance without internet**
* Learn to add **targeted access** to AWS APIs (like EC2 and S3) via PrivateLink
* Connect to a **private EC2 using SSM** — without public IP or NAT Gateway

---

### 🧠 What You’ll Learn

* How to configure **VPC endpoints** step by step via AWS Console
* How to **test access** to AWS services with and without PrivateLink
* How **gateway endpoints differ from interface endpoints**
* How to use **Session Manager** as a secure bastionless alternative

---

### 🧱 Architecture Overview

| Component      | Purpose                                                       |
|----------------|---------------------------------------------------------------|
| VPC            | Custom VPC for isolation                                      |
| Public Subnet  | Holds public EC2 (used for testing and SSH into private EC2)  |
| Private Subnet | Holds EC2 with no internet access (primary focus of this lab) |
| S3 Bucket      | Used to test access over Gateway Endpoint                     |
| EC2 Instances  | One in public subnet, one in private subnet                   |
| VPC Endpoints  | Interface endpoint for EC2 API, SSM; Gateway endpoint for S3  |
| IAM Roles      | Attach permissions for SSM and S3 to private EC2              |

---

### 📶 Architecture Diagram (1 AZ)

```text
        ┌───────────────────────────────────────────────────────────────────────┐
        │                            Public Internet                            │
        └───────────────────────────────────────────────────────────────────────┘
                 ▲                             │                       │
                 │                             │                       │
                 ▼                             ▼                       ▼
       ┌───────────────────┐        ┌───────────────────┐   ┌────────────────────┐
       │  Internet Gateway │        │     Amazon S3     │   │  EC2 API Endpoint  │
       └───────────────────┘        └───────────────────┘   └────────────────────┘
                 ▲                             ▲                       ▲
                 │                             │                       │ 
                 │                             ▼                       │
                 │                   ┌───────────────────┐             │
                 │                   │  AWS PrivateLink  │             │
                 │                   │  Gateway Endpoint │             │
                 │                   └───────────────────┘             │
                 │                             ▲                       │
                 │                             │                       │ 
                 ▼                             ▼                       ▼
       ┌───────────────────┐        ┌───────────────────┐   ┌────────────────────┐
       │    Route Table    │        │    Route Table    │   │  AWS PrivateLink   │
       │  (Public Subnet)  │        │  (Private Subnet) │   │ Interface Endpoint │
       └───────────────────┘        └───────────────────┘   └────────────────────┘
                 ▲                               ▲                  ▲
                 │                               │                  │
                 ▼                               ▼                  ▼
     ┌───────────────────────┐                ┌───────────────────────┐          
     │     Public Subnet     │                │     Private Subnet    │          
     │                       │                │                       │          
     │  ┌───────────────┐    │                │   ┌───────────────┐   │          
     │  │  EC2 Instance │    ───────────────────► │  EC2 Instance │   │
     │  │               │    │      SSH       │   │               │   │
     │  └───────────────┘    │                │   └───────────────┘   │
     └───────────────────────┘                └───────────────────────┘
     
```

---

## ✅ Step 1: Create VPC, Subnets, and S3 Bucket (AWS Console)

In this step, we’ll build the network foundation and the S3 bucket used for testing.

---

### 🧱 1.1 Create the VPC

1. Open the **AWS Console**
2. In the search bar, type **VPC**, and select **VPC Dashboard**
3. Click **Create VPC**
4. Choose **VPC only**
5. Configure:

   * **Name tag**: `Privatelink-Tutorial-VPC`
   * **IPv4 CIDR block**: `10.0.0.0/16`
   * Leave all other defaults (no IPv6, no DNS changes)
6. Click **Create VPC**

---

### 🌐 1.2 Create Subnets

We’ll create **two subnets in the same AZ**:

* A **Public Subnet** for bastion/testing
* A **Private Subnet** for endpoint testing

#### Public Subnet

1. In the **VPC Dashboard**, go to **Subnets**
2. Click **Create Subnet**
3. Configure:

   * **Name tag**: `privatelink-public-subnet`
   * **VPC**: `Privatelink-Tutorial-VPC`
   * **Availability Zone**: Choose one (e.g., `us-east-1a`)
   * **IPv4 CIDR block**: `10.0.1.0/24`
4. Click **Create subnet**

#### Private Subnet

Repeat the steps above with:

* **Name tag**: `privatelink-private-subnet`
* **CIDR block**: `10.0.2.0/24`

---

### 🌍 1.3 Create and Attach Internet Gateway

1. Go to **Internet Gateways** > **Create internet gateway**
2. Configure:

   * **Name tag**: `Privatelink-Tutorial-IGW`
3. Click **Create Internet Gateway**
4. Select the new IGW > **Actions > Attach to VPC**
5. Choose `Privatelink-Tutorial-VPC` and click **Attach**

---

### 🚦 1.4 Configure Route Tables

We’ll set up public routing for the public subnet only.

#### Public Route Table

1. Go to **Route Tables**
2. Click **Create route table**
3. Configure:

   * **Name tag**: `privatelink-public-rt`
   * **VPC**: `Privatelink-Tutorial-VPC`
4. Click **Create**
5. Select the route table > **Routes** > **Edit routes**
6. Add route:

   * **Destination**: `0.0.0.0/0`
   * **Target**: Select your **Internet Gateway**
7. Save changes
8. Go to **Subnet associations** > **Edit subnet associations**
9. Select `privatelink-public-subnet` and click **Save**

#### (No need for private route table changes yet — endpoints will route locally)

---

### 🪣 1.5 Create S3 Bucket for Testing

1. Open the **S3 Console**
2. Click **Create bucket**
3. Configure:

   * **Bucket name**: `privatelink-tutorial-bucket` (must be globally unique)
   * Region: same as your VPC (e.g., `us-east-1`)
4. Leave all other defaults (block public access enabled, versioning off)
5. Click **Create bucket**

---

✅ Done! You now have:

* A VPC with 1 public and 1 private subnet
* Public subnet routed via IGW
* S3 bucket for endpoint testing

---

## 🚀 Step 2: Launch EC2 Instances in Public and Private Subnets

We’ll launch **two EC2 instances** (Amazon Linux 2023), one in each subnet:

* The **public EC2** will act as a bastion/test client
* The **private EC2** will simulate a no-internet environment for endpoint testing

---

### 🔐 2.1 Create a Key Pair

If you don’t already have an SSH key pair:

1. Go to the **EC2 Dashboard**
2. In the left menu, click **Key Pairs**
3. Click **Create key pair**
4. Configure:

   * **Name**: `privatelink-ec2-key`
   * **Key pair type**: RSA
   * **Private key format**: `.pem`
5. Click **Create key pair** (your browser will download the `.pem` file)

✅ Keep this file safe — you’ll need it to SSH into the public instance.

---

### 🛡 2.2 Create a Security Group

We’ll allow SSH and HTTP for testing.

1. Go to **Security Groups**
2. Click **Create security group**
3. Configure:

   * **Name**: `privatelink-ec2-sg`
   * **VPC**: `Privatelink-Tutorial-VPC`
4. Under **Inbound Rules**, add:

   * Type: `SSH`, Source: `My IP`
   * Type: `HTTP`, Source: `0.0.0.0/0`
5. Leave **Outbound** as default (all traffic allowed)
6. Click **Create security group**

---

### 💻 2.3 Launch Public EC2 Instance

1. Go to **EC2 > Instances** > Click **Launch instance**
2. Configure:

   * **Name**: `public-ec2`
   * **AMI**: Amazon Linux 2023
   * **Instance type**: `t2.micro`
   * **Key pair**: Select `privatelink-ec2-key`
3. In **Network settings**:

   * VPC: `Privatelink-Tutorial-VPC`
   * Subnet: `privatelink-public-subnet`
   * Auto-assign public IP: **Enabled**
   * Security Group: Select `privatelink-ec2-sg`
4. Under **Advanced details**, paste the following User Data:

    ```bash
    #!/bin/bash
    dnf update -y
    dnf install -y awscli httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from PUBLIC EC2" > /var/www/html/index.html
    ```

5. Click **Launch instance**

---

### 🛑 2.4 Launch Private EC2 Instance

Repeat the same steps as above with the following changes:

* **Name**: `private-ec2`
* **Subnet**: `privatelink-private-subnet`
* **Auto-assign public IP**: **Disabled**
* **User Data**:

```bash
#!/bin/bash
dnf update -y
dnf install -y awscli httpd
systemctl start httpd
systemctl enable httpd
echo "Hello from PRIVATE EC2" > /var/www/html/index.html
```

✅ Launch it with the same security group and key pair.

---

💡 **Pro Tip: Use “Launch more like this” to Clone EC2 Config and save time**

Instead of manually configuring every EC2 setting twice, you can quickly launch a second instance based on the first:

1. Go to **EC2 → Instances**
2. Select your first instance (e.g., `public-ec2`)
3. Choose **Actions → Launch more like this**

This will pre-fill all the settings. Just update:

- **Name**: `private-ec2`
- **Subnet**: `privatelink-private-subnet`
- **Auto-assign public IP**: Disable
- **User Data**: Replace with private EC2 script

This approach reduces setup time and avoids misconfiguration.

---

### ✅ Step 2 Result

You now have:

| Instance      | Subnet                       | Public IP | Purpose         |
|---------------|------------------------------|-----------|-----------------|
| `public-ec2`  | `privatelink-public-subnet`  | ✅         | SSH & curl test |
| `private-ec2` | `privatelink-private-subnet` | ❌         | Endpoint test   |

Next, we'll **SSH into the public EC2**, try AWS CLI commands, and then **hop into the private EC2** to test how endpoints behave.


