# Auto-decisions: Spirit Herbs (unattended review loop)

## Round 1 — 2026-11-21 (full review, NEEDS REVISION)
- Fractional plots: floor the whole sum `floor(base + Thổ×0.04 + total(field_plots))` (smallest; Character Stats G back-link owed, not edited).
- Frozen: derived, not stored; plot index >= plots holding a herb; Frozen -> Locked on harvest/transplant; leaves Frozen when plots rise (no new state).
- Mastery xp: every Planted, non-Frozen herb on its real Δage, Mature included (standing decision: xp from growth years in plots).
- Seed market = market of the home place's region; sale paid from that market's commons pool up to its balance (Regional Economy), not Formula H.
- "Dominant purchase: none" replaced by an accepted-dominance statement (gate + maturity wait offset).
- F4 time-to-level-9 corrected to ~68 yrs (12 plots, best case) / ~490 yrs (3 plots); pacing goes to OQ3.
- F1 fit_growth range 0-1.2 (0.24 is the planting floor); seasons-to-target is "never" at rate 0, rounded up.
- Tick order added to rule 6; AC-07 fixed to 0.03 years/season.
- Not applied (Recommended only): AC wording passes beyond those a blocker needs, Tuning Knobs section, fantasy rewording, F3 max(0,..) beyond the stale-12 note, mastery-xp farming note, transplant-gate, hold-dominance, plot-count-vs-waiting.

## Round 2 — 2026-11-21 (full review, NEEDS REVISION)
- F2 / AC-SH-02 floor example: 0.5 gives floor(8.5) = 8 (kept the input, fixed the result; smallest).
- Rule 4: dropped the inner floor; rule 3 floors the whole sum once (matches F2).
- Rule 11 dormancy: only herbs at index >= plots freeze (matches derived Frozen; no new state).
- origin_market: tag at harvest only if empty, so a bought/found herb keeps its tag (smallest option; no laundering).
- Capability #14: rule 10 now says plant, transplant and harvest, as built (herb_field.gd _can_work gates all three on #14); edge case and AC-SH-05 already agreed.
- AC-SH-01 / AC-SH-17: precondition "without capability #12"; OQ1 stays the user's call.
- Dependencies / Cross-References: "owed" cells set to Yes (back-links added 2026-11-21).
- Faucet line reworded (no mint; pool-to-grower transfer), plus the cheap numeric fixes sitting in the same lines: F1 26 seasons, h range 0, F4 ~470 yrs, F3 "50" is catalogue-bound, Free->Locked row, seed gate = buyer's realm.
- Not applied (Recommended only): Tuning Knobs section, fantasy "tends" wording, rule 6 tick-order AC and other AC wording passes (AC-SH-04/06/07/09/14/16, mastery cap ACs), transplant-of-Frozen note, origin_market sale-pool wording, Interactions sale payout row, AC-SH-04 no-market case.

## Round 3 — 2026-11-21 (full review, NEEDS REVISION)
- No-qi ground: planting always allowed, no floor check, no fit word, screen says "no land qi here" (as built, herb_fit.gd); the x1 > real-fit balance oddity is noted for the user, not changed (smallest).
- Rule 4 / OQ8: OQ8 reworded to "beyond Cave Abode's standard work upkeep" (the rule stays; no new upkeep).
- AC-SH-06: exact 26 seasons (25.4 rounded up), matching F1.
- Death edge case: herbs tagged as at harvest (rule 8, only if untagged).
- Not applied (Recommended only): AC splits/additions (tick order, Locked/Frozen transitions, no-plot refusal, no-qi, mastery across move), AC-SH-02/03/04/01/09/18/19 wording, transplant-of-Frozen note, sale-payout Interactions row, faucet/36-year/Output-Range wording, variable-table rows, float epsilon, xp-farming note, fantasy "tends", forced harvest on move (standing).

## Round 4 — 2026-11-21 (full review, NEEDS REVISION)
- Core Rules intro: "0.04 plots and 0.8 % growth (0.008) per purity" (smallest; matches F1 and its variable table).
- AC-SH-03: GIVEN now states base 3, Thổ 50, field_plots 1 (F2 example), so 9 and 6 derive; AC-SH-16 inherits it.
- Forced harvest on move (game-designer B1) and no-qi x1 (B3): not changed; standing user decision / round 3 decision.
- Not applied (Recommended only): AC-SH-14/18/16/02/13 rewrites and missing ACs (tick order, Locked/Frozen refusal, no free plot, no-qi, death, mastery across a move), F1/F3 max(0,..) guards, variable-table result rows, F3 range wording, F4 "12 plots" illustration, rule 4 lost-grade sentence, States Frozen transitions on Growing/Mature, dominance scope, pool-shopping, pill-value pointer, feel notices (ready, dormancy, move warnings).

## Round 5 — 2026-11-21 (lean review, APPROVED)
- Verdict APPROVED with no blockers; no GDD edit made (approved text is the reviewed text); systems-index row set to Approved.
- Not applied (Recommended only): rule 5 no-qi exception wording, Frozen transplant plant_floor, Character Stats floor back-link (OQ 3), missing ACs, Tuning Knobs.
