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

| Component      | Purpose                                                                  |
|----------------|--------------------------------------------------------------------------|
| VPC            | Custom VPC for isolation                                                 |
| Public Subnet  | Holds public EC2 (used for testing and SSH into private EC2)             |
| Private Subnet | Holds EC2 with no internet access (primary focus of this lab)            |
| S3 Bucket      | Used to test access over Gateway Endpoint                                |
| EC2 Instances  | One in public subnet, one in private subnet                              |
| VPC Endpoints  | Interface endpoint for EC2 API, SSM (terraform); Gateway endpoint for S3 |
| IAM Roles      | Attach permissions for SSM and S3 to private EC2                         |

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

## 📦 Step 1.5: Create an S3 Bucket for Testing

To test `aws s3` CLI from your EC2 instances, we’ll create a simple public S3 bucket.

> 🔄 Later in the Terraform section, we’ll use a **secure setup** with a **private bucket** and VPC endpoint policies.

---

### 🧰 Create the Bucket

1. Go to the **S3 Console**

2. Click **Create bucket**

3. Configure:

   * **Bucket name**: `privatelink-lab-bucket` (or your custom name)
   * **Region**: Same as your VPC (e.g., `us-east-1`)

4. Under **Block Public Access**:

   * 🔓 **Uncheck**: “Block all public access”
   * Confirm the warning checkbox

5. Click **Create bucket**

---

### 🔐 Attach a Simple Public Bucket Policy

After creating the bucket:

1. Go to **Permissions** tab
2. Under **Bucket Policy**, paste the following:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowPublicReadWrite",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::privatelink-lab-bucket",
        "arn:aws:s3:::privatelink-lab-bucket/*"
      ]
    }
  ]
}
```

> Replace `privatelink-lab-bucket` with your actual bucket name if different.

✅ This allows both **public** and **private** EC2 instances to access the bucket without needing IAM roles or VPC endpoint policies.

---

### 💡 Pro Tip: This Is Not Secure for Real-World Use

We’re making the bucket public **only for learning purposes**.

In production, you should:

* ✅ Keep the bucket **private**
* ✅ Assign **IAM roles** to EC2 instances
* ✅ Restrict bucket access using:

  * `aws:SourceVpce` (to only allow traffic via your VPC endpoint)
  * IAM conditions like `aws:SourceArn` or `aws:SourceAccount`

We’ll implement all of this securely in the **Terraform section** of this lab.

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

---

## 🧪 Step 3: Connectivity Testing Before VPC Endpoints

In this step, we'll verify which operations succeed and fail **before** we configure any VPC endpoints.

We will:

1. SSH into the **public EC2** using your key and SSH agent forwarding
2. Test:

   * Internet access from **public** and **private** EC2
   * AWS CLI calls (`aws s3 ls`, etc.)
3. Confirm that private EC2 **cannot** access public internet or AWS APIs (yet)

---

### 🔑 3.1 SSH into Public EC2 (with Key + Agent Forwarding)

To connect securely and later hop into the private EC2, use this **combined SSH command**:

```bash
ssh -A -i /path/to/privatelink-ec2-key.pem ec2-user@<public-ec2-public-ip>
```

**Explanation:**

* `-i`: Authenticates to public EC2 using your `.pem` key
* `-A`: Enables **agent forwarding**, allowing you to SSH into private EC2 without copying the key

✅ Result: You’re now inside `public-ec2` with secure credentials forwarded.

---

### 🌍 3.2 Test Internet + AWS CLI from Public EC2

From inside the `public-ec2`:

```bash
curl http://example.com
```

✅ This should work — proving it has internet via the Internet Gateway.

Then try:

```bash
aws s3 ls
aws ec2 describe-instances --region <your-region>
```

✅ These also work — the CLI uses the public internet to reach AWS APIs.

> 🔎 If you see `Unable to locate credentials`, that's fine for now — we'll assign IAM roles in the next step.

---

### 🔁 3.3 SSH from Public EC2 into Private EC2

1. From your AWS Console, get the **private IP** of `private-ec2`
2. From inside the **public EC2 terminal**, run:

```bash
ssh ec2-user@<private-ec2-private-ip>
```

✅ Because your local key was forwarded, you’ll connect without needing to upload the `.pem` file.

> 💡 This works only because we used `-A` earlier. Your local machine handles key verification behind the scenes.

---

### 🔍 3.4 Test Internet + AWS CLI from Private EC2

Now inside the **private EC2**:

```bash
curl http://example.com
```

❌ This will **fail** — there’s no Internet Gateway or NAT Gateway.

Now try AWS CLI:

```bash
aws s3 ls
aws ec2 describe-instances --region <your-region>
```

❌ These also fail — there are **no VPC endpoints** to reach AWS services.

---

### ✅ Step 3: Result Summary

| Test                         | Public EC2  | Private EC2                |
|------------------------------|-------------|----------------------------|
| `curl http://example.com`    | ✅           | ❌                          |
| `aws s3 ls`                  | ✅           | ❌                          |
| `aws ec2 describe-instances` | ✅           | ❌                          |
| SSH access                   | ✅ (from PC) | ✅ (via public EC2 + agent) |

