# 3. Orchestrate account creation and account baselines

- Status: Proposed
- Date: 2026-09-27

## Context

The repository is a single Terraform root module with a single state (`main.tfstate`), applied from the management account. It can create member accounts through `modules/template/account` (no member account is currently deployed, see commit `fc5edd6`), but it cannot deploy baseline resources *into* those accounts in the same apply.

An attempt was made and then removed (see commit `203a39b`, "remove factory"). It used modules `modules/factory/log_archive` and `modules/factory/security_tooling`, each declaring its own `provider "aws"` that assumed the new account's role using `module.<account>.account_id`. It failed for these reasons:

1. **Provider settings must be known at plan time.** On the first apply, the account ID is unknown, so the provider for that account cannot be set up. It either errors or works only on a second apply.
2. **New accounts are not ready right away.** `CreateAccount` runs asynchronously, and the new account's role cannot be assumed for a while after it exists. That gives intermittent `AccessDenied` errors.
3. **Destroying is fragile.** Removing an account and the provider that reaches into it in the same change leaves resources Terraform can no longer reach.
4. **A provider declared inside a module** stops you from using `for_each`/`count`, so one generic "account + baseline" module cannot be reused per account.

In this ADR, an **account baseline** is the set of resources that one member account needs once it exists (for example, the CloudTrail log bucket in LogArchive). It is distinct from creating the account itself, which happens in the management account.

Needed baselines include, for example, the organization CloudTrail bucket in LogArchive and the organization trail. An organization trail can only be created from the management account or from a CloudTrail delegated administrator account. The trail depends on the bucket, and the bucket depends on the LogArchive account, so the trail cannot be created in the same apply as the account either.

Member accounts are reached through the role created by `aws_organizations_account` (`<service_name>_<name>_Root`), which the deploy role in the management account assumes.

Constraints: personal organization, keep running costs minimal, GitHub Actions as the only deployment path.

## Options considered

### A. Separate states per stage, run in order by the pipeline

- Stage 1 (`organization`) covers the organization, OUs, accounts, Identity Center and the delegated admins. It outputs account IDs and role names.
- Stage 2 (`baselines/<AccountName>`) is one root module per account (or one shared module used per account). Its provider assumes the account role, and it reads stage 1 outputs through `terraform_remote_state` or SSM parameters. A stage can also declare a management account provider for resources that must live there but depend on the account's baseline, such as the organization trail in the LogArchive stage.
- A GitHub Actions job dependency (`needs:`) enforces the order, with a matrix over accounts for stage 2.

**Pros:** plain Terraform, no extra tools, no extra AWS cost. Provider settings are always known at plan time (fixes 1), and each baseline root module owns its provider (fixes 4).
**Cons:**
- The pipeline glue has to be written and maintained, and each stage has its own state and backend key.
- Account readiness (2) remains on the first creation, since stage 2 runs right after stage 1. It needs a step that retries assuming the account role before stage 2, or a manual re-run.
- Destroy order (3) becomes a process: remove the account's baseline stage in one push, then the account in a later push. A mistake is costly because accounts use `close_on_deletion = true`.
- Every stage runs `terraform apply -auto-approve` on push, so more states mean more unreviewed applies.

### B. Terragrunt (or Terramate) with a dependency graph

The same split as A, but ordering and output passing are declared (`dependency` blocks) instead of hand-written in the pipeline.

**Pros:** less pipeline glue, `run-all plan/apply`, handles many accounts cleanly. Moving from A to B later is cheap, since the state split is the same.
**Cons:** one more tool to learn, pin and install in CI. Account readiness (2) and destroy order (3) remain as in A.

### C. AWS Control Tower

Control Tower sets up a landing zone: LogArchive and Audit accounts, an organization trail, Config and controls (guardrails). Account Factory creates accounts with a baseline.

