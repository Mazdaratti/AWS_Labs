## 🔒 PrivateLink & VPC Endpoints Lab

This hands-on lab demonstrates how to securely access AWS services (like **S3** and **EC2 APIs**) from an **EC2 instance in a private subnet**, **without using a NAT Gateway or Internet Gateway**.

We’ll simulate both failure and success scenarios by testing connectivity:

* 🔴 When no VPC endpoints are configured (access fails)
* ✅ After adding the correct VPC **Interface** and **Gateway** Endpoints (access succeeds)

---

### 🎯 Goal of This Lab

* Understand how VPC **interface endpoints** and **gateway endpoints** work
* See the behavior of a **private EC2 instance without internet**
* Learn to add **targeted access** to AWS APIs (like EC2 and S3) via PrivateLink

---

### 🧠 What You’ll Learn

* How to configure **VPC endpoints** step by step via AWS Console
* How to **test access** to AWS services with and without PrivateLink
* How **gateway endpoints differ from interface endpoints**

---

### 🧱 Architecture Overview

| Component      | Purpose                                                       |
|----------------|---------------------------------------------------------------|
| VPC            | Custom VPC for isolation                                      |
| Public Subnet  | Holds public EC2 (used for testing and SSH into private EC2)  |
| Private Subnet | Holds EC2 with no internet access (primary focus of this lab) |
| S3 Bucket      | Used to test access over Gateway Endpoint                     |
| EC2 Instances  | One in public subnet, one in private subnet                   |
| VPC Endpoints  | Interface endpoint for EC2 API; Gateway endpoint for S3       |
| IAM Roles      | Attach permissions for EC2 and S3 to public/private EC2       |

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
     │  │  EC2 Instance │   ───────────────────►  │  EC2 Instance │   │
     │  │               │    │      SSH       │   │               │   │
     │  └───────────────┘    │                │   └───────────────┘   │
     └───────────────────────┘                └───────────────────────┘
     
