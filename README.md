Deploying Strapi in EC2 with terraform and Implement CI/CD using Github actions.

Documentation: https://docs.google.com/document/d/1mmJWL3Jwanv7NcuTvLIkxiN7qyqg4xe_73eeUqv-R5E/edit?usp=sharing

Screencast: https://www.loom.com/share/1e081843a91543db8a2c01fac7b15a77?sid=86d695f6-656f-45c9-8495-13571f050e40

This repo contains :

1.Created Terraform configuration files to set up the infrastructure on AWS. 2.Configured GitHub Actions workflows for CI/CD. 3.Added environment setup scripts to generate necessary environment variables for Strapi.

1.main.tf:

terraform { required_providers { aws = { source = "hashicorp/aws" version = "5.54.1" } } }

provider "aws" { region = var.region }

resource "tls_private_key" "strapi_ec2" { algorithm = "RSA" rsa_bits = 4096 }

resource "aws_key_pair" "strapi_keys" { key_name = "strapi-keypair" public_key = tls_private_key.strapi_ec2.public_key_openssh }

resource "aws_instance" "strapi_instance" { ami = var.ami instance_type = "t2.medium" key_name = aws_key_pair.strapi_keys.key_name security_groups = [aws_security_group.strapi_ec2_sg.name]

tags = { Name = "Paramesh-Strapi-Instance" }

provisioner "remote-exec" { inline = [ "sudo apt-get update", "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -", "sudo apt-get install -y nodejs", "sudo apt-get install -y npm", "sudo npm install pm2 -g", "if [ ! -d /srv/strapi ]; then sudo git clone https://github.com/raviiai/Strapi-project-Deployment /srv/strapi; else cd /srv/strapi && sudo git pull origin master; fi", "sudo chmod u+x /srv/strapi/generate_env_variables.sh*", "cd /srv/strapi", "sudo ./generate_env_variables.sh", ] connection { type = "ssh" user = "ubuntu" private_key = tls_private_key.strapi_ec2.private_key_pem host = self.public_ip } }

}

resource "aws_security_group" "strapi_ec2_sg" { name = "strapi-security-group2" description = "Security group for Strapi EC2 instance"

ingress { from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

ingress { from_port = 1337 to_port = 1337 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }

egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }

tags = { Name = "Strapi Security Group" } }

2.variables.tf:

variable "region" { default = "eu-west-2" }

variable "ami" { default = "ami-09627c82937ccdd6d" }

3.outputs.tf:

output "instance_ip" { value = aws_instance.strapi_instance.public_ip }

4.generate_env_variables.sh:

#!/bin/bash

Generate random values for each environment variable
APP_KEYS=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))") API_TOKEN_SALT=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'))") ADMIN_JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'))")

TRANSFER_TOKEN_SALT=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'))")

Export variables
export APP_KEYS export API_TOKEN_SALT export ADMIN_JWT_SECRET export TRANSFER_TOKEN_SALT

Optionally, write them to a .env file
echo "APP_KEYS=${APP_KEYS}" > .env echo "API_TOKEN_SALT=${API_TOKEN_SALT}" >> .env echo "ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}" >> .env

echo "Environment variables generated and exported:" echo "APP_KEYS=${APP_KEYS}" echo "API_TOKEN_SALT=${API_TOKEN_SALT}" echo "ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}"

GitHub Actions Workflows 1.Terraform Workflow (.github/workflows/terraform.yml)

name: Terraform CI/CD

on: workflow_dispatch:

jobs: terraform: runs-on: ubuntu-22.04

steps:
- name: Checkout code
  uses: actions/checkout@v2

- name: Set up Terraform
  uses: hashicorp/setup-terraform@v1
  with:
    terraform_version: 1.8.5  # Adjust to the version you're using
    aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    region: ${{ secrets.AWS_REGION }}

- name: Terraform Init
  run: terraform init

- name: Terraform Validate
  run: terraform validate

- name: Terraform Plan
  id: plan
  run: terraform plan -out=tfplan

- name: Terraform Apply
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'  # Adjust condition as needed
  run: terraform apply -auto-approve tfplan
2.Strapi application workflow (.github/workflows/strapi-deploy.yaml)

name: Deploy Strapi Application

on: push: branches: - Parameswaran pull_request: branches: - Parameswaran

jobs: deploy: runs-on: ubuntu-22.04

steps:
- name: Checkout code
  uses: actions/checkout@v2

- name: Install SSH client
  run: sudo apt-get install openssh-client

- name: SSH into EC2 instance and deploy Strapi
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.EC2_PUBLIC_IP }}
    username: paramesh
    key: ${{ secrets.PRIVATE_SSH_KEY }}
    script: |
      cd /srv/strapi
      sudo git pull origin main
      sudo npm install         
      # Check if Strapi is already managed by pm2
      if ! sudo pm2 status | grep -q "strapi-app"; then
        echo "Strapi is not managed by pm2. Starting Strapi with pm2..."
        sudo pm2 start "npm run start --silent" --name "strapi-app"
      else
        echo "Strapi is already managed by pm2. Restarting Strapi..."
        sudo pm2 restart strapi-app
      fi
How to Use

Clone the repository:

git clone https://github.com/PearlThoughts-DevOps-Internship/strapi.git

cd strapi

Create a new branch for your changes:

git checkout -b your-branch-name

Add your changes, commit, and push to the remote repository:

git add .

git commit -m "Your commit message"

git push origin your-branch-name

Create a pull request from your branch to the main branch and wait for reviews.
