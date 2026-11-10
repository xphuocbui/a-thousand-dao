# Design Review: `design/gdd/combat.md`

**Mode:** headless, read-only. The `design-review` skill failed to load (`Execute skill: design-review` returned an error), so I ran the review by hand against the project's GDD standards.

**Coverage:** I read the following in full or in large part:
- Status header, Summary and Overview.
- Core Rules 1–11, which includes the rule 10 timeline.
- Formulas A, A2, E, E2, F and K, plus Parameter keys.
- The decision log `design/research/economy-revision-44-decisions.md`.

I only grepped these sections rather than reading them line by line:
- Core Rules 12–24.
- Formulas B, C, D, G, H, I and J.
- Edge Cases, Dependencies, Tuning Knobs, Game Feel and Open Questions.
- The roughly 170 Acceptance Criteria.

The verdict covers what I read. The unread parts could hide more of the same kind of problem, because the AC lines are very long and several came back as "[Omitted long matching line]".

## Verdict: NEEDS REVISION (minor to moderate)

The structure is sound. All 8 sections are present: Detailed Design, Formulas, Edge Cases, Dependencies, Tuning Knobs and Acceptance Criteria, plus Overview and Player Fantasy folded into the Summary and Overview. The #44 mechanics (fatigue, log-curve regeneration, removed caps and decay) are applied consistently in the places I read. The remaining defects are stale numbers and doc-state problems left over from the revision. They are not design contradictions.

## What I verified as correct

- **Health examples:** 64 × 6.31 × 1.0883 = 439.5, the 0.7-vitality start of 307.6 and the 0.4 floor of 175.8 all hold.
- **Pool output ranges:** 101–128,600 health and 41–52,250 linh lực are right.
- **Linh lực regeneration:** the `regen_k` log curve checks out at +6 / +30 / +100 pp (4.48 / 12.47 / 20.82 pp). The typical 6.05 per pulse and the +6 pp case of 13.78 are right.
- **Fatigue:** 1 + 2 + … + 14 = 105 %, so a full-health side falls at 73 s. The t = 65 example of 26.4 is right.
- **Cooldown rounding:** the 3.333 s example is right.
- **Soul attacks:** the ×8 boss cap of 3.75 % is right.
- **Formulas K:** the worked rotation (48.5 s, 76.9 s, T0 = 55.8 s) is consistent with `t_fat` 73 s.

## Findings

### Major

**1. Typical effective health (ehp) is stale in Formulas A and the Layers calibration.**
- Line 479 gives "Typical Qi Refining **297.8**", and line 595 divides 297.8 by 6.31 = 47.2 U.
- `combat-defence.md` Formulas G (line 718) and AC-CD-42 (line 1080) say ehp is now **1,376.2** after #44. The decision log (P2-4) agrees.
- 297.8 is also below the typical `health_max` of 439.5, which is impossible for an effective-health figure, so it is a leftover pre-#44 number.
- Anything calibrated from the line-595 figure (the Layers section, the realm-gap and display-power scaling) is suspect until it is re-derived.
- Fix: update line 479 and re-derive line 595 and its downstream numbers with 1,376.2 / 6.31 ≈ 218 U.

**2. The Formulas F status example contradicts the equal-value stack fit.**
- The Poison example (line 760) and the `c_tick` range (0.15–0.5 per stack, line 727) use `c_tick` 0.15.
- Decision log, "Equal-value stacks APPLIED": Burn and Poison now use `c_tick` **0.019**, and Poison is now Wood's debuff.
- The example's 1.53 per pulse is wrong at the new value (about 0.19). The lint range also excludes the values the catalogue now uses.
- Fix: re-base the lint range on the stack-seconds charge in effects.md Formulas D, and recompute the example.

