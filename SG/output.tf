output "sg_output" {
  value = "aws_security_group.my_first_sg.*.id"
  description = "ID of SG"
}