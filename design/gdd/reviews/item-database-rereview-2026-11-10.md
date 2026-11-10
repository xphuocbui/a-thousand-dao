# Confirming re-review: Item Database & Generation — 2026-11-10

Report only. Nothing was edited except this file and the review log. Mode: lean (no specialists) · Workflow: standard · Scope signal: L (producer should verify).
Re-review: yes. The prior verdict was NEEDS REVISION on 2026-11-10 (3 blocking, 10 recommended). Answers D1–D7 were given and fixes applied the same day.

## Verdict: NEEDS REVISION (no blocking items; 8 recommended, 5 minor, 2 decisions)

All three earlier blockers are fixed correctly. No new contradiction against the registry or the same-day GDDs breaks the design. The verdict is NEEDS REVISION and not APPROVED because the fixes left stale text of their own: two places still say a pre-D2 slot cap, the retired Mạch Ấn is still asserted in the shipped-data criteria, and `artifact_slots` and "capability #2" point at things the neighbouring GDDs do not define. Each is a small edit, and none needs a redesign. After the sweep and the two decisions below, I expect APPROVED.

Completeness: 5/5 required sections present (Overview, Detailed Design, Edge Cases, Dependencies, Acceptance Criteria), plus Formulas (required, numeric system). Player Fantasy and Tuning Knobs present (advisory).
Dependency graph: every GDD named exists on disk.
Registry values: no numeric conflict. `equip_max_slots` 6 matches AC-ID-41 (6 then 7 with +1). `default_role` output_range now reads "weapon, ward_gear, body_gear, utility". The alias notes for `potency_per_doubling` and `equip_max_slots` are present.

## (a) Recorded answers and fixes: verified

| Item | Where | Result |
|---|---|---|
| ID-01 / body gear mapping | Rule 6 (l.103-107), Dependencies bullet (l.560), Cross-ref row (l.623) | Correct. Matches combat-defence Formulas A0 (`a_w` non-body, `a_b` body_gear), A2 (`gear_block = 12` per a, `min(a_w, 1) + a_b`) and B (0.60 per `a_b`). Body guard and Open Question 10 are gone. |
| ID-02 / D1 | Rule 20, AC-ID-85, Interactions row (l.221) | Present. Agrees with Modifiers rule 13 (named items may carry rare modifiers) and Effects (hosts). |
| ID-03 / FX-L, AC-ID-62 | l.643, l.747 | Re-derived. k = 0.15 × 120 = 18 (character-stats Formulas I: f_life 0.15, L_realm 120). 18·ln(1 + 5/18) = 4.412, so the cap is 124.41; age 121 is above the base 120 and below 124.41. 18·ln(1 + 15/18) = 10.91. Both correct. |
| ID-04 / D3 | Rule 12 (l.142), AC-ID-34 (l.698) | Present. Matches linh-can (never refused, +8 past 100; Tẩy Tủy Đan still refused when all owned ≥ 100). linh-can's earlier self-contradiction is gone. |
| ID-05 / D4 | Formulas F "Reward bounds" (l.404-410), AC-ID-86 | Present, but see ID-R06 (wording). |
| ID-06 / D2 | Rule 11, Interactions row, AC-ID-41 | Present, but see ID-R01, ID-R02, ID-R03. |
| ID-07 / D6 | Rule 19 (l.178-181), AC-ID-85 | Lint present. The affix pool itself is still not specified: see ID-R07. |
| ID-08 / D5 | Rule 6, Formulas D variable `damage_type`, Interactions rows | Present. No acceptance criterion: see ID-R09. |
| ID-09 | Interactions table rows for #21a, #21b, #40, #41, #39 | Present in Interactions. The Dependencies tables were not given them: see ID-R05. |
| ID-13, ID-14, ID-15, ID-16, ID-17 | Registry, AC-ID-70 (a_w 0.35, a_b 0.30, 10.5 = 100 · 0.30 · 0.35; Kỳ gives 0.50), AC-ID-26, header, systems-index row #13 (In Review) | All correct. |
| ID-10 | Rule 3 and kinh-mach-do (item 13 retired; capability text now in effects.md) | Resolved by retiring Mạch Ấn. kinh-mach-do and Item DB agree. |

## Findings

### Recommended

