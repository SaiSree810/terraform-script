
output "instance_ip" {
  value = aws_instance.strapi_terraform_instance.public_ip
}