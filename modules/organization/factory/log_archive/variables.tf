variable "aws_region" {
  description = "AWS Region in which the AWS account is deployed."
  type        = string
  default     = "eu-west-1"
}

variable "log_archive_account_id" {
  description = "Log Archive AWS Account ID."
  type        = string
}

variable "resources_prefix" {
  description = "Generic prefix used to name resources to avoid naming collisions."
  type        = string
}