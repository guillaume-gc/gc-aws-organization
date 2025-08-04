variable "git_branch_name" {
  description = "Name of the checked in Git Branch."
  type        = string
}

variable "aws_default_region" {
  description = "Default region for AWS provider."
  type        = string
}

variable "service_name" {
  description = "Name of the service managing resources."
  type        = string
}

variable "notification_emails" {
  description = "Alerts are sent to those emails."
  type        = list(string)
}