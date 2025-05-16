# 🛡️ Gateway Load Balancer Lab – Inspecting Outbound Traffic to the Internet

## 📘 Project Overview

In this lab, you will simulate a real-world network security architecture where **outbound traffic from an application is routed through a virtual firewall for inspection before it reaches the public internet**.

To achieve this, we’ll use a combination of AWS services:

- **Gateway Load Balancer (GWLB)** – Acts as a transparent pass-through for traffic, routing it to a security appliance.
- **Gateway Load Balancer Endpoint (GWLBe)** – A PrivateLink endpoint used by applications to send traffic into the inspection path.
- **Security Appliance EC2 Instance** – A dummy EC2 simulating a firewall or intrusion detection system.
- **NAT Gateway** – Allows inspected traffic to reach the internet.
- **Internet Gateway (IGW)** – Required for NAT Gateway to function.

---

## 🎯 Aim of the Lab

The main goal of this lab is to understand and deploy an AWS architecture where:

- An **application server in a Consumer VPC** sends all internet-bound traffic through a **GWLBe**.
- The traffic is forwarded to a **GWLB** in a **Provider VPC**, which passes it to a **Security Appliance**.
- The Security Appliance then forwards that traffic to the **NAT Gateway**, enabling access to the public internet.
- **Return traffic from the internet** follows the same path back, allowing **bidirectional inspection**.

This setup simulates what companies do to ensure **security, visibility, and compliance** before any application data leaves and enters their network.

---

## 🧠 What You’ll Learn

By the end of this lab, you will:

✅ Understand when and why to use Gateway Load Balancer for traffic inspection  
✅ Learn how to route traffic through PrivateLink using GWLBe  
✅ Set up and connect a Provider and Consumer VPC for service-based inspection  
✅ Configure route tables to enforce traffic flow through a security appliance  
✅ (Optionally) Use VPC Flow Logs to confirm traffic path  
✅ Prepare for real-world use cases like centralized egress inspection, firewalling, or compliance monitoring

## 🧱 Consumer VPC Subnet Design and Rationale

The **Consumer VPC** contains the application servers and the Gateway Load Balancer Endpoint (GWLBe) to send traffic into the inspection path. It typically includes:

| Subnet Name      | CIDR        | Purpose                                            | Public/Private     |
|------------------|-------------|----------------------------------------------------|--------------------|
| **App Subnet**   | 10.0.1.0/24 | Hosts Application EC2 instances generating traffic | Private or Public* |
| **GWLBe Subnet** | 10.0.2.0/24 | Hosts the Gateway Load Balancer Endpoint           | Private            |

> *The App subnet can be public or private depending on your use case. In this lab, it is public for simplicity, but production workloads usually reside in private subnets.

### Why separate subnets?

- The **GWLBe requires its own subnet** to establish PrivateLink connections to the Provider VPC’s GWLB.
- Keeping the **App servers separate from the GWLBe** subnet allows flexible routing and security controls.
- Proper subnet segregation improves security, availability, and routing clarity.


## 🧱 Provider VPC Subnet Design and Rationale

The **Provider VPC** is divided into **three distinct subnets** to isolate resources by their function and access level:

| Subnet Name          | CIDR           | Purpose                                      | Public/Private     |
|----------------------|----------------|----------------------------------------------|--------------------|
| **Appliance Subnet** | 192.168.1.0/24 | Hosts Security Appliance EC2 instance(s)     | **Private subnet** |
| **GWLB Subnet**      | 192.168.2.0/24 | Hosts the Gateway Load Balancer              | **Private subnet** |
| **Public Subnet**    | 192.168.3.0/24 | Hosts NAT Gateway and Internet Gateway (IGW) | **Public subnet**  |

### Why split the subnets this way?

- The **Gateway Load Balancer requires its own subnet** for scalability and isolation.
- The **Security Appliance must be in a private subnet** without direct internet access for security.
- The **NAT Gateway and Internet Gateway must be in a public subnet** so they can route traffic to/from the internet.
- The **Security Appliance forwards internet-bound traffic to the NAT Gateway**, which handles external communication.
- Route tables enforce this traffic flow and ensure **bidirectional inspection**.

---

## 🧰 Architecture Components

