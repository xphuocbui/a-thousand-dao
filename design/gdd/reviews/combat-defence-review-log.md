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

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 4 | Recommended: 13
Summary: Daytime re-review after the user's answers; a full fresh review, not a carried verdict. Both overnight blockers are resolved: the registry's `defence_shield` now describes uncapped shields, and Formulas C, rule 8, AC-CD-60 and the registry's `ward_payment` agree on drain billing. Four new blockers: the soul shield has no formula (and ward strength can scale it past 100 %), `ws`, `we`, `a_w` and `a_b` lose their definition if Combat Formulas D is deleted as rule 1 says, the new drain billing does not cover shared block or a short pool's order, and AC-CD-59 cannot pass as written because its FX-U attacker is fully blocked by the kit under test. All worked numbers were recomputed by hand (a scratch script could not run unattended, because its permission prompt had no one to answer it); 7 small mismatches were fixed.
Prior verdict resolved: Yes (both prior blockers resolved; the fourth new blocker's kit and the third's billing come from those fixes)
Findings:
- [BLOCKING] Rules 6, 9, 14 / Formulas H: the soul shield has no formula. Rule 9 calls a shield a pool, while rule 6 and Soul-Guarding Lamp give a share; rule 6 scales it by ws, so 50 % reaches 100 % at ws 100 and 250 % at ws 400. Combat rule 24 and E2 also say soul hits ignore every ward.
- [BLOCKING] Rule 1 / Dependencies / OQ 2 / Formulas A, A2, B: rule 1 and Dependencies replace "all of Combat Formulas D", OQ 2 says "the ward half". Formulas A gives ws's source as `defense_pct` only, but ws 30.8 needs D's gear term; `we`, `ward_floor`, `a_w` and `a_b` are defined only in D.
- [BLOCKING] Formulas C / rule 8: `blk_w` has no attribution when block comes from several sources (flesh, gear, wards), and no rule says whether a short pool's leak happens before block and shields or what a short pool does to a drain-paid block. AC-CD-22 and AC-CD-60 test neither.
- [BLOCKING] AC-CD-59: against FX-U the kit cannot fall. FX-U's basic hit is 6.31, and the kit's block is about 4.95 rating-derived points (flesh 4.4 + a_b 2.0 gear 24 + tier 5 50) before Physical resistance, so every hit deals 0. Restoring a cap knob cannot fix this, though the AC names that as the remedy. Slow hitters are also untested: at we 400, Mountain Screen recharges 291 per second after its delay.
- [RECOMMENDED] Rule 8 / States / Edge Cases: the cast row "Its duration lasts, or its shield holds" and the Edge Case "until its duration ends or its shield breaks" conflict with States (non-shield payloads stay up on a broken shield).
- [RECOMMENDED] Rules 7–9: unstated whether a standing shield starts full, and what an unpaid upkeep ward's shield does while Down (keeps its value, soaks, recharges).
- [RECOMMENDED] Formulas G: `x = Q_use / b` divides by 0 for reserved-only sides (b = 0).
- [RECOMMENDED] Rule 11: a status-only or soul-only ward switches off the default ward's 0.30 against every other hit, a likely trap with Clear Heart Ward, Soul-Guarding Lamp and Iron Shirt.
- [RECOMMENDED] Formulas B: a_b's range is "0–1.0 at top end", but Output Range, AC-CD-30 and AC-CD-59 use a_b 2.0.
- [RECOMMENDED] Formulas A2: `a_w` reads "ward-role" defence, while Combat D, Item DB and the 0.85 anchor count all non-body defence (consistency N1).
- [RECOMMENDED] Rules 5, 11: effects.md Open Question 3 and AC-EF-40 wait on two No Ward flags ("cannot slot wards", "no default ward") this GDD does not have.
- [RECOMMENDED] Formulas A, A2, B: modifiers.md Pending rows cite this GDD for typed block, foe-scoped resistance and a body shield I op; no rule here defines them yet.
- [RECOMMENDED] Registry: `defence_ehp` output range ">= H" contradicts the floor (P / 1.5), `default_resist`'s note still says "general resistance", and `dot_pool_cap` is unregistered. Out of scope for this pass.
- [RECOMMENDED] Tuning Knobs: `ward_resist_max`, σ max, `ward_block_max`, `ward_cap`, `hregen_cap`, α_m and `T_ref` are missing.
- [RECOMMENDED] Cross-References: no row for effects.md or Modifier System rule 13, though rules 5, 10 and 16 cite them.
- [RECOMMENDED] Dependencies: back-references are still missing in the planned #43 sweep's GDDs. Carried.
- [RECOMMENDED] Formulas E: the "continuous model" note covers both figures, but 37.6 s recomputes to 37.4 s continuous. Confirm through AC-CD-45.
- [ADVISORY] Player Fantasy section absent (advisory at `standard`; Game Feel covers it).
Safe fixes applied after this review (re-review pass 1): 11; see `rereview-2026-11-08-decisions.md`. The hash below is the content after those fixes.
Reviewed-Content-Hash: design/gdd/combat-defence.md da752666e06252aa2820e7c2eeba06b43f561af3
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 4d296d462001e758228e3a892bc6e77188e6c352
Reviewed-Content-Hash: design/gdd/modifiers.md 4e716c015150db487659925dd70c5dfa4f196613
Reviewed-Content-Hash: design/gdd/effects.md 675919fd8277f2b82b09c81014e8ecce480cfbce
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 4 | Recommended: 14
Summary: Daytime re-review, pass 2. The freshness check found this GDD, the registry and the skill unchanged since pass 1; only combat-damage-types.md, modifiers.md and effects.md had changed (their own pass 1 safe fixes). Their diffs moved no value or rule this GDD depends on, so pass 1's verdict stands and its four blockers carry over. The whole GDD was also re-read and its worked numbers recomputed by hand (an inline script again needed a permission prompt no one could answer); that found 7 safe fixes and one new cross-document recommendation. Not recomputed, because they need realm or harness data: AC-CD-46's other-realm mirrors, the "446 against top-end hits" figure, and the other realms' typical-block shares.
Prior verdict resolved: No (the blockers need user decisions; only safe fixes applied)
Findings:
- [BLOCKING] Rules 6, 9, 14 / Formulas H: the soul shield has no formula, and ws can scale its share past 100 %. Carried.
- [BLOCKING] Rule 1 / Dependencies / OQ 2 / Formulas A, A2, B: `ws`, `we`, `a_w` and `a_b` lose their definition if all of Combat Formulas D is removed. Carried.
- [BLOCKING] Formulas C / rule 8: drain billing for shared block and a short pool is undefined. Carried.
- [BLOCKING] AC-CD-59: the kit fully blocks FX-U, so the criterion cannot pass, and a shield cap cannot fix it. Carried.
- [RECOMMENDED] Rule 8 / States / Edge Cases: wording on a cast ward with a broken shield conflicts. States' Up row ("or shield broken") is part of the same conflict. Carried, extended.
- [RECOMMENDED] Rules 7–9: a standing shield's start value and an unpaid ward's shield behaviour are unstated. Carried.
- [RECOMMENDED] Formulas G: `x = Q_use / b` divides by 0 for reserved-only sides. Carried.
- [RECOMMENDED] Rule 11: a status-only or soul-only ward switches off the default ward. Carried.
- [RECOMMENDED] Formulas B: a_b's range against the a_b 2.0 cases. Carried.
- [RECOMMENDED] Formulas A2: `a_w` "ward-role" against all non-body defence. Carried.
- [RECOMMENDED] Rules 5, 11: effects.md OQ 3 and AC-EF-40 wait on two No Ward flags. Carried.
- [RECOMMENDED] Formulas A, A2, B / rule 7: modifiers.md Pending rows cite this GDD for rules it does not define. Carried, extended (modifiers.md OQ 4 also names recharge delay, cast ward duration and the [body_shield] scope, and its row says a cast ward's duration stays below its cooldown, a limit this GDD does not state).
- [RECOMMENDED] Registry: `defence_ehp` range, `default_resist` note, `dot_pool_cap` unregistered. Carried; out of scope for this pass.
- [RECOMMENDED] Tuning Knobs: seven values missing. Carried.
- [RECOMMENDED] Cross-References: no row for effects.md or Modifier System rule 13. Carried.
- [RECOMMENDED] Dependencies: back-references missing in the #43 sweep's GDDs. Carried.
- [RECOMMENDED] Formulas E: the "continuous model" label on 37.6 s. Carried.
- [RECOMMENDED] Formulas B, I / modifiers.md: modifiers.md's artifact defence row says "about 0.35 on body gear", which looks stale against the raised body-gear mapping and the 0.648 parity here (AC-CD-57). New; the owner is modifiers.md.
- [ADVISORY] Player Fantasy section absent (advisory at `standard`; Game Feel covers it).
Safe fixes applied after this review (re-review pass 2): 7; see `rereview-2026-11-08-decisions.md`. The hash below is the content after those fixes.
Reviewed-Content-Hash: design/gdd/combat-defence.md e4325d2daf244efd0e86973067b480177d2c412e
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d5a09b75ed4ddb6bd15ccb5988e5a6edcbb9c5af
Reviewed-Content-Hash: design/gdd/modifiers.md 83069a628589d674abcd5fa8162f183cd948b2be
Reviewed-Content-Hash: design/gdd/effects.md d0c1c3d6a61d4dfe7c34dbdbb9b977ae941ebe6d
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 5 | Recommended: 18
Summary: Daytime re-review, pass 3. The freshness check found this GDD, the registry and the skill unchanged since pass 2; only combat-damage-types.md, modifiers.md and effects.md had changed (their own pass 2 safe fixes), and none moved a value or rule this GDD depends on. The GDD was re-read in full and its numbers recomputed by hand (a scratch script again needed a permission prompt no one could answer). That reading found one new blocker: Formulas F's V for a cast resistance ward uses the whole T, under which Black Tortoise Shell scores 3.72 and fails, while the catalogue's 0.930 uses its 2 s up time, so AC-CD-41 cannot pass as written. It also found 4 new recommendations and 3 safe fixes. Not recomputed, because they need realm or harness data: AC-CD-46's other-realm mirrors, the "446 against top-end hits" figure, and the other realms' typical-block shares. The stall and upkeep timings were not re-derived this pass.
Prior verdict resolved: No (the blockers need user decisions; only safe fixes applied)
Findings:
- [BLOCKING] Rules 6, 9, 14 / Formulas H: the soul shield has no formula, and ws can scale its share past 100 %. Carried.
- [BLOCKING] Rule 1 / Dependencies / OQ 2 / Formulas A, A2, B: `ws`, `we`, `a_w` and `a_b` lose their definition if all of Combat Formulas D is removed. Carried.
- [BLOCKING] Formulas C / rule 8: drain billing for shared block and a short pool is undefined. Carried.
- [BLOCKING] AC-CD-59: the kit fully blocks FX-U, so the criterion cannot pass, and a shield cap cannot fix it. Carried.
- [BLOCKING] Formulas F / H / AC-CD-41: V for cast wards with resistance, block or evade payloads uses the full T, so Black Tortoise Shell computes V 96.4 against C 25.9 (3.72, fail) while the catalogue lists 0.930, which needs r · I · 2 s. New.
- [RECOMMENDED] Rule 8 / States / Edge Cases: wording on a cast ward with a broken shield conflicts. Carried.
- [RECOMMENDED] Rules 7–9: a standing shield's start value and an unpaid ward's shield behaviour are unstated. Carried.
- [RECOMMENDED] Formulas G: `x = Q_use / b` divides by 0 for reserved-only sides. Carried.
- [RECOMMENDED] Rule 11: a status-only or soul-only ward switches off the default ward. Carried.
- [RECOMMENDED] Formulas B: a_b's range against the a_b 2.0 cases. Carried.
- [RECOMMENDED] Formulas A2: `a_w` "ward-role" against all non-body defence. Carried.
- [RECOMMENDED] Rules 5, 11: effects.md OQ 3 and AC-EF-40 wait on two No Ward flags. Carried.
- [RECOMMENDED] Formulas A, A2, B / rule 7: modifiers.md Pending rows cite this GDD for rules it does not define. Carried.
- [RECOMMENDED] Registry: `defence_ehp` range, `default_resist` note, `dot_pool_cap` unregistered. Carried; out of scope for this pass.
- [RECOMMENDED] Tuning Knobs: seven values missing. Carried.
- [RECOMMENDED] Cross-References: no row for effects.md or Modifier System rule 13. Carried.
- [RECOMMENDED] Dependencies: back-references missing in the #43 sweep's GDDs. Carried.
- [RECOMMENDED] Formulas E: the "continuous model" label on 37.6 s. Carried.
- [RECOMMENDED] Formulas B, I / modifiers.md: artifact defence "about 0.35 on body gear" looks stale. Carried; the owner is modifiers.md.
- [RECOMMENDED] Edge Cases (Compile) / rule 3 / Interactions: "every defence sum is compiled once" conflicts with curses that lower resistance mid-fight and effects.md's "raise or lower a ward ... while a condition holds" action. New.
- [RECOMMENDED] Rule 19 / Edge Cases: "the defeat check is final" does not mention Effects' Down step, whose refusal sets health to 1, and nothing says whether a refusal counts as healing under `no_heal` or the heal cap. The registry's `down_step` lists this GDD as a reference, but it never mentions it. New.
- [RECOMMENDED] Rule 7 / States / AC-CD-17 / Formulas F: between firings a cast ward is "down" in rule 7, AC-CD-17 and Formulas F, but "Expired" in States, and States has no state before a cast ward's first firing. New.
- [RECOMMENDED] Formulas I: the `[fire, over_time]` resistance row has no rule behind it; rule 3 and modifiers.md's incoming-hit scope match resistance on the final damage type only. New.
- [ADVISORY] Player Fantasy section absent (advisory at `standard`; Game Feel covers it).
Safe fixes applied after this review (re-review pass 3): 3; see `rereview-2026-11-08-decisions.md`. The hash below is the content after those fixes.
Reviewed-Content-Hash: design/gdd/combat-defence.md df399caecd2077ce49634e2a0660af1b1623b26a
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-damage-types.md e9ff439387a6274e53c8244d31d9e2164f8209be
Reviewed-Content-Hash: design/gdd/modifiers.md 1c088bc23c1bf8767f0d0309f106d034133b7732
Reviewed-Content-Hash: design/gdd/effects.md 1a4a6f1d16dda2da7b6408f4fad1e8f2e46d8cc3
Reviewed-Content-Hash: design/gdd/thien-kiep.md 48cf4978cc8de61a69ef33edc82e66d0c1b2ee58
Reviewed-Content-Hash: design/gdd/character-stats.md 9a1732061df85886a4bfa92f3119d502fd8c1743
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08b (second re-review, fresh session) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard · Reviewed at: commit 9400de1 (no content receipts: the document changed the same day)
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 7 | Nits: 7 (15 safe, 1 decision)
Summary: The 23 answers from the first re-review were applied correctly, apart from two slips: Formulas A0 capped `a_w` at 1 for ws and we (Combat Formulas D never did), and the cast cost still counted firings inside the up time `T`. Full report: `rereview-2026-11-08b/combat-defence.md`.
Prior verdict resolved: Yes (the first re-review's 5 blockers are closed)
Findings:
- [BLOCKING] CD-01 Formulas A0: `min(a_w, 1)` on ws and we cuts top-end ward gear from +150 to +30. Fixed: the cap is on gear block only.
- [BLOCKING] CD-02 Formulas F: the cast cost used `T` (up time). Fixed: `T_up` for the payloads, `floor(T_ref / cooldown)` for the cost; AC-CD-69 added.
- [RECOMMENDED] CD-04 (decision) A drain ward makes a linh lực tick cost more (13.0 against 10). User decision 2026-11-08b: keep it and document it as a known weakness; AC-CD-68 added.
- [RECOMMENDED] CD-03, CD-05 to CD-09 and nits CD-10 to CD-16: all applied (the qi-tick path row, drain billed in two steps, AC fixes, AC-CD-66 and AC-CD-67, the Combat #43 list).
Applied: 2026-11-08, all 16 findings. Next: a fresh re-review.
