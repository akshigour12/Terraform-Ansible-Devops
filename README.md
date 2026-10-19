# Terraform + Ansible DevOps Project

## 📌 Overview

This project demonstrates an end-to-end **Infrastructure as Code (IaC) and Configuration Management** workflow using **Terraform, AWS, Ansible, Dynamic Inventory, and Docker**.

Terraform is used to provision the AWS infrastructure, while Ansible is used from a dedicated Control Node to configure the worker nodes.

The environment contains **4 EC2 instances**:

- 1 Ubuntu Control Node
- 1 Ubuntu Worker Node
- 1 Amazon Linux Worker Node
- 1 Debian Worker Node

Ansible uses **AWS Dynamic Inventory** to automatically discover the EC2 instances based on AWS tags.

Docker is then installed and configured on all worker nodes using an **Ansible Role with OS-specific tasks**.

---

## 🏗️ Architecture

```text
                         AWS Cloud
                            |
                     Custom VPC
                      10.0.0.0/16
                            |
              +-------------+-------------+
              |                           |
        Control Node                 Worker Nodes
          Ubuntu                   +------+------+------+
          Ansible                  |      |      |
                                   |      |      |
                                Ubuntu Amazon  Debian
                                       Linux
                                   |      |      |
                                   +------+------+ 
                                          |
                                   AWS Dynamic Inventory
                                          |
                                       Ansible
                                          |
                                    Docker Role
                                          |
                         +----------------+----------------+
                         |                |                |
                         v                v                v
                      Ubuntu        Amazon Linux         Debian
                         |                |                |
                         +----------------+----------------+
                                          |
                                        Docker
```

---

## 🎯 Project Objectives

The main objectives of this project are:

- Provision AWS infrastructure using Terraform.
- Create a custom VPC.
- Create public subnets.
- Create Internet Gateway and route tables.
- Create security groups.
- Create IAM roles and instance profiles.
- Create an SSH key pair during infrastructure provisioning.
- Provision 4 EC2 instances.
- Configure one EC2 instance as an Ansible Control Node.
- Configure three EC2 instances as worker nodes.
- Use different Linux distributions on worker nodes.
- Configure Ansible on the Control Node.
- Use AWS Dynamic Inventory.
- Automatically discover EC2 instances.
- Group instances using AWS tags.
- Create an Ansible Docker role.
- Use OS-specific Ansible task files.
- Install Docker on Ubuntu, Amazon Linux, and Debian.
- Start and enable the Docker service.
- Demonstrate Ansible idempotency.

---

# ☁️ AWS Infrastructure

Terraform provisions the following AWS resources:

```text
AWS
│
├── Custom VPC
│
├── Public Subnets
│
├── Internet Gateway
│
├── Route Tables
│
├── Security Groups
│
├── IAM Role
│
├── IAM Instance Profile
│
├── SSH Key Pair
│
└── EC2 Instances
    │
    ├── Control Node
    │   └── Ubuntu
    │
    ├── Worker Node 1
    │   └── Ubuntu
    │
    ├── Worker Node 2
    │   └── Amazon Linux
    │
    └── Worker Node 3
        └── Debian
```

---

# 🖥️ EC2 Configuration

| Instance | Operating System | Purpose |
|---|---|---|
| Control Node | Ubuntu | Ansible Control Node |
| Worker 1 | Ubuntu | Docker Worker |
| Worker 2 | Amazon Linux | Docker Worker |
| Worker 3 | Debian | Docker Worker |

The Control Node is used to manage all three worker nodes through Ansible.

---

# 🏗️ Terraform

Terraform is used to provision the complete AWS infrastructure.

## Terraform Structure

```text
Terraform-Ansible-Devops/
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars
│
├── modules/
│   │
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security-groups/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── ansible/
```

---

## Terraform Modules

### VPC Module

The VPC module is responsible for creating:

- Custom VPC
- Public subnets
- Internet Gateway
- Route tables
- Route table associations

```text
modules/vpc/
├── main.tf
├── variables.tf
└── outputs.tf
```

---

### Security Group Module

