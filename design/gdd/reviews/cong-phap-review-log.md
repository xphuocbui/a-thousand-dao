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
