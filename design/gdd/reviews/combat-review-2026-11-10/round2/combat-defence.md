# Design Review (confirming pass): `design/gdd/combat-defence.md`

**Verdict: NEEDS REVISION (minor).** The earlier blocking findings 1–6 have landed. These were the floor and cap text, AC-CD-09, 14, 24 and 41, the slot ceiling, piecewise share and the points units in the ACs. The new decisions are also carried through in most places. A few contradictions remain, one of them new.

**Basis.** I grepped the whole GDD for retired terms and read the affected rules, formulas, edge cases and ACs. I did not re-run the simulator or recompute the price checks.

## Still wrong or newly wrong, most important first

1. **Usable linh lực has two definitions (new, from the Water ruling).**
   - Rule 10 (line 223) and the Q_use row in Formulas G (line 724) say usable is `qi_max · (1 − Σ reserved)`, which is a share form.
   - Edge Cases (line 872) now says reservations are fixed points, so usable is the live maximum less the reserved points.
   - The two give different answers when Water raises the maximum. With Still Lake reserving 0.6153, +20 linh lực adds about 7.7 under the share form and 20 under the points form.
   - AC-CD-74 asserts +20, but AC-CD-19 and AC-CD-26 still use the share.
   - The Formulas C reserved cost `ρ · … · qi_max` is a share too.
   - Decide what is fixed at compile: the share or the points. Then make rule 10, Formulas C and G and the ACs agree.

2. **The tick floor of 1 is still in the text (line 33).**
   - It says "What reaches health from a tick is at least 1 when anything does (Combat revision D11)."
   - You retired that floor, and AC-CD-71 already says ticks have no floor.
   - Delete the sentence or reword it.
   - Hits are a separate question. Rule 3 (line 83), Formulas B (lines 460 and 478) and rule 11 (line 261) keep "a hit part deals at least 1". If your ruling covered only ticks, state that explicitly. If it covered both, those lines are stale.

3. **Header and status text (lines 3 and 5).**
   - Line 3 is one very long status paragraph that mixes old review logs with the current state. Collapse it to the current revision plus a pointer to the review log.
   - Line 5 chains four "Earlier:" notes. This is carried over from the previous review.

4. **The price check is still isolated per ward (earlier findings 8 and 9 are open).**
   - Prices still use a bare-defender stop share and flat per-point prices.
   - Under uncapped, concave resistance, stacked wards and reserved auras are overvalued, and a flat price over-prices high-R points.
   - There is no marginal-value note. Add a one-line "known approximation, harness item" at minimum.

5. **Smaller leftovers.**
   - **Cleanse ward (finding 13):** there is still no formula, price, knob or AC.
   - **Shield-ward repricing (finding 15):** this stays deferred under OQ 18.
   - **Healer check (finding 16):** AC-CD-45 is still unrun.
   - **Regeneration owner (finding 14):** the linh lực regeneration formula still has no owner, and there is no `regen_k` knob row.
   - **Element-stack composition (finding 10):** rule 1 now says the multiplier is `(1 + inc)/(1 + damp)` on the part and never touches R. That is decided and fine. Thunder is placed in the crit layer. Only the Ice point was open, and it is now decided.

## Confirmed landed

- **Points, no cap or floor:** this holds in rules 3 and 4, Formulas A, G and the anchors.
  - Piecewise `r_j` is defined.
  - The ehp output range is stated.
  - No per-ward maximum remains. `ward_resist_max` is retired and a record carrying it is rejected at load.
  - The old −50 % floor text is gone, and the leftover "caps" lines are the intended retired or unrelated knobs.
- **AC-CD-09, 14, 24, 41 and 66:** rewritten. AC-CD-24 now says the bill strictly falls (26.42 down to 1.96) and the text explains why. AC-CD-14 now gives 7 slots.
- **Ice:** only art-slot wards pay the raise (line 840 and AC-CD-74).
- **Heal refund:** any health restored refunds in full. Cast-time and short-pool edges are stated in AC-CD-73.
- **Fatigue and stalemate:** `time_limit` and the stalemate are gone, and fatigue is flat n² (lines 668, 1109, 1110).
- **Soul resistance:** I found no soul floor.