The Security Group module controls network access to the EC2 instances.

Example:

```text
Internet
   |
   | SSH : 22
   |
   v
EC2 Instances
```

SSH access should ideally be restricted to trusted source IP addresses.

---

### EC2 Module

The EC2 module creates the four instances:

```text
Control Node
    ↓
Ubuntu

Worker 1
    ↓
Ubuntu

Worker 2
    ↓
Amazon Linux

Worker 3
    ↓
Debian
```

The instances are tagged with information such as:

```text
Role
OS
AnsibleUser
```

These tags are later used by Ansible Dynamic Inventory.

---

# 🔑 SSH Key Pair

The SSH key pair is created during Terraform provisioning.

The private key is used to connect to the EC2 instances.

Example:

```text
terraform-ansible-key.pem
```

Protect the private key:

```bash
chmod 400 terraform-ansible-key.pem
```

The private key is excluded from Git using `.gitignore`.

**Never commit the `.pem` file to GitHub.**

---

# 🤖 Ansible

Ansible is installed on the Ubuntu Control Node.

The Control Node manages the three worker nodes:

```text
                 Control Node
                    Ubuntu
                      |
                   Ansible
                      |
       +--------------+--------------+
       |              |              |
       v              v              v
    Ubuntu        Amazon Linux      Debian
    Worker          Worker          Worker
```

Terraform is used for infrastructure provisioning, while Ansible handles configuration management.

---

# 📂 Ansible Directory Structure

```text
ansible/
│
├── ansible.cfg
│
├── inventory/
│   └── aws_ec2.yml
│
├── group_vars/
│   ├── os_ubuntu.yml
│   ├── os_amazonlinux.yml
│   └── os_debian.yml
│
├── playbooks/
│   └── install-docker.yml
│
└── roles/
    └── docker/
        │
        ├── defaults/
        │   └── main.yml
        │
        ├── handlers/
        │   └── main.yml
        │
        ├── tasks/
        │   ├── main.yml
        │   ├── ubuntu.yml
        │   ├── amazonlinux.yml
        │   └── debian.yml
        │
        └── vars/
            └── main.yml
```

---

# 🔄 AWS Dynamic Inventory

Instead of manually maintaining an inventory file containing EC2 IP addresses, this project uses the AWS EC2 Dynamic Inventory plugin.

The inventory file is:

```text
ansible/inventory/aws_ec2.yml
```

The plugin used is:

```text
amazon.aws.aws_ec2
```

The inventory automatically discovers running EC2 instances in the AWS region:

```text
ap-south-1
```

---

# 🏷️ EC2 Tags

EC2 tags are used to automatically create Ansible groups.

Example Control Node tags:

```text
Role = control
OS = ubuntu
AnsibleUser = ubuntu
```

Ubuntu Worker:

```text
Role = worker
OS = ubuntu
AnsibleUser = ubuntu
```

Amazon Linux Worker:

```text
Role = worker
OS = amazonlinux
AnsibleUser = ec2-user
```

Debian Worker:

```text
Role = worker
OS = debian
AnsibleUser = admin
```

These tags allow Dynamic Inventory to create groups such as:

```text
role_control
role_worker

os_ubuntu
os_amazonlinux
os_debian
```

---

# 🔍 Check Dynamic Inventory

From the Control Node:

```bash
cd ~/Terraform-Ansible-Devops/ansible
```

Run:

```bash
ansible-inventory --graph
```

Expected structure:

```text
@all:
  |--@aws_ec2:
  |  |--CONTROL_NODE
  |  |--UBUNTU_WORKER
  |  |--AMAZONLINUX_WORKER
  |  |--DEBIAN_WORKER
  |
  |--@role_control:
  |  |--CONTROL_NODE
  |
  |--@role_worker:
  |  |--UBUNTU_WORKER
  |  |--AMAZONLINUX_WORKER
  |  |--DEBIAN_WORKER
  |
  |--@os_ubuntu:
  |
  |--@os_amazonlinux:
  |
  |--@os_debian:
```

The IP addresses are discovered automatically.

---

