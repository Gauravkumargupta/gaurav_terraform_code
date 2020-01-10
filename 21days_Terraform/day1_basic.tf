provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "test_key" {
  public_key = ""
  key_name = "test"
}

resource "aws_security_group" "test_sg" {
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [0.0.0.0/0]
  }
}
resource "aws_instance" "test_instance" {
  ami = "ami-01ed306a12b7d1c96"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.test_sg.id}"]
  key_name = ["${aws_key_pair.test_key.id}"]
  tags {
    Name="my-ec2-instance"
  }
}

#terraform  fmt: run terraform fmt command which will rewrite terraform configuration files to a canonical format and style.

#terraform init: what this will do is going to download code for a provider(aws) that we are going to use, It’s safe to run terraform
#init command multiple times as it’s idempotent.

#terraform plan: this will tell what terraform actually do before making any changes,This is good way of making any sanity check
#before making actual changes to env Output of terraform plan command looks similar to Linux diff command.

1: (+ sign): Resource going to be created

2: (- sign): Resources going to be deleted

3: (~ sign): Resource going to be modified

#To apply these changes, run "terraform apply"

#If you have modified something after running "terraform apply" then  run terraform plan again to see what changes have been made.

#Now if we can think about it, how does terraform knows that there only change in the tag parameter and nothing else
#Terraform keep track of all the resources it already created in .tfstate files, so its aware of the resources that already exist.

#In most of the cases we are working in team where we want to share this code with rest of team members and the best way to share code is by using GIT

git add main.tf
git commit -m "first terraform EC2 instance"
vim .gitignore
git add .gitignore
git commit -m "Adding gitignore file for terraform repository"

#Via .gitignore we are telling terraform to ignore(.terraform folder(temporary directory for terraform)and all *.tfstates file(as this file may contain secrets))

cat .gitignore

.terraform
*.tfstate
*.tfstate.backup

#Create a shared git repository
git remote add origin https://github.com/<user name>/terraform.git

git push -u origin master