```

---

## ✅ Step 1: Create VPC, Subnets, and S3 Bucket (AWS Console)

In this step, we’ll build the network foundation and the S3 bucket used for testing.

---

### 🧱 1.1 Create the VPC (with DNS for PrivateLink)

1. Open the **AWS Console**, search for and open **VPC**
2. In the search bar, type **VPC**, and select **VPC Dashboard**
3. In the left menu, select Your VPCs
4. Click **Create VPC**
5. Choose **VPC only** (not the wizard)
6. Configure:

| Field                     | Value                        |
|---------------------------|------------------------------|
| **Name tag**              | `Privatelink-Tutorial-VPC`   |
| **IPv4 CIDR block**       | `10.0.0.0/16`                |
| **Enable DNS hostnames**  | ✅ Enabled (very important!)  |
| **Enable DNS resolution** | ✅ Enabled (very important!)  |

6. Click **Create VPC**

💡 Pro Tip: Why DNS Matters for PrivateLink?
Interface Endpoints (like for EC2 API or SSM) rely on DNS to map AWS service domains to VPC ENIs.
If DNS hostnames and resolution are disabled, endpoints will silently fail to resolve.

---

### 🌐 1.2 Create Subnets

We’ll create **two subnets in the same AZ**:

* A **Public Subnet** for bastion/testing
* A **Private Subnet** for endpoint testing

#### 📥 Public Subnet

1. In the **VPC Console**, go to **SubnetsSubnets > Create subnet**
2. Configure:

   * **Name tag**: `privatelink-public-subnet`
   * **VPC**: `Privatelink-Tutorial-VPC`
   * **Availability Zone**: Choose one (e.g., `us-east-1a`)
   * **IPv4 CIDR block**: `10.0.1.0/24`
3. Click **Create subnet**

#### 🔐 Private Subnet

Repeat the steps above with:

* **Name tag**: `privatelink-private-subnet`
* **CIDR block**: `10.0.2.0/24`
* Use the same AZ

💡 Staying in one AZ keeps this lab simple and avoids cross-AZ data transfer costs.

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

We’ll now configure:
* A public route table (with internet access)
* A private route table (required for S3 Gateway Endpoint)

#### 🛣 Public Route Table

1. Go to **Route Tables**
2. Click **Create route table**
3. Configure:

   * **Name tag**: `privatelink-public-rt`
   * **VPC**: `Privatelink-Tutorial-VPC`
4. Click **Create route table**
5. Select the route table > **Routes** > **Edit routes**
6. Add route:

   * **Destination**: `0.0.0.0/0`
   * **Target**: Select your **Internet Gateway**
7. Save changes
8. Go to **Subnet associations** > **Edit subnet associations**
9. Select `privatelink-public-subnet` and click **Save**

### 🔒 Private Route Table (for Private EC2)

1. Go to **Route Tables**
2. Click **Create route table**
3. Configure:

   * **Name tag**: `privatelink-private-rt`
   * **VPC**: `Privatelink-Tutorial-VPC`
4. Click **Create route table**
5. Go to **Subnet associations** > **Edit subnet associations**
6. Select `privatelink-private-subnet` and click **Save**

📌 Leave the routes default (local only) for now — the S3 Gateway Endpoint will add itself later.

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

---

✅ Done! You now have:

* A VPC with DNS fully enabled
* 1 public and 1 private subnet
* Two route tables (public + private) correctly associated
* S3 bucket for endpoint testing

---

## 🚀 Step 2: Launch EC2 Instances in Public and Private Subnets

We will:

1. Create IAM roles with scoped permissions
2. Create separate security groups for public and private EC2
3. Launch two EC2 instances:

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
5. Click **Create key pair** — your browser will download the `.pem` file

✅ Keep this file safe — you’ll need it to SSH into the public instance.

---

### 🔐 2.2 Create IAM Roles for EC2

We’ll assign **IAM roles** to each instance at launch, granting only the permissions they need.

#### 🔧 Public EC2 Role

1. Go to **IAM > Roles** → **Create role**
2. **Trusted entity**: Choose `AWS service` → Use case: **EC2**
3. Click **Next**
4. Attach the following AWS-managed policy:

   * ✅ `AmazonEC2ReadOnlyAccess`
   * ✅ `AmazonS3FullAccess`
5. Click **Next**
6. Name it: `public-ec2-role`
   Add tag (optional): `Lab = PrivateLink`
7. Click **Create role**

---

#### 🔧 Private EC2 Role

1. Create another role following the same steps.
2. Name it: `private-ec2-role`

💡 **Pro Tip:**

> These roles avoid the need for embedded credentials and let you test IAM-based access to AWS services through VPC endpoints.
>  We use the same policies for both instances to allow S3 uploads and EC2 metadata queries. This mimics common cloud automation scenarios.
   
---

### 🛡 2.3 Create Separate Security Groups

We’ll create **dedicated security groups** for each EC2:

#### 🔒 Public EC2 Security Group

1. Go to **EC2 > Security Groups**
2. Click **Create security group**
3. Name: `public-ec2-sg`
4. VPC: `Privatelink-Tutorial-VPC`
5. Inbound rules:

   * Type: `SSH` → Source: `My IP` (for SSH access)
   * Type: `HTTP` → Source: `0.0.0.0/0`(optional)
6. Outbound rules:
   
   * Leave as default:
      * Type: All traffic; Destination: 0.0.0.0/0

7. Click **Create security group**

✅ This allows full internet access from the public EC2 — required for updates, S3, AWS CLI, etc.

#### 🔒 Private EC2 Security Group

1. Create another SG:
2. Name: `private-ec2-sg`
3. VPC: Same
4. Inbound rules:

   * Type: `SSH` → Source: `public-ec2-sg` (for SSH jump via bastion)
   * Type: `HTTPS` → Source: `10.0.2.0/24` (Your private subnet's CIDR block)
5. Outbound rules:

   * Type: `HTTPS` → Source: `0.0.0.0/0`
6. Click **Create**

💡 **Pro Tip:**

> This ensures private EC2 is **not accessible from the internet**, but is accessible **from the public EC2** using SSH and from endpoint ENI inside private subnet

💡 **Why restrict outbound on private EC2?**

 - EC2 needs outbound HTTPS to talk to:
   - Interface Endpoints (e.g., EC2 API, SSM)
   - S3 via Gateway Endpoint
 - No need for full outbound access — this is least privilege.

---

### 💻 2.4 Launch Public EC2 Instance

1. Go to **EC2 > Instances** → **Launch instance**

2. Name: `public-ec2`

3. AMI: **Amazon Linux 2023**

4. Instance type: `t2.micro`

5. Key pair: `privatelink-ec2-key`

6. Network settings:

   * VPC: `Privatelink-Tutorial-VPC`
   * Subnet: `privatelink-public-subnet`
   * Auto-assign public IP: **Enabled**
   * Security group: `public-ec2-sg`

7. Advanced details:

   * IAM Instance profile: `public-ec2-role`
   * User data:

     ```bash
     #!/bin/bash
     echo "Hello from PUBLIC EC2" > /home/ec2-user/public-upload.txt
     chmod 644 /home/ec2-user/public-upload.txt
     ```

8. Click **Launch instance**

---

### 🛑 2.5 Launch Private EC2 Instance

Repeat the steps above with changes:

* Name: `private-ec2`
* Subnet: `privatelink-private-subnet`
* Auto-assign public IP: **Disabled**
* Security group: `private-ec2-sg`
* IAM Instance profile: `private-ec2-role`
* User data:

  ```bash
  #!/bin/bash
  echo "Hello from PRIVATE EC2" > /home/ec2-user/private-upload.txt
  chmod 644 /home/ec2-user/private-upload.txt
  ```

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
- **security Group**: `private-ec2-sg`
- **User Data**: Replace with private EC2 script

This approach reduces setup time and avoids misconfiguration.

---

### ✅ Step 2 Result

You now have:

|   Instance    |            Subnet            |  Public IP  |  Security Group   |         Role         |         Purpose          |
|:-------------:|:----------------------------:|:-----------:|:-----------------:|:--------------------:|:------------------------:|
| `public-ec2`  | `privatelink-public-subnet`  |      ✅      |   public-ec2-sg   |   public-ec2-role    |  Bastion & test client   |
| `private-ec2` | `privatelink-private-subnet` |      ❌      |  private-ec2-sg   |   private-ec2-role   | VPC endpoint validation  |

Both instances have a pre-created file you’ll use for `aws s3 cp` tests in later steps.

Next, we'll **SSH into the public EC2**, try AWS CLI commands, and then **hop into the private EC2** to test how endpoints behave.

---

## 🧪 Step 3: Test Connectivity Before PrivateLink (VPC Endpoints)

Before deploying any PrivateLink endpoints, let’s validate what works — and what doesn’t — when the **private EC2** has **no internet access**.

---

### 🎯 What We’re Testing

| Action                       | Public EC2           | Private EC2            |
|------------------------------|----------------------|------------------------|
| `curl` external site         | ✅ Yes (via IGW)      | ❌ No (no NAT/IGW)      |
| `aws ec2 describe-instances` | ✅ Yes (via internet) | ❌ No (no EC2 endpoint) |
| `aws s3 ls` / `s3 cp`        | ✅ Yes (via internet) | ❌ No (no S3 endpoint)  |
| `ssh` into private EC2       | ✅ Yes (via agent)    | N/A                    |

---

### 🔑 3.1 SSH into Public EC2 (with SSH Agent Forwarding)

From your local terminal, run:

```bash
ssh -A -i /path/to/privatelink-ec2-key.pem ec2-user@<public-ec2-public-ip>
```

**Explanation:**

* `-i`: Specifies your `.pem` key for public EC2
* `-A`: Enables **SSH agent forwarding**, letting you jump securely into the private EC2 *without copying your key*

✅ You’re now connected to the `public-ec2`.

---

### 🌐 3.2 From Public EC2: Test Internet + AWS API Access

Once inside the public EC2:

#### 🌍 Internet test

```bash
curl http://example.com
```

✅ Expected: Should load successfully — using Internet Gateway.

#### 🖥 EC2 API test

```bash
aws ec2 describe-instances --region <your-region>
```

#### ☁ S3 access test

```bash
aws s3 ls
aws s3 cp /home/ec2-user/public-upload.txt s3://privatelink-lab-bucket/
```

✅ Expected: All AWS CLI calls should work — you're accessing over the public internet via the attached IAM role.

---

### 🔁 3.3 SSH into Private EC2 (via Public EC2)

Still inside the `public-ec2`, run:

```bash
ssh ec2-user@<private-ec2-private-ip>
```

✅ This works **because we used `-A`** for agent forwarding. Your local key gets forwarded through `public-ec2` — no need to copy `.pem`.

---

### 🌐 3.4 From Private EC2: Test Internet + AWS Access (Fails)

You’re now inside the **private EC2**. Test the same commands:

#### 🌍 Internet

```bash
curl http://example.com
```

❌ Expected: This fails — there’s **no IGW or NAT**.

#### 🖥 EC2 API

```bash
aws ec2 describe-instances --region <your-region>
```

#### ☁ S3 access

```bash
aws s3 ls
aws s3 cp /home/ec2-user/private-upload.txt s3://privatelink-lab-bucket/
```

❌ All AWS CLI calls should **fail** — there are no **VPC endpoints yet**, even though IAM roles are present.

---

### ✅ Step 3 Results Summary

| Action                       | Public EC2  | Private EC2        |
|------------------------------|-------------|--------------------|
| `curl http://example.com`    | ✅           | ❌                  |
| `aws ec2 describe-instances` | ✅           | ❌                  |
| `aws s3 ls`                  | ✅           | ❌                  |
| `aws s3 cp`                  | ✅           | ❌                  |
| SSH access                   | ✅ (from PC) | ✅ (via public EC2) |

