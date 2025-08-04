module "log_archive_account" {
  source = "./modules/template/account"

  name         = "LogArchive"
  parent_id    = aws_organizations_organizational_unit.security.id
  service_name = var.service_name
}

module "log_archive_factory" {
  source = "./modules/factory/log_archive"

  log_archive_account_id        = module.log_archive_account.account_id
  log_archive_account_role_name = module.log_archive_account.account_role_name
  cloudtrail_logs_bucket_name   = local.cloudtrail_logs_bucket_name
  cloudtrail_trail_arn          = "arn:aws:cloudtrail:eu-west-1:${module.security_tooling_account.account_id}:trail/${local.cloudtrail_trail_name}"
  git_branch_name               = var.git_branch_name
  service_name                  = var.service_name
  aws_default_region            = var.aws_default_region

}

module "security_tooling_account" {
  source = "./modules/template/account"

  name         = "SecurityTooling"
  parent_id    = aws_organizations_organizational_unit.security.id
  service_name = var.service_name
}

resource "aws_cloudtrail_organization_delegated_admin_account" "delegated_admin_account" {
  account_id = module.security_tooling_account.account_id
}

module "security_tooling_factory" {
  source = "./modules/factory/security_tooling"

  security_tooling_account_id        = module.security_tooling_account.account_id
  security_tooling_account_role_name = module.security_tooling_account.account_role_name

  // Using module.log_archive_factory.trail_arn ensure the trail will be created after Log Archive Bucket Policy, which is required to use this bucket as the trail destination.
  cloudtrail_trail_name = module.log_archive_factory.trail_arn

  s3_trail_log_bucket_name = local.cloudtrail_logs_bucket_name
  git_branch_name          = var.git_branch_name
  service_name             = var.service_name
  aws_default_region       = var.aws_default_region
}