| VPC          | Resource               | Purpose                                     |
|--------------|------------------------|---------------------------------------------|
| Consumer VPC | Application EC2        | Generates traffic that must be inspected    |
| Consumer VPC | GWLBe                  | Forwards traffic into the provider’s GWLB   |
| Provider VPC | GWLB                   | Forwards to inspection appliance            |
| Provider VPC | Security Appliance EC2 | Simulates firewall/IDS                      |
| Provider VPC | NAT Gateway + IGW      | Allows internet access **after** inspection |

---
## 📊 Architecture Diagram
```
┌───────────────────────────┐                            ┌────────────────────────────────┐ 
│       Provider VPC        │                            │          Consumer VPC          │
│    CIDR: 192.168.0.0/16   │                            │        CIDR: 10.0.0.0/16       │
│                           │                            │                                │
│      ┌───────────────┐    │                            │  ┌──────────────────────────┐  │
│      │     GWLB      │◀─────────────────────────────────▶ │          GWLBe           │  │
│      │  (Gateway LB) │    │         PrivateLink        │  │      (10.0.2.0/24)       │  │
│      └───────▲───────┘    │                            │  │ Gateway Load Balancer EP │  │
│              │            │                            │  └──────────────────────────┘  │
│      ┌───────▼───────┐    │                            │               ▲                │
│      │    Security   │    │                            │               │ Route          │
│      │ Appliance EC2 │    │                            │               ▼                │
│      └───────▲───────┘    │                            │       ┌──────────────┐         │
│              │            │                            │       │    App EC2   │         │
│      ┌───────▼───────┐    │                            │       │ (10.0.1.0/24)│         │
│      │  NAT Gateway  │    │                            │       └──────────────┘         │
│      └───────▲───────┘    │                            └────────────────────────────────┘
│              │            │
│      ┌───────▼───────┐    │
│      │    Internet   │    │
│      │ Gateway (IGW) │    │
│      └───────────────┘    │
└───────────────────────────┘ 
              ▲
              │  
              ▼
      ┌──────────────┐        
      │    Public    │ 
      │   Internet   │
      └──────────────┘
```
## 🧭 Traffic Flow Summary

1. The **Application EC2** in the Consumer VPC sends all internet-bound traffic.
2. The **route tables** redirect this traffic to the **GWLBe** in the Consumer VPC.
3. The **GWLBe** forwards traffic through **PrivateLink** to the **GWLB** in the Provider VPC.
4. The **GWLB** sends traffic to the **Security Appliance EC2** in its private subnet.
5. The **Security Appliance** forwards outbound traffic to the **NAT Gateway** located in the Provider VPC’s public subnet.
6. The **NAT Gateway**, using an Elastic IP and **Internet Gateway (IGW)**, sends traffic out to the internet.
7. Return traffic follows the same path in reverse, allowing **full bidirectional inspection**.

---

Next, we will proceed with the **manual AWS Console setup**, starting with creating the Provider and Consumer VPCs and their subnets.

---

## 🔧 Step 1: Create the Provider VPC and Subnets

In this step, we'll create the **Provider VPC** with the following subnets:

- **Appliance Subnet** (`192.168.1.0/24`) – for the Security Appliance EC2
- **GWLB Subnet** (`192.168.2.0/24`) – for the Gateway Load Balancer
- **Public Subnet** (`192.168.3.0/24`) – for the NAT Gateway and Internet Gateway (IGW)

---

### 1.1 Create the Provider VPC

1. Go to the **VPC Dashboard** in the AWS Console.
2. Click **"Create VPC"**.
3. Select **"VPC only"**.
4. Configure as follows:
   - **Name tag**: `provider-vpc`
   - **IPv4 CIDR block**: `192.168.0.0/16`
   - Leave the rest as default
5. Click **Create VPC**

---

### 1.2 Create Subnet: Appliance Subnet (private)

1. In the VPC dashboard sidebar, click **"Subnets"** → **"Create subnet"**
2. Select:
   - **VPC**: `provider-vpc`
   - **Subnet name**: `appliance-subnet`
   - **Availability Zone**: pick one (e.g., `us-east-1a`)
   - **IPv4 CIDR block**: `192.168.1.0/24`
3. Click **Create subnet**

---

### 1.3 Create Subnet: GWLB Subnet (private)

1. Click **Create subnet** again
2. Use:
   - **Subnet name**: `gwlb-subnet`
   - **CIDR block**: `192.168.2.0/24`
   - **Same VPC and AZ** as previous step