---

### 💡 Why This Happens

* The **private EC2 has no route to the internet**
* Even with IAM roles, **AWS CLI fails** — because the EC2 can’t reach the service endpoints without help
* That’s exactly why we need **PrivateLink VPC Endpoints**

---

### 💡 Pro Tip: What is SSH Agent Forwarding?

**Agent forwarding** allows you to authenticate through a bastion (public EC2) into private EC2s **without uploading your key**.

* `-A` forwards your local SSH agent into the first EC2
* When you SSH to a second EC2, your local machine handles the key verification
* No need to copy `.pem` files — more secure and cleaner

✅ Perfect for test labs and jump-box-based access.

---

## 🌐 Step 4: Create EC2 API Interface Endpoint (PrivateLink)

To allow your **private EC2 instance** (with no internet access) to interact with **Amazon EC2 APIs** — like `describe-instances`, `start-instances`, etc. — we need to create an **Interface Endpoint** via AWS **PrivateLink**.

This endpoint allows secure, private communication with AWS APIs inside your VPC — no Internet Gateway or NAT Gateway needed.

---

### 🧱 4.1 Create a Dedicated Security Group for the Endpoint

VPC Interface Endpoints **attach to an Elastic Network Interface (ENI)** in your subnet — and that ENI **must allow inbound HTTPS (TCP 443)** from your EC2 instance.

