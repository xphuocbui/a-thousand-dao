# Combat — Review Log

## Review — 2026-11-06 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 6
Summary: The design is internally rigorous; every worked example and bound recomputed correctly and almost all 75 acceptance criteria are testable. The blockers are spec gaps and consistency slips: the order hits land within a round is undefined, one key has two names, and some numbers are stale.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Rule 10 step 3 / Formulas C: "apply together" contradicts "one at a time against live linh lực"; hit order within a round is undefined, which breaks ward drain determinism (AC-CB-01, AC-CB-25).
- [BLOCKING] Tuning Knobs, AC-CB-74, registry `body_guard`: `guard_share_qi` conflicts with `guard_share_kind` in Formulas and AC-CB-19 (AC-CB-56 cannot be checked).
- [BLOCKING] Open Question 6 says 18 % for top-end two realms up; Formulas H says 54 / 54 / 60 %. Formulas A gives `health_rounds` 12–22 while AC-CB-58 passes 26.
- [RECOMMENDED] Dependencies: Item Database (#13) is missing.
- [RECOMMENDED] AC-CB-54: "about ×10 per realm" has no pass/fail band.
- [RECOMMENDED] AC-CB-53: the g = 2 band (40–75 %) is narrower than the stated sensitivity (17–76 %).
- [RECOMMENDED] Open Question 9: `slot_count` per realm has no value.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard).
- [RECOMMENDED] Soul attacks (Open Question 16): add an interim limit on chaining before content is authored.
Reviewer note after the review: the user proposed replacing the round loop and priority list with per-art cooldown timers that fire when they reach 0 (Backpack Battles style). Blocker 1 is held until that is settled.
Reviewed-Content-Hash: design/gdd/combat.md 90eecf726ff9489b65c0b5f7e75c1a2930dfe23b
Reviewed-Content-Hash: design/registry/entities.yaml fe930d66a6d40b91770ecfe332b8c11bc489cc8a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43

## Review — 2026-11-06 (second pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 8
Summary: All 3 blockers of the first review are resolved (hit order in rule 10 step 3 and AC-CB-76, `guard_share_kind` everywhere, stale numbers). Worked examples recomputed correctly and the registry shows no conflicts. Two spec slips remained and were fixed in the same session; the GDD was not re-reviewed after the fixes.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] AC-CB-24: "simultaneous apply" contradicted rule 10 step 3 (hits apply one at a time). Fixed.
- [BLOCKING] Rule 10: no step resolved the escape art. Fixed: escape resolves at the end of step 3 (rule 10).
- [RECOMMENDED] Dependencies / Cross-References lacked Item Database (#13). Fixed.
- [RECOMMENDED] Rule 22: "up if its cost can be paid" was ambiguous for drain wards, and the default ward's per-kind mapping was unstated. Fixed.
- [RECOMMENDED] AC-CB-54: "about ×10 per realm" had no band. Fixed: ×7 to ×14.
- [RECOMMENDED] Open Question 20 and 9: anchors, AC-CB-30 and AC-CB-54 hold for one-art builds only; `slot_count` has no value. Open.
- [RECOMMENDED] Rule 24: a 0-cooldown soul art can fire every round; add an interim chain limit. Open.
- [RECOMMENDED] AC-CB-53: the g = 2 band (40–75 %) is narrower than the stated sensitivity (17–76 %). Open.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard). Open.
Note: Reviewed-Content-Hash for combat.md is deliberately not stamped, because the file was edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 464360d88fc691b1b317b8fbb25374ec9a19448b
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md 2017d0eaac9940f04149de9616a313f30977083b
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md b8cae5370082854ad69412572d4e3b84cf5f27a9
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 101b72ed58c6e165c881f3027e65e0cc8ed8f043

