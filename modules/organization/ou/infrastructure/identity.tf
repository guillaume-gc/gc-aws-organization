module "identity_account" {
  source = "../../template/account"

  name      = "Identity"
  parent_id = aws_organizations_organizational_unit.infrastructure.id
}

module "identity_account_factory" {
  source = "../../factory/identity"

  identity_account_id = module.identity_account.account_id

  providers = {
    aws = aws.infrastructure
  }
}