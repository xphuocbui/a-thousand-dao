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

## Review — 2026-11-06 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 8
Summary: First review of the timeline rework. Registry matches on every owned entry, and the worked examples recompute (FX-T and FX-U pools, ward and trigger examples, the art lint, AC-CB-30 simulated second by second, AC-CB-58). Two spec holes were found and both were fixed in the same session on the user's decisions; the fixes were not re-reviewed.
Prior verdict resolved: Yes (the fourth pass's blockers stayed fixed; the rework was the new input)
Findings:
- [BLOCKING] Rule 10/13 Firing: when a guard that turns true mid-instant fires was unstated. Fixed: follow-up instants at the same t (user decision), AC-CB-32 extended.
- [BLOCKING] Formulas D: `ws` had no lower bound, so `pass` divided by zero at `defense_pct` −100. Fixed: `ward_floor` −90 (user decision), registry entry, AC-CB-13, Tuning Knobs.
- [RECOMMENDED] Rule 10, Formulas A2: float event times compared exactly; use integer milliseconds or a rounding rule. Open.
- [RECOMMENDED] Rule 13/22: what protects a side between slotted ward-art firings, and what the ward slot holds. Open.
- [RECOMMENDED] Rule 7, Formulas F: status duration in seconds vs in ticks; curse bounds are prose constants, not named keys. Open.
- [RECOMMENDED] Formulas C, AC-CB-57: `c_art` range 1.2–5 vs the lint (11.25 at cost 0.25, cooldown 30); the 0.5–30 s cooldown range is untested. Open.
- [RECOMMENDED] AC-CB-46: boss "at least 4 seconds" is a harness criterion tagged Logic, with no fixture. Open.
- [RECOMMENDED] Rule 14, Open Question 12: capability #9 outcome unresolved. Open.
- [RECOMMENDED] Open Question 20 (carried): anchors, win rates and mirror lengths still come from the round simulation; AC-CB-53's g = 2 band is narrower than its sensitivity. Open.
- [RECOMMENDED] Player Fantasy section absent and Tuning Knobs without safe ranges (advisory at standard). Open, carried.
Note: Reviewed-Content-Hash for combat.md and entities.yaml is deliberately not stamped, because both were edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md b68575b52f3d836c9bf16fa1c15413610abd3bcb
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md a5b0ca3b803da8733c0b900e89e8834ad14e2e93
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

Note 2026-11-06, after the fifth pass: recommended items 1-6 were also fixed in the same session on the user's decisions: whole-millisecond event times (rule 10, Formulas A2, I); the default ward stands in between ward-art firings (rule 22, AC-CB-27); status and curse durations counted in pulses with seven named `curse_*` keys (Formulas F, Tuning Knobs, registry `curse_bounds`); `c_art` range widened to 1.2-12 to match the lint (Formulas C, K, AC-CB-57); the 4-second boss check left to AC-CB-54 (AC-CB-46); Open Question 12 closed as knockout only (rule 14, AC-CB-63). Open: Open Question 20 anchors, Player Fantasy, Tuning Knob safe ranges. Not re-reviewed. Follow-up outside this GDD: Realms and Character Stats still say "defeat" and "kill" for capability #9.

## Review — 2026-11-06 (sixth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 9
Summary: First full read of the timeline rework and the later fixes. The registry matches on every owned entry and every worked example recomputes (pools, ward and guard hits, trigger, poison, soul, companion, Formulas K, AC-CB-30 FX-U mirror). One spec contradiction blocked implementation (when a guard is read) and was fixed in the same session on the user's decision, together with four small items. The fixes were not re-reviewed.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rule 10 Firing vs Follow-up instants: "all read live" contradicted "read at the start of an instant". Fixed: guards read at the start of the instant, affordability live in slot order (user decision); AC-CB-32 extended.
- [RECOMMENDED] Rule 22 vs rule 10 Start: per-pulse ward upkeep at t = 0 not scheduled. Fixed.
- [RECOMMENDED] Rule 10 Escape: overlapping channels unspecified. Fixed: one channel at a time (user decision).
- [RECOMMENDED] AC-CB-54: typical mirror band 7-9 s against 6.5-7.6 s in Formulas B. Fixed: 6-9 s, provisional.
- [RECOMMENDED] Dependencies: Time & Turn (#4) missing. Fixed.
- [RECOMMENDED] AC-CB-53: g = 2 band (40-75 %) narrower than the stated sensitivity (17-76 %); Summary claim rests on round-simulation numbers (Open Question 20). Open, carried.
- [RECOMMENDED] AC-CB-32 bundles about ten assertions; AC-CB-76 and AC-CB-77 are out of order. Open.
- [RECOMMENDED] AC-CB-59 and Parameter keys count 11 new stat keys; `art_speed_pct` is a twelfth not yet in Character Stats (Open Question 21). Open.
- [RECOMMENDED] Tuning Knobs without safe ranges (user decision; revisit after the first harness run). Open, carried.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard). Open, carried.
- [RECOMMENDED] Realms and Character Stats still say "defeat" and "kill" for capability #9. Open, outside this GDD.
Note: Reviewed-Content-Hash for combat.md is deliberately not stamped, because the file was edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 6e11896df3bee7cf5bb32fe542911ea428fab21f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md b68575b52f3d836c9bf16fa1c15413610abd3bcb
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md a5b0ca3b803da8733c0b900e89e8834ad14e2e93
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-06 (seventh pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 7
Summary: Full read after the guard-timing fixes. The registry matches on every checked value and the worked examples recompute. Two spec gaps would have changed what an implementer builds, and both were fixed in the same session on the user's decisions. The fixes were not re-reviewed.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Formulas D: `pass` had no upper clamp, so at `ward_floor` -90 it could exceed 1 and make blocked damage negative. Fixed: `clamp(pass_raw / (1 + ws/100), pass_min, 1)`.
- [BLOCKING] Rule 10 Down timing and overkill base: the remaining hits and triggers of a side at 0 health, and the overkill base over a multi-hit instant, were undefined. Fixed (user decision): all of an instant's damage resolves first, the larger overkill loses, and equal overkill is a draw with both left at 1 health and a grave wound. The linh lực tiebreak and the random draw are removed. Ticks count as part of the instant's damage.
- [RECOMMENDED] Rule 10 Firing: guard snapshot did not say whether the opening pulse counts. Fixed (user decision): guards are read after the pulse, before art costs.
- [RECOMMENDED] Rule 10 Escape: a roll falling after `time_limit` was unspecified. Fixed: it never rolls and the fight is a stalemate.
- [RECOMMENDED] Tuning Knobs: no safe ranges, while the registry holds some (`health_units`, `qi_units`). User decision, open, carried.
- [RECOMMENDED] AC-CB-32 bundles about ten assertions; AC-CB-76 and AC-CB-77 are out of order. Open, carried.
- [RECOMMENDED] Open Question 20: anchors, win rates and the Summary claim rest on the round simulation; AC-CB-53 and AC-CB-54 provisional. Open, carried.
- [RECOMMENDED] Open Question 21: `art_speed_pct` is a twelfth new key not yet in Character Stats. Open, carried.
- [RECOMMENDED] Realms and Character Stats still say "defeat" and "kill" for capability #9. Open, outside this GDD.
- [ADVISORY] Player Fantasy section absent. Registry note for `cooldown_min` lacks `round_ms`.
Note: Reviewed-Content-Hash for combat.md is deliberately not stamped, because the file was edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 6e11896df3bee7cf5bb32fe542911ea428fab21f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md b68575b52f3d836c9bf16fa1c15413610abd3bcb
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md a5b0ca3b803da8733c0b900e89e8834ad14e2e93
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-06 (eighth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 | Recommended: 5
Summary: Full read after the seventh-pass fixes. Registry constants match and about 40 worked examples and ACs recompute. Two blockers were spec and registry mismatches, both fixed in the same session. The fixes were not re-reviewed.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Rule 10 Defeat check vs Formulas C: the rule said "further below zero" (absolute) while overkill is a share of own `health_max`. Fixed: the rule and Edge Cases now say overkill share.
- [BLOCKING] Registry `ward_block`: expression lacked the upper clamp on `pass`. Fixed in `design/registry/entities.yaml`.
- [RECOMMENDED] Rule 10, rule 14: "grave wound" had no representation. Fixed: a `wound` value (`none`, `grave`, `mortal`) per side in the result.
- [RECOMMENDED] Rule 10 draw test was an exact float comparison. Fixed: `overkill_epsilon` 1e-9, added to Tuning Knobs. Not yet in the registry.
- [RECOMMENDED] AC-CB-23 said health "stops at 0". Fixed: health may be negative until the defeat check.
- [RECOMMENDED] Rule 10: only art cooldowns rounded to milliseconds. Fixed: every time key rounds the same way at load. `cooldown_min` registry note updated.
- [RECOMMENDED] Formulas A2 "Why slots grow slowly" predated the first-fire delay. Fixed: re-derived volley costs (0.45 / 0.75 / 1.05 of the pool).
- [RECOMMENDED] Carried, open: Tuning Knobs safe ranges (user decision); AC-CB-32 bundles about 15 assertions; AC-CB-76 and AC-CB-77 out of order; Open Question 20 (simulation basis, AC-CB-53 and 54 provisional); Open Question 21 (`art_speed_pct`); Realms and Character Stats wording for capability #9.
- [ADVISORY] Player Fantasy section absent.
Note: Reviewed-Content-Hash for combat.md is deliberately not stamped, because the file was edited after this review. The next /design-review will run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 5a92120eef9c6d87988adb2e8f84d5a13c31c17e
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md b68575b52f3d836c9bf16fa1c15413610abd3bcb
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md a5b0ca3b803da8733c0b900e89e8834ad14e2e93
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-06 (ninth pass, covers the ninth-pass fixes) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 8
Summary: Full read after the wake-up and ward-expiry fixes. All 35 registry constants match, about 40 worked examples and ACs recompute, and both mirror fixtures (FX-U t = 25, FX-T t = 8) trace correctly on the timeline. Rules approved; numbers stay provisional until the Balance Harness re-simulates on the timeline (Open Questions 6, 20).
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Rule 13: guard comparisons had no stated operator; AC-75 needs inclusive. Fixed: inclusive.
- [RECOMMENDED] Formulas G, I: trigger free hits had no evade or crit rule. Fixed: can be evaded, cannot crit.
- [RECOMMENDED] Rule 10 Pulse: pulse triggers versus the per-pulse reset. Fixed: they count in the ending window.
- [RECOMMENDED] Rule 14: deciding layer undefined for a draw. Fixed.
- [RECOMMENDED] `wound: grave` had no consumer. Added Open Question 23.
- [RECOMMENDED] Formulas K example uses the old round coefficient (Off 36.51), not FX-T. Open, relabel after Open Question 20.
- [RECOMMENDED] Carried, open: AC-CB-32 bundles about 15 assertions; AC-CB-76 and 77 out of order; Open Question 21; Realms and Character Stats wording for capability #9; Tuning Knobs safe ranges (user decision).
- [ADVISORY] Player Fantasy section absent.
Note: Reviewed-Content-Hash for combat.md is deliberately not stamped, because items 1-5 were edited in after this review. The next /design-review will run in full.
Reviewed-Content-Hash: design/registry/entities.yaml 1dd18313c5a6f5612b6f396a6bd0b84607199d38
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/item-database.md 4a025e61c17dae55125104d5f7b1e58fdfbde8a2
Reviewed-Content-Hash: design/gdd/character-stats.md b68575b52f3d836c9bf16fa1c15413610abd3bcb
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/cong-phap.md a5b0ca3b803da8733c0b900e89e8834ad14e2e93
Reviewed-Content-Hash: design/gdd/dao.md e8b49c93ce9502c1226d44fe9d906a3f9361951d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
