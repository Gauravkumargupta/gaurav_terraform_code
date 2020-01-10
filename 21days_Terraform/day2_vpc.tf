#When we create VPC, following things create by default if we create by console, but through Terraform you have to create all.

#NACL
#SG
#Route Table

#We need to create following things:

#IGW
#Subnets
#Custom Route Tables

data "aws_availability_zones" "available" {}

#VPC Creation:

resource "aws_vpc" "test_vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "my-test-vpc"
  }
}

#Internet Gateway Creation:

resource "aws_internet_gateway" "test_igw" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  tags = {
    Name = "my-test-igw"
  }
}

#Public Route Table Creation:

resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test_igw.id}"
  }
  tags = {
    Name = "public-route-table"
  }
}

#Private Route Table Creation:
#If the subnet is not associated with any route by default it will be associated with Private Route table

resource "aws_default_route_table" "private_rt" {
  default_route_table_id = "${aws_vpc.test_vpc.default_route_table_id}"
  tags = {
    Name = "private-route-table"
  }
}

#Public Subnet Creation:

resource "aws_subnet" "public_subnet" {
  count = 2
  cidr_block = "${var.public_cidrs[count_index]}"
  vpc_id = "${aws_vpc.test_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count_index]}"
  tags = {
    Name = "my-public-subnet.${count.index+1}"
  }
}

#Private Subnet Creation:

resource "aws_subnet" "private_subnet" {
  count = 2
  cidr_block = "${var.private_cidrs[count_index]}"
  vpc_id = "${aws_vpc.test_vpc.id}"
  map_public_ip_on_launch = false
  availability_zone = "${data.aws_availability_zones.available.names[count_index]}"
  tags = {
    Name = "my-private-subnet.${count.index+1}"
  }
}

#Associate Public Subnet with Public Route Table

resource "aws_route_table_association" "public_subnet_assoc" {
  count = 2
  vpc_id = "${aws_vpc.test_vpc.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
  subnet_id = "${aws_subnet.public_subnet.*.id[count.index]}"
  depends_on = ["aws_route_table.public_rt", "aws_subnet.public_subnet"]
}

# Associate Private Subnet with Private Route Table

resource "aws_route_table_association" "private_subnet_assoc" {
  count = 2
  route_table_id = "${aws_default_route_table.private_rt.id}"
  subnet_id = "${aws_subnet.private_subnet.*.[count.index]}"
  depends_on = ["aws_default_route_table.private_rt","aws_subnet.private_subnet"]
}

#Security group:

resource "aws_security_group" "my-test-sg" {
  name = "my-test-sg"
  vpc_id = "${aws_vpc.test_vpc.id}"
}

resource "aws_security_group_rule" "allow-ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.my-test-sg}"
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow-outbound" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.my-test-sg.id}"
  to_port = 0
  type = "egress"
  cidr_blocks = [0.0.0.0/0]
}


