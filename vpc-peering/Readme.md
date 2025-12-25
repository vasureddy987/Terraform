````md
# 🔗 VPC Peering on AWS using Terraform

## 📌 Project Overview

This project demonstrates how to **securely connect two AWS VPCs using VPC Peering** with **Terraform**.  
Two separate VPCs are created and managed using **multiple AWS providers with aliases**, simulating a real-world multi-VPC setup.

The project enables **private communication between EC2 instances** running in different VPCs without using the public internet.

---

## 🧠 Definition

**VPC Peering** is a networking connection between two VPCs that enables private communication using private IP addresses, ensuring **secure and low-latency connectivity**.

---

## 🎯 Objectives

- Connect two VPCs securely using VPC Peering
- Practice Terraform **multiple providers with alias**
- Build networking components step by step
- Enable EC2 communication across VPCs
- Follow Infrastructure as Code (IaC) best practices

---

## 🛠️ Tools & Technologies

- AWS VPC
- AWS EC2
- AWS VPC Peering
- AWS Route Tables
- AWS Security Groups
- Terraform
- Linux

---

## 🏗️ Architecture Diagram

![VPC Peering Architecture](./architecture.png)

### Architecture Flow

1. Create **VPC-A** and **VPC-B** with non-overlapping CIDR blocks  
2. Create public subnets in both VPCs  
3. Attach Internet Gateways to both VPCs  
4. Create route tables and associate them with subnets  
5. Establish VPC Peering connection  
6. Accept peering connection using second provider  
7. Add routes in both VPC route tables  
8. Launch EC2 instances in both VPCs  
9. Enable secure communication using security groups  

---

## 📂 Project Structure

```text
vpc-peering-terraform/
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
├── images/
│   └── architecture.png
````

---

## ⚙️ Terraform Implementation Details

### 🔹 Providers

* Two AWS providers created using **alias**
* Each provider manages one VPC

### 🔹 VPC Configuration

* Primary CIDR block (VPC-A)
* Secondary CIDR block (VPC-B)
* DNS support and DNS hostnames enabled
* Proper tagging applied to all resources

### 🔹 Networking Resources

* Subnets created in both VPCs
* Internet Gateways attached to both VPCs
* Route tables created for both VPCs
* Route table associations with subnets

### 🔹 Data Sources

* Availability Zones
* Latest Amazon Linux AMI

### 🔹 VPC Peering

* VPC Peering connection created
* Acceptor resource configured
* Routes added on both VPCs for peering traffic

### 🔹 Compute Resources

* Key pair created for SSH access
* Security group allowing SSH and internal traffic
* EC2 instance launched in each VPC

---

## 🚀 How to Deploy

### 1️⃣ Initialize Terraform

```bash
terraform init
```

### 2️⃣ Validate Configuration

```bash
terraform validate
```

### 3️⃣ Review Plan

```bash
terraform plan
```

### 4️⃣ Apply Infrastructure

```bash
terraform apply
```

---

## 📤 Outputs

After successful deployment, Terraform outputs:

* VPC IDs
* VPC Peering Connection ID
* EC2 Public IP addresses
* Subnet IDs

These outputs help verify correct infrastructure creation.

---

## 🔐 Security Considerations

* Non-overlapping CIDR blocks
* VPC Peering traffic stays within AWS network
* Security groups restrict access to required ports only
* No hardcoded AWS credentials

---

## 🧠 Key Learnings

* Managing multiple AWS providers using Terraform
* Understanding VPC Peering and routing
* Designing secure AWS networking architectures
* Writing clean, readable Terraform code
* Real-world Infrastructure as Code workflow

---

## 📈 Future Enhancements

* Use private subnets with NAT Gateway
* Cross-account VPC peering
* Add Application Load Balancer
* Convert VPC setup into Terraform modules
* Add CI/CD pipeline for Terraform

---

## 👤 Author

**Vasu Reddy**

AWS | Terraform | Kubernetes | Docker

---

## 📜 License

This project is intended for **learning and portfolio purposes**.

```
```