---

### 💡 Pro Tip: What is SSH Agent Forwarding?

**Agent forwarding** allows you to authenticate through a bastion (public EC2) into private EC2s **without uploading your key**.

* `-A` forwards your local SSH agent into the first EC2
* When you SSH to a second EC2, your local machine handles the key verification
* No need to copy `.pem` files — more secure and cleaner

✅ Perfect for test labs and jump-box-based access.

---

## 🔐 Step 4 (Optional for Console Setup): Assign IAM Role for Secure Access

In a real-world scenario, your EC2 instances should **never rely on public S3 buckets** or embedded access keys.

Instead, you attach an **IAM role** to give them secure, scoped permissions.

---

### ⚠️ In This Lab (Console Setup)

- We’re using a **public S3 bucket** for simplicity
- That means IAM roles are **not required** to access the bucket or run `aws s3` commands
- You can **skip this step for now**

---

### 🔐 In Production / Terraform Section

We’ll assign IAM roles like:
- `AmazonS3FullAccess`
- `AmazonEC2ReadOnlyAccess`

To allow:
- Access to private S3 buckets
- Communication with EC2 and SSM APIs through **VPC interface endpoints**
- No need to store AWS credentials on the instance

---

💡 **Pro Tip: IAM Role vs Public Bucket**

| Use Case            | Public S3 Bucket | Private S3 + IAM Role |
|---------------------|------------------|-----------------------|
| Easy testing (lab)  | ✅                | ❌                     |
| Secure environments | ❌                | ✅                     |
| Terraform version   | ❌                | ✅                     |

---

## 🌐 Step 5: Create EC2 API Interface Endpoint (PrivateLink)

To allow your **private EC2 instance** (with no internet access) to interact with **Amazon EC2 APIs** — like `describe-instances`, `start-instances`, etc. — we need to create an **Interface Endpoint** via AWS **PrivateLink**.

This enables secure, private communication with AWS services **over the VPC** without traversing the public internet.

---

### 🧰 Create the EC2 Interface Endpoint

1. Go to the **VPC Console**
2. In the left navigation pane, choose **Endpoints**
3. Click **Create endpoint**
4. Configure the following:

   #### 📌 Settings

   | Setting              | Value                            |
   |----------------------|----------------------------------|
   | **Service category** | AWS services                     |
   | **Service name**     | `com.amazonaws.<region>.ec2`     |
   | **VPC**              | `privatelink-lab-vpc` (your VPC) |

   #### 📍 Subnet selection

   * Select the **private subnet** created earlier

   #### 🔐 Security group

   * Select the **default SG** or create one that allows HTTPS (TCP port 443) inbound and outbound
     *(Don’t worry, it’s automatically locked to AWS service traffic)*

5. Click **Create endpoint**

---

### 🧠 What Just Happened?

You created an **Interface VPC Endpoint** — this means:

* Your **private EC2** can now access EC2 APIs like `describe-instances`
* **No public IP** or internet route is needed
* Requests stay inside the **AWS network**

---

## 🧪 Step 6: Verify EC2 API Access from Private EC2 (via PrivateLink)

Now that your **EC2 Interface Endpoint** is in place, let’s confirm it works.

---

### 🧭 Steps

1. From your **public EC2**, SSH into the **private EC2** (as you did in Step 3):

   ```bash
   ssh ec2-user@<PRIVATE_EC2_PRIVATE_IP>
   ```

2. On the private EC2, run the following:

   ```bash
   aws ec2 describe-instances --region <your-region>
   ```

---

### ✅ Expected Result

You should see a JSON response listing EC2 instance metadata.

This confirms:

* ✅ The request stayed within your **VPC**
* ✅ It went through the **interface endpoint** — not the internet
* ✅ You do **not** need a public IP, NAT, or IGW

