# Review Log — Combat Damage Types (design/gdd/combat-damage-types.md)

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; overnight autonomous run)
Blocking items: 2 | Recommended: 12
Summary: The core split (eight damage types, elements as art tags, no element cycle) is clear and agrees with Combat Defence & Healing, the Modifier System, the Effects System and the registry (`damage_parts`, `defence_resistance`, `defence_block`). All worked examples and AC numbers were recomputed; one rounding (15.90 → 15.91) was fixed. Two rules a programmer would have to guess remain: hits that mix Soul with other types, and how two conversions from one type in the same step share a part (the formula as written is sequential, but AC-DT-16 expects them to be applied together).
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 1, 4, 6 / AC-DT-22: a hit with a Soul part plus other parts is not defined (evade, block split, crit, Formulas C vs E2), yet AC-DT-22 needs a hit carrying all 8 types.
- [BLOCKING] Formulas A / Edge Cases / AC-DT-16: the formula updates `s_j ← s_j·(1−c_k)` one conversion at a time, which with 0.583 then 0.417 leaves Physical at 0.243, while AC-DT-16 expects 0. "Step" is never defined.
- [RECOMMENDED] Core Rule 6: whether a conversion that changes no part (a back-conversion, or no part of its source type) counts toward the 2.
- [RECOMMENDED] Core Rule 6: whether conversion reaches ticks and statuses (does Physical → Fire turn a bleed into Fire?).
- [RECOMMENDED] Core Rule 6: the bullet names resistance and block reading the final type but not penetration (only Edge Cases and AC-DT-08 say so).
- [RECOMMENDED] Header: the ownership line still lists "its element, its mode", which Combat rule 6 and Spiritual Roots own.
- [RECOMMENDED] systems-index row 21b: the description still says kinds (body, qi, soul), the element cycle and "resistance by kind and element".
- [RECOMMENDED] Registry `defence_resistance`: variables still list R_gen, R_kind, R_elem (owned by combat-defence.md).
- [RECOMMENDED] Open Question 4: partly answered by effects.md (16 statuses; Light's status is Exposed and has no tick).
- [RECOMMENDED] Dependencies: one row lists four systems with three statuses; Talismans (#18) is missing from the Interactions table.
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet.
- [RECOMMENDED] Tuning Knobs: absent (advisory at standard); the conversion limit of 2 and the type colours are knobs.
- [RECOMMENDED] Player Fantasy: absent (advisory at standard); Game Feel covers most of it.
- [RECOMMENDED] Header: the status line still reads "pending an independent /design-review".
- [NICE-TO-HAVE] Formulas A output range: "at most 4 × authored parts" holds, but the tight bound is 3 × (each conversion splits only one type).
Safe fixes applied (overnight, 10): header "its kind" → "its damage type"; rule 5 penetration cite → Defence rules 3 and 4; rule 8 and Cross-References rows → Spiritual Roots rule 1 (the element cycle is rule 1, not 3); thể tu example and AC-DT-19 15.90 → 15.91; Dependencies statuses for Combat Defence (Needs revision), Modifier System and Effects System (Designed, Yes); Last Updated.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 2d2064c3bb057e4f76c9c44822fdd443cd510298
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md 2210fe9f3624c98013ec87c81d13461ca04fa54f
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md 06a71d2cd7d4cb3b4f5cd8ddb580ca7e22e92dfd
Reviewed-Content-Hash: design/gdd/effects.md 5c4b4d985ea4cfffaf39c34a862bdc2244dfb066

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; overnight autonomous run, pass 2)
Blocking items: 2 | Recommended: 8
Summary: The freshness check found the GDD, the registry and this skill byte-identical to pass 1. Only combat-defence.md, modifiers.md and effects.md had changed. Their changes were re-verified against this GDD: they are status lines and wording fixes. The thể tu fixture, defence rules 1–4, 9 and 12, the shield defaults and every citation of this GDD's rules 1, 2, 4–7 and 9 still agree, so no cross-document conflict appeared and the prior verdict stands. Both blockers (mixed Soul hits; same-step conversions) are still open, because they need user decisions.
Prior verdict resolved: No (blockers need user decisions)
Findings:
- [BLOCKING] Core Rules 1, 4, 6 / AC-DT-22: a hit with a Soul part plus other parts is still undefined (open from pass 1).
- [BLOCKING] Formulas A / Edge Cases / AC-DT-16: sequential `s_j ← s_j·(1−c_k)` versus "Physical share left is 0"; "step" undefined (open from pass 1).
- [RECOMMENDED] Core Rule 6: whether a conversion that changes no part counts toward the 2 (open).
- [RECOMMENDED] Core Rule 6: whether conversion reaches ticks and statuses (open).
- [RECOMMENDED] systems-index row 21b: the description still names kinds, the element cycle and "resistance by kind and element" (open; status cell updated only).
- [RECOMMENDED] Registry `defence_resistance`: variables still list R_gen, R_kind, R_elem (open; the registry is out of scope tonight).
- [RECOMMENDED] Open Question 4: partly answered by effects.md (open).
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet (open).
- [RECOMMENDED] Tuning Knobs: absent (advisory at standard).
- [RECOMMENDED] Player Fantasy: absent (advisory at standard).
- [NICE-TO-HAVE] Formulas A output range: the tight bound is 3 × the authored parts, not 4 ×.
Safe fixes applied (overnight pass 2, 7): header status line now records the review; header ownership line drops "its element, its mode" (element tags belong to Combat rule 6 and Spiritual Roots, as Interactions says); rule 6 bullet adds penetration (matching Edge Cases and AC-DT-08); Interactions adds Talismans (#18) to match Dependencies; Dependencies statuses for Modifier System and Effects System → Needs revision; Dependencies row for #9/#39/#13/#18 gets four statuses for four systems; Last Updated.
Autonomous decisions: freshness path "only stamped cross-documents CHANGED" → re-verified the changed files and re-issued the verdict instead of a full re-review; systems-index status kept as Needs Revision (status cell note updated); review log appended; design-decision revisions deferred to the user.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 523651072ba2500c0683fb98a7973567b961c1f8
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md 43bcf8a6b1b100813f43a6ef087c050b738a84c2
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md f98f94566e196d300bbdf2d0ab8b5124f5b02a1f
Reviewed-Content-Hash: design/gdd/effects.md 38e5f9d742333c563889f44184c008f8877886ce

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; overnight autonomous run, pass 3)
Blocking items: 2 | Recommended: 8
Summary: The freshness check found the GDD, the registry and this skill byte-identical to pass 2. Only combat-defence.md, modifiers.md and effects.md had changed (their own pass-2/3 status and wording fixes). Re-verified: the thể tu fixture (Physical 0.60, Fire and Chaos 0.30, block 5.57, body shield 109.0), the block split by after-resistance size (Formulas A2, AC-CD-53), defence rules 1, 3, 4, 9 and 12, the 0.75/0.90/−0.50 resistance limits, modifiers.md's damage-type tag family and effects.md's citations of rules 1 and 6 all still agree; AC-DT-19 recomputed (9.91, 11.56, 2.57/3.00, 15.91; Chaos 8.56 and 7.34). No conflict, so the prior verdict stands. Both blockers still need user decisions.
Prior verdict resolved: No (blockers need user decisions)
Findings:
- [BLOCKING] Core Rules 1, 4, 6 / AC-DT-22: a hit with a Soul part plus other parts is still undefined (open from pass 1).
- [BLOCKING] Formulas A / Edge Cases / AC-DT-16: sequential `s_j ← s_j·(1−c_k)` versus "Physical share left is 0"; "step" undefined (open from pass 1).
- [RECOMMENDED] Core Rule 6: whether a conversion that changes no part counts toward the 2 (open).
- [RECOMMENDED] Core Rule 6: whether conversion reaches ticks and statuses (open).
- [RECOMMENDED] systems-index row 21b: the description still names kinds, the element cycle and "resistance by kind and element" (open; status cell updated only).
- [RECOMMENDED] Registry `defence_resistance`: variables still list R_gen, R_kind, R_elem (open; registry out of scope tonight).
- [RECOMMENDED] Open Question 4: partly answered by effects.md (open).
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet (open).
- [RECOMMENDED] Tuning Knobs: absent (advisory at standard).
- [RECOMMENDED] Player Fantasy: absent (advisory at standard).
- [NICE-TO-HAVE] Formulas A output range: the tight bound is 3 × the authored parts, not 4 ×.
Safe fixes applied (overnight pass 3, 1): header Status and Last Updated lines record three passes.
Autonomous decisions: freshness path "only stamped cross-documents CHANGED" → re-verified cross-document facts and re-issued the verdict; revise-now → [B] (design choices deferred to the user); systems-index kept at Needs Revision (status cell notes pass 3); review log appended; next step: user answers the blockers, then a fresh-session re-review. A fourth unattended pass would find the same thing.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 19ff78c01791abc93f0b908ca250d0ef59f53c51
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md c6eed88fdf2385044541ac202edfcbbc620b3905
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md e24ada0e3825948d7f0413534d47c90ef78aa462
Reviewed-Content-Hash: design/gdd/effects.md c08c8a88fd73e52dc363b53a2b5264e32a04f351

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; overnight autonomous run, pass 4)
Blocking items: 2 | Recommended: 8
Summary: The freshness check found the GDD, the registry and this skill byte-identical to pass 3. Only combat-defence.md, modifiers.md and effects.md had changed (their own pass-3/4 status and wording fixes). Re-verified: the thể tu fixture (combat-defence.md test fixtures: R_all 0.30 + R_Physical 0.30, so Physical 0.60, Fire and Chaos 0.30; block 5.57; body shield 109.0), block split by after-resistance size (Formulas A2), defence rules 1, 3, 4, 9, 12 and 13 (evade all hits but Soul), the 0.75/0.90/−0.50 resistance limits, modifiers.md's damage-type tag family and its rule-6 final-type reading, and effects.md's citations of rules 1 and 6 all still agree. Formulas A examples (150, 146) and AC-DT-19 (9.91, 11.56, 2.57/3.00, 15.91; Chaos 8.56 and 7.34) recomputed. No conflict, so the prior verdict stands. Both blockers still need user decisions.
Prior verdict resolved: No (blockers need user decisions)
Findings:
- [BLOCKING] Core Rules 1, 4, 6 / AC-DT-22: a hit with a Soul part plus other parts is still undefined (open from pass 1).
- [BLOCKING] Formulas A / Edge Cases / AC-DT-16: sequential `s_j ← s_j·(1−c_k)` versus "Physical share left is 0"; "step" undefined (open from pass 1).
- [RECOMMENDED] Core Rule 6: whether a conversion that changes no part counts toward the 2 (open).
- [RECOMMENDED] Core Rule 6: whether conversion reaches ticks and statuses (open).
- [RECOMMENDED] systems-index row 21b: the description still names kinds, the element cycle and "resistance by kind and element" (open; status cell updated only).
- [RECOMMENDED] Registry `defence_resistance`: variables still list R_gen, R_kind, R_elem (open; registry out of scope tonight).
- [RECOMMENDED] Open Question 4: partly answered by effects.md (open).
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet (open).
- [RECOMMENDED] Tuning Knobs: absent (advisory at standard).
- [RECOMMENDED] Player Fantasy: absent (advisory at standard).
- [NICE-TO-HAVE] Formulas A output range: the tight bound is 3 × the authored parts, not 4 ×.
Safe fixes applied (overnight pass 4, 1): header Status and Last Updated lines record four passes.
Autonomous decisions: freshness path "only stamped cross-documents CHANGED" → re-verified cross-document facts and re-issued the verdict; revise-now → [B] (design choices deferred to the user); systems-index kept at Needs Revision (status cell notes passes 3 and 4); review log appended; next step: user answers the blockers, then a fresh-session re-review.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d513b0cc9b2fe6f9f8b59712024c003c4db08aee
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md 5cc84b8b2fdf8472501e12f7a16ed75b66e7848d
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md 20ff37b70820cf176aa8afd907f61c1732c33093
Reviewed-Content-Hash: design/gdd/effects.md 380b5401e2e4a4654cd4f2e5629faa4d2d14be85
