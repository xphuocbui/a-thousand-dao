# Review Log: Character Stats

## Review — 2026-11-04 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: The arithmetic reproduces everywhere checked (grade shares, Formula C table, D/E/F/G/H/I examples, AC-CS-18, AC-CS-32, #4 numbers), and the registry has no value conflicts. The one blocker is a tuning-range contradiction: the effective talent clamp's safe range (120–200) breaks the Market's no-profit-loop limit above presence 157.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Tuning Knobs: effective talent clamp range 120–200 contradicts the `mi_luc_price_per_point` derived limit (loop profits above presence 157)
- [RECOMMENDED] Rule 8 / AC-CS-19: "kills add none" vs #9 "+2 per defeat" needs an explicit with-#9 case
- [RECOMMENDED] Registry: `failure_khi_huyet_loss_pct` carries the old name (now `_frac`)
- [RECOMMENDED] Rule 13 / Formulas I: no stacking rule for `cultivation_speed_per_element_pct`; no owner for lifespan keys
- [RECOMMENDED] Formulas C: #4's "+22 % at CF" holds only at physique 45
- [RECOMMENDED] Formulas G: `field_plots` names both the key and the output
- [RECOMMENDED] Formulas H: Market ceil/floor needs the Formula I tolerance rule or integer maths
- [RECOMMENDED] AC-CS-09, 11, 19: missing pill toxicity / quality, and a provisional bullet
- [RECOMMENDED] Edge Cases: talent-lowering pills and events not covered
Reviewed-Content-Hash: design/gdd/character-stats.md 142d6010328a1834a1e15df4c8a59d2a3f0f3729
Reviewed-Content-Hash: design/registry/entities.yaml 446511e0a80b7c23020f6c4e921386e0d9803f4a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md ea41e3937b8b97af305964140398a574dadeb1a3
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 65d5beb25169d28526b489c656b70abaaa419b0c
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/systems-index.md d6bb32eaf229dd12e5fb4e55adc519ad4fb4fecc

## Review — 2026-11-04 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: All nine findings from the first review are resolved. The arithmetic reproduces across Formulas A–I and the ACs, and the registry has no value conflicts. Remaining items are data-driven-rule, precision and test-coverage gaps, not design contradictions.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Rule 15 / Formulas I: no precision unit for can_cot, than_hon, dao_tam, mi_luc
- [RECOMMENDED] Parameter keys: effective talent clamp, presence price, fortune factors and #25 params have no data key (code hardcodes 1..150)
- [RECOMMENDED] Rule 9 / Formula F: qi deviation setting vitality to the floor is missing from Rule 9
- [RECOMMENDED] Acceptance Criteria: no AC for cultivation_speed_per_element_pct (or lifespan) stacking
- [RECOMMENDED] Tuning Knobs: dan_doc_divisor range 100–400 contradicts the 0.5–1.0 cultivation multiplier output range
- [RECOMMENDED] Registry derived_values: output_range ignores tech_power up to 2.0 and linh_luc_pct
- [RECOMMENDED] Registry stat_precision_grid: "small flats" is ambiguous
Reviewed-Content-Hash: design/gdd/character-stats.md 1ba60a6df1101840e65eeda7eec1e843f8ed7ce1
Reviewed-Content-Hash: design/registry/entities.yaml 797e50ff6629ba8152105398f7dfac7fe02d4937
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 607bd9da2b8829b7385517262cf7f3fa3f12684b
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 65d5beb25169d28526b489c656b70abaaa419b0c
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/systems-index.md 30b68980b3b3d489b66b6bad9f80a1c54eac100c

## Cleanup — 2026-11-04 (no new review)
Applied the second pass's 7 recommended items:
- 0.01 precision for all six talent keys;
- data keys for the effective talent clamp, the fortune and presence factors, and #25's parameters;
- rule 9 states the qi deviation's vitality floor;
- AC-CS-51 (per-element cultivation speed) and AC-CS-52 (lifespan stacking) added;
- the `dan_doc_divisor` range is narrowed to 200–400 to match its output range;
- the registry `derived_values` range is unbounded above;
- the registry `stat_precision_grid` lists its keys.

The status header is set to Approved. No values changed.
