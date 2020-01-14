/*
provider "aws" {
  region = ""
}
*/
resource "aws_s3_bucket" "my-test-bucket" {
  bucket = "${var.s3_bcuket_name}"
  acl = "private"
  versioning {
    enabled = true
  }
  tags = {
    Name = "gaurav_47_test_bucket"
  }
}

/*
NOTE: Every S3 bucket must be unique and that why random id is useful to prevent our bucket to collide with others.
To implement that let use random_id as providers

resource "random_id" "my-random-id" {
  byte_length = 2
}

byte_length – The number of random bytes to produce. The minimum value is 1, which produces eight bits of randomness.

*/

resource "random_id" "my-random-id" {
  byte_length = 2
}

resource "aws_s3_bucket" "my-test-bucket" {
  bucket = "${var.s3_bucket_name}-${random_id.my-random-id.dec}"
  acl = "private"
  versioning {
    enabled = true
  }
  lifecycle_rule {
    enabled = true
    transition {
      storage_class = "STANDARD_IA"
      days = 30
    }
  }
  tags = {
    Name= "gaurav_47_test_bucket1"
  }
}


