# Third confirming review: `combat.md` and its sibling GDDs, 2026-11-10

**Verdict: nearly done. Only minor stale wording is left.** I edited nothing. I did not run the simulator or any tests. I spot-checked the arithmetic by hand rather than re-deriving everything.

## What landed

I checked each of these in the files:
- **Qi Disruption cap:** the 5 % per-pulse cap is gone from effects.md (line 333, AC-EF-26 and AC-EF-48) and AC-DT-30. AC-EF-26 and AC-DT-30 now use points (20 → ÷1.20, 10 + 20 → ÷1.30).
- **Tick floor:** combat.md rule 7, Formulas F and the Output Range, and combat-defence.md line 33 all say ticks deal exactly what reaches health. The Poison example (0.19) is consistent. The remaining "at least 1" lines (combat-defence.md lines 83, 263 and 480, combat.md line 650) are about hits, which is correct.
- **`curse_soul_shred_max`:**
  - It is retired in combat.md Formulas F, the Parameter keys paragraph and AC-CB-56. The AC now lists it as gone and requires `fatigue_units` 0.5 and `fatigue_pow` 2.
  - effects.md line 739 and the registry curse-bounds note (line 2740) say retired.
- **Status resistance:** AC-CD-04 now says it is a share of the chance, not points. AC-CD-05 uses points (R 900).
- **AC-CD-10:** rewritten as the share-stopped examples.
- **Fatigue, `time_limit` and the stalemate:** retired in combat.md rule 10, the registry and thien-kiep.md (`stall_time` 60 s).

## Still wrong, most important first

1. **AC-CB-13 still says "a cap raise is rejected" and points at AC-CD-10.** AC-CD-10 no longer tests that. It only holds the share-stopped examples; the load rejection of `resist_cap_pct` now sits inside it. Drop the phrase or say "AC-CD-10 (share stopped; `resist_cap_pct` rejected at load)".
2. **Healing against fatigue has no stated bound.**
   - Rule 10 says "every fight ends", and rule 11 says fatigue ends a fight neither side can win.
   - Fatigue grows as n² while healing is flat and uncapped, so a bound exists mathematically. Nobody has shown it holds against the largest heal stack, though. The text does not say what happens if a side's flat healing per pulse exceeds the fatigue amount for a long time.
   - Add a harness or lint check, or one sentence stating the bound.
   - The 120 s "bug" threshold (rule 10, AC-CB-29) should be labelled a harness reporting threshold, not a rule. I did not check whether `sim.py` still stops at `time_limit` 120.
3. **The Formulas F tick formula still multiplies by `(1 − r_eff)`.** `r_eff` is defined as the share stopped (`r_j` of Combat Defence & Healing Formulas A, below 0 allowed), so it is correct if that formula is piecewise. Write `D / (1 + R/100)` with R = resistance − penetration in points, as the other docs do. That avoids anyone reading R/(100+R) below 0.
4. **Registry bookkeeping (cosmetic).** The deprecated `curse_soul_shred_max` entry (line 3737) still lists combat.md as `referenced_by`. effects.md line 852 shows the old 30 pp value as history, which is fine. The retired `resist_cap` entries keep share-unit values.
5. **combat-damage-types.md numbers, only partly re-checked.**
   - The AC-DT-19 Physical part (24.78 / 1.961 = 12.64) matches. I did not confirm the Fire, block, body shield and Chaos figures.
   - There is still no edge case or AC for negative R on a converted part. The AC-DT-15 knob-3 note and the "(knob + 1) ×" part-count bound are still unconfirmed.

Balance-harness items already in Open Questions are not raised here.