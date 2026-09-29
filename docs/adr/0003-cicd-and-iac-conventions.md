# 3. Apply Terraform only from CI, gate local runs behind consent

- Status: Accepted
- Date: 2026-09-29

## Context

This is a personal AWS Organization, managed as Terraform and deployed by GitHub Actions, at MVP stage: a single operator (the user), and the priority is shipping over process. At the same time, it is a live, billable organization where member accounts close on deletion — mistakes are not free. These constraints were decided before the other ADRs in this log and are the ground they build on, but they were never written down, only encoded as unexplained rules in `CLAUDE.md`.

## Decision

- Terraform, applied from the management account, is the only way the organization is changed.
- `apply` runs only in CI: every push to `main` triggers `.github/workflows/on_push_main.yml` → `terraform apply -auto-approve`, with no plan or review step gating it.
- AWS credentials (profiles, SSO sessions, environment variables, secrets) are never used — locally, or by an agent such as Claude — without the user's explicit, per-use consent. This applies even to read-only calls (`terraform plan`, `aws sts get-caller-identity`), because the organization being read is real.
- Local `terraform apply` and other write or delete AWS commands are not run unless the user explicitly asks, for the same reason.

## Consequences

- One path (push → CI → auto-apply) means one audit trail and no drift between what's on `main` and what's deployed.
- No review gate means a bad commit on `main` applies immediately. Accepted at MVP stage for a single operator; the first thing to add if the project gains more contributors or higher stakes is a plan/review step before apply. This ADR should be revisited then, not silently overridden.
- Credential consent is a discipline, not a technical control — nothing in the repository stops a local `apply`. It is enforced by convention (`CLAUDE.md`, ADR 0002) and by whoever runs commands here.
- `CLAUDE.md`'s deployment and credential rules point back to this ADR instead of standing on their own.
