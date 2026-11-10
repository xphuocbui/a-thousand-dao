# Design Review: `design/gdd/combat-defence.md`

**Verdict: NEEDS REVISION (minor to moderate).** There is no design rethink. The mechanics are coherent, and the arithmetic I recomputed reproduces. The two rulings (points with no cap, linh lực regeneration on a log curve) are only partly carried through the text and the acceptance criteria. Several statements and ACs still describe the old capped, floored, share-based model, and some of them would fail an implementation that follows the rules.

**Basis.**
- I read the whole GDD (1,167 lines), plus the triage note and the earlier re-review report.
- I recomputed every price-check ratio, the ehp examples (typical 1,376.2; thể tu 2,098.8), the block and shield examples and the drain bill.
- I did not open `modifiers.md`, `effects.md` (beyond the stack table), the registry or the simulator. Claims about them are marked "verify".
- Nothing was edited.

## Blocking: the text and ACs contradict the ruled rules

1. **The −50 % floor is still in the Edge Cases (line 814).**
   - It says "If resistance falls below −50 %: held at the floor, and the part takes at most 1.5 × its damage."
   - Rule 3 and line 817 say negative resistance amplifies with no limit.
   - Rule 4 (line 112) still says penetration is "applied, down to the floor."
   - **AC-CD-09** asserts the old behaviour: a sum of −0.80 gives r −0.50 and 61.95 dealt. In points, R = −80 gives ×1.8, which is 74.3. A compliant build fails this AC.

2. **AC-CD-24 and "Why the bill stays flat" (Formulas C, lines 598–601) are wrong under points.**
   - They claim the Common Ward's drain bill is 6.47 for every ws "up to the cap", then falls once the cap binds.
   - Resistance is now concave in R, but the drain rate falls as 1/(1+ws). The bill therefore falls strictly with ws.
   - At D 41.3 and we 30.8, the bill is 6.47 at ws 30.8, about 4.5 at ws 100 and about 2.0 at ws 400.
   - "Total payment never rises with ws" still holds. "Flat while protection grows" does not, and the "cap binds" branch no longer exists.
   - The AC must be rewritten as "non-increasing". The text should say plainly that strength now makes drain wards cheaper. That is a design consequence worth a line.

3. **The Common Ward breaks its own limit.**
   - Formulas A and F give `ward_resist_max` as 300 points per ward. The Common Ward carries 342.5.
   - The Tuning Knobs row (line 1005) still lists `ward_resist_max` as **0.75** with a range of 0.65–0.80, in share units.
   - **AC-CD-41** tests "no ward exceeds `ward_resist_max` 0.75" against the catalogue. Read in points it fails on the Common Ward. Read as a share (0.75 is 300 points), the Common Ward's 0.774 stop share also fails.
   - Pick one unit. Then either raise the max (about 350–400 points) or cut the Common Ward.
   - Fire-Shunning Veil sits exactly at 300.

4. **The ward-slot ceiling is stale.**
   - `ward_slots_by_realm` Deity Transformation is 4, so 3.5 × `ds_ref` plus one bonus slot gives 4 + 2 + 1 = **7**.
   - **AC-CD-14** says 6 (the old 3).
   - Formulas D "Output Range" says "up to 5 plus bonuses". The correct figure is 6 plus bonuses.

5. **"Share stopped" is wrong for negative R.**
   - Formulas A line 411 says "the share stopped is R/(100+R)".
   - That is correct only for R ≥ 0. At R = −50 it gives −1.0 (damage ×2), but the damage formula in the same line gives ×1.5.
   - Formulas G reuses r as R/(100+R), so ehp for a Sundered or Exposed defender is overstated.
   - Define r piecewise, or state that G holds for R ≥ 0 only.
   - The G output range ("P/1.5 up to 50 × P", resistance "at the floor") is stale for the same reason. The lower bound is now unbounded.

6. **AC fixtures still use shares and the old cap.** The values are numerically fine at the typical point, but they mix units. A tester cannot tell whether "0.75" means 0.75 points or 75 %.
   - AC-CD-03 uses all resistance 0.75.
   - AC-CD-04 says the default ward "would add 0.30"; it is 60 points (37.5 %).
   - AC-CD-12 says "rises by 0.45".
   - AC-CD-16 uses r_w 0.40 and "0.60 resistance".
   - AC-CD-48 lists "cap" in the Breakdown.
   - AC-CD-60 uses r_eff −0.2.
   - AC-CD-66 says a curse "lowers all resistance by 0.10" and r goes 0.8175 to 0.7175. Sundered is −150 points, which gives R 448 to 298 and 81.75 % to 74.9 %.
   - AC-CD-71 uses penetration 0.20 against resistance 0.50.
   - Rewrite them all in points. AC-CD-66's expected values change.

