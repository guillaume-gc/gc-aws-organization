variable "aws_region" {
  description = "AWS Region in which the AWS account is deployed."
  type        = string
  default     = "eu-west-1"
}

variable "identity_account_id" {
  description = "Identity AWS Account ID."
  type        = string
}