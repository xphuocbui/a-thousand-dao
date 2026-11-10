# Design Review, round 5 (confirming): `design/gdd/combat-defence.md`

**Verdict: APPROVED.** Nothing blocks. Round 4's findings landed except two (the mirror length and the header). The one new problem is a stale line in the catalogue. The resistance, ward and heal fixtures I recomputed all hold.

**Basis**
- I read the whole GDD.
- I checked the new decisions: points with no cap or floor, uncapped soul resistance, no `ward_cap`, flat n² fatigue, no tick floor, Ice on art-slot ward costs only, Water's gain usable, full heal refund.
- I recomputed these by hand:
  - the Common Ward drain bill at we 30.8, with ws 0 and 30.8;
  - the Golden Bell, Surging Tide, Mountain Screen, Golden Light Shield and Black Tortoise Shell price ratios;
  - the AC-CD-09, 13, 14, 16, 19 and 35 values.
- I did not re-run the simulator, and I did not re-raise the balance-harness items already in Open Questions.

## Still wrong or newly wrong, most important first

1. **The healer mirror length still disagrees within Formulas E.**
   - Line 670 says "about 66 s". Line 673 and AC-CD-45 say "about 65 s".
   - Round 4 flagged 70 against 65, and the 70 became 66, so the two figures still differ.
   - Pick the simulator's figure and use it in all three places.

2. **The Formulas H intro contradicts the re-priced shield wards (new).**
   - Lines 775–776 say shield wards are "kept at their old payments, Open Question 18".
   - The table rows below it show them re-priced (Mountain Screen 0.060, Thousand-Layer Cloud 0.044, Golden Light Shield 0.024). Open Question 18 is closed.
   - Reword it to say shield wards were re-priced 2026-11-10.

3. **The thể tu fixture mixes units (line 1048).**
   - It reads "R_all 0.375 (default ward, 60 points)".
   - 0.375 is the stopped share, not points.
   - Write "R_all 60 points (stops 37.5 %)".

4. **The header is out of date (cosmetic).**
   - Line 3 still carries the review history and says "three headless rounds".
   - Line 6 "Last Verified" still points at round 4.
   - Point line 6 at round 5, and keep only the current revision plus the `reviews/` pointer in line 3.

## Confirmed landed from round 4

- **AC-CD-35:** the lint is now 5.1 and the limit 7.14 (1.4 × 5.1). 7.14 passes and 7.15 fails, which matches the formula.
- **`we` range:** the Formulas C table now says "≥ 0 (no ceiling since 2026-11-10)".
- **Soul resistance without a floor:** the Edge Cases carry the line (amplifies through `rho`, counted in pp). It matches combat.md Formulas E2 and Slackened Soul at line 722.
- **Ice:** the edge case now says only a cast is an art's cost. Reserved, per-hit and drain payments are unchanged wherever the ward sits, and AC-CD-74 agrees.
- **Water's gain:** usable linh lực rises with the maximum, clamps at 0 if the maximum falls below the reserved points, and art costs read the start maximum.
- **Earlier decisions, still consistent across the rules, formulas, knobs and ACs:**
  - no cap or floor on resistance, and `ward_resist_max` rejected at load;
  - `ward_cap` retired, with `ward_floor` −90 kept and explained;
  - no tick floor, while hit parts keep a floor of 1;
  - flat fatigue with no `time_limit` or stalemate;
  - full heal refund when any health is restored;
  - ward slots 1/1/2/3/4, with 7 at Deity Transformation in AC-CD-14.