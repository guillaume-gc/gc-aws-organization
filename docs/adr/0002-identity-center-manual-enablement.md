# 2. Enable IAM Identity Center by hand and keep users out of Terraform

- Status: Accepted
- Date: 2025-07 (recorded retroactively on 2026-09-27)

## Context

IAM Identity Center gives human access to all accounts of the organization. Terraform cannot enable the organization instance of Identity Center (checked on 2025-08-02). An earlier attempt to host Identity Center in a dedicated "Identity" account was abandoned; it now lives in the management account.

## Decision

- Enable IAM Identity Center by hand in the management account before the first deployment.
- Terraform (`identity.tf`, using the `aws-ia/iam-identity-center` module) manages **groups, permission sets and account assignments** only.
- **Users** and their group memberships are managed by hand, outside Terraform.

## Consequences

- A fresh setup needs a manual step before `terraform apply` can succeed.
- Personal user data stays out of the repository and the state.
- Each new account has to be added to `account_assignments` in `identity.tf` by hand.
