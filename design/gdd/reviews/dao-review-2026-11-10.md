# Design Review: The Way (Đạo) — 2026-11-10

Target: `design/gdd/dao.md` (revised 2026-11-10: graph Ways, Effects on notables, facet slot table, rare arts, 2-6 capstones, 94-Way Catalogue, Sword pilot).
Mode: lean · Workflow: standard · Automation: autonomous · Report-only (no file other than this report and the review log was touched).
Re-review: yes. The prior verdict was APPROVED on 2026-11-06 (fifth pass). The 2026-11-10 rewrite is a new design, so this was a full read.
Checked against: effects.md, modifiers.md, combat.md, kinh-mach-do.md, canh-gioi.md, character-stats.md, linh-can.md, cong-phap.md, systems-index.md, `design/registry/entities.yaml`, and `tools/design/meridian_rework/regions/dao_sword.py`.

## Verdict: NEEDS REVISION

Counts: blocking 1, recommended 12, minor 14 (4 judgement, 10 mechanical), user decisions 7.

**Completeness (standard workflow).** The 5 required sections are present: Overview, Detailed Design (accepted as Detailed Rules), Edge Cases, Dependencies and Acceptance Criteria. Formulas is present and required, because the system defines numeric rules. Tuning Knobs is present. Player Fantasy is absent (advisory at `standard`; see D-10).

**What holds.** The arithmetic in D1, D2 and D3 re-derives:
- W_small 2 × 1 × 1.2 = 2.4, and W_notable 2 × 1 × 8 = 16.
- Bands 1.92–2.88 and 12.8–19.2.
- Mean floor 0.9 × 2 × 2.07 = 3.73.
- The Sword pilot's 158 nodes (121 small or road, 15 stat notables, 15 Effect notables, 6 capstones, plus the free start) and 157 points. The mix gives 530 W against 325 W of map value.
- D3 outputs: 1.661, 1.667 and 1.664; the cap binds only from 596 points.
- The offer invariant 3 + 4 − 1 = 6.

The slot table is consistent with the Sword data: 5 majors, 10 minors, no art, a rival pair (One Sword and Ten Thousand Swords), and capstones 11–12 deep. The registry values match the GDD, except for the stale notes under D-23. The Effect hosts used by the pilot (Echo, Blood Drinker, Steady Breath, First Move, Flowing Water, Opening Cut, Called Blow) list `Way` in effects.md. The rare-modifier rule (Modifier System rule 13) and the Way-art `more` on L2 (rule 12) agree with rule 3. The q-extras treatment of a node's breakthrough chance agrees with canh-gioi.md.

