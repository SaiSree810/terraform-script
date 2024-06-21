variable "region" {
  default = "eu-west-2"
}

variable "ami" {
  default = "ami-053a617c6207ecc7b"
}

variable "ec2_private_key" {
  description = "SSH private key for connecting to EC2 instance"
}