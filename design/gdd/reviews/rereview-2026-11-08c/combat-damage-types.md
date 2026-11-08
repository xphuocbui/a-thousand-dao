# Re-review 3 — Combat Damage Types (Loại Sát Thương), #21b — 2026-11-08 (night)

Target: `design/gdd/combat-damage-types.md` (as of commit b5ca784). Method: `/design-review`, lean mode, workflow `standard`, run headless. No existing file was edited.

Read: the review log's latest entry (2026-11-08b), the previous report (`rereview-2026-11-08b/combat-damage-types.md`), the diff of b5ca784 for this GDD, the whole GDD (by section), and the cited parts of modifiers.md, effects.md, combat-defence.md, item-database.md, character-stats.md, combat.md and `design/registry/entities.yaml`.

## Verdict: NEEDS REVISION (light)

All 14 findings from the last round are in the GDD. The four user decisions (DT-01, DT-02, DT-07, DT-10) are applied as given, and I did not reopen them. Every number holds when recomputed. There are no blockers. One gap would trip a programmer: the host-order list in rule 6 is shorter than the list of hosts that may carry Effects, and the "artifact slot" it names has no order in the Item Database. One earlier fix (DT-05, Combat Defence rule 9) was only half applied. The rest are nits: a broken table row, stale header lines, registry notes, and two ACs that need more detail.

Counts: 0 blocking, 2 recommended, 10 nit. 10 SAFE, 2 DECISION.

## Checks

### Applied decisions, checked against b5ca784

| Item | Where | Result |
|---|---|---|
| DT-01 one conversion per from → to key, `c_k` = sum / 100, type order, sum ≤ 0 is no conversion | Rule 6 "The modifier step", Formulas A `c_k` row, AC-DT-32 | Applied as decided |
| DT-02 slotted hosts, then technique / Way / tree, then record id, then listing order | Rule 6 "Order inside a step", `c_k` row, AC-DT-27 | Applied as decided. See DT-01 below for what it leaves open |
| DT-03 moves-nothing skip, earlier steps count | Rule 6, Edge Cases, AC-DT-21, AC-DT-27 | Applied |
| DT-04 "Any tick on health", qi tick passes every shield | Rule 4, rule 7 | Applied |
| DT-05 Defence qi-tick row | combat-defence.md line 69 | Row added. Rule 9 sentence missing. Table row broke. See DT-02 and DT-09 |
| DT-06 registry `damage_parts` | entities.yaml 1175–1193 | Applied. See DT-11 |
| DT-07 plain scoped conversions are `convert_pct` | Rule 6, Interactions, effects.md lines 141, 359–363, AC-EF-58 | Applied |
| DT-08 conversion-order ownership | Dependencies, Cross-References | Applied |
| DT-09 rename list | OQ 7 | Applied. canh-gioi.md 490, kinh-mach-do.md 415 and 1403, game-concept.md 156 and linh-can.md 184, 212, 664 still say "Chaos (Hỗn Độn)", as OQ 7 says. Nothing to fix until the #43 sweep |
| DT-10 whole-pp grid | modifiers.md Stat List "grid 1", character-stats.md line 240, entities.yaml line 1481 | Applied in all three |
| DT-11 to DT-14 | AC-DT-21, `c_k` row, AC-DT-31, merged Interactions row | Applied |

Rule 7's new bullet "soul shields are the reverse: passed by everything except Soul" was not in last round's findings. It matches Combat Defence rule 9 (line 192) and Formulas B (line 542). No conflict.

### Arithmetic, recomputed

