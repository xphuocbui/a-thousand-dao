# Design Review: Cultivation Techniques (Công Pháp), 2026-11-10

Report only. Nothing in `cong-phap.md`, any other GDD, the registry, project.yaml or code was edited.
Review mode: lean (solo, no specialists) · Workflow: standard · Re-review: yes (prior entry: 2026-11-05, NEEDS REVISION, fixed the same day, never re-reviewed).
Scope signal: L (about 14 dependencies, 6 formula families, several new ADR-sized contracts with Combat and the Modifier/Effects systems; the producer should verify).

## Verdict: NEEDS REVISION

The core of the GDD is sound. I re-derived the arithmetic of Formulas A to F and of about 30 acceptance criteria by hand (the Formulas A examples, AC-CP-01, 02, 06, 14 to 24, 27, 28, 32, 37, 51 to 54) and found no numeric error. Every registry value this GDD owns matches (tech_norm, count_gain, beyond_realm_mult, no_cong_phap_mult, seal seasons, second_main_mult, tech_power and its 0.5 to 3.355 range, the comp_strength keys).

The document has not been touched since 2026-11-06 (header). Since then purity became uncapped, the Character Stats ceilings became curves, body guard was retired for block, body shields and resistance, and Modifiers, Effects and the Combat sub-GDDs were revised. Two of those contradict what this GDD says: **CP-01** (uncapped purity against `match`, `F`, `strongest_purity` and the ranges) and **CP-02** (body techniques cannot produce what Combat Defence and Combat AC-CB-60 expect from them). Both need a user decision (D1, D2). Five recommended items and seven minor ones follow.

Completeness (standard tier, 5 required plus Formulas): 6/6 present. Player Fantasy is absent: advisory at `standard` (it is Open Question 10); not counted.

Dependency graph: every system with a GDD exists on disk (linh-can, canh-gioi, character-stats, kinh-mach-do, combat, combat-defence, combat-damage-types, modifiers, effects, dao, item-database). Systems with no GDD yet (Time & Turn, Market, Event Engine, World Generation, Sects & Missions, NPC Build Generation, Codex, Save/Load) are provisional and correctly marked as such. Cited code and data paths all exist.

Registry values: all entries owned by this GDD match (see above). One registry entry that references this GDD is stale (see CP-03).

## Blocking

**CP-01 (blocking) Purity is no longer capped at 100, but the whole speed and bonus model assumes it is.**
- Where: Formulas A variables `match` (0.08 to 1.00), `strongest_purity` (10 to 100), `tech` range 0.03 to 2.9 and its Output Range text; the crude branch; Formulas D `avg_purity` (8 to 100), F range 0.58 to 1.5 and v up to 2.63 × v_full; Formulas A "Check" tables; AC-CP-18 ("Heaven method at purity 100 gives 2.9", "purity in {10, 50, 100}"); Parameter keys; rule 9 and the Interactions row ("the purity of each named element and variant").
- Against: `linh-can.md` rule 8, "No cap: both uses above read the full purity, past 100 too (user decision 2026-11-10)", and rule 8a (purity past 100 from Linh Căn Quả, meridian roads of an element land, rare items and Đạo nodes). The Linh Căn re-review (`linh-can-review-2026-11-10.md`, LC-08 and decision D6) already flags this as owed by this GDD.
- What goes wrong:
  - `match` and `F` can exceed 1.0 and 1.5. The purity-form `F` has no cap, unlike the body form's `F_cap`.
  - The `bonus_single_cap` and per-tier budget logic reads `v_full`, so it is safe, but `v` is no longer bounded by 2.63 × v_full.
  - The "par tier at match 0.5 = 1.0 in every realm" calibration and the tier ceilings assume purity at most 100.
  - Rule 8 and rule 4 are silent on an element the root does not own but has gained purity in (Linh Căn rule 8a says it does not make the root own it). Presumably still unusable and never read in `match`, but the GDD never says so.
- Fix: take D1 first. Then either clamp the purity read by `match`, `F` and crude at 100 (and say so in rule 9, Formulas A and D and the Interactions row), or widen every range and recompute the Output Ranges and AC-CP-18. Either way add one sentence: purity of an unowned element is ignored by techniques. Re-run Realms AC-CG-33 and AC-CG-33a if purity is not clamped.