3. Click **Create subnet**

---

### 1.4 Create Subnet: Public Subnet for NAT Gateway

1. Click **Create subnet** again
2. Use:
   - **Subnet name**: `public-subnet`
   - **CIDR block**: `192.168.3.0/24`
   - **Same VPC and AZ**
3. Click **Create subnet**

---

### 1.5 Enable Auto-Assign Public IP for the Public Subnet

1. Select the **`public-subnet`** from the subnet list
2. Choose **Actions → Edit subnet settings**
3. Enable: ✅ **Auto-assign public IPv4 address**
4. Save changes

---

✅ **Result:** You now have a Provider VPC with:
- Two private subnets for the GWLB and Security Appliance
- One public subnet for internet access (via NAT Gateway + IGW)

Next: We'll create the **Consumer VPC and its subnets**.

---

## 🔧 Step 2: Create the Consumer VPC and Subnets

In this step, you'll create the **Consumer VPC** and two subnets:

- **App Subnet** (`10.0.1.0/24`) – hosts an EC2 instance that generates outbound traffic  
- **GWLBe Subnet** (`10.0.2.0/24`) – hosts the Gateway Load Balancer Endpoint

The App EC2 will be deployed in a **public subnet with a public IP**, so you can **SSH in and test traffic** from your own machine.

---

### 2.1 Create the Consumer VPC

1. Go to the **VPC Dashboard** in the AWS Console
2. Click **"Create VPC"**
3. Choose **"VPC only"**
4. Configure as follows:
   - **Name tag**: `consumer-vpc`
   - **IPv4 CIDR block**: `10.0.0.0/16`
   - Leave the rest as default
5. Click **Create VPC**

---

### 2.2 Create Subnet: App Subnet (public)

1. In the VPC dashboard sidebar, go to **Subnets** → click **"Create subnet"**
2. Use:
   - **VPC**: `consumer-vpc`
   - **Subnet name**: `app-subnet`
   - **Availability Zone**: choose the same AZ as the Provider VPC (e.g. `us-east-1a`)
   - **CIDR block**: `10.0.1.0/24`
3. Click **Create subnet**

---

### 2.3 Create Subnet: GWLBe Subnet (private)

1. Click **Create subnet** again
2. Use:
   - **Subnet name**: `gwlbe-subnet`
   - **CIDR block**: `10.0.2.0/24`
   - Same AZ and VPC
3. Click **Create subnet**

---

### 2.4 Enable Auto-Assign Public IP for App Subnet

1. In **Subnets**, select the `app-subnet`
2. Click **Actions → Edit subnet settings**
3. Enable: ✅ **Auto-assign public IPv4 address**
4. Save changes

---

### 2.5 Create and Attach Internet Gateway to Consumer VPC

1. Go to **VPC → Internet Gateways**
2. Click **Create internet gateway**
   - **Name tag**: `consumer-igw`
3. After creation, click **Actions → Attach to VPC**
   - Select: `consumer-vpc`
4. Click **Attach internet gateway**

---

### 2.6 Create Route Table for Public Subnet

1. Go to **VPC → Route Tables**
2. Click **Create route table**
   - **Name tag**: `consumer-public-rt`
   - **VPC**: `consumer-vpc`
3. After creation, select the route table and:
   - Click **Actions → Edit routes**
   - Add route:
     - **Destination**: `0.0.0.0/0`
     - **Target**: `Internet Gateway` → `consumer-igw`
   - Click **Save routes**

---

### 2.7 Associate Route Table with App Subnet

1. Still in **Route Tables**, select `consumer-public-rt`
2. Go to the **Subnet associations** tab
3. Click **Edit subnet associations**
4. Select `app-subnet` (10.0.1.0/24)
5. Click **Save associations**

---

✅ Result: You now have a Consumer VPC with:
- A **public subnet** for your App EC2 with internet access
- A **private subnet** for the GWLBe endpoint

Your App Subnet is ready for:
- App EC2 with a **public IP**
- Outbound internet access
- SSH connection from your machine

Next: We’ll launch the **App EC2 instance** with the correct security group and set up SSH access.

---

## 🔧 Step 3: Launch the App EC2 Instance in Consumer VPC

In this step, you’ll launch an EC2 instance into the **App Subnet (10.0.1.0/24)** of the **Consumer VPC**.

