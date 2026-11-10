# Review Log: The Way (Đạo) — design/gdd/dao.md

## Review — 2026-11-06 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 3 | Recommended: 7
Summary: The design was coherent at the reviewed text (D1 arithmetic, D2 shuffle and D3 formula re-derived and held at defaults). Blockers were a data-lint invariant that broke at the stated knob ranges, an NPC multiplier range sentence citing a total (164) that is not in the Meridian Map ladder, and missing reverse dependencies. The reviewed text was the 2026-11-05 version; D1 (flat 3-point nodes, 20 nodes, dao_premium 2) and D3 (premium in power_mult) were rewritten on 2026-11-06 while the review ran, so the D1/D3 findings and the trap-choice recommendation were not checked against the new text.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas D2 / Tuning Knobs: dao_open_min ≥ offer size + 3 holds only at defaults; ranges for glimpses per realm (1–2) and offer size (2–4) break it. Fixed: invariant dao_open_min ≥ dao_offer_size + 4·dao_glimpses_per_realm − 1, linted in AC-DAO-01, ranges narrowed.
- [BLOCKING] Formulas D3: "164 points" is not a Meridian Map total, and level 54 (179 points) falls outside the stated plateau. Level 87 = 304 was verified (278 + 6 + 20). Fixed in the Output Range text.
- [BLOCKING] Dependencies: cong-phap.md and canh-gioi.md did not list the Way. Fixed: rows added to both.
- [RECOMMENDED] Rule 10: a Dao priced to the map mean loses to best-first map play (trap choice). Likely answered by the 2026-11-06 premium; re-check.
- [RECOMMENDED] D3: the linear-power assumption (points_total ÷ map_points) likely over-compensates; the premium makes this larger. Bot run needed (Open Question 5).
- [RECOMMENDED] Rule 11: an NPC Dao is only a multiplier, with no world presence (Pillar 5).
- [RECOMMENDED] Edge Cases: a glimpsed Dao deleted from the catalogue, or its requirement changed.
- [RECOMMENDED] Acceptance Criteria: split AC-DAO-01, give AC-DAO-15 measurable fields, fix numbering order.
- [RECOMMENDED] Registry: add w_target (2.07); align W_n with W(n); check the entries for the new dao_node_cost, dao_premium and dao_node_count.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard).
Receipt: none stamped. The document changed during the review, so a hash would falsely mark the new D1/D3 as reviewed. Re-review from scratch.

