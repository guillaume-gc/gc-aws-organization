module "log_archive_account" {
  source = "../../template/account"

  name      = "Log-Archive"
  parent_id = aws_organizations_organizational_unit.security.id
}
