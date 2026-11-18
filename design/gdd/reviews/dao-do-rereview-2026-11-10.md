# Confirming re-review: Meridian Map (Kinh Mạch Đồ) — 2026-11-10

Review mode: lean (single session, no specialists) · Workflow: standard · Report only: no GDD, registry or code was edited.
Re-review: Yes. Prior verdict MAJOR REVISION NEEDED (`kinh-mach-do-review-2026-11-10.md`); its answers D1–D6 were applied and committed.
Scope signal: XL (about 1,140 lines after the rewrite, 11 dependencies, 4 formula families, 34 live acceptance criteria).
The drawn map is a shape placeholder (header); measured counts and distances are treated as placeholder data.

## Verdict: NEEDS REVISION

The rewrite is faithful to the user's answers and its arithmetic holds. One blocking gap remains: the capability catalogue
points to `effects.md` records that mostly do not exist. Three questions need the user, and the rest is cross-document
tidy-up (registry notes, other GDDs' stale references).

## (a) Were the recorded answers and fixes applied correctly?

| Answer | Present and correct? |
|---|---|
| D1 adopt the drawn tree, scrap hidden clusters and old generator | Yes (rules 1, 6–15, 21; Formulas C/D/G/H2–H4 retired). |
| D2 element-land roads grant purity only, ~0.5/node, blend half, hub generic | Yes (rule 4, A2, AC-KMD-06/97, registry `road_purity`, `purity_price`). R0 = 0.5 × 0.3 = 0.15 W ✓. |
| D3 Blood and Void locked and uncounted | Yes (rule 20, Edge Cases). |
| D4 effects.md owns capability text | Direction applied, but see KMD-R01: the records are not there yet. |
| D5 #44 keys allowed except `leech_health_pct`, `bonus_ward_slots` | Yes (rule 4, Formulas F, AC-KMD-06). |
| D6 breakthrough clamp becomes a curve | Yes. 8/16/32 pp → 5.55/8.79/12.88 pp ✓ (8·ln2, 8·ln3, 8·ln5); example 16 pp → 8.8 ✓; matches canh-gioi, character-stats, dao and the registry (`tree_breakthrough_k` 8). |
| Shadow Shrine kept; variants follow the drawing; player picks a start; NPC takes its strongest; fresh id baseline with one-time refund | Yes (rules 1, 3, 19, 20; AC-KMD-96, 98). Tie-break order matches linh-can. |

Numbers re-derived and correct: the points ladder and all 15 totals in AC-KMD-01/02/03/56; stage thresholds (CF 54/67,
NS 87/94, DT 104/107); piece sum 11 + 616 + 5,364 + 1,084 + 40 = 7,115; regions 4,379 + 1,906 + 729 + 101 = 7,115;
w̄_map = 15,201 / 7,064 = 2.152 W; AC-KMD-15 multipliers (1.10, 1.50, 1.90, 0.675, 1.00); the capability host list covers
all 25 once; E2 examples unchanged.
All earlier mechanical fixes (header dates, Dependencies preamble, Interactions rows for Modifiers, Effects and Combat, UI
viewer path, "curve" wording) are in.

## Blocking

### KMD-R01 — blocking — Rule 16, rule 17 table, AC-KMD-41, Formulas E2 vs effects.md
Rule 17 replaced every capability's rule text with "effects.md record", and AC-KMD-41 requires "each with an
effects.md record". effects.md has records for only six (#5, #9, #11, #15, #17, #25). It says about 12 more "close
nothing" and will become rule-change Effects whose "place in the tree is decided at the tree rework", and about 7 are
unsettled (effects.md lines 466–481, Open Question 4). #1–#4, #22 and #23 and most others have no record. So after
this rewrite 19 of 25 capabilities have a name and a host and no rule text in any GDD, and AC-KMD-41 cannot pass.
Formulas E2 still holds the #22 and #23 rules here (and canh-gioi Formulas H), so "effects.md owns the text" is also
untrue for them.
Fix: see decision D-R1. Whichever is chosen, AC-KMD-41 must say which records are required now.

## Recommended

### KMD-R02 — recommended — Edge Cases ("walks the roads of an element its root lacks"), rule 4, AC-KMD-15/97 vs linh-can rule 8a
The edge case says road purity in an absent element "powers its stacks only". Linh-can lines 219–222 and rule 4 say it
counts everywhere, including land scaling. So two road nodes in Metal (purity 1.0) lift every Metal-land acupoint from
×0.25 to ×0.51, doubling their value, for 2 points. No criterion tests a small purity in an absent element
(AC-KMD-15 tests only absent = ×0.25, AC-KMD-97 tests only the purity amount).
Fix: reword the edge case ("powers stacks and scales the land, adds no base element"), add one AC (absent element
plus 2 road nodes → ×0.51), and decide D-R2.

### KMD-R03 — recommended — A2, Dependencies row 31 (Quests), registry `w_target` vs quests.md, dao.md, modifiers.md
A2 now calls 2.15 W "a data lint, not a power target" and 2.07 "the generated map's target". Dependencies row 31
still says Quests takes `w̄_target`; modifiers.md line 1046 reads "w̄_target 2.07"; the registry `w_target` 2.07 (note
cites "A2: 7.55 / 3.64", gone) is what the Way prices Dao nodes against and Quests' `tree_point_w` copies. Nothing in
this GDD now owns that target. See D-R3.

### KMD-R04 — recommended — Rule 5, Computational budget, Open Question 8, AC (none) vs dao.md OQ 5
The review's KMD-08 was not carried through. Rule 5 scores "kind × focus × purity multiplier" but does not name a weight
for road purity, so NPCs will not walk roads on purpose, and the stack power that road purity buys NPCs
(an unbounded source) has no bound. AC-KMD-49 (the NPC uplift bound) was retired with no replacement, and Open Question 8
mentions the Way's breakthrough Effects but not the joint tree-plus-Dao NPC uplift that dao.md Open Question 5 asks for.
Fix: add an allocator weight key for road nodes (`tree_kind_scores` entry), one criterion or Open Question for the joint
NPC uplift with the Way (inside the NPC targets), and state NPC road purity is included in AC-KMD-101.

### KMD-R05 — recommended — Registry entries owned by kinh-mach-do (report only; registry not edited)
Values are right, notes are stale: `visible_huyet_count` note still describes "430 kinh lộ, 65 visible clusters … 11
keystones"; `capability_count` note "sealed outer clusters with n ≥ 7"; `keystone_min_power` note about cluster
huyệt caps (21/25.8 W); `w_target` note (KMD-R03). (`cluster_fill_budget` is already deprecated.) Apply in the registry sweep.

### KMD-R06 — recommended — Other GDDs still citing retired Meridian rules (listed as "left for other GDDs' turns")
- cong-phap.md: rule 15 interim sector rule, `seal_clusters`, lines 310/841/976/1482 still depend on this GDD's retired
  rule 7 and `cong_phap_seasons`; this GDD's Dependencies drop that link, so the bidirectional rule is broken.
- character-stats.md lines 978 and 1236: "the tree cap", "the 9.5 → 8 clamp".
- linh-can.md lines 1058, 1081, 1442–1443, 1451: variant sector wording and Open Questions 4, 5, 13 (13 can now close: Blood and Void stay locked and uncounted).
- effects.md lines 679, 855: "Redesign planned"; Open Question 4 still waits on placement (feeds KMD-R01).
No change needed here; each owner updates its own file.

## Minor

- **KMD-R07** — AC-KMD-50 and E2 ("Formulas F, plot price") cite a plot price Formulas F no longer has; the Acceptance Criteria preamble says "AC-KMD-07, -50 and -89's successors" though AC-KMD-89 is retired (the live bot items are 07, 50, 101).
- **KMD-R08** — Formulas H blend row labels the 377-point zone "Water–Fire"; the five neighbour pairs (kit modules `blend_fe/em/mw/ww/wf`) are Fire–Earth, Earth–Metal, Metal–Water, Wood–Water, Wood–Fire. Should read "Wood–Fire".
- **KMD-R09** — Rule 5 ("a sector favoured by the NPC's archetype") and AC-KMD-18 ("any other sector") use the retired term; say "land" or "region".
- **KMD-R10** — The user's D1 answer says lean ≈ 6,300 visible; the overnight note gives 6,403 for the lean variant, plus 77 hidden clusters (~700 acupoints). 7,115 is about that sum. Confirm the build really drops the hidden band (rule 1) when the map is next re-measured; placeholder, so not a finding against the rules.
- **KMD-R11** — Terminology (project memory): Taiji hub, blend zone, keystone, ring/road have no Hán-Việt annotation at first use.
- **KMD-R12** — Header Status still says "Major revision in progress … sections not yet rewritten still describe the old generated map". Every section is rewritten; set Status to In Review and update the systems-index row (not done here).

## Decisions for the user

- **D-R1** — The 19 capabilities with no `effects.md` record: where does their rule text live until the records exist? Recommend **restore each capability's one-line rule and closing cost from the 2026-11-05 text (git history) into rule 17, marked provisional, and relax AC-KMD-41 to "records for those that exist"**. Alternatives: write all 19 records in effects.md now (large, owned by effects); keep rule 17 as is and mark capabilities not implementable until their records land.
- **D-R2** — Should road purity in an element the root lacks lift the ×0.25 absent-element floor on that land? Recommend **keep it as linh-can decided (it counts), but let the multiplier floor stay 0.25 until the root owns the element or purity reaches 10**, so two road nodes are not a free doubling. Alternatives: accept the cliff as designed; or have road purity in an unowned element power stacks only, as the edge case now says (then change linh-can 219–222).
- **D-R3** — Who owns the per-point target the Way and Quests price against? Recommend **keep `w_target` 2.07 as a named target in A2 and keep 2.15 as a lint inside ±5 %**. Alternatives: move the target to 2.15 and update dao.md, quests.md, modifiers.md and the registry; or give the Way and Quests their own target.

## Mechanical fixes (one sweep)

1. Edge Cases: reword the absent-element road-purity case (after D-R2); add the AC from KMD-R02.
2. Dependencies row 31: replace `w̄_target` with the name chosen in D-R3.
3. AC preamble and AC-KMD-50 / E2: drop the "plot price" and "AC-KMD-89" references (KMD-R07).
4. Formulas H blend row: "Water–Fire" → "Wood–Fire".
5. Rule 5, AC-KMD-18: "sector" → "land".
6. Header: Status → In Review; Hán-Việt at first use (Thái Cực hub etc.).
7. Registry sweep: notes of `visible_huyet_count`, `capability_count`, `keystone_min_power`, `w_target`.
8. Other GDDs (KMD-R06): each owner updates its stale lines.

## Not checked

Formulas E2's arithmetic was not re-derived beyond AC-KMD-44's headline values (unchanged by this revision). The drawn
map's counts, distances and `tree.json` were not re-measured (placeholder). No specialist agents (lean mode). I did not
open `quests.md` or `combat.md` line by line; the Quests row was judged from the registry and modifiers.md.

## User answers and applied fixes (2026-11-10, same session)

- D-R1: the 19 capabilities without an effects.md record carry their 2026-11-05 one-line rule in rule 17, marked provisional (#2 now reads `artifact_slots` +1); AC-KMD-41 asks for records only for #5, #9, #11, #15, #17, #25.
- D-R2: an unowned element's or variant's land scales by 0.25 + purity ÷ 100 (rule 4, Edge Cases, AC-KMD-15).
- D-R3: `w_target` 2.07 stays the target this GDD owns; 2.15 is a lint within ±5 % (A2, Dependencies row 31, registry).
- Applied: KMD-R04 (road score key, OQ 8 joint uplift), KMD-R05 (registry notes), KMD-R06 for cong-phap.md, character-stats.md and linh-can.md (effects.md lines left), KMD-R07 to KMD-R09, KMD-R11 (Thái Cực only), KMD-R12 (status).
