resource "aws_security_group" "my_first_sg" {
  name = "MY_FIRST_SG"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    protocol = "tcp"
    to_port = 65535
    cidr_blocks = ["44.55.66.77/32"]
  }
  egress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "GLOBAL"
  }
}