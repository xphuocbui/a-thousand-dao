# Design review: `design/gdd/combat.md`

**Verdict: NEEDS REVISION (minor).** The design is sound and I found no rethink needed. The #44 economy changes and the 2026-11-10 rulings are applied correctly in the rules and the main formulas. What's left is stale fixtures and acceptance criteria that a QA tester or programmer would implement wrong, plus mixed resistance units. I read the whole file and spot-checked the arithmetic by hand. I did not run the simulator, and I read `combat-defence.md` and `effects.md` only where combat.md points into them. Nothing was edited.

I checked the new regeneration log curve and the fatigue schedule by hand and both are correct:
- **Regeneration:** +6, +30 and +100 pp of bonus give 7.98 %, 15.97 % and 24.32 % per pulse, matching AC-CB-34.
- **Fatigue:** a full-health side falls at 73 s, and the 50 %-health case at 69 s, matching AC-CB-58.
- **Stagnation:** the regeneration dampening in AC-CB-35 is correct.

## Blocking: wrong numbers a test would pin

**1. AC-CB-46: boss health is pre-×4.** It says 8,076.3. That is `health_units` 16 × 6.31 × 8 × 10. At the current 64 it is **32,305** (±0.5). The same AC's creature figure, 111.05, and AC-CB-09's 128,608.3 are already on 64, so the file contradicts itself. Linh lực 13,123.9 is correct.

**2. AC-CB-78: starting-share health is pre-×4.** A health share of 0.25 on FX-T gives 0.25 × 439.48 = **109.87**. The AC says 27.47, which is 0.25 × the old 109.87 pool. The linh lực figures (86.37 and 48.95) are correct.

**3. AC-CB-40: costs and bills are pre-#44.**
- "A cost raise of +50 % makes FX-T's art cost 38.87" is the old 0.15-share cost. With halved costs, 12.96 × 1.5 = **19.44**.
- "Leaking Ward … bills 38.84 (+50 %), not 46.60" uses the old drain of 1.64. With drain 0.328 the Common Ward bill is 6.47, so +50 % gives **9.71** (and the +80 % cap case is clamped to that).
- The pointer for Sundered and Exposed ("at most 0.50, never below −0.50", AC-EF-24) describes the retired share model. See finding 11.

**4. AC-CB-45: contradicts Formulas J.** The AC says the share-40 companion hit "deals 1.91". Formulas J, same fixture, gives 8.26 × 0.1825 − 0.946 = 0.56, so the floor yields **1.00**. One of the two is wrong. By the arithmetic it is the AC.

**5. AC-CB-74: thể tu numbers are stale.** The AC says a D 41.30 Physical hit at 0 linh lực "loses 12.39 to resistance … body shield falls by 23.34". 12.39 is 30 % of 41.30, the old `default_resist`. At 0 linh lực no default ward is up, so the fixture's R is only 36.1 points, which stops 26.5 %. That gives:
- resistance loss: **10.95**
- block: 5.57
- body shield loss: **24.78**

The Chaos line (35.73) is right. Please confirm against `combat-defence.md` Formulas G before fixing.

**6. AC-CB-80 and Formulas F: the tick formula is still on the stop-share model.**
- Formulas F says `tick = … · (1 − r_eff)`, with `r_eff` = resistance minus penetration.
- Under the points rule it should be `/(1 + (R − pen)/100)`, with penetration in points.
- AC-CB-80 uses "Chaos penetration 0.10", "r_eff is 0.7175" and 2.37 per tick. 0.10 points of penetration does essentially nothing now, so the test and its numbers are meaningless.
- The AC's Poison is c_tick 0.15, but Poison is now the Wood stack at 0.019 per stack. Re-base it on a Chaos DoT that really has c_tick 0.15, or on the 0.019 values.

## Should fix: unit and wording drift

**7. Resistance is stated in two units.** Formulas C's formula line only says "resistance `a_j`". The examples run in stop shares ("r 0.8175", "× 0.1825"), and the fixtures say "all resistance 0.50" (line 1247) and "all resistance 0.375" (FX-U). The Common Ward is **342.5 points** (448 at ws 30.8), and the default ward is 60 points. The shares are equivalent at the typical anchor, but an implementer reading Formulas C cannot tell which to code.
- Put `D / (1 + R/100)` in Formulas C.
- State R in points in the fixtures, with the share beside it for reference.

