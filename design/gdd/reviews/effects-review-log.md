# Review Log: Effects System (`design/gdd/effects.md`)

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 11
Summary: The record shape, statuses, Down step, counted chance and standing-status rules are sound, and every worked number checks out (Formulas A–C, AC-EF-05/07/18/24/27/30/37/38/41/43; the catalogue fits Combat Formulas F and the registry curse bounds). The GDD's own starter catalogue breaks its two closed lists, though. Several starters read quantities missing from rule 5's readable list. Several use actions missing from rule 6's action list. Rule-change Effects as a kind have no listed actions at all. Under the GDD's own Edge Cases and AC-EF-05/06, those starters would be rejected.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads not on the readable list: ward payments (Water Table), regeneration clip (Still Water), `dot_pulse_cap` clip (Spillover), a status's stack count (Rime Lock); overflow as a kind reads cap clips, which rule 5 never lists
- [BLOCKING] Rule 6 / Starter Effects: actions not on the action list: add a tag (Elemental Fist), add a slot (Talisman Sleeve), skip evade/crit rolls (Measured Stroke), double the companion share (Beast Soul Union), fire an art at Down (Final Clause), raise a level cap (Formation Within a Formation), change an item's output (Strange Pill Reborn); refusal (rule 11) and counted chance (rule 12) are also missing from the table
- [RECOMMENDED] Starter Effects: many `reads` lack the read time rule 1 requires (e.g. Blood Casting, Water Table, Called Blow), and the life table has no Reads column, so AC-EF-01/45 would reject the shipped data
- [RECOMMENDED] Keystones: Called Blow's "fortune never shifts your crits" restates rule 12 (true of all counted chance), so it is not a real cost. Soul Leaves the Body's closes repeats its payload
- [RECOMMENDED] Enablers: Blood Casting's healing taken −50 % equals `curse_heal_taken_max`; whether it stacks with Withering, or is clipped by that bound, is unstated
- [RECOMMENDED] Status Catalogue: Corpse Rot (no duration) vs the lint `c_tick · duration ≤ 1.2 · c_art`: how standing statuses meet the lint is undefined
- [RECOMMENDED] Status Catalogue: Sundered lowers "the damage type of the hit that applied it", but hits have several typed parts; which part decides is unstated
- [RECOMMENDED] Acceptance Criteria: AC-EF-10 reuses Combat Formulas G's 15.9 / 21.7 / 7.9 example, which is built on the retired body-ward model; restate after the Combat revision (#43) or mark it a test fixture
- [RECOMMENDED] Dependencies: 7 rows say the other GDD does not list this system yet; Talismans, Formations, Alchemy, Spirit Beasts, Event Engine and NPC Builds have no GDD file
- [RECOMMENDED] Completeness: Player Fantasy and Tuning Knobs absent (advisory at `standard`); the tuning values (`standing_cost` range, `counted_start`, starter numbers) are not gathered anywhere
- [RECOMMENDED] systems-index.md row #41 says 44 starter Effects; the GDD's tables hold 46 (5+4+9+7+5+7+5+4)
- [RECOMMENDED] Rule 7: "trigger damage at most half of the direct damage" omits Combat Formulas G's floor `max(direct, 0.5 · U · stage)`; cite G instead of paraphrasing
- [RECOMMENDED] Formulas A: `counted_start` range 0–0.99 vs per-mille storage (0–0.999); state it in per mille
Safe fixes applied in the same session (overnight, no design choice): header status and Last Updated; rule 11's "both saved" sentence aligned with Edge Cases and AC-EF-29; Root added to the Starter Effects host legend; Cross-References rows for modifiers.md (rules 6, 15) and the 25 capabilities (keystones or rule changes, per rule 13).
Reviewed-Content-Hash: design/gdd/effects.md 38e5f9d742333c563889f44184c008f8877886ce
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md f98f94566e196d300bbdf2d0ab8b5124f5b02a1f
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md 2210fe9f3624c98013ec87c81d13461ca04fa54f
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 2d2064c3bb057e4f76c9c44822fdd443cd510298

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 12
Summary: Pass 2 (overnight). effects.md, the registry and this skill were byte-identical to pass 1. Only modifiers.md, combat-defence.md and combat-damage-types.md had changed (status lines and wording fixes), so the cross-document facts were re-verified instead of re-running the full review. Every cited rule number (modifiers.md 1, 6, 9, 16; combat-defence.md 5–10, 16–19; combat-damage-types.md 1, 6) still matches, and no conflict appeared, so the pass 1 verdict stands. Every AC number was recomputed again and matches (AC-EF-10's 21.7 is Combat Formulas G's own rounding of 6 × 3.617).
Prior verdict resolved: No (both pass-1 blockers still open; the document has not been revised)
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads not on the readable list (ward payments, regeneration clip, `dot_pulse_cap` clip, a status's stack count; overflow reads cap clips), carried from pass 1
- [BLOCKING] Rule 6 / Starter Effects: actions not on the action list (add a tag, add a slot, skip evade/crit rolls, double a companion share, fire an art at Down, raise a level cap, change an item's output; refusal and counted chance), carried from pass 1
- [RECOMMENDED] Pass-1 recommendations 3–13 all stand unchanged (read times, token closes, Blood Casting vs Withering, Corpse Rot lint, Sundered's type, AC-EF-10 fixture, one-way dependencies, advisory sections, starter count 44 vs 46, rule 7 paraphrase, `counted_start` range)
- [RECOMMENDED] Starter Effects / Open Questions 4–5 (new): the capability arithmetic does not add up: 6 capabilities are re-expressed in the tables and about 12 are named rule changes, but the inventory filter calls "the other 19 capabilities" deferred (6 + 12 + 19 > 25)
Safe fixes applied in the same session: Dependencies status for #40, #21a and #21b set to Needs revision (systems index); header Status records passes 1 and 2.
Reviewed-Content-Hash: design/gdd/effects.md c08c8a88fd73e52dc363b53a2b5264e32a04f351
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md e24ada0e3825948d7f0413534d47c90ef78aa462
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md 43bcf8a6b1b100813f43a6ef087c050b738a84c2
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 523651072ba2500c0683fb98a7973567b961c1f8

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 12
Summary: Pass 3 (overnight). effects.md, the registry and this skill were byte-identical to pass 2. Only modifiers.md, combat-defence.md and combat-damage-types.md had changed, from their own pass-3 safe fixes (status lines, wording, separate ward and body shield caps, evade listed as a ward payload), so the cross-document facts were re-verified instead of re-running the full review. Every cited rule still names the intended rule (modifiers.md 1, 6, 9, 16; combat-defence.md 5–10, 16–19 and Formulas E; combat-damage-types.md 1, 6), and nothing effects.md states conflicts with the changes, so the pass-2 verdict stands. A stale-term sweep found nothing to fix: "kind" means the Effect kind of rule 2, "guard" means Combat's guards, and "body guard" appears only as a retirement record.
Prior verdict resolved: No (both blockers still open; the document has not been revised)
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads not on the readable list (ward payments, regeneration clip, `dot_pulse_cap` clip, a status's stack count; overflow reads cap clips), carried from pass 1
- [BLOCKING] Rule 6 / Starter Effects: actions not on the action list (add a tag, add a slot, skip evade/crit rolls, double a companion share, fire an art at Down, raise a level cap, change an item's output; refusal and counted chance), carried from pass 1
- [RECOMMENDED] Pass-2 recommendations 3–14 all stand unchanged
Safe fixes applied in the same session: header Status records passes 1–3; systems index row #41 now says three passes and 12 recommendations, and design-order row 42 says Needs Revision instead of pending review.
Reviewed-Content-Hash: design/gdd/effects.md 380b5401e2e4a4654cd4f2e5629faa4d2d14be85
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md 20ff37b70820cf176aa8afd907f61c1732c33093
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md c6eed88fdf2385044541ac202edfcbbc620b3905
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 19ff78c01791abc93f0b908ca250d0ef59f53c51

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 2 | Recommended: 12
Summary: Pass 4 (overnight). effects.md, the registry and this skill were byte-identical to pass 3. modifiers.md, combat-defence.md and combat-damage-types.md had changed only by their own pass-4 header status lines, so the cross-document facts were re-checked and the review was not re-run in full. Every rule this GDD cites (modifiers.md 1, 6, 9, 16; combat-defence.md 5–10, 16–19; combat-damage-types.md 6) still says what it said, and the Dependencies status column (#40, #21a, #21b all Needs revision; each lists this system) still matches. A stale-term sweep found only the retirement record on line 365, so the pass-3 verdict stands.
Prior verdict resolved: No (both blockers still open; the document has not been revised)
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads not on the readable list (ward payments, regeneration clip, `dot_pulse_cap` clip, a status's stack count; overflow reads cap clips), carried from pass 1
- [BLOCKING] Rule 6 / Starter Effects: actions not on the action list (add a tag, add a slot, skip evade/crit rolls, double a companion share, fire an art at Down, raise a level cap, change an item's output; refusal and counted chance), carried from pass 1
- [RECOMMENDED] Pass-3 recommendations 3–14 all stand unchanged
Safe fixes applied in the same session: the header Status now reads passes 1–4; systems index row #41 says four passes.
Reviewed-Content-Hash: design/gdd/effects.md 48b21e28a630c1a3c8f876021c23517f21bfadb6
Reviewed-Content-Hash: design/registry/entities.yaml 2a6b2ae68032b4be62cb3dc4bc366bccda6b3530
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md d01b987c1026aa78f19e39511c75c1bacc7c1e34
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md 5cc84b8b2fdf8472501e12f7a16ed75b66e7848d
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d513b0cc9b2fe6f9f8b59712024c003c4db08aee
