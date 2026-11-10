# Review Log — Cultivation Techniques (Công Pháp)

## Review — 2026-11-04 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L (borderline XL)
Specialists: none (lean)
Blocking items: 0 | Recommended: 8
Summary: Design delivers Pillar 3; all ~35 hand-recomputed numbers matched and registry values agree. Main gaps are a crude-vs-slotted speed discontinuity, an undefined per-tier bonus budget, and a "layer (tầng)" terminology collision. Balance guesses still need the bot ACs 46-48.
Prior verdict resolved: First review
Findings:
- [RECOMMENDED] Formulas A / Tuning Knobs: a slotted beyond-realm or low-match method can be slower than crude cultivation (AC-CP-18 example 0.035 vs 0.258); "no_cong_phap_mult nearly inert" note is wrong
- [RECOMMENDED] Rule 3 / Formulas D: per-tier bonus budget promised but undefined; authored v_full unbounded, validator does not check it
- [RECOMMENDED] Terminology: "layer (tầng)" collides with glossary/Realms (QR 13 sub-steps); add glossary entries for tiers, kinds, harmony, great completion
- [RECOMMENDED] Rules 17-18: 15 guaranteed par-tier methods per world strain the ~40 catalogue and Earth/Heaven rarity weights
- [RECOMMENDED] Edge Cases: known list per life / NPC death manuals unspecified
- [RECOMMENDED] Formulas E: Earth and Heaven manual price bands undefined
- [RECOMMENDED] Cross-GDD: OQ1 leaves Realms years table ~24% stale for multi-element roots; register cross-system technique constants
- [RECOMMENDED] Player Fantasy section absent (advisory at standard)
Reviewed-Content-Hash: design/gdd/cong-phap.md de69dbcef875ca3e3900e69ffd2c572e09d9215f
Reviewed-Content-Hash: design/registry/entities.yaml 2822e572ff55df64093918be68ffaff2083a8984
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md c374398023153060a9ebf19d835d2a7a055a9b83
Reviewed-Content-Hash: design/gdd/character-stats.md 675ce33d3f5a62c0e67972036a7dfed702c04bdf
Reviewed-Content-Hash: design/gdd/canh-gioi.md d8a6a787af03293597afdd61a7d9dca046a2bd4c
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md e4fcd50f07226f2403a03ea28076404248435dc7
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/glossary.md a057a5eea33c30b06ab8caaf778e93f4e0ab0f0f

## Cleanup — 2026-11-04 (no new review)
Applied the key recommended items:
- Formulas A: a crude floor, so a slotted main method never runs below crude cultivation; the Tuning Knobs notes on `no_cong_phap_mult` and `beyond_realm_mult` are corrected;
- Formulas D: a per-tier bonus budget (1 / 2 / 3 / 4 pool maxima, single bonus at most 1.5) with validator checks (AC-CP-34);
- Terminology: technique layers are written "technique layer (tầng công pháp)"; glossary entries added for tiers, kinds, manual, great completion, harmony and crude cultivation;
- Formulas E: the price formula covers authored manuals (Earth 1,275–1,725; Heaven 10,200–13,800);
- Edge Cases: what happens to known techniques and manuals when a character dies.

Recorded as Open Questions: the rule 18 guarantee load (9) and the missing Player Fantasy (10); the Realms years-table drift stays with Open Question 1. Cross-system constants were already registered.

The status header is set to Approved. No tuned values changed except the new budget keys.

## Review — 2026-11-04 (second pass) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 6
Summary: Full re-review after the cross-GDD fixes. The only content change since the first pass is the rule 12 bullet requiring confirmation when a slot or main-method change would drop the lifespan cap to the age or below; it agrees with Realms rule 14 and AC-CG-62. About 45 hand-computed values (Formulas A-E examples, AC-CP-06, 14-28, 37, 39) were recomputed and match, and all owned registry values agree.
Prior verdict resolved: Yes (first-pass recommendations were applied in the cleanup)
Findings:
- [RECOMMENDED] Rule 6 / AC-CP-05 / UI Requirements / Interactions / Cross-References: "no cost" slot swaps and the slotting preview do not mention the rule 14 lifespan confirmation or cap
- [RECOMMENDED] Dependencies: stale "Bidirectionality" paragraph (index row 9 already carries the dependencies)
- [RECOMMENDED] Rule 8 guard: an involuntary unslot could lower the lifespan cap with no stated behaviour (Realms NG8)
- [RECOMMENDED] Tuning Knobs: bonus_budget and bonus_single_cap have no safe-range row
- [RECOMMENDED] Edge Cases: stale "systems-designer was not consulted" header
- [RECOMMENDED] Open Questions 1, 2, 5, 6, 9 carried (balance guesses and the rule 18 content load)
- [ADVISORY] Player Fantasy section absent (advisory at standard)
Note: the Status header and systems-index row were set to Approved before this hash was taken.

