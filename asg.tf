resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"
  max_size = 5
  min_size = 2
  tags {
    key = "Name"
    propagate_at_launch = true
    value = "terraform-asg-example"
  }
}