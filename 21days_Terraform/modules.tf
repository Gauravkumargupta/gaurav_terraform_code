#Terraform Module
/*
You can think of Terraform Module like any other language module eg: Python,
It’s the same terraform file but just that after creating a module out it we can re-use that code OR
Instead copy-pasting the code the same code in different places we can turn into reusable modules.

------> Syntax------->:

module "NAME" {
  source = "SOURCE"
  [CONFIG...]
}

Example: Day-2

module "vpc" {
  source = "./vpc"
  public_cidrs = ["10.0.1.0/24","10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24","10.0.4.0/24"]
}

./vpc - vpc is a folder where the module code can be found.

*/

#Example: Day-3

module "ec2" {
  source = ""
  my_public_key = "tmp/id_rsa.pub"
  instance_type = "t2.micro"
  security_group = "${module.ec2.security_group}"
  subnets = "${module.ec2.pulic_subnets}"
}

#Day-6
module "sns_topic" {
  source = ""
  alarms_email = "kumargaurav1247@gmail.com"
}

#Day-10
module "route53" {
  source = ""
  hostname = ["test1", "test2"]
  arecord = ["10.0.1.11", "10.0.1.12"]
  vpc_id = "${module.vpc.vpc_id}"
}