## Dependency graph
- ✓ linh-can.md, character-stats.md, kinh-mach-do.md, canh-gioi.md, cong-phap.md, effects.md, modifiers.md, combat.md, combat-damage-types.md, combat-defence.md exist.
- No GDD, but listed as Implemented in the index: Event Engine (#23), NPC Builds (#24), Living World (#28), Save/Load (#5), Guidance/Debug Terminal (#35/#36). Game UI (#37) is Not Started.
- Not listed as dependencies although the Catalogue leans on them: thien-kiep.md, quests.md, item-database.md (D-08).

## Registry values
- Searched `dao_*`, `npc_dao_*`, `w_target`, `power_mult` and the numeric keys in dao.md.
- No GDD value conflicts with the registry. Every knob dao.md states matches its registry entry: 1, 2, 150, 149, 0.2, 10, 5, 0.2, 10, 1, 1, 3, 6, 0.5 and 0.25.
- The registry itself holds stale notes (D-23).
- `dao_two_art_max` is used by the GDD but has no registry entry (D-14).

---

## Findings

### Blocking

**D-01 [blocking] The key-headroom lint rests on Character Stats ceilings that no longer exist.**
- Where: Formulas D1 part 5 (lines 435–446); Core Rules 4 (97–99), 10 (157–158) and 12 (186–188); Edge Cases "stat line above a ceiling" (570–572); Tuning Knobs `dao_rate_cap_pct`; AC-DAO-09 (789) and AC-DAO-26 (753).
- What is wrong:
  - character-stats.md rule 14 was revised on 2026-11-10 ("no caps", replacing the 2026-11-04 ceilings).
  - `herb_growth_pct` and the lifespan bonus now follow `k · ln(1 + Σ⁺/k)`, with k = 10 for herb growth and a fraction of the realm's lifespan for lifespan.
  - `alchemy_success` now dampens the brew's failure chance (fail ÷ (1 + total/100)).
  - There is no clamp and no "clamp line" for these three keys.
  - D1 part 5 still computes H(k) = ceiling × price (8.1 W, 9 W, "likewise" for lifespan), says a node can be "priced for a line the stat sheet will clamp", and lints against it.
  - The Edge Case, the Advisor warning and AC-DAO-09 still test a clamp on these keys.
  - Only the q-extras ceiling, the tree's 8 pp cap and the crit-type caps remain as real clamps.
- Why blocking: AC-DAO-26 and AC-DAO-09 would be built against behaviour the stat sheet no longer has. The lint also bans craft-key lines for a reason that is now false, and it shapes every craft Dao's graph (Đan, Kỹ, Thời, Mộc and others).
- Fix: see decision Q7. Recommended: keep the headroom as a design guard rather than a clamp. Reword D1 part 5 as "diminishing-return guard": H(k) = k × price, using the curve scales (herb 10, alchemy 3, lifespan 0.15 × L_realm).
  - Remove the "clamp" wording from part 5, rules 4, 10 and 12, and the Edge Case.
  - Keep the clamp text only for keys that still have a ceiling, and name them.
  - Restate AC-DAO-26 against the guard and AC-DAO-09 against a key that really clamps (q extras, crit).
  - Tell the Advisor to warn about diminishing return on curve keys instead of "will not count".

### Recommended

**D-02 [recommended] The NPC premium applies 2.0× to every Dao point, but the pilot's stat value is about 1.63×.**
- Where: Formulas D1 Output Range (468–473), D3 (515–525, 537–545), Overview "the best point a life spends".
- What is wrong:
  - At 1 point a node, Effect notables (15) and capstones (6) are 21 of the Sword's 157 points and carry no W.
  - The pilot's stat lines are 530 W over 157 points = 3.38 W/pt, against the map's 2.07, which is 1.63×.
  - The D1 mean floor (3.73) is taken over priced nodes only, so it does not bind the per-point average.
  - D3 gives an NPC `dao_premium` × P_npc, a full 2.0×, on all its Dao points and says the premium is "the same the player gets".
  - The gap is made up only by unpriced Effects, which D3 also says are "not in the model".
  - So an NPC gets a modelled +25 % from the Dao, while the same points are worth about 1.63× the map in stat lines (a gain of about +16 % at P_npc = 25 % of the points). The unpriced Effects are expected to cover the rest.
- Fix: state the measured premium per point over all points in D1 (pilot 3.38 W/pt, 1.63×). Say in D3 that the NPC's 2.0× includes the Effects' assumed share. Settle through decision Q1 and Open Question 5.

**D-03 [recommended] Many Catalogue facets need systems Combat does not have.**
- Where: Catalogue rows 38 (Ái: companions), 73 (Tọa Kỵ: Mounts), 77 (Gia Tộc, Tổ Tiên: the lineage fights beside you), 80 (Đệ Tử: disciples who fight), 82 (Thần Dân: followers), 83 (Binh Sĩ, Chiến Trận, Công Thành, Lương Thảo: mass battle, siege, supply), 84 (Hộ Vệ: allies, Khiêu Khích: Taunt), 58 (Hội: allies' power), 92 (Cô Tinh: power per missing ally), 94 (Tín Đồ: faith from the world), 91 (Kẻ Thù: a sworn enemy from the World Database).
- What is wrong: Combat is one fighter against one creature plus attached companions (a companion cannot be targeted). Combat has no party, no taunt, no mount, no mass battle and no disciples; mass battles are the Living World's rating profile. Effects rule 5's readable list has no allies, troops or "followers". An Effect that reads them is "an engine addition first" (rule 5).
- Fix: see decision Q2. Add a "needs engine" tag in the Catalogue for these facets so nobody draws them before the decision.

**D-04 [recommended] "No Effect id appears in two Daos" cannot be met from the existing Effect catalogue and implies about 1,900 new Effects.**
- Where: Core Rules 3 and 12; AC-DAO-23; Catalogue (94 Ways).
- What is wrong:
  - Each Way holds up to 15 facet Effects plus 2–6 capstone Effects, so about 20 each, and 94 × 20 ≈ 1,900.
  - The Sword pilot already consumed 7 starter Effects (Echo, Blood Drinker, Steady Breath, First Move, Flowing Water, Opening Cut, Called Blow). effects.md lists those with generic host `Way`, and several also list MM, Tech or Item. After rule 12, no other Way may use them.
  - effects.md's `hosts` field names the kind of source, not a Dao id. Neither GDD says how a per-Dao restriction is recorded.
- Fix: see decision Q3. Whatever the answer, add a `host_dao` field (or equivalent) to the Effect record and give AC-DAO-23 a fixture for it.

**D-05 [recommended] Effects that touch breakthrough and heart demon are not covered by the gate guard.**
- Where: Rule 4; AC-DAO-10 and AC-DAO-22; Catalogue rows 87 (Kiếp Đạo: Hiểm Phá, Risky Breakthroughs, and Kiếp Hậu), 85 (Nghịch Đạo: Cải Mệnh, rerolled odds; Bất Phục), 12 (Mệnh Đạo: Định Mệnh, counted chance), 40 and 41 (Tâm Đạo, Thiền Đạo: heart demon, Tĩnh Tọa), 39 (Vô Tình: heart demon immunity), 80 (Chỉ Điểm: others' breakthroughs), 43 and 90 (heart demon as fuel).
- What is wrong:
  - Rule 4 and AC-DAO-22 test stat lines and "no node multiplies a whole rate or chance". An Effect that rerolls odds, makes a breakthrough riskier for a reward, or lowers heart demon is not a multiplier, but it moves the Realms gate calibration.
  - AC-DAO-10 tests only three stat-line fixtures.
  - Counted chance may be granted "only by a keystone, one chance per keystone" (Effects rule 12). Mệnh's facet idea needs that to be true.
- Fix: see decision Q4. Add a lint rule: an Effect payload on `breakthrough_chance`, `qi_deviation_pct` or heart demon counts under the q-extras ceiling, and a bot fixture for one such Effect.

**D-06 [recommended] D3 and AC-DAO-11 use point totals that do not match the Meridian Map's table.**
- Where: D3 Variables and Output Range (179, 240, 304); AC-DAO-11 (216, 304).
- What is wrong:
  - D3 says an NPC's level is "the first level of its stage".
  - kinh-mach-do.md's table gives CF early 161, CF great perfection 216, NS early 278, NS great 357, DT early 458 and DT great 566.
  - 240 lies between 216 and 278, so it is not a total anyone reaches. 304 is not on the table either. 179 is plausible (CF middle-stage first level) but is not shown.
  - The earlier reviews derived power_mult only from the formula, so this was not caught.
- Fix: re-take the plateau examples from stage-first-level totals in kinh-mach-do.md Formulas A (161, the CF middle and late stages, 278, 357, 458, 566). If 304 is the NS middle-stage first level, say so.

**D-07 [recommended] The Stars seed maps to Mệnh Đạo while a Stars Way (Tinh Đạo) exists.**
- Where: Catalogue seed mapping (line 391); rows 9 and 12.
- What is wrong: "Stars → Mệnh Đạo" (its facet Tinh Tượng, Star Signs), yet row 9, Tinh Đạo · Tinh Hà (River of Stars), is the obvious home of Stars and carries no † mark. Linh Căn rule 16 says "no seed is lost", but the reader cannot tell which Way inherits the Stars seed's old effect.
- Fix: decision Q5.

**D-08 [recommended] Dependencies omit systems the Catalogue and rules lean on.**
- Where: Dependencies; Catalogue.
- What is wrong:
  - thien-kiep.md: Lôi Đạo ("Carry your own tribulation", Thiên Lôi), Kiếp Đạo and Nghịch Đạo's Nghịch Kiếp all act on tribulation. Their rewards are deferred content.
  - quests.md: Hiệp Đạo's Du Hiệp (quests), Bồ Đề's Thiện Hạnh (quests, standing).
  - item-database.md: Kim Đạo's artifact slots, Kỹ Đạo's Luyện Khí.
  - Combat Damage Types and Combat Defence are named only in a sub-bullet block.
  - effects.md, modifiers.md and combat.md list the Way, but there is no back-reference from thien-kiep.md or quests.md.
- Fix: add soft rows for Thiên Kiếp, Quests and the Item Database, and note the reverse references.

**D-09 [recommended] Capstone rivalry is under-specified for enablers and across Daos.**
- Where: Core Rule 3 (capstone, rivals), D1 part 4, AC-DAO-28, Edge Cases (603–604).
- What is wrong:
  - Effects rule 13 makes only a **keystone** exclusive with its marked rival ("A keystone is exclusive with any keystone its host marks as rival"). An `enabler` capstone has no rival mechanism, although rule 3 lets any capstone be marked.
  - The lint marks rivals only inside one Dao. A character may take up to 4 Daos with up to 6 capstones each, so 94 Ways hold about 470 capstones with `closes` clauses. Contradictory ones in different Daos (for example One Sword, "one slotted sword art", and a capstone that needs several sword arts) are not caught.
- Fix: ask effects.md to let an enabler carry a rival mark. Add a catalogue-wide lint: capstones whose `closes` and payloads contradict must be marked rival, even across Daos. Test the lint with a cross-Dao fixture.

**D-10 [recommended] Player Fantasy section is still missing (advisory at `standard`).**
- Where: no `## Player Fantasy` (the file jumps from Overview to Detailed Design).
- What is wrong: this is the fourth review to note it. The rewrite makes it matter more, since the "romantic" pass (names, titles, "the Way as a feeling") is exactly the fantasy. The Overview and Game Feel hold pieces of it.
- Fix: add a short Player Fantasy (2–3 paragraphs): glimpsing a Way, the graph as a place, a capstone naming the build. Take it from the Overview and Game Feel.

**D-11 [recommended] The cultivation-speed cap is per Dao, not character-wide.**
- Where: Rule 4, D1 part 5, `dao_rate_cap_pct`, AC-DAO-10.
- What is wrong: `cultivation_speed_pct` has no ceiling. Each Dao may give +10 %, so 4 Daos give +40 %, plus the map's own lines. AC-DAO-10 tests one fixture Dao at a time. Realms' gate calibration was run without any Dao.
- Fix: either add a character-wide Dao sum (a cap across Daos) or add an AC-DAO-10 variant with the maximum number of Daos reachable at the point total, run against AC-CG-31's windows.

**D-12 [recommended] A requirement states no threshold, and 80 of 94 Ways have none.**
- Where: Rule 5 ("elements at a minimum purity") and the Catalogue "Needs" column; `dao_open_min`.
- What is wrong:
  - Rule 5 says "at a minimum purity" but the Catalogue only says "Fire", "Wood or Fire" and so on. No value or knob exists.
  - Only 12 Ways need anything, so a requirement rarely shapes an offer. The `dao_open_min` 6 invariant is trivially met by about 80 open Ways.
- Fix: decision Q6. Add a knob (for example `dao_req_purity_min`) with a first guess and range, register it, and use it in AC-DAO-06.

**D-13 [recommended] AC-DAO-10's procedure cannot run as written.**
- Where: AC-DAO-10 (791–800).
- What is wrong: it grants the glimpse "on entering Foundation Establishment" and buys the graph "until Mastered". A Foundation Establishment character has 82–120 points and a graph costs about 157. Mastery arrives only at Core Formation or later, so what the test asserts at each realm gate is unclear. The sentence "13.7 W mean" is stale (see D-23).
- Fix: say at which realm the bot grants the glimpse and which gate windows it checks, and recompute the top-of-lint mean for the 1-point graph (about 6.6 W for a 121/36 small/notable mix at the band tops).

### Minor (judgement)

**D-14 [minor] `dao_two_art_max` has no registry entry.** Where: D1 part 4, Tuning Knobs, rule 10. Fix: add an entry to `entities.yaml` (value 2, source dao.md); today it appears only inside the `dao_art_share_max` note.

**D-15 [minor] Catalogue naming and overlap gaps.**
- Rows 1–5, 7, 8, 11, 13, 14, 28–31, 39, 42, 45, 49, 50, 52, 68 and 77 have no hiệu (poetic title), although the short-name pass says every Way keeps one. Some are bare Hán-Việt glosses (row 11).
- Facet names repeat across Ways: Khế Ước (73 and 79), Vô Hình (7 and 8), Cổ (62 and 67). The same concept sits in two Ways: Triều Tịch (Thái Âm, 3) and Triều (Thủy Đạo, 17); Bình Minh (Thái Dương, 2) and Bình Minh Kiếm (Quang Đạo, 25), both "opening burst"; Đan Hỏa (Hỏa Đạo, 18) and Đan Lô (Đan Đạo, 64).
- None of those overlaps is in the "Overlaps to keep apart" list (lines 402–406).
- Fix: add the missing titles, rename or merge the repeated facets, and extend the overlap list.

**D-16 [minor] The D2 shuffle order ("catalogue order") is undefined.** Where: D2. What is wrong: a re-numbered or inserted Way changes every seeded offer. Fix: fix the order as a stable `dao.json` id order (not the display number) and say so.

**D-17 [minor] No data-size or performance note.** Where: Formulas, Tuning Knobs, UI. What is wrong: 94 Ways at about 150 nodes is about 14,000 nodes of data, and the UI draws a 158-node graph. Save stores bought node ids. Nothing states a load budget or how the UI draws a graph. Fix: one line each in Tuning Knobs and UI Requirements.

### Mechanical fixes (apply in one sweep)

**D-18 Status header.** Line 3 says "Approved (design-review 2026-11-06, fifth pass…)" and line 6 says "Last Verified: 2026-11-06" although line 5 says the revision needs a fresh review. Set the Status to "Needs Revision (design-review 2026-11-10)", and update Last Verified when this is resolved.

**D-19 Wrong part number.** "Formulas D1 part 4" for the headroom or rate cap is wrong; it is part 5.
- Line 98–99 (rule 4).
- Line 188 (rule 12, "headroom (D1 part 4)").
- AC-DAO-26 (line 753).
- The other uses of "part 4" (slot table; rule 10; AC-DAO-28) are correct.

**D-20 Stale "only these GDDs exist".** Lines 219–220 (Interactions) and 619–621 (Dependencies): replace "Only Spiritual Roots, Character Stats, Cultivation Techniques, Realms & Bottlenecks and the Meridian Map have GDDs" with the current list (also effects, modifiers, combat, combat-damage-types, combat-defence, item-database, quests, thien-kiep). The Interactions table's "Modifier System, Effects System" row is also marked provisional by this sentence.

**D-21 Stale symbol "V̄".** Tuning Knobs `dao_node_tol` row (line 683) says "from V̄", which D1 no longer defines. Use W_small and W_notable.

**D-22 Stale numbers in Open Question 4 (line 861).** "about 323 W against 279 W at the most Effect-heavy slot table" comes from the 45-node, cost-3 graph (279 = 135 points × 2.07). Use the pilot's figures: about 530 W against 325 W.

**D-23 Registry stale notes (`entities.yaml`).**
- `dao_node_value` notes (line 310) say "Every node costs a flat 3 points" and "output_range is at the defaults (cost 3, premium 2)". It should say cost 1.
- The comment at line 307 says "40-50 nodes". It should say 110–170.
- `dao_full_points` and `dao_node_count` carry old-value comments, which is acceptable.
- The `dao_two_art_max` entry is missing (D-14).

**D-24 Stale AC-DAO-10 mean.** Line 795 "13.7 W mean": replace with the recomputed top-of-lint mean (see D-13).

**D-25 Rule 8a citation.** Catalogue line 247 says requirements "use the root's element purity (Spiritual Roots rule 8a)". linh-can.md rule 8a is "Purity powers element stacks". Cite the rule that defines purity (birth purities), and use rule 8a only for the stack effect.

**D-26 Hard-coded "three".** AC-DAO-15 ("the three-Dao offer"), AC-DAO-17 ("all three Daos") and Game Feel (line 701, "three Daos offered") should read `dao_offer_size`. Rule 6 and the UI list already do so.

**D-27 Stale text in other GDDs (for their own sweeps, not dao.md).**
- kinh-mach-do.md lines 196–197: "at a higher cost per node". It is now the same flat 1 point.
- character-stats.md line 855 (Interactions row 39): "passive ability ids in the capability-style record". Dao nodes are now Effect records.
- combat.md lines 266, 420 and 1090: "Way art nodes on hold", "arts stay on hold", "Art pricing is open (its Open Question 3)". Dao Open Questions 3 and 8 are closed.
- effects.md line 94 ("a Way branch node") and line 292 ("nodes, branches and capstones"): graph Ways have facets and notables, not branches.

---

## Decisions for the user

Each question has a recommended answer first and the alternatives after it.

1. **Q1 (D-02). The NPC premium: should `power_mult` use 2.0 on all Dao points, or the measured stat value?** Recommended: keep 2.0 for now and record that Effects and capstones are the unpriced remainder (about 0.37× of the premium), then let Open Question 5's bot run decide. Alternatives: (a) lower `dao_premium` for NPCs to the pilot's 1.63; (b) raise the stat bands so the stat lines alone give 2.0.
2. **Q2 (D-03). Do Combat and the Living World get allies, mounts, disciples and troops?** Recommended: no, not in this version; tag the roughly 10 affected facets "needs engine" and reshape them onto what exists (companion, self, ground). Alternatives: (a) extend Combat with a party model (large, touches an approved GDD); (b) defer the affected Ways (Binh, Hoàng, Sư, Hiếu, Thủ, Thần) to the end of the catalogue.
3. **Q3 (D-04). May two Ways share an Effect?** Recommended: allow a small shared pool of starter and "family" Effects (hosts listed per Way), and require uniqueness only for capstones and `major` Effects. Alternatives: (a) keep strict uniqueness and accept about 1,900 hand-designed Effects (matches "effects hand-designed"); (b) allow any reuse but never twice in one Dao.
4. **Q4 (D-05). May a Way Effect change breakthrough or heart-demon odds?** Recommended: yes, but only under the q-extras ceiling, with one bot fixture per such Effect. Alternatives: (a) ban it and drop Kiếp Hiểm Phá and Cải Mệnh; (b) allow it outside the ceiling, re-running the Realms calibration.
5. **Q5 (D-07). Which Way inherits the Stars seed?** Recommended: Tinh Đạo (row 9), marked †; Mệnh Đạo keeps Tinh Tượng as its own facet. Alternatives: keep Mệnh Đạo only; mark both.
6. **Q6 (D-12). What minimum purity does a requirement name?** Recommended: one knob `dao_req_purity_min` = 30 (safe range 20–50), applied to every elemental "Needs". Alternatives: a per-Way value in `dao.json`; no purity floor (element ownership only).
7. **Q7 (D-01). What replaces the clamp-based headroom lint?** Recommended: keep it as a design guard using the curve scales (herb 10, alchemy 3, lifespan 0.15 × L_realm) and reword the clamp text. Alternatives: (a) drop part 5, since the curves already give diminishing returns, and rely on AC-DAO-10; (b) cap the marginal value per key against the curve slope.

---

## Specialist notes
Lean mode: no specialists spawned.

## Scope signal
L. There are 94 Ways at about 150 nodes (a heavy authoring load), three formulas, more than 10 dependencies, and several Effect and Combat interface questions. The producer should verify before sprint planning.

## Next steps (for the user)
1. Decide Q7 and Q2–Q6, then revise D-01, D-19 and D-25 in one pass with the mechanical sweep (D-18 to D-27).
2. Re-run `/design-review design/gdd/dao.md` after the revision.
3. Open Question 1 (the `dao_glimpse` contract against the built Event Engine) is still the gate to any Dao being playable.

---

## User answers (2026-11-10, parent session)

- **Q7 / D-01:** drop the headroom check (D1 part 5); the curves already give diminishing returns, and AC-DAO-10 guards the gates.
- **Q2 / D-03:** archive the facets that need allies, mounts, disciples, troops or followers for future extensions, and record them in Combat's future plans.
- **Q3 / D-04:** share minors only. A pool of starter and family `minor` Effects may appear in several Ways; capstones and `major` Effects stay unique to one Way.
- **Q4 / D-05:** allow Way Effects on breakthrough and heart-demon odds **beyond** the q-extras ceiling, and re-run the Realms calibration to absorb them.
- **Q1 / D-02:** keep `dao_premium` 2.0 for NPCs and note that Effects and capstones are the unpriced remainder; Open Question 5's bot run decides.
- **Q5 / D-07:** the Stars seed stays with Mệnh Đạo (no change).
- **Q6 / D-12:** one knob, `dao_req_purity_min` 30 (safe range 20–50), for every elemental requirement.

## Applied (2026-11-10, parent session)

- D-01 key-headroom check dropped (D1 part 5 is now the per-Dao rate cap only); rule 4, rule 12, Edge Cases, UI, AC-DAO-09/26 reworded for Character Stats' curves.
- D-02 measured premium (3.38 W/pt, 1.63×) in D1; D3 notes the NPC's 2.0× assumes Effects and capstones.
- D-03 ◇ archive marks on 10 facets and Binh Đạo; combat.md Open Question 27 records the future extension.
- D-04 shared `minor` pool; `host_dao` field added to effects.md rule 1; rules 3, 12 and AC-DAO-23.
- D-05 rule 4 lets Effects on breakthrough and heart-demon odds exceed the q-extras ceiling; AC-DAO-29; canh-gioi cross-reference row.
- D-06 D3 and AC-DAO-11 on the Meridian stage totals (161, 216, 278, 458, 566).
- D-07 no change (Stars stays with Mệnh Đạo).
- D-08 soft dependency rows: Heavenly Tribulation, Quests, Item Database.
- D-09 effects.md rule 13: enablers may be rivals; cross-Dao rival lint in D1 part 4 and AC-DAO-28.
- D-10 Player Fantasy written.
- D-11, D-13, D-24 AC-DAO-10 rewritten (points-as-they-allow, gates per realm, top-of-band 6.6 W/pt, four-Dao run).
- D-12 `dao_req_purity_min` 30 (rule 5, knob, AC-DAO-06, Catalogue note, registry).
- D-14 registry `dao_two_art_max`. D-15 titles for 22 Ways, repeated facets renamed, overlaps extended.
- D-16 stable `dao.json` id order. D-17 data-size knob row and UI note.
- D-18–D-23, D-25, D-26 mechanical sweep (status, part numbers, stale "only these GDDs", V̄, OQ 4 numbers, registry notes, citation, `dao_offer_size`).
- D-27: combat.md and effects.md lines fixed now; kinh-mach-do.md and character-stats.md lines wait until their own reviews (running) report back.
