# 7. Pin tools and save commands with mise

- Status: Accepted
- Date: 2026-09-29

## Context

Running Terraform locally needs long commands that are only written down in `CLAUDE.md`, such as `terraform init` with three `-backend-config` flags. ADR 0006 (Option A) would multiply them: each stage has its own directory and backend key.

The Terraform version is defined in two places that can drift apart: the `CICD_TERRAFORM_VERSION` repository variable used by CI, and `required_version = ">= 1.12"` in `versions.tf`, which accepts any newer local version.

Development happens on Windows, and CI runs on Linux (GitHub Actions `ubuntu-latest`).

## Options considered

### A. mise

One `mise.toml` pins tool versions (Terraform) and defines tasks (init, plan, fmt, validate). It runs on Windows, macOS and Linux, and has an official GitHub Action (`jdx/mise-action`).

**Pros:** one file for both tool versions and commands, shared by local runs and CI. Local, untracked settings go in `mise.local.toml`.
**Cons:** one more tool to install locally. Tasks must work with both the Windows and Linux shells.

### B. Makefile

**Pros:** well known, no install on Linux.
**Cons:** `make` is not installed on Windows by default. It does not pin tool versions.

### C. Task runner only (Taskfile, just) with a version manager (tfenv)

**Pros:** mature task runners.
**Cons:** two tools instead of one. tfenv does not support Windows natively.

### D. Shell scripts in `scripts/`

**Pros:** no extra tool.
**Cons:** does not pin tool versions. Bash and PowerShell scripts would have to be kept in sync.

### E. asdf

**Pros:** pins tool versions with `.tool-versions`.
**Cons:** no native Windows support, and no tasks.

## Decision

Use mise (Option A):

- `mise.toml` (committed) pins the exact Terraform version and defines the tasks `fmt`, `init`, `validate` and `plan`. The pinned version starts as the current value of the `CICD_TERRAFORM_VERSION` repository variable, so CI keeps the same version. Tasks that act on a stage take the stage directory as an argument once ADR 0006 introduces stages.
- `mise.local.toml` (gitignored) holds every local setting:
  - the backend settings used by `init` (state bucket, region), as environment variables;
  - the Terraform variables, as `TF_VAR_*` environment variables.
  It replaces `deploy.tfvars`, so local settings live in one file. A committed `mise.local.toml.example` lists the expected entries with placeholder values.
- There is no `apply` task. Applies only run in CI (see ADR 0003).
- Tasks do not select AWS credentials (profiles, SSO). The user provides them explicitly (see ADR 0003).
- CI installs mise and Terraform with `jdx/mise-action`, with both the action and the mise version pinned. It sets the same environment variables as `mise.local.toml` from the repository variables, and runs the same `init`, `fmt` and `validate` tasks.

## Consequences

- The Terraform version has a single source of truth, `mise.toml`. The `CICD_TERRAFORM_VERSION` repository variable is removed.
- `required_version` in `versions.tf` stays as a lower bound for anyone running Terraform without mise.
- Upgrading Terraform (or mise) is a commit, reviewed and deployed like any other change.
- `deploy.tfvars` is no longer used. Terraform variables are passed the same way locally and in CI (`TF_VAR_*`).
- Contributors (and Claude) must install mise to use the saved commands. Raw `terraform` commands still work.
- Tasks are kept to single `terraform` commands, so they behave the same in the Windows and Linux shells.

## Implementation plan

### Deliverables

- `mise.toml`: the Terraform version and the tasks.
- `mise.local.toml.example`, and `mise.local.toml` added to `.gitignore`.
- `deploy.yml`: `jdx/mise-action` (pinned) instead of `hashicorp/setup-terraform`, the environment variables from the repository variables, and the tasks instead of the raw `init`, `fmt` and `validate` commands. `apply` stays a raw command in the workflow.
- `CLAUDE.md`: the commands replaced by the tasks, `mise.local.toml` instead of `deploy.tfvars`.
- README: mise in the tools (install on Windows with winget or scoop), the setup of `mise.local.toml`, and `CICD_TERRAFORM_VERSION` removed from the repository variables table.

### Verification

- Read the current `CICD_TERRAFORM_VERSION` value to pin it. This reads the repository settings on GitHub, so it is done by the user or with their agreement.
- Run each task locally in PowerShell and in Git Bash. `init` and `plan` need AWS credentials, which are only used after the user agrees (see ADR 0003). `plan` must show no changes compared with the current deployment.
- After the push, check that the CI run uses the pinned Terraform version and succeeds.
- Only then remove the `CICD_TERRAFORM_VERSION` repository variable (by hand, in GitHub) and the local `deploy.tfvars`.

### Commits

1. `chore(tooling)`: `mise.toml`, `mise.local.toml.example`, and `mise.local.toml` in `.gitignore`.
2. `feat(cicd)`: install Terraform with `jdx/mise-action` and use the tasks and `TF_VAR_*` variables in `deploy.yml`.
3. `docs(claude)`: the tasks and `mise.local.toml` in `CLAUDE.md`.
4. `docs(readme)`: tools, local setup and repository variables in the README.

If ADR 0006 Option A is implemented, it comes after this ADR and its stages reuse these tasks with the stage directory as argument.
