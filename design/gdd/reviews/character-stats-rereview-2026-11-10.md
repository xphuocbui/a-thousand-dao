# Confirming re-review: Character Stats (2026-11-10)

Mode: lean (standard workflow), autonomous, report-only. No GDD, registry or code was edited.
Re-review of: `reviews/character-stats-review-2026-11-10.md` (NEEDS REVISION, 4 blocking) after its answers and fixes.
Read against: the registry, `modifiers.md`, `canh-gioi.md`, `kinh-mach-do.md`, `cong-phap.md`, and the previous review's own text.
GDD sections re-read: header, rules 7-15, Formulas F, G, I and Parameter keys, Edge Cases, Dependencies, Interactions, Tuning Knobs, Cross-References, ACs 19-32 and 51-57, Open Questions 2, 7 and 8.

## Verdict: NEEDS REVISION (1 blocking, small)

Most of the fixes are in and correct. One stale statement of the old tree clamp contradicts the new rule 14, and a few fixes that the answers section lists as done were not actually applied. All of it is mechanical. No user decision is needed.

### (a) Recorded answers and fixes: status

| Item | Status |
|---|---|
| D1 (keep the 0.1-2.0 resistance clamp) | Present (rule 8, Edge Cases, knobs, registry `resist_factor_clamp`). |
| D2 (keep the 1-150 effective talent clamp) | Present (Formulas B, Edge Cases, knobs, registry). |
| D3 (negative `alchemy_success` floors at 0; `D` op) | Present in rule 14, Edge Cases, AC-CS-54, the Formulas I example, `modifiers.md` row 404, registry `bonus_curves` and Realms Formulas D. **Not** in the Formulas I formula line (CS-R03). |
| D4 (Realms calibrates first; this GDD retunes scales only) | Present in rule 14, Formulas I and Open Question 8 (with the Realms checklist). |
| CS-01 curve wording | Mostly. Rule 14, Edge Cases, Formulas I (output range, `B_life`), AC-CS-28, 52, 54 and 56 are done. Tuning Knobs `bonus_curves` row is not (CS-R02). |
| CS-02 floor and boundary AC | Done (AC-CS-54 covers −100 and −150). |
| CS-03 registry | Done: `bonus_curves` is active, `bonus_ceilings` and `tree_breakthrough_chance_cap` are deprecated, `tree_breakthrough_k` is added, and `stat_precision_grid` and `lifespan_cap` are updated. |
| CS-04 rule 15 | Done: the `points` unit, the seven keys, `resist_cap_pct` retired, Pending keys reserved. |
| CS-05 twelve kinds | Done. I counted twelve; AC-CS-30 matches. Stack power is a root term. Interactions and Cross-References rows are added. |
| CS-06 Realms checklist | Done (OQ 8). Realms itself is mostly updated (Formulas D, `p_brew`, `n_plots`); lines ~905 and ~1688 still say "ceilings 10 / 3 / 15 %" and "clamped to 3". That is Realms' own turn. |
| CS-07 knockout | Done (rules 8, E, AC-CS-19, OQ 2 closed). The fight-loss line is only partly done (CS-R04). |
| CS-08 to CS-12 | Mostly done; the leftovers are in CS-R05, CS-R07 and CS-R08. |

Numbers re-derived: all the replacement values are correct to the digits printed. These are 10·ln7−20 = −0.5; +5 and −20 → −15.9; 10·ln6.6 = 18.9; 10·ln2.4 = 8.8; 50/1.07 = 46.7 %; 50/1.04 = 48.1 %; QR 17.7 and 12.7; QR 21.1; FE 18.2; CF 32.1 (k 75); AC-CS-52 12.16 / 233.4 and 25.42 / 248.0; AC-CS-56 199.7; Earth 100 +7 → 14; +40 → 16.09 and 1.718; tree 6.26 / 18.26 / 5.029; Kinh Mạch Đồ's 8.8 pp. One exception is CS-R05.

Cross-document check: `bonus_curves`, `tree_breakthrough_k`, the `D` op for `alchemy_success`, the `resist_cap_pct` retirement, the grids for the on-event keys, and the Realms `p_brew` form all agree with this GDD. No new contradiction was found except CS-R01, which is internal.

Completeness at `standard`: 5 of 5 required sections plus Formulas and Tuning Knobs. Player Fantasy is absent (advisory, as before). Scope signal: L.

## Findings

### CS-R01 (blocking): the tree's 8 pp clamp is still stated in two places
- Formulas I, first formula line: "for `breakthrough_chance`: `total = min(Σ_tree v_i, cap_tree) + Σ_other v_i`".
- Edge Cases → Stat sheet: "If the tree's `breakthrough_chance` modifiers exceed 8 pp: only the tree's share is clamped".
- UI Requirements, `explain`: "the tree's capped share".

Rule 14, the Variables row `k_tree`, the Formulas I example, AC-CS-31/32 and `kinh-mach-do.md` Formulas F all say the share is `k·ln(1 + Σ/k)`, k = 8 pp, with no clamp. An implementer reading the formula line would build the clamp. The first review said this edge case "is still correct". It was correct then, and the later curve change made it stale.

Fix:
- Formulas I: `total = k_tree · ln(1 + Σ_tree v_i / k_tree) + Σ_other v_i`.
- Edge case: "If the tree's modifiers are large: the share keeps rising on its curve (8 pp → 5.5, 16 pp → 8.8); other sources add on top; the sum still meets Realms' q-extras ceiling".
- `explain`: "the tree's curved share".