## Major: gaps and under-specified rules

7. **Drain-bill variables mix shares and points.**
   - `prevented_w = D·max(0, r_eff)·r_w / R_pos` uses a share (`r_eff`) times points (`r_w`) over points (`R_pos`).
   - The variable table still gives `r_eff` as "−0.5–0.9" and `r_w` as "calculated (A)".
   - It works only if `r_eff` means the share stopped. Say so, or write the bill as (D − a_j) · R_w / R_pos.
   - "Output Range" (line 592) still says "a floored … r_eff". "Other overnight faults" (line 605) says "the floor and the cap belong to the side".

8. **The price check no longer matches how wards stack.**
   - V_w values each ward alone, with stop share s = R/(100+R) against a bare defender.
   - Under the dampen shape a ward's marginal value falls as other resistance accumulates.
   - **Reserved auras.** The reserved auras are the clearest case. Still Lake (+50.9 points for 0.71 of the pool) and Flame-Quelling (+50.9 for 0.49) add about 1.5 percentage points of stop share (81.75 % to about 83.3 %) on top of a Common Ward. They also cut the pool that pays the Common Ward's drain by about 70 %. Open Question 19 asks only whether they are "still picked"; the check overvalues them.
   - **Per-hit wards.** The same applies to Golden Bell and Surging Tide when stacked.
   - **Slots.** With free slots now 1/1/2/3/4, stacking is the main lever.
   - **Fix.** Price a ward at its marginal value on the typical defender, or state that the check is an isolated upper bound. Move OQ 19 up to a real finding.

9. **Flat per-point prices ignore concavity (Formulas I).**
   - `resist_pct` is 0.04 W per point, derived at the typical 448 points.
   - At 1,900 points (the Deity Transformation top end) a point is worth about 0.05 % of damage, against 0.18 % at 448 and about 0.6 % near the default ward's 60.
   - A flat price over-prices high-R points and under-prices early ones. Penetration (0.1 W per point) is the same, and it is worth more against high R.
   - Either price per realm or note it as a known approximation and a harness item.

10. **Element stacks in the defence path: rule 1 is incomplete.**
    - Rule 1 says damage-taken stacks act "before resistance" (Q2). That settles order but not composition, which is the open point the triage left: does Earth's dampen multiply the part, or add to R?
    - It lists "Metal's and Thunder's debuffs". Per `effects.md` line 218, Thunder's debuff is crit chance and crit-damage exposure, which is an offence-side layer, not a damage-taken change to Physical. Metal's +Physical taken is the one that belongs here.
    - **Ice stacks.** Ice raises art cost, and the GDD does not say whether that reaches cast-ward costs (κ·qi_max). That decision should be stated.

11. **Water's live max linh lực (Edge Cases, line 865) leaves one gap.**
    - It says reservations stay as compiled, but a rise in max linh lực with a fixed reserved share changes the usable pool.
    - Say whether usable = `qi_max_live − reserved_at_compile` or `qi_max_live · (1 − Σ reserved)`.
    - The Formulas C wording ("`qi_max` of the full pool") reads as the second form, so the first needs explicit wording if it is intended.

12. **The heal-refund wording is inconsistent.**
    - Rule 16 and the Q4 ruling say it refunds what was actually paid, only when health is restored.
    - Formulas E says it "refunds its own linh lực cost".
    - **Partial restore.** It is unstated whether a heal that restores 1 hp of 116 refunds in full. On those terms a heal art is free whenever any health is missing.
    - **Cast time.** It is also unstated when the refund lands for an art with a cast time.
    - **Short pool.** It is unstated what happens when drain left the pool short (nothing paid, nothing refunded).