## Review — 2026-11-06 (third pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 10
Summary: Both blockers of the second pass are resolved and every worked example recomputes. Three small required items remained (two stale registry entries, one acceptance criterion that conflicts with Open Question 20) and were fixed in the same session. The GDD was not re-reviewed after the fixes.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Registry `health_rounds`: safe range 12-22 against GDD 12-26 and AC-CB-58. Fixed in entities.yaml.
- [BLOCKING] Registry `guard_share_kind`: single value 0.75, GDD has body 1.0 and qi 0.75. Fixed (note added).
- [BLOCKING] AC-CB-52: build-generator pairs include multi-art builds, Formulas K is valid for one art a round only. Fixed: gated run limited to one-art pairs, multi-art run reported.
- [RECOMMENDED] Rule 22, Formulas D, rule 10: per-round ward upkeep order against "art costs first" and the snapshot. Open.
- [RECOMMENDED] Formulas I: draw order omits escape rolls and per-side order (AC-CB-01 depends on it). Open.
- [RECOMMENDED] Rule 14: deciding layer undefined for soul wins and for stalemate or flight. Open.
- [RECOMMENDED] Formulas F: `dot_pool_cap` bounds one tick, not the sum over statuses, and ticks skip the ward. Open.
- [RECOMMENDED] Tuning Knobs lists a subset of the data keys that AC-CB-56 requires. Open.
- [RECOMMENDED] Rule 24 / Open Question 16: no interim limit on cooldown-0 soul arts (rho 2 kills in 5 rounds). Open, carried.
- [RECOMMENDED] Formulas G: trigger budget "direct damage this round" has no owner or before/after ward. Open.
- [RECOMMENDED] AC-CB-53: g = 2 band (40-75 %) narrower than stated sensitivity (17-76 %). Open, carried.
- [RECOMMENDED] Open Questions 9 and 20: `slot_count` has no value, multi-art anchors not simulated. Open, carried.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard). Open, carried.
Note: Reviewed-Content-Hash for combat.md and entities.yaml is deliberately not stamped, because both were edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md 2017d0eaac9940f04149de9616a313f30977083b
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md b8cae5370082854ad69412572d4e3b84cf5f27a9
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 101b72ed58c6e165c881f3027e65e0cc8ed8f043

## Review — 2026-11-06 (fourth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 11
Summary: All 3 blockers of the third pass are resolved, the registry matches on 23 checked keys, and every worked example recomputes. The cooldown-timer rework is coherent. Two spec holes around the multi-art round remained and were fixed in the same session; the GDD was not re-reviewed after the fixes.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rule 10 step 3 vs Formulas I: RNG draw order contradicted the round loop (escape rolls, which side's hit list draws first). Fixed: one fixed order.
- [BLOCKING] Rule 13: "no art fired" did not say what counts, so a ward or escape art could silence the basic attack. Fixed: only damage arts suppress it.
- [RECOMMENDED] AC-CB-33, AC-CB-47: stale priority-list wording. Fixed.
- [RECOMMENDED] Rule 22: per-round ward upkeep order. Fixed.
- [RECOMMENDED] Rule 14: deciding layer for soul wins, stalemate, flight. Fixed.
- [RECOMMENDED] Rule 24: interim soul limit. Fixed: one soul art per side per round.
- [RECOMMENDED] Formulas F: sum of ticks uncapped. Fixed: `dot_round_cap` 0.08 (registry entry added).
- [RECOMMENDED] Formulas G: `direct_damage_this_round` had no owner. Fixed.
- [RECOMMENDED] Tuning Knobs listed a subset of the data keys AC-CB-56 requires. Fixed.
- [RECOMMENDED] Rule 10: flight with the other side not Down had no stated winner. Fixed: no winner, failure branch.
- [RECOMMENDED] AC-CB-30, -53, -54, -55, Formulas B, H, K: anchors simulated with one action a round; `slot_count` unset (Open Questions 9, 20). AC-CB-53 marked provisional. Open.
- [RECOMMENDED] AC-CB-53: g = 2 band (40-75 %) narrower than the stated sensitivity (17-76 %). Open, carried.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard). Open, carried.
Note: Reviewed-Content-Hash for combat.md and entities.yaml is deliberately not stamped, because both were edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md 2017d0eaac9940f04149de9616a313f30977083b
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md b8cae5370082854ad69412572d4e3b84cf5f27a9
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 101b72ed58c6e165c881f3027e65e0cc8ed8f043

Note 2026-11-06, after the fourth pass: the user removed rounds. combat.md was reworked to a timeline of seconds (rule 10, Formulas A2) and entities.yaml updated. Not reviewed. Simulated numbers predate the rework and are provisional (Open Question 20); Open Question 21 tracks `art_speed_pct` (replaced cooldown reduction the same day: +100 % halves a cooldown).
Note 2026-11-06: Open Question 9 closed with `slots_by_realm` 3 / 4 / 5 / 6 / 7 and uncapped earned slots (Formulas A2, AC-CB-77). Not reviewed. Open Question 22 holds tree-node sources for the skill tree rework.
