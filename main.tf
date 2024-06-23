provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "strapi_instance" {
  ami           = "ami-0f58b397bc5c1f2e8"  
  instance_type = "t2.micro"      
  subnet_id     = aws_subnet.subnet.id
  security_groups = [aws_security_group.strapi_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "StrapiInstance"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi_sg"
  description = "Allow HTTP, SSH, and Strapi inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337 
    to_port     = 1337
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


output "instance_public_ip" {
  value = aws_instance.strapi_instance.public_ip
}
