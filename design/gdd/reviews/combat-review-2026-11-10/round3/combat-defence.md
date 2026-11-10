# Design Review, round 3 (confirming): `design/gdd/combat-defence.md`

**Verdict: APPROVED with minor edits.** Nothing blocks. The earlier findings landed, and what is left is stale text and one number that disagrees with combat.md.

**Basis.** I grepped the GDD for retired terms and read rules 1–4, 10 and 16, Formulas C and E–G, the Edge Cases, Open Questions and AC-CD-05 to 74. I did not re-run the simulator or recompute any price check.

## Still wrong or newly wrong, most important first

1. **The FX-U mirror end time disagrees with combat.md.**
   - AC-CD-46 (line 1112) says the FX-U mirror ends "at 68.000 s by fatigue".
   - combat.md line 614 says 64.000 s, and both cite AC-CB-30.
   - Fix whichever is stale. Hand-work the fixture under flat n² fatigue to settle it.
   - AC-CD-45's "about 65 s" is a different case (a healer mirror) and is consistent with the rest.

2. **Open Question 11 and a trailing note still describe retired mechanics.**
   - OQ 11 (line 1170) still lists "capped resistance", "over-cap from two drain wards" and "an upkeep ward at we 400 falls before 40 s (AC-CD-43)".
   - Resistance has no cap and upkeep wards are gone.
   - The "Remaining gaps" bullet at line 1154 cites AC-CD-43's figure, but AC-CD-43 is retired.
   - Reword the OQ 11 items for uncapped resistance and delete the AC-CD-43 references.

3. **Two examples still state resistance as a share.**
   - Line 483 and AC-CD-53 (line 1128) use "r 0.90" for the Fire part; that is 900 points.
   - The numbers still work (D 30 stopped by 90 % leaves 3), but they mix units with the rest of the points text.
   - Rewrite them as R 900.

4. **The header text is still hard to read.**
   - Line 3 (Status) is one long paragraph of old review logs. Line 5 chains four "Earlier:" notes.
   - Collapse each to the current revision plus a pointer to `reviews/`.
   - Line 3 also still lists "resistance cap 0.90 and ceiling 0.95" under #44, which is retired. Keep it only if it is marked retired.

5. **Edge case: Water's gain with a falling maximum is unstated.**
   - Line 874 says usable linh lực is the live maximum less the reserved points.
   - It does not say what happens if live `qi_max` falls below the reserved points, for example from a curse. Q_use is declared ≥ 0, so say it clamps to 0.
   - Rule 10 also says art costs stay a share of the "full `qi_max`". State whether that means the live or the compile-time maximum when Water changes it.

6. **Ward strength still has a cap and a floor.**
   - `ward_cap` 400 and `ward_floor` −90 (lines 397 and 1016) stay as hard bounds on ws and we.
   - Your ruling was "no cap or floor on resistance". These bound ward strength, a multiplier, and they are not resistance, so they may be intended.
   - If you meant "uncapped everywhere", ws now scales a ward's resistance points without bound, so the cap is the only thing limiting ward-boosted resistance. Confirm this is intended and note it in the knob row.

## Confirmed landed from rounds 1 and 2

- **Usable linh lực (round-2 finding 1):** it is now one definition. Rule 10, the Q_use row in Formulas G, the Edge Cases and AC-CD-74 all use the live maximum less fixed reserved points. AC-CD-19 and AC-CD-26 are start-of-fight values, so the share form is correct there.
- **Tick floor (round-2 finding 2):** line 33 now says ticks have no floor. AC-CD-71 agrees. Hits keep the floor of 1 in rule 3, Formulas B and rule 11, and line 33 says so explicitly.
- **Points, no cap or floor:** this holds in rules 3 and 4, Formulas A and G, and the anchors and ACs. `ward_resist_max` is retired and rejected at load. Soul resistance has no floor.
- **Fatigue and stalemate:** flat n² fatigue is in the rules and ACs. No `time_limit` or stalemate remains here.
- **Ice and Water:** Ice raises art-slot wards only (line 842 and AC-CD-74). Water's gain is all usable.
- **Heal refund:** any health restored refunds all that was paid (rule 16 and AC-CD-73).
- **Ward slots:** 1/1/2/3/4, with the Output Range at 6 for Deity Transformation.
- **Price-check items:** the isolated check, cleanse pricing, shield-ward prices, the healer win rate and the ward's marginal value are in OQ 4, 18, 19, 20 and 21 and AC-CD-45. I did not re-raise them. The regeneration formula is owned by Combat Formulas E and `regen_k` is a Combat knob, so that earlier finding is closed.