We'll create a **dedicated security group** to tightly control this.

#### 🔧 Create `ec2-endpoint-sg`

1. Go to **VPC → Security Groups**
2. Click **Create security group**
3. Configure:

   * **Name**: `ec2-endpoint-sg`
   * **VPC**: `Privatelink-Tutorial-VPC`
4. Under **Inbound Rules**, add:

   * Type: HTTPS
   * Source: `private-ec2-sg` (to allow private EC2 to reach the endpoint)
   * Type: HTTPS
   * Source: `public-ec2-sg` (to allow public EC2 to reach the same endpoint)
5. Leave **Outbound Rules** as default (allow all)
6. Click **Create security group**

💡 **Why this matters:**
This allows the **private EC2** to connect to the EC2 API Interface Endpoint via HTTPS.

---

### 🔌 4.2 Create the EC2 Interface Endpoint

Follow these instructions using the **latest AWS Console UI (2025)**:

1. Go to the **VPC Dashboard**
2. In the left nav, click **Endpoints**
3. Click **Create Endpoint**

#### 📋 Configuration

| Field                | Value                               |
|----------------------|-------------------------------------|
| **Name**             | `ec2-interface-endpoint`            |
| **Service category** | AWS services                        |
| **Service name**     | `com.amazonaws.<your-region>.ec2`   |
| **VPC**              | `Privatelink-Tutorial-VPC`          |
| **Service type**     | Interface                           |
| **Subnets**          | Select `privatelink-private-subnet` |
| **Security group**   | Select `ec2-endpoint-sg`            |
| **Policy**           | Full access (default)               |

