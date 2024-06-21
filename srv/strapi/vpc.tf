resource "aws_vpc" "strapi-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "strapi-subnet" {
  vpc_id     = aws_vpc.strapi-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gateway1" {
  vpc_id = aws_vpc.strapi-vpc.id
  
}


resource "aws_route_table" "max" {
  vpc_id = aws_vpc.strapi-vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway1.id
  }
  
}

resource "aws_route_table_association" "max1"{
  route_table_id = aws_route_table.max.id
  subnet_id = aws_subnet.strapi-subnet.id
}
 