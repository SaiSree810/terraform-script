# Strapi Deployment with Terraform and GitHub Actions

## Introduction
This repository contains the setup for deploying a Strapi application on AWS EC2 using Terraform and GitHub Actions. The configuration includes infrastructure as code, CI/CD pipeline, and environment setup scripts.

## What We Have Done
- Created Terraform configuration files to set up the infrastructure on AWS.
- Configured GitHub Actions workflows for CI/CD.
- Added environment setup scripts to generate necessary environment variables for Strapi.

## How We Have Done It

### Terraform Setup
1. **main.tf**: This file contains the main configuration for creating the EC2 instance, security group, and other resources.
    ```hcl
    resource "tls_private_key" "strapi_key" {
      algorithm = "RSA"
      rsa_bits = 4096
    }

    resource "aws_key_pair" "strapi_keypair" {
      key_name   = "strapi-keypair"
      public_key = tls_private_key.strapi_key.public_key_openssh
    }

    resource "aws_instance" "strapi_instance" {
      ami           = var.ami
      instance_type = "t2.medium"
      key_name      = aws_key_pair.strapi_keypair.key_name
      security_groups = [aws_security_group.strapi_sg.name]
      tags = {
        Name = "StrapiInstance"
      }

      provisioner "remote-exec" {
        inline = [
          "sudo apt-get update",
          "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
          "sudo apt-get install -y nodejs",
          "sudo apt-get install -y npm",
          "sudo npm install pm2 -g",
          "if [ ! -d /srv/strapi ]; then sudo git clone https://github.com/PearlThoughts-DevOps-Internship/strapi /srv/strapi; else cd /srv/strapi && sudo git pull origin main; fi",
          "sudo chmod u+x /srv/strapi/generate_env_variables.sh",
          "cd /srv/strapi",
          "sudo ./generate_env_variables.sh",
          "sudo pm2 start npm --name 'strapi' -- start"
        ]

        connection {
          type        = "ssh"
          user        = "ubuntu"
          private_key = tls_private_key.strapi_key.private_key_pem
          host        = self.public_ip
        }
      }
    }

    resource "aws_security_group" "strapi_sg" {
      name        = "strapi-security-group"
      description = "Security group for Strapi EC2 instance"

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

      tags = {
        Name = "Strapi Security Group"
      }
    }
    ```

2. **variables.tf**: Defines the variables used in the Terraform configuration.
    ```hcl
    variable "region" {
      default = "us-west-2"
    }

    variable "ami" {
      default = "ami-0c55b159cbfafe1f0"
    }
    ```

3. **provider.tf**: Configures the AWS provider.
    ```hcl
    terraform {
      required_providers {
        aws = {
          source = "hashicorp/aws"
          version = "3.27.0"
        }
      }
    }

    provider "aws" {
      region = var.region
    }
    ```

4. **outputs.tf**: Outputs the public IP of the EC2 instance.
    ```hcl
    output "instance_ip" {
      value = aws_instance.strapi_instance.public_ip
    }
    ```

5. **generate_env_variables.sh**: Script to generate and export environment variables for Strapi.
    ```sh
    #!/bin/bash

    # Generate random values for each environment variable
    APP_KEYS=$(node -e "console.log(require('crypto').randomBytes(32).toString('hex'))")
    API_TOKEN_SALT=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'))")
    ADMIN_JWT_SECRET=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'))")
    TRANSFER_TOKEN_SALT=$(node -e "console.log(require('crypto').randomBytes(16).toString('base64'))")

    # Export variables
    export APP_KEYS
    export API_TOKEN_SALT
    export ADMIN_JWT_SECRET
    export TRANSFER_TOKEN_SALT

    # Optionally, write them to a .env file
    echo "APP_KEYS=${APP_KEYS}" > .env
    echo "API_TOKEN_SALT=${API_TOKEN_SALT}" >> .env
    echo "ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}" >> .env
    echo "TRANSFER_TOKEN_SALT=${TRANSFER_TOKEN_SALT}" >> .env

    echo "Environment variables generated and exported:"
    echo "APP_KEYS=${APP_KEYS}"
    echo "API_TOKEN_SALT=${API_TOKEN_SALT}"
    echo "ADMIN_JWT_SECRET=${ADMIN_JWT_SECRET}"
    ```

### GitHub Actions Workflows
1. **Terraform Workflow (.github/workflows/terraform.yml)**
    ```yaml
    name: 'Terraform'

    on:
      workflow_dispatch: {}

    jobs:
      terraform:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout repository
            uses: actions/checkout@v2

          - name: Set up Terraform
            uses: hashicorp/setup-terraform@v1
            with:
              terraform_version: 1.0.11

          - name: Terraform Init
            run: terraform init

          - name: Terraform Apply
            run: terraform apply -auto-approve
    ```

2. **Code Workflow (.github/workflows/code.yml)**
    ```yaml
    name: 'Code Workflow'

    on:
      push:
        branches:
          - main

    jobs:
      deploy:
        runs-on: ubuntu-latest

        steps:
          - name: Checkout repository
            uses: actions/checkout@v2

          - name: Deploy Strapi
            env:
              EC2_USER: ubuntu
              EC2_HOST: ${{ secrets.EC2_HOST }}
              EC2_KEY: ${{ secrets.EC2_KEY }}
            run: |
              ssh -o StrictHostKeyChecking=no -i $EC2_KEY $EC2_USER@$EC2_HOST "
                cd /srv/strapi
                git pull origin main
                npm install
                pm2 restart strapi
              "
    ```

### How to Use
1. Clone the repository:
    ```sh
    git clone https://github.com/PearlThoughts-DevOps-Internship/strapi.git
    cd strapi
    ```

2. Create a new branch for your changes:
    ```sh
    git checkout -b your-branch-name
    ```

3. Add your changes, commit, and push to the remote repository:
    ```sh
    git add .
    git commit -m "Your commit message"
    git push origin your-branch-name
    ```

4. Create a pull request from your branch to the `main` branch and wait for reviews.

## Notes
- Ensure you have AWS credentials configured for Terraform.
- The GitHub Actions workflows will handle the CI/CD pipeline for deploying the Strapi application.

## Conclusion
This README provides an overview of the setup and deployment process for the Strapi application using Terraform and GitHub Actions. Follow the steps provided to replicate the setup in your environment.