- Formulas A example: 0.6 × 1.3 = 0.78; 0.2 × 1.7 = 0.34; 0.2 × 1.9 = 0.38. Sum 1.50, so **150**. ✓ (Lightning part: history Physical and Fire, so M = 1 + 0.3 + 0.4 + 0.2 = 1.9. Fire part: 1.7.)
- Lava: 0.6 × 1.3 = 0.78; 0.4 × 1.7 = 0.68. Sum 1.46, so **146**. ✓
- Thể tu example (D 41.3):
  - Physical: 41.3 × 0.6 × (1 − 0.60) = 9.912. Fire: 41.3 × 0.4 × (1 − 0.30) = 11.564. Sum 21.476. ✓
  - Block 5.57 split by size: Fire gets 5.57 × 11.564 / 21.476 = 64.41148 / 21.476 = 2.9992, so 3.00. Physical gets 5.57 − 2.9992 = 2.5708, so 2.57. ✓
  - Left: 9.912 − 2.5708 = 7.3412 and 11.564 − 2.9992 = 8.5648. Sum 15.906, so 15.91, under the 109.0 shield, so 0 to health. ✓
  - Chaos case: 8.5648 rounds to **8.56**. Physical 7.34 goes into the shield. ✓
- AC-DT-16 and AC-DT-27: 0.7 / 1.2 = 0.5833; 0.5 / 1.2 = 0.4167. ✓
- AC-DT-31: 1 − 0.2 = 0.8 and 0.2. ✓
- **AC-DT-32:** Physical → Fire key sum = 15 + 15 = 30 pp, so c = 0.30. Physical 0.5 × 0.70 = 0.35; Fire 0.5 × 0.30 = 0.15. Force → Lightning 20 pp: Force 0.5 × 0.80 = 0.40; Lightning 0.5 × 0.20 = 0.10. Total 1.00. ✓ Physical comes before Force in rule 1's table, so Physical → Fire runs first. ✓
- Part bound: with 2 conversions, each part of the source type spawns at most one new part, so n parts become at most 3n (4n with 3 conversions). ✓
- AC-MD-32 (modifiers.md): 1.2 × 1.5 / 0.8 = 2.25, floored on the 1 pp grid = 2 pp. 7 types × 6 targets = 42 keys. ✓
- Colours (nearest xterm level from 0, 95, 135, 175, 215, 255, or the grey ramp 8 + 10k):

  | Type | RGB | Working | Code |
  |---|---|---|---|
  | Physical | 230,230,230 | grey ramp 8 + 10 × 22 = 228 (distance 2) beats 255 (25) | 254 |
  | Force | 159,232,232 | 159 → 175 (16 vs 24); 232 → 215 (17 vs 23) | 16 + 108 + 24 + 4 = 152 |
  | Fire | 255,85,51 | 85 → 95; 51 → 95 (44 vs 51) | 16 + 180 + 6 + 1 = 203 |
  | Cold | 127,200,255 | 127 → 135; 200 → 215 (15 vs 25) | 16 + 72 + 24 + 5 = 117 |
  | Lightning | 255,225,77 | 225 → 215 (10 vs 30); 77 → 95 (18) | 16 + 180 + 24 + 1 = 221 |
  | Light | 255,242,179 | 242 → 255; 179 → 175 | 16 + 180 + 30 + 3 = 229 |
  | Chaos | 163,92,255 | 163 → 175; 92 → 95 | 16 + 108 + 6 + 5 = 135 |
  | Soul | 255,102,204 | 102 → 95; 204 → 215 | 16 + 180 + 6 + 4 = 206 |

  All eight codes differ. ✓

### Cross-checks

- **Registry:** `damage_parts` (entities.yaml 1175–1193) agrees with Formulas A. `referenced_by` lists modifiers.md and effects.md. `revised: 2026-11-08`. The `convert_pct` precision (1) matches. No value conflict. Gap: DT-11.
- **modifiers.md:** rule 8 "conversion" bullet, rule 1 (`from`, `to`) and the Stat List row agree with rule 6. AC-MD-12 rejects a damage-type scope on `convert_pct`, so the [sword] and [moc] scopes are tag scopes. ✓
- **effects.md:** lines 141, 281, 359–363 and AC-EF-58 agree. Qi Disruption's path agrees with rule 4.
- **combat-defence.md:** the rule 1 table, Formulas B and AC-CD-68 agree on the qi-tick path, apart from DT-02 and DT-09.

## Findings

### DT-01 — RECOMMENDED — DECISION — The host order in rule 6 is shorter than the list of hosts

**Location:** Core Rule 6, "Order inside a step" (lines 139–144). Formulas A, `c_k` row (line 220). AC-DT-27 (line 378).

