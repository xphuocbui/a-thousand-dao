# NPC Traits — Review Log

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 6
Summary: Structurally complete and arithmetic reproduces (F1, F2, F3, F7, F8 examples). Two implementability gaps: fate-given traits have no opposed-set rule, and n_against / n_with are undefined for mixed-tag choices. Nine dependencies have no GDD yet (expected by design order).
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 2-3 / F4: fate-given draws may yield Heaven-favoured + Ill-starred together; no opposed rule
- [BLOCKING] F7 / rule 9: n_against and n_with undefined when a trait has both affinity and aversion across a choice's tags
- [RECOMMENDED] AC-NT-22: 25/50/25 split needs disjoint, non-opposed parent traits in the fixture
- [RECOMMENDED] Registry: tm_against vs tm_a, fate_p_any vs p_any/p_second name mismatches
- [RECOMMENDED] Edge Cases / rule 17: pool-empty path hedged; forbid 0 leans or keep an AC
- [RECOMMENDED] F6: stock estimate ignores refresh and replacement effects on AC-NT-36 band
- [RECOMMENDED] Header: status line says In Design; index says Designed, pending review
- [RECOMMENDED] Player Fantasy and Tuning Knobs absent (advisory at standard)
Reviewed-Content-Hash: design/gdd/npc-traits.md 6b2c82885ef0d086cc5980a69f47a3fc4c997420
Reviewed-Content-Hash: design/registry/entities.yaml be8d4d9c9b55f399e6f46382ddfe806855e6fc00
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/sects.md 3f76acfb0db8cc0c3d97271b03d76426e8082509
Reviewed-Content-Hash: design/gdd/quests.md 34b5f67d0857cb7eee2b1daff0a65fa99eda43e3
Reviewed-Content-Hash: design/gdd/modifiers.md 85585177df4bf77132eba252c9af08ee864632c2
Reviewed-Content-Hash: design/gdd/character-stats.md c922793195b355c2f2bcf802e3fb25a4b7d73aa1
Reviewed-Content-Hash: design/gdd/canh-gioi.md 621247dbc70ac007d6752bc9231b1bc040268a05

## Review — 2026-11-14 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Both prior blockers are resolved (fate-given opposed rule in rule 2/F4/AC-NT-35; n_against/n_with defined by per-trait tag product in F7). Arithmetic in F1-F8 and the AC examples reproduces, and the F5 disciple share (0.60 vs 0.24) was confirmed by simulation. Remaining items are wording and registry bookkeeping.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] F6: formula text says an opposed trait replaces outright; rule 13 and AC-NT-13 refuse a small trait opposed to a held notable one
- [RECOMMENDED] Registry: tm_against vs tm_a, fate_p_any vs p_any/p_second, used_this_season vs heart_demon_used
- [RECOMMENDED] Header: status line says In Design; index said Needs Revision
- [RECOMMENDED] AC-NT-22: fixture needs disjoint parent trait sets for an exact 25/50/25 split
- [RECOMMENDED] Edge Cases: pool-empty path is hedged; forbid lean 0 in lint or keep the AC
- [RECOMMENDED] Edge Cases / FX-CAT: Grudge vengeful 1.5 is not in the fixture and has no AC
- [RECOMMENDED] F6: steady-state estimate ignores refresh and replacement (estimate about 980, band still holds)
- [ADVISORY] Player Fantasy and Tuning Knobs absent at standard
Reviewed-Content-Hash: design/gdd/npc-traits.md 7d76cf80c7efbce68d596c8fba9185f28be6cf76
Reviewed-Content-Hash: design/registry/entities.yaml be8d4d9c9b55f399e6f46382ddfe806855e6fc00
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/sects.md 3f76acfb0db8cc0c3d97271b03d76426e8082509
Reviewed-Content-Hash: design/gdd/quests.md 34b5f67d0857cb7eee2b1daff0a65fa99eda43e3
Reviewed-Content-Hash: design/gdd/modifiers.md 85585177df4bf77132eba252c9af08ee864632c2
Reviewed-Content-Hash: design/gdd/character-stats.md c922793195b355c2f2bcf802e3fb25a4b7d73aa1
Reviewed-Content-Hash: design/gdd/canh-gioi.md 621247dbc70ac007d6752bc9231b1bc040268a05
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