We’ll configure it with:
- A **public IP**
- A **Security Group allowing SSH from your IP**
- A basic Amazon Linux 2 AMI for outbound testing using `curl`

---

### 3.1 Create a Security Group for the App EC2

1. Go to **EC2 → Security Groups**
2. Click **Create security group**
3. Configure:
   - **Security group name**: `app-sg`
   - **Description**: `Allow SSH from my IP`
   - **VPC**: Select `consumer-vpc`
4. Under **Inbound rules**, click **Add rule**:
   - **Type**: `SSH`
   - **Port**: `22`
   - **Source**: `My IP` (this autofills your public IP)
5. Click **Create security group**

---

### 3.2 Launch the App EC2 Instance

1. Go to **EC2 → Instances**
2. Click **Launch instance**
3. Configure:
   - **Name**: `app-ec2`
   - **AMI**: Select **Amazon Linux 2023 (x86_64)**  
     *(This is the latest stable Amazon Linux distribution)*
   - **Instance type**: `t2.micro` (or `t3.micro` if eligible)
4. Under **Key pair (login)**:
   - Select an existing key pair or create a new one
   - **Important:** You’ll need this `.pem` file to SSH later
5. Under **Network settings**:
   - **VPC**: `consumer-vpc`
   - **Subnet**: `app-subnet (10.0.1.0/24)`
   - ✅ **Auto-assign public IP**: Ensure this is enabled
   - **Firewall (security group)**: Select **existing security group** → `app-sg`
6. Leave storage and advanced settings default
7. Click **Launch instance**

---

### 3.3 Confirm and Save Public IP

1. After the instance launches, go to **EC2 → Instances**
2. Select `app-ec2`
3. Copy its **public IPv4 address** — you’ll use this to SSH in and test later

---

✅ Result: You now have an App EC2 instance running in the Consumer VPC with:
- A **public IP**
- A **security group** allowing SSH from your machine

Next: We’ll deploy the **Security Appliance EC2** in the Provider VPC, then build out the IGW, NAT Gateway, and route tables.

---

## 🔧 Step 4: Launch the Security Appliance EC2 in Provider VPC

In this step, you'll launch an EC2 instance to act as a **dummy security appliance**, simulating a firewall or inspection layer. This instance will receive traffic from the Gateway Load Balancer.

---

### 4.1 Create a Security Group for the Appliance

1. Go to **EC2 → Security Groups**
2. Click **Create security group**
3. Configure:
   - **Security group name**: `appliance-sg`
   - **Description**: `Allow GENEVE traffic from GWLB`
   - **VPC**: Select `provider-vpc`
4. Under **Inbound rules**, click **Add rule**:
   - **Type**: Custom UDP
   - **Port**: `6081`
   - **Source**: `0.0.0.0/0` *(for lab simplicity; restrict in production)*
5. Under **Outbound rules**, click **Add rule**:
   - **Type**: Custom UDP
   - **Port**: `6081`
   - **Destination**: `0.0.0.0/0`
6. Click **Create security group**

---

### 4.2 Launch the Appliance EC2 Instance

1. Go to **EC2 → Instances**
2. Click **Launch instance**
3. Configure:
   - **Name**: `security-appliance-ec2`
   - **AMI**: Select **Amazon Linux 2023 (x86_64)**
   - **Instance type**: `t2.micro` (or `t3.micro` if eligible)
4. **Key pair**:
   - Select a key pair (no SSH access needed, but AWS requires one)
5. Under **Network settings**:
   - **VPC**: `provider-vpc`
   - **Subnet**: `appliance-subnet (192.168.1.0/24)`
   - ❌ **Auto-assign public IP**: Leave disabled
   - **Firewall (security group)**: Select `appliance-sg`
6. Leave storage and advanced settings default
7. Click **Launch instance**

---

✅ Result: You now have a **Security Appliance EC2** running in a **private subnet**, reachable only via the **Gateway Load Balancer** (UDP 6081).

Next: We’ll configure the **Internet Gateway**, **Elastic IP**, **NAT Gateway**, and **route table** in the Provider VPC so the appliance can send inspected traffic to the internet.

---

## 🔧 Step 5: Configure Internet Access in Provider VPC (NAT Gateway Path)

In this step, you’ll:

- Create an **Internet Gateway (IGW)** for the Provider VPC
- Allocate an **Elastic IP (EIP)**
- Create a **NAT Gateway** in the **public subnet**
- Create a **route table** for the **appliance subnet**, pointing to the NAT Gateway

