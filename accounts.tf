module "log_archive_account" {
  source = "./modules/template/account"

  name         = "LogArchive"
  parent_id    = aws_organizations_organizational_unit.security.id
  service_name = var.service_name
}

module "audit_account" {
  source = "./modules/template/account"

  name         = "Audit"
  parent_id    = aws_organizations_organizational_unit.security.id
  service_name = var.service_name
}

module "security_tooling_account" {
  source = "./modules/template/account"

  name         = "SecurityTooling"
  parent_id    = aws_organizations_organizational_unit.security.id
  service_name = var.service_name
}

resource "aws_cloudtrail_organization_delegated_admin_account" "delegated_admin_account" {
  account_id = module.security_tooling_account.account_id
}