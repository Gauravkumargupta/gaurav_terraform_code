resource "aws_iam_user" "example" {
  count = "${length(var.username)}"
  name = "${element(var.username,count.index )}"
}
data "aws_iam_policy_document" "example" {
  statement {
    actions = [
      "ec2:Describe*"]
    resources = [
      "*"]
  }
}
resource "aws_iam_policy" "example" {
  policy = "${data.aws_iam_policy.example.json}"
  name = "ec2-read-only"
}
resource "aws_iam_user_policy_attachment" "test-attach" {
  policy_arn = "${aws_iam_policy.example.arn}"
  user = "${element(aws_iam_user.example.*.name,count.index )}"
  count = "${length(var.username)}"
}

#Give EC2 instance access to S3 bucket
#Step-1 Create an IAM role
resource "aws_iam_role" "test_role" {
  name = "test_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    tag-key = "tag-value"
  }
}

#Step-2 Create EC2 Instance Profile:

resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = "${aws_iam_role.test_role.name}"
}

#Step-3 Adding IAM Policies, To give full access to S3 bucket

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#Step4: Attach this role to EC2 instance

resource "aws_instance" "role-test" {
  name = ""
  ami = "ami-0bbe6b35405ecebdb"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
  key_name = "mytestpubkey"
}