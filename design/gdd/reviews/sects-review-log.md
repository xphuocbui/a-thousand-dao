# Review Log: Sects & Missions

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 7 | Recommended: 7
Summary: Structure and worked examples are sound (all F1–F16 examples recomputed and match). Gaps are missing rules: the members step, war targeting and the Expansion dial, invest-track choice, plus a pull-range contradiction between F6 and F15 and a standing field type mismatch with Quests.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Cross-doc: Quests `sect_standing` is an int per sect; Sects F10 is a float per (sect, player)
- [BLOCKING] States/tick step 7: no formula for recruitment, promotions, desertions; AC-SM-42 member band unreachable
- [BLOCKING] Rules 12/17, F7/F9: no war target or goal selection; Expansion dial has no consumer
- [BLOCKING] Tick step 4/F15: no definition of track needs for investment choice
- [BLOCKING] F6 vs F15: pull range -2..2 vs -3..+3
- [BLOCKING] F15 vs npc-traits.md: dispute rulings, raid production x1.5, conditional Tax pull, defence-pact-only lines not in contract; no default dispute ruling
- [BLOCKING] F10: missing leak discovery -40, levy refusal -10 events
- [RECOMMENDED] F3: board_cash source undefined (who takes the missions)
- [RECOMMENDED] F3: head and Indulgent draw missing from Cost
- [RECOMMENDED] Rule 5: vassal levy losses undefined
- [RECOMMENDED] Rule 4: tribute in goods has no valuation
- [RECOMMENDED] Stale cross-refs: Quests rule 3 -> rule 2; Travel & Map/Quests "no GDD"; Phase 5 one-way-links paragraph
- [RECOMMENDED] AC gaps: rule 23, succession tiebreak, Openness manual gate; split AC-SM-38
- [RECOMMENDED] Register truce length, war goal thresholds, p0
- [ADVISORY] Player Fantasy and Tuning Knobs absent
Reviewed-Content-Hash: design/gdd/sects.md 8d1eba620d21f05c6dcd15107a73a9b9d7093aab
Reviewed-Content-Hash: design/registry/entities.yaml d3cc796b28692146abe2e8a2db514aaca0c66c66
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/npc-traits.md 5ae73c3ff9e6913ec9e357d127bd973dc242ebd5
Reviewed-Content-Hash: design/gdd/travel-map.md d0da36e307f9058cbbf1bd3375b96fc2a58fc983
Reviewed-Content-Hash: design/gdd/quests.md 9cbe999adef3a7ee2bc95417e061c5f39ac537cd
Reviewed-Content-Hash: design/gdd/canh-gioi.md ad811a0565d3c91cb87b2a8a3f8b4fe54577151c
Reviewed-Content-Hash: design/gdd/combat.md 16f6c74f5052fba36d5d31a7bfaf34afa96697d3
Reviewed-Content-Hash: design/gdd/cong-phap.md ce33d6ed099b971f0f2498d9dc47896865854a08
Reviewed-Content-Hash: design/gdd/item-database.md 79988e97bb4b0b0226e0d4fc9f2a14e20464c47c
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 (re-review) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 12
Summary: All 7 blockers from the first review are resolved and every worked example recomputes. Remaining gaps are seams between rule text and formulas: the defender-ahead war outcome, two dials with no formula, and the head's draw missing from F3 Cost.
Prior verdict resolved: Yes (7 of 7)
Findings:
- [BLOCKING] F9: outcome undefined when the defender leads; "concedes the goal" does not say whose lead
- [BLOCKING] Rule 12 vs F3/F19: Tax town-rate (tf constant) and War readiness invest share (inv_frac constant) have no dial term
- [BLOCKING] F3 vs F13/F15: head draw (Temperate 1x, Indulgent 4x stipend, every season) missing from Cost
- [RECOMMENDED] F7 vs F18: war-odds test defined twice (war_odds vs war_odds')
- [RECOMMENDED] F9: raid production loss undefined; Cruel x1.5 has nothing to multiply
- [RECOMMENDED] F17 vs AC-SM-42: capacity grows with Institutions, so the members +/-20% band fails by construction
- [RECOMMENDED] F7/F15: event fade defined only in F15
- [RECOMMENDED] Rules 4-5: tribute in goods valuation and vassal levy losses
- [RECOMMENDED] Rule 12 Openness: manual/seat access has no threshold or AC
- [RECOMMENDED] Dependencies table says Realms/Combat do not list Sects back; they do
- [RECOMMENDED] Quests line 668 stale "no GDD"; systems-index #26 note stale
- [RECOMMENDED] AC-SM-42 "war repays" not measurable
- [RECOMMENDED] AC-SM-38/41 bundle checks; no AC for rule 23 or some F15 kinds
- [RECOMMENDED] Registry: truce length, war-goal thresholds, weariness limit, p0
- [ADVISORY] Player Fantasy and Tuning Knobs absent
Reviewed-Content-Hash: design/gdd/sects.md 837ae4006a8a3d0a48070510c7cf18f0cc68bb4b
Reviewed-Content-Hash: design/registry/entities.yaml dd7c70c55cc03c3b417fb229e41fd9dd6a1580df
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/npc-traits.md 5ae73c3ff9e6913ec9e357d127bd973dc242ebd5
Reviewed-Content-Hash: design/gdd/travel-map.md 832eaa5c9220352d07981a78efc16d71ab83aff3
Reviewed-Content-Hash: design/gdd/quests.md 9e511a7e4e4827d9d9d25204254e2a8615582aa7
Reviewed-Content-Hash: design/gdd/canh-gioi.md ad811a0565d3c91cb87b2a8a3f8b4fe54577151c
Reviewed-Content-Hash: design/gdd/combat.md 16f6c74f5052fba36d5d31a7bfaf34afa96697d3
Reviewed-Content-Hash: design/gdd/cong-phap.md ce33d6ed099b971f0f2498d9dc47896865854a08
Reviewed-Content-Hash: design/gdd/item-database.md 79988e97bb4b0b0226e0d4fc9f2a14e20464c47c
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 (third review) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 11
Summary: All 3 blockers from the second review are resolved and every worked example recomputes. The registry shows no conflicts. What remains is seam tidying and gaps that wait on #43 and #27.
Prior verdict resolved: Yes (3 of 3)
Findings:
- [RECOMMENDED] F7 vs F18: war-declaration test says war_odds in F7, war_odds' in F18
- [RECOMMENDED] F9: raid production loss undefined (deferred to #43); Cruel x1.5 has no base
- [RECOMMENDED] Rules 4-5: tribute-in-goods valuation and vassal levy losses
- [RECOMMENDED] Rule 12 Openness: manual/seat access has no threshold or AC
- [RECOMMENDED] F7/F15: event fade defined only in F15
- [RECOMMENDED] Edge Cases and AC-SM-09 cut order omit the head's draw (F3 lists it)
- [RECOMMENDED] AC-SM-42: members +/-20% band fails by construction; "war repays" has no metric
- [RECOMMENDED] Dependencies table says Realms/Combat do not list Sects; they do
- [RECOMMENDED] Quests line 668 stale "no GDD"
- [RECOMMENDED] AC gaps: rule 23, succession tiebreak; AC-SM-38/41 bundle checks
- [RECOMMENDED] Registry: truce length, war-goal thresholds, weariness limit, p0
- [ADVISORY] Player Fantasy and Tuning Knobs absent
Reviewed-Content-Hash: design/gdd/sects.md c32f89e57cba044464f206d2142c33b0aa3a2728
Reviewed-Content-Hash: design/registry/entities.yaml df64c2842421d62d09b1ac6115ddf8539f354996
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/npc-traits.md 5ae73c3ff9e6913ec9e357d127bd973dc242ebd5
Reviewed-Content-Hash: design/gdd/travel-map.md 832eaa5c9220352d07981a78efc16d71ab83aff3
Reviewed-Content-Hash: design/gdd/quests.md 9e511a7e4e4827d9d9d25204254e2a8615582aa7
Reviewed-Content-Hash: design/gdd/canh-gioi.md ad811a0565d3c91cb87b2a8a3f8b4fe54577151c
Reviewed-Content-Hash: design/gdd/combat.md 16f6c74f5052fba36d5d31a7bfaf34afa96697d3
Reviewed-Content-Hash: design/gdd/cong-phap.md ce33d6ed099b971f0f2498d9dc47896865854a08
Reviewed-Content-Hash: design/gdd/item-database.md 79988e97bb4b0b0226e0d4fc9f2a14e20464c47c
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
