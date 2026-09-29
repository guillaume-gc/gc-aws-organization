# 1. Record architecture decisions with ADRs

- Status: Accepted
- Date: 2026-09-29

## Context

Decisions about this project's architecture and conventions — how it's deployed, how credentials are handled, which tools it commits to — tend to get made once and then either go undocumented or end up as bare rules in whatever file is handy, with no reasoning attached. That makes them hard to trust later (is this still the reason?) and hard to revisit (was an alternative considered, and why was it rejected?).

## Decision

- Record every architecture-significant decision as an ADR in `docs/adr/`, one file per decision: Status, Date, Context, Options considered (optional), Decision, Consequences, Implementation plan (optional).
- A decision is architecture-significant when it is costly or risky to reverse, changes the deployment pipeline or the account/security model, or introduces a convention other contributors (human or agent) are expected to follow. Routine implementation choices don't need one.
- ADRs are numbered in the order they're adopted, and the number is permanent once accepted: a later decision that changes or reverses an earlier one gets a new ADR that supersedes it, not an edit to the old number.

## Consequences

- A future architecture-significant rule needs a new or superseding ADR, not just a note added to whatever file is convenient.
- The reasoning behind a rule always has exactly one place to look, instead of being scattered across commit messages, comments, or informal notes.
- Every decision from here on gets an ADR, including ones that feel obvious at the time — the cost is paid once and pays off whenever the decision needs to be revisited.