**CP-02 (blocking) Body techniques cannot yield the block, body shield and resistance that Combat Defence and Combat AC-CB-60 expect.**
- Where: Core Rules 2 (body technique) and 12; Formulas D (body technique `F`, `B(k)`, `body_comp_strength`, `bonus_pool`); Dependencies, "Combat sub-systems" paragraph; AC-CP-23, AC-CP-39; Open Question 4.
- Against: `combat-defence.md` rule 12 and Formulas H ("Iron Body Art (Thiết Thân Công), tier t of 1 to 5: per tier block +10, σ_b +0.10, Physical resistance +8.3 points; tier 3 is 30 / 0.30 / 25 points", sizes fixed when the piece is designed); `combat.md` rule 23 and AC-CB-60 ("Iron Body Art at tier 3 gives block rating 30, σ_b 0.30, Physical resistance, none of it scaled by ws, at Qi Refining"); `combat.md` line 418, which lists these as Cultivation Techniques' outputs.
- What goes wrong:
  - There are four technique tiers (0 to 3) but Combat's Iron Body Art has five tiers. The mapping from one to the other is nowhere defined.
  - Here a body technique's bonus is `v_full × B(k) × F(Physique) × body_comp_strength`. A tier-3 body technique found at Qi Refining stops at layer 3 (B ≈ 0.43 for Earth), so it would give about 13 block, not 30, and the values move with Physique and Comprehension. The fixed Combat figures cannot come out of Formulas D.
  - The keys `block_rating` (grid 1), `body_shield_pct` and `resist_pct` have no `bonus_pool` row and no budget share, so the load-time validator would reject such a template. The thể tu is the route this GDD calls the answer for a root that fits nothing.
  - Open Question 4 says no body technique can be obtained in play yet.
- Fix: decide D2. Then state in this GDD which keys a body technique may carry, how the tier or the mastered layer maps onto Combat's per-tier sizes, whether `F` and `comp_strength` apply to them, and add `bonus_pool` rows (or an exempt list) for them. Rewrite AC-CP-23 and add an integration case that matches AC-CB-60.

## Recommended

