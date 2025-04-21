data "aws_organizations_organization" "root" {}

locals {
  root_organization_id = data.aws_organizations_organization.root.roots.0.id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = local.root_organization_id
}

module "identity_account" {
  source = "../../account/default"

  parent_id = aws_organizations_organizational_unit.infrastructure.id
  name      = "Identity"
}