✅ Leave **DNS options** and **Private DNS** as default (enabled).

4. Click **Create endpoint**

> ⚠️ **Note**: With **Private DNS enabled**, any EC2 in the VPC — including public instances — may attempt to use this interface endpoint.
> If you want **both public and private EC2s** to reach the EC2 API through the endpoint, the **endpoint’s security group must allow HTTPS** from **both** EC2 security groups.

---

### 🧠 What Just Happened?

You created an **Interface VPC Endpoint** — this means:

* Your **private EC2** can now access EC2 APIs like `describe-instances`
* **No public IP** or internet route is needed
* Requests stay inside the **AWS network**

---

> 💡 **Pro Tip: DNS Overrides Apply VPC-Wide**
>
> When you create a VPC Interface Endpoint (e.g., EC2 API), AWS overrides DNS **across your entire VPC**.
>
> Even EC2 instances **not in the associated subnet** will resolve the service hostname (e.g., `ec2.<region>.amazonaws.com`) to the endpoint’s private IP.
>
> ✅ To ensure connectivity:
> - The EC2 instance must be **able to route** to the endpoint ENI (via your VPC)
> - The **endpoint's security group must allow HTTPS** from the EC2's security group
>
> 🧠 Subnet association only determines **where AWS places the ENIs** — it does **not restrict DNS override or access**.

---

## 🧪 Step 5: Verify EC2 API Access from Private EC2 (via PrivateLink)

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

### 💡 Pro Tip: Jump Directly into Private EC2 (One-Line SSH via Bastion)

You can use this **single SSH command** to connect directly from your local machine to a **private EC2**, routing through the **public bastion** (without needing multiple shell hops):

```bash
ssh -J ec2-user@<BASTION_PUBLIC_IP> ec2-user@<PRIVATE_EC2_IP> -i path/to/your-key.pem
```

✅ **Explanation:**

* `-J` = Jump host (the bastion/public EC2)
* `ec2-user@<BASTION_PUBLIC_IP>` = Your public EC2 with internet access
* `ec2-user@<PRIVATE_EC2_IP>` = The destination: your isolated EC2
* `-i` = Path to your SSH private key (`.pem`)

This method securely connects through the **bastion** without copying your key or starting multiple sessions manually.

> 🔐 Make sure SSH agent forwarding is enabled if you omit `-i` and rely on `ssh-agent`.

---

## 🚪 Step 6: Create Gateway Endpoint for S3 (PrivateLink)

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
   | **Name**             | s3-gateway                       |
   | **Service category** | AWS services                     |
   | **Service name**     | `com.amazonaws.<region>.s3`      |
   | **VPC**              | `privatelink-lab-vpc` (your VPC) |
   | **Endpoint type**    | **Gateway**                      |

   #### 📍 Route table selection

   * Select the **route table for the private subnet**
     (You created it earlier — named like `privatelink-private-rt`)

5. Leave **Policy** set to: `Full access`
   > 🔐 This allows all S3 requests from within your VPC to succeed.

> ✅ We’ll restrict access more tightly (using `aws:SourceVpce`) in the **Terraform section**.

6. Click **Create endpoint**

---

### 💡 Pro Tip: Gateway vs Interface Endpoints

When you created the endpoint for EC2 in Step 4, it was an **Interface Endpoint** — which creates a special network interface (ENI) inside your subnet to privately reach an AWS API (like EC2).

But **this time**, we’re creating a **Gateway Endpoint** — which works a bit differently:
✅ You won’t see a new network interface for S3. Instead, AWS automatically updates the **route table** to send all S3 traffic **privately through AWS**, instead of out to the internet.

| Feature      | Interface Endpoint (SSM, EC2) | Gateway Endpoint (S3, DynamoDB) |
|--------------|-------------------------------|---------------------------------|
| **Type**     | ENI in your subnet            | Route table-based               |
| **Resource** | Private IP + Security Group   | No IP — modifies route table    |
| **Services** | Most AWS APIs                 | Only S3 & DynamoDB              |
| **Billing**  | Billed per hour + data        | Free                            |

