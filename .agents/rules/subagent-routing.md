---
trigger: glob
globs: "**/*"
---

# Subagent Model Routing Rules

- **Default delegated subagent model (user ruling 2026-11-27):** Always use Google `antigravity` / `gemini-4-neon` with `options: {"thought_level": "high"}` for all delegated subagents (coding, reviews, audits, design, and fixes), except for **basic/mechanical tasks** (where a lighter/cheaper model such as `gemini-4-hydrogen` or `gemini-3.8-flash` may be used), unless the user explicitly specifies another provider or model.
- **Orchestrator boundary:** Keep the parent orchestrator thread strictly for delegation, gating, and commits — do not perform direct implementation work in the orchestrator thread.
- **Parallelism & barriers:** Up to **6 parallel** non-conflicting lanes; never run concurrent writers on overlapping paths (`10-owner` serial barriers during batch work).
