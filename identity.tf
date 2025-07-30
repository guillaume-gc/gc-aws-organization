data "aws_caller_identity" "current" {}

data "aws_organizations_organization" "org" {}

# data "aws_organizations_organizational_unit" "ou_security" {
#   parent_id = data.aws_organizations_organization.org.roots[0].id
#   name      = "Security"
# }

# data "aws_organizations_organizational_unit_child_accounts" "ou_security_accounts" {
#   parent_id = data.aws_organizations_organizational_unit.ou_security.id
# }

locals {
  management_account_id  = data.aws_caller_identity.current.account_id
  # log_archive_account_id = [for n in data.aws_organizations_organizational_unit_child_accounts.ou_security_accounts.accounts : n if n.name == "Log-Archive"][0].id
}

module "aws-iam-identity-center" {
  source = "aws-ia/iam-identity-center/aws"

  sso_groups = {
    Admin : {
      group_name        = "Admin"
      group_description = "Admin IAM Identity Center Group."
    }
  }

  permission_sets = {
    AdministratorAccess = {
      description          = "Provides AWS full access permissions.",
      session_duration     = "PT6H", // How long until session expires - PT6H means 6 hours. Max is 12 hours.
      aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }

    ViewOnlyAccess = {
      description          = "Provides AWS view only permissions.",
      session_duration     = "PT6H",
      aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
    }
  }

  account_assignments = {
    Admin : {
      principal_name  = "Admin"
      principal_type  = "GROUP"
      principal_idp   = "INTERNAL" // type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
      permission_sets = ["AdministratorAccess", "ViewOnlyAccess"]
      account_ids = [
        local.management_account_id,
        "262194309215",
      ]
    },
  }
}