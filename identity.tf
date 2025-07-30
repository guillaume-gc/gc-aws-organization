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
}