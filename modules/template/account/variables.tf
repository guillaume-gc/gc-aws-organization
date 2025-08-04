variable "parent_id" {
  description = "Parent Organizational Unit ID or Root ID for the account."
  type        = string
}

variable "name" {
  description = "Account Name. It must be unique in the Organization."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.name))
    error_message = "The name variable can contain only alphanumeric characters, and it cannot be empty."
  }
}

variable "service_name" {
  description = "Name of the service managing resources."
  type        = string
}