**ID-R01 [recommended] "Meridian capability #2" no longer exists as a slot source.**
Locations: rule 11 (l.131-132), Cross-ref row l.624, Edge Cases l.512, AC-ID-41, AC-ID-43.
Wrong: kinh-mach-do now says capability rule text lives in `effects.md`, and neither file contains an equip-slot or artifact-slot capability. The only mention left is the Modifiers row 362 ("capability #2 today"). A test fixture "capability #2 removed" (AC-ID-43) has nothing to remove.
Fix: name the real sources only (Kim Đạo's Binh Khố facet, keystones, named items, quest rewards, Way capstones: Modifiers lines 674 and 678). Mention capability #2 only if the user confirms it will be authored in `effects.md`. Reword AC-ID-43 and Edge Cases l.512 to "an `artifact_slots` source is removed".

**ID-R02 [recommended] `artifact_slots` is called "a Character Stats key" but Character Stats does not define it.**
Locations: rule 11 (l.131), Interactions row l.222, registry note (l.3032).
Wrong: no `artifact_slots` key exists in character-stats.md. Modifiers rows 362 and 678 list "Artifact slots" with stat key "—", state Pending, owner "Item DB", price 25 W, rare. Rule 11 now fixes the name but neither neighbour has it. See decision D-1.

**ID-R03 [recommended] Two places still state the pre-D2 slot cap.**
Locations: Edge Cases l.510 ("If equipping would pass `equip.max_slots`: it is refused"), Tuning Knobs l.578 (`equip.max_slots` only).
Wrong: rule 11 and AC-ID-41 say `equip.max_slots` + `artifact_slots`. As written, edge case l.510 refuses a 7th piece even when `artifact_slots` is +1.
Fix: "…would pass `equip.max_slots` + `artifact_slots`". Add `artifact_slots` (25 W per slot in the Modifier catalogue, rare) to Tuning Knobs under "How many pieces a build wears".

**ID-R04 [recommended] The retired Mạch Ấn is still asserted as shipped data.**
Locations: Formulas A table row 4 (l.285); AC-ID-02, AC-ID-05 (l.654), AC-ID-22 (l.677), AC-ID-29, AC-ID-58, AC-ID-78 (all "Given FX-D" or no fixture); rule 12 (l.138-139: "a seal through the Meridian Map", "A Meridian capability may keep a talisman"); Open Question 16 text ("opens the nearest sealed cluster").
Wrong: rule 3 says generation never makes Mạch Ấn and its template has nothing to open. FX-K says "every criterion that names Mạch Ấn uses FX-K", but AC-ID-02, 05 and 22 explicitly say "Given FX-D" while naming Mạch Ấn at rarity 4 and value 800. The tests would contradict one another if FX-D no longer ships the item. The rule-12 phrases name a Meridian Map interface that was retired.
Fix: if the template stays in shipped data (so old saves load), say so once in rule 3 and keep the criteria; otherwise change AC-ID-02, 05, 22 and 78 to FX-K and drop the Formulas A row. Delete "a seal through the Meridian Map" and the "Meridian capability may keep a talisman" clause from rule 12 (or point the latter at effects.md). Strike Open Question 16's closing text. See decision D-2.

**ID-R05 [recommended] The Dependencies tables lack the revised neighbours.**
Location: Dependencies tables (l.526-548).
Wrong: the Interactions table has rows for Combat Defence, Damage Types, Modifier System, Effects and the Way. The Upstream and Downstream tables have none, and the Way is not mentioned in the Bidirectional-check paragraph, although dao.md row 677 lists Item DB. Modifier System (rare modifiers on named items, affix catalogue) and Effects (named-item hosts) are upstream/soft, the rest downstream.
Fix: add one row each with type and state (Modifier #40 and Effects #41 "approved"; Combat Damage Types "in review"), and add the Way to the bidirectional paragraph.

**ID-R06 [recommended] The reward-bound wording for the Legendary exception is ambiguous.**
Locations: Formulas F l.404-410, AC-ID-86.
Wrong: "one rank above the realm cap" can mean the ladder cap (3 / 4 / 5 / 5 / 5) or a kind's own cap (the same minus `kind_offset`). Quests rule 14 means the ladder: the bonus "reaches `rarity_max` 6 from Core Formation". Also, "the lint passes it by name" does not say which field marks the item as the Legendary quest's one item, and pills, talismans and treasures have no rarity cap to exceed.
Fix: write "one ladder rank above `realm_rarity_cap[realm]`, applied to the kinds that have a cap". Name the field the quest record sets (for example `legendary_reward: true`). Add one number to AC-ID-86: Core Formation, cap 5, passes at 6, fails at 7; Qi Refining, cap 3, passes at 4, fails at 5.

**ID-R07 [recommended] The affix pool is still unspecified against the lint.**
Locations: Formulas D (l.363-366: "the 9 in the pool"), rule 19.
Wrong: rule 19 now checks affix keys against the catalogue, bars rare modifiers and bars Chaos resistance, and says "resistance affixes are counted in points". Formulas D names no pool, no resistance affix and no catalogue keys, so rule 19 has nothing concrete to check. Combat Defence expects Black Iron Armour to carry a Physical-resistance affix, and Combat Damage Types OQ 3 is waiting on this content rule to close.
Fix: list the 9 affixes (or the data file) with their catalogue keys, add the Physical resistance affix in points (range from Modifiers), then tell Combat Damage Types that its OQ 3 is closed from this side.

**ID-R08 [recommended] Items carried from the first review are still open (not new).**
ID-11 (Open Question 7, timed-pill timer owner; Thiên Kiếp l.135 relies on them), ID-12 (Formulas H has no measure; OQ 14 blocks AC-ID-71 to 77; no per-tick performance target at 200,000 records). The review log carries both since 2026-11-06.
Fix: give OQ 7 and OQ 14 each an owner-and-date line, or mark rule 12's "timed pill effects" deferred. They do not need to be solved before approval.

**ID-R09 [recommended] The damage-type decision (D5) has no acceptance criterion and no migration note.**
Locations: Formulas D (`damage_type`), Build Gaps migration note (l.253-254), Acceptance Criteria.
Wrong: rolled artifacts are "stored whole" (rule 2), so every existing record lacks `damage_type`. The migration note covers `bound` and `value` only. No criterion tests the default or the "any type but Soul" restriction.
Fix: add `damage_type` default Physical to the version-3 migration, and one Logic criterion: a base with no `damage_type` reads Physical; Soul on an artifact base fails the lint.

### Minor

- **ID-R10** Formulas D: "any Combat Damage Types type but Soul" has no source. Cite the Damage Types rule that excludes it, or drop the exclusion.
- **ID-R11** AC-ID-85 and AC-ID-86 sit before AC-ID-81 (the same disorder as AC-ID-84 before 83). Move them, and put the Open Questions in order 1–16. (ID-18 left open by the user.)
- **ID-R12** AC-ID-85 holds five checks in one criterion (the four lint faults and the named-template pass). Split it so each fault is its own pass or fail.
- **ID-R13** The Build Gaps table has no rows for rules 19 (new lint checks), 20 (named items) or 11's `artifact_slots`, so the build scope is understated.
- **ID-R14** Header l.3 still says "re-review pending". Update it to the re-review's verdict when the sweep is applied.

## Decisions for the user

- **D-1 (ID-R02)** Who defines the `artifact_slots` key? Recommended: Item DB defines it in rule 11 as the Modifier stat key (25 W, rare, Modifiers row 362), and Modifiers row 362 and Character Stats rule 15 adopt it (edits in those GDDs, in the user's session); reword rule 11 to "an Item Database stat key, read by Character Stats". Alternatives: a Character Stats key as written (then Character Stats must add it first); or reuse `bonus_slots` (rejected: it is Combat's art slots).
- **D-2 (ID-R04)** Does the Mạch Ấn template stay in shipped data? Recommended: keep it only as an old-save loader (rule 3 already says old saves keep it), remove it from FX-D and the Formulas A table, and point AC-ID-02/05/22/29/58/78 at FX-K. Alternative: keep it in shipped data (as an unobtainable item) and leave the criteria as they are.

## Mechanical fixes (one sweep)

1. Edge Cases l.510: "pass `equip.max_slots` + `artifact_slots`" (ID-R03).
2. Tuning Knobs l.578: add `artifact_slots` (ID-R03).
3. Rule 12 l.138-139: delete "a seal through the Meridian Map" and "A Meridian capability may keep a talisman" (ID-R04).
4. Open Question 16: strike the closing sentence about the nearest sealed cluster (ID-R04).
5. Rule 11, Cross-ref row l.624, Edge Cases l.512, AC-ID-41 and 43: drop "capability #2" or replace it with the sources in Modifiers lines 674 and 678 (ID-R01).
6. Dependencies tables: add rows for Modifier #40, Effects #41, Combat Defence #21a, Combat Damage Types #21b and the Way #39; add the Way to the Bidirectional-check paragraph (ID-R05).
7. Formulas F and AC-ID-86: "ladder rank above `realm_rarity_cap`" with the two numeric cases and the field name (ID-R06).
8. Build Gaps: add rows for rules 11, 19, 20 and the `damage_type` migration (ID-R09, ID-R13).
9. Ordering: AC-ID-85 and 86 after 84; Open Questions 8 to 10 before 11; split AC-ID-85 (ID-R11, ID-R12).
10. Header l.3: update the status after this review (ID-R14).

## User answers and applied fixes (2026-11-10, same session)

- D-1: `artifact_slots` is already a Character Stats key (character-stats.md line 262, rule 15); wording points there.
- D-2: the Mạch Ấn template stays only for old saves; FX-D criteria moved to FX-K; Formulas A row and AC-ID-05 cleared.
- Capability #2 returns as a provisional one-liner in Meridian rule 17 (Meridian re-review D-R1), so ID-R01 keeps it as a source.
- Applied: ID-R01 to ID-R14 (the affix pool listed with a new Thiết Bích Physical-resistance affix, a guess; Combat Damage Types Open Question 3 closed from this side; AC-ID-85 split, AC-ID-87 added; Open Questions in order with owners on 7 and 14).
