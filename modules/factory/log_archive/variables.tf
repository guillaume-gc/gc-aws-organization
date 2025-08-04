variable "aws_default_region" {
  description = "AWS Region in which the AWS account is deployed."
  type        = string
}

variable "log_archive_account_id" {
  description = "Log Archive AWS Account ID."
  type        = string
}

variable "log_archive_account_role_name" {
  description = "Log Archive AWS Account IAM Role name to assume for access."
  type        = string
}

variable "cloudtrail_logs_bucket_name" {
  description = "CloudTrail logs bucket name. Must be specified outside of the module to avoid circular dependency."
  type        = string
}

variable "cloudtrail_trail_arn" {
  description = "Trail ARN. The Trail should be in Security Tooling account."
  type        = string
}

variable "service_name" {
  description = "Name of the service managing resources."
  type        = string
}

variable "git_branch_name" {
  description = "Name of the checked in Git Branch."
  type        = string
}
