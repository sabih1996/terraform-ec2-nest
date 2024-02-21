# main.tf

provider "aws" {
  region = "us-east-1"
}

# VPC and Subnets
resource "aws_vpc" "nest_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "nest_subnet" {
  vpc_id            = aws_vpc.nest_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Security Group
resource "aws_security_group" "nest_security_group" {
  name        = "nest-app-sg"
  description = "Security group for Nest.js app"

  vpc_id = aws_vpc.nest_vpc.id

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

# EC2 Instance
resource "aws_instance" "backend_instance" {
  ami           = "ami-0821e601b0426ccf5" 
  instance_type = "t2.micro"
  key_name      = "nest-key-pair" 

  vpc_security_group_ids = [aws_security_group.nest_security_group.id]
  subnet_id              = aws_subnet.nest_subnet.id

  tags = {
    Name = "nest-app-instance"
  }
}

# Route 53 DNS Record
resource "aws_route53_record" "nest_app_dns" {
  zone_id = "your-route53-zone-id"  # Replace with your Route 53 hosted zone ID
  name    = "nest-be.com"      # Replace with your domain name
  type    = "A"

  alias {
    name                   = aws_instance.backend_instance.public_ip
    zone_id                = aws_instance.backend_instance.zone_id
    evaluate_target_health = false
  }
}