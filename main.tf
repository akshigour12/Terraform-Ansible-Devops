# ---------------------------------------------------------
# AMIs
# ---------------------------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


data "aws_ami" "debian" {
  most_recent = true

  owners = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ---------------------------------------------------------
# SSH KEY
# ---------------------------------------------------------

resource "tls_private_key" "ansible" {
  algorithm = "ED25519"
}


resource "aws_key_pair" "ansible" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ansible.public_key_openssh

  tags = {
    Name    = "${var.project_name}-key"
    Project = var.project_name
  }
}


resource "local_sensitive_file" "ansible_private_key" {
  filename        = "${path.root}/${var.project_name}.pem"
  content         = tls_private_key.ansible.private_key_openssh
  file_permission = "0600"
}


# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------

module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = var.availability_zones
}


# ---------------------------------------------------------
# SECURITY GROUP
# ---------------------------------------------------------

module "security_group" {
  source = "./modules/security-group"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}


# ---------------------------------------------------------
# IAM
# ---------------------------------------------------------

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}


# ---------------------------------------------------------
# CONTROL NODE
# ---------------------------------------------------------

module "control" {
  source = "./modules/ec2"

  project_name = var.project_name

  name = "ansible-control"

  ami_id = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = module.vpc.public_subnet_ids[0]

  security_group_id = module.security_group.security_group_id

  iam_instance_profile = module.iam.instance_profile_name

  key_name = aws_key_pair.ansible.key_name

  role = "control"

  os = "ubuntu"

  user_data = <<-EOF
              #!/bin/bash

              mkdir -p /home/ubuntu/.ssh

              cat > /home/ubuntu/ansible-control.pem <<'KEYEOF'
              ${tls_private_key.ansible.private_key_openssh}
              KEYEOF

              chmod 600 /home/ubuntu/ansible-control.pem
              chown ubuntu:ubuntu /home/ubuntu/ansible-control.pem

              apt-get update -y
              apt-get install -y ansible python3-pip

              python3 -m pip install --break-system-packages boto3 botocore

              su - ubuntu -c "ansible-galaxy collection install amazon.aws"

              mkdir -p /home/ubuntu/ansible/inventory
              mkdir -p /home/ubuntu/ansible/playbooks

              chown -R ubuntu:ubuntu /home/ubuntu/ansible
              EOF
}


# ---------------------------------------------------------
# WORKER 1 - UBUNTU
# ---------------------------------------------------------

module "worker_ubuntu" {
  source = "./modules/ec2"

  project_name = var.project_name

  name = "docker-worker-ubuntu"

  ami_id = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = module.vpc.public_subnet_ids[0]

  security_group_id = module.security_group.security_group_id

  iam_instance_profile = module.iam.instance_profile_name

  key_name = aws_key_pair.ansible.key_name

  role = "worker"

  os = "ubuntu"
}


# ---------------------------------------------------------
# WORKER 2 - AMAZON LINUX
# ---------------------------------------------------------

module "worker_amazonlinux" {
  source = "./modules/ec2"

  project_name = var.project_name

  name = "docker-worker-amazonlinux"

  ami_id = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  subnet_id = module.vpc.public_subnet_ids[1]

  security_group_id = module.security_group.security_group_id

  iam_instance_profile = module.iam.instance_profile_name

  key_name = aws_key_pair.ansible.key_name

  role = "worker"

  os = "amazonlinux"
}


# ---------------------------------------------------------
# WORKER 3 - DEBIAN
# ---------------------------------------------------------

module "worker_debian" {
  source = "./modules/ec2"

  project_name = var.project_name

  name = "docker-worker-debian"

  ami_id = data.aws_ami.debian.id

  instance_type = var.instance_type

  subnet_id = module.vpc.public_subnet_ids[1]

  security_group_id = module.security_group.security_group_id

  iam_instance_profile = module.iam.instance_profile_name

  key_name = aws_key_pair.ansible.key_name

  role = "worker"

  os = "debian"
}