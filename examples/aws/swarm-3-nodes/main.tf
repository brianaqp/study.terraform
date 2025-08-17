terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.9.0"
    }
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners = [ "099720109477" ]

  filter {
    name = "name"
    values = [ "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*-amd64-server-*" ]
  }
}


resource "aws_instance" "tf-swarm-node" {
  ami = data.aws_ami.ubuntu_latest.id
  instance_type = var.instance_type
  user_data_base64 = base64encode(file("${path.module}/user_data.sh"))

  tags = {
    Name = "tf-testing"
  }
}