provider "aws" {
  region = var.aws_default_region
  alias  = "management"
}

provider "aws" {
  region = var.aws_default_region
  alias  = "infrastructure"

  assume_role {
    role_arn    = "arn:aws:iam::610420547454:role/identity-root-role"
    external_id = "managemenent-identity-root-role"
  }
}