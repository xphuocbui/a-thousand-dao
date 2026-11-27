# Multi-Agent Collaboration (Subagents & Swarms)

Antigravity Game Studios supports two native Antigravity multi-agent patterns:

## 1. Subagents (`invoke_subagent`) — Default, Always Active

Used by all `team-*` skills and orchestration skills (`/review-all-gdds`, `/gate-check`, `/architecture-review`, etc.):
- Spawn independent subagents in parallel in the same turn via `invoke_subagent`.
- Coordinate follow-ups via `send_message`.
- Use `Workspace: "share"` or `"branch"` when parallel subagents must edit or build simultaneously without colliding on the working tree; use `Workspace: "inherit"` (default) for read-only reviewers and sequential tasks.

## 2. Swarms (`swarm` tool) — Optional, Opt-In

For large parallel initiatives where multiple autonomous agents benefit from a shared message board and peer-to-peer coordination (or when the user invokes `/teamwork`):
- Spawn named workers with clear file/domain ownership using the `swarm` tool (`workspace: "share"` for parallel authors).
- Keep the user's Collaboration Protocol active: review and approve changes before landing or committing.
