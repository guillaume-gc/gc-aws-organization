# 1. Bootstrap the GitHub OIDC provider with CloudFormation

- Status: Accepted
- Date: 2024-10 (recorded retroactively on 2026-09-27)

## Context

The GitHub Actions pipeline authenticates to the management account through an IAM OIDC provider and an IAM role. Terraform needs those credentials before it can run, so it cannot create the OIDC provider or the role itself.

## Decision

Create the OIDC provider and the deploy role once, by hand, from the CloudFormation template `scripts/oicd_provider/template.yml`. Terraform does not manage them.

## Consequences

- Bootstrapping stays infrastructure as code (a versioned template) without a circular dependency.
- The stack is deployed and updated by hand, outside the pipeline.
- The template only defines the role's trust policy. Its permissions are attached outside the template.
- The trust condition `repo:<org>/<repo>:*` lets any branch or workflow of the repository assume the role.
