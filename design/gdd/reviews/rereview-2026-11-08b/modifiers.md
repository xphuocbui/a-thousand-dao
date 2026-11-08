# Re-review — Modifier System (`design/gdd/modifiers.md`, #40) — 2026-11-08 (evening, pass b)

Review mode: lean (no specialists) · Workflow: standard · Run unattended: where `/design-review` would ask, its
recommended option was taken. The receipt check showed the GDD, the registry, effects.md, combat-defence.md,
combat-damage-types.md and the generator CHANGED since the last log entry (commit 9400de1), so this was a full review.
Nothing was edited except this new file. The review log, systems index and registry were not touched.

## Verdict: APPROVED

Both carried blockers are closed. Re-review MD 1 is applied: rule 8 now has a whole-hit bullet (largest part, ties
by the fixed type order), an art bullet (authored parts), an Edge Case and AC-MD-31. MD 2 is applied: the
`[fire, over_time]` row is gone from this GDD, from Defence Formulas I and from the generator. The other answers
(MD 3–18) are in place, and so is the conversion decision (DT 2): `convert_pct` is an ordinary Designed stat at
0.8 W (G), implied family, on the 1 pp grid, 42 rows. The generator's output matches the General Catalogue exactly
by scripted diff, including `Concrete modifiers listed: 266` (AC-MD-27). Every numeric AC and formula example was
recomputed, and the rounding lint was run over every catalogue row. No registry conflict was found. No finding
blocks. Nine recommendations remain. Most are wording that still calls conversion an Effect, or loose ends of the
new rules: `convert_pct`'s record has no from/to fields; crit is listed under two targets; accuracy and pierce
have the same multi-type gap MD 1 closed for crit; and status-tag scopes are still marked Pending after MD 4. Three
need your choice (MD-04, MD-08, MD-09).

**Counts:** blocking 0 · recommended 9 · nit 7 · SAFE 13 · DECISION 3.

## How it was checked

- **Completeness (standard tier):** Overview, Detailed Design, Formulas, Edge Cases, Dependencies and Acceptance
  Criteria are present (6/6 required, with Formulas required). Player Fantasy is absent, which is advisory at
  `standard`. Tuning Knobs is present.
- **Catalogue:** `python -I tools/design/modifier_catalogue.py` was diffed against lines 424–597 with blank lines
  ignored. The diff was empty. Count 266 = 224 + 42 conversion pairs (7 non-Soul types × 6 targets).
- **Rounding lint:** every generated row at both grades. Only three pass 15 %: typed block broad small
  (3.75 → 3, 20.0 %), breakthrough small (0.24 → 0.2, 16.7 %) and density small (0.0086 → 0, 100 %). These are the
  three listed exceptions. One stat outside the generator also passes it (MD-08).
- **Recomputed by hand:** AC-MD-05 (115 · 1.5 = 172.5), AC-MD-06 (100 · 1.5 · 1.4 · 1.2 = 252), AC-MD-16 (all eight
  breadth values), AC-MD-17/18/19, AC-MD-20 (1.265 / 1.4 = 0.904; 20 × 1.513 = 30.3; floor(8 / 0.904 / 0.1) × 0.1 = 8.8;
  DT 3.465 / (0.5 · 1.4) = 4.95), AC-MD-32 (1.2 · 1.5 / 0.8 = 2.25 → 2; 8 · 1.5 / 0.8 = 15), realm drift
  (4.95 / 0.904 = 5.48), resistance effective prices (1.25 / 1.25 = 1.0; 1.25 / 1.5 = 0.83) and the Formulas C range
  (25.8 · 2.5 / 0.3 = 215; 60 · 2.5 / 0.3 = 500; the 0.15 W stats cannot be scoped, so 25.8 / 0.15 = 172 stays below).
- **Registry:** all 281 entry names searched in the GDD (63 lines, 22 terms). None conflicts. `stat_power_weights`
  now holds the full (key, op) table with `convert_pct` 0.8. `stat_precision_grid` puts `convert_pct` on 1, both regens
  on 0.01 and `lifespan_years` on 0.1. `modifier_value`'s range is 215 / 500. `resist_cap` is 0.75,
  `resist_cap_max` 0.90 and `recharge_delay` 2.0.
- **Dependency files:** combat.md, combat-defence.md, combat-damage-types.md, character-stats.md, effects.md,
  kinh-mach-do.md, quests.md, cong-phap.md and dao.md all exist. Market, Time & Turn, Talismans and the other
  quick-spec systems have no GDD, which the Dependencies table already says.

## Prior answers: applied?