> ✅ Use Gateway Endpoints where available — they are **faster and cheaper**.

---

## 🧪 Step 7: Upload and List Files from Private EC2 to S3

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
   aws s3 cp private-upload.txt s3://privatelink-lab-bucket/
   ```

   #### 📥 Confirm it uploaded from the CLI:

   ```bash
   aws s3 ls s3://privatelink-lab-bucket/
   ```

3. **🧾 Final validation — go to the S3 bucket in the AWS Console**:

   * Open the **AWS Console**
   * Navigate to **S3 > privatelink-lab-bucket**
   * Confirm that `private-upload.txt` is listed in the bucket

---

### ✅ Expected Result

You should see:

* ✅ `private-upload.txt` appears both in the **CLI output** and in the **S3 Console**
* ✅ No internet access was needed from the private EC2
* ✅ The S3 bucket was accessed via the **Gateway Endpoint**

This confirms:

* The private EC2 can **securely access S3 over the AWS network**
* No **NAT Gateway**, **Internet Gateway**, or **public IP** is required

---

### 💡 Pro Tip: How to Confirm Which Path Is Used?

* Use **VPC Flow Logs** to see if S3 traffic exits the VPC (it shouldn’t!)
* You can also use **CloudTrail** to verify that requests came via your **VPC Endpoint**

> In production, use S3 **bucket policies** with `aws:SourceVpce` to lock down access to the endpoint path only.

---

### 💡 Pro Tip:🛠 How to Enable Flow Logs (If Not Yet Configured)

### 1. Navigate to **VPC > Your VPCs**

* Select your VPC (e.g., `Privatelink-Tutorial-VPC`)
* Click the **Flow Logs** tab
* Click **Create flow log**

### 2. Configure Flow Log

| Setting     | Value                                                       |
|-------------|-------------------------------------------------------------|
| Filter      | `All` (to capture accepted and rejected traffic)            |
| Destination | `Send to CloudWatch Logs`                                   |
| Log group   | Create a new one or select `/vpc/flow-logs`                 |
| IAM Role    | Use existing or create one with `vpc-flow-logs` permissions |

> If needed, AWS will auto-create the IAM role for CloudWatch log delivery.

### 3. Click **Create Flow Log**

---

## 📊 Step 3: View Logs in CloudWatch

1. Go to **CloudWatch** > **Logs** > **Log Groups**
2. Select your log group (e.g., `/vpc/flow-logs/<your-vpc-name>`)
3. Click into one of the **Log Streams**
4. You’ll see entries like:

```text
10.0.2.100 10.0.0.0 443 ACCEPT OK ...
10.0.2.100 10.0.0.0 443 ACCEPT OK ...
```

Use the **CloudWatch Logs Insights** tool to run structured queries:

```sql
fields @timestamp, srcAddr, dstAddr, dstPort, action
| filter dstPort = 443
| sort @timestamp desc
```

---

## What to Look For

| What You’re Testing             | What to Look For                            |
|---------------------------------|---------------------------------------------|
| EC2 → S3 via Gateway Endpoint   | Private IP accessing `443` on `s3` IPs      |
| EC2 → EC2 API via Interface EP  | Port `443` to a private endpoint IP         |
| EC2 → Public Internet (blocked) | Dropped or missing entries for external IPs |

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

This Terraform project mirrors your manual setup and automates:

* VPC with public & private subnets
* EC2 instances with IAM roles
* Gateway & Interface Endpoints (PrivateLink)
* A secure S3 bucket with limited access
* All resource creation with **modular, beginner-friendly Terraform**

---

### 📁 Project Structure

```text  
Terraform/
├── main.tf                      # Root module: orchestrates all submodules
├── variables.tf                 # Input variables for the root module
├── outputs.tf                   # Outputs 
├── data.tf                      # Dynamic values (Fetch AZs, AMI)
├── terraform.tfvars.example     # Example variable values
├── README.md                    # Lab instructions (matches console and terraform versions)
│
└── modules/                     # Reusable infrastructure components
    ├── vpc/
    │   ├── main.tf              # VPC + public/private subnets + IGW + route tables
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── iam/                     # EC2 roles and policies
    │   ├── main.tf              
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── security_groups/         # EC2 and endpoint security groups
    │   ├── main.tf              
    │   ├── variables.tf
    │   └── outputs.tf
    │
    ├── ec2_instances/           # EC2 instances in public and private subnets
    │   ├── main.tf              
    │   ├── variables.tf
    │   └── outputs.tf
    │        
    ├── endpoints/               # Interface and Gateway endpoints
    │   ├── main.tf              
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── s3/
        ├── main.tf              # S3 bucket for upload test
        ├── variables.tf
        └── outputs.tf
