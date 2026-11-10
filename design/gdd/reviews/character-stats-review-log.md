# Review Log: Character Stats

## Review — 2026-11-04 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: The arithmetic reproduces everywhere checked (grade shares, Formula C table, D/E/F/G/H/I examples, AC-CS-18, AC-CS-32, #4 numbers), and the registry has no value conflicts. The one blocker is a tuning-range contradiction: the effective talent clamp's safe range (120–200) breaks the Market's no-profit-loop limit above presence 157.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Tuning Knobs: effective talent clamp range 120–200 contradicts the `mi_luc_price_per_point` derived limit (loop profits above presence 157)
- [RECOMMENDED] Rule 8 / AC-CS-19: "kills add none" vs #9 "+2 per defeat" needs an explicit with-#9 case
- [RECOMMENDED] Registry: `failure_khi_huyet_loss_pct` carries the old name (now `_frac`)
- [RECOMMENDED] Rule 13 / Formulas I: no stacking rule for `cultivation_speed_per_element_pct`; no owner for lifespan keys
- [RECOMMENDED] Formulas C: #4's "+22 % at CF" holds only at physique 45
- [RECOMMENDED] Formulas G: `field_plots` names both the key and the output
- [RECOMMENDED] Formulas H: Market ceil/floor needs the Formula I tolerance rule or integer maths
- [RECOMMENDED] AC-CS-09, 11, 19: missing pill toxicity / quality, and a provisional bullet
- [RECOMMENDED] Edge Cases: talent-lowering pills and events not covered
Reviewed-Content-Hash: design/gdd/character-stats.md 142d6010328a1834a1e15df4c8a59d2a3f0f3729
Reviewed-Content-Hash: design/registry/entities.yaml 446511e0a80b7c23020f6c4e921386e0d9803f4a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md ea41e3937b8b97af305964140398a574dadeb1a3
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 65d5beb25169d28526b489c656b70abaaa419b0c
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/systems-index.md d6bb32eaf229dd12e5fb4e55adc519ad4fb4fecc

## Review — 2026-11-04 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: All nine findings from the first review are resolved. The arithmetic reproduces across Formulas A–I and the ACs, and the registry has no value conflicts. Remaining items are data-driven-rule, precision and test-coverage gaps, not design contradictions.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Rule 15 / Formulas I: no precision unit for can_cot, than_hon, dao_tam, mi_luc
- [RECOMMENDED] Parameter keys: effective talent clamp, presence price, fortune factors and #25 params have no data key (code hardcodes 1..150)
- [RECOMMENDED] Rule 9 / Formula F: qi deviation setting vitality to the floor is missing from Rule 9
- [RECOMMENDED] Acceptance Criteria: no AC for cultivation_speed_per_element_pct (or lifespan) stacking
- [RECOMMENDED] Tuning Knobs: dan_doc_divisor range 100–400 contradicts the 0.5–1.0 cultivation multiplier output range
- [RECOMMENDED] Registry derived_values: output_range ignores tech_power up to 2.0 and linh_luc_pct
- [RECOMMENDED] Registry stat_precision_grid: "small flats" is ambiguous
Reviewed-Content-Hash: design/gdd/character-stats.md 1ba60a6df1101840e65eeda7eec1e843f8ed7ce1
Reviewed-Content-Hash: design/registry/entities.yaml 797e50ff6629ba8152105398f7dfac7fe02d4937
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 607bd9da2b8829b7385517262cf7f3fa3f12684b
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 65d5beb25169d28526b489c656b70abaaa419b0c
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/gdd/systems-index.md 30b68980b3b3d489b66b6bad9f80a1c54eac100c

