# Design Review: `design/gdd/combat-defence.md`

**Verdict: NEEDS REVISION.** The mechanics are coherent and the arithmetic I recomputed mostly checks out. The #44 edits, though, left stale statements and contradicting acceptance criteria behind, and a few real gaps remain.

**Review basis.** The `design-review` skill errored on load, so I reviewed manually. I read all 1,150 lines of the GDD and `design/research/economy-revision-44-decisions.md`. I did not open `combat.md`, `effects.md`, `modifiers.md`, the registry or `project.yaml`. Anything about those files is marked "verify". Nothing was edited.

## What holds up
- **Ward price checks.** I recomputed the ratios for the Common Ward, Fire-Shunning Veil, Qi-Scattering Robe, both reserved auras, Golden Bell, Surging Tide, both shield wards, both cast wards and Iron Shirt. All match the catalogue (e.g. Golden Bell 821.2 / 272.1 = 3.019).
- **Worked examples.** The drain bill (6.47), ehp (1,376.2), heal (116.6, 26.5 % of health), block split (25.0) and shield recharge (19.9 a second) all reproduce.
- **Structure.** It has Overview, Formulas, Edge Cases, Dependencies, Tuning Knobs and Acceptance Criteria. Formulas carry variables, ranges and examples, and the ACs are mostly Given/When/Then and testable.

## Blocking: contradictions after #44

1. **The default ward is stated two ways.** Rule 11 (line 235) says 0.30 resistance at drain 2.0. Formulas A (line 438) and the Tuning Knobs say 0.375 at 0.40.
2. **Healing decay survives in the ACs and Game Feel.**
   - AC-CD-33 asserts d(7.5) = 0.55 and d(15) = 0.10. AC-CD-37 says "heal equals base × d(t)".
   - Both contradict rules 17–18 and AC-CD-34/36 (no decay).
   - Game Feel (line 917) says "Late heals visibly fade". It should be rewritten for fatigue-driven pressure.
3. **Resistance cap edge case is stale.** Line 804 says "If cap raises would pass 90 %: the cap is 90 %". It should be 95 % (`resist_cap_max`). The Formulas G range for `r_all` (−0.5 to 0.9) is stale for the same reason.
4. **Fixtures are pre-#44.**
   - The "Common Ward: all r 0.50, drain 1.64" fixture should be 0.625 / 0.328.
   - AC-CD-21 uses Golden Bell φ 0.14, against 0.035 in the catalogue and AC-CD-40.
   - AC-CD-32 is the default-ward AC. It uses 0.30, 28.91, 28.6 and a bill of 24.8, all pre-#44.
   - AC-CD-06 uses a 33.0 body shield, which is the old 109.9 health × 0.30. With health 439.48 it is 131.8.
   - AC-CD-04 says the default ward adds 0.30.
   - AC-CD-19/25 use Still Lake at ρ 0.50, but the catalogue now has 0.71.
5. **Body-gear prices were not carried through R3.**
   - The body shield is now 0.51 W/pp, but Formulas H still gives Iron Body as "about 20.7 W per tier" and Black Iron Armour as "about 65 W".
   - Recomputing per tier: 4.0 for block, 5.1 for σ_b (10 pp × 0.51) and 6.7 for Physical resistance gives about 15.8.
   - Black Iron Armour at a_b 1.0 comes to about 35 W (block 4.8 + shield 30.6), against the 65 W claimed.
   - AC-CD-57 requires parity at 0.648 W per defence point. That parity no longer holds.
   - The Căn cốt "4.6 W" line is stale for the same reason.

## Major: real gaps

6. **Fatigue is missing from the defence path.** The Rule 1 threat table has no fatigue row. AC-CD-59 says "fatigue passes shields, so this holds by rule", but no rule in this GDD says so. The decision list says fatigue damage is unblockable and passes wards, shields and resistance, so it should be written here. The Down step and the "at least 1" rule should be stated for it too.
7. **Element stacks are absent from the defence path.**
   - Earth's buff and Metal's debuff change Physical damage taken. The GDD never says where "damage taken" modifiers sit: before or after resistance, block and shields.
   - Wood and Fire debuff ticks are now uncapped. Whether a per-hit ward pays one fee per tick or per stack is not stated.
   - Ice raises art cost. It does not say whether cast-ward costs or per-hit fees are affected.
