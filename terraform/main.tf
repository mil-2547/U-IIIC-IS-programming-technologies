terraform {
  required_providers {
    aws = {
      # registry.terraform.io/hashicorp/aws
      source = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.14.0"
}

# Configure the AWS provider
provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "web_app" {
  name        = "web_app"
  description = "security group"

  # Inbound configuration
  ingress {
    from_port   = 10000
    to_port     = 10000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound configuration
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags= { Name = "web_app" }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*20.04*"]
  }

  # owners: список ID тих, хто володіє образом (в даному випадку ubuntu)
  # Щоб terraform (та AWS) обрали тільки офіційні від Canonical (official ubuntu)
  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "webapp_instance" {

  ami = data.aws_ami.ubuntu.id

  instance_type   = "t3.micro"
  vpc_security_group_ids  = [aws_security_group.web_app.id]

  root_block_device {
    volume_size = 8     # <= 30GB безкоштовно на Free Tier
    volume_type = "gp3" # gp3 теж безкоштовний
  }

  tags = { Name = "webapp_instance" }
}

output "instance_public_ip" {
  # IP output (in sensitive mode (secret))
  value     = aws_instance.webapp_instance.public_ip
  sensitive = true
}