**CP-03 (recommended) "Ceilings" are now curves.**
- Where: rule 12 ("count toward Character Stats' character-wide bonus ceilings (its Formulas I)"); Formulas D Output Range ("a ceiling still caps what v delivers"); Cross-References (Character Stats row); the `bonus_budget` rationale.
- Against: `character-stats.md` rule 14 and Formulas I (user decision 2026-11-10, "no caps"): `herb_growth_pct` and the lifespan bonus follow `k · ln(1 + Σ⁺/k)`, `alchemy_success` dampens the brew failure chance, and penalties apply after the curve.
- Effect: a technique's `herb_growth_pct`, `alchemy_success` and `lifespan_years` still share the pool with the other sources, but with diminishing returns instead of a stop. The "never over a ceiling" wording and the safe-range reasoning for these bonus stats no longer hold, and the lifespan-cap confirmation in rule 12 should read the curved bonus.
- Fix: reword to "the character-wide bonus curves"; check the `bonus_pool` maxima of those three stats against the curve scales. The registry entry `bonus_ceilings` (owned by character-stats, `entities.yaml` line 2256 on) still describes ceilings and is also stale (not this GDD's to fix; flagging it for the sweep).

**CP-04 (recommended) Technique bonuses are not connected to the Modifier System's budget and `more` rules, nor to Effects as hosts (see D4).**
- Where: rule 1 (`bonuses` as stat modifiers priced by `bonus_pool`), Formulas D (budget in pool maxima), Tuning Knobs `bonus_budget`; no `effects` field in the template; Dependencies paragraph "Combat sub-systems".
- Against: `modifiers.md` rule 12 ("each source GDD owns its budgets ... a technique tier", priced in W) and the `more` rule (L2 points on techniques and arts, Stat List row `damage_more`); `effects.md` rule 13 (techniques and their arts may host Effects; a technique may be an enabler, whose `closes` is part of the rule); modifiers' tag rule (a technique holding several modifiers carries the union of their tags).
- What is missing: no path for `damage_more` or conversion modifiers on a technique, no `effects` list or enabler marking on the template, no tags, and the sheet's per-source quantisation of a scaled `more` value is not stated. The pool-maximum budget is a second pricing scale next to W.
- Fix: after D4, add an `effects` field (and tags) to rule 1 and say how L2 points scale with B(k), F, H and comp_strength (or that they do not).

**CP-05 (recommended) Harmony with a multi-element or Primordial Chaos (Hỗn Độn) main is always 0.60 (see D3).**
- Where: rule 12 harmony, Formulas D table, AC-CP-22.
- Against: `linh-can.md` rule 9 (Chaos is formed from all five base elements; Thunder, Darkness are two-element convergences).
- Effect: "a derived variant counts as its required elements" plus "the worst relation applies" means any art under a Chaos main, and any Chaos art under any main, meets an overcoming pair, so H = 0.60 always; a Darkness or Thunder main hits it for most arts too. Probably unintended.
- Fix: D3, then one Edge Cases line and an AC row either way. Also say that archived Blood and Void (Linh Căn rule 9) are not nameable by new templates.

**CP-06 (recommended) The divine ability record is too thin for what Combat now requires.**
- Where: rule 1 (`abilities`: `{ability_id, unlock_layer}`), rule 13, rule 14, AC-CP-09.
- Against: `combat.md` rule 13 (an art has an id, tags, damage parts with types, a linh lực cost, a cooldown, an effect, optionally a heal payload; arts share one pool of `slot_count` art slots, so "unlocked" is not "usable"); `combat-damage-types.md` ("every art a technique unlocks declares its damage parts and types").
- Fix: say that `ability_id` points at a Combat art record, that unlocking only makes it eligible for the art slots, and who owns the record (Combat, per Open Question 3, which is still open). Add the slot-pool wording to rule 13 and AC-CP-09. Mark Open Question 3 as owned by Combat's own OQ 13.

**CP-07 (recommended) Dependencies and Interactions omit the Combat sub-systems, Modifiers and Effects as rows.**
- Where: Interactions table and Dependencies tables list only Combat (#21); the sub-systems (#21a, #21b, #40, #41) appear only in one prose paragraph, which also says "All four related GDDs list this system" (stale, now about ten).
- Fix: add table rows with direction and owner for Combat Defence & Healing, Combat Damage Types, Modifier System and Effects System (bidirectionality is otherwise satisfied: combat.md, combat-defence.md, modifiers.md, effects.md and dao.md all list this GDD), and rewrite the Bidirectionality paragraph.

## Minor

**CP-08 (minor) States table gaps.** `States and Transitions`: Gated and Great completion leave only to Slotted or Known · usable; a Gated technique can also be unslotted and can become unusable by a root change (guard). Add those exits, or say "any Slotted sub-state".

**CP-09 (minor) Header dates.** `Last Updated 2026-11-06`, `Last Verified 2026-11-05` and the Status line predate the #44 revisions and the purity and curve decisions. Update after the fixes; keep Status at In Review until a clean re-review.

**CP-10 (minor) Open Question 14 wording.** It says Combat's "ward fit" used 2.2. Combat retired that ward and body guard (combat.md line 598); re-state which Combat anchors still assume a tech_power of at most 2.2 (Combat Formulas A sizes the qi pool from spiritual power), or close it.

**CP-11 (minor) Registry range of `technique_speed_factor` is [0.03, 4.35]; this GDD says "about 4.3 with #6" (Formulas A variables) and 4.35 in AC-CP-18.** Make both say 4.35 (and revisit with CP-01).

**CP-12 (minor) Cross-References, Character Stats row: "range edited to 0.5 to 2.2".** The range is 0.5 to 3.355 (user decision 2026-11-06), as in Formulas C and the registry.

**CP-13 (minor) Edge Cases header: "Two lean design reviews and three cross-GDD reviews".** The review log shows more passes than that; reword without a count.

**CP-14 (minor) Rule 2 still says a body technique "feeds body guard ... (Combat rule 23)".** Body guard is retired; rule 23 now says the body defends with block, body shields and resistance. (The substance is CP-02.)

## Decisions needed (autonomous run: recommended answers below, none applied)

- **D1 (CP-01).** Does technique speed and bonus read purity past 100, or is it clamped at 100? **Recommended: clamp at 100 for techniques** (`match`, `F`, crude), keeping the tier-ceiling calibration and the Realms years table valid; uncapped purity then powers element stacks and crafts only. This is the same recommendation as Linh Căn D6. Alternative: read it uncapped, widen the ranges (and `F` gets a cap like the body form) and re-run Realms AC-CG-33 and 33a.
- **D2 (CP-02).** How do body techniques produce Combat's fixed Iron Body sizes? **Recommended: body techniques carry fixed per-tier sizes (Combat's table), mapped from tier 0 to 3 onto Combat's tiers 1 to 5 with the layer gate only deciding when the technique unlocks it, and outside `F`, `B(k)` and `comp_strength`.** Alternative: keep scaling by layer and Physique and change Combat's table to ranges.
- **D3 (CP-05).** How should harmony treat a main or art that names several elements, or Chaos? **Recommended: replace "worst relation" with "the average of the pairwise factors" for 3 or more named or implied elements, and treat Chaos as neutral.** Alternative: keep the worst relation and accept that Chaos and wide arts always sit at 0.60 (a deliberate price).
- **D4 (CP-04).** Should technique bonuses move to the Modifier System's W budgets now? **Recommended: not yet.** Keep `bonus_pool` and `bonus_budget` as the interim scale (the design order puts công pháp after the modifier library and the Đạo), add `effects`, tags and `more` hooks to the record now, and convert when the catalogue is authored. Alternative: convert now, with a per-tier W budget table in this GDD.

## Mechanical fixes (one sweep)

1. Rule 2: replace "feeds body guard, the defence that needs no spiritual power (Combat rule 23)" with block, body shields and resistance (Combat Defence rule 12; Combat rule 23).
2. Rule 12 third bullet and Formulas D Output Range last bullet: "ceilings" to "curves" (Character Stats rule 14, Formulas I).
3. Cross-References, Character Stats row: "0.5–2.2" to "0.5–3.355".
4. Formulas A variables `tech` row: "about 4.3" to "4.35" (matches AC-CP-18 and the registry).
5. Dependencies, Bidirectionality paragraph: replace "All four related GDDs" with the current list; add the four rows of CP-07.
6. Edge Cases header: drop the review counts.
7. Header: Last Updated, Last Verified and the Status text.
8. Open Question 14: reword per CP-10.
9. States table: add the exits of CP-08.

## Cross-document notes (not this GDD's to fix)

- `combat.md` AC-CB-60 says Iron Body tier 3 gives "Physical resistance 0.20"; `combat-defence.md` Formulas H now says 25 points (resistance in points). Combat should be corrected in its own sweep.
- Registry `bonus_ceilings` (character-stats) still describes ceilings (see CP-03).
- Item DB line 222 says authored manuals copy `value`, `bonuses` and `layers` onto the record; recheck once CP-04 adds `effects` and tags.

## What was checked and found sound

- Formulas A to F arithmetic, the pacing tables, the price band and the root-bias probabilities (68.0 %, 28.0 %, 90.4 %).
- Harmony table counts (5 / 10 / 10 of 25 ordered pairs) against the generating cycle and the five overcoming pairs.
- Meridian Map rule 7 and `cong_phap_seasons` (24 / 24 / 48 / 48); capability #6 text; Realms Formulas I `tech` term and rule 14's confirmation; Character Stats `tech_power`, spiritual power and Comprehension (`comp` against `comp_strength`); Combat AC-CB-60's qi pool of 82.02 from spiritual power 50; the Way's rule 5 requirement on a technique's kind and tier.

---

## User answers and applied fixes (2026-11-10, parent session)

- **D1:** purity is read **uncapped** (decided with Spiritual Roots D6); the ranges widen, Realms re-checks (its OQ 23).
- **D2:** body techniques give **fixed sizes per tier**: tier t reaches Combat Iron Body tier t + 2 at great
  completion, tier 1 at the first layer, the rest at even shares of the layers; outside F, B(k), comp_strength and
  the bonus budget.
- **D3:** harmony averages the pairs when there are three or more; Primordial Chaos is neutral.
- **D4:** not yet: `bonus_pool` stays interim; `effects`, `tags` and the art-record pointer are added to the template
  now.
- Applied: CP-01 (rule 9, Formulas A and D ranges, AC-CP-18, unowned purity counts), CP-02 (rule 2, `body_defence`,
  AC-CP-23), CP-03 (curves), CP-04 (template fields), CP-05 (rule 12, Edge Cases, AC-CP-22, Blood/Void not nameable),
  CP-06 (rule 1 and 13 art records and slots), CP-07 (Dependencies paragraph), CP-09, CP-10, CP-11 (registry note),
  CP-12, CP-13, CP-14. Spiritual Roots rule 8 and its edge case follow (purity 0, not "lacks").