**3. Element stacks are barely in combat.md, although the decision log makes them part of #44.**
- Decisions D1–D8 and P3 are applied in effects.md and modifiers.md, so combat.md only needs to define how the fight runs them.
- I found no rules here for how stacks interact with the fight frame:
  - the pulse step (when batch timers fall, when cleansing wards act and `cleanse_share`);
  - the defeat check and ordering within an instant;
  - how stacks enter Layers B (which layer a stack buff or debuff belongs to).
- The Formulas F `stack_cap` of 5 in the variables table is the old status cap. D3 makes element stacks uncapped, so the two uncapped/capped regimes need to be explicitly separated or the table reads as contradictory.
- The grep for element-stack terms returned 22 hits in total, and I did not confirm that they cover those mechanics.
- Fix: add a short "Element stacks in the fight" subsection (or cross-reference to the owning effects.md rule) and make the pulse order include stack batch expiry and cleansing.

### Moderate

**4. The Game Feel section still says a typical fight is about 6 to 8 seconds** (line 1174). The #44 target is 30–60 s, with the typical mirror at 36–45 s. Any log-length or readability criterion built on 6–8 s needs rework.

**5. The status header is out of date.**
- "Last Updated 2026-11-09" and "Last Verified 2026-11-08" predate the 2026-11-10 changes: Stagnation as a dampen, `art_cost_health_pct` paying with health, the regeneration log curve, and the `khi_huyet_pct` price cut.
- The header narrative describes only part 1 of #44.
- Fix: update the dates and add the 2026-11-10 changes.

**6. The Parameter keys list does not name the stat keys added in #44.** Those are `linh_luc_regen_inc_pct`, `health_regen_inc_pct`, `art_cost_health_pct`, the five on-hit / leech keys, and the `stack_effect_pct` / `stack_duration_pct` / `stack_grant` keys. Line 953 lists only `fatigue_start`, `fatigue_step` and `regen_k` as new data keys. Combat's own key list should match Character Stats, since decision log Part 5 says that row is meant to list every key Combat names.

**7. Registry formula text still pre-#44.** The decision log already flags that the registry expressions for Formulas A, C, E and the price check show old text, and it lists a fresh review of this GDD as a follow-up. This review covers part of that. The registry fix is still open.

### Minor

**8. "Upkeep" wording.** Line 257 says prepared items cost "time, goods and upkeep". That is a different upkeep from the removed ward upkeep, but it reads as a leftover. Line 658 mentions `upkeep_share`, and line 960 says `upkeep_share` moves onto ward records, which contradicts C2 (upkeep wards removed). Check that `upkeep_share` is deprecated and not still migrated.

**9. Overshoot of the `health_units` range note.** The range reads "48–104, default 64", which is only ×4 of the old defaults; the old safe range's lower bound of 12–26 ×4 is 48–104, so this is consistent. The sentence "fatigue ends every fight, so the old unbuilt-mirror limit is retired" is clear. No change is needed except to confirm the tuning-knob table (line ~1148) matches, which I did not verify.

**10. Time keys in rule 10.** The list of seconds-authored keys includes `fatigue_start` and `time_limit`. It omits `fatigue_step`, which is a share and correctly not a time. No issue, but the list is long and error-prone.

## Open items outside this GDD that affect it

- `thien-kiep.md` follow-up applied 2026-11-10, but its boss-kill window now reads 0.75 × `time_limit` = 90 s. Confirm combat.md's Formulas and Edge Cases agree after `stall_share` moved to 0.5.
- Combat Defence & Healing, effects.md and modifiers.md each need their own fresh design review, as the decision log (E2) says.
- The Earth buff re-shape (1.1 % Physical damage taken, dampened) and the Wind cooldown floor mean the stack-per-element table that Layers B should reference has changed. Confirm combat.md cites the current table.

## Recommended order of fixes

1. Findings 1 and 2 (stale ehp, `c_tick`), since other numbers depend on them.
2. Finding 3 (element stacks in the fight frame).
3. Findings 4–6, which are quick text fixes.
4. Re-run the review on the unread sections (Rules 12–24, Formulas B–D, G–J, Edge Cases, ACs) once those are in.

I made no file edits.