provider "aws" {
  region = var.aws_default_region
  alias  = "management"

  default_tags {
    tags = {
      GitBranch = var.git_branch_name
      Service   = var.service_name
      ManagedBy = "Terraform"
    }
  }
}