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

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name = "key12"
  subnet_id = aws_subnet.strapi-subnet.id
  security_groups = [ aws_security_group.top_sec.id ]
  associate_public_ip_address = true
  

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nodejs npm git
              sudo npm install -g pm2
              sudo npm install -g npx
              sudo mkdir -p /srv/strapi
              sudo chown -R ubuntu:ubuntu /srv/strapi
              cd /srv/strapi
              npx create-strapi-app my-project --quickstart
              cd my-project
              pm2 start npm --name "strapi" -- run develop
              EOF




  tags = {
    Name = "strapi-application"
  }
}

output "public_dns" {
  value = aws_instance.web.public_dns
  
}
