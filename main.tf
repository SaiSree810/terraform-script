# Configure Terraform provider (e.g., AWS)
provider "aws" {
  profile = "strapi-profile"  # Assuming you have a profile configured
  region  = "ap-south-1"      # Replace with your desired region
}

# Create a security group with descriptive names
resource "aws_security_group" "strapi_app_sg" {
  name        = "strapi-application-security-group"
  description = "Security group for Strapi application access"

  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict for production
  }

  ingress {
    from_port = 1337  # Replace with your Strapi port
    to_port   = 1337
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict for production
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Outbound traffic (review for your needs)
  }
}

# Create an EC2 instance referencing the security group
resource "aws_instance" "strapi-server" {
  ami           = "ami-05e00961530ae1b55"  # Replace with a suitable AMI
  instance_type = "t2.micro"             # Adjust based on resource requirements
  vpc_security_group_ids = ["sg-0dba8dc443a23f48e"]

  # User data script to install packages, clone repo, configure PM2, etc.
  user_data = <<EOF
    #!/bin/bash

    # Update package lists
    sudo apt-get update

    # Install necessary packages
    sudo apt-get install -y nodejs npm git

    # Clone Strapi repository (replace with your actual URL)
    git clone https://github.com/PearlThoughts-DevOps-Internship/strapi /srv/strapi

    # Navigate to the directory
    cd /srv/strapi

    # Install Strapi dependencies
    npm install

    # Build the application
    npm run build

    # Start the Strapi server using PM2
    pm2 start npm -- start

    # Keep the script running permanently
    tail -f /dev/null
  EOF
}
