terraform {
 required_providers{
   aws = {
      source = "hashicorp/aws"
      version = "~>3.0" 
   }
 }
}

provider "aws" {
 access_key = "AKIAROVLYDHMTYQADM7Y"
 secret_key = "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"
 region = "eu-west-1"
}

/*data "aws_ami" "myami" {
  owners = ["100218182105"]
  filter {
    name = "virtualization-type"
    values =  ["hvm"]
  }
  filter {
    name = "name"
    values = ["apache_webserver"]
  }
}

resource "aws_instance" "myserevr" {
  ami = data.aws_ami.myami.id
  instance_type = "t2.micro"
  tags = {
   Name = "ApacheServer"
  }
}*/

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/24"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
  }
  enable_dns_support = true   # Amazon Route53 resolver can resolve the dns name
  enable_dns_hostnames = true # give you instance a dns name
}

resource "aws_subnet" "pub_sub" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/26"
  map_public_ip_on_launch = true
  availability_zone_id = "euw1-az1"
  # create = "5s"
  tags = {
    Name = "pub_sub"
  }
}

resource "aws_subnet" "pvt_sub" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.0.64/26"
  map_public_ip_on_launch = false
  availability_zone_id = "euw1-az2"
  # create = "5s" 
  tags = {
    Name = "pvt_sub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.myvpc.id
  route = []
  tags = {
    Name = "pub_rt"
  }
}

resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.myvpc.id
  route = []
  tags = {
    Name = "pvt_rt"
  }
}

resource "aws_route" "internet_route" {
  route_table_id = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "no_internet_route" {
  route_table_id = aws_route_table.pvt_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "pub_sub_asso" {
  subnet_id = aws_subnet.pub_sub.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pvt_sub_asso" {
  subnet_id = aws_subnet.pvt_sub.id
  route_table_id = aws_route_table.pvt_rt.id
}
