output "public_ip" {
  value = aws_instance.MyFirstInstance.public_ip
  description = "This is Public IP of Instance."
}