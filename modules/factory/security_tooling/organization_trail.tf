resource "aws_cloudtrail" "organization_trail" {
  name = var.cloudtrail_trail_name

  provider = aws.security_tooling

  s3_bucket_name = var.s3_trail_log_bucket_name

  enable_log_file_validation    = true
  is_multi_region_trail         = true
  is_organization_trail         = true
  include_global_service_events = true

  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = []
  }
}