---

Awesome! Here's your next section for the `README.md`, written in the same clear, beginner-friendly style:

---

## 🚪 Step 7: Create Gateway Endpoint for S3 (PrivateLink)

Now we’ll allow your **private EC2** to communicate with **Amazon S3** — without going through the internet — by creating a **VPC Gateway Endpoint** for S3.

This allows your EC2 instance to upload, list, and download files from the bucket **privately**, through the AWS network.

---

### 🧰 Create the Gateway Endpoint for S3

1. Open the **VPC Console**
2. In the left navigation, click **Endpoints**
3. Click **Create Endpoint**
4. Fill out the following fields:

   #### 📌 Settings

   | Setting              | Value                            |
   |----------------------|----------------------------------|
   | **Service category** | AWS services                     |
   | **Service name**     | `com.amazonaws.<region>.s3`      |
   | **VPC**              | `privatelink-lab-vpc` (your VPC) |

   #### 📍 Route table selection

   * Select the **route table for the private subnet**
     (You created it earlier — named like `privatelink-lab-private-rt`)

5. Leave **Policy** set to: `Full access`
6. Click **Create endpoint**

---

### 🔎 What This Does

When you created the endpoint for EC2 in Step 5, it was an **Interface Endpoint** — which creates a special network interface (ENI) inside your subnet to privately reach an AWS API (like EC2).

But **this time**, we’re creating a **Gateway Endpoint** — which works a bit differently:

| Type of Endpoint       | Used For                       | How It Works                                                                                         |
|------------------------|--------------------------------|------------------------------------------------------------------------------------------------------|
| **Interface Endpoint** | Services like EC2, SSM         | Adds a special ENI inside your subnet for private connections                                        |
| **Gateway Endpoint**   | Services like **S3**, DynamoDB | Adds a **route** to your route table — so traffic to S3 goes directly through AWS’s internal network |

✅ You won’t see a new network interface for S3. Instead, AWS automatically updates the **route table** to send all S3 traffic **privately through AWS**, instead of out to the internet.

---

## 🧪 Step 8: Upload and List Files from Private EC2 to S3

Now that your **Gateway Endpoint for S3** is in place, let’s test whether your **private EC2 instance** can access the S3 bucket — without using the internet.

---

### 🧭 Steps to Validate

1. **SSH into the private EC2 instance** (via the public EC2 as a bastion, like before)):

   ```bash
   ssh ec2-user@<PRIVATE_EC2_PRIVATE_IP>
   ```

2. **Run the following commands** to interact with S3:

   #### 🔍 Check bucket access:

   ```bash
   aws s3 ls s3://privatelink-lab-bucket
   ```

   #### 📤 Upload a test file:

   ```bash
   echo "Hello from private EC2" > testfile.txt
   aws s3 cp testfile.txt s3://privatelink-lab-bucket/
   ```

   #### 📥 Confirm it uploaded from the CLI:

   ```bash
   aws s3 ls s3://privatelink-lab-bucket/
   ```

3. **🧾 Final validation — go to the S3 bucket in the AWS Console**:

   * Open the **AWS Console**
   * Navigate to **S3 > privatelink-lab-bucket**
   * Confirm that `testfile.txt` is listed in the bucket

---

### ✅ Expected Result

You should see:

* ✅ `testfile.txt` appears both in the **CLI output** and in the **S3 Console**
* ✅ No internet access was needed from the private EC2
* ✅ The S3 bucket was accessed via the **Gateway Endpoint**

This confirms:

* The private EC2 can **securely access S3 over the AWS network**
* No **NAT Gateway**, **Internet Gateway**, or **public IP** is required

---

Thanks for catching that — you're absolutely right.

We **didn't create a NAT Gateway**; instead, we deployed a **VPC Interface Endpoint for EC2 Systems Manager (SSM and related services)** to allow access from the **private EC2** without requiring internet.

Here's the **corrected and finalized clean-up section** that reflects your actual architecture:

---

## 🧹 Step 9: Clean-Up Resources

Once you're done validating the architecture, it's important to delete all AWS resources you provisioned manually to avoid ongoing charges.

---

### 🧭 Clean-Up Checklist 

#### ✅ EC2 Instances and Key Pair:

1. **Terminate EC2 instances**:

   * Go to **EC2 > Instances**
   * Select both the **public** and **private** EC2 instances
   * Click **Instance State > Terminate**

2. **Delete Key Pair** (if manually created):

   * Go to **EC2 > Key Pairs**
   * Delete the key used for SSH access

