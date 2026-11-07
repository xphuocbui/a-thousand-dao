# Review Log: Heavenly Tribulation (Thiên Kiếp)

## Review — 2026-11-06 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 7
Summary: The design is sound and its math recomputes cleanly against the registry, Combat and Realms. Two cross-document and rule contradictions blocked approval. All were fixed in the same session; a re-review decides Approved.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Detailed Design rules 3 and 6 vs Formulas D: `equiv_realm` was per-boss in the rules but forced to the destination realm by the lint. Fixed: field dropped.
- [BLOCKING] Dependencies: Character Stats and Item Database did not list this system. Fixed: rows added to both.
- [RECOMMENDED] Edge Cases: save-scum stance undocumented. Fixed: reload allowed, death final on ironman saves only.
- [RECOMMENDED] Registry: `pool_target`, `stall_share`, `tribulation_enabled` unregistered. Fixed.
- [RECOMMENDED] Formulas: ehp units (9,400) vs Combat's 94 U unbridged. Fixed.
- [RECOMMENDED] Acceptance Criteria: AC-TK-65 tolerance too loose; AC-TK-16/17 weak. Fixed.
- [RECOMMENDED] Tuning Knobs section absent (advisory). Fixed: table added.
- [RECOMMENDED] Open Questions 4 and 5 (hidden draw, pill duration) are assumptions awaiting the user. Open.
- [RECOMMENDED] AC-TK-67 provisional until the boss pool and Combat build exist. Open.
Reviewed-Content-Hash: design/gdd/thien-kiep.md 27f4e419bb4d751ce18e66fa501e70c35c4e5b92
Reviewed-Content-Hash: design/registry/entities.yaml fa1195a9428bb4cf4114df808e139a7137f554ba
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md 794d7b9a67b2a8fe8c18feb0848b55d25e07904c
Reviewed-Content-Hash: design/gdd/combat.md 198d428dd1da70e74588d35db5e87f63d264af17
Reviewed-Content-Hash: design/gdd/character-stats.md ee140066d800a0e00cb90e773e38c1e76f5cb5f4
Reviewed-Content-Hash: design/gdd/item-database.md 025cce7e96a08953e5cd4c4e05ca31ccb29ce4eb
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc

## Review — 2026-11-06 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 6
Summary: Re-review after the first NEEDS REVISION fixes. Formulas, draw odds, carry-over and lint boundaries all recompute against the registry, Combat and Realms. The rules are approved; the numbers stay provisional until the Balance Harness measures p_t (Open Question 2).
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Combat Dependencies: Tribulation row said "Not designed". Fixed in this session.
- [RECOMMENDED] Realms Interactions: row said "not started". Fixed in this session.
- [RECOMMENDED] Rule 1 / Formulas E: the tribulation_steps row schema (step, destination realm, buff keys and amounts) is only implied.
- [RECOMMENDED] Rule 9 / Open Question 9: reward and buff form still an assumption.
- [RECOMMENDED] AC-TK-16, AC-TK-17: "at least 5 distinct lists" from 20 inputs is a weak check.
- [RECOMMENDED] Player Fantasy: advisory section absent.
Reviewed-Content-Hash: design/gdd/thien-kiep.md 58b227473bc64c4ee88237f7803f6fe8ea6013b9
Reviewed-Content-Hash: design/registry/entities.yaml fa1195a9428bb4cf4114df808e139a7137f554ba
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/canh-gioi.md e85220be59d4b1a789bc7816f28b5f697ee2e90e
Reviewed-Content-Hash: design/gdd/combat.md ba6a0641df0f79625e9fbaad06619afe68f5e99a
Reviewed-Content-Hash: design/gdd/character-stats.md ee140066d800a0e00cb90e773e38c1e76f5cb5f4
Reviewed-Content-Hash: design/gdd/item-database.md 025cce7e96a08953e5cd4c4e05ca31ccb29ce4eb
Reviewed-Content-Hash: design/gdd/game-concept.md 0430e49dd96dd3f455d70f249ec1f6c7f76823bc