## Cleanup — 2026-11-04 (no new review)
Applied the second pass's 7 recommended items:
- 0.01 precision for all six talent keys;
- data keys for the effective talent clamp, the fortune and presence factors, and #25's parameters;
- rule 9 states the qi deviation's vitality floor;
- AC-CS-51 (per-element cultivation speed) and AC-CS-52 (lifespan stacking) added;
- the `dan_doc_divisor` range is narrowed to 200–400 to match its output range;
- the registry `derived_values` range is unbounded above;
- the registry `stat_precision_grid` lists its keys.

The status header is set to Approved. No values changed.

## Review — 2026-11-04 (third pass) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Full re-review after the cross-GDD fixes. The lifespan ceiling edits (rule 13, rule 14 heading, AC-CS-52) are correct and agree with Realms and Cultivation Techniques. About 60 values were recomputed (grade shares, the Formulas C table, D-H examples, AC-CS-09 to 54) and all match; the registry has no value conflicts. The one real open item is the cross-review W10 decision on mutation lifespan against the ceiling.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Rule 14 / Formulas I: mutation lifespan_years is capped at 18-300 by realm while Spiritual Roots Formulas E prices Time at +200 years; needs a user decision (cross-review W10)
- [RECOMMENDED] Interactions, Dependencies, Open Questions: stale "no GDD yet" and "provisional" text for Spiritual Roots and Cultivation Techniques (C2)
- [RECOMMENDED] Cross-References: no linh-can.md or cong-phap.md rows (C3)
- [RECOMMENDED] Edge Cases / AC-CS-54: "unequipped modifiers leave immediately" conflicts with the Realms rule 14 confirmation; no held-back or realm-rise lifespan case
- [RECOMMENDED] Parameter keys: vitality_floor and tam_ma_natural_decay duplicated although Realms owns the values (Realms OQ11)
- [RECOMMENDED] Dependencies: "Spiritual power at power 1.0" vs 0.5 with no main method (N14)
- [RECOMMENDED] Tuning Knobs: failure_tam_ma_gain range "above 10 and below 20" vs Realms 10-20 inclusive
- [ADVISORY] Player Fantasy section absent (advisory at standard)
Note: the Status header and systems-index row were set to Approved before this hash was taken.

Reviewed-Content-Hash: design/gdd/character-stats.md fdfda6b3a9dac2bd208996343b48b47fd47737be
Reviewed-Content-Hash: design/registry/entities.yaml 6c13ff12951f6e07a0026696ed94eea801d06d70
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md c374398023153060a9ebf19d835d2a7a055a9b83
Reviewed-Content-Hash: design/gdd/canh-gioi.md 862f0775bcfd3fa9f23ba42fac9e97626f2d07e1
Reviewed-Content-Hash: design/gdd/cong-phap.md 71bb0c29b137f9b8a632d5a6f75f06260191691b
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 2484b6a22721d7a3ebae4f9c941fdd197a6ac0f7
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/glossary.md ff571453f374812f6f9f2e2a38eac45a38fb22ca
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04d.md f7ee9ab61ae60ad71faff3d9fd9949fb2facc9f3

## Cleanup — 2026-11-04 (no new review)
Applied after the third pass: W10 is decided (user, 2026-11-04) - a mutation's lifespan_years counts under the lifespan ceiling and Spiritual Roots prices it at the delivered years; stale 'no GDD yet' text and Open Question 1 are corrected; Cross-References gain linh-can and cong-phap rows; the unequip Edge Case defers to the Realms rule 14 confirmation and a held-back lifespan case is added (AC-CS-54); vitality_floor and tam_ma_natural_decay are read-only here; the no-main-method power is 0.5; the failure_tam_ma_gain range matches Realms. No tuned values changed.

## Cleanup — 2026-11-04 (no new review)
Cross-GDD review 04e W-B: rule 14 no longer points to a missing Spiritual Roots question; new Open Question 7 says no current source grants lifespan_pct and any future one needs a price and a bound. No values changed.

