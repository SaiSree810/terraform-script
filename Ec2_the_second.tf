# resource "aws_instance" "ec2-node-server2" {
#   ami                    = "ami-05e00961530ae1b55" #from https://bitnami.com/stack/nodejs/cloud/aws/amis
#   instance_type          = "t3a.small"
#   vpc_security_group_ids = [aws_security_group.HelloSG.id]
#   subnet_id              = aws_subnet.subnet1.id
#   key_name               = "NestJs_server"


#   tags = {
#     Name = "terraform-aws-Ubuntu_debian_based"
#   }

#   provisioner "remote-exec" { # keep this block inside resource block and save hours of time on the internet
#     inline = [
#       "sudo apt-get update",
#       "curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -",

#       "sudo apt install -y nodejs",
#       "sudo npm install -g yarn",
#       "sudo apt-get install git -y",
#       "sudo npm install -g pm2 ",
#       "git clone --single-branch --branch somesh https://github.com/PearlThoughts-DevOps-Internship/strapi.git",
#       "cd strapi/svc/strapi/",
#       "git pull",
#       "npm install",
#       "npm run build",
#       "pm2 start npm --name strapi-app -- run develop"

#     ]

#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file("/home/somesh/Desktop/AWS_IAC/nestjsserver.pem") # Replace with your private key path
#       host        = self.public_ip
#       #private_key = aws_key_pair.deployer.id

#     }
#   }



# }


