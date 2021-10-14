terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "tls_private_key" "instance_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "instance_key_pair" {
  key_name   = "flugel.it key pair"
  public_key = tls_private_key.instance_private_key.public_key_openssh

}

resource "aws_s3_bucket" "bucketinstance" {
  bucket = "flugel.it s3 bucket instance"
  acl    = "private"
  tags   = var.tags
}

resource "aws_instance" "ec2_manager_service" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.instance_key_pair.key_name
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  iam_instance_profile   = aws_iam_instance_profile.tags_reader.name

  tags = var.tags

  connection {
    type        = "ssh"
    host        = aws_instance.ec2_manager_service.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.instance_private_key.private_key_pem
  }

  provisioner "file" {
    source      = "../service.py"
    destination = "/tmp/service.py"
  }

  provisioner "file" {
    source      = "../p.service"
    destination = "/tmp/p.service"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y -qq",
      "sudo apt-get install python3-pip -y -qq",
      "sudo pip install boto3",
      "sudo pip install ec2-metadata",
      "chmod +x /tmp/service.py",
      "sudo mv /tmp/p.service /etc/systemd/system/p.service",
      "sudo apt-get install apache2 -y -qq",
      "sudo service apache2 start",
      "sudo systemctl enable p.service",
      "sudo systemctl start p.service",
    ]
  }
}


resource "aws_security_group" "webSG" {
  name        = "flugel.it security group"
  description = "Allow ssh  inbound traffic"

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

  ingress {
    from_port   = 8000
    to_port     = 8000
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