terraform {
  required_providers {
    aws = {
      # registry.terraform.io/hashicorp/aws
      source = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.14.0"

  backend "s3" {
    bucket = "lab-my-tf-state-bucket"
    key    = "terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "lab-my-tf-lockid"
  }
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

variable "aws_ami" {
  type = string
  default = "ami-0cebfb1f908092578"
}

resource "aws_instance" "webapp_instance" {

  ami = var.aws_ami

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