Reviewed-Content-Hash: design/gdd/cong-phap.md 71bb0c29b137f9b8a632d5a6f75f06260191691b
Reviewed-Content-Hash: design/registry/entities.yaml 6c13ff12951f6e07a0026696ed94eea801d06d70
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md c374398023153060a9ebf19d835d2a7a055a9b83
Reviewed-Content-Hash: design/gdd/canh-gioi.md 862f0775bcfd3fa9f23ba42fac9e97626f2d07e1
Reviewed-Content-Hash: design/gdd/character-stats.md e777ab76a33ac9e2cc21bede7abbf4e9f8e1a989
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 2484b6a22721d7a3ebae4f9c941fdd197a6ac0f7
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: design/glossary.md ff571453f374812f6f9f2e2a38eac45a38fb22ca

## Cleanup — 2026-11-04 (no new review)
Applied after the second pass: rule 6 and AC-CP-05 carry the Realms rule 14 lifespan confirmation; the slotting preview shows the new cap; the Interactions and Cross-References rows name Realms rule 14; the stale Bidirectionality paragraph and the Edge Cases header are corrected; bonus_budget and bonus_single_cap have Tuning Knobs rows. No values changed.

## Revision — 2026-11-04 (Spiritual Roots redesign; no new review)
Reopened from Approved. Wording aligned from mutations to variant roots; rule references updated. Harmony: a derived variant counts as its required elements, an innate variant is neutral (new; innate variants have no parents). count_gain stays keyed by n_base. Open Question 11 added for techniques naming relocated mutations.

## Review — 2026-11-05 (independent, ahead of the cross-GDD pass) — Verdict: NEEDS REVISION
Review mode: solo · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 7 | Recommended: 8
Summary: AC-CP-22, a layer leftover, a technique filling two slots, technique seals, combat line, manual prices, stale facts.
Prior verdict resolved: Yes
Resolution: Fixed the same day by the reviewing agent under decisions from the main session, with the user's mandate to accept the right fixes. A cross-GDD review then found no blockers (design/gdd/gdd-cross-review-2026-11-05.md). The fixes have not had their own solo re-review. The hashes stamp the files as reviewed, before those fixes.
Reviewed-Content-Hash: design/gdd/cong-phap.md cfa220cbdfb71a405667dba257fcb71cb92f7298
Reviewed-Content-Hash: design/registry/entities.yaml 598fceae60b85a79be6a2763e0bba270d5e0f684
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/systems-index.md 316bd191788182445931fcf87c1dae09c7ac0fbd
Reviewed-Content-Hash: design/gdd/game-concept.md 97d16997e271c1a187365e08392eab74f8ed60e2
Reviewed-Content-Hash: design/gdd/canh-gioi.md bab602ac6aefc7a4e8589f7078e93f28560c930c
Reviewed-Content-Hash: design/gdd/character-stats.md 55d9ae80692694927176c65f7603cb63f1cab407
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md a9ddc4cd7fdba22c937c6afa9bb916ad1a2827db
Reviewed-Content-Hash: design/gdd/linh-can.md f88b04a3e103bc0e817ff0ef33948dd9e7d14227

