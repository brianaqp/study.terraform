terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

// Network dependencies
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

// Network
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone_id    = "use2-az1"

  tags = {
    Name = "public-1a"
  }
}

resource "aws_subnet" "public-2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone_id    = "use2-az1"

  tags = {
    Name = "public-2a"
  }
}

// Security groups
# resource "aws_vpc_security_group_egress_rule" "example" {
#   security_group_id = aws_security_group.example.id

#   cidr_ipv4   = "10.0.0.0/8"
#   from_port   = 80
#   ip_protocol = "tcp"
#   to_port     = 80
# }

// EC2 instances
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

# resource "aws_instance" "ec2_in_p1a" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"
#   subnet_id = aws_subnet.public-1a.id

#   tags = {
#     Name = "${aws_subnet.public-1a.tags.Name}"
#   }
# }