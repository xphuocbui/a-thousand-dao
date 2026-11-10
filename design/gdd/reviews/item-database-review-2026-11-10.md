# Design Review: Item Database & Generation — 2026-11-10

Report only. Nothing was edited except this file and the review log. Mode: lean (no specialists) · Workflow: standard · Scope signal: L (producer should verify).
Re-review: yes. The prior verdict was APPROVED on 2026-11-06 (0 blockers, 9 recommended). The GDD itself still reads "Designed (pending review)". Its text is unchanged in substance since 2026-11-08 (D2 rename); the approved GDDs around it changed on 2026-11-09/10.

## Verdict: NEEDS REVISION

The record, ladder, herb, pill and artifact math is sound. I hand-checked the ladder bands, Kim Tủy at age 42 (0.874), Phi Kiếm, Ấn and Giáp at their tiers, the role table and the AC-ID-06 band edges. None needed a fix.
The GDD is behind the Combat economy revision (#44) and the neighbouring revisions. It describes an interface (body guard) that Combat no longer has. It has no rule for the "named item" that Modifiers, Effects and Combat Defence all rely on it to define. Two acceptance criteria now contradict approved GDDs.

Completeness: 5/5 required sections present (Overview, Detailed Design, Edge Cases, Dependencies, Acceptance Criteria), plus Formulas (required, numeric system). Player Fantasy and Tuning Knobs are present (advisory).

Dependency graph: every GDD named in Dependencies or Cross-References exists on disk (character-stats, canh-gioi, cong-phap, kinh-mach-do, combat, combat-defence, combat-damage-types, modifiers, effects, thien-kiep, quests). The "no GDD yet" systems are correctly flagged as built or provisional.

Registry values: 9 item entries owned by this GDD (`item_rarity`, `herb_potency`, `herb_value`, `pill_value`, `artifact_power`, `default_role`, `realm_rarity_cap_by_kind`, plus constants `rarity_max`, `realm_rarity_cap`, `default_rarity_offset`, `pill_band_edges`, `weapon_min`, `ward_max`, `potency_per_doubling`, `max_potency`, `equip_max_slots`). No numeric conflict with the GDD. Registry name drift and one stale output_range are listed below.

Cross-checked against: character-stats (rule 14, Formulas I), combat, combat-defence, combat-damage-types, modifiers, effects, linh-can, dao, kinh-mach-do, quests, thien-kiep, canh-gioi/cong-phap references. The two research notes (`meridian-tree-overnight.md`, `meridian-land-authoring.md`) change nothing in this GDD: the item-sealed cluster and capability #2 are unchanged in kinh-mach-do.

## Blocking

**ID-01 [blocking] Rule 6 (lines 103-104) and Cross-References row "Rule 6, Formulas E" (line 596): the Combat interface is described as it was before #43/#44.**
- Wrong: "a body_gear piece's defence feeds body guard ... (Combat Formulas D)". Body guard is retired (registry deprecations, combat-defence rule 12). `ws`/`we`/`a_w`/`a_b` moved to Combat Defence & Healing Formulas A0. Combat Open Question 10 is closed.
- Missing: combat-defence Open Question 13 and its Formulas B/I cross-reference say Item DB "must adopt the body-gear mapping". That is 0.60 body shield and 12 block per `a_b`, top-end body gear 1.0 × B_p, and gear block from ward gear capped at a = 1. Formulas D/E say nothing about what an artifact's defence is spent on. The "Combat sub-systems" paragraph (line 533) states part of it only as a back-reference.
- Fix: rewrite rule 6's last sentences as "body_gear defence feeds `a_b` (block and body shield), every other piece's defence feeds `a_w` (ward strength, efficiency, block up to a = 1) (Combat Defence & Healing Formulas A0, A2, B)". Retarget the cross-reference row to combat-defence.md Formulas A0 and drop "Open Question 10". Add a short Formulas E note that the Item DB owns only the role tag and the base's defence number; Combat Defence owns the mapping. Close combat-defence OQ 13 from this side.

**ID-02 [blocking] No rule defines a named item, an Effect host record or an artifact's active effect.**
- Modifiers (rule 13, line 251-253, AC-MD-23) allows rare modifiers on "a named item". Effects lists named items as hosts. Combat Defence prices Black Iron Armour as a named body_gear artifact. Combat Damage Types lists "an item's active art". Every one points at Item DB, and this GDD's only mention is the back-reference bullets at lines 534-537.
- Rules 1-3 give kinds and categories but no `named` template, no `effects` or `modifiers` fields on a record, and no statement of whether they are read through the template (follow data) or stored whole (rule 2). Nothing says a rolled artifact never carries a rare modifier or an Effect. Rule 19's lint has no check for it.
- Fix: add a rule. A named item is an authored template (artifact or treasure) that lists its `effects` and `modifiers`, read through the template. Generation never rolls one. Lint rejects a rare modifier on a rolled affix. Add the Interactions row and an AC. See Decision D1.

**ID-03 [blocking] AC-ID-62 and the FX-L fixture (AC-ID-45 to 47, 80) assume a flat lifespan bonus.**
- Character Stats rule 14 / Formulas I (user decision 2026-11-10, "no caps") replaced the ceiling with `B_life = k_life · ln(1 + (pill_years + Σ⁺ lifespan_years)/k_life) + Σ⁻`, `k_life = f_life · L_realm`.
- AC-ID-62 says a quality-0 Diên Thọ Đan raises the lifespan bonus "by 15.0". That is only the raw pill years. The bonus is now the curve of 15, which is less than 15, and it depends on the realm.
- FX-L ("+5 `lifespan_years` ... age is the cap without it + 1") and the "new cap" line in AC-ID-45 assume +5 years. The curve gives less than +5, and the result depends on the realm's k. The fixture states no realm. The test could pass or fail depending on what the fixture happens to use.
- Rule 12's wording ("asks Character Stats for the resulting cap") is fine. The fixtures are not.
- Fix: give FX-L a realm and `L_realm`, compute the expected cap through Formulas I, and set the age to that cap + 1. Rewrite AC-ID-62 as "the lifespan bonus equals Formulas I's value for 15 pill years" with the number for a named realm.

## Recommended

**ID-04 [recommended] Rule 12 and AC-ID-34: "Linh Căn Quả with all five elements at 100" is refused.**
Linh Căn Quả is now allowed past 100: linh-can rule 8a and Formulas D ("no cap since 2026-11-10") add +8 past 100. linh-can's own rule 13 (line 299) still says "with all five at 100 it is refused and kept", so linh-can contradicts itself. Item DB mirrors the old line in rule 12 ("refused at full purity") and in AC-ID-34. The Tẩy Tủy Đan half of AC-ID-34 is still right (capped at 100 by linh-can Formulas D2). Decision D3.

**ID-05 [recommended] Reward bounds are used by Quests and Thiên Kiếp but not defined.**
- Quests rule 14 / registry `legendary_rarity_bonus` allow one above-cap item per Legendary quest. Quests OQ 8 and Cross-References say Item DB's Formulas F "must name the Legendary exception". Formulas F and AC-ID-16 clamp any request above the realm cap and log it. They never mention the exception.
- Thiên Kiếp rule 9 and AC-TK-78 reject a boss `reward` "outside the Item Database's bounds". Item DB defines budgets for events only (rarity cap, `pill_price_max`, `herb_age_max`, `linh_thach_max`, whitelist). "Pills, talismans and treasures have no rarity cap" leaves no bound to check for them except price.
- Fix: add a short "Reward bounds" paragraph to Formulas F. It states what a bound is per kind, how the Legendary exception passes it, and that the lint (not the generator clamp) applies it for quests and bosses. Decision D4.

**ID-06 [recommended] Rule 11 and AC-ID-41 name only Meridian capability #2 as the source of extra slots.**
Modifiers line 362 lists an "Artifact slots" modifier (Item DB owner, Pending) and its `bonus_slots` row. Dao Kim Đạo (Binh Khố) and Kỹ Đạo need artifact slots (dao.md line 677 says those facets fall back to stat lines until Item DB supports them). The GDD has no slot stat. Decision D2.

**ID-07 [recommended] The affix pool is not specified against the Modifier System.**
- Formulas D describes "9 affixes" with min/max ranges. Modifiers says affixes are catalogue modifiers priced in W, and it keeps rare modifiers off rolled affixes. Combat Defence relies on "resistance affixes" (Black Iron Armour's Physical affix, resistance in points). combat-damage-types OQ 3 asks Item DB for "a content rule" keeping Chaos resistance rare. Modifiers line 787 asks to re-derive the artifact-defence price when Item DB adopts the body-gear mapping.
- The GDD names no resistance affix and no affix–catalogue link, and rule 19's lint does not check affix keys against the modifier catalogue or reject rare modifiers.
- Fix: list the pool (or point at its data file) and the catalogue keys it uses. Add the lint (affix keys exist in the catalogue; no rare modifier on a rolled affix; no Chaos resistance). Add resistance affixes counted in points. Decision D6.

**ID-08 [recommended] Artifact attack has no damage type.**
Combat Damage Types gives every part a type (resistance and block read it). Item DB's weapon attack feeds Combat L3 and has no type, element handling or conversion host statement. Combat Damage Types does not say either. Rule 11 says pieces count "in equip order", which Damage Types uses for conversion order. That part is correct. Decision D5.

**ID-09 [recommended] Interactions and Dependencies tables do not list all the revised neighbours.**
The Interactions table (lines 196-212) and the Dependencies tables have no rows for Combat Defence & Healing (#21a), Combat Damage Types (#21b), Modifier System (#40), Effects System (#41) or The Way (#39). These appear only as four prose bullets (533-537). dao.md lists Item DB as a dependency (row 677). The "Bidirectional check" paragraph does not mention any of them. Fix: add one table row each, with type, interface and state.

**ID-10 [recommended] The seal contract is still inconsistent with Meridian Map.**
Item DB OQ 16 (closed 2026-11-06): Mạch Ấn is bound to its holder and opens the nearest sealed cluster. kinh-mach-do rule 7 (line 265) still says "a Meridian Seal key item bound to this cluster", and its OQ 19 asks to build "bound seal keys". Also, kinh-mach-do's state table has a Pending path (realm below the gate: the seal is consumed, the cluster waits). AC-ID-34 and AC-ID-65 test neither "no cluster to open" for a Pending-only case nor the Pending path. The fix is in kinh-mach-do (another session); add an AC here once the rule is settled.

**ID-11 [recommended] Timed pill effects (Open Question 7) are still open.**
Open since the first review, and Thiên Kiếp line 135 now relies on them holding for every wave. Rule 12 says only "timed pill effects" without a timer owner. Assign the owner (Character Stats or Alchemy) or mark rule 12's reference deferred.

**ID-12 [recommended] No implementable measurement for Formulas H.**
OQ 14 (drift, "value created", "unrestricted recipes") still blocks AC-ID-71 to 77, and there is no per-tick performance target for item operations at 200,000 records. The log shows both carried since 2026-11-06 (pill_price_max never binds, "rank 6 pills pass the cap" are now explained by "no rarity cap" and are closed). Fix: set a budget (for example, owner-index lookup and per-season herb tick in ms at 200,000 records) and give OQ 14 an owner and date.

**ID-13 [recommended] Registry name drift.**
Registry `potency_per_doubling` vs GDD `per_doubling`, and `equip_max_slots` vs `equip.max_slots` (the notes say "built as"). Also `default_role` output_range lists "weapon, ward, body, utility". Fix the registry names or add the GDD names as aliases in the registry note (registry edits are for the user's session).

## Minor

- **ID-14** AC-ID-70 (on hold) uses "a piece tagged ward and body" — the tags are `ward_gear` and `body_gear` (D2). It also checks only `ws`/`we` and `a_w`/`a_b`. Its numbers still hold (a_w 0.35, a_b 0.30, +10.5 = 100 · 0.30 · 0.35). Add the block and body-shield outputs once ID-01 is applied (12 per a, 0.60 per `a_b`; gear block uses `min(a_w, 1) + a_b`).
- **ID-15** AC-ID-26 says "Chuông and Thuẫn are ward"; should be `ward_gear`.
- **ID-16** Header: Status "Designed (pending review)" and "Last Updated/Verified 2026-11-06" are stale. Quick reference "Key deps" omits Character Stats (soft), which the systems index and Dependencies include.
- **ID-17** systems-index.md row #13 says "Approved (2026-11-06 ...)". After this review it should be Needs Revision. Not changed here (user's session).
- **ID-18** Ordering: Open Questions run 1-7, 11-16, then 8-10. Acceptance Criteria put AC-ID-84 before AC-ID-83. The Visual/Audio section's "Glyphs, not paintings" pillar reference should cite the art bible or concept by section.

## Mechanical fixes (one sweep)

1. Line 3: status text and the `Last Updated` / `Last Verified` dates (ID-16).
2. Line 17: add Character Stats (soft) to "Key deps" (ID-16).
3. Lines 103-104: replace "body guard" and "Combat Formulas D" with body block/shield and Combat Defence & Healing Formulas A0 (ID-01).
4. Line 596: cross-reference row for Rule 6: Formulas D → combat-defence Formulas A0; remove "Open Question 10" (closed) (ID-01).
5. AC-ID-26 line 656: "ward" → `ward_gear`, "Chuông and Thuẫn" (ID-15).
6. AC-ID-70 line 727: "tagged ward and body" → "tagged ward_gear and body_gear" (ID-14).
7. Open Question and AC ordering: move 8-10 before 11; put AC-ID-83 before AC-ID-84 (ID-18).
8. Registry: `default_role` output_range → "weapon, ward_gear, body_gear, utility" (ID-13).
9. systems-index #13 status after the revision (ID-17).

## Decisions for the user

- **D1 (ID-02)** Where does a named item live? Recommended: a `named` authored artifact or treasure template listing `effects` and `modifiers`, read through the template and never rolled. Alternatives: a new item kind `named_item`; or let the Effects GDD own host records and Item DB only link to them.
- **D2 (ID-06)** How do slots grow? Recommended: slot count = `equip.max_slots` + an `artifact_slots` stat from Character Stats; capability #2, Kim Đạo and keystones feed it as modifiers. Alternative: keep capability #2 as the only source and leave the Way's facets as stat lines.
- **D3 (ID-04)** Linh Căn Quả with all five elements owned at 100: Recommended: never refused; it adds +8 past 100 (linh-can rule 8a, Formulas D), so change linh-can line 299 and Item DB AC-ID-34. Alternative: keep the refusal at 100 and change linh-can Formulas D.
- **D4 (ID-05)** The Legendary above-cap item: Recommended: name it in Formulas F as a lint-passed exception (one rank above the realm cap, never above `rarity_max`), not through the clamp. Alternative: raise `realm_rarity_cap` for Legendary rewards.
- **D5 (ID-08)** Artifact damage type: Recommended: each base carries a `damage_type` (default Physical), and an artifact's element stays a tag. Alternative: weapons have no type and only arts and statuses carry damage types.
- **D6 (ID-07)** Chaos resistance: Recommended: lint rejects it in the affix pool; it is allowed on named items only. Alternative: allow it as a very low-weight affix.
- **D7 (ID-17)** Index status: Recommended: set #13 to Needs Revision until ID-01 to ID-03 are applied. Alternative: leave Approved with a note.

---

## User answers and applied fixes (2026-11-10, parent session)

- **D1:** named items are authored `named` templates listing `effects` and `modifiers` (rule 20).
- **D2:** slots = `equip.max_slots` + `artifact_slots` (a Character Stats key fed by capability #2, Kim Đạo, keystones).
- **D3:** a Linh Căn Quả is never refused (+8 past 100), as Spiritual Roots decided.
- **D4:** the Legendary exception is named in Formulas F's reward bounds, passed by the lint.
- **D5:** each base carries a `damage_type` (default Physical).
- **D6:** Chaos resistance on named items only; the lint keeps it out of the rolled pool.
- **D7:** the index row moves to In Review after these fixes.
- Applied: ID-01 (rule 6, cross-reference row, bidirectional check), ID-02 (rule 20, AC-ID-85), ID-03 (FX-L at Qi
  Refining: cap 124.41 with the piece; AC-ID-62 10.91), ID-04, ID-05 (reward bounds, AC-ID-86), ID-06, ID-07 (rule 19
  lint), ID-08, ID-09 (Interactions rows), ID-13 (registry `default_role`, name aliases), ID-14, ID-15, ID-16, ID-17.
  Left open: ID-10 (the seal contract retired with the Meridian Map's hidden clusters: Mạch Ấn has nothing to open
  now; a follow-up decides whether the item kind is retired), ID-11 (timed pills' owner), ID-12, ID-18 (ordering).