**Problem.** Rule 6 says: "slot order for hosts in a slot (art slots, then artifact slots), then hosts with no slot (technique, Way, tree); then record id". Two gaps:

1. effects.md rule 13 lets an Effect sit on many more hosts: the Meridian Map, Way nodes, techniques and arts, named artifacts, treasures, talismans, pills, formations and ground, spirit beasts, progression edges, spiritual roots and statuses. A conversion Effect on a formation, a talisman or a root has no place in the list. The list is closed, so a programmer must guess.
2. "Artifact slots" has no slot order. The Item Database (rule 11, lines 125–128) has a flexible set of equipped pieces, "counted in equip order", up to `equip.max_slots`. Combat's "slot order" (rule 13) is for arts only.

This keeps the user's DT-02 answer. It only finishes the list.

**Options.**

- **A (recommended).** Keep the order as decided and finish it. Slotted hosts first: art slots in slot order, then equipped pieces in equip order, then talismans in slot order. Then unslotted hosts in the order of effects.md rule 13's list. Then record id, then listing order. One list, no new mechanism.
- **B.** After the slotted hosts, put every other host together and sort by record id alone. Simple, but a designer's id choice then decides play. DT-02 option B was rejected for this.
- **C.** Allow conversion Effects only on hosts that already have an order (arts, equipped pieces, techniques, Way, tree), and reject the rest at compile. Smallest rule, but it removes hosts that Effects rule 13 allows.

**Proposed text (option A).** In rule 6, replace "slot order for hosts in a slot (art slots, then artifact slots), then hosts with no slot (technique, Way, tree);" with:

> hosts in a slot first (art slots in slot order, then equipped pieces in equip order, Item Database rule 11, then talismans in slot order), then every other host in the order of Effects rule 13's list;

Mirror it in the `c_k` row. Add to AC-DT-27: "**GIVEN** a conversion Effect on a formation and one on a Way node, **THEN** the Way node's comes first (Effects rule 13's order)."

### DT-02 — RECOMMENDED — SAFE — Combat Defence rule 9 still lets a body shield soak a qi tick

**Location:** combat-defence.md rule 9, "What passes a shield" (lines 190–192). Last round's DT-05.

**Problem.** DT-05 asked for two edits. The table row was added (line 69). The rule 9 sentence was not. Rule 9 still says "body shields by Soul and Chaos, so a burn wears a body shield down and a poison slips past it", with nothing about a tick on linh lực. Read alone, a body shield soaks a Force qi tick. That contradicts rule 4 here, AC-DT-30 ("both shields are unchanged") and Defence's own line 844.

**Proposed text.** In combat-defence.md rule 9, after "…and a poison slips past it.", add: "A tick on linh lực passes every shield, whatever its list (Combat Damage Types rule 4)."

### DT-03 — NIT — SAFE — One key's sum can pass 100 pp, and `c_k` is stated as 0–1

**Location:** Formulas A, `c_k` range "0–1" (line 220). Rule 6, "The modifier step" (line 145).

**Problem.** Each `convert_pct` key is summed from every matching record. Stacking sources is how a build reaches 40–50 % (effects.md line 362). Nothing stops a key reaching 120 pp, which gives `c_k` = 1.2, outside "0–1". The scaling rule only covers conversions that "sum above 100 %", so one key over 100 is easy to miss. Modifier rule 7 says a clipped sum shows the clip in the Breakdown.

**Proposed text.** Add to the modifier-step bullet: "A key whose sum is above 100 pp counts as 100 pp, and the Breakdown shows the clip." Add to AC-DT-32: "**GIVEN** a key whose sum is 120 pp, **THEN** `c_k` is 1.0 and the Breakdown shows the clip."

### DT-04 — NIT — DECISION — Scaling in a step is not said to be per part

**Location:** Rule 6 "Steps" (lines 135–138). Formulas A expression (line 211). Tuning Knobs, "Conversions per hit" 1–3.

