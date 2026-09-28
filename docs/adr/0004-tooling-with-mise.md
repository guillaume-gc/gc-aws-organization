# 4. Pin tools and save commands with mise

- Status: Accepted
- Date: 2026-09-28

## Context

Running Terraform locally needs long commands that are only written down in `CLAUDE.md`, such as `terraform init` with three `-backend-config` flags. ADR 0003 (Option A) would multiply them: each stage has its own directory and backend key.

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

- `mise.toml` (committed) pins the exact Terraform version and defines the tasks `fmt`, `init`, `validate` and `plan`. Tasks that act on a stage take the stage directory as an argument once ADR 0003 introduces stages.
- `mise.local.toml` (gitignored) sets the local values that tasks need, such as the state bucket and region, as environment variables.
- There is no `apply` task. Applies only run in CI (see `CLAUDE.md`).
- Tasks do not select AWS credentials (profiles, SSO). The user provides them explicitly.
- CI installs Terraform with `jdx/mise-action` from `mise.toml`, and runs the same `init` and `fmt` tasks.

## Consequences

- The Terraform version has a single source of truth, `mise.toml`. The `CICD_TERRAFORM_VERSION` repository variable is removed.
- `required_version` in `versions.tf` stays as a lower bound for anyone running Terraform without mise.
- Upgrading Terraform is a commit to `mise.toml`, reviewed and deployed like any other change.
- Contributors (and Claude) must install mise to use the saved commands. Raw `terraform` commands still work.
- Tasks are kept to single `terraform` commands, so they behave the same in the Windows and Linux shells.

## Implementation plan

1. `chore(tooling)`: add `mise.toml` (Terraform version, tasks), add `mise.local.toml` to `.gitignore`.
2. `feat(cicd)`: install Terraform with `jdx/mise-action` and use the tasks in `deploy.yml`. Remove `CICD_TERRAFORM_VERSION` from the repository variables afterwards.
3. `docs(claude)`: replace the commands in `CLAUDE.md` with the mise tasks, and document `mise.local.toml`.

If ADR 0003 Option A is implemented, its stages reuse these tasks with the stage directory as argument.