## Review — 2026-11-06 (second pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 9
Summary: A full read of the current text (flat 3-point nodes, dao_premium 2, premium in D3) found the D1, D2 and D3 arithmetic correct and the registry values consistent. The two blockers were specification gaps: the cap a Dao's breakthrough chance falls under, and a value lint that only held the whole-tree mean. All blockers and 8 of 9 recommendations were fixed in the same session; the revised text has not been re-reviewed.
Prior verdict resolved: Yes (the three blockers of the first pass held; the prior recommendations on the premium and trap choice, reverse dependencies and the registry were closed or re-raised below)
Findings:
- [BLOCKING] Rule 4 / AC-DAO-18: the Dao's breakthrough chance was tested against "the tree's 8 pp cap", which belongs to the Meridian Map tree. Fixed: counts under the 10 pp q-extras ceiling only; Realms lists the Way as a q-extras source (user decision).
- [BLOCKING] Formulas D1: the lint held only the whole-tree mean, so one branch or the keystone route could be a trap or a jackpot. Fixed: per-branch ±20 % (dao_branch_tol) and keystone route ≥ 0.9 x V̄ (dao_route_floor), in AC-DAO-01 and the example.
- [RECOMMENDED] D1 Output Range: "+40 %" was the Deity Transformation figure; restated per realm (+37 % one Dao at Core Formation entry, +56 % two at its end, +40 % four at the top). Fixed.
- [RECOMMENDED] Rule 1 vs the N lint: branches of 6 or 7 give 19-22 nodes, not 18-22. Fixed: 19-22, C_dao 57-66.
- [RECOMMENDED] Registry: w_target not registered, C_dao named differently from dao_full_points. Fixed; dao_branch_tol and dao_route_floor added.
- [RECOMMENDED] Edge Cases: nodes added to a Mastered Dao, a deleted glimpsed Dao, a changed requirement. Fixed (AC-DAO-24).
- [RECOMMENDED] Glimpse timing: the player cannot know a glimpse is coming. Fixed: Advisor heads-up (user decision), UI Requirements and AC-DAO-15.
- [RECOMMENDED] Pillar 5: an NPC's Dao had no world presence. Fixed: stored on the record and written to the World Database (AC-DAO-25).
- [RECOMMENDED] Acceptance Criteria: AC-DAO-01 split (01, 21, 22, 23), AC-DAO-10 fixtures named, AC-DAO-20 threshold, AC-DAO-15 reordered. Fixed.
- [RECOMMENDED] Tuning Knobs: glimpses 2 with offer 4 needs dao_open_min 11, above the range. Fixed in the knob note.
- [RECOMMENDED] Pillar 3: with arts on hold and half the nodes stat lines, "a specialisation, not a bonus" is weak. Open (creative call; Open Question 8). Player Fantasy section still absent (advisory at standard).
Files changed in this session: design/gdd/dao.md, design/gdd/canh-gioi.md (q-extras list), design/registry/entities.yaml.
Receipt: none stamped. The revised text has not been reviewed, so a hash would falsely mark it as reviewed. Re-review from scratch.

## Review — 2026-11-06 (third pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 7
Summary: A full read found the D1, D2 and D3 arithmetic and the registry values correct, and the reverse dependencies in place. The one blocker was that the node-value lint priced stat lines unclamped, so craft Daos (alchemy_success capped at 3 pp, herb_growth_pct at 10) could be built from dead nodes, and cultivation_speed_pct (no ceiling) could reach about +125 % in one tree. The blocker and three recommendations were fixed in the same session; the revised text has not been re-reviewed.
Prior verdict resolved: Yes (both second-pass blockers held)
Findings:
- [BLOCKING] Formulas D1 / rules 4, 10, 12: no key-headroom lint. Fixed: part 4 of the lint (ceiling x F1 weight per key; cultivation speed capped by new knob dao_rate_cap_pct 10 %, user decision), AC-DAO-26, AC-DAO-10 fixtures exempted, registry entry added.
- [RECOMMENDED] Formulas / AC-DAO-01 / Tuning Knobs: bands and ranges only valid at cost 3, premium 2. Fixed: marked "at defaults", credits rescale with the premium.
- [RECOMMENDED] D2 and registry: hard-coded min(3, |E|). Fixed: dao_offer_size.
- [RECOMMENDED] Edge Cases / States: "Keystoned or Glimpsed" after nodes are added. Fixed: Keystoned.
- [RECOMMENDED] Dependencies: Progression Edges "#21" collided with Combat. Fixed: system 11, design order #10.
- [RECOMMENDED] AC-DAO-10: [Bot] tag not in the evidence table. Fixed: [Integration, Bot].
- [RECOMMENDED] Player Fantasy section absent (advisory at standard); Open Question 8 (specialisation vs bonus with arts on hold) still open.
- [RECOMMENDED] Open Questions 4 and 5: premium uplift and linear-power assumption await a bot run.
Files changed in this session: design/gdd/dao.md, design/registry/entities.yaml, design/gdd/systems-index.md.
Receipt: none stamped. The revised text has not been reviewed, so a hash would falsely mark it as reviewed. Re-review from scratch.

