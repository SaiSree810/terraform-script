resource "aws_instance" "strapi" {
  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.medium"
  subnet_id              = "subnet-0c724a9e1beb09e35"
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  key_name = "thepair"
  associate_public_ip_address = true
  user_data                   = <<-EOF
                                #!/bin/bash
                                sudo apt update
                                curl -fsSL https://deb.nodesource.com/setup_20.x -o nodesource_setup.sh
                                sudo bash -E nodesource_setup.sh
                                sudo apt update && sudo apt install nodejs -y
                                sudo npm install -g yarn && sudo npm install -g pm2
                                echo -e "skip\n" | npx create-strapi-app simple-strapi --quickstart
                                cd simple-strapi
                                echo "const strapi = require('@strapi/strapi');
                                strapi().start();" > server.js
                                pm2 start server.js --name strapi
                                pm2 save && pm2 startup
                                sleep 360
                                EOF

  tags = {
    Name = "Strapi_Server"
  }
}
