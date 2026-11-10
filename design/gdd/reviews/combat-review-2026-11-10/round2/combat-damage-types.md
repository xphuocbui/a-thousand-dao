# Design review (confirming round): `design/gdd/combat-damage-types.md`

**Verdict: APPROVED WITH MINOR FIXES.** The earlier findings landed. I checked these against the diff and `combat-defence.md`:
- Rule 5 and the Cross-References row now describe resistance in points with no cap or floor.
- AC-DT-07, AC-DT-08 and AC-DT-30 are rewritten in points. The negative-R case and the no-cap case are added.
- The thể tu fixture is re-based in the Formulas A example, the Acceptance Criteria preamble and AC-DT-19. My arithmetic reproduces 12.64 and 10.32 after resistance, 3.07 and 2.50 of block, 17.39 into the body shield, and 7.82 and 9.57 on the Chaos variant. These match the fixture at `combat-defence.md` lines 1029–1031 and 567.
- Frostbite and Shock are removed. The part-count bound is now (knob + 1) ×. AC-DT-15 includes AC-DT-33. The negative-R edge case is added. The Dependencies status column is refreshed.

I did not run any tests. Only the Status line was changed in the header. I read `combat-defence.md`, `combat.md` and `effects.md` only where they bear on this GDD.

## Still wrong or newly wrong

1. **AC-DT-30 keeps the 5 % `qi_max` per-pulse cap on Qi Disruption, and the other GDDs disagree.**
   - AC-DT-30 says "capped at 5 % of `qi_max` a pulse".
   - `effects.md` line 331 keeps the cap. `effects.md` AC-EF-48 says "nothing is clipped", and `combat.md` line 770 says `dot_pulse_cap` is removed under the no-ticks-capped ruling.
   - Fix: the user decides whether Qi Disruption keeps its own cap. Then make all three documents agree. I did not check whether the ruling reaches the Qi Disruption cap.

2. **`effects.md` AC-EF-26 still tests resistance in fractions.**
   - It reads "Force resistance 0.20 … cut by 0.20", which AC-DT-30 now contradicts.
   - This is outside the file under review, but both tests would encode different units.
   - Fix: restate it in points (divided by 1.20).

3. **Rule 5's formula is ambiguous for negative R.**
   - It says "damage ÷ (1 + R/100); negative R amplifies". Read literally, R −50 gives ÷0.5, which is ×2. Divide by zero comes at R −100.
   - `combat-defence.md` lines 110 and 821 say a negative part is multiplied by (1 + |R|/100), so R −50 gives ×1.5. This is what AC-DT-07 and the new edge case use.
   - Fix: state the two branches in Rule 5 and in the Cross-References row. Say "for R ≥ 0 ÷ (1 + R/100), below 0 × (1 + |R|/100)".

4. **The header is not fully refreshed.**
   - Last Verified still reads 2026-11-08.
   - The Status line is still one run-on paragraph.
   - Fix: update Last Verified. Optionally replace the Status line with a short table or a link to the review log.

5. **The Chaos rarity is still "rare" with no number.**
   - Rule 5 and Open Question 3 leave it untestable.
   - This is minor, and it waits on the Modifier System's `resist_pct` price.

**What did not need changing:** I found no mention in this GDD of the new Ice, Water, fatigue, `time_limit` or heal-refund decisions. The soul-resistance and tick-floor decisions touch only Rule 4's Soul row and AC-DT-30, which are consistent. AC-DT-29's reference to the at-least-1 floor is still correct, since it applies only to what reaches health.