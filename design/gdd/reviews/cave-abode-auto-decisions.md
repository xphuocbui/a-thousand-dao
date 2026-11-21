# Cave Abode & Home Works — Auto Decisions

## Round 1 (2026-11-21, unattended /design-review full)
- Starting grade of a claim: rule 2 now says a self-built abode starts at grade 1, a claimed one at F4's `grade_after`; smallest edit, rule 11 already decided it.
- Claim vs realm gate: `grade_after = min(max(1, old − 1), top_grade[claimant realm])`, fee priced at the claimant's realm; keeps the standing "grades 4/5 need Core Formation / Nascent Soul" decision.
- Residences on leaving: return to their holder, never Left or claimable; keeps the standing "residences keep rent and a fixed grade" decision.
- Death: Left = owner moved away; Ruin = last owner dead, reached directly from Open/Neglected/Left; drops the word "founder".
- Fade clock: consecutive unpaid seasons, resets after each drop and on any payment; Fallen is a one-season event, not a resting state.
- Grade-1 fade (needed a design choice): grade 1 is a floor, the abode stays the owner's home (Neglected), only upkept works fade; chosen as the Recommended option because a living owner must not be made homeless by a 1-stone upkeep.
- Level ceiling after a grade fall: the work counts and is upkept at min(level, ceiling) and keeps its stored level.
- NPC abodes: pay F2 upkeep inside the same aggregate, lose a grade by the same fade clock, no simulated works or dormancy; top grade 3 below Core Formation / 4 at Core / 5 from Nascent Soul; aggregate clamped to pool minus reserve; dead hermit's abode becomes a Ruin record.
- Player spend in Formula H: kept as `burn_abode`; clarified that it nets against the purchase in `player_net`, so M (player excluded) is untouched. Formula H itself not edited (another document).
- ACs fixed: 01, 02, 08, 10, 12, 13, 14, 16, 17, 18, 20 (numbers, fixtures, injected roll, floors).
- Dormancy: only forced by a lost slot, default is the most recently built, earliest-built returns first (needed by the Level-ceiling and 2-slot ambiguity fixes).
- F2 rounds to 6 decimals before `ceil` (float risk; cheap, inside a blocker fix).
- Early cheap raises of grades 2-3: accepted as intended, noted in the boundary checks.
- Capability #15 text in boundary checks updated (c1u +0.30) because the "0.85 / grades 4-5 add only arrays" claim contradicted F3.
- Not applied (Recommended only): grade_min field on work records and grade-4/5-only works (stays in Open Questions 2 and 5); pricing grades 2-3 at a realm floor; extra ACs for Neglected/Fallen/Claimed/Ruin-hidden transitions, AC-04/05 fixtures, AC-10/13 splits, AC-21 extra screens; literal-vs-data-file wording of ACs; stating the per-life absorbable sink maximum (harness question, OQ 3).

