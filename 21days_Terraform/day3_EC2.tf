#In order to deploy EC2 instance we need a bunch of resources AMI, Key Pair, EBS Volumes Creation, User data.

/*
The first step in deploying EC2 instance is choosing correct AMI and in terraform, there are various ways to do that:

-We can hardcore the value of AMI
-We can use data resource(finding)(similar to what we used for Availability Zone in VPC section) to query and filter AWS and
get the latest AMI based on the region, as the AMI id is different in a different region.

NOTE: Use of data resource is not ideal and each and every used case, eg: In the case of Production we might want to use a specific
version of CentOS.
*/

/*
The above code will help us to get the latest Centos AMI, the code is self-explanatory but one important parameter we used is owners
#owners – Limit search to specific AMI owners. Valid items are the numeric account ID, amazon, or self.
#most_recent – If more than one result is returned, use the most recent AMI.This is to get the latest Centos AMI as per our use case.

*/

#---------------------------------------------------AMI----------------------------------------------------------

data "aws_ami" "centos" {
  owners = ["473469341"]
  most_recent = true
  filter {
    name = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}

#----------------------------------------------KEY PAIR------------------------------------------------------------

/*Either we can hardcode the value of key pair or generate a new key via command line and then refer to this file.*/

resource "aws_key_pair" "mytest-key" {
  public_key = "${file(var.my_public_key)}" #will define in module
}


/* There is one more resource, I want to use here called template_file. The template_file data source renders a template from a
template string, which is usually loaded from an external file. This you can use with user_data resource to execute any script during
instance boot time
*/

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

/* userdata.tpl file will be like:

#!/bin/bash
yum -y install httpd
echo "hello from terraform" >> /var/www/html/index.html
service httpd start
chkconfig httpd on

*/

#let start building EC2 instance
resource "aws_instance" "my-test-instance" {
  ami = "${data.aws_ami.centos.id}"
  instance_type = "${var.instance_type}" #will define in module
  count = 2
  key_name = "${aws_key_pair.mytest-key.id}"
  vpc_security_group_ids = ["${var.security_group}"] #define in module
  subnet_id = "${element(var.subnets, count.index )}"
  user_data = "${data.template_file.init.rendered}"
  tags = {
    Name = "my-instance-${count.index+1}"
  }
}

/*

If you notice the above code, one thing which is interesting here is vpc_security_group_ids and subnet_id
The interesting part, we already created these as a part of VPC code, so we just need to call in our EC2 terraform and the way to do
it using outputs.tf.

*/

/* Let’s create two EBS volumes and attach it to two EC2 instances we created earlier */

resource "aws_ebs_volume" "my-test-ebs" {
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  count = 2
  size = 1  //size of volume
  type = "gp2"
}
resource "aws_volume_attachment" "my-vol-attach" {
  count = 2
  device_name = "/dev/xvdh"
  instance_id = "${aws_instance.my-test-instance.*.id[count.index]}"
  volume_id = "${aws_ebs_volume.my-test-ebs.*.id[count.index]}"
}

/*

As this time we are creating ebs volume, let’s modify our userdata.tpl script and format the partition
#!/bin/bash
mkfs.ext4 /dev/xvdh
mount /dev/xvdh /mnt
echo /dev/xvdh /mnt defaults,nofail 0 2 >> /etc/fstab

*/