This setup allows the **Security Appliance EC2** to send traffic to the internet without needing a public IP.

---

### 5.1 Create an Internet Gateway (IGW)

1. Go to **VPC → Internet Gateways**
2. Click **Create internet gateway**
   - **Name tag**: `provider-igw`
3. After creation, select the IGW → **Actions → Attach to VPC**
   - Choose: `provider-vpc`
4. Click **Attach internet gateway**

---

### 5.2 Allocate an Elastic IP Address

1. Go to **EC2 → Elastic IPs**
2. Click **Allocate Elastic IP address**
3. Keep default settings → click **Allocate**
4. Click **Actions → Add tag**
   - **Key**: `Name`
   - **Value**: `nat-gateway-eip`

---

### 5.3 Create the NAT Gateway

1. Go to **VPC → NAT Gateways**
2. Click **Create NAT gateway**
3. Configure:
   - **Subnet**: `public-subnet (192.168.3.0/24)`
   - **Elastic IP allocation ID**: Select the one just created
   - **Name tag**: `provider-nat-gateway`
4. Click **Create NAT gateway**

> ⚠️ NAT Gateways take a couple of minutes to become “Available”

---

### 5.4 Create a Route Table for the Appliance Subnet

1. Go to **VPC → Route Tables**
2. Click **Create route table**
   - **Name tag**: `appliance-rt`
   - **VPC**: `provider-vpc`
3. After creation:
   - Select it → **Actions → Edit routes**
   - Add route:
     - **Destination**: `0.0.0.0/0`
     - **Target**: `NAT Gateway` → `provider-nat-gateway`
   - Save routes

---

### 5.5 Associate Route Table with Appliance Subnet

1. In the same route table, go to **Subnet associations**
2. Click **Edit subnet associations**
3. Select: `appliance-subnet (192.168.1.0/24)`
4. Click **Save associations**

---

✅ Result: The **Security Appliance EC2** can now send inspected traffic to the internet **via the NAT Gateway**, even though it has **no public IP**.

Next: We’ll create the **Gateway Load Balancer (GWLB)** and **Target Group** to forward traffic to the appliance.

---

## 🔧 Step 6: Create Gateway Load Balancer and Target Group in Provider VPC

The **Gateway Load Balancer (GWLB)** allows traffic to be transparently forwarded to and from the Security Appliance using the **GENEVE protocol** (UDP 6081).  
You’ll also create a **Target Group** that includes the Security Appliance EC2 instance.

---

### 6.1 Create a Target Group (GENEVE / Appliance)

1. Go to **EC2 → Target Groups**
2. Click **Create target group**
3. Configure:
   - **Target type**: `Instances`
   - **Protocol**: `GENEVE`
   - **Port**: `6081`
   - **VPC**: `provider-vpc`
   - **Target group name**: `appliance-tg`
4. Click **Next**
5. Under **Register targets**:
   - Select your `security-appliance-ec2` instance
   - Click **Include as pending**
6. Click **Create target group**

---

### 6.2 Create the Gateway Load Balancer (GWLB)

1. Go to **EC2 → Load Balancers**
2. Click **Create load balancer**
3. Choose **Gateway Load Balancer**
4. Configure:
   - **Name**: `provider-gwlb`
   - **VPC**: `provider-vpc`
   - **Availability Zone**: `us-east-1a` (or your chosen AZ)
   - **Subnet**: `gwlb-subnet (192.168.2.0/24)`
   - **Listener**: Defaults to GENEVE / 6081
   - **Forwarding target group**: Select `appliance-tg`
5. Click **Create load balancer**

---

✅ Result: The Gateway Load Balancer is now forwarding all received traffic to the **Security Appliance EC2** via the **GENEVE protocol**.

Next: We’ll publish this Gateway Load Balancer as an **Endpoint Service**, so the Consumer VPC can connect to it using **PrivateLink (GWLBe)**.

---

## 🔧 Step 7: Create the Endpoint Service (PrivateLink) for GWLB

In this step, you’ll  expose the Gateway Load Balancer (GWLB) to other VPCs by creating an **Endpoint Service**.
This allows the Consumer VPC to connect to the GWLB through a Gateway Load Balancer Endpoint (GWLBe) using **PrivateLink**.
---

