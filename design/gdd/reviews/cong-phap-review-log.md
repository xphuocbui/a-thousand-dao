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
