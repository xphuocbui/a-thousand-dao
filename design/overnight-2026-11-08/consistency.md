# Consistency check — 2026-11-08 (overnight, report only)

**Result: CONFLICTS FOUND.** 44 findings:
- **17 new** (4 high, 9 medium, 4 low): no current plan covers them.
- **16 covered by the Combat revision (#43)**: a new GDD's #43 list names them, or the overnight decisions file proposes them for the #43 sweep.
- **11 already known** from tonight's four design reviews and waiting on your decisions. They are not #43 items.

The four new GDDs mostly agree with each other. The registry constants they own match their text. Most of the trouble is in the *older* GDDs: none of the ten mentions any of the four new GDDs, and several still describe body guard (hộ thể thân), threat kinds (body / qi / soul) or W-priced rule pieces.

Nothing was edited. The only file written is this one.

## How this was run

| Item | Value |
|---|---|
| Skill | `/consistency-check`, full scope, report-only. Its fix and write steps were declined (see the last section) |
| Registry | `design/registry/entities.yaml`: 0 entities, 0 items, 69 formulas, 209 constants (278 entries). `registry.sh validate`: 0 duplicate, status, layout or missing-path rows |
| GDDs scanned | 14: combat-defence, combat-damage-types, modifiers, effects, combat, character-stats, kinh-mach-do, canh-gioi, item-database, thien-kiep, quests, cong-phap, dao, linh-can |
| Scope | Required sections only (`workflow: standard`). No `workflow_overrides.tuning_knobs` flag, so Tuning Knobs was not compared |
| Not checked at this tier | Tuning Knobs, Player Fantasy, Visual/Audio, Game Feel, UI, Cross-References, Open Questions. Values stated there that touch this check: thien-kiep Tuning Knobs `soul_share_max` ("most builds cannot ward" soul; soul wards now exist); character-stats Tuning Knobs #25 (50 / 2 / +100); combat-damage-types Visual/Audio type colours |
| Clean | canh-gioi.md: no conflict. linh-can.md: only the naming question (K8). All 37 registry constants and 14 formulas owned by the four new GDDs match their GDDs, except K1 and K2 |

Severity: **High** means an implementer would build the wrong thing or could not build it. **Medium** means two documents give different rules or numbers. **Low** means wording, a stale note or registry tidiness.

---

## A. New conflicts (not covered by #43 or tonight's reviews)

> **Decided 2026-11-08 (user):** N1 = combat-revision D2, N2 = D3, N5 = D1 (all as recommended). **N3** as
> recommended: a main damage type and 3 coverage groups (Physical/Force; Fire/Cold/Lightning/Light/Chaos; Soul),
> applied to thien-kiep.md with #43. **N4** as recommended: Way passives become Effect records with a slot
> table, and `dao_ability_credit` is deprecated, at the Đạo catalogue step.

### High

| # | Where | What conflicts | Change | Suggested fix |
|---|---|---|---|---|
| N1 | item-database.md rule 6, Formulas E; registry `default_role`; modifiers.md rule 8, rule 9 (artifact role row), Stat List `artifact_defense_pct`; combat-defence.md Formulas A2 (`a_w`) | **Artifact role tags differ.** Item DB (the owner) and the registry use `weapon`, `ward`, `body`, `utility`. The Modifier System uses `weapon`, `ward_gear`, `body_gear`, `utility` and says these are "Item DB (Combat's role tags)". Item DB's `ward` is also Combat's mode tag `ward`. Item DB and Combat Formulas D send *every* non-body piece's defence to the ward. Defence's A2 calls `a_w` "ward-role" defence | Item DB (owner), with a user decision; then modifiers.md and combat-defence.md | Rename the Item DB roles to `ward_gear` and `body_gear`, which avoids the clash with mode `ward`. Update `default_role`'s output range. Decide whether `a_w` is ward-role defence only or all non-body defence, and say it the same way in Item DB, Defence A2 and #43's ward formula |
| N2 | combat.md rule 24, Formulas E2 ("Wards, body guard, evade and crit do not apply"); registry `soul_attack` note ("Ignores wards"); combat-defence.md rule 14 and Formulas H (Soul-Guarding Lamp: a soul shield soaking 50 % of each soul hit); combat-damage-types.md rule 4 | **Soul wards.** Defence adds soul wards: soul resistance plus an optional soul shield. Combat says soul attacks ignore every ward, and E2 has no soul-shield term. No #43 list names rule 24 or E2 | combat.md (add this to the #43 list); combat-defence.md (give the soul-shield formula); registry note | In Defence, define the soul shield: it takes `share × pct` off each pool loss after E2's `pct`, and its own bar is spent first. In #43, rewrite rule 24 and E2 to "ignores everything except soul resistance and soul wards (combat-defence rule 14)". Fix the `soul_attack` note at the same time |
| N3 | thien-kiep.md rule 12, Formulas D coverage lint, `main_kind`, `kind_share_max`, FX-POOL, AC-TK-77 | **Tribulation bosses are typed by threat kind** (body, qi, soul). Combat Damage Types replaces kinds with 8 damage types, and says tribulation lightning deals Lightning. Neither the #43 lists nor the proposed sweep (which only adds `no_heal`) covers this | thien-kiep.md, with a user decision | Replace `main_kind` with a main damage type. Restate coverage, for example "at least one boss mainly Physical or Force, one mainly Fire, Cold, Lightning, Light or Chaos, and one mainly Soul". Keep `kind_share_max` for those three groups. Re-baseline FX-P's ehp (9,400) once #43 swaps in Defence's ehp |
| N4 | dao.md rule 3, Formulas D1 (node-value lint, `credit(T)`); registry `dao_ability_credit` (10 / 18 / 30 W); effects.md rules 1, 4, 13 | **Dao passives are priced in W; Effects are unpriced.** The Way gives each passive a W credit by tier and lints node value with it. It keeps passives as capability-shaped records with `npc_effect`. Effects says every rule piece is an Effect record with `price: unpriced` and a tier (minor / major / keystone / enabler), and Way nodes, branches and capstones are Effect hosts | dao.md (at the Đạo catalogue step), with a user decision; registry later | Make Dao passives Effect records. Replace the W credit in the D1 lint with a slot table ("a branch holds at most N minor and M major Effects; the keystone holds one keystone"), as Effects rule 4 asks of host GDDs. Mark `dao_ability_credit` deprecated when dao.md changes |

### Medium

| # | Where | What conflicts | Change | Suggested fix |
|---|---|---|---|---|
| N5 | combat-defence.md rule 1 and Dependencies ("all of Combat Formulas D" is replaced) vs its Open Question 2 ("the ward half of Formulas D"); Defence A uses `ws` with source "`defense_pct`" only; A2 and B read `a_w`, `a_b` "from Combat Formulas D" | **Ward strength and gear lose their home.** The typical `ws` 30.8 needs Combat D's gear term, `100 · ward_gear_scale · a_w`, and `a_w` / `a_b` are defined only in Combat D. If #43 deletes all of D as rule 1 says, nothing defines them | combat-defence.md now; then the #43 list | Say once which parts of D survive: the `ws`/`we` clamp with `ward_gear_scale`, `ward_cap` and `ward_floor`, plus the `a_w`/`a_b` definitions. Move them into Defence Formulas A, and fix the variable tables to cite that |
| N6 | combat.md, places **no #43 list names** (the lists cover rules 4, 6, 22, 23, Formulas A, A2, C, D, F's tick factor and curse bounds, K, and the ward ACs) | Still written for the old model: **rule 7** (a tick "is inside the ward, so only body guard reduces it"); **rule 11** ("Nothing reserves it"; blocked damage drains); **rule 13** (one ward slot plus an autocast ward); **rule 16** (log lines for the ward and body guard); **rule 17** (rating profile per threat kind); **rule 18** (an enemy for each threat kind, "a ward that resists each kind"); **Formulas B** anchors (thể tu "body guard 25 %" of W, "body gear 5 × B_p"; Defence says top-end body gear is 1.0 × B_p); **Formulas G, J** ("then the ward and body guard as any hit"); **Formulas I** (evade on "body and qi hits only"); **Parameter keys** (lists `body_guard_pct`, lacks the new keys); the fight request has no `no_heal` flag, which Defence's Interactions says Combat receives | combat.md (#43) | Add these to the #43 checklist so the revision does not miss them. Rule 18 becomes "each realm has an enemy dealing each damage-type group, and one with high resistance to each" |
| N7 | modifiers.md Formulas A (linh lực regeneration "uses the 0.01 grid"), Formulas C example, catalogue rows (`linh_luc_regen_pct` +0.15, `health_regen_pct` +0.40 / +2.66, `block_rating` "grid 1"); character-stats.md rule 15; kinh-mach-do.md Formulas F; registry `stat_precision_grid` | **Precision grid.** Character Stats (the owner) puts every `_pct` key on the 0.1 grid. Modifiers needs 0.01 for the two regeneration keys and 1 for block. Modifiers' own rule 1 says validation rejects off-grid values, so its catalogue would fail its own check | character-stats.md (owner); registry | Add to Character Stats rule 15: "0.01: `linh_luc_regen_pct`, `health_regen_pct`; 1: `block_rating`, `bonus_ward_slots`, `bonus_slots`". Update `stat_precision_grid`. This can go in the same edit as the proposed rule 15 key sweep (C14) |
| N8 | effects.md Starter Effects (Keystones; Life table) vs kinh-mach-do.md capability table (#11, #17, #25) and character-stats.md rule 18 (hosts #25, live) | **Re-expressed capabilities differ from the live ones.** **#25** live: heart demon above **50** adds `attack_pct` (L1) = heart demon ÷ **2**, deviation ×2. Effects: above **30**, **L5** +1 per point, cap +40, and +1 heart demon per fight won. **#17** live: full beast power instead of half. Effects adds "−1 art slot; only one companion fights". **#11** live: "a random mutated pill within budget". Effects: "a random lesser pill" | effects.md now (label them); kinh-mach-do.md and character-stats.md at the tree rework | In Effects, mark these rows "proposed change; the live capability stays as built until the tree rework" and list each difference. Or match the live values. The user decides at the tree rework |
| N9 | quests.md rule 11, Formulas D (`gain_w = Σ amount_key · W_key`, `W_key` from `stat_power_weights`); modifiers.md rules 13, 16, Formulas C | **Quest lasting gains are priced outside the Modifier System.** (a) Quests has no breadth multiplier, so a scoped boon costs more W than the catalogue says. (b) Quests reads `stat_power_weights`, which has none of the new defence and healing stats. (c) Modifiers allows rare modifiers on "a quest reward" at 10–30 W, but `quest_boon_w` is at most 12 W, so a quest can never pay one | quests.md; modifiers.md rule 13 (user decision on c) | Size boons with Modifier Formulas C (`W · breadth_mult / price`) and read `modifier_prices`. For (c), either drop "quest reward" from rule 13's hosts, or let Legendary quests pay one rare modifier outside `quest_boon_w`, counted against `quest_gain_cap_w` |
| N10 | cong-phap.md rule 2 (a body technique "also feeds body guard … Combat rule 23"); combat-defence.md rule 12, Formulas H (Iron Body Art: block +10, σ_b +0.10, Physical resistance +6.7 pp per tier, about 20.7 W) | **Body techniques still feed body guard.** Defence retires body guard. Body techniques now grant block, body shield and resistance. The technique record has no fields for them. The proposed #43 sweep does not include cong-phap | cong-phap.md (at the Cultivation Techniques step) | Rewrite rule 2's fight line as "grants block, body shield and resistance (combat-defence rule 12)", and add those fields to the body-technique record with a W budget per tier |
| N11 | dao.md rule 3 ("Art: on hold … combat is a power ratio today"), Interactions ("Combat (not designed)"), Open Question 3; modifiers.md rule 12 and catalogue (Way art nodes grant `more` L2); effects.md rule 13 | **Way art nodes.** The Way says combat is not designed and art nodes wait for it. Combat is approved for rules, and Modifiers and Effects both size and host Way art nodes | dao.md (Đạo catalogue step) | Lift the hold, or restate it as "on hold until #43". Point art nodes at Modifiers rule 12 (L2 points) and Effects hosts |
| N12 | modifiers.md "Formulas F weights move here unchanged" and registry `stat_power_weights` (source: modifiers.md) vs kinh-mach-do.md Formulas F (still the table, data `meridian_tree.json` `stat_weights`), character-stats.md rule 15 ("Precision follows the Meridian Map's Formulas F"), quests.md Cross-References (reads kinh-mach-do) | **Two owners for the W table.** Modifiers says it owns the prices. The Meridian Map still states them as its own, and two readers cite it. The registry value has only the old keys (Modifiers Open Question 8 covers part of this) | kinh-mach-do.md (Meridian Map redesign); registry | In Meridian Map Formulas F, say the table lives in modifiers.md Formulas A. Re-point the Character Stats and Quests citations. Register the full price table in `stat_power_weights` |
| N13 | effects.md Status Catalogue, cleanse tags (`bleed`, `seal`); modifiers.md rule 9 (unknown tags fail validation); combat.md rule 6 (effect family: pierce, lock, poison, cleanse, escape) | **Tags not in the vocabulary.** Bleed's cleanse tag `bleed` and Sealed Meridian's and Silence's `seal` are in no tag family, so a cleanse naming them would fail validation | modifiers.md rule 9 (vocabulary), with #43 for Combat rule 6 | Add `bleed` and `seal` to the effect family, or use existing tags (Bleed: `physical`; seals: `lock`) |

### Low

| # | Where | What conflicts | Change | Suggested fix |
|---|---|---|---|---|
| N14 | item-database.md Formulas D affix roll ("snapped uniform(min, max), 0.1", 9 built affixes); cong-phap.md `bonus_pool` ("uniform, rounded to 0.1"); modifiers.md rule 12; combat-defence.md Dependencies ("resistance affixes"), Formulas H (Black Iron Armour "may carry a Physical-resistance affix") | **Affixes and technique bonuses are sized by min–max ranges, not by W.** Modifiers says each source sizes modifiers from a W budget. No affix in the built pool is a resistance affix | item-database.md, cong-phap.md (at their steps) | Give each affix grade and bonus tier a W budget, and convert it with Modifier Formulas C. Add resistance affixes to the pool, with Chaos resistance only on named items (Damage Types rule 5) |
| N15 | modifiers.md Formulas A, artifact defence basis ("0.51 through ward gear, about 0.35 on body gear") vs combat-defence.md Formulas I ("about 0.648 per defence point on ward and body gear alike … raised to match", user decision 2026-11-07) | The basis text predates the user's decision. The price (0.6) is the same in both | modifiers.md | Change the basis to "about 0.65 per point on ward and body gear alike (combat-defence Formulas I)" |
| N16 | effects.md Keystones, No Ward (the body shield regains 2 % after each quiet pulse; limits: "Body shield cap" only) vs combat-defence.md Formulas B ("Restoring a body shield is healing": heal cap, decay, `no_heal`) | No Ward's regain does not say it counts as healing. Iron Skin Renewed does say so | effects.md | Add "healing: heal cap and decay; 0 under `no_heal`" to No Ward's limits |
| N17 | registry | (a) `dot_pool_cap` (0.05) is read by combat-defence rule 17, effects Formulas B and the `heal_pulse_cap` note, but is not registered; `dot_pulse_cap` is. (b) The 14 formulas of the four new GDDs sit after the CONSTANTS banner comment but are still in the `formulas:` list. YAML and the validator accept this, but a reader is misled. (c) The old ward and guard constants (`default_ward_pass`, `default_ward_drain`, `guard_*`, `pass_min`, `drain_min`, `ward_art_duration`, `trig_ward_strength`) carry no "superseded" comment, unlike `ward_block` and `body_guard` | registry | Register `dot_pool_cap`. Move the banner comment below the last formula. Add a "superseded by combat-defence.md; deprecate with #43" comment over those constants |

---

## B. Covered by the Combat revision (#43)

"Named" means a new GDD's #43 list names it. "Proposed" means it is in the overnight decisions file (Defence item 5) as a #43-sweep recommendation that you have **not yet approved**.

| # | Where | What conflicts | Covered by |
|---|---|---|---|
| C1 | combat.md rule 4 | Three threat kinds meet the ward, then body guard; now one defence path by damage type | Named: Defence OQ 2; Damage Types OQ 2 |
| C2 | combat.md rule 6; Formulas C example ("Fire to Lava", "body to qi") | Kind family replaced by the damage-type family; conversion examples rewritten | Named: Damage Types OQ 2, rules 9–10 |
| C3 | combat.md rule 22, Formulas D (ward half); registry `ward_block` | One ward at a time and pass/drain; replaced by wards in slots and five payment models | Named: Defence OQ 2; registry comment |
| C4 | combat.md rule 23, Formulas D (body guard); `body_guard_pct`; registry `body_guard` | Body guard retired; block and body shields replace it | Named: Defence rule 1, OQ 10/14 ("retire `ward_block` and `body_guard_pct` with #43") |
| C5 | combat.md Formulas A2 and registry `ward_art_duration` | Removed | Named: Defence Dependencies |
| C6 | combat.md Formulas A `ehp`; Formulas K `t_w`, `t_h`, `f`; registry `rating_clash` | Replaced by Defence Formulas G (typical 297.8) | Named: Defence OQ 2, Formulas G |
| C7 | combat.md Formulas C `dealt_j`, Formulas F tick factor `(1 − m · guard_share_kind)`; registry `combat_hit_damage` | Replaced by Defence's path | Named: Defence Formulas G note |
| C8 | combat.md Formulas F curse bounds; registry `curse_bounds` | Retire `curse_pass_raise_max`; add `curse_heal_taken_max` 0.5, `curse_soul_shred_max` 0.30, a reapply lockout; restate `curse_shred_max` as resistance points | Named: Effects OQ 2 |
| C9 | combat.md ward ACs; effects.md AC-EF-10 (old body-ward model) | Rewrite the ACs; restate AC-EF-10 | Named: Defence OQ 2; summary item 10 |
| C10 | combat.md (derived art tags `basic`, `quick`, `slow`, `cheap`, `costly`) | Modifiers proposes them; Combat must adopt them | Named: Modifiers OQ 2 |
| C11 | combat.md rules 7–9 | Status catalogue and the Down step move to Effects | Named: Effects Dependencies |
| C12 | combat.md Formulas B, Open Question 5 | Combat should cite Modifiers for operations, scope and the `more` exchange rate | Named: Modifiers Dependencies |
| C13 | All ten older GDDs | None mentions the four new GDDs (kinh-mach-do line 4 names #40 in passing). Rules require two-way dependencies | Named and proposed: "#43 and Meridian Map sweeps". Note: no sweep is scheduled yet for cong-phap, dao, linh-can, quests or canh-gioi |
| C14 | character-stats.md rule 15 | Still lists `body_guard_pct`. Lacks `resist_pct`, `resist_cap_pct`, `resist_pen_pct`, `block_rating`, `body_shield_pct`, `health_regen_pct`, `healing_pct`, `healing_taken_pct`, `bonus_ward_slots`, `reserve_eff_pct`, `x_soul`, `escape_pct`, `bonus_slots`, `damage_more` (and `art_speed_pct`, its OQ 21) | Proposed: decisions item 5 |
| C15 | thien-kiep.md rule 7 and its fight request | No `no_heal` flag, which Defence rule 19 says every wave sets | Proposed: decisions item 5 |
| C16 | item-database.md rule 6 | "A body piece's defence feeds body guard"; Defence maps body gear to 12 block and a 0.60 body shield per `a_b` | Proposed: decisions item 5 (body-gear mapping) |

---

## C. Already known from tonight's design reviews (not #43)

These are in `design/gdd/reviews/overnight-2026-11-08-summary.md` and wait on your decisions. They are listed so the counts are complete.

| # | Where | What | Review item |
|---|---|---|---|
| K1 | registry `defence_shield` vs combat-defence.md Formulas B | Range 1.0 × health_max vs 2.0 (1.0 ward + 1.0 body) | Defence blocker 1 |
| K2 | registry `defence_resistance` | Variables still R_gen, R_kind, R_elem | Damage Types item 5 |
| K3 | combat-defence.md line 228 | Cites "Modifier System; Formulas H", which does not exist | Modifiers item 15 |
| K4 | modifiers.md rule 13 vs combat-defence.md rule 5, Formulas I | Rare list lacks ward slots (30 W), and its range 10–25 W is below 30 | Modifiers item 3 |
| K5 | modifiers.md Stat List vs combat-damage-types.md rule 5 | Chaos resistance listed as ordinary family, not rare | Modifiers item 4 |
| K6 | effects.md Blood Casting and Withering vs `curse_heal_taken_max` | Two −50 % healing-taken sources; do they stack? | Effects item 4 |
| K7 | systems-index.md | Row 21b is stale (kinds, element cycle); it says 44 starter Effects, the GDD has 46 | Damage Types item 6; Effects item 12 |
| K8 | combat-damage-types.md Open Question 1 vs linh-can.md | "Chaos" (Tà) type vs Chaos root (Hỗn Độn). **Also found tonight:** Light is both a type and a variant (Quang), and Lightning shares Hán-Việt "Lôi" with the Thunder variant. Add both to OQ 1 | Damage Types OQ 1 |
| K9 | combat-defence.md Formulas G thể tu fixture, used by combat-damage-types AC-DT-19 | Physical resistance 0.30 but the named sources give 0.20 | Defence item 4 |
| K10 | effects.md Corpse Rot vs combat.md Formulas F (duration 2–6, `curse_duration_max` 5) | A standing status has no duration | Effects item 6. **Add the exemption to the #43 Formulas F list** |
| K11 | effects.md "Capabilities without a closing cost" vs kinh-mach-do.md (25 capabilities) | 6 + about 12 + "the other 19" is more than 25 | Effects item 9 |

---

## Counts

| Group | High | Medium | Low | Total |
|---|---|---|---|---|
| A. New | 4 | 9 | 4 | **17** |
| B. Covered by #43 (12 named, 4 proposed) | — | — | — | **16** |
| C. Known from tonight's reviews | — | — | — | **11** |
| **All** | | | | **44** |

By document that should change (new findings only): combat.md 2 (N2, N6), combat-defence.md 2 (N2, N5), item-database.md 2 (N1, N14), effects.md 2 (N8, N16), modifiers.md 3 (N9c, N13, N15), dao.md 2 (N4, N11), cong-phap.md 2 (N10, N14), quests.md 1 (N9), thien-kiep.md 1 (N3), character-stats.md 1 (N7), kinh-mach-do.md 1 (N12), registry 2 (N2 note, N17). N2, N9 and N14 each touch more than one document.

**Suggested order:** N1, N2 and N5 before #43 starts, since they change what #43 writes. Then add N6's list to the #43 checklist. N3 and N4 need your decisions.

## What was not done, and why

| Step | Status |
|---|---|
| Phase 6: registry corrections | **Declined** (report-only; writes allowed only in this folder). K1, K2, N2's note and N17 are not applied |
| Phase 6b: append to `docs/consistency-failures.md` | **Declined**, same reason. The 17 new conflicts are **not logged** there |
| Phase 7: breadcrumb in `production/session-state/active.md` | **Declined**, same reason |
| Closing question and `log_decision` | Not run: unattended, and logging would write outside this folder |
| kinh-mach-do.md (268 KB) | Read by targeted grep and two section reads (capabilities, Formulas F), not section by section. Its numbers were not checked |
| Numeric re-derivation | Not repeated. Tonight's reviews recomputed every number in the four new GDDs |
| Specialist agents | None spawned |
| Commits | None |