### 7.1 Create the Endpoint Service

1. Go to **VPC → Endpoint Services**
2. Click **Create endpoint service**
3. Configure:
   - **Name**: `gwlb-endpoint-service`
   - **Load balancer type**: `Gateway Load Balancer`
   - **Select load balancer**: Choose `provider-gwlb`
   - ✅ Enable: **Acceptance required** (keep this checked for control)
4. Click **Create endpoint service**

---

### 7.2 View and Copy the Service Name

1. After creation, go to the **Endpoint Services** list
2. Select your service → copy the **Service name** (it will look like this):
   ```
   com.amazonaws.vpce.us-east-1.vpce-svc-xxxxxxxxxxxxxxxxx
   ```
3. Save this string — you'll need it when creating the **GWLBe** in the Consumer VPC

---

✅ Result: Your **GWLB is now published as a PrivateLink Endpoint Service** and can receive traffic from other VPCs.

Next: You’ll switch to the Consumer VPC and create a **GWLBe (Gateway Load Balancer Endpoint)** that connects to this service.

--- 

## 🔧 Step 8: Create the Gateway Load Balancer Endpoint (GWLBe) in Consumer VPC

Now we’ll create a **GWLBe** in the Consumer VPC that connects to the **Endpoint Service** we just created in the Provider VPC.  
This enables traffic from the Consumer VPC to be routed through the **GWLB → Security Appliance → NAT → Internet**.

---

### 8.1 Create the GWLBe Endpoint

1. Go to **VPC → Endpoints**
2. Click **Create endpoint**
3. Configure:
   - **Service category**: `Other endpoint services`
   - **Service name**: Paste the **service name** from Step 7 (e.g., `com.amazonaws.vpce.us-east-1.vpce-svc-xxxxxxxxxxxx`)
   - Click **Verify service**
4. Once verified, continue configuring:
   - **VPC**: `consumer-vpc`
   - **Subnet**: `gwlbe-subnet (10.0.2.0/24)`
   - **Enable Private DNS name**: Leave unchecked
   - **Enable acceptance**: Leave default
5. Click **Create endpoint**

---

### 8.2 Accept the Endpoint Connection (Provider Side)

1. Go back to **VPC → Endpoint Services**
2. Select your `gwlb-endpoint-service`
3. In the **Pending endpoints** tab:
   - Select the new request
   - Click **Actions → Accept endpoint**

---

✅ Result: The **Consumer VPC is now connected to the GWLB** via PrivateLink (GWLBe).  
Traffic from the App EC2 can now be routed through the inspection layer.

Next: We’ll configure the **route tables in the Consumer VPC** to force outbound traffic through the GWLBe.

---

## 🔧 Step 9: Configure Route Tables in Consumer VPC

In this step, you’ll configure the **App Subnet’s route table** so that all outbound traffic (`0.0.0.0/0`) is routed through the **GWLBe**.

This ensures traffic goes through:
   ```
   App EC2 → GWLBe → GWLB → Appliance → NAT Gateway → Internet
   ```
---

### 9.1 Create a New Route Table for the App Subnet

1. Go to **VPC → Route Tables**
2. Click **Create route table**
3. Configure:
   - **Name tag**: `app-subnet-rt`
   - **VPC**: `consumer-vpc`
4. Click **Create route table**

---

### 9.2 Add Default Route to GWLBe

1. Select the newly created route table
2. Click **Actions → Edit routes**
3. Add a route:
   - **Destination**: `0.0.0.0/0`
   - **Target**: `VPC Endpoint` → select the **GWLBe** endpoint created in Step 8
4. Click **Save routes**

---

### 9.3 Associate the Route Table with the App Subnet

1. In the same route table, go to the **Subnet associations** tab
2. Click **Edit subnet associations**
3. Select `app-subnet (10.0.1.0/24)`
4. Click **Save associations**

---

✅ Result: All outbound traffic from the **App EC2** will now be forced through the **Gateway Load Balancer Endpoint** and into the inspection path.

You're now ready to **test your architecture!**

---

## 🔧 Step 10: Testing and Validating the Setup

Now that everything is deployed, it’s time to test whether traffic is being inspected and forwarded correctly through the architecture.

---

### 🔌 10.1 Connect to the App EC2 (Consumer VPC)

1. Go to **EC2 → Instances**
2. Select your `app-ec2` instance
3. Copy its **Public IPv4 address**
4. Open your terminal and SSH into it:

