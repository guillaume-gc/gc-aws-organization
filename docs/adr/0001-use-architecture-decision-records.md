# 1. Record architecture decisions with ADRs

- Status: Accepted
- Date: 2026-09-29

## Context

Decisions about this project's architecture and conventions — how it's deployed, how credentials are handled, which tools it commits to — tend to get made once and then either go undocumented or end up as bare rules in whatever file is handy, with no reasoning attached. That makes them hard to trust later (is this still the reason?) and hard to revisit (was an alternative considered, and why was it rejected?).

## Decision

- Record every architecture-significant decision as an ADR in `docs/adr/`, one file per decision: Status, Date, Context, Options considered (optional), Decision, Consequences, Implementation plan (optional).
- A decision is architecture-significant when it is costly or risky to reverse, changes the deployment pipeline or the account/security model, or introduces a convention other contributors (human or agent) are expected to follow. Routine implementation choices don't need one.
- An ADR does not contain:
  - commit plans (commit lists, messages or order);
  - progress tracking (what is done or left to do);
  - step-by-step procedures, which go in runbooks;
  - copies of code or configuration that live in the repository;
  - paths to source code files (folders, documentation and other ADRs can still be referenced);
  - environment-specific values (account IDs, emails, bucket names).
- ADRs are numbered in the order they're adopted, and the number is permanent.
- Once the repository is stable, an accepted ADR is never edited directly: a later decision that changes or reverses it gets a new ADR that supersedes it. Until then, accepted ADRs can be edited in place. The repository is stable once the organization and all its base accounts (see ADR 0008) are created, each with its account baseline deployed. This is a personal project with a single operator: while the base is being built, decisions change often and no one else relies on their history, so superseding ADRs would add overhead without benefit.

## Consequences

- A future architecture-significant rule needs an ADR, not just a note added to whatever file is convenient.
- The reasoning behind a rule always has exactly one place to look, instead of being scattered across commit messages, comments, or informal notes.
- Every decision from here on gets an ADR, including ones that feel obvious at the time — the cost is paid once and pays off whenever the decision needs to be revisited.
