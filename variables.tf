variable "git_branch_name" {
  description = "Name of the checked in Git Branch."
  type        = string
  default     = "main"
}

variable "aws_default_region" {
  description = "Default region for AWS provider."
  type        = string
  default     = "eu-west-1"
}

variable "resources_prefix" {
  description = "Generic prefix used to name resources to avoid naming collisions."
  type        = string
  default     = "gc-aws-organization"
}