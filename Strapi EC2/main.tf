resource "aws_security_group" "Strapi_SG" {
    name        = "security_group_for_strapi"
    description = "security group for strapi application"
    vpc_id      = var.vpc_id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow SSH"
        }

    ingress {
            from_port   = 1337
            to_port     = 1337
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "allow HTTP"
            }

    egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    }
}


# Launch an EC2 instance using the created key pair
resource "aws_instance" "web" {
    ami             =  var.ami_id  # Specify an appropriate AMI ID
    instance_type   = var.instance_type
    security_groups = [aws_security_group.Strapi_SG.name]
    key_name        = var.key_pair
    # user_data       = file("Strapi.sh")
    
    root_block_device {
        volume_size = 15
    }
    tags = {
        Name = "Strapi"
    }
}

