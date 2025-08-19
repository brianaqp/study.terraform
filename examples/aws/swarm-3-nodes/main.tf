terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*-amd64-server-*"]
  }
}


// Security groups to allow Docker ports to work
data "aws_vpc" "current" {
  default = true
}

variable "open_cidr" {
  type        = string
  description = "Provides 0.0.0.0/0 access"
  default     = "0.0.0.0/0"
}

// General rule
resource "aws_security_group" "swarm_sg" {
  name        = "docker-swarm-ports"
  description = "Provides access to docker swarm ports"
  vpc_id      = data.aws_vpc.current.id
}

# 1. SSH access
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.open_cidr
  security_group_id = aws_security_group.swarm_sg.id
}

# Swarm management
resource "aws_vpc_security_group_ingress_rule" "swarm_tcp_2377" {
  from_port         = 2377
  to_port           = 2377
  ip_protocol       = "tcp"
  cidr_ipv4         = var.open_cidr
  security_group_id = aws_security_group.swarm_sg.id
}

# Node communication TCP 7946
resource "aws_vpc_security_group_ingress_rule" "swarm_tcp_7946" {
  from_port         = 7946
  to_port           = 7946
  ip_protocol       = "tcp"
  cidr_ipv4         = var.open_cidr
  security_group_id = aws_security_group.swarm_sg.id
}

# UDP 7946
resource "aws_vpc_security_group_ingress_rule" "swarm_udp_7946" {
  from_port         = 7946
  to_port           = 7946
  ip_protocol       = "udp"
  cidr_ipv4         = var.open_cidr
  security_group_id = aws_security_group.swarm_sg.id
}


# Overlay network UDP 4789
resource "aws_vpc_security_group_ingress_rule" "swarm_udp_4789" {
  from_port         = 4789
  to_port           = 4789
  ip_protocol       = "udp"
  cidr_ipv4         = var.open_cidr
  security_group_id = aws_security_group.swarm_sg.id
}

# Example: HTTP service port 80
resource "aws_vpc_security_group_ingress_rule" "http_80" {
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.open_cidr
  security_group_id = aws_security_group.swarm_sg.id
}
// Instance
resource "aws_instance" "tf-swarm-node" {
  ami              = data.aws_ami.ubuntu_latest.id
  instance_type    = var.instance_type
  user_data_base64 = base64encode(file("${path.module}/user_data.sh"))
  count            = 2
  vpc_security_group_ids = [aws_security_group.swarm_sg.id]

  tags = {
    Name = "tf-testing-${count.index}"
  }
}
