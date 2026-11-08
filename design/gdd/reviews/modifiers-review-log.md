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
