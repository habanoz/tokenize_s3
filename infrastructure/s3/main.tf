provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "tokenize_bucket" {
  bucket_prefix = "tokenize-bucket"
  force_destroy = true
}

output "instance_id" {
  value = aws_s3_bucket.tokenize_bucket.bucket
}