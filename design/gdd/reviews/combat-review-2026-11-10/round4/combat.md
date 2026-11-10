# Fourth confirming review: `combat.md`, 2026-11-10

**Verdict: NEEDS REVISION, but only for two small text fixes.** I edited nothing, and I did not run the simulator or any tests. I checked by reading and by hand arithmetic. The first two items below contradict other text in the GDD. The rest are cosmetic.

## Round-3 findings: all five landed

- **AC-CB-13:** it now reads "AC-CD-10 (share stopped; `resist_cap_pct` rejected at load)".
- **Healing against fatigue:** rule 10 states the bound. A heal art is limited by the heal lint and its cooldown, and fatigue grows as n² with no ceiling. It points to AC-CD-45 for the largest-heal-stack check. AC-CB-29 labels the 120 s limit a harness reporting threshold.
- **Tick formula:** Formulas F now uses `raw ÷ (1 + R_eff/100)` in points, with the amplifying branch below 0.
- **Registry:** `curse_soul_shred_max` is marked deprecated. It still lists combat.md in `referenced_by`, which is harmless (cosmetic).
- **combat-damage-types.md:** the negative-resistance case on a converted part is now covered (line 266).

## New decisions: all present except where noted below

I checked the fatigue arithmetic by hand and it agrees with the text:
- 66 s for the typical side, 67 s for the thể tu, 90 s for the largest pool.
- 113.6 a pulse at 65 s and 381.8 at 70 s.
- 64 s for the unbuilt mirror in AC-CB-30.
- 66 s in AC-CB-58.

The other decisions are also in place:
- `time_limit` and the stalemate are retired.
- Ticks have no floor.
- Resistance and the tick formula are in points.
- Ice, Water and the heal refund are stated correctly in combat-defence.md (rule 10, AC-CD-73 and AC-CD-74).

## Still wrong, most important first

1. **Rule 8 (`combat.md:138`) still says "soul resistance never goes below 0 (Combat revision D12)".** This contradicts the no-floor decision. It also contradicts Formulas E2, the Formulas F curse table (line 765) and AC-CB-40, which gives −10 and rho 1.10. Replace it with "soul resistance has no floor; below 0 it amplifies".
2. **AC-CB-49 says T0 is "below `t_fat` 73".** Formulas K and its example give `t_fat` as 66 s (rule 10 agrees). Change 73 to 66.
3. **Rule 10 (line 228) mislabels the fatigue amounts as unit values.** It says "U_r is the side's own realm fight unit: 3.16, 12.6, 28.4, 50.5 … at Qi Refining". Those are the fatigue pulse amounts for n = 1 to 4. U_r at Qi Refining is 6.31, as Formulas A and AC-CB-08 say. Reword it as "6.31 at Qi Refining; the first pulses are 3.16, 12.6, 28.4, 50.5".
4. **Formulas E and the Output Range disagree with combat-defence.md on regeneration.**
   - Combat says art costs and regeneration "stay shares of the full `qi_max`".
   - Combat Defence & Healing (rule 10 and the Water edge case, lines 884–888) says the maximum, and so regeneration, follows Water live. Only art costs keep the start maximum.
   - Combat never says Water's extra maximum is usable. Add one sentence, or a pointer to AC-CD-74.
5. **Heal-art refund and Ice's art-slot-only ward cost live only in combat-defence.md.**
   - Combat has no pointer for either decision, and effects.md rule 9a and AC-EF-65 do not mention the art-slot limit.
   - Add a cross-reference and a note on Ice.
6. **Formulas F lists status resistance as 0–0.9.**
   - That is an implicit cap, and it sits beside the "no cap or floor everywhere" decision.
   - AC-CD-04 deliberately keeps it as a share of the chance.
   - If the decision covers it, drop the bound. Otherwise state that status resistance is the one bounded exception.
7. **AC-CB-66 still uses a 120 s worst-case fixture.** That is fine as a harness scenario, but `sim.py` still stops at `time_limit=120` (line 26). The text calls it a harness threshold, so just keep that wording consistent.

No other contradictions found. The balance-harness items already in Open Questions are not raised here.