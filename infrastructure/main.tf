provider "aws" {
    region = "eu-central-1"
}

resource "aws_s3_bucket" "tokenized" {
  bucket = "tokenized"
  force_destroy = true
}