8. **Water's +% maximum linh lực conflicts with "compiled once at start".** Reservation shares, shield sizes (σ·qi_max) and the usable pool are all derived from `qi_max`. The Compile edge case says base sums are fixed at compile. A live max-linh-lực buff either breaks that or needs a stated rule (does the reservation re-resolve, do shields grow?).
9. **Cleansing is underspecified.**
   - P3-1 (`cleanse_share` 0.25, stacks removed oldest first) is not in rule 6's Status payload, which still mentions only "cleanse tags".
   - Clear Heart Ward still cleanses `[poison]`, though Poison became Wood stacks (D1).
   - Drain cannot pay status payloads, so the price check's 0.008 · I · T coarse value (Open Question 8) is the only price. A cleanse that must keep up with 6–8 stacks a second is not covered.
10. **Healing sources are incomplete.**
    - Rule 16 lists regeneration, heal arts and Effects. It omits the new plain-modifier leech (`leech_health_pct`, B3). It does not say whether leech passes `healing_pct`, `healing_taken` and `no_heal`.
    - Formulas E's regeneration lacks `health_regen_inc_pct` (B5) and the Stagnation dampen divisor.
11. **The heal-refund rule has open edges.** It is unclear whether the refund is the nominal cost or the cost actually paid. That matters under cost reduction and `art_cost_health_pct`. It is also unclear whether a heal under `no_heal` refunds, and how a refund interacts with the "overflow" quantity (B7) at a full pool. The full-health case refunds (line 851). That makes a heal art a free-cost art whenever it lands on a healthy side.
12. **Shield wards look underpowered, not just unpriced.** Open Question 18 frames the wide margins (Mountain Screen 0.600 of 3.05) as a re-pricing job. The check is an upper bound, so a ratio of 0.2 means the shield delivers about a fifth of its budget. Shield sizes also did not scale with the ×4 health. Expect shield wards to be picked rarely until this is fixed. The direction of the fix is to buff, not to cap.
13. **The resistance cap sits at odds with the user's "no caps, dampen instead" strategy (2026-11-10).** At Core Formation and above, one Common Ward reaches the 0.90 cap. After that, ward strength adds nothing to resistance and penetration becomes mandatory. The strategy names other cap candidates but not resistance, evade or `reserve_cap`. This needs an explicit decision, either to keep it as an exception or to put it on the dampen list.
14. **One heal art out-heals typical offence on paper.** Healing is 116.6 per 3 s, or about 39 a second. Typical offence against a warded defender is about 20 a second (decision doc). The 38 % win rate from the simulator is the only evidence, and AC-CD-45 only runs it as a harness check. Healing also has no cap, no decay and a cost refund. The harness should confirm it before the numbers are trusted.

## Minor
- **Section coverage.** There is no Player Fantasy section; the Overview covers part of it. I did not check `modes.workflow`, so I can't say whether it is required.
- **Header.** `Last Verified` is 2026-11-08. The header should list the 2026-11-10 changes (R2/R3 pricing, Stagnation dampen, equal-value stacks). The status paragraph is very long.
- **Stale pre-#44 text still reading as current:**
  - the calibration paragraph (typical mirror 7.7 s, unbuilt 24 s);
  - the "typical block 7.5 / 8.8… %" row, which is now about 12.5 % at r 0.8175;
  - the 0.5 s kit table and AC-CD-58, which use r 0.654;
  - the "FX-U 24.3 s" claim;
  - the Interactions table's "cap lines".
- **Formulas I prices.** Health regeneration shows 3.0 W/pp "to re-price", but the decision doc says 9.9 was applied. The all-resistance 1.25 W/pp note says "re-priced in part 4" but it was kept. Align the text with what was applied (verify against `modifiers.md`).
- **Per-hit price check.** Formulas F hard-codes `45 · φQ` instead of `T_ref · φQ`.
- **Ward resistance maximum.** Formulas A's `r_w,x` range reads "0–0.75 (×1.25 with #44)". It is unclear whether `ward_resist_max` is 0.75 or 0.9375. The catalogue and AC-CD-41 treat it as 0.75.
- **Retired stubs.** Rules 17–18 and AC-CD-20/43 are kept as "retired" placeholders. Open Question 11 still lists the upkeep AC-CD-43.
- **Dependencies table.** The statuses ("Needs Revision (design review 2026-11-08)", "Not yet" for Combat #43) are likely stale. Verify against `combat.md`.
- **Tuning Knobs.** There are no entries for `cleanse_share`, the heal refund fraction or `regen_k`. Some safe ranges, such as `default_resist` 0.30–0.45, straddle old and new values.
- **Bidirectional dependencies.** I did not verify that the other GDDs list this one.

## Recommended order of fixes
1. Items 1–4: mechanical text and AC corrections.
2. Item 5: re-derive the Formulas H body-piece W values.
3. Items 6–11: short rule additions, each needing a user decision on placement.
4. Items 12–14: hand to the simulator and the harness (Open Questions 18 and 19, AC-CD-45).

Then run `/design-review` again after the edits, as the decision list (E2) already plans.