**Pros:** AWS-managed baseline and account vending, well-documented. Since the landing zone APIs (November 2023), the landing zone, controls and OU baselines can be managed as code (`aws_controltower_landing_zone`, `aws_controltower_control`, `aws_controltower_baseline`). No member account is currently deployed, so there is nothing to migrate.
**Cons:**
- Running costs (Config recording in every governed region, and so on), which go against the minimal-cost constraint.
- Prerequisites (LogArchive and Audit accounts, four service roles) must exist before the landing zone is created.
- Account Factory vends accounts through Service Catalog (`aws_servicecatalog_provisioned_product` in Terraform), which is awkward to manage and debug.
- Landing zone and baseline versions are driven by AWS and must be upgraded regularly. Tooling is still rough: for example, the Terraform provider replaces `aws_controltower_baseline` on a version change instead of updating it (hashicorp/terraform-provider-aws#45871).
- Drift on Control Tower-managed resources is repaired through Control Tower, not Terraform.
- Custom baselines still need something else (CfCT, AFT or StackSets), so it does not solve this problem on its own.

### D. Account Factory for Terraform (AFT)

A Terraform-based account vending pipeline on top of Control Tower. It creates accounts from requests and applies global and per-account customizations.

**Pros:** built for exactly this problem, and stays Terraform.
**Cons:** requires Control Tower (all the cons of C), and deploys a lot of infrastructure (CodePipeline, CodeBuild, DynamoDB, Lambda, Step Functions) that costs money. Heavy for a personal organization.

### E. CloudFormation StackSets with service-managed permissions

The single state manages `aws_cloudformation_stack_set` resources with `permission_model = "SERVICE_MANAGED"` and `auto_deployment` enabled, targeting OUs from the management account. AWS deploys the stack into every account in the OU, including accounts added later, and waits for them to be ready.

**Pros:** single state, no provider per account (fixes 1 and 4), AWS handles account readiness (fixes 2), and stack instances are removed when an account leaves the OU (fixes 3). No extra cost.
**Cons:**
- Baselines are written in CloudFormation, not Terraform. Two IaC languages in the repository.
- Outputs from stack instances do not flow back into Terraform easily.
- Suited to "every account in the OU gets X" baselines, not to resources specific to one account (such as the trail bucket in LogArchive), unless each such account gets its own OU or StackSet.
- Cannot target the management account.

### F. Rejected up front

- **Keep a single state and apply twice, or use `-target`:** not reproducible, and it breaks the push-to-apply pipeline.
- **Terraform Stacks:** handle unknown provider settings natively with deferred changes, but require HCP Terraform, while this repository uses an S3 backend and GitHub Actions.

## Decision

Pending. Option A is recommended: it fits the cost and tooling constraints, and it can move to Option B later without changing the state split.

## Consequences

To be completed once a decision is made.

## Implementation plan (if Option A is chosen)

### Layout

```
.                        # stage 1: organization (key main.tfstate, unchanged)
└── baselines/
    ├── LogArchive/      # stage 2: key baselines/LogArchive.tfstate
    └── SecurityTooling/ # stage 2: key baselines/SecurityTooling.tfstate
```

- Stage 1 stays at the repository root, so its state needs no migration. Terraform only loads the `.tf` files of the directory it runs in, so the root apply ignores `baselines/`.
- Each baseline directory is named exactly after its account name (as passed to `modules/template/account`). The directory name is the key used to look up the account in the stage 1 outputs, the backend key and the pipeline matrix entry.

### Prerequisites

- ADR 0004 (mise) is implemented first. The pipeline and local commands below use its tasks.
- State locking and concurrency are added first, independently of this ADR, since they are already missing with a single state:
  - Every stage's backend uses S3 native locking (`use_lockfile = true`). The deploy role needs `s3:PutObject` and `s3:DeleteObject` on the `.tflock` keys.
  - `on_push_main.yml` gets a `concurrency` group (without `cancel-in-progress`), so two pushes never apply at the same time.

### Stage 1 changes

- Declare member accounts in one map keyed by account name, whose values describe the account (for example `{ parent_ou_id = ... }`), and create them with `for_each` over `modules/template/account`.
- Add an `accounts` output: account name → `{ id, role_name }`.
- In `identity.tf`, add the member account IDs from that map to the `Admin` group assignment, so the new accounts are reachable through IAM Identity Center.

### Stage 2 structure (per account)

- Files: `versions.tf` (required Terraform and provider versions, empty `backend "s3" {}`), `providers.tf`, `variables.tf`, the resources, and a committed `.terraform.lock.hcl`.
- Inputs: `aws_default_region`, `service_name`, `git_branch_name` and `state_bucket`. In CI they come from the repository variables (`CICD_TERRAFORM_STATE_BUCKET` for `state_bucket`). Locally they come from the settings defined in ADR 0004.
- `terraform_remote_state` on `main.tfstate` (using `state_bucket` and `aws_default_region`) to read the `accounts` output.
- Two providers: the management account (pipeline credentials) and the member account (`assume_role` on `arn:aws:iam::<id>:role/<role_name>`). Both set the same `default_tags` as stage 1 (`GitBranch`, `Service`, `ManagedBy`).

### LogArchive baseline

- In the member account: an S3 bucket named with the `var.service_name` prefix, with public access blocked, a bucket policy allowing CloudTrail to write the organization's logs (`AWSLogs/<organization id>/*`, restricted by `aws:SourceArn` to the trail), and a lifecycle rule that expires logs after a retention period to decide (for running costs).
- Decide whether the bucket uses `force_destroy`. Without it, removing the baseline fails until the bucket is emptied by hand.
- In the management account: a multi-region organization trail (`is_organization_trail = true`) writing to the bucket, depending on the bucket policy. CloudTrail trusted access is already enabled in `organization.tf`. The first copy of management events is free, so the cost is S3 storage.

### Pipeline

- Move the shared steps (checkout, mise and Terraform setup, credentials, init, apply) into a composite action that takes the working directory and the backend key.
- `terraform fmt -check -recursive` covers every stage, so it runs once, in the `organization` job. `terraform validate` runs in every job.
- `deploy.yml` gets two jobs: `organization`, then `baselines` with `needs: organization`, a static matrix of baseline directories and `fail-fast: false`.
- Before applying a baseline, a script waits for the account: it finds the account ID by name with `aws organizations list-accounts` (management credentials, no stage 1 init needed), then retries `aws sts assume-role` on the account role (for example every 30 seconds for up to 10 minutes). The AWS CLI is preinstalled on GitHub runners.

### Manual prerequisites (outside Terraform, see ADR 0001)

- Allow the deploy role `sts:AssumeRole` on `arn:aws:iam::*:role/<service_name>_*_Root`.
- Extend the deploy role's state bucket permissions to `baselines/*`, including the `.tflock` keys.
- Make sure the deploy role can call `organizations:ListAccounts`.
- Add these to the manual prerequisites in `CLAUDE.md` and the README.

### Documentation and runbooks

- `CLAUDE.md`: layout (`baselines/`, `docs/runbooks/`), commands per stage, and the two-job deployment.
- README: prerequisites and layout.
- `docs/runbooks/add-account.md`:
  1. Add the account to the stage 1 map.
  2. Create `baselines/<AccountName>/`, starting from an existing baseline.
  3. Add the directory to the pipeline matrix.
  4. Push, then check the result (see Verification).
- `docs/runbooks/remove-account.md`. Deleting a baseline directory destroys nothing: the pipeline stops running it and its state is left behind. So:
  1. Check that the data the baseline holds (such as logs) is no longer needed. For LogArchive, removing the baseline also deletes the organization trail, which stops logging for the whole organization.
  2. Empty the bucket if it does not use `force_destroy`.
  3. Remove all resources from the baseline directory (keep the backend, providers and variables) and push, so the apply destroys them. Terraform deletes the trail before the bucket, since the trail depends on it.
  4. Remove the account from the pipeline matrix and from the stage 1 map, delete the baseline directory, and push. The account is closed (`close_on_deletion = true`).
  5. Delete the stage's state file from the state bucket.

### Verification

- Before each push: `fmt` and `validate` on every changed stage, then `plan` on each stage locally. Running `plan` needs AWS credentials, which are only used after the user agrees (see `CLAUDE.md`). A stage 2 `plan` cannot run before its account exists, so the first time only `validate` applies to it.
- After the first run:
  - The account exists in the right OU.
  - The `baselines` job succeeded.
  - The trail is logging (`aws cloudtrail get-trail-status`) and log files reach the bucket.
  - The account is reachable through IAM Identity Center.

### Commits

1. `fix(cicd)`: state locking and the `concurrency` group. Independent of this ADR, can be done now.
2. The ADR 0004 commits.
3. `feat(cicd)`: composite action and the two-job `deploy.yml`, stage 1 only (no behavior change).
4. `feat(account)`: accounts with `for_each` and the `accounts` output. Pushing it creates the accounts.
5. `feat(identity)`: assign the `Admin` group to the member accounts.
6. `feat(baseline)`: `baselines/LogArchive` (bucket and trail), the wait script and the matrix entry. Pushing it creates the bucket and the trail.
7. `docs(runbook)`: the add and remove account runbooks.
8. `docs(claude)`: `CLAUDE.md` layout, commands, deployment and prerequisites.
9. `docs(readme)`: README prerequisites and layout.
10. `docs(adr)`: accept this ADR and complete its consequences.

The manual prerequisites must be in place before commit 6 is pushed.
