# Architecture Traceability Index
Last Updated: 2026-11-22
Engine: Godot 4.7 (4.7.1 installed)
Source: `docs/architecture/architecture-review-2026-11-22.md` (full review, FAIL)

> Contract-level matrix. The 15 GDDs in `architecture.md`'s baseline were not re-read; the other 19 were scanned only
> for performance, persistence and determinism lines. Requirements not searched for are absent, so the gap count is a
> lower bound.

## Coverage Summary
- Total requirements: 30
- Covered (Accepted ADR): 9 (30%)
- Covered by a Proposed ADR (not a pass): 2
- Partial: 5
- Gaps: 12
- Parked (LLM, deprecated in the registry): 2

## Full Matrix

| Requirement ID | GDD | Requirement | ADR Coverage | Status |
|---|---|---|---|---|
| TR-sim-001 | combat.md | Same seed and actions give the same life | ADR-0002, ADR-0001 | ✅ |
| TR-sim-002 | effects.md | A counted chance consumes no draw; fixed seed lists in sampling tests | none (effects.md only) | ⚠️ Partial |
| TR-save-001 | canh-gioi.md | Save/load round trip deep-equal for every record kind | ADR-0002 (session stream only) | ⚠️ Partial |
| TR-save-002 | item-database.md | Save versions: 1 migrates, 2 refused, 3 loads | none | ❌ GAP |
| TR-save-003 | travel-map.md | A save stores the seed and changes; map and history come from data | none | ❌ GAP |
| TR-combat-001 | combat.md | No clock, nodes or global state; headless | ADR-0001 | ✅ |
| TR-combat-002 | combat.md | One fight under 50 ms in a release export | ADR-0001 | ✅ |
| TR-combat-003 | combat.md | World NPC fights decided from ratings (reworded 2026-11-22) | ADR-0003 | ✅ |
| TR-effects-001 | effects.md | Effects are validated JSON records | ADR-0001 | ✅ |
| TR-modifiers-001 | modifiers.md | One provider interface with a `Breakdown` | ADR-0001 (combat part only) | ⚠️ Partial |
| TR-items-001 | item-database.md | About 200,000 items at 5,000 cultivators | none | ❌ GAP |
| TR-world-001 | canh-gioi.md | 5,000 cultivators; per-region work once a season | none | ❌ GAP |
| TR-meridian-001 | dao-do.md | NPC allocation at most 50 ms at 566 points | ADR-0004 (budget only a verification item) | ⚠️ Partial |
| TR-dao-001 | dao.md | 94 Ways, about 150 nodes each | none | ❌ GAP |
| TR-travel-001 | travel-map.md | One authored tile continent from index images | none | ❌ GAP |
| TR-quests-001 | quests.md | A quest brief is stored, not regenerated (reworded 2026-11-22) | ADR-0002 decision 5 | ✅ |
| TR-llm-001 | game-concept.md | LLM acts inside engine budgets; fallback always works | none | ➖ Parked (deprecated) |
| TR-llm-002 | game-concept.md | Structured-output reliability; no UI blocking | none | ➖ Parked (deprecated) |
| TR-ui-001 | game-concept.md | 2D UI, three languages, accessibility | ADR-0005 (tooltips only) | ⚠️ Partial |
| TR-realms-001 | canh-gioi.md | The realm ladder is a data contract | none | ❌ GAP |
| TR-stats-001 | character-stats.md | Provider interface is the single stability point | none | ❌ GAP |
| TR-session-001 | design/ux/hud.md | Frontends use `GameSession` only; reads are copies; one job at a time | ADR-0006 (Proposed) | 🟡 Covered (Proposed) |
| TR-ui-002 | design/ux/hud.md | Tooltip chain, keyboard and Esc routing, accessibility settings | ADR-0005 (Proposed) | 🟡 Covered (Proposed) |
| TR-power-001 | power-rankings.md | At most 10,000 fights a season off the main thread; no frame over 33 ms | ADR-0003 | ✅ |
| TR-power-002 | power-rankings.md | World fights use keyed seeds, one session draw | ADR-0002, ADR-0003 | ✅ |
| TR-dao-002 | dao-do.md | 8,057-node tree loads from the drawn map; tree Effects in both engines | ADR-0004 | ✅ |
| TR-world-002 | living-world-tick.md | Tick mean ≤150 ms, p99 ≤250 ms at 5,000 (provisional) | none | ❌ GAP |
| TR-world-003 | living-world-tick.md | One fixed season order S1–S10 | none | ❌ GAP |
| TR-world-004 | living-world-tick.md | Callee budgets: sects, ties S8b, map | none | ❌ GAP |
| TR-codex-001 | codex-karmic-carryover.md | Codex on a profile outside any save | none | ❌ GAP |

## Known Gaps

| ID | Layer | Suggested ADR | Engine risk |
|---|---|---|---|
| TR-save-002, TR-save-003, TR-save-001 (rest), TR-codex-001 | Foundation | `/architecture-decision save format and migration policy, including the profile record` | LOW |
| TR-realms-001, TR-stats-001, TR-modifiers-001 (rest) | Core | `/architecture-decision stat sheet and provider interface` | LOW |
| TR-world-001 to 004, TR-items-001 | Foundation / Feature | `/architecture-decision world scale and simulation budget, with season order` | MEDIUM (threading not in the engine reference) |
| TR-travel-001, TR-dao-001 | Feature | `/architecture-decision fixed-world map pipeline` | LOW |
| TR-sim-002 | Core | fold into the save/stat-sheet ADRs or a short rule in ADR-0002 | LOW |
| TR-ui-001 (rest) | Presentation | Game UI framework, localization and accessibility, after the art bible | HIGH |

Proposed ADRs awaiting acceptance (cap the verdict at CONCERNS until Accepted): ADR-0005 and ADR-0006, to be accepted
together (`/architecture-decision accept ADR-NNNN`).

## Superseded Requirements
None superseded. Two were reworded because their GDD changed: TR-combat-003 (Combat amended 2026-11-14) and
TR-quests-001 (LLM parked 2026-11-15). TR-llm-001 and TR-llm-002 are deprecated while the LLM Game Master stays parked.
