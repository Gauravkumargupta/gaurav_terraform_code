resource "aws_launch_configuration" "my-test-launch-config" {
  image_id = "ami-01ed306a12b7d1c96"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.my-asg-sg.id}"]
  user_data = <<-EOF
              #!/bin/bash
              yum -y install httpd
              echo "Hello, from Terraform" > /var/www/html/index.html
              service httpd start
              chkconfig httpd on
              EOF
  lifecycle {
    create_before_destroy = true
  }
}

/*lifecycle settings are create_before_destroy, which, if set to true, tells Terraform to always create a replacement resource before
//destroying the original resource. For example, if you set create_before_destroy to true on an EC2 Instance, then whenever you make
change to that Instance, Terraform will first create a new EC2 Instance, wait for it to come up, and then remove the old EC2 Instance.
*/
resource "aws_security_group" "my-asg-sg" {
  name = "my-asg-sg"
  vpc_id = "${aws_vpc.test_vpc.id}"
}
resource "aws_security_group_rule" "inbound_ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.my-asg-sg.id}"
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "inbound_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.my-asg-sg.id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "outbound_all" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.my-asg-sg.id}"
  to_port = 0
  type = "engress"
  cidr_blocks = ["0.0.0.0/0"]
}

//Step2: Define auto-scaling group

data "aws_availability_zone" "available" {}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.my-test-launch-config.name}"
  vpc_zone_identifier = "${var.subnet_id}" //A list of subnet IDs to launch resources in, we will get this value from vpc module.
  availability_zones = ["${data.aws_availability_zone.available.name}"]
  target_group_arns = ["${var.target_group_arn}"]
  health_check_type = "ELB"
  max_size = 10
  min_size = 2
  tag {
    key = "Name"
    propagate_at_launch = false
    value = "my-test-asg"
  }
}
