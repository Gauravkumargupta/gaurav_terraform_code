resource "aws_instance" "MyFirstInstance" {
  ami = "ami-0b69ea66ff7391e80"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "EC2_Instance_Terraform"
  }
}
resource "aws_security_group" "instance" {
  name = "terraform_ec2_example"
  ingress {
    from_port = var.server_port
    protocol = "tcp"
    to_port = var.server_port
    cidr_blocks = ["0.0.0.0/0"]
  }
}