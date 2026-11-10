# Confirming review: `combat.md` and its sibling GDDs, 2026-11-10

**Verdict: NEEDS REVISION (minor).** Almost every earlier finding landed, and the new user decisions are carried through the rules and formulas. What remains is stale wording in a few places. I edited nothing. I did not run the simulator or any tests, and I did not re-derive the numbers in combat-damage-types.md (see item 6).

## What landed

I checked each of these against the working files:

- **Arithmetic fixes:**
  - The old combat.md findings 1–5 are fixed: AC-CB-46 (32,305), AC-CB-78 (109.87), AC-CB-40 (19.44 and 9.71), AC-CB-45 (1.00) and AC-CB-74 (10.95 / 24.78).
  - AC-CB-80 is rebuilt in points: 1.53, then 1.87 with 100 points of penetration (R 348, 77.68 % stopped).
- **Points and caps:**
  - Formulas C is in points, with the piecewise form for negative R.
  - AC-CD-09, 14, 24, 41 and 66 are rewritten.
  - `ward_resist_max` is retired (no per-ward maximum), and AC-CD-14 now gives 7 ward slots.
  - AC-DT-07 and AC-DT-08 are rewritten in points.
  - The 0.60 threshold is now 150 points.
- **Fatigue and the time limit:**
  - Flat n² fatigue checks out by hand: 3.16, 12.62, 28.39 …; FX-T falls at 66 s, the thể tu at 67 s, FX-U at 64 s and the largest pool at 90 s.
  - `time_limit` and the stalemate are retired in the rules, the registry and thien-kiep.md.
- **Other rulings:**
  - Soul resistance has no floor (AC-CB-40: 20 − 30 = −10, rho 1.10).
  - Ice reaches art-slot ward costs only (AC-CD-74), and Water's extra maximum is all usable.
  - The heal refund is in full when any health is restored (AC-CD-73).
  - The cleanse ward now has a knob and an AC (AC-CD-72).
- **Mirror length:** the Formulas B mirror column is marked superseded, and the 36.7 s simulator figure is named canonical.
- **effects.md AC-EF-24:** now in points (−102, ×2.02).

## Still wrong, most important first

1. **Qi Disruption still has a per-pulse cap in three places.**
   - effects.md line 331 and AC-EF-26 say it burns at most 5 % of `qi_max` a pulse. AC-DT-30 in combat-damage-types.md says the same.
   - combat.md Formulas F, effects.md line 145 and AC-EF-48 say there is no cap and nothing is clipped, per the 2026-11-09 decision.
   - AC-EF-26 also still reads "Force resistance 0.20" in share units.
2. **Defence still floors ticks at 1.**
   - combat-defence.md line 33 says a tick that reaches health deals at least 1. AC-CD-71 in the same file says 0.4.
   - combat.md lines 129–130 say the at-least-1 floor applies to what reaches health from a status, with no tick exemption.
   - Following those lines, Poison's 0.19 per pulse becomes 1. Hits keep their floor of 1; only ticks are exempt.
3. **`curse_soul_shred_max` is still treated as live.** It is retired everywhere else.
   - AC-CB-56 requires the key at value 30, so a conforming data file fails it.
   - combat.md line 968 (the Parameter keys paragraph) and Tuning Knobs line 1144 still list it.
   - The registry's curse-bounds note (line 2718) still names `curse_shred_max` and `curse_soul_shred_max`.
   - The deprecated `curse_soul_shred_max` entry (line 3715) still lists combat.md as `referenced_by`.
4. **AC-CB-13 points at retired AC-CD-10.** It says "a cap raise is rejected". AC-CD-10 now only holds the share-stopped examples (R 100, 448 and 900 giving 50 %, 81.75 % and 90 %).
5. **The tick formula in Formulas F still multiplies by `(1 − r_eff)`.**
   - It defines `r_eff` as the share stopped with penetration subtracted. The generic share R/(100+R) is wrong below 0, which is where Sundered (−150) and Exposed (−100) now put targets.
   - Write it as `D / (1 + R/100)` with R = resistance − penetration in points, and cite the piecewise form.
6. **combat-damage-types.md: I did not re-verify the thể tu example numbers.**
   - These are in AC-DT-19 and the Formulas A example. The earlier review gave new values (body shield 436.1, Physical R 96.1 points); check they were applied.
   - There is still no edge case or AC for negative R on a converted part.
   - The AC-DT-15 knob-3 note and the "(knob + 1) ×" part-count bound were not confirmed.
7. **The 120 s "bug" threshold is a time limit in practice.** `sim.py` line 26 still stops fights at `time_limit` 120.
   - AC-CB-29 says a fight still running at 120 s is a bug. Say it is a harness reporting threshold, not a rule.
   - Healing against fatigue has no stated bound. A heal-heavy side can outlast the pool-based fall times (66 s typical, 90 s for the largest pool). AC-CD-45 only checks a healer mirror.
8. **Some ACs still mix shares and points.** AC-CD-04 uses status resistance 0.375 and 0.9, and AC-CD-05 uses "r 0.90". Status resistance is a separate fraction, so this may be intended. If so, say it once.
9. **Registry:** the retired `resist_cap` and `resist_cap_max` entries keep their share-unit values. They are marked deprecated, so this is cosmetic.