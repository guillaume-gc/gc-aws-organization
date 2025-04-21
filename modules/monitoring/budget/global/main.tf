resource "aws_budgets_budget" "global" {
  name         = "budget-global-monthly"
  budget_type  = "COST"
  limit_amount = "1"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.forecasted_absolute_threshold
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.email_addresses
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = var.actual_absolute_threshold
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.email_addresses
  }
}