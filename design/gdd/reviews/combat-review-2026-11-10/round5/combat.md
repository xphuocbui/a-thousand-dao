# Fifth confirming review: `combat.md`, 2026-11-10

**Verdict: APPROVED.** Nothing blocks. I edited nothing and ran no simulator or tests; I checked by reading and by searching for the old wording. One real inconsistency remains (item 1). It is a small text fix, but fix it before the tests are written.

## Round-4 findings: all seven landed

- **Rule 8** now says soul resistance has no floor and amplifies below 0. This agrees with Formulas E2, the Formulas F curse table and AC-CB-40.
- **AC-CB-49** now reads "below `t_fat` 66".
- **Rule 10** now says U_r is 6.31 at Qi Refining and that 3.16, 12.6, 28.4 and 50.5 are the first pulses.
- **Formulas E Output Range** now matches combat-defence.md on four points:
  - art costs read the start maximum;
  - regeneration and the pool ceiling follow the live maximum;
  - Water's extra maximum is all usable (AC-CD-74);
  - a heal art refunds when it restores any health, and Ice raises art-slot ward costs only.
- **Status resistance** is now "≥ 0, no cap". The 5–95 % apply-chance clamp is its only stated bound.
- **AC-CB-29** calls the 120 s limit a harness reporting threshold. Rule 10 says the same.
- **The retired items** are consistent everywhere I searched: `time_limit`, the stalemate, `ward_cap`, `resist_cap_pct`, the tick floor and the soul-resistance floor. Fatigue figures are consistent too: 66 s, 67 s, 90 s and 55.8 s for T0.

## Still wrong or newly wrong, most important first

1. **Apply chance of a certain status.**
   - Formulas F (`combat.md:741`) says `p_status = chance` when chance is 0 or 1, so a chance of 1 is never resisted.
   - AC-CD-04 (`combat-defence.md:1063`) says a curse with chance 1.0 against status resistance 0.375 applies at 0.625.
   - The two cannot both pass. Pick one. With uncapped status resistance, I recommend dropping the "0 or 1" exception, so only chance 0 is exempt. That makes resistance always count and leaves the 5–95 % clamp as the only bound.
   - I did not re-read combat-defence rule 15, so check that it matches whichever you choose.
2. **Unit of status resistance.**
   - The Formulas F table row says "≥ 0, no cap" but gives no unit. The formula uses `(1 − resist)`, so it is a share, while every other resistance is in points. AC-CD-04 says it is a share.
   - Add "share of the chance (0.375 = 37.5 %)" to the row so nobody converts it to points by mistake.
   - Above 1 the product goes negative and the clamp gives 5 %. State that in one sentence.
3. **AC-CB-66 fixture.**
   - It uses "120 s". Fatigue ends any legal fight by 90 s, and AC-CB-29 treats a fight at 120 s as a bug.
   - Re-word it as an event-count stress fixture with fatigue off, or cut it to 90 s.
4. **Σ reserved range.**
   - `combat.md:488` still shows "0–0.9". This is a reservation share, not resistance, so it is probably intended.
   - Add "(reservation, not resistance; not covered by the no-cap decision)" so it is not mistaken for a leftover cap.

No other contradictions found. The balance-harness items already in Open Questions are not raised.