#### ✅ Security Groups:

* Go to **EC2 > Security Groups**
* Delete the custom security groups used for public/private EC2 and endpoints

#### ✅ VPC and Networking:

1. **Delete Subnets**:

   * Go to **VPC > Subnets**
   * Delete the **public** and **private** subnets

2. **Delete Route Tables** (custom only):

   * Go to **VPC > Route Tables**
   * Delete any custom route tables

3. **Delete Internet Gateway**:

   * Go to **VPC > Internet Gateways**
   * Detach and delete the IGW (if created)

4. **Delete the VPC Endpoints**:

   * Go to **VPC > Endpoints**
   * Delete:

     * The **Gateway Endpoint** for S3
     * The **Interface Endpoints** for SSM, EC2 Messages, SSM Messages, etc.

5. **Delete the VPC**:

   * Go to **VPC > Your VPCs**
   * Delete the custom VPC created for the lab

#### ✅ S3 Bucket:

* Go to **S3 > privatelink-lab-bucket**
* Empty the bucket
* Then delete the bucket

---

### ⚠️ Final Check

Ensure that:

* No EC2 instances are still running
* No Interface or Gateway Endpoints remain
* No Elastic IPs are allocated
* The custom VPC and all subcomponents are removed

---

## 🌩️ Terraform Deployment: PrivateLink Lab

### 🔒 **What You’ll Automate**  
This Terraform project demonstrates **AWS PrivateLink** to securely access AWS services (S3, SSM) from isolated EC2 instances without using the public internet by creating:  
- A **private EC2 instance** (no public IP)  
- **VPC endpoints** for SSM (Interface) and S3 (Gateway)  
- A **private S3 bucket** accessible only via the endpoint  

---

### 📂 **Directory Structure**  
```text  
Terraform/
├── main.tf                      # Root module: orchestrates all submodules
├── variables.tf                 # Input variables for the root module
├── outputs.tf                   # Outputs (e.g., SSM access command)
├── data.tf                      # Dynamic values (AZs, AMI)
├── terraform.tfvars.example     # Example variable values
├── README.md                    # Lab instructions (matches console and terraform versions)
│
└── modules/                     # Reusable infrastructure components
    ├── vpc/
    │   ├── main.tf              # VPC + isolated private subnet
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── endpoints/
    │   ├── main.tf              # Critical VPC endpoints: Interface (SSM) + Gateway (S3) endpoints
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2_ssm/
    │   ├── main.tf              # Private EC2 with IAM roles for SSM/S3
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security_groups/
    │   ├── main.tf              # SGs for EC2 and endpoints
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── s3/
        ├── main.tf              # Private S3 bucket with VPC endpoint policy
        ├── variables.tf
        └── outputs.tf
```
---

### 🧱 **Core Components**  

#### 1. **VPC Endpoints (PrivateLink)**  
| Endpoint Type | Service                      | Purpose                            |  
|---------------|------------------------------|------------------------------------|  
| **Interface** | `com.amazonaws.<region>.ssm` | Allows SSM sessions to private EC2 |  
| **Gateway**   | `com.amazonaws.<region>.s3`  | Private S3 access without internet |  

> 🔍 **Why Only SSM (Not EC2 API)?**  
> - **SSM is sufficient**: It handles both management *and* CLI access via `start-session`  
> - **Reduced complexity**: EC2 API endpoint isn’t needed just to manage the instance  
> - **Cost optimization**: Fewer endpoints = lower cost  
> - **Best practice**: SSM is the recommended way to manage EC2 in private networks

#### 2. **Private EC2 Instance**  
- **No SSH/key pair**: Uses IAM role `AmazonSSMManagedInstanceCore`  
- **User Data**: Simple web server to test connectivity  

#### 3. **Locked-Down S3 Bucket**  
- **Accessible only via VPC endpoint** (enforced by bucket policy)  
- **Test file auto-uploaded** during deployment  

---

### 📂 Module Breakdown (PrivateLink Focused)

#### 1. **vpc/** (Simplified)
```hcl
# Purpose: Isolated private network for SSM access only
resources:
  - VPC (10.0.0.0/16)
  - Private subnet (10.0.1.0/24) with local route table
  - No Internet Gateway or public subnets
outputs:
  - vpc_id
  - private_subnet_id
```