| Answer | Applied where | OK? |
|---|---|---|
| MD 1 type scopes on whole-hit and whole-art stats | Rule 8 (lines 106–109, 114–115), Edge Cases line 898, AC-MD-31 | Yes. MD-03 and MD-06 are wording slips; MD-04 is the same gap on two more stats |
| MD 2 remove `[type + mode]` resistance | Catalogue, generator, Defence Formulas I | Yes |
| DT 2 conversion modifiers allowed | Stat List line 274, rule 8 line 110, catalogue line 478, AC-MD-32, Left-out list line 398, DT rule 6 | Yes. Older text still calls conversion an Effect (MD-01). The record has no from/to fields (MD-02) |
| MD 3 Effect payloads exempt from W | Rule 12 line 214, rule 13 line 228, AC-MD-23 | Yes. The Summary still says otherwise (MD-01) |
| MD 4 status family | Rule 9 table line 168; Effects Status Catalogue Tags column | Yes. The Pending marks on status scopes were not lifted (MD-07). Rule 8's scope families omit it (MD-05) |
| MD 5 floors for lower-is-better | Rule 7 | Yes |
| MD 6 prices keyed by (key, op) | Formulas A, AC-MD-21, registry | Yes |
| MD 7 AC cases | AC-MD-10, AC-MD-23 | Yes |
| MD 8 six dependency rows | Interactions line 653, Dependencies line 928 | Yes |
| MD 9, MD 11, MD 12, MD 13, MD 14, MD 15, MD 16, MD 17, MD 18 | OQ 3; DT rule 5; Defence OQ 1; registry; Realm drift; Formulas A artifact defence; Stat List grids; table headings; rule 8 incoming-hit bullet | Yes. OQ 8 is now stale (MD-13) |
| MD 10 lint exceptions and knob | Formulas E, Tuning Knobs | Yes. One more pair fails the lint (MD-08) |

## Findings

### MD-01 — RECOMMENDED — SAFE
**Location:** header `> **Scope**` (line 8); Summary (lines 15–17); Overview, last paragraph (lines 39–41).
**Problem:** Three passages contradict the 2026-11-08 decision that a plain conversion share is a modifier.
- Line 8: "Effects (conditions, scaling, triggers, conversion, keystones, enablers) are a separate system".
- Line 40: "Anything with a rule in it (a condition, scaling, a trigger, a conversion, a keystone or an enabler) is an **Effect**".
- Lines 15–16: "One price list in W … size every modifier the same way, wherever the tree, a technique, an item, a pill
  or an Effect grants it". Rule 12 (MD 3) exempts Effect payloads from W. The re-review flagged this in pass 1, but
  only rule 12 was changed. "One conversion formula" also now reads like damage conversion.

**Fix:**
- Line 8: "Effects (conditions, scaling, triggers, conditional conversion, keystones, enablers) are a separate system
  with their own GDD (user decision 2026-11-07). A plain conversion share is a modifier (`convert_pct`, user
  decision 2026-11-08)."
- Line 40: "Anything with a rule in it (a condition, scaling, a trigger, a conversion with a condition, a keystone or
  an enabler) is an **Effect** …"
- Lines 15–17: "One price list in W, five breadth tiers and one value formula size every modifier the same way,
  wherever the tree, a technique, an item or a pill grants it. An Effect's payload uses the same records unpriced
  (rule 12). Rules (conditions, triggers, keystones) are Effects, a separate system."

### MD-02 — RECOMMENDED — SAFE
**Location:** Core Rules, rule 1 (lines 51–57); AC-MD-01 (line 1004).
**Problem:** The record holds `stat`, `op`, `value`, `layer`, `scope` and `tags`. But `convert_pct` is "keyed by
its from and to types" (rule 8 line 110, Stat List line 274, DT rule 6). The record has no field for them, so a
programmer must guess. Validation (AC-MD-32: not Soul, not to itself) also needs them.
**Fix:** Add to rule 1's list:
"- `from`, `to`: damage types, only on `convert_pct` and required there (Combat Damage Types rule 1). Neither may be
`soul`, and `to` may not equal `from`. Every other stat rejects them."
Add to AC-MD-01: "**GIVEN** `convert_pct` with no `to`, or `from` on `attack_pct`, **THEN** it is rejected."