# 🔐 OS-Specific SSH Users

Because different operating systems use different default SSH usernames, the project handles this using AWS tags and Ansible variables.

| OS | SSH User |
|---|---|
| Ubuntu | `ubuntu` |
| Amazon Linux | `ec2-user` |
| Debian | `admin` |

This prevents the same SSH username from being incorrectly used for every worker.

---

# 🧪 Test Worker Connectivity

Run:

```bash
ansible role_worker -m ping
```

Expected:

```text
SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

All three worker nodes should return:

```text
pong
```

---

# 🐳 Docker Ansible Role

Docker installation is implemented as a reusable Ansible Role.

```text
roles/docker/
```

The role contains separate task files for different operating systems:

```text
roles/docker/tasks/
│
├── main.yml
├── ubuntu.yml
├── amazonlinux.yml
└── debian.yml
```

---

# 🔀 OS Detection

The main Docker task file checks the operating system using Ansible facts.

```text
Ansible Facts
     |
     v
Operating System
     |
     +------ Ubuntu ------> ubuntu.yml
     |
     +-- Amazon Linux ----> amazonlinux.yml
     |
     +------ Debian ------> debian.yml
```

This allows the same role to manage multiple Linux distributions.

---

# 📋 Docker Role

The Docker role performs the following operations:

1. Detect operating system.
2. Execute the appropriate OS-specific task file.
3. Install Docker.
4. Start Docker.
5. Enable Docker at boot.

---

# ▶️ Install Docker

Run the playbook:

```bash
cd ~/Terraform-Ansible-Devops/ansible

ansible-playbook playbooks/install-docker.yml
```

The playbook targets:

```yaml
hosts: role_worker
```

Therefore, it automatically runs against all three worker nodes discovered by Dynamic Inventory.

---

# 🔍 Verify Docker Installation

Check the Docker version:

```bash
ansible role_worker -a "docker --version"
```

Example output:

```text
13.204.64.177 | CHANGED | rc=0 >>
Docker version 20.10.24

3.6.126.149 | CHANGED | rc=0 >>
Docker version 25.0.14

65.0.95.107 | CHANGED | rc=0 >>
Docker version 29.1.3
```

The exact Docker version can vary depending on the operating system repositories.

---

# ⚙️ Verify Docker Service

Check whether Docker is running:

```bash
ansible role_worker -a "systemctl is-active docker" -b
```

Expected:

```text
active
```

Check whether Docker starts automatically after reboot:

```bash
ansible role_worker -a "systemctl is-enabled docker" -b
```

Expected:

```text
enabled
```

---

# 🔁 Ansible Idempotency

Ansible is designed to be idempotent.

After Docker has already been installed, running:

```bash
ansible-playbook playbooks/install-docker.yml
```

again should not reinstall Docker unnecessarily.

A subsequent run should generally report:

```text
ok
```

instead of:

```text
changed
```

This means the target system is already in the desired state.

---

# 🔐 Security Practices

The project follows basic security practices.

### Private SSH Keys

Private keys are excluded from Git:

```gitignore
*.pem
*.key
```

### Terraform State

Terraform state is excluded:

```gitignore
*.tfstate
*.tfstate.*
```

### Terraform Variables

Terraform variable files are excluded:

```gitignore
*.tfvars
*.tfvars.json
```

### IAM

EC2 instances use IAM roles and instance profiles instead of hard-coded AWS access keys.

### SSH

SSH access should be restricted to trusted IP addresses.

For production environments, AWS Systems Manager Session Manager can be used instead of publicly exposed SSH.

---

# 🚫 .gitignore

The repository should contain a `.gitignore` similar to:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log
crash.*.log

# Terraform variables
*.tfvars
*.tfvars.json

# SSH private/public keys
*.pem
*.key
*.pub

# Ansible
*.retry
__pycache__/
*.pyc

# IDE
.vscode/
.idea/

# OS
.DS_Store
```

---

# 🧰 Useful Commands

## Terraform

Initialize:

```bash
terraform init
```

Validate:

```bash
terraform validate
```

Plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

Destroy:

