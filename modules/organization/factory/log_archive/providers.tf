provider "aws" {
  region = var.aws_region
  alias  = "log_archive"

  assume_role {
    role_arn    = "arn:aws:iam::${var.log_archive_account_id}:role/log-archive-root-role"
    external_id = "managemenent-log-archive-root-role"
  }
}

