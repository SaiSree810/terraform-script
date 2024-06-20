cat <<EOF > main.tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "strapi" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "your-key-pair-name"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g pm2",
      "sudo apt-get install -y git",
      "sudo mkdir -p /srv/strapi",
      "cd /srv/strapi",
      "git clone https://github.com/PearlThoughts-DevOps-Internship/strapi.git .",
      "npm install",
      "pm2 start npm --name 'strapi' -- start"
    ]
  }

  tags = {
    Name = "StrapiInstance"
  }
}

output "instance_ip" {
  value = aws_instance.strapi.public_ip
}
EOF