13. **The cleanse ward has no Formulas or ACs.**
    - Rule 6 has a Cleanse payload, and Clear Heart Ward carries it.
    - There is no formula or price for it (the catalogue's † note leaves it unchecked), no Tuning Knob for `cleanse_share`, and no AC.
    - Drain cannot pay status or soul payloads, and no price covers cleanse. It has no check against stack inflow (6–8 stacks a second under uncapped element stacks).
    - Add an AC, a knob (0.25 default, 0.25–0.5 range) and a price.

14. **`regen_k` and the log curve have no home here.** The regeneration formula in Formulas E (`health_max · (hregen_base + hregen_bonus)`) shows no curve, no dampened divisor (Stagnation) and no `health_regen_inc_pct`.
    - The ruling put linh lực regeneration on a log curve. This GDD has no linh lực regeneration formula, but the drain pool depends on it (the simulator's dry-pool times in AC-CD-46).
    - State where the curve is owned (verify `modifiers.md`) and cite it. There is also no knob row for `regen_k`, the refund fraction or `cleanse_share`.

15. **Shield wards are still unfinished, and the decision log defers the fix.**
    - Mountain Screen is 0.600 of 3.05; Thousand-Layer Cloud is 0.667.
    - Mountain Screen's shield (61.0, about 14 % of health) costs 0.30 of the pool that pays the Common Ward's drain. Shields were not scaled with ×4 health.
    - OQ 18 treats this as a repricing job. Expect shield wards to be rarely picked. The direction of the fix is to buff, not to cap.

16. **One heal art out-heals typical offence on paper.** 116.6 per 3 s is about 39/s against about 20/s of typical offence. The only evidence is the simulator's 38 % win rate for a healer, and AC-CD-45 runs it as a harness check. Run it before the numbers are trusted.

## Minor: stale text that still reads as current

- **Calibration paragraph (lines 378–382).** It still quotes the pre-#44 numbers (typical ehp 297.8, mirror 7.7 s, unbuilt mirror 24 s). The #44 note follows, but the old values read as current. Prefix or strike them.
- **Block share row (line 493).** "Typical block takes 7.5 / 8.8 / 10.9 / 12.2 / 13.3 %" is the old r 0.654 figure. At r 0.8175 it is about 12.5 % (0.946 of 7.54). Line 483 ("unbuilt mirror stays at 24.3 s") is stale too.
- **Block 0.5 s kit table (lines 500–510) and AC-CD-58.** They still use r 0.654, and the table is labelled pre-#44. The harness re-derive is pending.
- **Tuning Knobs.** Some rows are still in share units: `default_resist` and `ward_resist_max`. `ward_cap, ward_floor` is fine (it is ws, not resistance).
- **Resistance panel (UI line 946–948).** It still lists "caps", "over-cap amounts".
- **Cross-References (line 983).** "cap raise" is retired.
- **Interactions table.** "resistance cap" is stale.
- **Header (lines 3–6).** The status paragraph is very long and mixes old review logs with the current state. Collapse it to the current revision plus a pointer to the review log.
- **Dependencies.** The "Not yet" and "Needs Revision (design review 2026-11-08)" statuses look stale. `combat.md` mentions this GDD 8 times, so verify the "Lists this system?" column against `combat.md`.
- **Formulas I.** The rows read correctly now (health regeneration 9.9). The "1.25 W/pp … re-priced in part 4" note from the earlier report is gone.
- **Player Fantasy.** There is no section. The Overview and Game Feel cover part of it. Whether it is required depends on `modes.workflow`, which I did not check.
- **Retired stubs.** Rules 17–18 and AC-CD-20, 33 and 43 remain as retired placeholders. OQ 11 still lists the upkeep AC-CD-43.
- **Stale triage line.** The triage's "Not done: the thể tu ehp numbers" is out of date. I recomputed them and Physical 2,098.8 reproduces.

## What holds up

- **Price checks.** Common Ward 3.049, Fire-Shunning Veil 4.545, Qi-Scattering Robe 3.788, Flame-Quelling 4.364, Still Lake 3.012, Golden Bell 3.019, Surging Tide 2.935 and Iron Shirt all reproduce.
- **Anchors.** The resistance anchors table reproduces: 448 / 472 / 507 / 557 / 631 points and the stop shares.
- **Worked examples.** The drain bill, the typical ehp, the thể tu ehp, the block split, the shield recharge and the heal (116.6) reproduce. So do AC-CD-06, 19, 21, 22, 25, 28, 30, 32, 53 and 68.
- **Body-gear prices.** The earlier mismatch is fixed (Iron Body about 9.4 W a tier, Black Iron Armour about 35 W, parity dropped).
- **Earlier findings now closed.** Default ward (60 points), healing decay (retired), the 95 % cap wording, fatigue in the path table, leech as healing, the duplicate-ward rule and the cleanse payload row are all fixed.

## Recommended order

1. **Findings 1–6.** Mechanical sweeps of the floor and cap text, the `ward_resist_max` unit and value, the slot ceiling, the piecewise share for negative R, and the AC units. Rewrite AC-CD-09, 24, 41 and 66, and fix AC-CD-14.
2. **Finding 7 and the variable tables.** Settle drain-bill units.
3. **Findings 10–14.** Short rule additions that each need a decision: composition and placement of stack effects, Ice and cast wards, Water's usable pool, the refund edges, and cleanse pricing.
4. **Findings 8, 9, 15, 16.** Hand to the simulator and the harness (the price check against stacking, flat point prices, shield wards, the healer).
5. Rerun `/design-review` afterwards.