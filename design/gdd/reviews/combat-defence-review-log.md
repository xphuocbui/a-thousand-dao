# Review Log — Combat Defence & Healing (`design/gdd/combat-defence.md`)

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 9
Summary: First independent review (overnight, autonomous). All 6 required sections are present and every worked example and fixture recomputes: Formulas A–I examples, the 14-ward catalogue's price-check ratios and limits, the block_unit table and all of AC-CD-06 to AC-CD-58. All 23 registry constants owned by this GDD match. Two gaps block: the registry's `defence_shield` output range says 1.0 × health_max, while Formulas B allows 2.0 × (ward plus body), and Formulas C bills drain only for resistance payloads, although rule 8 lets any non-shield ward be drain-paid and Formulas G already assumes a drain-paid block bill.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas B / registry: `defence_shield` output_range "0 to 1.0 x health_max per side" contradicts Formulas B's "at most 2 × health_max" (1 × ward shields, 1 × body shield). Registry needs the fix; the GDD is the newer, consistent source.
- [BLOCKING] Formulas C / rule 8: drain billing is defined only as `prevented_w = D · r_eff · r_w / R_pos` (resistance). No bill is given for a drain-paid block, evade, status or soul payload, yet Formulas G uses `rate_w · B_w / D_ref` for drain-paid block. A programmer must guess.
- [RECOMMENDED] Rule 9 / Edge Cases: `shield_total_cap` clipping is not stated as applying to maximum sizes at compile or to live totals (a cast shield refiring while others are full).
- [RECOMMENDED] Formulas E stall check: the floor-0.25 counterfactual "41 s" recomputes to about 43.8 s in a continuous model (the 0.10 case, 37.6 s, recomputes to about 37.4 s). The conclusion (a stall) holds; confirm the figure with the harness.
- [RECOMMENDED] Dependencies: bidirectional mentions still missing in combat.md (#43 revision), character-stats.md (Parameter keys), thien-kiep.md rule 7 (`no_heal`) and item-database.md (body-gear mapping). All planned.
- [RECOMMENDED] Open Questions 10 and 14: the registry already holds the listed entities (resist_cap … defence_lambda_min, defence_block) and marks body guard and the old ward superseded; close or narrow them.
- [RECOMMENDED] Open Question 1 and Formulas I say "when the Modifier System resumes"; modifiers.md is now designed and its Stat List carries `resist_pen_pct`, `block_rating`, `body_shield_pct`, `bonus_ward_slots`. Narrow OQ 1 to the price check of its existing defence rows.
- [RECOMMENDED] Header status line still says "pending an independent /design-review"; update once revisions land.
- [RECOMMENDED] AC numbering: AC-CD-53 to 58 sit between 46 and 47. Renumbering would break OQ references, so it is left as is.
- [ADVISORY] Player Fantasy section absent (advisory at `standard`).
- [ADVISORY] Tuning Knobs section absent (advisory at `standard`); knobs are spread over the Formulas variable tables with no safe-range column.
Safe fixes applied after this review (overnight pass 1): 14 wording, stale-term and cross-reference fixes; see `overnight-2026-11-08-decisions.md`. The hash below is the content as reviewed, before those fixes, so the next run re-reviews in full.
Reviewed-Content-Hash: design/gdd/combat-defence.md 977bb0e3cfcab21eb81ba1592a9f9c1652b1c2ea
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 43ca9e14491a915cc99402f4dab0c197c2d0482c
Reviewed-Content-Hash: design/gdd/modifiers.md 06a71d2cd7d4cb3b4f5cd8ddb580ca7e22e92dfd
Reviewed-Content-Hash: design/gdd/effects.md 5c4b4d985ea4cfffaf39c34a862bdc2244dfb066
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 9
Summary: Re-review (overnight pass 2). Since pass 1 the GDD changed only by that pass's 14 safe fixes, so both pass-1 blockers still stand. One new defect joins blocker 2: the drain bill turns negative (a refund) when penetration pushes r_eff below 0, which contradicts Formulas C's output range "every payment ≥ 0". All worked examples, catalogue ratios and AC-CD-01 to 58 were recomputed again. One prose figure was wrong (the fast kit against block builds, ×0.66 should be ×0.57) and was fixed. All six required sections are present, and every dependency GDD file exists.
Prior verdict resolved: No (the pass-1 blockers are not addressed; nothing but safe fixes has been applied)
Findings:
- [BLOCKING] Formulas B / registry: `defence_shield` output_range "0 to 1.0 x health_max per side" contradicts Formulas B's 2 × health_max (separate ward and body caps). Rule 9's wording ("a side's shields together") also read as one cap. That wording was fixed tonight; the registry still needs its fix.
- [BLOCKING] Formulas C / rule 8: drain billing is defined only for resistance payloads (no bill for drain-paid block, evade, status or soul, though Formulas G assumes one for block). `prevented_w = D · r_eff · r_w / R_pos` goes negative when r_eff < 0 and is undefined at R_pos = 0.
- [RECOMMENDED] Rule 9 / Edge Cases: `shield_total_cap` clipping timing (maximum sizes at compile, or live totals) is still unstated.
- [RECOMMENDED] Formulas E stall check: the "41 s" floor-0.25 counterfactual recomputes to about 43.8 s in a continuous model; confirm it with the harness.
- [RECOMMENDED] Dependencies: bidirectional mentions are still missing in combat.md (#43), character-stats.md, thien-kiep.md rule 7, item-database.md, cong-phap.md and dao.md.
- [RECOMMENDED] Open Questions 10 and 14: the registry already holds most of the listed entities; close or narrow them.
- [RECOMMENDED] Open Question 1 / Formulas I: "when the Modifier System resumes" is stale; modifiers.md is designed and carries the keys.
- [RECOMMENDED] AC order: AC-CD-53 to 58 sit between 46 and 47.
- [RECOMMENDED] Thể tu fixture (Formulas G, AC fixtures): R_Physical 0.30, but the listed sources give only 0.20 (Iron Body tier 3). The other 0.10 (presumably an armour affix) is unnamed.
- [RECOMMENDED] Formulas A2 fast-kit table: the thể tu fast hit reads 4.33, and D 24.8 recomputes to 4.35. That is within tolerance, but the table implies D ≈ 24.75; state the exact D.
- [RECOMMENDED] Formulas C: penetration can push r_eff to the floor while a drain ward still "prevents" nothing. Say whether a drain ward bills 0 or stays Up at no cost in that case (covered by blocker 2's fix).
- [ADVISORY] Player Fantasy section absent (advisory at `standard`).
- [ADVISORY] Tuning Knobs section absent (advisory at `standard`).
Safe fixes applied after this review (overnight pass 2): 11; see `overnight-2026-11-08-decisions.md`. The hash below is the content after those fixes.
Reviewed-Content-Hash: design/gdd/combat-defence.md 43bcf8a6b1b100813f43a6ef087c050b738a84c2
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 2d2064c3bb057e4f76c9c44822fdd443cd510298
Reviewed-Content-Hash: design/gdd/modifiers.md f98f94566e196d300bbdf2d0ab8b5124f5b02a1f
Reviewed-Content-Hash: design/gdd/effects.md 38e5f9d742333c563889f44184c008f8877886ce
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 9
Summary: Re-review (overnight pass 3). The freshness check found this GDD, the registry and the skill byte-identical to pass 2; only combat-damage-types.md, modifiers.md and effects.md had changed. Following the skill, the prior verdict stands except for cross-document facts, which were re-checked against those diffs: status lines, a 15.90→15.91 rounding in AC-DT-19 (not restated here), linh-can rule renumbering (not cited here), the both-saved wording in Effects, and modifiers rule 6 wording. Every rule number this GDD cites in those files (Damage Types rules 2, 4–7, 14; Modifier System rule 13; `bonus_ward_slots`) still matches. No conflict, so both pass-2 blockers and all recommendations carry over unchanged.
Prior verdict resolved: No (the blockers need user decisions; only safe fixes have been applied)
Findings:
- [BLOCKING] Formulas B / registry: `defence_shield` output_range "0 to 1.0 x health_max per side" contradicts Formulas B's 2 × health_max (separate ward and body caps). Carried from passes 1–2.
- [BLOCKING] Formulas C / rule 8: drain billing defined only for resistance payloads; `prevented_w` goes negative when r_eff < 0 and is undefined at R_pos = 0. Carried.
- [RECOMMENDED] Rule 9 / Edge Cases: `shield_total_cap` clipping timing unstated. Carried.
- [RECOMMENDED] Formulas E stall check: "41 s" recomputes to about 43.8 s continuous. Carried.
- [RECOMMENDED] Dependencies: bidirectional mentions missing in combat.md, character-stats.md, thien-kiep.md, item-database.md, cong-phap.md, dao.md. Carried.
- [RECOMMENDED] Open Questions 10 and 14: mostly done in the registry; close or narrow. Carried.
- [RECOMMENDED] Open Question 1: scope should narrow to checking modifiers.md's defence prices (its stale timing wording fixed this pass). Carried in part.
- [RECOMMENDED] AC order: AC-CD-53 to 58 sit between 46 and 47. Carried.
- [RECOMMENDED] Thể tu fixture: R_Physical 0.30 but named sources give 0.20. Carried.
- [RECOMMENDED] Formulas A2 fast kit: state the exact D (24.75 vs 24.8). Carried.
- [RECOMMENDED] Formulas C: drain ward billing when penetration floors r_eff (part of blocker 2's fix). Carried.
- [ADVISORY] Player Fantasy and Tuning Knobs sections absent (advisory at `standard`).
Safe fixes applied after this review (overnight pass 3): 3 (Formulas I "when it resumes" wording, OQ 1 timing cell, header status pass count); see `overnight-2026-11-08-decisions.md`. The hash below is the content after those fixes.
Reviewed-Content-Hash: design/gdd/combat-defence.md c6eed88fdf2385044541ac202edfcbbc620b3905
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 523651072ba2500c0683fb98a7973567b961c1f8
Reviewed-Content-Hash: design/gdd/modifiers.md e24ada0e3825948d7f0413534d47c90ef78aa462
Reviewed-Content-Hash: design/gdd/effects.md c08c8a88fd73e52dc363b53a2b5264e32a04f351
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 9
Summary: Re-review (overnight pass 4). The freshness check found this GDD, the registry, the skill, combat.md, thien-kiep.md and game-concept.md byte-identical to pass 3. Only combat-damage-types.md, modifiers.md and effects.md had changed, and per the pass-3 decision log each change was its own header status line ("three passes" / "passes 1–3"). No rule, value or rule number this GDD cites moved, so the prior verdict stands and every finding carries over.
Prior verdict resolved: No (the blockers need user decisions; only safe fixes have been applied)
Findings:
- [BLOCKING] Formulas B / registry: `defence_shield` output_range "0 to 1.0 x health_max per side" contradicts Formulas B's 2 × health_max (separate ward and body caps). Carried from passes 1–3.
- [BLOCKING] Formulas C / rule 8: drain billing is defined only for resistance payloads; `prevented_w` goes negative when r_eff < 0 and is undefined at R_pos = 0. Carried.
- [RECOMMENDED] Rule 9 / Edge Cases: `shield_total_cap` clipping timing unstated. Carried.
- [RECOMMENDED] Formulas E stall check: "41 s" recomputes to about 43.8 s continuous. Carried.
- [RECOMMENDED] Dependencies: bidirectional mentions missing in combat.md, character-stats.md, thien-kiep.md, item-database.md, cong-phap.md and dao.md. Carried.
- [RECOMMENDED] Open Questions 10 and 14: mostly done in the registry; close or narrow them. Carried.
- [RECOMMENDED] Open Question 1: narrow it to checking modifiers.md's defence prices. Carried.
- [RECOMMENDED] AC order: AC-CD-53 to 58 sit between 46 and 47. Carried.
- [RECOMMENDED] Thể tu fixture: R_Physical 0.30, but the named sources give 0.20. Carried.
- [RECOMMENDED] Formulas A2 fast kit: state the exact D (24.75 vs 24.8). Carried.
- [RECOMMENDED] Formulas C: drain ward billing when penetration floors r_eff (part of blocker 2's fix). Carried.
- [ADVISORY] Player Fantasy and Tuning Knobs sections absent (advisory at `standard`).
Safe fixes applied after this review (overnight pass 4): 1 (header status "three passes" became "four passes"); see `overnight-2026-11-08-decisions.md`. The hash below is the content after that fix.
Reviewed-Content-Hash: design/gdd/combat-defence.md 5cc84b8b2fdf8472501e12f7a16ed75b66e7848d
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 19ff78c01791abc93f0b908ca250d0ef59f53c51
Reviewed-Content-Hash: design/gdd/modifiers.md 20ff37b70820cf176aa8afd907f61c1732c33093
Reviewed-Content-Hash: design/gdd/effects.md 380b5401e2e4a4654cd4f2e5629faa4d2d14be85
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