```
---

### 📂 Root Module Responsibilities

The root module:

* Instantiates all submodules in order
* Supplies required input variables
* Fetches dynamic values like availability zones and AMIs
* Exports useful output (e.g., instance IDs)

---

## 🧱 Terraform Modules Overview

### 1️⃣ `vpc/` Module

Creates the core network layout:

```hcl
Resources:
- VPC (10.0.0.0/16)
- Public subnet (10.0.1.0/24)
- Private subnet (10.0.2.0/24)
- Internet Gateway
- Public & private route tables

Outputs:
- vpc_id
- public_subnet_id
- private_subnet_id
```

---

### 2️⃣ `security_groups/` Module

Controls traffic for EC2s and interface endpoints:

```hcl
Resources:
- public_ec2_sg:
    - Allows SSH from "My IP"
    - Allows HTTP (optional: useful for web/SSM testing)

- private_ec2_sg:
    - Allows SSH from public SG (for bastion jump)
    - Allows HTTPS to endpoint (egress is open by default)

- endpoint_sg:
    - Allows HTTPS from private EC2 SG
    - ✅ Also allows HTTPS from public EC2 SG (needed if public EC2 uses endpoint DNS)
```

**Outputs:**

* `public_ec2_sg_id`
* `private_ec2_sg_id`
* `endpoint_sg_id`

---

> 💡 **Why Add Public EC2 Access to Endpoint?**
>
> When you create a VPC Interface Endpoint (e.g., `com.amazonaws.region.ec2`) with **Private DNS enabled**, all EC2s in the VPC — public or private — will resolve AWS API domains to the **endpoint ENI**.
>
> That means even **public EC2s with internet access** will silently reroute requests through the endpoint.
>
> ✅ If you don’t allow their SG → endpoint SG traffic over **HTTPS**, those requests will **timeout**.

---

> 🧠 **Pro Tip: How DNS Interception Works**
>
> Private DNS for Interface Endpoints overrides public DNS records **globally inside your VPC**.
>
> So even public EC2s might end up hitting the endpoint — make sure your **security groups are endpoint-aware**, not just subnet-aware.

---

### 3️⃣ `iam/` Module

Assigns roles and permissions to EC2s:

```hcl
Resources:
- public_ec2_role:
    - AmazonS3FullAccess
    - AmazonEC2ReadOnlyAccess
- private_ec2_role:
    - Same as above
- Instance profiles for each role

Outputs:
- public_ec2_instance_profile
- private_ec2_instance_profile
```

> 🔐 **IAM Best Practice**: Avoid hardcoding credentials. Use instance profiles so EC2s inherit permission securely.

---

### 4️⃣ `endpoints/` Module

Implements PrivateLink for EC2 APIs and S3 access:

```hcl
Resources:
- Interface endpoint for EC2 APIs (com.amazonaws.region.ec2)
- Gateway endpoint for S3 (com.amazonaws.region.s3)
- Route table entry for S3 access in private subnet

Outputs:
- ec2_endpoint_id
- s3_endpoint_id
```

> 💡 **Pro Tip:** Gateway endpoints modify route tables. Interface endpoints add ENIs inside your subnet and need security groups.

---

### 5️⃣ `s3/` Module

Creates a restricted-access S3 bucket:

```hcl
Resources:
- S3 bucket
- S3 bucket policy:
    - Allows only:
      • Access via VPC Endpoint
      • IAM role from public EC2

