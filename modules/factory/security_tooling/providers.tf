provider "aws" {
  region = var.aws_default_region
  alias  = "security_tooling"

  assume_role {
    role_arn    = "arn:aws:iam::${var.security_tooling_account_id}:role/${var.security_tooling_account_role_name}"
    external_id = "managemenent-log-${var.security_tooling_account_id}-${var.security_tooling_account_role_name}"
  }

  default_tags {
    tags = {
      GitBranch = var.git_branch_name
      Service   = var.service_name
      ManagedBy = "Terraform"
    }
  }
}
