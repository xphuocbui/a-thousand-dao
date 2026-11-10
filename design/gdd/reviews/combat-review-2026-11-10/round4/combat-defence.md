# Design Review, round 4 (confirming): `design/gdd/combat-defence.md`

**Verdict: APPROVED.** Nothing blocks. All six round-3 findings landed. What remains is two internal number disagreements, one stale range and two small gaps in the 2026-11-10 decisions.

**Basis.**
- I read the whole GDD.
- I checked the new decisions (points, no ward cap, flat fatigue, no tick floor, Ice, Water, heal refund) against combat.md's fatigue and soul resistance text.
- I hand-checked the ward price ratios, the resistance, shield, drain, ward-slot and heal-lint fixtures, and the Common Ward, Golden Bell, Surging Tide and Black Tortoise Shell ratios.
- I did not re-run the simulator.

## Still wrong or newly wrong, most important first

1. **The healer mirror length disagrees within Formulas E.**
   - Line 669–670 says the healer mirror "ends by fatigue at about 70 s".
   - Line 673 and AC-CD-45 say about 65 s.
   - Pick one figure, whichever the 2026-11-10 simulator gave.

2. **AC-CD-35's numbers don't follow from the heal lint.**
   - It says a heal art at cost 0.15 and cooldown 3 s passes at c_heal 0.99 and fails at 1.00.
   - With the current terms the lint is 1.0 × (1 + 24 × 0.15) + 0.25 × 2 = 5.1, and ×1.4 gives a limit of 7.14.
   - 0.99 matches neither the 1.4 ratio nor the old 0.3 ratio (1.53); it equals the cost-0.075 lint of 3.3, so it was probably carried over from that example.
   - Re-derive it, or change the fixture to the cost 0.075 case that AC-CD-34 already uses (limit 4.62).

3. **A stale ceiling remains in the Formulas C variable table.**
   - Line 588 gives `we` a range of "0–400".
   - Ward efficiency has no ceiling since 2026-11-10 (Formulas A0 and AC-CD-16 say so).
   - Change it to "≥ 0".

4. **Soul resistance without a floor is not stated here.**
   - Combat Formulas E2 now has no floor, and Slackened Soul can push it below 0.
   - Rule 14, the Edge Cases and the Soul-Guarding Lamp row (line 792) say nothing about negative soul resistance.
   - The Lamp row also writes "+22.5 pp", while the other resistance text uses points.
   - Add one Edge Cases line (negative soul resistance amplifies the soul hit's rho, with no floor) and use one unit.

5. **The Ice edge case names only cast cost.**
   - Line 853–855 and AC-CD-74 say Ice raises an art-slot ward's cast cost.
   - They don't say what happens to an art-slot ward that is reserved, per hit or drain.
   - State that Ice leaves those payments unchanged, or say which ones it raises.

6. **The header is still verbose (cosmetic).**
   - Line 3 still carries the old review history. Line 6 "Last Verified" still points at round 2.
   - Update line 6 to this round and keep only the current revision plus the `reviews/` pointer.

## Confirmed landed from round 3

- **FX-U mirror:** AC-CD-46 now says 64.000 s by flat n² fatigue, matching combat.md line 617.
- **Open Question 11:** it now describes uncapped resistance and no longer mentions upkeep wards. The AC-CD-43 figure and the stale "Remaining gaps" bullet are gone.
- **Resistance as a share:** line 486 and AC-CD-53 now say R 900 points.
- **Water's gain with a falling maximum:** the edge case clamps usable linh lực to 0. Rule 10 says art costs read the start maximum.
- **`ward_cap`:** it is retired in rule 6, A0, the knob rows and AC-CD-16. `ward_floor` −90 stays and is explained as keeping `1 + ws/100` positive.
- **Rounds 1–2 decisions, carried through:**
  - Resistance has no cap or floor, and no per-ward maximum; `ward_resist_max` is rejected at load.
  - Ticks have no floor, while hit parts keep a floor of 1 (line 33, AC-CD-71).
  - Fatigue is flat n². No `time_limit` or stalemate text remains, and the 60 s onset matches combat.md.
  - Ice raises art-slot ward costs only, and Water's gain is all usable (AC-CD-74).
  - Any health restored refunds the full heal cost (rule 16, AC-CD-73).
  - Ward slots are 1/1/2/3/4 (Output Range 6 at Deity Transformation).
  - Shield and Clear Heart Ward prices reproduce the listed ratios.
- **Balance-harness items:** the ward price check per ward, shield ward prices, cleanse price and healer win rate stay in the Open Questions. I did not re-raise them.