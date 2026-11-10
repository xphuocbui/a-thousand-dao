# Design Review: Character Stats (2026-11-10)

Mode: lean (standard workflow), autonomous, report-only. No GDD, registry or code was edited.
Re-review: yes. The prior verdict was NEEDS REVISION (independent review, 2026-11-05, 7 blocking). Its fixes were never re-reviewed on their own, but a cross-GDD pass found no blockers.
Specialists: none (lean).
Document: `design/gdd/character-stats.md`, 84 KB, 1,288 lines, read in full.
Read against: the registry (`design/registry/entities.yaml`), `canh-gioi.md`, `linh-can.md`, `kinh-mach-do.md`, `modifiers.md`, `combat.md`, `combat-defence.md`, `combat-damage-types.md`, `effects.md` and `dao.md`, plus `design/research/meridian-*.md`.

## Verdict: NEEDS REVISION

The numbers still hold. About 70 values were recomputed:
- the Formulas C table (40 cells);
- the D, E, F and H examples;
- the #4 shares;
- AC-CS-06, 09, 11, 12, 14, 17, 18, 25, 33, 39, 43, 44;
- the new curve examples in Formulas I (18.9, −0.5, −15.9, 46.7 %, 17.7, 12.7) and Wood 60 → 1.582.

All of them reproduce.

The failure is that the 2026-11-10 "no caps" change (the rule 14 ceilings became log curves, `alchemy_success` dampens, `max_plots` is gone) was applied to rule 14, Formulas G and I and the Parameter keys. It was not applied to Edge Cases, to the ACs, to Tuning Knobs, to the Formulas I output range, to the registry or to Realms. The GDD now says two things at once about the same totals. Rule 15's key list is also out of step with the Modifier System's Stat List, which blocks data validation as written.

Completeness at `standard`: 5 of 5 required sections are present (Overview, Detailed Design, Edge Cases, Dependencies, Acceptance Criteria), and Formulas and Tuning Knobs are present. Player Fantasy is absent, which is advisory and noted as CS-14.

Dependency graph: every depended-on GDD exists (`linh-can`, `canh-gioi`, `kinh-mach-do`, `cong-phap`, `dao`, `modifiers`, `effects`, `combat`, `combat-defence`, `thien-kiep`, `quests`, `item-database`). Systems with no GDD are Time & Turn, Event Engine, Market, NPC Interaction, Formations, Spirit Herbs, Alchemy and Progression Edges (which has a quick spec only). Those interfaces are correctly marked provisional.

Scope signal: L (about 10 formula blocks, 12 or more dependencies, a stat-key contract used by every system). Producer should verify.

## Blocking

