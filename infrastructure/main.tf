provider "aws" {
    region = "eu-central-1"
}

resource "aws_s3_bucket" "tokenize_bucket" {
  bucket_prefix = "tokenize-bucket"
  force_destroy = true
}