provider "aws" {
  region = var.aws_default_region
  alias  = "management"
}