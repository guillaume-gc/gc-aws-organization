module "log_archive_account" {
  source = "../../template/account"

  name      = "Log-Archive"
  parent_id = aws_organizations_organizational_unit.security.id
}

module "log_archive_factory" {
  source = "../../factory/log_archive"

  log_archive_account_id = module.log_archive_account.account_id
  resources_prefix       = var.resources_prefix
}