### MD-03 — RECOMMENDED — SAFE
**Location:** rule 8, outgoing-hit bullet (line 103); Stat List rows Crit chance and Crit damage (lines 263–264).
**Problem:** Line 103 says "damage, crit, pierce, accuracy and resistance penetration match the hit part's tags".
Line 106 then gives crit its own whole-hit rule. A programmer reading line 103 matches crit per part. The Stat List
still gives both crit rows the target "outgoing hit".
**Fix:** Line 103: "**outgoing hit**: damage, pierce, accuracy and resistance penetration match …". In lines 263–264,
set Target to "whole hit (rule 8)".

### MD-04 — RECOMMENDED — DECISION
**Location:** rule 8, outgoing-hit bullet (line 103); Stat List Accuracy and Realm pierce (lines 265–266).
**Problem:** Accuracy enters `p_evade`, which is rolled once per hit (Combat Formulas I; DT rule 4 "Evade applies to
every hit"). Realm suppression (`supp`) is one value per attacker and defender pair (Combat Formulas H). Neither
can be read per part. So a damage-type scope on them ("+5 pp accuracy, [fire]") has the same multi-type gap MD 1
closed for crit. Evade is also rolled before conversion (DT States), so crit's "or has it in its history" cannot
apply to accuracy. No catalogue row uses such a scope today (accuracy is universal only; pierce is universal and
[art]), but rule 8 allows one.
**Options:**
- (a) **Forbid damage-type scopes on accuracy and realm pierce.** Element, form, mode and source scopes still apply,
  as they read the art's tags. Add "accuracy or pierce scoped by a damage type" to AC-MD-12's reject list.
  No row changes.
- (b) Use MD 1's whole-hit rule, with authored parts for accuracy (it is read before conversion) and the largest
  part after conversion for pierce. This means two timings to explain.
- (c) Leave it until a row needs it, and note it in Open Questions.

**Recommendation:** (a). It costs nothing today and keeps one whole-hit rule.
Fix for (a): move both stats to a "whole hit" target, and add to rule 8: "Accuracy and realm pierce are one value per
hit, so they take no damage-type scope; element, form, mode and source scopes read the art's tags."

### MD-05 — RECOMMENDED — SAFE
**Location:** rule 8, last paragraph (lines 134–136).
**Problem:** "A scope holds at most **two** tags, drawn from the damage type family, Combat's families (element,
form, mode, source, effect), the derived art tags (rule 10), the artifact role family and the Pending foe and
activity families (rule 9)." This omits the **status** family (MD 4) and the **heal source** family
(`body_shield`). Yet rule 11 tiers "one status tag" as narrow, the Stat List scopes status resistance "by one
status", and the catalogue has `[body_shield]` and status rows. Read literally, validation rejects them as tags
from no allowed family.
**Fix:** "… the artifact role family, the status family, the heal source family and the Pending foe and activity
families (rule 9)."

### MD-06 — RECOMMENDED — SAFE
**Location:** Acceptance Criteria, AC-MD-31 (line 1048).
**Problem:** "**GIVEN** the same hit after Physical → Fire 50 % (parts 0.3 Physical, 0.7 Fire), **THEN** it counts."
Conversion spawns a new part and does not merge parts of the same type (Combat Damage Types Formulas A). Working:
the Physical part is 0.6; 0.6 × 0.5 = 0.3 is spawned as Fire with history {Physical}; 0.3 Physical is left; the
authored 0.4 Fire is unchanged. That gives **three** parts: 0.3 Physical, 0.3 Fire (history Physical), 0.4 Fire.
No part is 0.7. The verdict still holds, because the largest part (0.4) is Fire. But a test built from the AC's
figure would test a merged-part model that rule 8 ("the hit's largest **part**") and DT do not use.
**Fix:** "**GIVEN** the same hit after Physical → Fire 50 % (parts 0.3 Physical, 0.3 Fire with history Physical,
and the authored 0.4 Fire), **THEN** it counts: the largest part, 0.4, is Fire. **GIVEN** parts of 0.35 Physical,
0.33 Fire and 0.32 Fire (history Physical), **THEN** a [fire] crit scope does not count, because parts are not
summed by type."
(The second case pins the per-part reading. The same reading is used by Effects' Sundered.)

### MD-07 — RECOMMENDED — SAFE
**Location:** Stat List, Status resistance (line 295); General Catalogue row "against status: burn, bleed,
frostbite, qi_disruption (Pending)" (line 512); rule 8 outgoing-status bullet (lines 118–119); Open Question 4
(line 1059).
**Problem:** MD 4 made the status family real. The Effects Status Catalogue now has a Tags column with one status
tag per status (effects.md lines 193–195, 270–298). But line 295 still says scopes by one status "wait on status
tags". The catalogue row is still Pending. OQ 4 still lists "status tags" as owed. Rule 8 reads a status's
"damage type, mode and effect tags" and leaves out its own status tag. Under this GDD's own convention ("Scoped rows
are *Designed* even on a Live key"), these rows are Designed now. The `[body_shield]` scope does stay Pending:
Defence does not define that tag yet (its OQ 15).
**Fix:**
- Line 295 Owner cell: "Combat F. Scopes by one status read the status tags (Effects Status Catalogue; re-review MD 4)."
- Line 512: change the label to "against status: burn, bleed, frostbite, qi_disruption" and the Status to Designed.
  This needs the same label edit in `tools/design/modifier_catalogue.py` (line with `"<status>"`), then a
  regenerate. The count is unchanged at 266.
- Line 118: "… match the status's own tags (its status tag, damage type, mode and effect tags, Effects System
  Status Catalogue) …"
