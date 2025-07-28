provider "aws" {
  region = var.aws_region
  alias  = "infrastructure"

  assume_role {
    role_arn    = "arn:aws:iam::${var.identity_account_id}:role/identity-root-role"
    external_id = "managemenent-identity-root-role"
  }
}