**Problem.** The text says conversions from one type in one step "sum above 100 % … are scaled down to 100 %". Whether the sum is taken over the whole step or per part matters once a part's history blocks one conversion. At the default of 2 this cannot happen, because it needs one earlier conversion plus two in the step, which is 3. But the Tuning Knob allows 3. Worked case, knob at 3:

- Art authored 50 % Force and 50 % Physical. Art step: Force → Physical 100 % (count 1). Force is removed. Part A is Physical 0.5 with no history. Part B is Physical 0.5 with history {Force}.
- Effects step: Physical → Force 70 % (applies to A only, since Force is in B's history) and Physical → Cold 50 % (applies to both). Sum 1.2.
- **Scaled over the step:** 0.7 / 1.2 = 0.5833 and 0.5 / 1.2 = 0.4167. B gets Cold 0.5 × 0.4167 = 0.208 and keeps Physical 0.292.
- **Scaled per part:** B sees only Cold 50 %, sum 0.5, so no scaling. B gets Cold 0.25 and keeps Physical 0.25.

Two readings give two results.

**Options.**

- **A (recommended).** Per part. For each part j, the kept conversions that apply to j are summed and scaled if over 100 %. This matches the Formulas A line "Σ c_k over that step's conversions that apply to j".
- **B.** Once per step, over every kept conversion from that type. Simpler to state, but a conversion that does not touch a part still shrinks what that part converts.
- **C.** Fix the knob at 2 and drop the 1–3 range. The ambiguity then cannot occur.

**Proposed text (option A).** In rule 6 "Steps", change "and if they sum above 100 % they are scaled down to 100 %" to "and if the ones that apply to a part sum above 100 %, they are scaled down to 100 % for that part". Add one AC with the case above, knob at 3: B's Cold share is 0.25.

### DT-05 — NIT — SAFE — The Dependencies table does not list the conversion row

**Location:** Dependencies, Modifier System and Effects System rows (lines 275–276).

**Problem.** The Interactions table says the Modifier System gives in "conversion modifiers (`convert_pct`)", and the Effects row says "conditional conversions only". The Dependencies rows still say "Damage-type and element scopes" and "Conversion records".

**Proposed text.**

- Modifier System row, "What this system needs": "Damage-type and element scopes; the `convert_pct` row".
- Effects System row: "Conditional conversion records; element-relation Effects (none yet)".

### DT-06 — NIT — SAFE — Rule 4's qi-tick row names only Force resistance

**Location:** Core Rule 4 table (line 113). AC-DT-30 (line 381).

**Problem.** Rule 5 says "all resistance" applies to every type except Soul. Combat Defence's row (line 69) says "resistance (all + Force, rule 3)". Here the row says "Force resistance". A tester could skip all resistance.

**Proposed text.** Line 113: "all + Force resistance (rule 5) → linh lực". AC-DT-30: add "**GIVEN** all resistance 0.10 and Force resistance 0.20, **THEN** the tick is reduced by 0.30". Check: 0.10 + 0.20 = 0.30, under the 0.75 cap.

### DT-07 — NIT — SAFE — A ragged line in Edge Cases

**Location:** Edge Cases, "If three conversions meet one step" (lines 264–266).

**Problem.** The b5ca784 edit left a short line break mid-sentence: "…less any already kept in earlier steps, then scaled if they exceed / 100 %; the third is logged as ignored."

**Proposed text.** Reflow as: "**If three conversions meet one step**: the first two in compile order that move something are kept, less any already kept in earlier steps, then scaled if they exceed 100 %; the third is logged as ignored."

### DT-08 — NIT — SAFE — The header lines do not mention the second re-review

**Location:** Status and Last Updated lines (lines 3 and 5).

**Problem.** Status ends with the first re-review's answers. Last Updated says "re-review answers applied; see `reviews/rereview-2026-11-08-decisions.md`". The 2026-11-08b answers are named only in the review log and `rereview-2026-11-08b/`.

**Proposed text.** Append to Status: "Second re-review 2026-11-08b (fresh session): all 14 findings applied (modifier step, host order, scoped conversions as modifiers, whole-pp grid); see `reviews/rereview-2026-11-08b/combat-damage-types.md`." Change Last Updated to: "2026-11-08 (second re-review applied; see the review log)".

### DT-09 — NIT — SAFE — The new row in Combat Defence's path table is not indented

**Location:** combat-defence.md line 69 ("| Tick on linh lực (Qi Disruption) | …").

**Problem.** Rows 65–68 and 70–71 start with three spaces, to sit inside the list item. Line 69 starts at column 0. In most Markdown renderers this ends the table, so the Soul and Curse rows below it stop rendering as rows.

**Proposed text.** Indent line 69 by three spaces, like its neighbours.

### DT-10 — NIT — SAFE — The `c_k` description cell is over 700 characters

**Location:** Formulas A variables table, `c_k` row (line 220).

**Problem.** Every round has added a clause to this one cell. It now holds the limit, the order, the host order, the modifier step, the sum rule, the Soul rule, the history rule and the share-0 rule. It repeats rule 6 and is hard to implement from.

**Proposed text.** Keep in the cell: "Conversion share. Which conversions apply, in what order, and how many, is Core Rule 6." Add a short "Conversion order" list under Formulas A that restates rule 6 once, with no new content.

### DT-11 — NIT — SAFE — The registry notes miss two rules

**Location:** entities.yaml, `damage_parts` notes (line 1191).

**Problem.** Notes say "(one that moves nothing is not counted)" but not that it is judged on the shares at the step's start, nor that conversions kept in earlier steps count toward the 2. Both were added to rule 6 in b5ca784.

**Proposed text.** Append to the notes: "A conversion that moves nothing is judged at the step's start and skipped. Conversions kept in earlier steps count toward the 2 (user decision 2026-11-08b, DT-03)."

### DT-12 — NIT — SAFE — Two ACs lack the detail to test them

**Location:** AC-DT-27, last GIVEN (line 378). AC-DT-32, second GIVEN (line 383).

**Problem.**

- AC-DT-27's last case names no hit and no shares. Fire → Lightning only "moves nothing" if the hit has no Fire at the step's start.
- AC-DT-32's penalty case says "a penalty that brings a key's sum to −5 pp" with no records, so a tester cannot build it.

**Proposed text.**

- AC-DT-27: change the last GIVEN to "**GIVEN** an all-Physical hit and, in one step, Fire → Lightning (it moves nothing), then Physical → Fire 40 % and Physical → Cold 30 %, **THEN** both Physical conversions are kept, and the parts are Physical 0.30, Fire 0.40 and Cold 0.30." Check: 1 − 0.4 − 0.3 = 0.3; the sum 0.7 is under 1, so no scaling.
- AC-DT-32: change the second GIVEN to "**GIVEN** two records on `convert_pct` Physical → Fire, +10 pp and −15 pp (sum −5 pp), **THEN** that key is no conversion, does not count toward the 2, and the Physical part is unchanged".

## Not reopened

Settled and left alone: conversion modifiers allowed; the Primordial Chaos name; the qi-tick path; "slot order, then record id"; the step tiers (art, Effects, modifiers); same-step reads at the step's start; one conversion per key in rule 1's type order; scoped conversions as modifiers; the whole-pp grid. The absent Player Fantasy section stays advisory at `standard`.

## Autonomous decisions

- Freshness: the GDD changed since the last report (commit b5ca784), so a full review ran.
- No question could be asked. Where the skill would ask, I took its recommended option: verdict NEEDS REVISION (light), report only, no revise-now, no systems-index or review-log update.
- Next step for the user: answer DT-01 and DT-04, apply the SAFE fixes, then run a short check.

## Receipt

```
Reviewed-Commit: b5ca784
Target: design/gdd/combat-damage-types.md
Cross-read: combat-defence.md, modifiers.md, effects.md, item-database.md, character-stats.md, combat.md, design/registry/entities.yaml
```

---

**Final summary:** Verdict NEEDS REVISION (light). 0 blocking, 2 recommended, 10 nit; 10 SAFE, 2 DECISION. The report could not be written (permission refused), so the parent session should save it to `design/gdd/reviews/rereview-2026-11-08c/combat-damage-types.md`.