#### 2. **security_groups/** (SSM-Optimized)
```hcl
# Purpose: Minimal access for SSM and endpoints
resources:
  - Private EC2 SG:
    • HTTPS to SSM endpoints
    • No inbound SSH (SSM replaces bastion)
  - Endpoint SG:
    • HTTPS from private subnet CIDR
outputs:
  - private_ec2_sg_id
  - endpoint_sg_id
```

#### 3. **ec2_ssm/** (SSM Only)
```hcl
# Purpose: Private instance with zero SSH access
resources:
  - EC2 Instance:
    • amazon-linux-2023 AMI
    • No public IP or key pair
    • IAM role:
      - AmazonSSMManagedInstanceCore
      - AmazonS3FullAccess (for upload testing)
    • user_data: Simple Apache web server (serves index.html used in upload test)
outputs:
  - instance_id
  - instance_private_ip
```

#### 4. **endpoints/** (PrivateLink Core)
```hcl
# Purpose: Enable private AWS API access
resources:
  - SSM Interface Endpoint (com.amazonaws.<region>.ssm)
  - SSM Messages Endpoint (com.amazonaws.<region>.ssmmessages) # required for interactive SSM sessions (like start-session)
  - S3 Gateway Endpoint (com.amazonaws.<region>.s3)
  - Endpoint security group (HTTPS only)
outputs:
  - ssm_endpoint_id
  - ssmmessages_endpoint_id
  - s3_endpoint_id
```

#### 5. **s3/** (Endpoint-Restricted)
```hcl
# Purpose: Demonstrate Gateway Endpoint access
resources:
  - Private S3 bucket
  - Bucket policy:
    • Deny all non-VPC endpoint traffic
    • Allow only from private subnet
    • Enforces access **only through Gateway Endpoint**, even if internet exists
  - Test file (via null_resource)
outputs:
  - bucket_name
  - bucket_arn
```
---

### 🔄 Key Differences from Console Lab

| Component         | Console Method             | Terraform Approach                 |
|-------------------|----------------------------|------------------------------------|
| **EC2 Access**    | SSH via bastion            | **SSM-only** (no SSH keys)         |
| **S3 Access**     | Public bucket              | **Private + endpoint policy**      |
| **Network**       | Public/private subnets     | **Private-only** architecture      |
| **Testing**       | Manual CLI checks          | **Auto-validated** endpoint access |
| **Security**      | Open temporary permissions | **Least-privilege IAM/SGs**        |
| **Access Method** | SSH with key pair          | **SSM Agent**                      |


---

### 🚀 Deployment Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/Mazdaratti/AWS_Labs
   cd VPC_Basics_6_PrivateLink/Terraform
   ```

2. **Configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit: region, allowed_ip (for SG), bucket_name
   ```

3. **Initialize & deploy**:
   ```bash
   terraform init
   terraform apply -auto-approve
   ```

4. **Connect via SSM**:

   💡 Make sure your AWS CLI is configured and authenticated (`aws configure`), and that the region matches your tfvars.

   ```bash
   aws ssm start-session --target $(terraform output -raw instance_id)
   ```

5. **Verify S3 access** (from SSM session):
   ```bash
   aws s3 ls s3://$(terraform output -raw bucket_name)
   ```
---

### 🧪 Testing S3 Uploads via SSM

1. **Manual Test** (after deployment):

   ```bash
   aws ssm start-session --target $(terraform output -raw instance_id)
   # Inside session:
   echo "Test file" > test.txt
   aws s3 cp test.txt s3://$(terraform output -raw bucket_name)/
   ```
2. **Automated Upload Test** (optional):

   ```hcl
   resource "null_resource" "test_upload" {
      triggers = {
         ec2_id = module.ec2_ssm.instance_id 
      }
  
       provisioner "local-exec" {
         command = <<EOT
           aws ssm start-session \
             --target ${module.ec2_ssm.instance_id} \
             --document-name AWS-StartInteractiveCommand \
             --parameters 'command="aws s3 cp /var/www/html/index.html s3://${module.s3.bucket_name}/"'
         EOT
       }
   }
   ``` 
---

### 💡 **Learning Takeaways** 
 
1. **PrivateLink Architecture**:  
   - Interface endpoints (SSM) = ENIs in your subnet  
   - Gateway endpoints (S3) = Route table entries  

2. **SSM as a Bastion Replacement**:  
   - No SSH keys → Uses IAM authentication  
   - Encrypted sessions with CloudWatch logging  

3. **S3 Security**:  
   - Bucket policy denies all non-VPC endpoint traffic — protects against accidental exposure even with public internet access. 

---










