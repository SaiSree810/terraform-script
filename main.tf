provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "strapi" {
  ami           = "ami-0e001c9271cf7f3b9" # Ubuntu Server 20.04 LTS (x86)
  instance_type = "t2.medium"

  key_name = "sajan" # Replace with your key pair name
  vpc_security_group_ids = ["sg-0de22c08f628be159"]

 user_data                   = <<-EOF
				#!/bin/bash
				sudo apt update
				curl -fsSL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh
				sudo bash -E nodesource_setup.sh
				sudo apt update && sudo apt install nodejs -y
				sudo npm install -g yarn && sudo npm install -g pm2
				sudo mkdir /srv
				sudo git clone https://github.com/ansal-sajan/strapi-terraform.git /srv/strapi
				cd /srv/strapi
				sudo npm install
				sudo npm run develop
                                EOF

  tags = {
    Name = "strapi-server"
  }
}
output "public_ip" {
  value = aws_instance.strapi.public_ip
}
