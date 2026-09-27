# 3. Orchestrate account creation and account baselines

- Status: Proposed
- Date: 2026-09-27

## Context

The repository is a single Terraform root module with a single state (`main.tfstate`), applied from the management account. It creates accounts (`modules/template/account`), but it cannot deploy baseline resources *into* those accounts in the same apply.

An attempt was made and then removed (see commit `203a39b`, "remove factory"). It used modules `modules/factory/log_archive` and `modules/factory/security_tooling`, each declaring its own `provider "aws"` that assumed the new account's role using `module.<account>.account_id`. It failed for these reasons:

1. **Provider settings must be known at plan time.** On the first apply, the account ID is unknown, so the provider for that account cannot be set up. It either errors or works only on a second apply.
2. **New accounts are not ready right away.** `CreateAccount` runs asynchronously, and the new account's role cannot be assumed for a while after it exists. That gives intermittent `AccessDenied` errors.
3. **Destroying is fragile.** Removing an account and the provider that reaches into it in the same change leaves resources Terraform can no longer reach.
4. **A provider declared inside a module** stops you from using `for_each`/`count`, so one generic "account + baseline" module cannot be reused per account.

Needed baselines include, for example, the organization CloudTrail bucket in LogArchive and the organization trail in SecurityTooling.

Constraints: personal organization, keep running costs minimal, GitHub Actions as the only deployment path.

## Options considered

### A. Separate states per stage, run in order by the pipeline

- Stage 1 (`organization`) covers the organization, OUs, accounts, Identity Center and the delegated admins. It outputs account IDs and role names.
- Stage 2 (`baselines/<account>`) is one root module per account (or one shared module used per account). Its provider assumes the account role, and it reads stage 1 outputs through `terraform_remote_state` or SSM parameters.
- A GitHub Actions job dependency (`needs:`) enforces the order, with a matrix over accounts for stage 2.

**Pros:** plain Terraform, no extra tools, no extra AWS cost. Provider settings are always known at plan time.
**Cons:** the pipeline glue has to be written and maintained, and each stage has its own state and backend key.

### B. Terragrunt (or Terramate) with a dependency graph

The same split as A, but ordering and output passing are declared (`dependency` blocks) instead of hand-written in the pipeline.

**Pros:** less pipeline glue, `run-all plan/apply`, handles many accounts cleanly.
**Cons:** one more tool to learn, pin and install in CI.

### C. AWS Control Tower

Control Tower sets up a landing zone: LogArchive and Audit accounts, an organization trail, Config and guardrails. Account Factory creates accounts with a baseline.

**Pros:** AWS-managed baseline and account vending, well-documented.
**Cons:**
- Running costs (Config recording, and so on), which go against the minimal-cost constraint.
- Overlaps with what this repository already creates (LogArchive, Audit, the organization trail), so either migrate or adopt existing accounts.
- Much of it is configured through the console. Custom baselines still need something else (CfCT or AFT).

### D. Account Factory for Terraform (AFT)

A Terraform-based account vending pipeline on top of Control Tower. It creates accounts from requests and applies global and per-account customizations.

**Pros:** built for exactly this problem, and stays Terraform.
**Cons:** requires Control Tower (all the cons of C), and deploys a lot of infrastructure (CodePipeline, CodeBuild, DynamoDB, Lambda, Step Functions) that costs money. Heavy for a personal organization.

### E. Keep a single state and apply twice or use `-target`

**Rejected up front:** not reproducible, and it breaks the push-to-apply pipeline.

## Decision

Pending.

## Consequences

To be completed once a decision is made.