### CS-01 (blocking) The "no caps" curves are in rule 14 and Formulas I, but the rest of the GDD still describes ceilings
Locations and what is stale (the new rule says total = k·ln(1 + Σ⁺/k) + Σ⁻):
- **Edge Cases → Stat sheet.** "If the lifespan bonus sits above the ceiling: the raw sum is kept…" and "If a ceiling key holds bonus above its ceiling and a penalty". The second gives "+60 with −20 = 10 − 20 = −10, ×0.9". Under the curve it is 10·ln 7 − 20 = −0.5 (Formulas I's own example). Rule 14's text also says "−10, not min(40, 10)".
- **AC-CS-28.** Expects Wood 60 with +10 → 1.628 and "sources summing to +40 → total 10 with a clamp line → 1.628". Under the curve, +10 → 6.93 → 1.582 (Formulas G's example) and +40 → 16.09. It also expects "Earth 100 with +7 → 12 (clamped)", but plots have no upper bound now (3 + 4 + 7 = 14). Both lines are testable and wrong.
- **AC-CS-52.** "bonus is min(40, 30) = 30 … with a clamp line". Under the curve k = 0.15 × 200 = 30 and the pill of 10 is part of the sum, so B_life = 30·ln(1 + 40/30) = 25.4 and the cap is (200 + 25.4) × 1.10 = 248.0 (the first case, pill 10 + 5, gives 30·ln 1.5 = 12.16 and a cap of 233.4, not 236.5).
- **AC-CS-54, every ceiling bullet.** These include "total of 10, with a clamp line", "+8 and +6 give 10", "`alchemy_success` 2 + 2 gives 3", "+2, +2 and +3 gives 3, with a clamp line (7 → 3)" and "a lifespan bonus of 18, with a clamp line". It also expects a stored bonus of 40 to count 18 / 30 / 40, and "−30 alone → cap 90". They contradict Formulas I's examples (18.9, 46.7 %, 17.7).
- **AC-CS-56.** "lifespan bonus of 18 … cap 138 × 1.45". With two +15 arts it is 17.7, so the cap is (120 + 17.7) × 1.45 = 199.7.
- **Formulas I, Output Range.** "A ceilinged total is at most its ceiling" and `B_life` "at most f_life · L_realm". Both are false for a log curve, which is unbounded (slowly). The variable table row for `B_life` repeats it.
- **Formulas G, `herb_growth_pct` row.** Says "after the rule 14 curve (scale 10), no ceiling" (correct), but its description still says "ceilinged with penalties added after the cap".
- **Tuning Knobs, `bonus_curves` row.** Safe range "5–10, 2–3, 0.10–0.15: at most the current values". The 2–3 is the old `alchemy_success` ceiling, which is no longer a curve scale, and "at most the current values" was the ceiling guard. The row also still says "Penalties apply after the cap".
- **Rule 14 prose.** The paragraph "Three totals slow down… They were capped, because…" mixes the old and new rationale. The "What is capped" bullet still says "every sheet modifier on a ceiling key is capped" and "A root term… are not capped".
- **Edge Cases, "If the tree's `breakthrough_chance` … exceed 8 pp".** This one is still correct (the tree cap and q-extras ceiling remain), so leave it.

Fix: do one pass for the curve semantics. Rewrite each stale Edge Case and AC with curve numbers (the recomputed ones above), reword "ceiling / clamp line / capped" to "curve / the curve line" for the three curve keys, and correct the Output Range and `B_life` rows. `breakthrough_chance` (tree cap 8, q-extras ceiling) keeps the word "cap". Keep a "curve line" in the Breakdown (a line showing Σ⁺ → curved value) so Pillar 2 still holds.

### CS-02 (blocking) `alchemy_success` dampening is undefined at total ≤ −100 and disagrees with the Modifier System
Location: Formulas I, `fail' = fail ÷ (1 + total / 100)` with `total = Σ v_i`, and rule 14's "`alchemy_success` dampens the brew's failure chance".
- Boundary: total = −100 divides by zero. Below −100 the denominator is negative, so the failure chance flips sign. A single large penalty from an item, a curse or the tribulation reaches this. The formula has no `max(0, …)`, unlike every other `_pct` multiplier in Formulas C, G and I.
- Modifier System rule 6a (dampened): "If a dampened sum is negative: the sum is floored at 0". That is the owner's rule, so a negative `alchemy_success` could never raise the failure chance. Formulas I's `total = Σ v_i` ignores this.
- `modifiers.md` still lists `alchemy_success` as op `F (pp)` (row at line 404). It is not a `D`-op stat, so Character Stats applies a dampen the Stat List does not know about.
- Realms Formulas D (`canh-gioi.md` line 590) still has `p_brew = clamp(p_brew0 + 0.0025·purity_fire + alchemy_success/100, 0.05, 0.95)`: additive, and capped by 3. See CS-06.

Fix: see decision D3. At minimum, state that the dampened sum is floored at 0 (or at −90) and add a boundary AC: total −100, −150 and 0. Make `modifiers.md` and Realms Formulas D say the same.

### CS-03 (blocking) Registry values contradict the GDD
The registry has `bonus_ceilings` as `{herb_growth_pct: 10, alchemy_success: 3, lifespan_frac: 0.15}` and calls them ceilings: "Character-wide ceilings… total = min(sum of positive modifiers, ceiling) + sum of negative modifiers… Lowered 2026-11-04… safe range at most the current values". The GDD now holds curve scales (`bonus_curves`: 10 and 0.15) plus a dampening for `alchemy_success`. Other registry stale items (all owned by `character-stats.md` or its neighbours):
- `lifespan_cap` (owner `canh-gioi.md`, line 504): the expression has `min(pill_years + sum_pos(lifespan_years), lifespan_frac · L_realm)`. It should be the curve `k·ln(1 + x/k)`, and the variables list still names `bonus_ceilings`.
- `bonus_ceiling_target` notes: "a life with every `bonus_ceilings` stat at its ceiling". There is no ceiling now (see Realms OQ8 / Character Stats OQ8).
- `stat_precision_grid` value: has no 0.001 grid for `linh_luc_on_hit_pct`, `linh_luc_on_crit_pct`, `linh_luc_on_kill_pct` and no `stack_grant`. Rule 15 says its precision is "as in the registry's `stat_precision_grid`", so the two disagree. `modifiers.md` rule 1 and line 336 say the grid is 0.001 for the on-event keys.
- `tree_breakthrough_chance_cap` (registry) vs `tree_breakthrough_cap` (this GDD and `kinh-mach-do.md`): a name mismatch for the same key.
- `derived_values.expression` omits the `max(0, …)` floors that Formulas C has. It is the same value but a weaker statement (minor).

Fix: rename and restate `bonus_ceilings` as `bonus_curves` (curve scales, no ceiling, `alchemy_success` dampen separate), update `lifespan_cap`, `bonus_ceiling_target` notes and `stat_precision_grid`, and align the tree cap key name. The user will do these in the sweep.

### CS-04 (blocking) Rule 15's key list does not match the Stat List, so data validation would reject valid keys
Rule 15 says "A key not in this table is rejected by data validation", and the Modifier System's open item 3 says Character Stats' Parameter keys must list the new stats.
- **Missing from rule 15 but live or pending in `modifiers.md`:** `recharge_delay_pct`, `cast_ward_duration_pct`, `status_duration_taken_pct`, `formation_upkeep_pct`, `talisman_ink_pct`, `buy_price_pct`, `sell_price_pct`. Some are "Pending", so they could wait, but then the GDD should say pending keys are deferred, not reject them silently. `refining_success` is in rule 15 and the Stat List, so that one is fine.
- **Listed in rule 15 but retired:** `resist_cap_pct` (retired 2026-11-10 in `combat-defence.md`, `modifiers.md` row 308 and AC-CD-10, which rejects a record with it at load). Also `body_guard_pct` is correctly marked retired in the table, but `modifiers.md` still lists it at lines 317-ish (not this GDD's problem).
- **Units:** the unit list is `pct / flat / years / flag`. Since 2026-11-10, `resist_pct` and `resist_pen_pct` are in points (damage ÷ (1 + R/100), no cap), `damage_more` is in layer points, and the group sentence still files `resist_pct` under "pct (percentage points)". Add a "points" unit, with its meaning, or state that 1 point of resistance is not 1 pp.
- **Precision for the new keys** (`resist_pct`, `resist_pen_pct`, `stack_effect_pct`, `stack_duration_pct`, `art_cost_health_pct`, `leech_*`): rule 15 says all `pct` keys are 0.1. `modifiers.md` gives some of them other grids (0.01, 0.001). Check each against the Stat List and list the exceptions.

Fix: add the seven keys (or mark them "reserved, validated once the owner leaves Pending"), delete `resist_cap_pct`, add the "points" unit and the precision exceptions.

## Recommended

### CS-05 (recommended) Rule 12 and the Interactions table omit new modifier sources and systems
- Rule 12 says "nine source kinds". The Dependencies table already adds three: the Way (Đạo, `dao.md` rules 3 and 4), `tribulation_tempered` (`thien-kiep.md`) and `quest_boon` (`quests.md`). `AC-CS-30` also says nine.
- The Interactions with Other Systems table has no rows for the Way, Modifier System, Effects System, Combat Defence & Healing, Heavenly Tribulation or Quests, though the Dependencies section does. Its introduction is stale: "Time & Turn, Combat, Event Engine and the crafts have no GDD yet… Spiritual Roots and Realms… at Needs Revision; Cultivation Techniques and the Meridian Map… In Review (2026-11-05)". Combat now has a GDD (on hold) and its sub-GDDs.
- The Cross-References table has no `dao.md`, `modifiers.md`, `effects.md`, `combat*.md`, `thien-kiep.md` or `quests.md`.
- Effects System rule 9a: element stack power `(1 + stack_purity_factor × P)` with uncapped purity is a root-style term that bypasses the sheet. Rule 14's "root term" list names Wood, Earth and Fire only. Add stack power so it is clear it is not a sheet modifier, and that `stack_effect_pct` (a sheet key) multiplies on top.

### CS-06 (recommended) The Realms GDD still has the old contract, so this GDD's cross-document claims are false until it is revised
`canh-gioi.md` still has: rule 14 "at most 15 % of the realm's base lifespan"; Formulas D `n_plots = clamp(3 + ⌊0.04·purity_earth⌋ + field_plots, 1, 12)` (Character Stats Formulas G has no upper bound); the `p_brew` term `alchemy_success/100` with "at most 3 pp"; `herb_growth_pct` "at most 10"; AC-CG-60 at line 1901 ("push… to their Character Stats ceilings (10 / 3 / …)"); and Open Question 12. This GDD's Interactions Realms row ("the bonus ceilings on herb growth, alchemy success and lifespan (rule 14)"), its Dependencies text and Formulas I ("The ceiling values are calibrated by Realms") all point at that. Open Question 8 here records the recalibration but not the Realms text that must change.
Fix: list the Realms edits under Open Question 8 as a checklist (rule 14, Formulas D, AC-CG-60, OQ12, the `bonus_ceiling_target` note), and reword this GDD's claims to "Realms reads the curves".

### CS-07 (recommended) "Kill" / "defeat" wording and the post-fight vitality write are out of step with Combat
- Combat's Related-rules table (`combat.md` line 1213) says capability #9 was closed on 2026-11-06 as "knockout only; both GDDs still say 'defeat' and 'kill'". This GDD still says "Kills add none" (rule 8, Formulas E amount row), "+2 per defeat", "a combat kill" (AC-CS-19), and Combat now reports a knockout, not a kill.
- Combat Formulas A: `v_after = min(v, health_end / health_max)`, so vitality never rises in a fight; and "the caller applies Character Stats' floor rules". Character Stats rule 9 and Formulas F list losses (failed breakthrough, mission wound, events) but not a fight loss, and do not say whether the 5 % floor (`vitality_floor`) applies after a fight. This is a gap, not a conflict.
- Open Question 2 still asks "What attack and defense mean in combat, and how combat uses vitality (× max(v, 0.4) as built)". Combat now answers it (health starts at max(v, `v_c`) of its maximum). The Formulas F output range ("Combat reads vitality as × max(v, v_c)") describes the as-built duel, not the Combat GDD's target.
Fix: replace "kill / defeat" with "knockout" where it means #9; add a fight-loss line to rule 9 / Formulas F (does the floor apply? recommend yes, 5 %, matching mission wounds); close or reword Open Question 2.

### CS-08 (recommended) Uncapped purity and plots have no AC, and some ranges are stale
- Purity is uncapped above 100 (`linh-can.md` rule 8a). Water purity feeds toxicity decay (`k_w · purity_water`, Formulas D), where no AC or example uses purity above 100, and the `purity_*` row says "uncapped after rare raises". No AC checks Wood, Metal or Earth above 100 either (AC-CS-28's Earth 100 line is the only one that tops out).
- `field_plots` row in Formulas G says "any; the result is clamped". The only clamp left is the lower bound of 1. The Output Range ("Field plots 1 and up") is right.
- Formulas G Output Range: "the purity term is 1.0–1.8 at birth purities" is correct, but no number is given at purity 150. Add one example (Wood 150 → 1 + 0.008 × 150 = 2.2).
Fix: add AC-CS-58 (purity 150 for Wood, Metal, Earth and Water) and fix the `field_plots` row.

### CS-09 (recommended) Curve outputs and the precision grid are not reconciled
Rule: "quantize at storage, by flooring, once", so each modifier sits on its grid. The curve result (18.9, 17.7, −0.5) is a derived float, but the doc never says so, nor what precision the Breakdown shows. Tests would compare with an unspecified tolerance, and the doc's own examples are rounded to 0.1. Also, `lifespan_years` has grid 0.1 while `B_life` depends on `L_realm`, so the curve changes at each realm step. The edge case "held-back years count again after a great breakthrough" is stale for that reason (see CS-01); the new behaviour is that the same raw sum is re-curved with the larger k.
Fix: state that curve outputs are floats, displayed to 0.1 and compared at 1e-6, and rewrite the held-back edge case.

### CS-10 (recommended) The Meridian Map redraw is not reflected, and several of its facts are unchecked
The hand-drawn tree (`design/research/meridian-tree-overnight.md`, `meridian-land-authoring.md`) is a layout; neither research file mentions capabilities or stat keys, so the geometry cannot contradict this GDD. But `kinh-mach-do.md` was last updated 2026-11-05 and still has the old tree and "Status: In Review". This GDD's hosted capabilities (#2, #4, #9, #25), the `tree_breakthrough_cap` of 8 and the `lifespan_pct` keystone (Vạn Cổ Trường Thanh, +25; it is named in `kinh-mach-do.md` line 2346) are all keyed to that catalogue.
Fix: when the Map GDD is re-based on the redrawn tree, re-verify these ids and names. Until then, add a line to the Dependencies section: "capability ids as in the Meridian Map catalogue of 2026-11-05; re-verify after the redraw". The tree cap's key name differs between the registry and the GDDs (CS-03).

## Minor

### CS-11 (minor) Header is stale
`Status` reads "In Review (2026-11-05 …)" and `Last Verified: 2026-11-05`, although the file changed on 2026-11-09 and 2026-11-10 and the last review verdict was NEEDS REVISION. The systems index row says the same. Update the status to "Needs Revision (2026-11-10)" and the last-verified date after the fixes (the index is not touched in this run).

### CS-12 (minor) Small AC defects
- **AC-CS-51** is labelled "Rule 15, per-element stacking", but the stacking rule is rule 13.
- **AC-CS-26** says "within 1e-9" while the AC preamble sets 1e-6 for floats.
- **AC-CS-19** and **AC-CS-30** are marked "provisional / not blocking", which leaves two Integration ACs unenforceable at the BLOCKING gate. State which story each waits on.
- **AC-CS-16** gives the #25 attack line as +27.0 while rule 18 and AC-CS-39 floor to 27.1 at 54.25. At exactly 54 both agree (27.0). Fine; just keep the heart demon value in the line.

### CS-13 (minor) Wording sweep, see the mechanical list below.

### CS-14 (minor, advisory at `standard`) Player Fantasy is absent
The Overview and Game Feel carry the intent. A short Player Fantasy would help (a talent roll as news, a sheet that reads like self-knowledge). Advisory only.

## Findings that need a user decision

- **D1. Should the toxicity and heart demon resistance factors keep their 0.1–2.0 clamp under "no caps"?** (rules 7 and 8, Formulas D and E, registry `resist_factor_clamp`; AC-CS-09, AC-CS-14 depend on it.) Recommended: keep it. It is a floor on gains, not a bonus cap, and the 0.1 floor stops resistance from deleting heart demon (a design intent stated in Edge Cases). Alternatives: (a) convert to the resistance-in-points shape, gain ÷ (1 + R/100), with no clamp, as Combat did, consistent with "resistance is counted in points", but R ≤ −100 then needs its own guard; (b) keep the clamp but raise the floor to 0.05.
- **D2. Should the effective talent clamp (1–150) stay?** (rule 5, Formulas B, Tuning Knobs.) Recommended: keep. The Market's no-loop limit depends on it (charm 0.4286 at 157), and it is a lever bound, not a power cap. Alternatives: remove it and cap only the price factor (charm clamp at 0.42), or raise it to 157 with the price knob unchanged.
- **D3. How should a negative `alchemy_success` total behave?** (CS-02.) Recommended: floor the dampened sum at 0 as Modifier System rule 6a already does, so penalties on this key do nothing past cancelling bonuses; and make `alchemy_success` a `D`-op stat in the Stat List. Alternatives: let negatives raise the failure chance but floor the denominator at 0.1 (so failure is at most ×10, still bounded by Realms' `p_brew` clamp 0.05–0.95); or keep `alchemy_success` additive in points with a floor and drop the dampen.
- **D4. Who re-tunes the curve scales once Realms is recalibrated (Open Question 8)?** Recommended: Realms and the systems-designer run AC-CG-60 first and Character Stats only changes `bonus_curves` scales (not the form). Alternatives: tune the lifespan curve's `lifespan_frac` now from the formula alone (it does not change the 17.7 / 12.7 examples by much), or give the lifespan bonus a soft ceiling again if the bot run shows pill supply running away.

## Mechanical fixes (one sweep)

1. Edge Cases: rewrite the held-back lifespan case and the "+60 with −20" case with curve numbers (−0.5; −15.9 for +5 with −20) and drop "clamp line" for the three curve keys. (CS-01)
2. AC-CS-28: Wood 60 with +10 → 1.582; the +40 case → herb growth +16.1 → 1.48 × 1.161 = 1.718; Earth 100 with +7 → 14 plots.
3. AC-CS-52 (realm lifespan 200, k = 30, pill 10, `lifespan_pct` +10): with `lifespan_years` +5 the bonus is 30·ln(1 + 15/30) = 12.16 and the cap is (200 + 12.16) × 1.10 = 233.4, not 236.5; with `lifespan_years` +30 it is 30·ln(1 + 40/30) = 25.4 and the cap is 248.0, not 253 with a clamp line.
4. AC-CS-54: rewrite every "clamp / ceiling" bullet with the curve values: two +25 arts and a tree +6 → 18.9; +60 with −20 → −0.5; +5 with −20 → −15.9; +8 and +6 → 10·ln(2.4) = 8.8; `alchemy_success` +2, +2, +3 → 46.7 % from 50 %; QR bonus 17.7 and 12.7.
5. AC-CS-56: 17.7 instead of 18; cap (120 + 17.7) × 1.45 = 199.7.
6. Formulas I: output range ("at most its ceiling") and `B_life` row ("at most f_life · L_realm"); the intro line "The ceiling values are calibrated by Realms".
7. Formulas G: `herb_growth_pct` row description; `total(field_plots)` row ("the result is clamped" → floored at 1).
8. Tuning Knobs: `bonus_curves` row, drop the old "2–3" range and the "after the cap" text.
9. Rule 14: delete "They were capped, because…" history from the body (keep it in the log) or move it to a note; fix the "What is capped" bullet; reword "Penalties apply after the cap" to "after the curve".
10. Rule 13 text "ceilinged by rule 14 below and Formulas I" → "curved by".
11. Rule 15: remove `resist_cap_pct`; add the seven missing keys; add the "points" unit.
12. Rule 12 and AC-CS-30: nine → twelve source kinds (add the Way, `tribulation_tempered`, `quest_boon`).
13. Interactions table: stale intro paragraph; Realms row ("bonus ceilings"); add rows for the Way, Modifier System, Effects, Combat Defence & Healing, Tribulation, Quests.
14. Cross-References: add `dao.md`, `modifiers.md`, `effects.md`, `combat.md`, `combat-defence.md`, `combat-damage-types.md`, `thien-kiep.md`, `quests.md`.
15. Rule 8 / Formulas E / AC-CS-19: "kill / defeat" → "knockout" where it means #9. Open Question 2: close or reword.
16. AC-CS-51 label rule 15 → rule 13; AC-CS-26 tolerance 1e-9 → 1e-6.
17. Status, Last Updated and Last Verified lines in the header.
18. Registry (CS-03): `bonus_ceilings` → `bonus_curves`; `lifespan_cap` expression and variables; `bonus_ceiling_target` notes; `stat_precision_grid` (0.001 keys, `stack_grant`); `tree_breakthrough_chance_cap` vs `tree_breakthrough_cap`.
19. Realms (CS-06): the checklist of text to revise under Open Question 8.

Replacement values above were recomputed in this review; recompute them once more when writing them in (items 2 to 5 were done by hand, not by a test run).

## Registry values searched

Searched the whole GDD for the entries it owns or references: `effective_talent`, `derived_values`, `qi_deviation_chance`, `presence_price`, `talent_roll`, `talent_grade_bands`, `resist_factor_clamp`, `cleanse_potency_floor`, `linh_luc_conversion`, `dan_doc_divisors`, `mi_luc_price_per_point`, `khi_van_reward_ceiling`, `stat_precision_grid`, `stage_power_step`, `failure_tam_ma_gain`, `failure_khi_huyet_loss_frac`, `lifespan_pct_bound`, `ngo_tinh_divisor`, `bonus_ceilings`, `bonus_ceiling_target`, `lifespan_cap`, `tree_breakthrough_chance_cap`, `vitality_floor`, `tam_ma_natural_decay`.
- Values that match: 45 / 16, 30 / 60 / 85 / 99 / 100, 0.1–2.0, 0.25, 0.20, 200 / 100, 0.004, 0.75 + 0.005, 0.15, 15, 0.40, 45, 200, 0.45, 8.
- Conflicts: `bonus_ceilings` (ceilings, not curves), the `lifespan_cap` expression, the `bonus_ceiling_target` notes, `stat_precision_grid` (missing keys), and the tree cap key name. All in CS-03.
