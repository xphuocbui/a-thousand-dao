# Gate Check: Concept → Systems Design

**Date**: 2026-11-15
**Checked by**: gate-check skill
**Tier**: `workflow: standard`, `review_mode: lean`, `qa.level: standard`, `team.size: individual`

## Verdict: CONCERNS

No blockers. The stage stays at **Concept**: the user chose to stop without accepting the concerns, so no stage was written.

### Required Artifacts: 1/1 present
- [x] `design/gdd/game-concept.md` — exists with real content

### Recommended (not blocking at `standard`): 2/3
- [x] Game pillars — 5 pillars plus anti-pillars
- [x] Visual Identity Anchor section — "Ink and Ledger"
- [~] Concept prototype with PROCEED — none; `prototypes/dao-engine-concept/REPORT.md` ended in PIVOT. The user states the concept is proven by other means (the Python combat sim, the built debug-terminal game, play sessions).

### Quality Checks: 3/4 passing
- [ ] Concept reviewed — **no** (user confirmed; status still Draft). Close with `/design-review design/gdd/game-concept.md`.
- [x] Core loop described
- [x] Target audience identified (Target Player Profile)
- [x] Visual Identity Anchor has a one-line rule ("The world is brushed; the math is printed") and 3 principles

### Blockers
None.

### Concerns
1. **Concept unreviewed** — the one unmet quality check.
2. **Concept describes the old game.** It still makes the LLM core (pitch, Core Fantasy, Pillars 2 and 5, the Narrative aesthetic, MVP item 8 "Bounded LLM game master"), though the LLM was parked 2026-11-15 and the game must play without it. Its MVP (one province, ~3 sects, ~20 NPCs; 2–3 months) predates the fixed 540 × 360 continent, 30 sects, 72-person cast and ~5,000 cultivators the GDDs now describe.
3. **Architecture keeps `LlmClient` in the Foundation layer** and "LLM first, template fallback" in the turn flow — mark it parked before the Technical Setup gate.
4. **Scope added without cuts, design order not followed.** Nine systems added by request (#43 and #44 straight into MVP); Vertical Slice and Alpha systems designed while 14 MVP systems are built with no GDD; the Way (outside the concept's MVP) already has 94 Ways and 223 arts.
5. **Review rounds as schedule risk.** Trade Goods (#45) took 12 `/design-review` rounds and Regional Economy (#43) 11. Suggested: about 3 rounds per GDD before escalating, and settle a system's tier before full review.
6. **Tracking stale.** The systems-index Progress Tracker is dated 2026-11-10 and disagrees with its rows; a parallel session has uncommitted edits in that file.

## Director Panel (2 of 4, `workflow: standard`)

Technical Director: CONCERNS
- Feasibility on Godot 4.7 is proven: 81 GDScript files and 54 test files; ADR-0001 records the combat engine fully ported; `docs/architecture/architecture.md` lays out the layers. The concept's "TD-FEASIBILITY skipped" line is now stale.
- Concerns 2 and 3 above. Performance budgets are not needed at this gate; the fight-throughput choice and the architecture's NOT SOURCEABLE / NEEDS VERIFICATION items belong in the risk register before Pre-Production.

Producer: CONCERNS
- The project can enter Systems Design and in practice has. Concerns 1, 2, 4, 5 and 6 above. Record the user's prototype override and its evidence so later gates stop raising it.

Creative and Art perspectives not consulted at this tier. Set `modes.workflow: full` (or raise `modes.rigor`) for the full panel.

## Recommendations
1. Re-baseline `game-concept.md`: the LLM as parked, the MVP and scope tiers for the fixed world. Then `/design-review design/gdd/game-concept.md` and re-run `/gate-check systems-design`.
2. Decide which added and Alpha systems the MVP keeps and which are frozen.
3. Refresh the systems-index Progress Tracker once the parallel session's edits are committed.

Chain-of-Verification: 5 questions checked (2 by re-reading files: the concept's LLM lines, both stage files) — verdict unchanged.
