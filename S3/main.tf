provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "terraform-state" {
  bucket = "gaurav-3333-terraform"
  # Basically it prevents accidental deletion of S3 bucket.
  lifecycle {
    prevent_destroy = true
  }
  #Enable versioning to see full revision history of our state files.
  versioning {
    enabled = true
  }
  #Enable server-side encryption(SSE)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  hash_key = "LockID"
  name = "terraform-test-locks"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
}
terraform {
  backend "s3" {
    # Your bucket name
    bucket = "gaurav-3333-terraform"
    key = "gaurav/s3/terraform.tfstate"
    region = "us-east-1"
    # DynamoDB table name
    dynamodb_table = "terraform-test-locks"
    encrypt = true
  }
}