- OQ 4: change "status tags and the [body_shield] scope (Effects, Combat Defence & Healing)" to "the [body_shield]
  scope (Combat Defence & Healing)".

### MD-08 — RECOMMENDED — DECISION
**Location:** Formulas E, lint exceptions (lines 849–852); General Catalogue "Lifespan in years" (lines 626–628).
**Problem:** The lint flags "any stat and grade pair that loses more than 15 % to rounding". `lifespan_years`
does so at Qi Refining, but it is not in the generator, so it is not in the known-exception list. Working: price
300 / L_r = 300 / 120 = 2.5 W per year; a small buys 1.2 / 2.5 = 0.48 years; on the 0.1 grid
(`stat_precision_grid`) that floors to 0.4; loss 0.08 / 0.48 = **16.7 %**. The notable is exact (8 / 2.5 = 3.2). At
Nascent Soul the loss is under 1 % (1.2 / 0.3 = 4.0; 8 / 0.3 = 26.67 → 26.6). The GDD's own figures (+0.4, +3.2)
agree with this.
**Options:**
- (a) **Add it as a fourth known exception:** "lifespan in years at small, Qi Refining, loses 16.7 %."
- (b) Move `lifespan_years` to the 0.01 grid. That is a Character Stats and registry change, and Live data uses 0.1.
- (c) Scope the lint to the generated catalogue only, and say so.

**Recommendation:** (a). It matches your MD 10 answer for the other three.

### MD-09 — RECOMMENDED — DECISION (cross-document; the fix lands in effects.md)
**Location:** this GDD rule 8 conversion bullet (lines 110–111) and the Left-out list (line 398), against
effects.md header Scope (line 8) and Starter Effects "Conversion and overflow" (lines 350–352).
**Problem:** Your Modifier vs Effect rule now makes a plain conversion share a modifier. A tag scope is a fixed
tag match, never a condition (rule 8, foe bullet). Three starter Effects are exactly that and nothing more:
- Flame-Tempered Edge: 40 % of Physical in sword hits → Fire = `convert_pct` Physical → Fire, scope [sword].
- Thunder Palm: 50 % Force → Lightning in palm hits = `convert_pct` Force → Lightning, scope [palm].
- Rot Seeps In: 25 % Physical → Chaos in Wood-element hits = `convert_pct` Physical → Chaos, scope [moc].

As Effects they are unpriced. As modifiers, Formulas C prices them (implied family + one family tag = narrow, ×2.0):
40 × 0.8 / 2.0 = **16 W**, 50 × 0.8 / 2.0 = **20 W**, 25 × 0.8 / 2.0 = **10 W**. So the same number now has two
homes and two pricing rules. That breaks this GDD's Overview promise ("costs the same wherever it appears").
Effects' Scope line also still lists "conversion" as a rule. Field Walls ("counts as") is a real rule and stays.
**Options:**
- (a) **Re-express the three as `convert_pct` modifiers** carried by their named hosts (a technique, item or Way
  node grants the modifier). Drop them from the Effects starter catalogue, and change effects.md line 8 to
  "conditional conversion".
- (b) Keep them as named Effects. Write in rule 1 here that a hosted, named conversion may be either, and accept two
  prices for one number while Effects are unpriced.
- (c) Defer to the Effects re-review, with an Open Question here.

**Recommendation:** (a), applied at the next effects.md revision. It is what your 2026-11-08 conversion answer
implies. Index row #41's description ("conversions") would need the same edit.

### MD-10 — NIT — SAFE
**Location:** Stat List, Damage conversion (line 274).
**Problem:** Other off-default grids are stated in the row ("grid 1" for block, "grid 0.01" for both regens).
`convert_pct` is on the 1 pp grid in the registry, the generator and AC-MD-32, but its row does not say so.
**Fix:** Ops cell: "F (pp of the from type's share; grid 1)".

