terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
} 
provider "aws" {    
    region = "us-east-2"
}

# Create s3 bucket to be protected
resource "aws_s3_bucket" "example" {
  bucket = "clumio-connect-example-bucket"
  tags = {
    "Key1" = "Value1"
  }
}