## Review — 2026-11-06 (fourth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 7
Summary: A full read found the D1, D2 and D3 arithmetic, the registry values and the reverse dependencies correct. The one blocker was a knob range that broke the lint: V̄ moves with cost and premium, but the ability credits rescaled with premium only, so `dao_node_cost` 5 could not meet the bands. The blocker and four recommendations were fixed in the same session; the revised text has not been re-reviewed.
Prior verdict resolved: Yes (the third-pass blocker held)
Findings:
- [BLOCKING] Formulas D1 / Tuning Knobs: ability credits did not scale with `dao_node_cost` (range 3–5). Fixed: the lint uses credit(T) × premium × cost ÷ 6, and a passive's parameters are retuned with it; knob rows and AC-DAO-01 updated.
- [RECOMMENDED] Rule 6 / UI Requirements / Edge Cases: "three" hard-coded against the `dao_offer_size` knob. Fixed.
- [RECOMMENDED] AC-DAO-11: no boundary fixtures for the D3 plateau and cap. Fixed: 216, 240 and 566 points.
- [RECOMMENDED] Edge Cases, NPCs: an NPC that qualifies for no Dao was unstated. Fixed: the roll counts as failed (AC-DAO-12).
- [RECOMMENDED] AC-DAO-20: a human judgement tagged as Config/Data alone. Fixed: human sign-off.
- [RECOMMENDED] Open Questions 4 and 5: settle the player and NPC uplift in one bot run against the difficulty targets. Open.
- [RECOMMENDED] Pillar 3: stat-line share with arts on hold; record the call under Open Question 8. Open.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard). Open.
Files changed in this session: design/gdd/dao.md, design/gdd/systems-index.md.
Receipt: none stamped. The revised text has not been reviewed, so a hash would falsely mark it as reviewed. Re-review from scratch.

## Review — 2026-11-06 (fifth pass) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: A full read found no blocker. D1, D2 and D3 arithmetic was re-derived and held (V̄ 12.42, the 236 W example, credit rescaling at premium 3 and cost 5, power_mult at 161/179/216/240/304/566 points). Registry values and the cross-document numbers (2.07 W per point, 566 points, 10.6 %, 8 pp and 10 pp caps, F1 weights, ceilings) are consistent, and all five related GDDs list the Way. Lean mode: no specialist or creative-director sign-off.
Prior verdict resolved: Yes (the fourth-pass credit-scaling blocker held)
Findings:
- [RECOMMENDED] Formulas D1 part 4: `lifespan_years` headroom is "likewise"; it derives to 45 W (15 % x L_r x 300 / L_r), and the shared pill-years term is unstated.
- [RECOMMENDED] Registry: `q_extras_ceiling_pp` note omits the Way's node breakthrough chance, which canh-gioi.md counts there.
- [RECOMMENDED] Overview vs rule 10: "a specialisation, not a bonus" against "extra power by design"; reword or record under Open Question 8.
- [RECOMMENDED] Tuning Knobs: at `dao_node_cost` 5 or `dao_premium` 3 the key-headroom limits do not scale, so a craft Dao may be unreachable.
- [RECOMMENDED] Open Questions 4 and 5: one bot run for the premium uplift and the linear-power assumption.
- [RECOMMENDED] Rule 9: "four Daos" restates the realm count; derive it.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard).
Gate to build: Open Question 1 (`dao_glimpse` contract with the implemented Event Engine) before any Dao is playable.
Files changed in this session: design/gdd/systems-index.md (row 39 status), this log.
Post-review edits, not re-reviewed: dao.md status line, the Overview wording and rule 9 (recommendations 3 and 6), and the q_extras_ceiling_pp registry note (recommendation 2). The hashes below are the reviewed content, so a later check reads these two files as changed.
Reviewed-Content-Hash: design/gdd/dao.md 1fa01ca75ee6ee76a85021cb5de12c16b5ca5b0c
Reviewed-Content-Hash: design/registry/entities.yaml e3c9846191bfa5abd35ed2ea21d3cc999bea9bd5
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 83b03b9cc2641b59073b2163fa10f007a3278a57
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/cong-phap.md 3208073198959665fb0efc24c66532fb4fedb15e
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/character-stats.md 8215f27f8abd2f984675f96d69ddceb554dc8464
Reviewed-Content-Hash: design/gdd/game-concept.md 101b72ed58c6e165c881f3027e65e0cc8ed8f043

