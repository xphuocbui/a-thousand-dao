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

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 3 | Recommended: 16
Summary: Daytime re-review, full and fresh, after the user's answers. Every item the overnight review named is resolved: the 3 reads and 9 actions were added, read times are in, and Corpse Rot, Sundered, the token costs, rule 7, the capability count and the tuning table are all settled. The defect class remains, though: starters still use reads and actions the closed lists do not hold, and how a linh lực tick meets the defence path is still undefined. The worked numbers all recompute, apart from a units slip in Formulas A, now fixed; registry and sibling values match.
Prior verdict resolved: Yes for the 2 named blockers (every read and action they listed is now on the lists); No for the class of defect (see the first two findings)
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads still not on the readable list: main root's element (Elemental Fist), formation level (Formation Within a Formation), own stage (Great Essence-Draining Art), a failed brew (Strange Pill Reborn), a death in an event (Soul Leaves the Body), the Down-step events (Unyielding Breath, Final Clause), crit chance read live against "sheet reads are always compile" (Called Blow)
- [BLOCKING] Rule 6 / Starter Effects: actions still not on the action list: burning linh lực (Spillover) and surviving a death (Soul Leaves the Body, unless "change a life output" covers it); no action backs what `closes` forbids (No Ward's ward ban, Paid in Advance's slot limit, Beast Soul Union's companion limit, Water Table's regeneration stop)
- [BLOCKING] Status Catalogue / Rule 6: Qi Disruption and Spillover tick linh lực, but no path says whether resistance or shields apply (same question as combat-damage-types blocker 3)
- [RECOMMENDED] AC-EF-16: requires a strength, but Sealed Meridian, Silence and Stagnation list none, so it rejects shipped curses
- [RECOMMENDED] Status Catalogue: Sundered reads "the applying hit", undefined when a talisman, the ground or a trigger applies it, or the hit is all Soul
- [RECOMMENDED] First Move, Paid in Advance: "costs no linh lực" is built on a refund, so affordability and drain wards still see the cost
- [RECOMMENDED] Rule 11 / Formulas C: no side order for both sides' last acts and their draws; not stated that a Down side's overkill is kept for the follow-up check, which decides whether a last act can win the fight
- [RECOMMENDED] Great Essence-Draining Art: a Trigger with a `closes` value, though rule 1 keeps `closes` to keystones and enablers, and rule 13 lets capabilities become only keystones or rule changes
- [RECOMMENDED] Rule 10: its list omits cultivation base and stage, which Great Essence-Draining Art and Soul Leaves the Body report
- [RECOMMENDED] Formulas A: no rounding rule for a p that is not a whole thousandth
- [RECOMMENDED] Starter Effects: no tie-break for Final Clause's longest cooldown, Rime Lock's least time left or Soul Wound's next ready art
- [RECOMMENDED] Status Catalogue: stacking "None" (Sealed Meridian, Silence) is not one of rule 9's options; a recast while it runs is undefined
- [RECOMMENDED] Acceptance Criteria: no AC exercises most of the reads and actions added today (cap clip event, ward payment event, multiply a share, raise a cap, change a life output, add a slot, skip a roll)
- [RECOMMENDED] Starter Effects: no record gives `domain` or `tags`, which rule 1 and AC-EF-45 require
- [RECOMMENDED] Blood Casting / Combat Formulas E: an Effect's health payment can cause Down, while Combat's `body_cost_share` cannot take health below 1
- [RECOMMENDED] AC-EF-40 / Open Question 3: Combat Defence & Healing still lacks No Ward's two flags (carried)
- [RECOMMENDED] Registry: `counted_chance` output range still reads `floor(counted_start + sum p)`; it needs the per-mille division Formulas A now states
- [RECOMMENDED] Seal of Full Payment + Corpse Rot: "linh lực pays for nothing" leaves a standing cost's payment undefined
- [RECOMMENDED] Dependencies: Talismans, Formations, Alchemy, Spirit Beasts, Event Engine and NPC Builds have no GDD file; back-references remain one-way; the Combat Damage Types interface row disagrees on direction and owner (carried)
Safe fixes applied in the same session (13): see `rereview-2026-11-08-decisions.md`.
Reviewed-Content-Hash: design/gdd/effects.md d0c1c3d6a61d4dfe7c34dbdbb9b977ae941ebe6d
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md 83069a628589d674abcd5fa8162f183cd948b2be
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md da752666e06252aa2820e7c2eeba06b43f561af3
Reviewed-Content-Hash: design/gdd/combat-damage-types.md d5a09b75ed4ddb6bd15ccb5988e5a6edcbb9c5af
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 3 | Recommended: 20
Summary: Daytime pass 2. effects.md, the registry and this skill were byte-identical to pass 1, and only modifiers.md, combat-defence.md and combat-damage-types.md had changed, so the skill's path is a cross-document re-check, which found no conflict; the whole GDD was also re-read and its AC numbers recomputed. The pass-1 verdict and its three blockers stand, with one more missing read in blocker 1. The crit caps pass 1 left untraced now trace to Combat Formulas C (`crit_chance_cap` 0.5).
Prior verdict resolved: No (the 3 pass-1 blockers are still open; the document has only had safe fixes)
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads not on the readable list, carried from pass 1, plus (new) an art's authored cooldown (Measured Stroke, Overheat)
- [BLOCKING] Rule 6 / Starter Effects: actions not on the action list (burn linh lực, survive a death, enforce what `closes` forbids), carried from pass 1
- [BLOCKING] Status Catalogue / Rule 6: no path for a linh lực tick (Qi Disruption, Spillover), carried from pass 1
- [RECOMMENDED] Pass-1 recommendations 4–19 all stand unchanged
- [RECOMMENDED] Rule 6 / Water Table (new): "restores count as healing", but Defence Formulas E's cap and decay cover only health and body shields, and "up to your maximum" ignores the usable maximum under reservation
- [RECOMMENDED] Rule 6 (new): Combat Damage Types rule 6 says changing a tick's type "takes an Effect", but no action exists
- [RECOMMENDED] Status Catalogue (new): Modifier System rule 8 reads a status's "mode and effect tags" from this catalogue, which records only cleanse tags
- [RECOMMENDED] Field Walls (new): the rule says "while your formation stands" but reads at compile, so a formation falling mid-fight is undefined
Safe fixes applied in the same session (7): see `rereview-2026-11-08-decisions.md`.
Reviewed-Content-Hash: design/gdd/effects.md 1a4a6f1d16dda2da7b6408f4fad1e8f2e46d8cc3
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md 1c088bc23c1bf8767f0d0309f106d034133b7732
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md e4325d2daf244efd0e86973067b480177d2c412e
Reviewed-Content-Hash: design/gdd/combat-damage-types.md e9ff439387a6274e53c8244d31d9e2164f8209be
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean mode)
Blocking items: 3 | Recommended: 21
Summary: Daytime pass 3. effects.md, the registry, this skill and combat.md were byte-identical to pass 2, and only modifiers.md, combat-defence.md and combat-damage-types.md had changed, so the skill's path is a cross-document re-check, which found no value conflict; the whole GDD was also re-read, its counts and numeric ACs recomputed, and every registry name searched. The three blockers stand, unchanged. One new recommendation: Bare Rack's [basic] scope is a Pending tag that adds nothing yet.
Prior verdict resolved: No (the 3 blockers are still open; the document has only had safe fixes)
Findings:
- [BLOCKING] Rule 5 / Starter Effects: reads not on the readable list, carried from passes 1 and 2
- [BLOCKING] Rule 6 / Starter Effects: actions not on the action list (burn linh lực, survive a death, enforce what `closes` forbids), carried from pass 1
- [BLOCKING] Status Catalogue / Rule 6: no path for a linh lực tick (Qi Disruption, Spillover), carried from pass 1
- [RECOMMENDED] Pass-2 recommendations 4–23 all stand unchanged
- [RECOMMENDED] Bare Rack (new): scope [basic] is a derived art tag, which Modifier System rule 10 marks Pending and which adds nothing until Combat adopts it, so the basic-attack half of Bare Rack does nothing today
Safe fixes applied in the same session (2): see `rereview-2026-11-08-decisions.md`.
Reviewed-Content-Hash: design/gdd/effects.md 0be9bb903a5e6ef8493ada78f4fb585ff33ecb03
Reviewed-Content-Hash: design/registry/entities.yaml 8a5e49fd2189be5cd8723a1a3c8808f8f72ce67a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md 9c1aa20c325fb15a390402079c5f8718bc858038
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md df399caecd2077ce49634e2a0660af1b1623b26a
Reviewed-Content-Hash: design/gdd/combat-damage-types.md abcf4805891aba5fe1d9a44a0b164d162cc7cb21
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-08b (second re-review, fresh session) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard · Reviewed at: commit 9400de1 (no content receipts: the document changed the same day)
Scope signal: L
Specialists: none (lean mode)
Blocking items: 3 | Recommended: 7 | Nits: 6 (12 safe, 4 decisions)
Summary: Nearly all 24 answers were applied correctly and the three old blockers are closed. The conversion-modifier decision had not reached this GDD. Full report: `rereview-2026-11-08b/effects.md`.
Prior verdict resolved: Yes (the first re-review's 3 blockers are closed)
Findings:
- [BLOCKING] EF-01 (decision) Flame-Tempered Edge, Thunder Palm and Rot Seeps In are plain scoped conversions. User decision 2026-11-08b: they move to `convert_pct` modifiers; 43 starter Effects remain; AC-EF-58 added.
- [BLOCKING] EF-02 The closing-rule action did not cover every starter's close. Fixed: the action covers lowering a cap, scaling a named cost or pool and a shared floor.
- [BLOCKING] EF-03 AC-EF-50 used a `c_comp_cap` of 0.35. Fixed to Combat Formulas J's 1.0 on `c_comp`.
- [RECOMMENDED] EF-05 (decision) Last acts in a double knockout. User decision: a last act's damage always counts toward its target's overkill.
- [RECOMMENDED] EF-06 (decision) The 5 % qi burn cap. User decision: one pool per target per pulse; Combat #43 restates Formulas F.
- [RECOMMENDED] EF-04, EF-07 to EF-10 and nits EF-11 to EF-16: all applied (AC-EF-56 and AC-EF-57 added; the effect-kind tag family is in modifiers.md rule 9).
Applied: 2026-11-08, all 16 findings. Next: a fresh re-review.

## Applied 2026-11-08 (round 3 fixes)

Source: `reviews/rereview-2026-11-08c/effects.md` and `combat-defence.md` (its EF-01).

Applied (14): EF-01 (Formulas C row and the new Edge Case), EF-02 (AC-EF-28 made self-contained, draw case 24 added), EF-03 (AC-EF-59 to 62), EF-04 (rule 14 text and the three Payload cells), EF-06 (AC-EF-52 band 0.28 to 0.32), EF-07 (Modifier System cell now Approved), EF-08 (AC-EF-45 lint scope and rule 4 Edge Case), EF-09 (`status` added to the kind tags), EF-10 (`qi_burn_cap` Tuning Knobs row; the registry entry is for the registry owner), EF-11 (Last Updated line), EF-12 (all four leftovers). From the Combat Defence report: its EF-01 (Qi Disruption row now "all + Force resistance"; AC-EF-26 fixture adds `no_default_ward`).

Skipped (1): EF-05 (Chaos conversion stacking) is tagged DECISION and stays open for the user.

No fix landed in `modifiers.md`, so its log is unchanged.

User decisions 2026-11-08c applied: EF-05 (option A: Chaos conversion stacking accepted, line added under the conversion note, Open Question 11 added as a balance-pass watch item).
