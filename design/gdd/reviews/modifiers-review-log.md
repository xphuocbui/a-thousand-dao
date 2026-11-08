# Modifier System — Review Log

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 12
Summary: The math holds up. Every catalogue value, the 195 count, the Formulas B–D examples and AC-MD-04/05/06/16–20 were recomputed and all match. `tools/design/modifier_catalogue.py` reproduces the General Catalogue exactly, and the registry entries match. The two blockers are both about what an implementer has to guess: rule 8 gives no matching rule for several targets the Stat List uses, and the typed-resistance W in the Stat List is a price with breadth already folded in, so applying Formulas C to it literally counts breadth twice. Seven safe fixes were applied unattended (stale statuses, duplicated L5 wording, role-tag names, a formatting break).
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules, rule 8: the Stat List uses the targets "heal (its tags)", "reservation", "outgoing status", "basic attack" and "outgoing soul hit", and rule 8 defines none of them (it has only incoming status). Scope validation and matching for healing, status duration ([curse], [poison]) and reservation cannot be built from the rule.
- [BLOCKING] Stat List / Formulas A–C, typed resistance: the W column reads 1.0 Physical/Force and 0.83 others "per pp effective". The generator uses 1.25 × breadth (1.25 / 1.5 → 1.0 / 0.83). Formulas C with price 1.0 and breadth 1.25 gives +1.5 pp, not the catalogue's +1.2 pp. AC-MD-21 (data equals Formulas A) cannot be met without knowing which number goes in `modifier_prices`.
- [RECOMMENDED] Core Rules, rule 13 / Rare table: ward slots (`bonus_ward_slots`, 30 W, rare) and the resistance cap raise (5 W, rare) are not in rule 13's list or the Rare table, and 30 W is outside the stated 10–25 W.
- [RECOMMENDED] General Catalogue, resistance: Chaos-scoped resistance appears as an ordinary family row, but Combat Damage Types rule 5 says Chaos resistance comes only from rare sources (Open Question 6).
- [RECOMMENDED] Formulas C: B's range is "0 to about 60 W", but the Output Range is computed at 25.8 W (215 units). At 60 W it is 500 units.
- [RECOMMENDED] Formulas note: says "reservation kept as Pending", but the Stat List has `reserve_eff_pct` as Designed (Combat Defence & Healing rule 10).
- [RECOMMENDED] Core Rules, rule 4: "regeneration as a share of maximum per second". Health regeneration is per pulse (Stat List) and linh lực regeneration is per second.
- [RECOMMENDED] Interactions: Combat Defence & Healing (#21a) and Combat Damage Types (#21b) are in Dependencies but have no Interactions rows.
- [RECOMMENDED] Dependencies: these do not list this system yet: Character Stats, Meridian Map, The Way, Cultivation Techniques, Item DB, Artifact Refining, Alchemy, Formations, Talismans, Spirit Beasts, Edges, Spiritual Roots and NPC Builds.
- [RECOMMENDED] Open Questions, OQ 8: mostly done. The registry already holds modifier_value, breadth_mult, more_price, grade_small, grade_notable and breadth_multipliers, and stat_power_weights has moved to this GDD.
- [RECOMMENDED] Header: the status line still says "pending an independent /design-review".
- [RECOMMENDED] Formulas D: writes `L_i_typ(r)` as realm-indexed, but the variable table gives fixed values (L2 1.4, L4 1.2).
- [RECOMMENDED] Tuning Knobs section absent (advisory at standard): breadth multipliers, grades, the rounding-lint threshold of 15 %, the scope tag limit of 2 and the derived-tag thresholds are knobs with no ranges.
- [RECOMMENDED] Player Fantasy section absent (advisory at standard). Game Feel covers most of it.
Reviewed-Content-Hash: design/gdd/modifiers.md f98f94566e196d300bbdf2d0ab8b5124f5b02a1f
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md 5c4b4d985ea4cfffaf39c34a862bdc2244dfb066
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 15d21872a1ffe0a4f78498c0305445a60db728e9

## Review — 2026-11-08 (pass 2) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 12
Summary: Receipt check: modifiers.md, the registry, this skill and the catalogue generator were byte-identical to pass 1; only effects.md had changed (its own pass-1 safe fixes). Per the skill, the prior verdict stands and only cross-document facts were re-verified. effects.md's new citations (modifiers.md rules 1, 6, 9, 16; L5 granted only from Effects; spiritual roots as a host) agree with this GDD. No new conflicts. The pass-1 findings stand unchanged because no design revision has been made yet. Two stale status lines were fixed (header, Effects dependency status).
Prior verdict resolved: No (document not revised; blockers still open)
Findings:
- [BLOCKING] Core Rules, rule 8: still no matching rule for the heal, reservation, outgoing-status, basic-attack and outgoing-soul-hit targets (pass 1 item 1).
- [BLOCKING] Stat List / Formulas A–C, typed resistance: W 1.0 / 0.83 is a breadth-adjusted price; Formulas C double-counts breadth (pass 1 item 2).
- [RECOMMENDED] Pass-1 recommended items 3–10, 12–14 stand unchanged. Item 11 (header status line) was fixed in this pass.
- [RECOMMENDED] Cross-References: no row for effects.md, though effects.md cites rules 1, 6, 9, 16 and Interactions/Dependencies name it.
Reviewed-Content-Hash: design/gdd/modifiers.md e24ada0e3825948d7f0413534d47c90ef78aa462
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md 38e5f9d742333c563889f44184c008f8877886ce
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 15d21872a1ffe0a4f78498c0305445a60db728e9

## Review — 2026-11-08 (pass 3) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 13
Summary: Receipt check: modifiers.md, the registry, this skill and the catalogue generator were byte-identical to pass 2. Only effects.md had changed, and its diff is its own pass-2 status-line fixes. Per the skill, the prior verdict stands and only cross-document facts were re-verified: effects.md still cites modifiers.md rules 1, 6, 9 and 16 correctly (L5 only from Effects matches rule 6), and AC-EF-03's `body_shield_pct` is in the Stat List. The rule numbers this GDD cites in combat-defence.md (2–4, 6, 9–12, Formulas A–E, I) and combat-damage-types.md (1, 2, 6, 9) still name the intended rules. Every "body guard" mention is a retirement record. No new conflicts, so the pass-1 findings stand. One safe fix was applied: the header now says passes 1–3.
Prior verdict resolved: No (document not revised; blockers still open)
Findings:
- [BLOCKING] Core Rules, rule 8: still no matching rule for the heal, reservation, outgoing-status, basic-attack and outgoing-soul-hit targets (pass 1 item 1).
- [BLOCKING] Stat List / Formulas A–C, typed resistance: W 1.0 / 0.83 is a breadth-adjusted price; Formulas C double-counts breadth (pass 1 item 2).
- [RECOMMENDED] Pass-1 recommended items 3–10 and 12–14, plus the pass-2 Cross-References/effects.md row, stand unchanged.
Reviewed-Content-Hash: design/gdd/modifiers.md 20ff37b70820cf176aa8afd907f61c1732c33093
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md c08c8a88fd73e52dc363b53a2b5264e32a04f351
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 15d21872a1ffe0a4f78498c0305445a60db728e9
Reviewed-Content-Hash: design/gdd/combat-defence.md c6eed88fdf2385044541ac202edfcbbc620b3905
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 19ff78c01791abc93f0b908ca250d0ef59f53c51

## Review — 2026-11-08 (pass 4) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 13
Summary: Receipt check: modifiers.md, the registry, this skill and the catalogue generator were byte-identical to pass 3. effects.md, combat-defence.md and combat-damage-types.md had changed (their own overnight safe fixes). Per the skill, the prior verdict stands and only cross-document facts were re-verified. combat-damage-types.md rule 2 now says penetration reads the final type, which the Stat List's `resist_pen_pct` row already says. combat-defence.md still cites this GDD's rule 13 for ward slots, and its stat keys (`resist_pen_pct`, `reserve_eff_pct`, `healing_pct`, `healing_taken_pct`, `health_regen_pct`, `bonus_ward_slots`, `body_shield_pct`) are all in the Stat List. effects.md still cites rules 1, 6, 9 and 16 correctly. No new conflicts. One safe fix: the header now says passes 1–4.
Prior verdict resolved: No (document not revised; blockers still open)
Findings:
- [BLOCKING] Core Rules, rule 8: still no matching rule for the heal, reservation, outgoing-status, basic-attack and outgoing-soul-hit targets (pass 1 item 1).
- [BLOCKING] Stat List / Formulas A–C, typed resistance: W 1.0 / 0.83 is a breadth-adjusted price; Formulas C double-counts breadth (pass 1 item 2).
- [RECOMMENDED] Pass-1 recommended items 3–10 and 12–14, plus the pass-2 Cross-References/effects.md row, stand unchanged.
Reviewed-Content-Hash: design/gdd/modifiers.md d01b987c1026aa78f19e39511c75c1bacc7c1e34
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md 380b5401e2e4a4654cd4f2e5629faa4d2d14be85
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 15d21872a1ffe0a4f78498c0305445a60db728e9
Reviewed-Content-Hash: design/gdd/combat-defence.md 5cc84b8b2fdf8472501e12f7a16ed75b66e7848d
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d513b0cc9b2fe6f9f8b59712024c003c4db08aee

## Review — 2026-11-08 (daytime re-review, pass 1) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 12
Summary: Full fresh review of the document revised this morning. Both overnight blockers are resolved: rule 8 now defines all five targets, and `resist_pct` has one stored price of 1.25 that Formulas A and C, the Stat List, the Rare table and the generator agree on. The numbers hold: Formulas B–D, the examples, the ACs and the defence prices against Combat Defence Formulas I all recompute, and the generator's catalogue reads the same as the GDD (224 modifiers). Two new blockers are rules an implementer would have to guess: a damage-type scope on a stat that applies to a whole hit or a whole art (crit is one roll per hit, but a hit can have several types), and the Designed resistance row [fire, over_time], which rule 8 and Defence rule 3 do not allow. 21 safe fixes applied.
Prior verdict resolved: Yes (both overnight blockers); new blockers found
Findings:
- [BLOCKING] Rule 8, Stat List, General Catalogue: type-scoped crit chance, art speed and art cost have no rule for hits or arts with several types. Combat rolls crit once per hit (Formulas C, AC-CB-22); rule 8 matches a part's tags.
- [BLOCKING] Rule 8, General Catalogue: the Designed row resistance [type + family tag], e.g. [fire, over_time], contradicts "final damage type only" and Defence rule 3, so it would fail rule 8's own validation.
- [RECOMMENDED] Rule 12, Summary: "every value is priced in W" contradicts Effects rules 3–4 (payload values are the designer's, unpriced). Rule 13's source kinds do not say whether an Effect may carry a rare modifier.
- [RECOMMENDED] Rule 9, rule 11: status tags and [body_shield] have no vocabulary family. Effects' status tags do not match them (Burn carries `fire`, Qi Disruption has no `qi_burn`).
- [RECOMMENDED] Stat List: cheap lower-is-better stats have no named floor. Two notables of formation upkeep or talisman ink reach −106.6 %, so the cost is free.
- [RECOMMENDED] Formulas A, AC-MD-21: `body_shield_pct` and `attack_pct` have two prices or ops on one key; "one W price" per key cannot hold them.
- [RECOMMENDED] Acceptance Criteria: no AC covers the heal, reservation, outgoing-status, basic or soul targets, or the rare-by-row rule.
- [RECOMMENDED] Dependencies, Interactions: Market, Time & Turn, Realms, Spirit Herbs, Sects and Travel own Stat List rows but are not listed.
- [RECOMMENDED] Dependencies: back-references are still missing in the reader GDDs (carried).
- [RECOMMENDED] Formulas E, Tuning Knobs: the 15 % lint flags three catalogue pairs (breakthrough small 16.7 %, typed block broad small 20 %, density small floors to 0), and its threshold is not a knob.
- [RECOMMENDED] Cross-document: Damage Types rule 5 calls rare Chaos resistance a "content guideline, not a cap", while rule 13 enforces it in validation.
- [RECOMMENDED] Cross-document: Defence Open Question 1 is answered by this review (all defence rows match Formulas I).
- [RECOMMENDED] Open Questions, OQ 8: the registry's `stat_power_weights` still lacks the full price table (carried).
- [RECOMMENDED] Realm drift, OQ 1: the "no deflator until measured" default is still not a user decision.
Reviewed-Content-Hash: design/gdd/modifiers.md 83069a628589d674abcd5fa8162f183cd948b2be
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md 675919fd8277f2b82b09c81014e8ecce480cfbce
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 40261d1a738f5d0972f8a92cec2b4859066dc4fd
Reviewed-Content-Hash: design/gdd/combat-defence.md da752666e06252aa2820e7c2eeba06b43f561af3
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d5a09b75ed4ddb6bd15ccb5988e5a6edcbb9c5af
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba

## Review — 2026-11-08 (daytime re-review, pass 2) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 14
Summary: Receipt check: this GDD, the registry, this skill, the generator and combat.md were byte-identical to pass 1; effects.md, combat-defence.md and combat-damage-types.md had changed (their own safe fixes). Per the skill, the prior verdict stands and cross-document facts were re-verified; no blocking conflict appeared. The whole GDD was also re-read and its numbers recomputed by hand: the catalogue rows, Formulas B–D, the examples and the ACs all hold. The generator ran and its output reads the same as the GDD by eye (224 modifiers). All 278 registry entry names were searched for the first time (74 hits on 17 terms); none conflicts. Two new recommendations and 3 safe fixes.
Prior verdict resolved: No (document revised only by safe fixes; both blockers still open)
Findings:
- [BLOCKING] Rule 8, Stat List, General Catalogue: type-scoped crit chance, art speed and art cost have no rule for hits or arts with several types (pass 1, carried).
- [BLOCKING] Rule 8, General Catalogue: the Designed resistance row [type + family tag] contradicts "final damage type only" and Defence rule 3 (pass 1, carried).
- [RECOMMENDED] Pass-1 recommended items 3–14 stand unchanged.
- [RECOMMENDED] Formulas A, Artifact defence: the basis "0.51 through ward gear, about 0.35 on body gear" disagrees with Defence Formulas I and AC-CD-57 (0.648 per defence point on both, user decision 2026-11-07). The units differ, so the price itself was not judged.
- [RECOMMENDED] Stat List, Character Stats grid: `health_regen_pct` and `linh_luc_regen_pct` are on the 0.01 grid, but the registry's `stat_precision_grid` puts pct keys on 0.1 and does not list them, and the Stat List does not state their grid.
Reviewed-Content-Hash: design/gdd/modifiers.md 1c088bc23c1bf8767f0d0309f106d034133b7732
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md d0c1c3d6a61d4dfe7c34dbdbb9b977ae941ebe6d
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 40261d1a738f5d0972f8a92cec2b4859066dc4fd
Reviewed-Content-Hash: design/gdd/combat-defence.md e4325d2daf244efd0e86973067b480177d2c412e
Reviewed-Content-Hash: design/gdd/combat-damage-types.md e9ff439387a6274e53c8244d31d9e2164f8209be
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba

## Review — 2026-11-08 (daytime re-review, pass 3) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 16
Summary: Receipt check: this GDD, the registry, this skill, the generator and combat.md were byte-identical to pass 2; effects.md, combat-defence.md and combat-damage-types.md had changed. Per the skill, the prior verdict stands and cross-document facts were re-verified; no conflict appeared and both blockers are still open in the source GDDs. The whole GDD was also re-read, and every catalogue row, Formulas B–D and the numeric ACs were recomputed by hand; the Count column sums to 224. This pass also checked the Formulas A basis notes, which found two wrong (evade, art cost; the prices themselves are unchanged). Registry search not re-run: the registry and GDD were byte-identical to pass 2's full search, which found no conflict. Two new recommendations and 6 safe fixes.
Prior verdict resolved: No (document revised only by safe fixes; both blockers still open)
Findings:
- [BLOCKING] Rule 8, Stat List, General Catalogue: type-scoped crit chance, art speed and art cost have no rule for hits or arts with several types (pass 1, carried).
- [BLOCKING] Rule 8, General Catalogue: the Designed resistance row [type + family tag] contradicts "final damage type only" and Defence rule 3 (pass 1, carried).
- [RECOMMENDED] Pass-1 recommended items 3–14 and pass-2 items 15–16 stand unchanged.
- [RECOMMENDED] Rule 9, Stat List: rule 9 derives each modifier's family tags and domain from the Stat List, but the Stat List has no such column and nothing maps a stat to its tags. AC-MD-14 and AC-MD-15 depend on the mapping.
- [RECOMMENDED] Rule 8, Stat List: the incoming-hit bullet names resistance only, but `resist_cap_pct` shares that target and Defence rule 3 lets a rare raise apply to one damage type or to all.
Reviewed-Content-Hash: design/gdd/modifiers.md 9c1aa20c325fb15a390402079c5f8718bc858038
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/effects.md 1a4a6f1d16dda2da7b6408f4fad1e8f2e46d8cc3
Reviewed-Content-Hash: tools/design/modifier_catalogue.py 40261d1a738f5d0972f8a92cec2b4859066dc4fd
Reviewed-Content-Hash: design/gdd/combat-defence.md df399caecd2077ce49634e2a0660af1b1623b26a
Reviewed-Content-Hash: design/gdd/combat-damage-types.md abcf4805891aba5fe1d9a44a0b164d162cc7cb21
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba

## Review — 2026-11-08b (second re-review, fresh session) — Verdict: APPROVED
Review mode: lean · Workflow: standard · Reviewed at: commit 9400de1 (no content receipts: the document changed the same day)
Scope signal: L
Specialists: none (lean mode)
Blocking items: 0 | Recommended: 9 | Nits: 7 (13 safe, 3 decisions)
Summary: Both carried blockers are closed and `convert_pct` is in as an ordinary modifier. The catalogue matched the generator exactly (266 modifiers). Full report: `rereview-2026-11-08b/modifiers.md`.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] MD-04 (decision) Damage-type scopes on accuracy and realm pierce. User decision 2026-11-08b: forbidden; both are whole-hit stats.
- [RECOMMENDED] MD-08 (decision) Lifespan in years at small, Qi Refining, loses 16.7 %. User decision: a fourth known lint exception.
- [RECOMMENDED] MD-09 (decision) The three plain conversion Effects. User decision: moved to `convert_pct` (effects.md).
- [RECOMMENDED] MD-01 to MD-03, MD-05 to MD-07 and nits MD-10 to MD-16: all applied. The status-scoped resistance row is now Designed (generator label changed; regenerated, still 266). The effect-kind tag family was added to rule 9 (Effects re-review EF-15).
Applied: 2026-11-08, all 16 findings.