Inputs:
- public_ec2_role_arn
- vpc_endpoint_id

Outputs:
- bucket_name
- bucket_arn
```

---

### 6️⃣ `ec2_instances/` Module

Creates and configures two EC2 instances:

```hcl
Resources:
- public EC2:
    - public IP enabled
    - creates "public-upload.txt" in user data
- private EC2:
    - no public IP
    - creates "private-upload.txt" in user data
- Uses IAM instance profiles
- Uses key pair for SSH 

Outputs:
- public_ec2_id
- private_ec2_id
- public_ec2_private_ip
- private_ec2_private_ip
```

> 🧪 These files will be uploaded via `aws s3 cp` from both instances to test permissions and endpoint routing.

---

## 🚀 How to Deploy

### 1️⃣ Clone the Project

```bash
git clone https://github.com/Mazdaratti/AWS_Labs.git
cd VPC_Basics_6_PrivateLink_Lab/Terraform
```

---

### 2️⃣ Set Your Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit region, bucket_name, key_pair_name, etc.
```

---

### 3️⃣ Initialize and Deploy

```bash
terraform init
terraform apply -auto-approve
```

---

### 4️⃣ Connect to Public EC2 and SSH into Private EC2

```bash
ssh -A -i path/to/your-key.pem ec2-user@<public-ec2-public-ip>
# From inside:
ssh ec2-user@<private-ec2-private-ip>
```

> 💡 **Pro Tip:**
> You can also SSH directly with jump host:
>
> ```bash
> ssh -J ec2-user@<public-ec2-ip> ec2-user@<private-ec2-ip> -i path/to/key.pem
> ```

---

### 5️⃣ Upload the File to S3 from Both Instances

```bash
aws s3 cp /home/ec2-user/public-upload.txt s3://<your-bucket-name>/
aws s3 cp /home/ec2-user/private-upload.txt s3://<your-bucket-name>/
```

---

### ✅ Final Validation Matrix

| Action                               | Public EC2 | Private EC2        |
|--------------------------------------|------------|--------------------|
| Internet Access (`curl`)             | ✅          | ❌                  |
| AWS CLI Access (`aws ec2 describe…`) | ✅          | ✅ (via endpoint)   |
| Upload to S3 (`aws s3 cp`)           | ✅          | ✅ (via endpoint)   |
| SSH Access                           | ✅          | ✅ (via public EC2) |

> 🔍 Note: Public EC2 can use the Interface Endpoint **even though it's not in the associated subnet**, due to VPC-wide DNS override.

---

### 🧹 Cleanup Reminder

To destroy your infrastructure:

```bash
terraform destroy -auto-approve
```

Then manually delete:

* Any IAM roles if not covered by Terraform
* S3 bucket contents if versioning or lifecycle is enabled

---

### ✅ Summary

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?style=flat\&logo=terraform\&logoColor=white)
![AWS](https://img.shields.io/badge/Platform-AWS-232F3E?style=flat\&logo=amazonaws\&logoColor=white)
![Level](https://img.shields.io/badge/Lab-Level%3A%20Intermediate-blueviolet)

In this lab, you deployed and validated a secure **PrivateLink + VPC Endpoints** setup using both the **AWS Console** and **modular Terraform**.

You built a production-style infrastructure that includes:

✅ A custom **VPC** with isolated public and private subnets
✅ Two EC2 instances — a public **bastion** and a private **workload host**
✅ IAM **roles and policies** granting scoped permissions to each EC2
✅ A **Gateway Endpoint** for secure Amazon S3 access
✅ An **Interface Endpoint** for EC2 API access over PrivateLink
✅ **Tightly scoped security groups** for all components
✅ A **private S3 bucket** accessible only via endpoint and IAM
✅ Manual validation using AWS CLI 


---

This hands-on tutorial demonstrates real-world **cloud security design**:

* How to isolate private infrastructure from the public internet
* How to securely reach AWS services via **PrivateLink**
* How to **build compliant networks** without NAT Gateways or IGWs
* How to write modular, maintainable Terraform code

Whether you're preparing for AWS certifications, moving toward DevOps, or building secure cloud systems, this lab provides strong foundational skills you’ll apply again and again.

---










