data "aws_caller_identity" "current" {}

locals {
  management_account_id = data.aws_caller_identity.current.account_id
}

# module "aws-iam-identity-center" {
#   source = "aws-ia/iam-identity-center/aws"
#
#   sso_groups = {
#     Administrator : {
#       group_name        = "Administrator"
#       group_description = "Admin IAM Identity Center Group."
#     }
#   }
#
#   permission_sets = {
#     AdministratorAccess = {
#       description          = "Provides AWS full access permissions.",
#       session_duration     = "PT6H", // How long until session expires - PT6H means 6 hours. Max is 12 hours.
#       aws_managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
#     }
#
#     ViewOnlyAccess = {
#       description          = "Provides AWS view only permissions.",
#       session_duration     = "PT6H",
#       aws_managed_policies = ["arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
#     }
#   }
#
#   account_assignments = {
#     Administrator : {
#       principal_name  = "Administrator"
#       principal_type  = "GROUP"
#       principal_idp   = "INTERNAL" // type of Identity Provider you are using. Valid values are "INTERNAL" (using Identity Store) or "EXTERNAL" (using external IdP such as EntraID, Okta, Google, etc.)
#       permission_sets = ["AdministratorAccess", "ViewOnlyAccess"]
#       account_ids = [
#         local.management_account_id,
#       ]
#     },
#   }
# }