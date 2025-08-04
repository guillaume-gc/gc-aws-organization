provider "aws" {
  region = var.aws_default_region
  alias  = "log_archive"

  assume_role {
    role_arn    = "arn:aws:iam::262194309215:role/log-archive-root-role"
    external_id = "managemenent-log-${var.log_archive_account_id}-${var.log_archive_account_role_name}"
  }

  default_tags {
    tags = {
      GitBranch = var.git_branch_name
      Service   = var.service_name
      ManagedBy = "Terraform"
    }
  }
}
