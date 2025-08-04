variable "aws_default_region" {
  description = "AWS Region in which the AWS account is deployed."
  type        = string
}

variable "security_tooling_account_id" {
  description = "Security Tooling AWS Account ID."
  type        = string
}

variable "security_tooling_account_role_name" {
  description = "Security Tooling AWS Account IAM Role Name to assume for access."
  type        = string
}

variable "service_name" {
  description = "Name of the service managing resources."
  type        = string
}

variable "cloudtrail_trail_name" {
  description = "Name of the CloudTrail trail. It is defined outside of the module to avoid circular dependency."
}

variable "s3_trail_log_bucket_name" {
  description = "Name of the S3 bucket in which trail logs will be sent. This bucket should be located in log archive account."
}

variable "git_branch_name" {
  description = "Name of the checked in Git Branch."
  type        = string
}