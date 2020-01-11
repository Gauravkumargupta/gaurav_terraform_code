variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_cidrs" {
  type = "list"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidrs" {
  type = "list"
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "alarms_email" {}

variable "sns_topic" {}

variable "instance_id" {}

variable "db_instance" {}

variable "rds_subnet1" {}

variable "rds_subnet2" {}

variable "vpc_id" {}