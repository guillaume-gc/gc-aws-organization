resource "aws_s3_bucket" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = "${var.resources_prefix}-cloudtrail-logs-${var.log_archive_account_id}"
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  provider = aws.log_archive
  bucket   = aws_s3_bucket.cloudtrail_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}
