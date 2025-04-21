resource "aws_organizations_organization" "organization" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "account.amazonaws.com",
    "ram.amazonaws.com"
  ]

  feature_set = "ALL"
}

module "global_budget" {
  source = "./modules/monitoring/budget/global"

  email_addresses = [
    "gc.alert@pm.me"
  ]

  forecasted_absolute_threshold = 1
  actual_absolute_threshold     = 1
}