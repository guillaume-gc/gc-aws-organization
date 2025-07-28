provider "aws" {
  region = var.aws_default_region
  alias  = "management"

  default_tags {
    tags = {
      GitBranch = var.git_branch_name
      Service   = var.resources_prefix
      ManagedBy = "Terraform"
    }
  }
}