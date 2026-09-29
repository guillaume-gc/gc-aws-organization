# 2. Keep decisions out of Claude-related files

- Status: Accepted
- Date: 2026-09-29

## Context

`CLAUDE.md` is the project's only Claude-related file today, but it won't stay the only one — `.claude/settings.json`, hooks, or project skills are all things this repository could reasonably add later. `CLAUDE.md` already accumulated operational rules (applying only from CI, asking before using credentials) that were never decided in an ADR, only stated as bare rules. ADR 0001 fixes that going forward for decisions in general, but doesn't say what role Claude-related files themselves are allowed to play — and without a stated boundary, it's tempting to add rules straight into them again, since they're fast to edit and are read by the agent on every turn.

## Decision

- `CLAUDE.md`, and any other Claude-related file added later (`.claude/settings.json`, hooks, project skills, etc.), hold no decisions and no reasoning. They state current, working-level facts an agent needs to act (commands, layout, prerequisites, permissions) and, where a fact follows from a decision, point at the ADR that made it.
- They may state routine conventions directly, without an ADR, when getting one wrong is cheap to notice and reverse: commit message format, comment style, formatting commands. The line is the "architecture-significant" test from ADR 0001 — costly or risky to reverse, changes the deployment pipeline or the account/security model, or is a convention other contributors are expected to follow. Being addressed to Claude specifically does not exempt a rule from that test.
- Changing what one of these files says still requires the matching ADR to be written or updated first; the file is edited to match, never the other way around.

## Consequences

- Every rule an agent reads has a traceable "why" one hop away, whether it's in `CLAUDE.md`, `.claude/settings.json`, or elsewhere.
- Low-stakes agent conventions stay cheap to add — no ADR needed — while consequential ones (credentials, deployment) can't sneak back in through a Claude-related file just because they're phrased as instructions to Claude.
- Reviewing a change to a Claude-related file means checking whether it states a new decision (needs an ADR first) or restates an existing one (should already have one).
