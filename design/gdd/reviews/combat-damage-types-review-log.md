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

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; unattended daytime re-review, pass 1, full fresh review)
Blocking items: 3 | Recommended: 11
Summary: Both overnight blockers are resolved: mixed Soul hits are rejected (rule 1, Edge Cases, AC-DT-22, AC-DT-25) and same-step conversions read the step's start (rule 6, AC-DT-16, registry `damage_parts`). All worked examples and AC numbers were recomputed and hold (150, 146, 9.91, 11.56, 2.57/3.00, 15.91, 8.56, 7.34, 0.583/0.417), and the registry values agree. The fresh pass found three new blockers an implementer would have to guess or that collide with another decision: which conversions win inside one step, a modifier conversion tier the Modifier System says cannot exist, and a tick path that does not fit Qi Disruption.
Prior verdict resolved: Yes (both overnight blockers). Earlier recommendations also closed: zero-move counting, ticks not converted, penetration wording, registry `defence_resistance`, OQ 4 narrowed, 3 × bound, Tuning Knobs table. Still open: index row 21b's dependency cell, back-references, Player Fantasy (advisory).
Findings:
- [BLOCKING] Core Rule 6 / Formulas A / AC-DT-21: the fixed order names tiers only, so with three conversions inside one tier nothing says which two apply, or whether scaling runs before or after the limit.
- [BLOCKING] Core Rule 6 / Formulas A / Tuning Knobs / AC-DT-26: modifiers are a conversion tier, but modifiers.md (Scope, "Left out on purpose") and the Modifier vs Effect decision make every conversion an Effect, so the tier has no source and AC-DT-26's modifier conversion cannot be built.
- [BLOCKING] Core Rule 4 / Core Rule 7: "Any tick" ends in shields and health, but Qi Disruption (Force, effects.md) ticks linh lực and not health; whether resistance and shields apply to it is undefined.
- [RECOMMENDED] Core Rule 1: Chaos's typical sources list "curses' damage", but Combat rule 8 and Defence rule 1 say curses never deal damage.
- [RECOMMENDED] Core Rule 6 / Edge Cases: penetration "reads only the final type", but Defence rule 4 and the Modifier System allow penetration scoped by any tag, such as an element.
- [RECOMMENDED] Visual/Audio / AC-DT-22: Lightning (#FFE14D) and Light (#F5C542) both round to 256-colour code 221, and they are near-identical hues, against the Tuning Knobs' "8 stay distinct".
- [RECOMMENDED] Edge Cases / AC-DT-20 / AC-DT-24: only arts and statuses must name a type; Effect free hits (Echo "same tags", Shattering Ward "Free Force hit") have no rule for their parts or conversions.
- [RECOMMENDED] Interactions: the Effects row disagrees with effects.md on direction and owner, and Combat is still named owner of conversion order although rule 6 now defines the steps.
- [RECOMMENDED] Acceptance Criteria: no criterion covers a same-step chain (Physical → Fire with Fire → Lightning moves no new Fire to Lightning) or a later step reading what an earlier step left.
- [RECOMMENDED] Cross-References: no rows for modifiers.md (rule 13; scopes) or effects.md (rule 6 action; statuses), though rules 2, 5, 6, 8 and Tuning Knobs cite them.
- [RECOMMENDED] Open Question 4: effects.md already says Light has no tick, so the remainder can close.
- [RECOMMENDED] Open Question 1: "Chaos" naming is due "before content is authored", but Chaos content already exists in effects.md and modifiers.md.
- [RECOMMENDED] systems-index row 21b: the dependency cell still says "resistance by kind and element" (only the status cell was in scope).
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet (carried).
- [NICE-TO-HAVE] Core Rule 5: "rarer sources" against "rare sources only" in Tuning Knobs and OQ 3.
- [ADVISORY] Player Fantasy: absent (advisory at standard); Game Feel covers most of it.
Safe fixes applied (re-review pass 1, 9): header status, Last Updated and Last Verified; rule 6 zero-move wording (source-type parts' history, per Formulas A); Formulas A same-step update (Σ c_k at the step's end, per rule 6 and AC-DT-16); Formulas A example and AC-DT-14 name the later step their numbers need; States conversion timing (after evade, before resistance); Cross-References rows for rules 4, 5 and 1/4.
Autonomous decisions: full re-review (target changed); revise-now → [B], design choices deferred to the user; systems-index kept at Needs Revision with this outcome in the status cell; review log appended; next step: user answers the blockers in `rereview-2026-11-08-decisions.md`, then a fresh-session re-review.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d5a09b75ed4ddb6bd15ccb5988e5a6edcbb9c5af
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md da752666e06252aa2820e7c2eeba06b43f561af3
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md 4e716c015150db487659925dd70c5dfa4f196613
Reviewed-Content-Hash: design/gdd/effects.md 675919fd8277f2b82b09c81014e8ecce480cfbce
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; unattended daytime re-review, pass 2)
Blocking items: 3 | Recommended: 14
Summary: The freshness check found this GDD, the registry and the skill byte-identical to pass 1; only combat-defence.md, modifiers.md and effects.md had changed. The skill's path is a cross-document re-check, and the GDD was also re-read in full and its numbers recomputed by hand. No cross-document conflict appeared: the thể tu fixture, defence rules 1, 3, 4, 9 and 13, the shield defaults, the resistance cap and floor and the status types all agree. All three blockers need user decisions, so they stand. The re-read added three recommended findings and no blocker.
Prior verdict resolved: No (the three pass 1 blockers need user decisions; re-checked against the current sibling text and still open).
Findings:
- [BLOCKING] Core Rule 6 / AC-DT-21: order inside one step, and whether scaling runs before or after the limit of 2, are undefined (open from pass 1).
- [BLOCKING] Core Rule 6 / Formulas A / Tuning Knobs / AC-DT-26: the modifier conversion tier has no source, because modifiers.md still says a conversion share is an Effect (open from pass 1).
- [BLOCKING] Core Rules 4, 7: "Any tick" ends in shields and health, but Qi Disruption ticks linh lực, not health (open from pass 1).
- [RECOMMENDED] Core Rule 1: Chaos's sources list "curses' damage" against Combat rule 8 and Defence rule 1 (open).
- [RECOMMENDED] Core Rule 6 / Edge Cases: penetration "reads only the final type" against Defence rule 4's tag scopes; Defence Formulas A already words it "a type scope matches the final type only" (open).
- [RECOMMENDED] Visual/Audio / AC-DT-22: Lightning and Light both round to 256-colour code 221 (open).
- [RECOMMENDED] Edge Cases / AC-DT-20 / AC-DT-24: Effect free hits have no rule for their parts or conversions (open).
- [RECOMMENDED] Interactions: the Effects row disagrees with effects.md on direction and owner, and Combat is still named owner of conversion order (open).
- [RECOMMENDED] Acceptance Criteria: no case for a same-step chain or for a later step reading what an earlier step left (open).
- [RECOMMENDED] Cross-References: no rows for modifiers.md or effects.md (open).
- [RECOMMENDED] Open Question 4: effects.md already says Light has no tick (open).
- [RECOMMENDED] Open Question 1: "Chaos" naming is due, and Chaos content exists (open).
- [RECOMMENDED] systems-index row 21b: the dependency cell still says "resistance by kind and element" (open).
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet (open).
- [RECOMMENDED] Core Rule 6 / Formulas A (new): a 100 % conversion leaves a part at share 0. Nothing says whether it survives, so "no part of its source type is left" and the at-least-1 floor (Combat Formulas C; Defence rule 1) can each read two ways.
- [RECOMMENDED] Core Rule 6 (new): "changing that takes an Effect" points at an action effects.md's action table does not list.
- [RECOMMENDED] Core Rule 1 (new): effects.md's Sundered breaks ties by "Combat Damage Types' order", but this GDD never declares rule 1's table a fixed order.
- [NICE-TO-HAVE] Formulas A (new): a conversion from a type to itself passes the `Y ∉ hist_j` test and would spawn a part of the same type.
- [NICE-TO-HAVE] Edge Cases (new): "authored or modified to mix Soul ... compile rejects" cannot catch a change made at the hit; no such Effect exists today.
- [NICE-TO-HAVE] Core Rule 5: "rarer sources" against "rare sources only" in Tuning Knobs and OQ 3 (carried).
- [ADVISORY] Player Fantasy: absent (advisory at standard); Game Feel covers most of it.
Safe fixes applied (re-review pass 2, 2): header status now reads "two passes"; the Cross-References defence row now also cites this GDD's rule 7 and Formulas A, and Defence Formulas A2, which the Formulas note names.
Checks: all worked examples and AC numbers recomputed by hand and they hold. Registry search covered the combat, defence and modifier entry names and their values, 20 lines, no conflict; a search over all 278 names needed a permission no one could answer, and the entries left out cover other systems (cultivation, economy, quests).
Autonomous decisions: freshness path "only stamped cross-documents CHANGED" → cross-document re-check plus a full re-read; revise-now → [B], design choices deferred to the user; systems-index kept at Needs Revision with this pass noted in the status cell; review log appended; next step: user answers the blockers in `rereview-2026-11-08-decisions.md`, then a fresh-session re-review.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md e9ff439387a6274e53c8244d31d9e2164f8209be
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md e4325d2daf244efd0e86973067b480177d2c412e
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md 83069a628589d674abcd5fa8162f183cd948b2be
Reviewed-Content-Hash: design/gdd/effects.md d0c1c3d6a61d4dfe7c34dbdbb9b977ae941ebe6d
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: M
Specialists: none (lean mode; unattended daytime re-review, pass 3)
Blocking items: 3 | Recommended: 16
Summary: The freshness check found this GDD, the registry and the skill byte-identical to pass 2; only combat-defence.md, modifiers.md and effects.md had changed (their own pass 2 and 3 safe fixes). The skill's path is a cross-document re-check, and the GDD was also re-read in full and its numbers recomputed by hand. No conflict with a recorded value appeared, and no new blocker. All three blockers need user decisions, so they stand. The re-read added two recommended findings.
Prior verdict resolved: No (the three pass 1 blockers need user decisions; re-checked against the current sibling text and still open).
Findings:
- [BLOCKING] Core Rule 6 / AC-DT-21: order inside one step, and whether scaling runs before or after the limit of 2, are undefined (open from pass 1).
- [BLOCKING] Core Rule 6 / Formulas A / Tuning Knobs / AC-DT-26: the modifier conversion tier has no source, because modifiers.md still says a conversion share is an Effect (open from pass 1).
- [BLOCKING] Core Rules 4, 7: "Any tick" ends in shields and health, but Qi Disruption ticks linh lực, not health (open from pass 1).
- [RECOMMENDED] Core Rule 1: Chaos's sources list "curses' damage" against Combat rule 8 and Defence rule 1 (open).
- [RECOMMENDED] Core Rule 6 / Edge Cases: penetration "reads only the final type" against Defence rule 4's tag scopes (open).
- [RECOMMENDED] Visual/Audio / AC-DT-22: Lightning and Light both round to 256-colour code 221 (open).
- [RECOMMENDED] Edge Cases / AC-DT-20 / AC-DT-24: Effect free hits have no rule for their parts or conversions (open).
- [RECOMMENDED] Interactions: the Effects row disagrees with effects.md on direction and owner, and Combat is still named owner of conversion order (open).
- [RECOMMENDED] Acceptance Criteria: no case for a same-step chain or for a later step reading what an earlier step left (open).
- [RECOMMENDED] Cross-References: no rows for modifiers.md or effects.md (open).
- [RECOMMENDED] Open Question 4: effects.md already says Light has no tick (open).
- [RECOMMENDED] Open Question 1: "Chaos" naming is due, and Chaos content exists (open).
- [RECOMMENDED] systems-index row 21b: the dependency cell still says "resistance by kind and element" (open).
- [RECOMMENDED] Dependencies: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do not list this system yet (open).
- [RECOMMENDED] Core Rule 6 / Formulas A: whether a part at share 0 survives a 100 % conversion is undefined (open from pass 2).
- [RECOMMENDED] Core Rule 6: "changing that takes an Effect" points at an action effects.md's action table does not list (open from pass 2).
- [RECOMMENDED] Core Rule 1: effects.md's Sundered breaks ties by "Combat Damage Types' order", but this GDD never declares rule 1's table a fixed order (open from pass 2).
- [RECOMMENDED] Core Rule 4 (new): "Block is taken once per hit, split across its parts by size" does not fit the Pending typed-block row in modifiers.md, where a typed rating blocks only matching parts after the shared pool.
- [RECOMMENDED] Core Rule 8 / Interactions / Dependencies (new): these name element-relation Effects, but effects.md has none, and rule 5's closed read list has no element-relation read.
- [NICE-TO-HAVE] Formulas A: a conversion from a type to itself passes the `Y ∉ hist_j` test (carried).
- [NICE-TO-HAVE] Edge Cases: "authored or modified to mix Soul ... compile rejects" cannot catch a change made at the hit; no such Effect exists today (carried).
- [NICE-TO-HAVE] Core Rule 5: "rarer sources" against "rare sources only" in Tuning Knobs and OQ 3 (carried).
- [ADVISORY] Player Fantasy: absent (advisory at standard); Game Feel covers most of it.
Safe fixes applied (re-review pass 3, 1): header status now reads "three passes".
Checks: all worked examples and AC numbers recomputed by hand and they hold; every rule number in Cross-References was checked against its file and points at the right rule; Dependencies' status cells match the systems index. Registry search covered the 37 entry names in the combat, defence, soul, curse, element and conversion domains, by term, not all 278: a search built from every name was refused by a permission check no one could answer. The entries left out cover other systems. No conflict.
Autonomous decisions: freshness path "only stamped cross-documents CHANGED" → cross-document re-check plus a full re-read; revise-now → [B], design choices deferred to the user; systems-index kept at Needs Revision with this pass noted in the status cell; review log appended; next step: user answers the blockers in `rereview-2026-11-08-decisions.md`, then a fresh-session re-review.
Reviewed-Content-Hash: design/gdd/combat-damage-types.md abcf4805891aba5fe1d9a44a0b164d162cc7cb21
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md df399caecd2077ce49634e2a0660af1b1623b26a
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/linh-can.md ecd0d4f0318e99185b0048dfad44e0f48ca56987
Reviewed-Content-Hash: design/gdd/modifiers.md 1c088bc23c1bf8767f0d0309f106d034133b7732
Reviewed-Content-Hash: design/gdd/effects.md 1a4a6f1d16dda2da7b6408f4fad1e8f2e46d8cc3
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08b (second re-review, fresh session) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard · Reviewed at: commit 9400de1 (no content receipts: the document changed the same day)
Scope signal: M
Specialists: none (lean mode)
Blocking items: 1 | Recommended: 9 | Nits: 4 (10 safe, 4 decisions)
Summary: The first re-review's answers (conversion modifiers, Primordial Chaos, the qi-tick path, the order inside a step) were applied correctly and the arithmetic holds. Allowing `convert_pct` left open how a summed modifier counts toward the limit of 2. Full report: `rereview-2026-11-08b/combat-damage-types.md`.
Prior verdict resolved: Yes (the first re-review's 3 blockers are closed)
Findings:
- [BLOCKING] DT-01 (decision) How conversion modifiers count. User decision 2026-11-08b: one conversion per from → to key, `c_k` = the sum / 100, keys in rule 1's type order; AC-DT-32 added.
- [RECOMMENDED] DT-02 (decision) Slot order for hosts with no slot. User decision: slotted hosts first, then technique, Way, tree; then record id; then listing order.
- [RECOMMENDED] DT-07 (decision) Three plain conversions in effects.md are modifiers. User decision: they move to scoped `convert_pct`.
- [RECOMMENDED] DT-10 (decision) `convert_pct` grid. User decision: whole pp (Character Stats updated).
- [RECOMMENDED] DT-03 to DT-06, DT-08, DT-09 and nits DT-11 to DT-14: all applied (registry `damage_parts` updated).
Applied: 2026-11-08, all 14 findings. Next: a fresh re-review.
