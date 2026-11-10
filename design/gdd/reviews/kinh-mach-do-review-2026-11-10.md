# Design Review: Meridian Map (Kinh Mạch Đồ) — 2026-11-10

Review mode: lean (single session, no specialists) · Workflow: standard · Report only: no GDD, registry or code was edited.
Re-review: Yes. The prior verdict was NEEDS REVISION on 2026-11-05. Its fixes never had their own re-review (log note).
Scope signal: XL (270 KB, 3,100+ lines, 8 hard or soft dependencies, a generator spec, 95 acceptance criteria).

## Verdict: MAJOR REVISION NEEDED

The GDD is internally careful, but it describes the **old** map: 1,300 acupoints, generic exact roads, 3 radials per
sector and fixed ring depths 5/14/20. Two things have moved past it:

- the hand-drawn tree (`meridian-tree-overnight.md`), and
- the user's own 2026-11-10 redraw decision, which is already pasted into rule 1.

That decision contradicts rules 4 and 21, the registry and the road tuning knob in the same document. The Combat #44, Effects, Modifiers, purity and
ceiling-curve revisions are also only partly carried through. Fixing this is a real rewrite of rule 1, Formulas C/F/H/G7, Parameter
keys, the Tuning Knobs and about 30 acceptance criteria, so it is not a patch pass.
The user has already said the tree will be reworked ("Redesign planned" banner), so I recommend deciding D1 first and
fixing everything else after.

### Completeness (standard tier: 5 required + Formulas, which the system defines)
All of Overview, Detailed Design, Formulas, Edge Cases, Dependencies and Acceptance Criteria are present and substantive: 6/6.
Player Fantasy and Tuning Knobs are present too (advisory at standard). Player Fantasy omits the variant sector origin story
only in a small way, and is otherwise fine.

### Dependency graph
Every GDD named exists: linh-can, character-stats, canh-gioi, cong-phap, dao, effects, modifiers, combat, item-database, quests.
**Not drawn from the list below:** Event Engine, Save/Load, World Database, LLM Game Master, Progression Edges, Time & Turn and the other hosts have no
GDD (known and recorded as provisional), so their interfaces stay provisional.
The Dependencies tables still have no rows for the Modifier System, Effects System or Combat sub-GDDs (KMD-12).

### Registry values
Searched: the registry's kinh-mach-do entries (`points_total`, `great_breakthrough_bonus`, `npc_unseal_chance`, `cluster_fill_budget`,
`huyet_value_small/notable/highway`, `tree_size_target`, `tree_breakthrough_chance_cap`, `variant_sector_size/value`, `stat_power_weights`) against the
GDD. Points ladder, bonuses, H0 1.2, S0 1.2, N0 8, size 1,300 (772 + about 525), cap 8 pp and sector size 30 all agree with the GDD.
No numeric conflict with the registry. The registry is as stale as the GDD on the redraw (KMD-01, KMD-02). `stat_power_weights` is owned by modifiers.md
and the GDD still writes its own table as if it owned it (KMD-04).

## Blocking findings

### KMD-01 — blocking — Rule 1 piece table (Meridian road row) vs rules 4/21, Tuning Knobs `road_stats`, registry `huyet_value_highway`, linh-can rule 8
The Meridian road row carries a "Redraw rule (user decision 2026-11-10)": an element land's roads grant only that element's **purity**,
blend-zone roads grant half of each neighbour's, and hub roads keep generic stats. The rest of the GDD still says the opposite:
rule 4 ("meridian roads are exact"), rule 21 ("generic roads … exact … same in every sector"), Tuning Knob `road_stats` ("generic stats
only"), Formulas A2 and H0 (route power uses H0 for roads) and AC-KMD-61/rule 21 criteria. The registry says the same (`huyet_value_highway`: generic, exact on every root).
Linh-can rule 8a and Open Question 14 expect roads to be a **purity source** ("rare sources … an element land's meridian roads"), but the price
(W per point of purity) and the amount per node are not set.
Fix: rewrite rule 4, rule 21, A2 route power, H0, `road_stats` and the road ACs to the new road model once D1/D2 are answered. Until then, mark the redraw row
as a banner, not a rule. Do not leave both live.

### KMD-02 — blocking — Summary, rule 1, Formulas C/G/H/H2, Parameter keys, Computational budget, AC-KMD-08/10/60–67 vs the redrawn tree
The redrawn tree (`design/research/meridian-tree-overnight.md`, built by `tools/design/meridian_rework/build_tree.py`) is a different structure:
- lean about 6,300 and full 8,672 visible acupoints, against 772 visible and 1,300 in all;
- five element lands, five blend zones, a Taiji hub, island regions and a Shadow Shrine, against five sectors with 3 radials, K1/K2/K3 rings at depths 5/14/20;
- 76–78 hidden clusters of 6–11 (mean 9), against about 75 of 3–12 (mean 8, sd 2);
- about 1,400 visible notables, 34–40 keystones and 11 starts, against 11 keystones and one start per element.

The GDD itself says the tree "will be redesigned" (header banner), yet it calls itself In Review and the generator, the sealed-cluster
authoring plan and the NPC allocator budget (about 3,700 BFS steps, which would grow about 5–7× at 6,300–8,700 acupoints) all target the old map.
Rules 19 (append-only, ids forever) and the id blocks (G9) also need a decision, because the redraw changes every position.
Fix: decide D1 (adopt the drawn tree or not). If adopted, the GDD needs a new "Map structure" section generated from the kit's output (counts, rules, drawing
checks) and Formulas C/H/G7/G8 and AC-KMD-08/10/60–67 re-derived. If not adopted, remove the redraw row and the draft's implications. Re-run the bot calibration (AC-KMD-07/50/89), which the log says is already due.

