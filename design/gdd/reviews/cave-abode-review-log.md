# Cave Abode & Home Works — Review Log

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: M
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 10 | Recommended: 6
Summary: The design holds; the problems are holes in the state machine and acceptance criteria that give wrong numbers. Every blocker has a one- or two-sentence fix that adds no mechanic, state or field. Round 1 of an unattended review-and-revise loop; revisions applied the same day (see cave-abode-auto-decisions.md).
Prior verdict resolved: First review
Findings:
- [BLOCKING] Rules 2 / 11 / F4: rule 2 says a claimed abode starts at grade 1, rule 11 says old grade − 1
- [BLOCKING] Rule 11 / F4: a claim ignores `grade_realm_min` (low-realm claimant of a grade-5 ruin would hold grade 4)
- [BLOCKING] Rule 10 / edge cases / AC-01: a rented or bought residence becomes Left and claimable, contradicting Travel & Map rule 34
- [BLOCKING] States table / edge cases / AC-17: death goes Left or Ruin inconsistently; "founder" is meaningless for a claimed abode
- [BLOCKING] Rule 8 / States: grade fade clock undefined (consecutive? reset? Fallen has no exit but Paid)
- [BLOCKING] Rule 8 / line 172 / AC-10: a living owner's grade-1 abode becoming Left contradicts "cannot push below grade 1"
- [BLOCKING] Rule 3 / 9 / F3: no rule for a work above the level ceiling after the grade falls
- [BLOCKING] Rule 12 / F5: NPC upkeep, fade and the top grade per realm are undefined
- [BLOCKING] Rule 14 / AC-16: player spend versus `M` and `player_net` in Formula H is not stated
- [BLOCKING] AC-08, AC-12, AC-14, AC-18, AC-20: wrong numbers or nondeterministic (Tụ Linh L5 is exactly the 0.75 cap; `tended_abode` max 0.06; no 0.1 step; roll not injected; 60 % fails at the 1-stone floor)
- [RECOMMENDED] Boundary checks / L175: Capability #15 (c1u +0.30) makes "0.85" and "grades 4–5 add only Hộ Sơn, Thanh Mộc, fields" out of date
- [RECOMMENDED] Rule 9: dormancy only when slots are short (free-storage dodge)
- [RECOMMENDED] F1: raising grades 2–3 cheaply at a low realm; accept as intended, note it
- [RECOMMENDED] Rule 12: a dead NPC hermit's abode becomes a Ruin record
- [RECOMMENDED] F2: round before `ceil` against float error
- [RECOMMENDED] ACs: split AC-10 and AC-13, fixtures for AC-04/05, AC-02 WHEN, AC-17 cites rule 11
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/registry/entities.yaml ff2fa65467c0a564336fe8d480ba09652509f8a1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/formations.md 8f2cdf8ac518d7389f483b6de87b182949453f62
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: M
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 7 | Recommended: 8
Summary: Round 2 of an unattended loop. Round-1 arithmetic holds; what remains is one stale range (F3), a ledger wording clash with Regional Economy Formula H, and gaps in the state tables, NPC payment and action timing. Every blocker is a one- or two-sentence fix that adds no mechanic, state or field.
Prior verdict resolved: Yes (round 1's 10 blockers resolved; no regression found)
Findings:
- [BLOCKING] F3 / registry abode_slot_limit: level ceiling range says 3 to 5, rule 3 gives grade + 2 (up to 7)
- [BLOCKING] Rule 14 / AC-CA-16: burn_abode in Formula H is grade raises, grade upkeep and claims only; standing arrays go to burn_formation; AC-16 cites a wrong identity
- [BLOCKING] Rule 12 / F5 / AC-CA-14: NPC payer per holder undefined; roll direction (roll < npc_raise_p) unstated
- [BLOCKING] States table / rule 11: no initial Open state, no move/death rows for Open/Neglected/Fallen, Hidden place has no exit to Claimed, "founder's ruin" left over
- [BLOCKING] Rules 8, 10, 11: grade clock and works on leaving, death and claim unspecified
- [BLOCKING] Rule 3 / 9 / work table: Building slot holding, level raise, Fading to Dormant, 2-slot reactivation
- [BLOCKING] Rules 6, 11: timing of paying and applying a raise, opening and claim
- [RECOMMENDED] Rule 8: one paid season in four dodges the fade clock; state automatic payment, harness watch
- [RECOMMENDED] Rule 6: a raise needs a realm that can hold the grade
- [RECOMMENDED] UI table: dormant choice only when a slot is lost
- [RECOMMENDED] States: Neglected/Fallen wording after a fall
- [RECOMMENDED] ACs: fixtures for 04, 05, 14, 19; split 13; new ACs for 2-slot dormancy, partly faded claim, Fallen to Open, clock reset on Left
- [RECOMMENDED] Variable tables: grade_cost, claim_fee, grade_after, top_grade, purse; registry round(...,6) and claim_fee referenced_by
- [RECOMMENDED] F4: claim fee ignores grade stones, record as a harness check
- [RECOMMENDED] Dependencies: Living World Tick and Game UI notes
Reviewed-Content-Hash: design/gdd/cave-abode.md ca46ef209d3c0eba34debdf5b1c583978aa00577
Reviewed-Content-Hash: design/registry/entities.yaml 9507b83004c3f7d135364be79d8dd6b85ccf58c1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/formations.md 8f2cdf8ac518d7389f483b6de87b182949453f62
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: M
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 4 | Recommended: 12
Summary: Round 3 of an unattended loop. Round-2 fixes hold and the arithmetic of F1-F5 checks out; what remains is one acceptance criterion that contradicts the timing rules, an NPC reserve clamp that contradicts itself, a ledger citation that points at nothing, and an ambiguous residence-upkeep clause. All four are text fixes that add no mechanic, state or field.
Prior verdict resolved: Yes (round 2's 7 blockers resolved; no regression found)
Findings:
- [BLOCKING] AC-CA-16 / rules 6, 11: grade-3 upkeep (13) paid in the season of the 2->3 raise and a claim; that season owes grade-2 upkeep (5), a claimed abode owes none, and one season cannot hold both
- [BLOCKING] Rule 12 / F5 / AC-CA-14: "clamped by construction to pool less reserve" vs per-NPC payment as "a check on the sum"; only the 2x raise gate holds a reserve
- [BLOCKING] Rule 14: cites a Travel & Map ledger line for layer-1 works, fields and the opening fee that does not exist
- [BLOCKING] Rule 8: "a residence pays rent instead" can be read as removing the upkeep of upkept works in a residence
- [RECOMMENDED] States: Claimed row has no exit on moving or dying; Building has no exit to Dormant/Fading; "gone" unnamed
- [RECOMMENDED] Rule 10 vs Travel & Map rule 34: a bought residence "returns to its holder" vs "owns" (round-1 decision stands)
- [RECOMMENDED] Rule 8: payment order and no part-payment; whether an Open abode owes upkeep in its opening season
- [RECOMMENDED] Line 176: grades 4-5 add slots, the works are not grade-gated; fantasy gap after grade 3
- [RECOMMENDED] Left to Ruin on a former owner's death; NPCs never claim; grade-1 upkeep has no penalty
- [RECOMMENDED] ACs: 18 dormancy cause, 08 data key, 03 ceiling fixture, 06/02 timing, 13 fixture and split, 14 sums, pool-clamp AC; F1 whole-ladder example is the worst case
- [RECOMMENDED] Open Questions: NPC purse granularity dependency; NPC fade-clock dodge
Reviewed-Content-Hash: design/gdd/cave-abode.md 02334bc982371023212f080a8710bbcbe37d8b23
Reviewed-Content-Hash: design/registry/entities.yaml 302843ddb650019b6f5c45573482f1747ab1ea90
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/formations.md 8f2cdf8ac518d7389f483b6de87b182949453f62
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: M
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 2 | Recommended: 14
Summary: Round 4 of an unattended loop. Round-3 fixes hold and the F1-F5 arithmetic is correct at every boundary. Two text contradictions remain: AC-CA-14 omits the raising NPC's same-season grade-2 upkeep (and F5 never says when the purse is read), and the Claimed state has no exit for a move or death although rule 10 gives it one. Both are text fixes that add no mechanic, state or field. Tuning Knobs is advisory at the standard tier.
Prior verdict resolved: Yes (round 3's 4 blockers resolved)
Findings:
- [BLOCKING] AC-CA-14 / F5 / Edge Cases (NPCs): two-NPC aggregate is 3,755 not 3,750 (raiser pays grade-2 upkeep 5, rule 6); "no money moves" contradicts upkeep; F5 does not say the purse is read before the season's upkeep
- [BLOCKING] States and Transitions: Claimed has no exit on move or death (rule 10); Ruin "reached from" list omits Claimed
- [RECOMMENDED] Rules 6/8: raise during the fade window and a raise-season move or death (game-designer B1, economy near-block); creative-director: independent and buildable, a refusal would be a new mechanic
- [RECOMMENDED] Rule 11/12: only the player claims (NPC claiming); would orphan edge line 201 and AC-CA-13
- [RECOMMENDED] Rule 14: economy "no recipient" — Regional Economy line 544 already names the commons pool; cite it; rule 8 "perpetual sink" is the grade upkeep
- [RECOMMENDED] Rule 12: per-NPC purses vs a banded-purse ADR in Formula H (Open Question 9)
- [RECOMMENDED] Tuning Knobs section absent (advisory at standard)
- [RECOMMENDED] Registry abode_upkeep expression lacks round(...,6); partial payment; Open-season upkeep; Left to Ruin on death clause; NPC starting-grade seeding; Building to Dormant; AC-18 dormancy cause; AC-04/05 fixtures; harness watches (claim fee vs grade, Ruin growth, dormancy parking, breakthrough re-pricing)
Reviewed-Content-Hash: design/gdd/cave-abode.md e7a6d4b4cdc82b733653d73357d267e379e06168
Reviewed-Content-Hash: design/registry/entities.yaml 302843ddb650019b6f5c45573482f1747ab1ea90
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/formations.md 8f2cdf8ac518d7389f483b6de87b182949453f62
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b

## Review — 2026-11-21 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean, single-session analysis)
Blocking items: 0 | Recommended: 4
Summary: Round 5 of an unattended loop. Round-4 fixes hold (AC-CA-14 aggregate 3,755, Claimed exits). F1-F5 arithmetic re-checked at every boundary (20 / 1.5M, 1 / 3,000, 2 / 7,500, 8.0 ladder, 12.5 rounds to 13); layer-1 records in map_works.json match the ACs; all dependency GDDs exist (Realms is canh-gioi.md); registry values agree. No contradiction or unbuildable rule left; the remaining items are tracked or advisory.
Prior verdict resolved: Yes (round 4's 2 blockers resolved)
Findings:
- [RECOMMENDED] Tuning Knobs section absent (advisory at standard)
- [RECOMMENDED] Registry abode_upkeep expression lacks round(...,6)
- [RECOMMENDED] Fixtures for AC-CA-04/05/18; Open-season upkeep and partial payment unstated
- [RECOMMENDED] Harness watches (claim fee vs grade, Ruin growth, dormancy parking) already in OQ 9
Reviewed-Content-Hash: design/gdd/cave-abode.md 91daf51680fb4839817a7509d0965b812ccc4651
Reviewed-Content-Hash: design/registry/entities.yaml 302843ddb650019b6f5c45573482f1747ab1ea90
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/formations.md 8f2cdf8ac518d7389f483b6de87b182949453f62
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
