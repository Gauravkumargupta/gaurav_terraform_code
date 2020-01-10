provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_instance" {
  ami = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  tags = {
    Name = "EC2_Terraform"
  }
}