## Round 2 (2026-11-21, unattended /design-review full)
- F3 range: level ceiling 3 to 7 (grade + 2), work.max up to 7 for Tụ Linh under Capability #15; registry abode_slot_limit output_range updated; matches rule 3 and the boundary check.
- Rule 14 / AC-16: burn_abode narrowed to grade raises, grade upkeep and claims (exactly Formula H's definition); standing arrays go to burn_formation; layer-1 works, fields and the opening fee keep Travel & Map's line (player-only, no new entry); AC-16 rewritten with Formula H's real identity and amounts. Chosen over editing Formula H (another document).
- NPC abodes: each NPC pays from its own purse, an unpaid NPC advances only its own fade clock, the pool clamp is a check on the sum; F5 roll direction `roll < npc_raise_p`; AC-14 fixture (3,750 / 7,500 / 7,499).
- State tables: initial state Open, move/death rows for Open/Neglected/Fallen, Hidden place as a state with exit to Claimed, "founder's ruin" -> "A Ruin", Neglected counts from the last paid season; work table gains leaving-to-Fading, level raise (keeps counting at the old level), Fading to Dormant with a frozen clock.
- Clock and works on leaving/death/claim: grade clock 0 on Left and on claim; death treated like leaving for works; fading stops only at Hidden place.
- Slots: a work holds slots from the season its building starts; reactivation is earliest built that fits.
- Timing: stones paid when the action starts; new grade applies from the next season; the claimant's home changes at payment, old home Left that season; claim season is Claimed, upkeep due from the next.
- Raise needs a realm that can hold the grade (rule 6), one sentence, since AC-02 and rule 2 already implied it (was Recommended; applied because the timing fix sits in the same sentence).
- UI table: dormant choice only when a slot is lost (one-phrase contradiction fix).
- Fade-clock dodge (pay one season in four): NOT reversed (the round-1 "any paid season resets" stays); logged as a harness watch in Open Question 9. Creative director: not a conservation hole, back-payment would be a new mechanic.
- Back-links (AC-RE-07, Living World Tick, Game UI) listed in Open Question 9, not edited.
- Not applied (Recommended only): fixtures for AC-04/05/19, splitting AC-13, new ACs (2-slot dormancy, partly-faded claim, Fallen to Open, clock reset on Left), AC-15 tag, variable-table rows (grade_cost, claim_fee, grade_after, top_grade, purse), registry round(...,6) and claim_fee referenced_by, F4 "Deity Transformation" naming, dependency notes, fantasy gap at grades 4-5, claim-fee-ignores-grade note beyond the harness watch.

## Round 3 (2026-11-21, unattended /design-review full)
- AC-CA-16: split over seasons (raise season N pays grade-2 upkeep 5; N+1 pays 13; claim in a separate season, claimed abode owes none); matches rules 6 and 11, no rule change.
- NPC reserve (rule 12): the sum is bounded by the purses by construction; the only reserve is the per-NPC raise gate `npc_reserve_mult`; upkeep may draw a purse to 0. Chosen over a pool-minus-reserve cap (would need a new Formula H term). AC-14 gains a two-NPC sum fixture.
- Rule 14: layer-1 works, fields and the opening fee are player purchases inside `player_net` with no Formula H burn line (the cited Travel & Map ledger line does not exist).
- Rule 8: the residence parenthetical limited to the grade upkeep; its upkept works' upkeep and fade clocks still apply.
- Bought residence "returns to its holder" (round 1) NOT reopened despite Travel & Map rule 34 "owns".
- Not applied (Recommended only): Claimed/Building exits and a name for gone works, payment order and Open-season upkeep, line 176 wording, Left-to-Ruin former-owner tracking, NPCs never claim, grade-1 upkeep penalty, AC-18/08/03/06/02/13 fixtures, pool-clamp AC, F1 worst-case note, OQ additions (NPC purse granularity, NPC fade dodge).

## Round 4 (2026-11-21, unattended /design-review full)
- AC-CA-14 / edge line 210: two-NPC fixture is A (purse 7,500, roll 0.049) and B (purse 0); aggregate 3,755 (raise 3,750 + grade-2 upkeep 5, old grade holds); "no money moves" became "no raise cost is booked, upkeep still paid"; matches rules 6 and 12.
- F5: the purse gate reads the purse at the start of the season, before upkeep; keeps the 7,500 / 7,499 fixture.
- States: Claimed exits to Open, Left or Ruin (move or death in the claim season); Ruin "reached from" gains Claimed; matches rule 10.
- Not applied (Recommended only): raise-vs-fade-clock refusal and raise-season move/death forfeit (new mechanic; raise and clock are independent); "only the player claims" (would orphan line 201 and AC-13); rule 14 commons-pool citation and rule 8 "grade upkeep is the perpetual sink" wording; per-NPC purse note vs a banded-purse ADR; Tuning Knobs section (advisory at standard); registry round(...,6); partial payment; Open-season upkeep; Left to Ruin clause; NPC grade seeding; Building to Dormant; AC-04/05/18 fixtures; harness watches (claim fee vs grade, Ruin growth, dormancy parking, breakthrough re-pricing).

## Round 5 (2026-11-21, unattended /design-review lean)
- Verdict APPROVED, no blockers; no GDD edit made (hashes stamp the reviewed text). Index row set to Approved.
- Not applied (Recommended only): Tuning Knobs section, registry round(...,6), AC-04/05/18 fixtures, Open-season upkeep, partial payment, harness watches (already in OQ 9).
