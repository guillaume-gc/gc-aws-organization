variable "email_addresses" {
  description = "List of email addresses for all budget related notifications."
  type        = list(string)
  default     = []
}

variable "forecasted_absolute_threshold" {
  description = "Threshold for when the forecasted notification should be sent."
  type        = number
  default     = 0
}

variable "actual_absolute_threshold" {
  description = "Threshold for when the actual notification should be sent."
  type        = number
  default     = 0
}