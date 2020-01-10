/*
So far we build VPC and EC2, let’s build Application Load Balancer and add two instances behind it. This is going to be a modular
approach i.e we are going to get vpc id,subnet1 and subnet2 created during the VPC module and instance id from EC2 module.

Support Path and Host-based routing(which let you route traffic to different target group)

#Key Terms
Target Group, Target Types, Instance types, Health Check
*/

#Step-1 Define Target Group:

resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 5
    unhealthy_threshold = 2
  }
  name = "my-test-tg"
  target_type = "Instance"
  protocol = "HTTP"
  port = 80
  vpc_id = "${var.vpc_id}"  //add in outputs.tf
}

/*

health_check: Your Application Load Balancer periodically sends requests to its registered targets to test their status.
These tests are called health checks.

Interval: The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum
value 300 seconds. Default 30 seconds.

path: The destination for the health check request.

protocol: The protocol to use to connect with the target. Defaults to HTTP

timeout:The amount of time, in seconds, during which no response means a failed health check. For Application Load Balancers,
the range is 2 to 60 seconds and the default is 5 seconds

healthy_threshold: number of consecutive health checks successes required before considering an unhealthy target healthy.Defaults to 3.

unhealthy_threshold: The number of consecutive health check failures required before considering the target unhealthy.

Matcher: The HTTP codes to use when checking for a successful response from a target. You can specify multiple values
(for example, "200,202") or a range of values (for example, "200-299")

name: The name of the target group. If omitted, Terraform will assign a random, unique name.

port: The port on which targets receive traffic

protocol: The protocol to use for routing traffic to the targets. Should be one of "TCP", "TLS", "HTTP" or "HTTPS".
Required when target_type is instance or ip

vpc_id:The identifier of the VPC in which to create the

target group. This value we will get from the VPC module we built earlier

target_type: Type of target that you must specify when registering targets with this target group. Instance id, ip address, containers.

*/
#Step-2 Provides the ability to register instances with an Application Load Balancer (ALB)

resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id = "${var.instance1_id}"
  port = 80
}
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  target_id = "${var.instnace1_id}"
  port = 80
}

#Step3: Define the load balancer

resource "aws_lb" "my-aws-lb" {
  name = "my-aws-lb"
  internal = false

  security_groups = [
    "${aws_security_group.my-alb-sg.id}"
  ]
  subnets = [
    "${var.subnet1}",
    "${var.subnet2}",
  ]
  tags = {
    Name = my-test-alb
  }
  ip_address_type = "ipv4"
  load_balancer_type = "appliction"

}

#Step4:  Security group used by ALB

resource "aws_security_group" "my-alb-sg" {
  name = "my-alb-sg"
  vpc_id = "${aws_vpc.test_vpc.id}"
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port = 22
  protocol = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port = 22
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port = 80
  type = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port = 0
  protocol = "-1"
  security_group_id = "${aws_security_group.my-alb-sg.id}"
  to_port = 0
  type = "egress"
  cidr_blocks = ["0.0.0.0/0"]
}

#Step5: Provides a Load Balancer Listener resource

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.my-aws-lb.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  }
}