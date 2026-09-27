# CLAUDE.md

Terraform project that manages a personal AWS Organization (OUs, accounts, IAM Identity Center, budget, Resource Explorer) from the **management account**. Applications are deployed elsewhere, not from this repository.

## Layout

- `organization.tf`: the organization, trusted service access, OUs (`Security`, `Infrastructure`).
- `accounts.tf`: member accounts (built from `modules/template/account`) and the CloudTrail delegated admin.
- `identity.tf`: IAM Identity Center groups, permission sets and account assignments (`aws-ia/iam-identity-center` module).
- `budget.tf`, `resource_explorer.tf`: cost alerts and the organization-wide Resource Explorer.
- `modules/template/account/`: one member account (generated email `gc.org.acc+<name>-<hex>@pm.me`, `close_on_deletion = true`).
- `scripts/oicd_provider/template.yml`: the CloudFormation bootstrap for the GitHub OIDC provider and deploy role.
- `docs/adr/`: Architecture Decision Records. Read them before changing the architecture.

## Commands

```bash
terraform fmt -recursive          # required: CI fails on `fmt -check`
terraform init -backend-config='key=main.tfstate' -backend-config='region=<region>' -backend-config='bucket=<state bucket>'
terraform validate
terraform plan -var-file=deploy.tfvars
```

`deploy.tfvars` (gitignored) supplies `git_branch_name`, `aws_default_region`, `service_name` and `notification_emails`.

## Deployment

- Every push to `main` runs `.github/workflows/on_push_main.yml` → `deploy.yml`, which runs `terraform apply -auto-approve` using OIDC credentials. There is no plan or review step.
- Repository variables: `CICD_AWS_REGION`, `CICD_IAM_ROLE`, `CICD_TERRAFORM_VERSION`, `CICD_TERRAFORM_STATE_BUCKET`, `CICD_SERVICE_NAME`, `CICD_NOTIFICATION_EMAIL`.
- Do not run `terraform apply` locally unless the user explicitly asks. This is the live organization, and account deletion closes accounts.

## Manual prerequisites (outside Terraform)

- The OIDC provider and deploy role (CloudFormation stack), see ADR 0001.
- Enabling IAM Identity Center and managing its users, see ADR 0002.

## Conventions

- Commits must follow [Conventional Commits](https://www.conventionalcommits.org/): `type(scope): message`. Types seen so far: `feat`, `fix`, `chore`, `refact`. Scopes are areas such as `account`, `identity`, `explorer`, `cicd`, `all`.
- Each commit has a single intention. Don't mix unrelated changes (for example a fix and a refactor, or two unrelated fixes). Split them into separate commits.
- Resource names are prefixed with `var.service_name` where AWS requires them to be unique.
- Account names must be alphanumeric (validated in the account module).
- Record significant architecture decisions as a new ADR in `docs/adr/` (`NNNN-title.md`: Status / Date / Context / Decision / Consequences).
