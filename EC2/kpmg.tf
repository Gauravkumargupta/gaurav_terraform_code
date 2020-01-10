#----------------------------------------------------vpc.tf------------------------------------------------------

# VPC Creation
resource "aws_vpc" "vpc_gaurav" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "gaurav VPC"
    BuildWith = "terraform"
  }
}

# Subnets Creation

#Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${ aws_vpc.vpc_gaurav.id }"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name      = "Public Subnet"
    BuildWith = "terraform"
  }
}

#Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${ aws_vpc.vpc_gaurav.id }"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name      = "Private Subnet"
    BuildWith = "terraform"
  }
}

# Internet Gateway Creation

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${ aws_vpc.vpc_gaurav.id }"

  tags = {
    Name      = "Internet Gateway"
    BuildWith = "terraform"
  }
}

#Public Route Table

resource "aws_route" "external_route" {
  route_table_id         = "${ aws_vpc.vpc_gaurav.main_route_table_id }"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${ aws_internet_gateway.internet_gateway.id }"
}

#Elastic IP

resource "aws_eip" "elastic_ip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.internet_gateway"]
}

#NAT Gateway

resource "aws_nat_gateway" "nat" {
  allocation_id = "${ aws_eip.elastic_ip.id }"
  subnet_id     = "${ aws_subnet.public_subnet.id }"
  depends_on    = ["aws_internet_gateway.internet_gateway"]
}

# Private Route Table

resource "aws_route_table" "private_route_table" {
  vpc_id = "${ aws_vpc.vpc_gaurav.id }"

  tags {
    Name      = "Private Subnet Route Table"
    BuildWith = "terraform"
  }
}

# Attach Private Route Table to NAT GW.

resource "aws_route" "private_route" {
  route_table_id         = "${ aws_route_table.private_route_table.id }"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${ aws_nat_gateway.nat.id }"
}

#Adding Public Subnets to Public Route Table

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${ aws_subnet.public_subnet.id }"
  route_table_id = "${ aws_vpc.vpc_gaurav.main_route_table_id }"
}

#Adding Private Subnets to Private Route Table

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = "${ aws_subnet.private_subnet.id }"
  route_table_id = "${ aws_route_table.private_route_table.id }"
}


#----------------------------------------------------SG.tf------------------------------------------------------

# SG for EC2 Instance

resource "aws_security_group" "3-tier-gaurav-security-group" {
  name        = "My Security Group"
  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${ aws_vpc.vpc_gaurav.id }"
}

#----------------------------------------------------EC2.tf------------------------------------------------------

# creating new keypair in EC2
resource "aws_key_pair" "my_key_pair" {
  key_name   = "${ var.key_name }"
  public_key = "${ file(var.public_key_path) }"
}

# creating EC2 instance with given userdata to initialize the applications we need in this example
resource "aws_instance" "3-tier-gaurav" {
  ami = "${ data.aws_ami.gaurav.id }"
  instance_type = "${ var.instance_type }"
  key_name      = "${ var.key_name }"

  source_dest_check           = false
  subnet_id                   = "${ aws_subnet.public_subnet.id }"
  associate_public_ip_address = true

  tags {
    BuiltWith = "terraform"
    Name      = "3-tier-gaurav"
  }
  # Attaching SG
  vpc_security_group_ids = ["${ aws_security_group.3-tier-gaurav-security-group.id }"]

  # User data
  user_data = "${ data.template_file.gaurav-data.rendered }"
}

# User data
data "template_file" "user_data" {
  template = "${ file("gaurav-data.tpl") }"
}


#----------------------------------------------------Variables.tf------------------------------------------------------
# Configuration
terraform {
  required_version = ">= 0.11.2"
  backend "s3" {
    encrypt = "true"
  }
}

#AWS provider
provider "aws" {
  region = "us-east-1"
}

# AMI Details
data "aws_ami" "gaurav" {
  filter {
    name   = "terraform-example"
    values = ["myami-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  owners = ["account-id"]
}

# Public Key
variable "public_key_path" {
  default = "~/.ssh/gaurav.pub"
}

# Key Name
variable "key_name" {
  default = "gaurav-ssh-key"
}

# EC2 machine instance type
variable "instance_type" {
  default = "t2.micro"
}

#----------------------------------------------------terraform.remote-------------------------------------------------
bucket = "3-tier-gaurav-bucket"
key    = "terraform.tfstate"
region = "us-east-1"

#-------------------------------------------------gaurav-data.tpl------------------------------------------------
User data that depends what do you want