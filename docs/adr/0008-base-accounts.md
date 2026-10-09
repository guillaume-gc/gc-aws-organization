# 8. Base accounts and their baselines

- Status: Proposed
- Date: 2026-10-10

## Context

ADR 0006 decides how member accounts and their account baselines are deployed (separate stages, run in order by the pipeline). It does not decide which accounts the organization needs. This ADR does.

The **base accounts** are the member accounts the organization needs before any application account: accounts that hold organization-wide resources such as logs or security tooling. Applications are deployed elsewhere, not from this repository.

The organization already has two OUs, `Security` and `Infrastructure`. No member account is deployed yet.

AWS's reference layout (the Control Tower landing zone) uses a LogArchive account for the organization's logs and an Audit account for security tooling. Control Tower itself is not used (see ADR 0006), but the same split is a reasonable starting point.

Constraints: personal organization, keep running costs minimal.

## Options considered

### LogArchive

An account that only stores the organization's logs, isolated from the management account. Its first baseline is the bucket for the organization CloudTrail trail.

An organization trail can only be created from the management account or from a CloudTrail delegated administrator account. So the trail itself lives in the management account, and is deployed by the LogArchive baseline through its management account provider (see ADR 0006).

### SecurityTooling

An account that would act as delegated administrator for security services. Most of them cost money (GuardDuty, Security Hub, Config). Some are free at the organization level, such as IAM Access Analyzer for external access. Nothing in the organization needs it yet.

## Decision

Pending. Proposed:

- **LogArchive**, in the `Security` OU, with the organization CloudTrail baseline described below.
- **SecurityTooling**: to decide whether it is a base account now, and if so, what its baseline contains.

Still open for LogArchive:

- The log retention period.
- Whether the log bucket uses `force_destroy`. Without it, removing the baseline fails until the bucket is emptied by hand.

## Consequences

To be completed once a decision is made. The repository counts as stable (see ADR 0001) once every base account decided here is created, with its account baseline deployed.

## Implementation plan

### Prerequisites

- ADR 0006 is implemented: the accounts map, the baseline stages and the pipeline exist.

### Accounts

- Each base account is an entry of the ADR 0006 accounts map, with its OU.

### LogArchive baseline

- In the member account: an S3 bucket named with the `var.service_name` prefix, with public access blocked, a bucket policy allowing CloudTrail to write the organization's logs (`AWSLogs/<organization id>/*`, restricted by `aws:SourceArn` to the trail), and a lifecycle rule that expires logs after the retention period.
- Check the bucket policy against AWS's documented policy for organization trails before implementing. It may also need the management account's prefix (`AWSLogs/<management account id>/*`) and an `s3:GetBucketAcl` statement.
- In the management account: a multi-region organization trail (`is_organization_trail = true`) writing to the bucket, depending on the bucket policy. CloudTrail trusted access is already enabled in `organization.tf`. The first copy of management events is free, so the cost is S3 storage.

### Removal

- Removing the LogArchive baseline also deletes the organization trail, which stops logging for the whole organization. Check first that the logs are no longer needed.
- Terraform deletes the trail before the bucket, since the trail depends on it.

### Verification

- The trail is logging (`aws cloudtrail get-trail-status`) and log files reach the bucket. This needs AWS credentials, which are only used after the user agrees (see ADR 0003).