## Review — 2026-11-10 (sixth pass, graph-Ways rewrite) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 12
Summary: A full read of the 2026-11-10 rewrite found the D1-D3 arithmetic, the registry values and the Sword pilot data consistent. The one blocker is that the key-headroom lint still models Character Stats ceilings that rule 14 replaced with curves on the same day. Recommended items cover the NPC premium against the pilot's measured value, Catalogue facets that need allies and troops Combat lacks, Effect uniqueness at scale, breakthrough-touching Effects, and the D3 point totals. Full report: design/gdd/reviews/dao-review-2026-11-10.md (report-only; no GDD edited).
Prior verdict resolved: First review of the rewritten design (the 2026-11-06 fifth-pass approval predates it)
Findings:
- [BLOCKING] Formulas D1 part 5 / rules 4, 10, 12 / AC-DAO-09, AC-DAO-26: headroom lint and clamp tests built on removed ceilings (D-01)
- [RECOMMENDED] D1/D3: NPC premium 2.0x vs pilot stat value 1.63x (D-02)
- [RECOMMENDED] Catalogue: facets need allies, mounts, troops, disciples (D-03)
- [RECOMMENDED] Rule 12: Effect uniqueness vs about 1,900 Effects and consumed starters (D-04)
- [RECOMMENDED] Rule 4 / AC-DAO-10, 22: breakthrough and heart-demon Effects uncovered (D-05)
- [RECOMMENDED] D3 / AC-DAO-11: totals 179, 240, 304 not on the Meridian Map table (D-06)
- [RECOMMENDED] Catalogue: Stars seed mapping vs Tinh Đạo (D-07)
- [RECOMMENDED] Dependencies: Thiên Kiếp, Quests, Item Database missing (D-08)
- [RECOMMENDED] Rule 3 / AC-DAO-28: enabler and cross-Dao rivalry (D-09)
- [RECOMMENDED] Player Fantasy absent (D-10)
- [RECOMMENDED] Rule 4: cultivation speed cap per Dao only (D-11)
- [RECOMMENDED] Rule 5: no purity threshold (D-12)
- [RECOMMENDED] AC-DAO-10: procedure cannot run as written (D-13)
- [MINOR] 4 judgement items and 10 mechanical fixes (D-14 to D-27)
Files changed in this session: design/gdd/reviews/dao-review-2026-11-10.md and this log only.
Reviewed-Content-Hash: design/gdd/dao.md c2951336024a0cd8817dd5cdcd695522c93ac57e
Reviewed-Content-Hash: design/registry/entities.yaml f2ad99700589a66dd1722e04802f3b3e58f1dd66
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b92f9946089a4d7e2d58062b33d1a328f2cda751
Reviewed-Content-Hash: design/gdd/linh-can.md bc26ba79399663c249c2488bf79f97487b1598c3
Reviewed-Content-Hash: design/gdd/cong-phap.md 747c3aa1bab3b24cbb70f4803581b3622a42c44d
Reviewed-Content-Hash: design/gdd/canh-gioi.md e905183a564a46d236b23cfb5758ef5cac358ff8
Reviewed-Content-Hash: design/gdd/character-stats.md a909d5d7a93bb21705a6c1cebcbc71db34062651
Reviewed-Content-Hash: design/gdd/effects.md fd3ef44e00d66b19d2e9d5824835f9a8e848861f
Reviewed-Content-Hash: design/gdd/modifiers.md 3f29eaaa9182b127e2f067e4921d84de403a4c3b
Reviewed-Content-Hash: design/gdd/combat.md b09a57de902251f6dc1c9b07f4f3767c1a211414
Reviewed-Content-Hash: design/gdd/systems-index.md 0c622ddc1431192f45cc3ed7a9842b795bbbd013