```bash
ssh -i /path/to/your-key.pem ec2-user@<PUBLIC_IP>
````

> Replace `/path/to/your-key.pem` with the full path to your `.pem` key file
> Replace `<PUBLIC_IP>` with the actual public IP of your instance

---

### 🌐 10.2 Test Outbound Internet Access

Once you're inside the EC2 instance, run the following commands to confirm internet access:

```bash
# Test DNS and HTTP resolution
curl http://example.com

# Test raw IP connectivity
ping 8.8.8.8
```

✅ If both commands succeed, it confirms:

* The EC2 is sending traffic out
* The route table is correctly forwarding via **GWLBe**
* Traffic is passing through the **GWLB and Security Appliance**
* The **NAT Gateway** is forwarding it to the public internet
* Return traffic is working, completing the inspection chain

---

### 🧪 10.3 (Optional) Enable VPC Flow Logs for Deep Inspection

To verify internal traffic between components, you can enable **VPC Flow Logs** for:

* `gwlbe-subnet` (Consumer VPC)
* `gwlb-subnet` and `appliance-subnet` (Provider VPC)
* `nat-public-subnet` (Provider VPC)

This lets you monitor:

* GENEVE protocol traffic (`UDP 6081`)
* Packet direction and acceptance
* Evidence of routing through inspection path

---

### 🔒 10.4 Confirm Appliance Isolation (Expected Failure)

From your own computer (not from the App EC2), try to SSH into the **Security Appliance EC2** using its **private IP**.

```bash
ssh ec2-user@<PRIVATE_IP_OF_APPLIANCE>
```

This will **fail**, because the appliance has:

* No public IP
* No SSH allowed from the internet
* No IGW route

✅ This confirms it is **securely isolated**, just like a real firewall in production.

---

### 🧹 10.5 Clean-Up (Optional)

When you're finished testing, you can clean up all resources manually or via Terraform.

#### Manual clean-up:

* Terminate both EC2 instances
* Delete the NAT Gateway and release the Elastic IP
* Delete the GWLB and target group
* Delete the VPC Endpoint and Endpoint Service
* Remove all subnets, route tables, and finally both VPCs

---

🎉 **Well done!**

You have now successfully built, tested, and validated a fully working **Gateway Load Balancer inspection architecture** with:

* Multi-VPC design
* Full traffic inspection using GWLB
* NAT-based secure internet access
* Bidirectional traffic flow

This mirrors real-world patterns used in enterprises for **egress filtering**, **traffic logging**, and **compliance enforcement**.

---

## 🧱 Gateway Load Balancer Lab Terraform Deployment

**Overview**

This Terraform project deploys a multi-VPC Gateway Load Balancer architecture on AWS with:

* **Provider VPC** containing private subnets for the security appliance and GWLB, plus a public subnet with NAT Gateway and Internet Gateway
* **Consumer VPC** with public App subnet and private Gateway Load Balancer Endpoint (GWLBe) subnet
* Security groups configured for secure traffic forwarding and GENEVE protocol (UDP 6081)
* Gateway Load Balancer, Target Group, and Endpoint Service
* Modular Terraform code for easy maintenance and scalability

---

**Structure**

```bash
terraform/
├── main.tf                  # Root configuration tying modules together
├── variables.tf             # Root input variables
├── outputs.tf               # Root output definitions
├── data.tf                  # Dynamic data sources (e.g., latest AMI, available AZ)
├── terraform.tfvars.example # Example variable values
├── README.md                # Project documentation
│
└── modules/                 # Reusable modules
    ├── provider_vpc/
    │   ├── main.tf          # Provider VPC, subnets, IGW, NAT Gateway, Security Appliance EC2, route tables, security groups
    │   ├── variables.tf
    │   └── outputs.tf
    ├── consumer_vpc/
    │   ├── main.tf          # Consumer VPC, subnets, IGW, App EC2, route tables, security groups
    │   ├── variables.tf
    │   └── outputs.tf
    ├── gwlb/
    │   ├── main.tf          # Gateway Load Balancer, target group, endpoint service
    │   ├── variables.tf
    │   └── outputs.tf
    ├── gwlbe/
    │   ├── main.tf          # Gateway Load Balancer Endpoint in consumer VPC
    │   ├── variables.tf
    │   └── outputs.tf
    └── flow_logs/
        ├── main.tf          # VPC Flow Logs: IAM role, CloudWatch group, subnet logs
        ├── variables.tf
        └── outputs.tf