### MD-11 — NIT — SAFE
**Location:** rule 8, conversion bullet (line 111); AC-MD-12 (line 1018).
**Problem:** "A scope narrows it by the art's tags." The bullet does not say whether a damage-type scope is legal on
`convert_pct`. By "a scope the stat's target can never match fails validation" it should be rejected, because the
`from` field already names the type. But an implementer may read [fire] on a Physical → Lightning conversion as a
history match.
**Fix:** "A scope narrows it by the art's element, form, mode, source or effect tags; a damage-type scope is
rejected (the `from` type already names it)." Add "`convert_pct` scoped [fire]" to AC-MD-12's reject list.

### MD-12 — NIT — SAFE
**Location:** rule 9 table, effect family (line 163) and status family (line 168).
**Problem:** `poison` is listed in both the effect family (Combat rule 6) and the status family (the Poison status).
Effects' Poison record carries one `poison` tag. Both families are narrow, so no number changes. But "one
vocabulary" with one string in two families leaves the owner unclear.
**Fix:** In the status row, write "poison (the effect tag `poison`, shared)" and add under the table: "A tag
listed in two families is one tag; its tier is the same in both."

### MD-13 — NIT — SAFE
**Location:** Open Questions, row 8 (line 1063).
**Problem:** "Register the full price table in `stat_power_weights` …" is done. The registry entry holds the
(key, op) table with `resist_pct` 1.25 and `convert_pct` 0.8, notes "Full table registered 2026-11-08 (re-review
MD 13)", and `modifier_value` runs to 500.
**Fix:** "| 8 | Closed 2026-11-08: the full price table is in the registry's `stat_power_weights`, keyed by key and
operation (re-review MD 13) | — | Closed |". Optionally, add one line in Formulas A saying that `modifier_prices`
is registered as `stat_power_weights`. The GDD uses both names.

### MD-14 — NIT — SAFE
**Location:** Interactions, Combat Damage Types row (line 656); Dependencies, Combat Damage Types row (line 918).
**Problem:** Line 656 has direction "in" only. Since DT 2 this system also supplies the `convert_pct` rows to DT's
modifier step (DT's own Interactions line 189 lists "Modifier System | in | Conversion modifiers"). Line 918 names
only scopes as what this system needs.
**Fix:** Line 656: "in / out | In: the damage-type family, history tags, element tags as art tags. Out: `convert_pct`
rows for the modifier step | Combat Damage Types (the conversion rules); this system (the row and its price)".
Line 918: "The damage-type family that scopes damage, penetration and resistance; the conversion steps and
2-per-hit limit `convert_pct` obeys".

### MD-15 — NIT — SAFE
**Location:** rule 7 (lines 93–96); Edge Cases, "If a stat's sum passes its owner's cap" (lines 885–887); Stat List
Linh lực regeneration (line 308).
**Problem:** The caps listed leave out four that clip catalogue stats: linh lực regeneration (`regen_cap` 0.08 per
pulse, Combat E), realm pierce (`pierce_cap` 0.75, Combat H), art cost reduction (`cost_red` 0–0.5, Combat E) and
reservation efficiency (`res_eff_cap` 50, Defence C). The Stat List also says linh lực regeneration is "per second",
but Combat E defines it per pulse (1 s at the default `pulse_interval`).
**Fix:** Rule 7: "… the crit, evade, escape, pierce, resistance, health and linh lực regeneration caps, art cost
reduction's 0.5 and reservation efficiency's 50 …". Edge Cases: add "pierce 0.75, linh lực regeneration 8 pp, art
cost reduction 50 %". Line 308: "pp of maximum per pulse (1 s); grid 0.01".

### MD-16 — NIT — SAFE
**Location:** header Status (line 3); Acceptance Criteria order (lines 1047–1050).
**Problem:** Line 3 reads "… body guard retired).; revised again 2026-11-08 …". AC-MD-31 and AC-MD-32 sit between
AC-MD-29 and AC-MD-30.
**Fix:** Change ").; revised again" to "). Revised again". Move AC-MD-30 above AC-MD-31. Neither change alters
an ID.

## Scope signal

Rough scope signal: L (13 hard and soft dependencies, five formulas, cross-cutting validation; producer should
verify before sprint planning).

## Next step

Apply the 13 SAFE fixes, MD-07's generator label included. Answer MD-04, MD-08 and MD-09. Then record the
approval in `reviews/modifiers-review-log.md` and systems-index #40. This run did not write either one.