### KMD-03 — blocking — Rules 16–18, the capability table (rule 17), Capability hosts, Dependencies (Effects bullet) vs effects.md
Ownership of the 25 capabilities is contradictory:
- Rules 16–18 and the Capability hosts list say the Meridian Map owns the catalogue and the hosts implement the behaviour.
- The Dependencies footnote (line about the Effects System) says "the 25 live capabilities moved there as Effects".
- effects.md rule 13/Keystones table re-expresses them as keystones (with a closing cost) or rule-change Effects, and its Open Question 4 asks where each sits in the tree.

The texts have diverged too: #25 Heart Demon Turned to Strength here reads "above 50 adds attack (+heart demon ÷ 2 %); backlash chance ×2", but in effects.md it is Heart Demon's Blade, "above 30, L5 +1 per point, cap +40, qi deviation ×2, +1 heart demon per fight won". #17 Beast Soul Union here has no cost, but effects.md closes with "−1 art slot; only one companion fights with you".
The GDD's own attack numbers (#1 "+15 %", #25) have no layer or op under Modifier System rule 6.
Fix: pick one home. Recommended: effects.md owns the rule text and closing costs, and this GDD keeps only the placement (which cluster holds which Effect, the `meridian_capabilities.json` mapping), the seal logic and the capability-set contract. Replace rule 17's text column with a pointer and bring #1, #4, #17 and #25 into line.

## Recommended findings

### KMD-04 — recommended — Formulas F stat-weight table and `stat_weights` source; `fill_stats`; road/theme stats vs modifiers.md (Formulas A) and Combat #44
The weight table (line about 1053) and Parameter keys source it from `meridian_tree.json`. The registry moved `stat_power_weights` to modifiers.md on 2026-11-07, and Dependencies says the table "moved there". The values still agree (checked: attack 1.0, khi_huyet 0.6, tam_ma 1.5, dan_doc 1.6, cultivation speed 2.2, breakthrough 5, alchemy 2.7), so this is a source-of-truth defect, not a number error.
The allowed stat list (`fill_stats`) and the H4 variant themes still contain none of the #44 keys: `resist_pct` in points (0.04 W per point), `block_rating`, `body_shield_pct`, `health_regen_pct`, `leech_health_pct`, `evade_pct`, `status_resist_pct`. The sustain decision ("sustain is king", many sources) needs tree nodes that pay them.
Fix: make Formulas F read the Modifier prices (delete the table or label it a copy with a lint); state which of the new keys fills, roads, clusters and variant themes may use, with the same pricing rule (price = modifiers.md).

### KMD-05 — recommended — Formulas F (the line beginning "The tree's `herb_growth_pct`, `alchemy_success` and `lifespan_years` also count toward…"), rule 20 Content, G/H4 "Ceiling keys", AC-KMD-59 area, Open Question 14 vs character-stats rule 14
Character Stats rule 14 replaced the three character-wide ceilings with log curves (user decision 2026-11-10, "no caps"): herb growth and the lifespan bonus follow k·ln(1+Σ⁺/k), and `alchemy_success` dampens failure. This GDD still says these keys "count toward the character-wide bonus ceilings", that a fill "can add value the sheet later clamps", and excludes them from roads and sectors as "ceiling keys" and "no stat under a character-wide ceiling". The tree's own `tree_breakthrough_cap` (8 pp) and the q-extras ceiling remain real caps and need no change.
Open Question 14 (tree-wide ceiling on `lifespan_years`) should be re-asked against the curve.
Fix: reword to "curve keys" and say a fill's value is priced at full W before the curve; keep the exclusion only if the reason (they feed breakthrough odds through pill supply) still holds under the curve, which Character Stats says Realms must re-check.

