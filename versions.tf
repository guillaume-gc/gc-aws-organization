terraform {
  required_version = ">= 1.9.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.59"
    }
  }

  backend "s3" {
    bucket = "gc-aws-organization-backend-bucket"
    region = "eu-west-1"
  }
}