```

---

**Prerequisites:**

1. AWS account with programmatic access configured
2. AWS CLI installed and configured
3. Terraform version 1.10 or newer

---

**Deployment steps:**

1. Clone the repository:

   ```bash
   git clone <repo-url>
   cd terraform
   ```

2. Configure variables:

   * Copy `terraform.tfvars.example` to `terraform.tfvars`
   * Edit `terraform.tfvars` with your values, for example:

   ```hcl
   aws_region       = "us-east-1"
   provider_vpc_cidr = "192.168.0.0/16"
   consumer_vpc_cidr = "10.0.0.0/16"
   # Override any other variables as needed
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Review the execution plan (optional but recommended):

   ```bash
   terraform plan
   ```

5. Deploy the infrastructure:

   ```bash
   terraform apply
   ```

   Confirm by typing `yes` when prompted.

6. After deployment, check Terraform outputs for useful info such as the public IP of the App EC2 instance.

---

## 📡 VPC Flow Logs for Visual Traffic Inspection

To help you **validate and visualize traffic flow** across your inspection architecture — especially since you cannot SSH into the Security Appliance — this project includes a dedicated **Terraform module** to enable **VPC subnet-level Flow Logs**.

These logs help confirm traffic flow through each hop in the inspection chain:

* App EC2 instance (in Consumer VPC)
* Gateway Load Balancer Endpoint (GWLBe)
* Gateway Load Balancer (GWLB)
* Security Appliance EC2 (in Provider VPC)
* NAT Gateway (for internet-bound access)

---

### 🛠️ How It Works

The `flow_logs` module provisions:

* A dedicated **CloudWatch Log Group**: `/vpc/flow-logs/<vpc_name>`
* An **IAM Role** with inline policy permissions for VPC Flow Logs to publish to CloudWatch
* Subnet-level flow logs on the following:

  * App subnet (consumer VPC)
  * GWLBe subnet (consumer VPC)
  * GWLB subnet (provider VPC)
  * Security Appliance subnet (provider VPC)
  * NAT/public subnet (provider VPC)

This enables **fine-grained visibility** into each point where traffic is intercepted, routed, inspected, and forwarded — without needing to SSH into any internal component.

---

### 🔍 Viewing Logs in CloudWatch Logs Insights

1. Go to **AWS Console > CloudWatch > Logs Insights**
2. Select the log group:
   `/vpc/flow-logs/provider-vpc`
3. Run this query (replace with your App EC2's private IP):

   ```sql
   fields @timestamp, interfaceId, srcAddr, dstAddr, action, protocol, bytes
   | filter srcAddr = "<App EC2 private IP>"
   | sort @timestamp desc
   ```

   This will show traffic originating from your application and moving through the network.

4. To see all traffic sorted by source and destination:
   ```sql
   fields @timestamp, interfaceId, srcAddr, dstAddr, action, protocol, bytes
   | sort @timestamp desc
   | limit 50
   ```

---

### 🧪 How to Test It

1. SSH into **App EC2**

2. Run:

   ```bash
   curl -I http://example.com
   ```

3. Return to **CloudWatch Logs Insights**

4. Filter by the App EC2’s private IP to trace its traffic path

✅ You should see:

* Traffic **accepted**
* Source and destination addresses
* Subnet interface IDs

✅ You’re Now Observing Real Flow Logs

This setup is enterprise-grade and production-like. No SSH into the appliance needed. You’re inspecting traffic invisibly through AWS-native observability.

---

**Cleaning up:**

```bash
terraform destroy
```

Confirm with `yes` to delete all resources.

---

**Troubleshooting**

* If the App EC2 can’t access the internet, check NAT Gateway and route table configurations
* If GWLB health checks fail, verify security groups allow UDP 6081 traffic
* If SSH access fails, confirm your IP is whitelisted in the security group

---

## ✅ Summary

You have deployed a real-world Gateway Load Balancer inspection architecture with:

* Modular, reusable Terraform code
* Multi-VPC setup with proper subnet segmentation
* Secure inspection and routing of outbound traffic
* Fully automated provisioning and easy cleanup

This is a strong foundation for building secure and scalable network inspection systems on AWS.
