output "pulic_subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "security_group" {
  value = "${aws_security_group.test_sg.id}"
}

output "vpc_id" {
  value = "${aws_vpc.test_vpc.id}"
}

output "instance1_id" {
  value = "${element(aws_instance.my-test-instance.*.id,1 )}"
}

output "instance2_id" {
  value = "${element(aws_instance.my-test-instance.*.id,2 )}"
}

/*
element(list, index) – Returns a single element from a list at the given index. If the index is greater than the number of elements,
this function will wrap using a standard mod algorithm. This function only works on flat lists.
*/

output "subnet1" {
  value = "${element(aws_subnet.public_subnet.*.id,1 )}"
}

output "subnet2" {
  value = "${element(aws_subnet.public_subnet.*.id,2 )}"
}

output "sns_arn" {
  value = "${aws_sns_topic.my-test-alarm.arn}"
}

output "private_subnet1" {
  value = "${element(aws_subnet.private_subnet.*.id, 1 )}"
}
output "private_subnet2" {
  value = "${element(aws_subnet.private_subnet.*.id, 2 )}"
}

output "user_arn" {
  value = "${aws_iam_user.example.*.arn}"
}