## Review — 2026-11-10 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 2 | Recommended: 5
Summary: Report-only review against the Combat economy revision (#44), uncapped purity, curved bonus ceilings and the revised Modifier, Effects and Combat sub-GDDs. The arithmetic of Formulas A–F and the registry values hold; two cross-GDD contradictions need user decisions (purity past 100; body technique sizes against Combat Defence). Full report: reviews/cong-phap-review-2026-11-10.md. Nothing was edited.
Prior verdict resolved: Yes (the 2026-11-05 findings were fixed and hold)
Findings:
- [BLOCKING] Formulas A, D: purity is uncapped (Linh Căn rule 8) but match, F, crude and ranges assume at most 100 (CP-01)
- [BLOCKING] Rules 2, 12, Formulas D: body techniques cannot yield Combat Defence's Iron Body sizes (tiers 1–5 vs 0–3; layer, Physique and Comprehension scaling; no pool rows) (CP-02)
- [RECOMMENDED] Rule 12, Formulas D: "ceilings" are now curves (CP-03)
- [RECOMMENDED] Rule 1, Formulas D: no Modifier System budget link, no Effects host field, tags or `more` hook (CP-04)
- [RECOMMENDED] Rule 12 harmony: Chaos and wide arts always 0.60 (CP-05)
- [RECOMMENDED] Rules 1, 13: ability record too thin for Combat's art record and art slot pool (CP-06)
- [RECOMMENDED] Dependencies, Interactions: no rows for #21a, #21b, #40, #41 (CP-07)
- [MINOR] 7 items: states table exits, header dates, OQ 14, registry range 4.35, stale 2.2 range, review count, body guard wording (CP-08 to CP-14)
Reviewed-Content-Hash: design/gdd/cong-phap.md 747c3aa1bab3b24cbb70f4803581b3622a42c44d
Reviewed-Content-Hash: design/registry/entities.yaml fb908ecd77913491aedb1b35089f77a6390a59ba
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md bc26ba79399663c249c2488bf79f97487b1598c3
Reviewed-Content-Hash: design/gdd/canh-gioi.md e905183a564a46d236b23cfb5758ef5cac358ff8
Reviewed-Content-Hash: design/gdd/character-stats.md a909d5d7a93bb21705a6c1cebcbc71db34062651
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md b92f9946089a4d7e2d58062b33d1a328f2cda751
Reviewed-Content-Hash: design/gdd/combat.md dd287950cbad5094bdbe0e74852c90de9241f61a
Reviewed-Content-Hash: design/gdd/combat-defence.md 939cb75414034b37ab04468ef72a7fbb61419f7f
Reviewed-Content-Hash: design/gdd/combat-damage-types.md 2a7884cd8be1c91b74aef27d6b254baae48235e3
Reviewed-Content-Hash: design/gdd/modifiers.md 3f29eaaa9182b127e2f067e4921d84de403a4c3b
Reviewed-Content-Hash: design/gdd/effects.md 7527907f89207a65be65e0e1582ab16d0f4c82f6
Reviewed-Content-Hash: design/gdd/dao.md a16e45d5d5c107c6acb4dd2a508c8f0f7815aada
Reviewed-Content-Hash: design/gdd/game-concept.md 88eba239210164e778fac6959cb6ee24da039f6d
Reviewed-Content-Hash: design/glossary.md 0b3cf7dcb934aeb999bbc996c5eb80d200bd0ac1

## Review — 2026-11-10 (confirming re-review) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none
Blocking items: 2 | Recommended: 4
Summary: Answers D1 to D4 and fixes CP-01 to CP-14 are mostly present and the numbers re-derive. Two items still block: purity in an unowned element can never be read under the usability rule, and the body-technique layer-to-tier mapping is undefined. Full report: reviews/cong-phap-rereview-2026-11-10.md.
Prior verdict resolved: Partly (CP-01 and CP-02 applied; new gaps found)
Findings:
- [BLOCKING] Rules 8 and 9: purity in an unowned element counts, but a technique naming it is unusable
- [BLOCKING] Rule 2 / AC-CP-23: body-defence layer-to-tier mapping undefined
- [RECOMMENDED] Combat Defence Qi Refining thể tu example unreachable under D2
- [RECOMMENDED] AC-CP-39, 36, 34 miss the Combat hand-off and the new fields
- [RECOMMENDED] Interactions and Dependencies tables omit Combat sub-systems, Modifiers, Effects
- [RECOMMENDED] `more` and `effects` rules around the new template fields missing
Reviewed-Content-Hash: design/gdd/cong-phap.md eebee87a8b02af50a2a516427e20594814e983bc
Reviewed-Content-Hash: design/registry/entities.yaml e39b9de2e2ec2a87abf7165ff67417d06385d5bc
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/linh-can.md 1de5075a08701c52dc4ec238fdcd106c8de56e57
Reviewed-Content-Hash: design/gdd/character-stats.md 5e365f68fb3fbe54cf8eb0935fb9a6be461055e0
Reviewed-Content-Hash: design/gdd/canh-gioi.md 4d3a98fb4eb2f588d26095ed91c8e6e2457b20e8
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md d229603fe4fae7df7ceae1dac3c5b98a67f156b2
Reviewed-Content-Hash: design/gdd/game-concept.md 88eba239210164e778fac6959cb6ee24da039f6d
Reviewed-Content-Hash: design/glossary.md 0b3cf7dcb934aeb999bbc996c5eb80d200bd0ac1
Reviewed-Content-Hash: design/gdd/systems-index.md 49e72f85b34236f531111fa88d9ece7d3e4d2161
Reviewed-Content-Hash: design/gdd/combat.md 82808aa10ffa17d0e7d2c4d4939c1899c509aa28
Reviewed-Content-Hash: design/gdd/combat-defence.md e5d35f785122c2e04b4f74e03564e6482c01d980
Reviewed-Content-Hash: design/gdd/combat-damage-types.md f465de9486301d5733e3c86fbabae830a0b94a8c
Reviewed-Content-Hash: design/gdd/modifiers.md af999b8be75e7b06c29806ee2f57cfca85d3cf9a
Reviewed-Content-Hash: design/gdd/effects.md cea9de5c3da6afad036851ee9a9e6e6da2624e1f
Reviewed-Content-Hash: design/gdd/dao.md 43e23bfbdc06222d4b7dba2fe9d281f714d04304
Reviewed-Content-Hash: design/gdd/item-database.md e2cbf6a1a3c0b0fb03f8ccc91c72a5dd1ce2ad58
