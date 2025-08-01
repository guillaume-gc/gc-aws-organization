variable "parent_id" {
  description = "Parent Organizational Unit ID or Root ID for the account."
  type        = string
}

variable "name" {
  description = "Account Name. It must be unique in the Organization."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "The name variable can contain only alphanumeric characters and hypens, and it cannot be empty."
  }
}