## Revision — 2026-11-04 (after cross-GDD review 04f, no new review)
Applied user decisions: B1 (a root mutation's `herb_growth_pct` counts under the herb growth ceiling, rule 14); `bonus_ceilings` lowered to herb_growth_pct 10 and alchemy_success 3 (were 40 and 8; lifespan 0.15 unchanged) so Realms AC-CG-60 holds under the discrete-brew model; C2 (craft mastery is a rule 12 modifier source, with a Crafts "in" row; Spirit Fields mastery adds herb_growth_pct, its curve owned by system 14); I2 (the Age row names the #23 burn). Formulas G and I examples, Parameter keys, the Tuning Knobs row and the stacking AC updated. Registry bonus_ceilings updated. Status set to In Review.

## Review — 2026-11-04 (fourth pass) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; run by a subagent, read-only)
Blocking items: 1 | Recommended: 7
Summary: The 04f changes (B1, ceilings 10 / 3 / 0.15, C2 craft mastery, I2) are applied consistently across rule 12, rule 14, Formulas G and I, Parameter keys, Tuning Knobs, AC-CS-54, the registry, Realms and Spiritual Roots. One leftover: AC-CS-28 still expects Wood 60 with +40 -> 2.072, above the ceiling (1.628).
Prior verdict resolved: Yes (third-pass items applied in cleanups; Player Fantasy advisory stands)
Findings:
- [BLOCKING] AC-CS-28: +40 herb growth contradicts the ceiling of 10; expected 1.628
- [RECOMMENDED] Tuning Knobs / Formulas I: "S <= 0.45" beside 0.44-0.46; AC-CG-60's measured <= 0.48 not mentioned; 12 / 4 safe-range top unjustified
- [RECOMMENDED] Rule 12 vs rule 14 source lists disagree (pills and consumable items, formations, generating pairs)
- [RECOMMENDED] Dependencies: no row for the crafts / #14 Spirit Herbs & Spirit Fields
- [RECOMMENDED] No AC for the craft mastery source; AC-CS-30 still says six source kinds
- [RECOMMENDED] Ceiling applies to the net sum, so an over-ceiling mutation absorbs penalties; state intent, Edge Case, AC
- [RECOMMENDED] Registry bonus_ceilings revised date (fixed 2026-11-04)
- [RECOMMENDED] Formulas G: no variable rows for herb_growth_pct / mission_income_pct; output range
- [ADVISORY] Player Fantasy absent
User decision (2026-11-04): penalties apply after the cap (total = min(sum of bonuses, ceiling) + sum of penalties).

Reviewed-Content-Hash: design/gdd/character-stats.md e5aa42a5613aa8a09e7ee8a827a0b7aae835a123
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/registry/entities.yaml 98f81534bc9142f93b105089d9d6424018851e12
Reviewed-Content-Hash: design/gdd/canh-gioi.md 95c39d0a40a5f6b40ac59bc8b1a88885f656acdc
Reviewed-Content-Hash: design/gdd/linh-can.md 8ed898fd73f7e724822ed0420b16c758dea70bb7

## Revision — 2026-11-04 (after the fourth pass, no new review)
Applied the fourth-pass findings and the user decision:
- Blocking: AC-CS-28 now expects Wood 60 with `herb_growth_pct` +10 → 1.628, plus an over-ceiling case (sources summing to +40 → total 10 with a clamp line → 1.628).
- Penalties after the cap (user decision): every ceilinged key is min(Σ positive, ceiling) + Σ negative; the lifespan bonus is min(pill_years + Σ positive lifespan_years, f_life · L_realm) + Σ negative lifespan_years. A negative lifespan bonus is allowed (no earlier rule bounded it) and can put the cap below the realm's base; Realms rule 14's confirmation applies. Rule 14, Formulas I (expression, variables, output range, example), Parameter keys and the `bonus_ceilings` knob updated; new Edge Cases (+60 −20 → −10; negative lifespan bonus); AC-CS-54 gains +60 −20 → −10, +5 −20 → −15, +8 +6 → 10 and lifespan penalty lines.
- Treasure lifespan: an equipped treasure's lifespan is its `lifespan_years` modifier, counted once; the separate `treasure_years` term is removed from Formulas I (AC-CS-54 line added).
- Source lists: rule 12 now lists nine source kinds, adding Spiritual Roots generating pairs and Item DB consumables and tools (fertilisers, timed pill effects); rule 14 says "every rule 12 source". AC-CS-30 says nine source kinds. The Overview lists craft mastery, consumables and generating pairs.
- Rule 14 gains the root-term test sentence and a pointer for Fire's brew success (Realms Formulas D; Alchemy owns it).
- Dependencies: soft-source row for #14 Spirit Herbs & Spirit Fields; the Item DB row names consumables, tools and lifespan pill years.
- AC-CS-54: a provisional Spirit Fields mastery +6 with a technique +8 → 10 line, with the craft named as its source.
- Formulas G: variable rows for `herb_growth_pct`, `mission_income_pct` and `total(field_plots)`; the output range says herb growth runs 0 to 1.98.
- Tuning Knobs and Formulas I prose no longer quote Realms' ceiling-run figures; they point to `bonus_ceiling_target` and AC-CG-60. The safe range is narrowed to at most the current values (5–10, 2–3, 0.10–0.15) until the bot run confirms headroom.
- Open Question 1 no longer gives Spiritual Roots' status.
No tuned values changed.

## Revision — 2026-11-04 (Time root factor, plots as a build; no new review)
Applied the user-approved changes (Realms is being changed to the same wording):
- Formulas G: herb growth is now `(1 + k_h · purity_wood) · (1 + herb_age_root_pct / 100) · max(0, 1 + herb_growth_pct / 100)`. New variable row for `herb_age_root_pct` (25 for a Time (Thời Gian) mutation holder, else 0; source: Time's effects in `character_elements.json`, kind "root", added by the data pass). It is a root term: set by the mutation, never a sheet modifier, not under the herb growth ceiling. Output range maximum is now 2.475 (1.8 × 1.25 × 1.10); new example Wood 60 with Time and +10 → 2.035.
- Rule 14, root-term test: a root term is a purity factor or a mutation's declared root factor (today only Time's `herb_age_root_pct`); every other mutation modifier is a sheet modifier and is capped. Time's herb aging joins the list of uncapped root terms.
- Rule 14, `field_plots` not capped: a deliberate build lever; extra plots can beat the breakthrough odds, and Realms' targets assume none (user decision 2026-11-04).
- AC-CS-28: new fixture Wood 60, Time held, +10 → 2.035; the +25 is not shown as a sheet modifier and has no clamp line.
- Status line updated; awaiting re-review.

## Cleanup — 2026-11-04 (cross-GDD review 04g fixes; no new review)
Applied the user-approved wording fixes from `gdd-cross-review-2026-11-04g.md`:
- C9: Formulas G `herb_age_root_pct` range is now "0, or Time's value (25 today; a Spiritual Roots knob, safe 0–68; registry `herb_age_root_pct`)"; the output range reads "up to 1.8 × (1 + herb_age_root_pct/100) × 1.10: 2.475 at 25".
- C13: the Interactions row for Spiritual Roots and Dependencies row 6 name Time's root factor `herb_age_root_pct` (kind "root") for Formulas G.
- C15: the canh-gioi.md Cross-References row names Realms Formulas D (pill supply reads `herb_growth_pct`, `alchemy_success` and h) and `bonus_ceiling_target` (AC-CG-60).
No tuned values changed.

## Revision — 2026-11-04 (after cross-GDD review 04g: holder-raised ceilings; no new review)
Applied the user-approved rulings F15, C5 and F14 from `gdd-cross-review-2026-11-04g.md`:
- F15, rule 14: new "Holder-raised ceilings" bullet. A craft mutation may raise one `bonus_ceilings` key for its holder to a stated value, declared as an effect of kind "ceiling_raise" (key, value). Raises on one key do not stack (highest applies); the sheet shows the raised ceiling with its source; penalties still apply after the raised cap. Today Pill Fire `alchemy_success` 3 → 6 and Spirit Farming `herb_growth_pct` 10 → 20; Spiritual Roots owns which mutations raise what, the values and the prices.
- F15, Formulas I: `ceiling(k) = max(base_ceiling(k), max_j raise_j(k))`; variable table split into base_ceiling(k), raise_j(k) and ceiling(k); examples add the Pill Fire holder (+2 +2 +3 → 6) and non-holder (→ 3).
- F15, consequential fixes: the Spirit Farming examples in rule 14, Formulas I, Edge Cases and AC-CS-54 assumed the base ceiling 10. They now read: on its holder, +60 → 20 (with −20 → 0); the −10 example is kept for a non-holder. Formulas G's `herb_growth_pct` range and output range now name the raised ceiling (2.16 for a Spirit Farming holder without Time; 2.7 only if one character could hold Time and Spirit Farming).
- F15, Parameter keys: new `character_elements.json` entry listing the effect kinds this GDD reads ("root", and new "ceiling_raise" with validation). Interactions row and Dependencies row 6 name the new kind.
- F15, Tuning Knobs: new row for the raises, marked as Spiritual Roots knobs.
- F15, Edge Cases: two raises on one key; a raise that is lost.
- F15, AC-CS-54: new lines for the Pill Fire holder (+2 +2 +3 → 6, clamp line naming the raise), Pill Fire plus another raise to 5 (→ 6), a non-holder (→ 3), and a holder with a −2 penalty (→ 4).
- C5: Formulas I prose and the Tuning Knobs `bonus_ceilings` row say `bonus_ceiling_target` covers lives without root factors beyond Wood, without holder raises and without extra plots, per Realms AC-CG-60.
- F14: rule 14 (after the tree cap) and Formulas I point to Realms Formulas C's q-extras ceiling on the summed per-attempt extras; its value is not defined here.
- Status line updated; awaiting re-review.
No base ceiling values changed.

## Cleanup — 2026-11-04 (user decisions after cross-GDD review 04g; no new review)
User decision 2026-11-04: Lava, a stable mutation, raises `alchemy_success` 3 → 5 for its holder. Rule 14's "Holder-raised ceilings" now says "a mutation may raise…" (was "a craft mutation") and lists Lava with Pill Fire and Spirit Farming; raises still do not stack (highest applies; a Pill Fire and Lava holder gets 6). The same wording and the Lava raise are applied in Formulas I (raise_j(k) and ceiling(k) rows: alchemy 3, 5 or 6), the `character_elements.json` parameter-key entry, the Tuning Knobs raises row, and the Interactions row for Spiritual Roots. No base ceiling values changed. Status unchanged.

## Revision — 2026-11-04 (Spiritual Roots redesign; no new review)
Aligned to the redesign: variant role lines added to Formulas G; holder-raised ceilings (rule 14, Formulas I, effect kinds, knobs, AC-CS-54) and Time's root factor (Formulas G, AC-CS-28) removed; Stars and Death examples replaced. The bonus ceilings are unchanged.

## Review — 2026-11-05 (independent, ahead of the cross-GDD pass) — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 7 | Recommended: 11
Summary: AC-CS-32 value, lifespan_pct sources, event vitality, talent pill gain, physique role, heart demon threshold, fortune check.
Prior verdict resolved: Yes
Resolution: Fixed the same day by the reviewing agent under decisions from the main session, with the user's mandate to accept the right fixes. A cross-GDD review then found no blockers (design/gdd/gdd-cross-review-2026-11-05.md). The fixes have not had their own solo re-review. The hashes stamp the files as reviewed, before those fixes.
Reviewed-Content-Hash: design/gdd/character-stats.md 55d9ae80692694927176c65f7603cb63f1cab407
Reviewed-Content-Hash: design/registry/entities.yaml 598fceae60b85a79be6a2763e0bba270d5e0f684
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/systems-index.md 316bd191788182445931fcf87c1dae09c7ac0fbd
Reviewed-Content-Hash: design/gdd/game-concept.md 97d16997e271c1a187365e08392eab74f8ed60e2
Reviewed-Content-Hash: design/gdd/canh-gioi.md bab602ac6aefc7a4e8589f7078e93f28560c930c
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md a9ddc4cd7fdba22c937c6afa9bb916ad1a2827db
Reviewed-Content-Hash: design/gdd/linh-can.md f88b04a3e103bc0e817ff0ef33948dd9e7d14227

## Review — 2026-11-10 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean; report-only, unattended, no files edited)
Blocking items: 4 | Recommended: 6 | Minor: 4 | User decisions: 4
Summary: The arithmetic still reproduces (about 70 values recomputed). The 2026-11-10 "no caps" change reached rule 14 and Formulas G and I but not Edge Cases, the ACs, Tuning Knobs, the Formulas I output range, the registry or Realms, and rule 15's key list no longer matches the Modifier System's Stat List. Full report: reviews/character-stats-review-2026-11-10.md.
Prior verdict resolved: Partly (2026-11-05 fixes stand; new drift from the 2026-11-09/10 revisions)
Findings:
- [BLOCKING] CS-01 Edge Cases, AC-CS-28/52/54/56, Formulas I output range, Tuning Knobs: ceiling semantics and numbers contradict the curves
- [BLOCKING] CS-02 Formulas I: alchemy_success dampen divides by zero at total <= -100; Modifier System floors a dampened sum at 0 and lists the key as F
- [BLOCKING] CS-03 Registry: bonus_ceilings, lifespan_cap, bonus_ceiling_target, stat_precision_grid and the tree cap key name conflict with the GDD
- [BLOCKING] CS-04 Rule 15: resist_cap_pct retired, seven Stat List keys missing, no "points" unit
- [RECOMMENDED] CS-05 Rule 12 source kinds, Interactions table and Cross-References miss the Way, tribulation, quests, Modifier System, Effects, Combat sub-GDDs
- [RECOMMENDED] CS-06 Realms still has ceilings, the 12-plot clamp and additive p_brew
- [RECOMMENDED] CS-07 "kill/defeat" vs Combat's knockout; no fight-loss vitality rule; Open Question 2 stale
- [RECOMMENDED] CS-08 No AC for purity above 100; field_plots row stale
- [RECOMMENDED] CS-09 Curve outputs vs the precision grid and the held-back lifespan case
- [RECOMMENDED] CS-10 Meridian Map redraw: capability ids and the lifespan_pct keystone unverified
- [MINOR] CS-11 header status/dates; CS-12 AC label and tolerance slips; CS-13 wording sweep; CS-14 Player Fantasy absent (advisory)
Reviewed-Content-Hash: design/gdd/character-stats.md a909d5d7a93bb21705a6c1cebcbc71db34062651
Reviewed-Content-Hash: design/registry/entities.yaml fb908ecd77913491aedb1b35089f77a6390a59ba
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md e905183a564a46d236b23cfb5758ef5cac358ff8
Reviewed-Content-Hash: design/gdd/linh-can.md bc26ba79399663c249c2488bf79f97487b1598c3
Reviewed-Content-Hash: design/gdd/cong-phap.md 747c3aa1bab3b24cbb70f4803581b3622a42c44d
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b92f9946089a4d7e2d58062b33d1a328f2cda751
Reviewed-Content-Hash: design/gdd/modifiers.md 3f29eaaa9182b127e2f067e4921d84de403a4c3b
Reviewed-Content-Hash: design/gdd/combat.md dd287950cbad5094bdbe0e74852c90de9241f61a
Reviewed-Content-Hash: design/gdd/combat-defence.md 939cb75414034b37ab04468ef72a7fbb61419f7f
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 2a7884cd8be1c91b74aef27d6b254baae48235e3
Reviewed-Content-Hash: design/gdd/effects.md 7527907f89207a65be65e0e1582ab16d0f4c82f6
Reviewed-Content-Hash: design/gdd/dao.md a16e45d5d5c107c6acb4dd2a508c8f0f7815aada
Reviewed-Content-Hash: design/gdd/game-concept.md 88eba239210164e778fac6959cb6ee24da039f6d
Reviewed-Content-Hash: design/gdd/systems-index.md 0c622ddc1431192f45cc3ed7a9842b795bbbd013
Reviewed-Content-Hash: design/glossary.md 0b3cf7dcb934aeb999bbc996c5eb80d200bd0ac1

## Review — 2026-11-10 (confirming re-review) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 4
Summary: The answers and fixes of the earlier 2026-11-10 review are present and the recomputed numbers hold. The tree's 8 pp clamp is still stated in Formulas I and one Edge Case against rule 14's curve, and a few listed fixes (Tuning Knobs row, alchemy floor in the formula, AC-CS-28's 1.5826) are not applied. Report: reviews/character-stats-rereview-2026-11-10.md.
Prior verdict resolved: Yes, except as listed
Findings:
- [BLOCKING] Formulas I / Edge Cases: tree breakthrough_chance still a min() clamp, contradicts the curve in rule 14
- [RECOMMENDED] Tuning Knobs: bonus_curves row still has ceiling wording and the 2-3 range
- [RECOMMENDED] Formulas I: alchemy_success formula lacks the floor at 0
- [RECOMMENDED] Rule 9 / Formulas F: fight-loss vitality line missing
- [RECOMMENDED] AC-CS-28: Wood 60 +10 is 1.5826, not 1.582, at 1e-6
- [MINOR] leftover ceiling words, points-unit grid, AC-19 wording, purity-150 coverage, field_plots row, header
Reviewed-Content-Hash: design/gdd/character-stats.md 5e365f68fb3fbe54cf8eb0935fb9a6be461055e0
Reviewed-Content-Hash: design/registry/entities.yaml e39b9de2e2ec2a87abf7165ff67417d06385d5bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 4d3a98fb4eb2f588d26095ed91c8e6e2457b20e8
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md d229603fe4fae7df7ceae1dac3c5b98a67f156b2
Reviewed-Content-Hash: design/gdd/linh-can.md 1de5075a08701c52dc4ec238fdcd106c8de56e57
Reviewed-Content-Hash: design/gdd/cong-phap.md eebee87a8b02af50a2a516427e20594814e983bc
Reviewed-Content-Hash: design/gdd/modifiers.md af999b8be75e7b06c29806ee2f57cfca85d3cf9a
Reviewed-Content-Hash: design/gdd/effects.md cea9de5c3da6afad036851ee9a9e6e6da2624e1f
Reviewed-Content-Hash: design/gdd/dao.md 43e23bfbdc06222d4b7dba2fe9d281f714d04304
Reviewed-Content-Hash: design/gdd/combat.md 82808aa10ffa17d0e7d2c4d4939c1899c509aa28
Reviewed-Content-Hash: design/gdd/combat-defence.md e5d35f785122c2e04b4f74e03564e6482c01d980
Reviewed-Content-Hash: design/gdd/combat-damage-types.md f465de9486301d5733e3c86fbabae830a0b94a8c
Reviewed-Content-Hash: design/gdd/game-concept.md 88eba239210164e778fac6959cb6ee24da039f6d
Reviewed-Content-Hash: design/gdd/systems-index.md 49e72f85b34236f531111fa88d9ece7d3e4d2161
Reviewed-Content-Hash: design/glossary.md 0b3cf7dcb934aeb999bbc996c5eb80d200bd0ac1
