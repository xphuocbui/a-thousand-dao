I've read the GDD, the triage notes and the current fixture in `combat-defence.md`. I'm checking the stale numbers against those sources, then I'll print the report.

# Design Review: `design/gdd/combat-damage-types.md`

**Verdict: NEEDS REVISION.** The mechanics are sound. The conversion rules are well specified, and I found no logic contradictions in rules 1–10. The defects are stale numbers and a stale cap rule left over from the 2026-11-10 resistance-in-points ruling. This GDD was not swept with the others. Its header still says "Last Updated 2026-11-08".

I read the whole GDD, the triage file, and the relevant `combat-defence.md` sections (rules 3 and 4, Formulas A, the fixture at line 1022). I did not read the other reviews. I did not run any tests. The recomputed numbers below are my own arithmetic from the fixture values in `combat-defence.md`; verify them before adopting them.

## Blocking findings

**1. Rule 5 and Cross-References still describe a resistance cap and floor that no longer exist.**
- Rule 5 says "The cap, floor and penetration rules are those of Combat Defence & Healing rules 3 and 4."
- The Cross-References row for rule 5 says "Resistance cap 0.75 (raisable to 0.90), floor −0.50".
- Resistance is now points with no cap or floor: `damage ÷ (1 + R/100)`, and negative R amplifies (`combat-defence.md` lines 99–111, 411).
- Fix: rewrite rule 5 to say there is no cap or floor, and update the Cross-References row.

**2. AC-DT-07 tests a rule that was retired.**
- It reads "all resistance 0.20 and Fire resistance 0.10 → r is 0.30 … a resistance sum of 0.95 → r is capped at 0.75".
- Under the new rule the sum is 30 points, stopping 23.1 % (damage ÷ 1.30). A 95-point sum stops 48.7 %, and nothing is capped.
- Fix: rewrite it in points. For example, a Fire part with R_all 20 and R_Fire 10 has R 30 and takes ÷1.30. Add a negative-R case (R −50 → ×1.5, no floor) and a case showing no cap at very high R.

**3. The thể tu fixture is the pre-#44, pre-points version, so its Formulas A example and AC-DT-19 are wrong.**
- The GDD uses Physical resistance 0.60, Fire and Chaos 0.30, block 5.57 and body shield 109.0 (Formulas A example; the AC-DT-19 header text; the Acceptance Criteria preamble).
- The current fixture (`combat-defence.md` lines 1022–1024, 563) is:
  - Physical R 96.1 points, stopping 49 %.
  - Fire and Chaos R 60 points, stopping 37.5 %.
  - Block 5.57 points.
  - Body shield 436.1 (σ_b 0.90 × health 484.6).
- My recomputation for the hit of D 41.3, 60 % Physical and 40 % Fire:
  - The parts are 24.78 and 16.52. After resistance they are about 12.64 and 10.33.
  - Block (5.57, split by size) takes about 3.07 and 2.50.
  - The body shield soaks about 17.4, so **0** reaches health. The old "0 reaches health" result still holds only because the shield is now larger.
- The Chaos variant: the Chaos part is about **7.82** after block and reaches health, and about 9.57 of Physical goes into the shield. The old figures were 8.56 and 7.34.
- Fix: replace the fixture sentence in three places (Formulas A example, the Acceptance Criteria preamble, AC-DT-19) and replace the example numbers with the recomputed ones. Do this before the tests are written, or the tests will encode the old values.

**4. The GDD uses "resistance 0.60" and "stopping" shares in fractions where the rest of the game now speaks in points.** AC-DT-08 ("Physical resistance 0.60, Fire resistance 0 and Physical penetration 0.20 → r 0") and AC-DT-07 (finding 2) use the old units. Penetration is now points off R and a type scope matches the final type only. AC-DT-08 still reaches the right conclusion but with the wrong unit. Restate it as: Physical R 96 points, Fire R 0, Physical penetration 20 points, so the part uses R 0 and the penetration does not apply.

## Non-blocking findings

**5. Stale header.** Status and Last Updated stop at 2026-11-08. Add the 2026-11-10 resistance-in-points pass and the Last Verified date. The Status line is also a long run-on that is hard to scan. Consider a table or a link to the review log.

**6. The linh lực regeneration log-curve ruling does not touch this GDD.** I found nothing here that depends on it. The rule 4 Qi Disruption row, "all + Force resistance → linh lực", is consistent with points as long as AC-DT-30's values (0.20, 0.10, "0.30 under the 0.75 cap") are converted. AC-DT-30 has the same cap and unit problem as finding 2: "reduced by 0.20 … 0.30 (under the 0.75 cap)".

**7. The Dependencies status column is out of date.** Combat Defence & Healing, the Modifier System and the Effects System are all marked "Needs revision". Triage says they have gone through the #44 sweep and a confirming round, so refresh those cells. "Lists this system?" still says "Not yet" for Combat. Open Question 2 tracks that.

**8. The Tuning Knobs table has no resistance entry, and Rule 5's "Chaos resistance is rare by its row" is the only place that rule is stated.** Resistance values now live as points in Combat Defence & Healing, so this is a pointer rather than a gap. One small improvement: state the Chaos rarity as a point range once the Modifier System's `resist_pct` price (0.04 W per point) is fixed, so "rare" is testable.

**9. Edge Cases and Acceptance Criteria gaps (minor):**
- No edge case for a negative-R converted part. After a conversion the final type decides R, and a negative R on the new type amplifies it. A one-line case and an AC would cover it.
- AC-DT-15 lists "16, 17, 27, 28, 29, 31 and 32" but omits AC-DT-33, which also sets the knob to 3. At knob 3 the part-count bound is 4×, not 3×, per Tuning Knobs. The criterion should say so explicitly.
- Formulas A's Output Range says "at most 3 × its authored parts" but only holds at the default knob of 2. The Tuning Knobs row says 3 conversions give 4×. State "(knob + 1) ×".

**10. The Open Questions table has two items that are resolved or owned elsewhere.** #1 is already marked resolved. #4 is answered by the Status Catalogue and only waits for effects.md approval. Neither blocks anything.

## What is fine

- The conversion rules (steps, compile order, per-part scaling, modifier-step key sums, the soul exclusion, the no-convert-back rule) are consistent between Core Rules, Formulas A and the Edge Cases. Several ACs (27–29, 32, 33) exercise exactly the awkward corners.
- Standard-mode section requirements are met. All 8 sections are present (Player Fantasy is covered by Overview and Game Feel; Detailed Design is accepted as Detailed Rules), and Formulas is present.
- Dependencies are bidirectional on paper. Combat, Combat Defence & Healing, the Modifier System and the Effects System are all listed, and the reverse "Lists this system?" column is tracked.

## Suggested order of fixes

1. Findings 1, 2 and 4: the resistance cap and unit wording in rule 5, Cross-References, AC-DT-07, AC-DT-08 and AC-DT-30.
2. Finding 3: replace the fixture and recompute AC-DT-19 and the Formulas A example. Check the recomputed numbers against `combat-defence.md` Formulas A2 and G.
3. Findings 5, 7 and 9: the header, Dependencies status and part-count bound.
4. Finding 10 as time allows.

No files were edited, per the headless instruction.