### KMD-06 — recommended — Rule 4, rule 20 (Value), Formulas A2/H3, AC-KMD-07/73 vs linh-can rule 8/8a
Linh-can now says purity scaling has no cap, so factors above ×1.5 are possible, and purity powers element stacks (rule 8a, Effects rule 9a). The GDD states the scale as 0.5 + purity/100 and tests it at purity 60 and 100 only. It does not say what a purity above 100 does to cluster and sector values, or whether purity gained from roads feeds back into the scale of that element's clusters (a loop: road gives purity, purity raises cluster value, which feeds back). Its budgets (about 90–125 W by the end of Qi Refining, sector +71 W at purity 100, H3 up to +25 % at Qi Refining) assume purity ≤ 100.
Fix: state the rule for purity above 100 and the loop (recommended: scale uses purity from root plus rare sources, and the roads' share is small enough that a bot run shows no runaway); add one criterion for purity 130 and one for road-granted purity on an absent element (no scale gain: linh-can says it powers stacks only).

### KMD-07 — recommended — Summary, Overview, rule 20 table, Formulas H2–H4/G9, registry `variant_sector_value`, Open Question 17 vs linh-can (Blood and Void archived 2026-11-09)
The Summary and rule 20 still count eight variant sectors (240 acupoints). Rule 20 notes Blood and Void are archived and "stay locked", which settles linh-can Open Question 13 only in passing. The Qi Refining power figure (+25 % for about 4.3 % of lives) was computed with the innate Blood and Void share, which is now 0, so the rare-root claim and the AC-KMD-89 arms need a re-count.
Fix: say "six live, two archived (240 reserved, 180 live)" consistently, and recompute the 4.3 % figure (Wind only). See D3.

### KMD-08 — recommended — Rule 5 (NPCs), Computational budget, Formulas G vs the Way (dao.md Formulas D3) and Combat sustain
NPC allocation scores "by kind and sector focus". With stack-purity builds and sustain nodes the scoring has no notion of a build, so NPCs will not take them on purpose. dao.md Open Question 5 already asks for a joint bot run on the NPC uplift (clusters plus Daos); this GDD's AC-KMD-49 bounds the cluster uplift alone and still allows about +25 % Qi Refining tree power.
Fix: add a combined criterion with the Way's uplift (the two together must stay inside the NPC targets) and name the allocator weight for road purity.

### KMD-09 — recommended — Dependencies preamble and table rows
"The other systems below have none yet, so their interfaces are provisional" is partly stale: Item Database, Quests, Thiên Kiếp, Combat, Effects and Modifiers now have GDDs. The Item Database and Quests rows should name the real contract (Meridian Seal key item, tree points paid by a quest). Row 39 puts the Way under "soft upstream", although the Way both reads the points total and writes back its spent count (it is a peer, as dao.md says), so Dependencies should say "shared pool, two-way".
Fix: rewrite the preamble and relabel row 39.

### KMD-10 — recommended — Dependencies "Combat sub-systems" bullets and Interactions table
Modifier System, Effects System, Combat Defence & Healing and Combat Damage Types appear only as two footnote bullets. They are real dependencies: node stats are Modifiers (scope, op layer), keystones are Effects, and damage-type resistance is in points. Add rows to the Interactions table and to Downstream/Upstream, with what each gives or takes.

### KMD-11 — recommended — UI Requirements, "Drawing the map" vs the new kit
The drawing rules (46-unit step, 15-unit clearance, `tools/meridian-map/` reports them) belong to the old viewer. The redrawn tree uses `tools/design/meridian_rework/` with its own checks (0 crossings, nodes not closer than 0.6, no link grazing a node, every cluster reachable by a bypass; `meridian-land-authoring.md`). One set must be the standard.
Fix: either point to the authoring guide and kit checks as the rule, or keep the old rules and say the old viewer applies to the old map only (follows D1).

### KMD-12 — recommended — Known gaps in the build / Open Questions 4, 5, 9, 14 carry-over
The 2026-11-05 review's fixes were never re-reviewed and four Open Questions stay open (4, 5, 9, 14). Several of its listed minor items no longer match the text (the "5.03 years" and "None of the systems below has a GDD yet" strings are gone, so those were applied; I did not re-verify the rest individually). The build described under Known gaps is the 2026-11-05 build and predates the debug-terminal work, so the table's claims cannot be trusted.
Fix: after D1, regenerate the Known gaps table from the current build or delete it.

## Minor findings
### KMD-13 — minor — AC-KMD-07/50/89
These bot-judged criteria are guesses until the bot runs ("needs a new bot run"). They are testable in form, but mark them pending explicitly while D1 is open so they do not read as passing.
### KMD-14 — minor — Header
`Status: In Review (2026-11-05 …)`, `Last Updated: 2026-11-05` and the stray "map density revision … awaiting a fresh /design-review" fragment. The rule 1 redraw row is dated 2026-11-10 and the Redesign banner is 2026-11-07, so Last Updated is stale. The header sentence about "Approved 2026-11-04 lean re-review" is history and could move to the review log.
### KMD-15 — minor — Rule 1 row, Summary
Summary still says "about 1,300 acupoints", "25 capabilities", "eight variant roots", and "one fixed map" with no mention of the redraw. Update together with D1.
### KMD-16 — minor — Hán-Việt
Per the project terminology memory, some English-only terms (for example "sector", "gate", "ring road", "keystone") have no Hán-Việt annotation at first use. Low priority.

## Decisions for the user

- **D1** — Adopt the hand-drawn tree (`meridian-tree-overnight.md`) as the map this GDD specifies? Recommend **yes, the lean build (about 6,300 visible), as the overnight note recommends**, then rewrite rule 1 and Formulas C/G/H from its output. Alternatives: the full 8,672 build; or keep the old 1,300-acupoint generator and drop the redraw (then remove the rule 1 row).
- **D2** — Do an element land's roads pay purity only, as the redraw row says? Recommend **yes, a small purity (about 0.5 per road node, priced about 0.1–0.2 W, tuned by a bot run) plus nothing else, so purity above 100 stays rare**. Alternatives: purity plus a small generic stat; or revert to generic exact roads and move purity to other sources (Linh Căn Quả, items, Đạo).
- **D3** — What happens to the Blood and Void sectors? Recommend **keep them in the data, locked, but remove them from the counts and calibration (six live sectors, 180 acupoints)**. Alternatives: delete them from the tree now; or keep full counts and revive them later.
- **D4** — Who owns capability rule text? Recommend **effects.md owns the rule and closing cost; this GDD owns placement, seals and the capability set**. Alternatives: keep full text here and make effects.md point to it; or turn all 25 into Effects and drop "capability" as a term.
- **D5** — Which #44 keys may the tree pay (resistance points, block, body shield, regeneration, leech, evade)? Recommend **allow all but `leech_health_pct` and `bonus_ward_slots` (rare, sustain exception), at modifiers.md prices**. Alternatives: only on clusters and keystones, not roads; or none until the Effects keystones are placed.
- **D6** — Should the tree keep `tree_breakthrough_cap` at 8 pp now that the other three bonus ceilings became curves? Recommend **keep it** (it guards the tree's direct share only; the q-extras ceiling is Realms'). Alternative: turn it into a curve too, for consistency.

## Mechanical fixes (one sweep)
1. Header: Status, Last Updated and Last Verified dates; remove the half sentence "map density revision … awaiting a fresh /design-review".
2. Dependencies preamble: replace "The other systems below have none yet" with the real list of missing GDDs (Event Engine, Save/Load, World Database, LLM Game Master, Progression Edges, Time & Turn and the other hosts).
3. Dependencies row 39: relabel from soft upstream to a two-way shared pool.
4. Formulas F: change "ceilings … clamps" wording for `herb_growth_pct`, `alchemy_success`, `lifespan_years` to "curves" (KMD-05); change the weight table source to modifiers.md.
5. Rule 20 Content and AC at "no stat under a character-wide ceiling": reword to "curve key".
6. Summary: variant sector count (six live, two archived) and capability count wording.
7. Interactions and Dependencies tables: add Modifier System, Effects System, Combat Defence & Healing and Combat Damage Types rows (KMD-10).
8. UI Requirements: fix the viewer path or add the new kit (KMD-11).
9. Mark AC-KMD-07/50/89 "pending bot run" until the calibration is rerun.

## Not checked (limits of this lean review)
Formulas H–H4 and the topology generator (Formulas, about 1,300 lines) and AC-KMD-60–95 were read only for the parts that touch the changed dependencies; I did not re-derive their arithmetic. Capability #4 and the other ids not in effects.md were not compared line by line. No specialist agents were used (lean mode).
