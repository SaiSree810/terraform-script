resource "aws_instance" "ec2-node-server" {
  ami                    = "ami-05e00961530ae1b55" #from https://bitnami.com/stack/nodejs/cloud/aws/amis
  instance_type          = "t3a.small"
  vpc_security_group_ids = [aws_security_group.HelloSG.id]
  subnet_id              = aws_subnet.subnet1.id
  key_name               = "NestJs_server"


  tags = {
    Name = "terraform-aws-Ubuntu_debian_based"
  }

  provisioner "remote-exec" { # keep this block inside resource block and save hours of time on the internet
    inline = [
      "sudo apt-get update",
      "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -",

      "sudo apt install -y nodejs",
      "sudo npm install -g yarn",
      "sudo apt-get install git -y",
      "sudo npm install -g pm2 ",
      #"sudo npm install -g strapi@latest -y ",
      "yes | npx create-strapi-app@latest my-strapi-project --quickstart --skip-cloud --no-run ", #if running --skip-cloud to skip loginsuff
      "cd ~/my-strapi-project",
      "pm2 start npm --name strapi-app -- run develop",
      "pm2 save"

    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      #private_key = file("/home/somesh/Desktop/AWS_IAC/nestjsserver.pem") # Replace with your private key path
      private_key = var.ssh_private_key
      host        = self.public_ip
      #private_key = aws_key_pair.deployer.id

    }
  }



}