### CS-R02 (recommended): the Tuning Knobs `bonus_curves` row was not rewritten
Row "`bonus_curves` (was `bonus_ceilings`)" still has:
- safe range "5–10, 2–3, 0.10–0.15: at most the current values" (the "2–3" was the old `alchemy_success` ceiling);
- "each gate's birth-mix mean S at all ceilings";
- "Penalties apply after the cap".

Mechanical fix 8 of the first review. Fix: range "`herb_growth_pct` k 5–10 and `lifespan_frac` 0.10–0.15, at most the current values until the bot run (AC-CG-60) confirms headroom"; "at the reference stack through the curves"; "after the curve". Also the `field_plots_per_purity` row has a note ("`max_plots` removed") in its Safe range column. Give it a range, for example 0.02–0.06 (guess), and move the note to the last column.

### CS-R03 (recommended): the `alchemy_success` formula line has no floor
Formulas I: `fail' = fail ÷ (1 + total / 100)`, `total = Σ v_i`. Rule 14, the example and AC-CS-54 floor the sum at 0, but the formula line itself would still divide by zero at −100. The fix: `fail' = fail ÷ (1 + max(0, total) / 100)`. Realms Formulas D already has the `max(0, …)`.

### CS-R04 (recommended): fight loss is in Edge Cases only
Edge Cases says the 5 % floor applies after a fight "(rule 9)", but rule 9 and Formulas F do not mention a fight loss.
- Rule 9 Losses/Floor: add "a fight's end vitality, written by Combat".
- Formulas F: add the line `v' = max(v_floor, v_end)` for a fight.
- Formulas F Output Range: "Combat reads vitality as × max(v, v_c)" describes the as-built duel. Reword it to match Combat's "health starts at max(v, `v_c`) of its maximum".

### CS-R05 (recommended): the AC-CS-28 Wood 60 value is below the AC's own tolerance
AC-CS-28 gives 1.48 × 1.0693 = 1.582. At 1e-6 the exact figure is 1.48 × 1.069315 = 1.58259. The Formulas G example (1.48 × 1.069 = 1.582) uses the rounded +6.9. Fix: AC-CS-28 → "1.5826 (±1e-4)" and the Formulas G example → "1.583". The +40 case (1.718) is fine.

### CS-R06 (minor): leftover "ceiling / capped" words
Lines 346 ("under the rule 14 ceiling"), 594 ("under a rule 14 ceiling"), 903 ("the ceilings" in the Modifier System bullet), 14 and 34 ("capped pills" is fine: those are use limits). The registry `lifespan_cap` notes still say "ceilinged bonus" and "under the ceiling"; that entry is Realms'. Fix: "curve" in the first three; "curve scales" in the bullet.

### CS-R07 (minor): the `points` unit has no stated grid
Rule 15 gives 0.1 for `pct` keys, `stealth` and `lifespan_years`. Keys in points (`resist_pct`, `resist_pen_pct`, `damage_more`) are not listed. `modifiers.md` (lines 286 and 903) puts points on 0.1. The registry grid has the same gap. Fix: add "`points` keys" to the 0.1 list, in the registry too.

### CS-R08 (minor): coverage and wording leftovers
- AC-CS-19's provisional note says "until Combat exists", but Combat's GDDs exist. Name the waiting story as the CS-12 fix did for AC-CS-30.
- Only Wood has a purity-150 line (AC-CS-28). Add Metal, Earth and Water (toxicity decay `k_w · purity_water`): the CS-08 fix named all four.
- Formulas G `total(field_plots)` row still says "the result is clamped". Change it to "floored at 1".
- Header `Last Updated` does not mention the 2026-11-10 fixes. The status line needs updating once this re-review is applied.

## Findings that need a user decision

None.

## Mechanical fixes (one sweep)

1. CS-R01: Formulas I `breakthrough_chance` line; the Edge Case for the tree's 8 pp; `explain` "capped share".
2. CS-R02: Tuning Knobs `bonus_curves` row; `field_plots_per_purity` range.
3. CS-R03: `max(0, total)` in the `alchemy_success` formula.
4. CS-R04: rule 9 and Formulas F fight-loss line; Formulas F output range.
5. CS-R05: AC-CS-28 → 1.5826; Formulas G example → 1.583.
6. CS-R06: "ceiling" → "curve" at lines 346, 594 and 903.
7. CS-R07: add `points` keys to rule 15's 0.1 list and to the registry grid.
8. CS-R08: AC-CS-19 note; purity-150 lines for Metal, Earth and Water; the `field_plots` row; the header lines.

## Registry values searched

All registry entries this GDD owns or references were searched across the whole document: `effective_talent`, `resist_factor_clamp`, `stat_precision_grid`, `bonus_curves`, `bonus_ceilings` (deprecated), `bonus_ceiling_target`, `lifespan_cap`, `lifespan_pct_bound`, `tree_breakthrough_k`, `tree_breakthrough_chance_cap` (deprecated), `vitality_floor` and the rest of the first review's list. Every printed line matches. The only conflicts are CS-R01 (the stale clamp, internal) and the Realms-owned wording in CS-R06.

## User answers and applied fixes (2026-11-10, same session)

- No decisions. Applied CS-R01 to CS-R08 (the curve in Formulas I, the edge case, `explain`, AC-CS-48 now 6.26 / 18.26; knob rows; `max(0, total)`; fight loss in rule 9 and Formulas F; AC-CS-28 1.5826; ceiling → curve wording; `points` keys on the 0.1 grid, registry too; purity-150 lines for Metal, Earth, Water; header).
