module "security_tooling_account" {
  source = "../../template/account"

  name      = "Security-Tooling"
  parent_id = aws_organizations_organizational_unit.security.id
}
