resource "aws_cloudwatch_metric_alarm" "cpu-utilization" {
  alarm_name = "high-cpu-utilization-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  //The number of periods over which data is compared to the specified threshold.
  threshold = "80"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  //The period in seconds over which the specified statistic is applied.
  statistic = "Average"
  //The statistic to apply to the alarm’s associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions = [
    "${var.sns_topic}"]
  dimensions = {
    //The dimensions for the alarm’s associated metric.
    InstanceId = "${var.instance_id}"
  }
}

