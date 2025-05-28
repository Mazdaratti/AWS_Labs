# 🌩️ AWS_Labs – Real-World Infrastructure on AWS

This repository contains a collection of **hands-on AWS infrastructure labs**, built using both the **AWS Console** and **modular Terraform**. Each lab simulates real-world networking and compute scenarios — great for Cloud Engineers, DevOps learners, and AWS certification candidates.

---

## 📦 Lab Index

| Lab                        | Description                                          | Approach            |
|----------------------------|------------------------------------------------------|---------------------|
| `VPC_Basics_1_VPC`         | Basic VPC with public/private subnets, IGW, NAT      | Console + Terraform |
| `VPC_Basics_2_VPC_Peering` | VPC Peering between isolated networks                | Console + Terraform |
| `VPC_Basics_3_ALB`         | Public Application Load Balancer for EC2 web servers | Console + Terraform |
| `VPC_Basics_4_GWLB`        | Gateway Load Balancer for traffic inspection         | Console + Terraform |
| `VPC_Basics_5_NLB`         | Network Load Balancer with private EC2s              | Console + Terraform |
| `VPC_Basics_6_PrivateLink` | Interface + Gateway Endpoints (EC2, S3)              | Console + Terraform |

> 🔁 The first two labs are based on AWS-provided tutorials and extended with custom Terraform. 
> Labs 3–6 are entirely custom-designed.

---

## 🧠 Skills You’ll Practice

- **Networking**: VPC, subnets, route tables, IGWs, NATs
- **Peering**: Secure cross-VPC communication
- **Load Balancing**: ALB, NLB, GWLB setup and testing
- **EC2 Automation**: Bastion hosts, user data
- **IAM**: Roles, instance profiles, least-privilege permissions
- **S3**: Private buckets with VPC endpoint-only access
- **PrivateLink**: Interface + Gateway endpoints with validation
- **Terraform**: Modular structure, variables, outputs, data

---

## 🚀 Getting Started

Each lab folder contains a detailed `README.md` with:

- Architecture overview + diagram
- Manual AWS Console setup 
- Terraform module breakdown
- Testing & validation instructions
- Security notes and real-world pro tips

You can start from any lab — no strict order is required.

---

## 💬 Contributing

Have suggestions? Found a bug? Want to add another lab?

✔️ Feel free to open a [pull request](https://github.com/Mazdaratti/AWS_Labs/pulls) or [issue](https://github.com/Mazdaratti/AWS_Labs/issues).  
✔️ Labs should be modular, testable, and beginner-friendly.  
✔️ All contributions must include a step-by-step `README.md`.

Let's learn and build better AWS infrastructure — together!

---

## 👨‍💻 Author

Built by Andriy Bualashov – AWS Cloud Practitioner certified, DevOps learner, and hands-on cloud enthusiast.

- 💼 [LinkedIn Profile](https://www.linkedin.com/in/andriy-bulashov)
- 🐙 [GitHub Profile](https://github.com/Mazdaratti)

---

## 🧩 License

This project is open-source under the MIT License.
