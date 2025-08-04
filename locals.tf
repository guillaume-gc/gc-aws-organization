locals {
  cloudtrail_logs_bucket_name = "${var.service_name}-trail-logs-${module.log_archive_account.account_id}"
  cloudtrail_trail_name       = "${var.service_name}-organization_trail"
}