**8. Retired caps still referenced.**
- Rule 16 says the log shows "resistance with its cap".
- AC-CB-13 points at AC-CD-09 and AC-CD-10 for "Resistance floor and caps". AC-CD-10 is retired, and AC-CD-09 still tests a −0.50 floor, which contradicts `combat-defence.md` line 817 (no limit, negative R amplifies).
- Tuning Knobs line 1131 lists "resistance caps".

**9. The 0.60 thresholds have no unit.** Rule 18 and AC-CB-84 require "at least 0.60 against it with its wards up". In points that is **150** (a 60 % stop). Written as 0.60 it reads as 0.6 points.

**10. AC-CB-60 says Iron Body tier 3 gives "Physical resistance 0.20".** `combat-defence.md` and the thể tu fixture use **25 points**.

**11. Sibling GDDs still carry old-unit ACs that combat.md points into.**
- `effects.md` AC-EF-24 still tests Sundered at −0.45 and Exposed at −0.10, with a `resist_floor` of −0.50. The rulings are −150 and −100 points with no floor.
- `combat-defence.md` AC-CD-09 has the same problem.
- Both are outside this file, but AC-CB-13 and AC-CB-40 depend on them.

## Design and consistency observations

**12. The typical mirror length has five different answers.** The same FX-T pair gets:
- 34 s (AC-CB-30, by hand)
- about 36 s (the #44 note, simulator)
- about 42 s (AC-CB-54)
- 55.8 s (Formulas K's averaged rotation)
- 7.6 s (the Formulas B table, "old sim")

The causes differ: art uptime of 30 % in K against an art that fires whenever affordable in AC-CB-30, and old versus new simulator runs. But AC-CB-52's rating agreement test will compare T0 55.8 against a full fight that ends near 34 s on the same pair.
- Pick one canonical figure for FX-T and say how the others relate.
- Mark the old-sim column as superseded, not just "re-derive".

**13. The `time_limit`, stalemate and fatigue relationship needs a decision.**
- With `time_limit` at 120 s and fatigue from 60 s, the stalemate ending is nearly unreachable. A full-health side falls at 73 s, and AC-CB-29 can only test stalemate by disabling fatigue.
- Healing is uncapped and does not decay, and fatigue grows linearly, so a build whose heals beat the fatigue step could stall the fight.
- Either state a bound (a healing-versus-fatigue check in the lint or harness) or accept that stalemate is effectively retired. Right now the text implies both.

**14. Some floors and caps survive "no caps".**
- `curse_soul_shred_max`, with soul resistance floored at 0, is still present.
- So are `layer_caps`, `evade_cap`, `pierce_cap`, `soul_cap` and `crit_*_cap`.
- That may be intentional, since the ruling was about resistance and regeneration. But soul resistance is now the one defence with a floor while ordinary resistance has none. Confirm it is deliberate.

**15. Smaller items.**
- Open Question 25 still says #44 part 2 "re-derives" the FX-U mirror and K's T0 under the new wards. The tracking notes say part 2 is done.
- The header's "Last Verified … confirming re-review" overstates things, given findings 1 to 5.
- Q2 (stack damage-taken effects apply before resistance) is in `combat-defence.md` rule 1 but not in combat.md rule 4's path summary. A one-clause pointer would help.
- The tick "at least 1 reaches health" floor is a bigger factor now. Poison at 0.19 per pulse always floors to 1, which makes it a flat 1 per pulse regardless of resistance. Worth a note in Formulas F that this is intended.

## Section completeness

All 8 required sections are present: Overview, Player Fantasy (carried in the Overview and Game Feel), Detailed Rules, Formulas, Edge Cases, Dependencies, Tuning Knobs and Acceptance Criteria. Dependencies are bidirectional with the four sub-GDDs.

Tuning Knobs deliberately has no safe ranges (user decision 2026-11-06), so I did not flag that.

## Suggested fix order

1. Findings 1 to 5: five arithmetic fixes, mechanical.
2. Finding 6: rewrite the F formula and AC-CB-80 in points.
3. Findings 7 to 10: unit wording sweep.
4. Finding 11: fix AC-EF-24 and AC-CD-09 in their own GDDs.
5. Findings 12 to 14: decisions for the user.