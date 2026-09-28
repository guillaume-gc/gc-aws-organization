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

Needed baselines include, for example, the organization CloudTrail bucket in LogArchive and the organization trail. An organization trail can only be created from the management account or from a CloudTrail delegated administrator account. Creating it from the management account keeps it in stage 1 of a split and leaves only the bucket in LogArchive.

Member accounts are reached through the role created by `aws_organizations_account` (`<service_name>_<name>_Root`), which the deploy role in the management account assumes.

Constraints: personal organization, keep running costs minimal, GitHub Actions as the only deployment path.

## Options considered

### A. Separate states per stage, run in order by the pipeline

- Stage 1 (`organization`) covers the organization, OUs, accounts, Identity Center, the delegated admins and the organization trail. It outputs account IDs and role names.
- Stage 2 (`baselines/<account>`) is one root module per account (or one shared module used per account). Its provider assumes the account role, and it reads stage 1 outputs through `terraform_remote_state` or SSM parameters.
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

Pending.

## Consequences

To be completed once a decision is made.
