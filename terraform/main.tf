provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "strapi" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Correct AMI ID for ap-south-1
  instance_type = "t2.micro"
  key_name      = "GitHub"  # Your key pair name

  tags = {
    Name = "StrapiServer"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y curl",
      "curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g pm2",
      "git clone -b revert-1-saipavan https://github.com/PearlThoughts-DevOps-Internship/strapi.git /srv/strapi",
      "cd /srv/strapi && npm install",
      "cd /srv/strapi && npm run build",
      "pm2 start npm --name strapi -- start"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/Downloads/GitHub.pem")  # Path to your private key
      host        = aws_instance.strapi.public_ip
    }
  }
}

output "instance_ip" {
  value = aws_instance.strapi.public_ip
}

