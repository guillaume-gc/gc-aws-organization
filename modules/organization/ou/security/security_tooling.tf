module "security_tooling_account" {
  source = "../../template/account"

  name      = "Security-Tooling"
  parent_id = aws_organizations_organizational_unit.security.id
}

resource "aws_cloudtrail_organization_delegated_admin_account" "delegated_admin_account" {
  account_id = module.security_tooling_account.account_id
}
