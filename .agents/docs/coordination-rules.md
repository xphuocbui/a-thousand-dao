# Agent Coordination Rules

1. **Vertical Delegation**: Leadership agents delegate to department leads, who delegate to specialists. Never skip a tier for complex decisions.
2. **Horizontal Consultation**: Agents at the same tier may consult each other but must not make binding decisions outside their domain.
3. **Conflict Resolution**: When two agents disagree, escalate to the shared parent. If no shared parent, escalate to `creative-director` for design conflicts or `technical-director` for technical conflicts.
4. **Change Propagation**: When a design change affects multiple domains, the `producer` agent coordinates the propagation.
5. **No Unilateral Cross-Domain Changes**: An agent must never modify files outside its designated directories without explicit delegation.
6. **Read Design Docs by Section**: A brief names the sections an agent needs by heading. Locate headings first and read the target range with `StartLine`/`EndLine` in `read_file`; read a large (>40 KB) doc whole only when the task needs all of it, and state why.
7. **Nothing Goes Upstream**: Never file, open, or comment on an issue or pull request in an engine, plugin, or vendor repository, even when asked. Write a draft (`/bug-report` drafts only) and let the user submit it.

## Model Tier Guidance

Read `.agents/docs/model-tiers.md` on demand. By default, all subagents run with `Model: "inherit"` (matching the user's active Antigravity session model).

## Subagents & Swarms

### Subagents (default, always active)
Spawned via `invoke_subagent` (and messaged via `send_message`). Used by all `team-*` skills and orchestration skills.

- **Spawn in parallel when independent**: If two subagents' inputs do not depend on each other (for example, `/review-all-gdds` **Phase 2** consistency and **Phase 3** design theory after Phase 1 loads the GDDs), issue both `invoke_subagent` calls in the same turn rather than waiting.

### Swarms (optional, opt-in)
Read `.agents/docs/agent-teams.md` on demand before proposing a multi-agent `swarm` session.

## Parallel Task Protocol

When an orchestration skill spawns multiple independent subagents:

1. Issue all independent `invoke_subagent` calls before waiting for any result.
2. Collect all results before proceeding to dependent phases.
3. If any subagent is BLOCKED, surface it immediately — do not silently skip.
4. Always produce a partial report if some subagents complete and others block.
