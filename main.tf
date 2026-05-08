terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # You can change this if your default AWS region is different
}

# 1. Generate an SSH Key locally so we can use it with Ansible later
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "akm-challenge-key"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  content  = tls_private_key.pk.private_key_pem
  filename = "${path.module}/akm-key.pem"
  file_permission = "0400"
}

# 2. Networking (VPC and Subnet)
resource "aws_vpc" "main" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "AKM-VPC" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = false # Forces all machines to have internal IPs by default
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# 3. Security Groups
resource "aws_security_group" "sg_a" {
  name        = "machine-a-sg"
  description = "Allow SSH and HTTP to Machine A"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_bc" {
  name        = "machine-bc-sg"
  description = "Allow internal traffic from Machine A"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_a.id] # Only allow SSH from Machine A
  }

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_a.id] # Only allow Nginx traffic from Machine A
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. AMI Data Source (Always grabs the latest Ubuntu 22.04)
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# 5. EC2 Instances
resource "aws_instance" "machine_a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  private_ip             = "192.168.0.10"
  vpc_security_group_ids = [aws_security_group.sg_a.id]
  key_name               = aws_key_pair.kp.key_name
  tags = { Name = "Machine-A" }
}

# Assign External Public IP specifically to Machine A
resource "aws_eip" "eip_a" {
  instance = aws_instance.machine_a.id
  domain   = "vpc"
}

resource "aws_instance" "machine_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  private_ip             = "192.168.0.20"
  vpc_security_group_ids = [aws_security_group.sg_bc.id]
  key_name               = aws_key_pair.kp.key_name
  tags = { Name = "Machine-B" }
}

resource "aws_instance" "machine_c" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet.id
  private_ip             = "192.168.0.30"
  vpc_security_group_ids = [aws_security_group.sg_bc.id]
  key_name               = aws_key_pair.kp.key_name
  tags = { Name = "Machine-C" }
}