# Pass 1 — Combat Damage Types (Loại Sát Thương), #21b — 2026-11-08 (night, round 3)

Target: `design/gdd/combat-damage-types.md`. Method: `/design-review`, lean mode, workflow `standard`, headless, autonomous. Settled decisions were not reopened (the 2026-11-08 decisions, the 08b and 08c reports, DT-01, DT-04 and EF-05 of round 3).

## Verdict: APPROVED (with notes)

No blockers. No design decision is open for this GDD. Every number recomputes: the 150 and 146 examples, the thể tu fixture (9.91 and 11.56, block 2.57 and 3.00, shield soak 15.91, Chaos 8.56 and 7.34), the 0.583 and 0.417 scale, AC-DT-32 (0.35, 0.15, 0.40, 0.10) and AC-DT-33 (0.25 and 0.25). The round 3 edits (host order, per-part scaling, 100 pp clip, "Conversion order" list) agree with each other and with Effects rule 13 and Item Database rule 11 (equip order exists there).

Completeness: all 5 required sections plus Formulas are present (Player Fantasy is advisory at `standard`). Dependency graph: combat.md, combat-defence.md, linh-can.md, modifiers.md, effects.md, cong-phap.md, dao.md, item-database.md and thien-kiep.md exist. Talismans (#18) has no GDD file (it is listed as implemented); advisory only.

Counts: 0 blocking, 1 recommended, 3 nits, 1 out-of-scope. 4 SAFE (all applied), 0 DECISION, 1 note for a file I do not own.

## Findings

| ID | Severity | Type | Location | Problem | Fix |
|---|---|---|---|---|---|
| DT-A1 | Recommended | SAFE, applied | AC-DT-15 | "a fixed conversion table" is not defined anywhere, so the test has no input | Named the cases: AC-DT-14, 16, 17, 27, 28, 29, 31, 32 at the default knob 2 |
| DT-A2 | Nit | SAFE, applied | Rule 6 "Order inside a step" | It says every step uses host order, but the modifier step sums by key and uses key order | Added: the modifier step is the exception and uses the key order below |
| DT-A3 | Nit | SAFE, applied | Edge Cases, first scaling bullet | Says "they are scaled down", not "per part", unlike rule 6 and AC-DT-33 | Reworded to per part |
| DT-A4 | Nit | SAFE, applied | Header Status and Last Updated | Do not mention round 3 | Added round 3 and this pass |
| DT-A5 | Note | Not my file | `design/registry/entities.yaml`, `damage_parts` | Expression and notes are stale: "scaled down if over 1" (not per part), host order "slotted hosts, then unslotted" (now the DT-01 list), no 100 pp clip, `revised` still 2026-11-08 text | Parent session: update the expression and notes to match rule 6 and the "Conversion order" list |

## SAFE fixes applied (all in `combat-damage-types.md`)

DT-A1, DT-A2, DT-A3, DT-A4. No value, cap, rule or mechanic was changed.

## DECISIONS

None.

## Observations (no action)

- Open Question 7 still lists the "Hỗn Độn" renames for the #43 sweep. Correct as is.
- Rule 6's limit of 2 and the "3 ×" part bound hold at the default knob. At knob 3 the bound is 4 ×, as the Tuning Knobs row says.