```bash
terraform destroy
```

---

## Ansible

Check inventory:

```bash
ansible-inventory --graph
```

Test workers:

```bash
ansible role_worker -m ping
```

Run Docker configuration:

```bash
ansible-playbook playbooks/install-docker.yml
```

Check Docker:

```bash
ansible role_worker -a "docker --version"
```

Check Docker service:

```bash
ansible role_worker -a "systemctl is-active docker" -b
```

Check Docker startup:

```bash
ansible role_worker -a "systemctl is-enabled docker" -b
```

---

# 🔄 End-to-End Workflow

```text
                 LOCAL KALI MACHINE
                        |
                        |
                    Terraform
                        |
                        v
                AWS Infrastructure
                        |
              +---------+---------+
              |                   |
              v                   v
             VPC                EC2
                                  |
             +--------------------+--------------------+
             |                    |                    |
             v                    v                    v
        Control Node         Worker Node 1        Worker Node 2
          Ubuntu               Ubuntu             Amazon Linux
             |                    |                    |
             |                    +--------------------+
             |                             |
             |                         Worker Node 3
             |                            Debian
             |                             |
             +-----------------------------+
                           |
                           v
                  Ansible Control Node
                           |
                           v
                 AWS Dynamic Inventory
                           |
                           v
                     role_worker
                           |
                           v
                     Docker Role
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
          Ubuntu       Amazon Linux    Debian
          Tasks          Tasks          Tasks
             |             |             |
             +-------------+-------------+
                           |
                           v
                      Docker Installed
                           |
                           v
                    Docker Service Active
                           |
                           v
                    Docker Enabled
```

---

# 📊 Project Flow

```text
Terraform
   ↓
Custom VPC
   ↓
Security Groups
   ↓
IAM
   ↓
SSH Key Pair
   ↓
4 EC2 Instances
   ↓
Ansible Control Node
   ↓
AWS Dynamic Inventory
   ↓
Automatic EC2 Discovery
   ↓
Role-Based Groups
   ↓
role_worker
   ↓
Docker Ansible Role
   ↓
OS Detection
   ↓
Ubuntu / Amazon Linux / Debian Tasks
   ↓
Docker Installation
   ↓
Docker Service Started
   ↓
Docker Service Enabled
```

---

# 📁 Final Repository Structure

```text
Terraform-Ansible-Devops/
│
├── .gitignore
├── README.md
│
├── main.tf
├── providers.tf
├── variables.tf
├── outputs.tf
├── versions.tf
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security-groups/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ec2/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── ansible/
    │
    ├── ansible.cfg
    │
    ├── inventory/
    │   └── aws_ec2.yml
    │
    ├── group_vars/
    │   ├── os_ubuntu.yml
    │   ├── os_amazonlinux.yml
    │   └── os_debian.yml
    │
    ├── playbooks/
    │   └── install-docker.yml
    │
    └── roles/
        └── docker/
            ├── defaults/
            │   └── main.yml
            │
            ├── handlers/
            │   └── main.yml
            │
            ├── tasks/
            │   ├── main.yml
            │   ├── ubuntu.yml
            │   ├── amazonlinux.yml
            │   └── debian.yml
            │
            └── vars/
                └── main.yml
```

---

# 👩‍💻 Author

**Akshita Gour**

Cybersecurity | DevSecOps | Cloud | Automation

GitHub:  
https://github.com/akshigour12

LinkedIn:  
https://www.linkedin.com/in/akshita-g-6a24871a4/

---

# ⭐ Key Learning Outcomes

This project demonstrates practical experience with:

- Infrastructure as Code using Terraform
- Terraform Modules
- AWS VPC networking
- AWS EC2
- AWS IAM
- Security Groups
- SSH key management
- Ansible Control Node
- Ansible Dynamic Inventory
- AWS EC2 inventory plugin
- Ansible Groups
- Ansible Variables
- Ansible Roles
- OS-specific task execution
- Docker installation automation
- Linux administration
- Configuration management
- Idempotent automation
- Git and GitHub
- Multi-OS infrastructure management
