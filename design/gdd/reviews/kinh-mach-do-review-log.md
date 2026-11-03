# Review Log: Kinh Mạch Đồ

## Review — 2026-11-03 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 4 | Recommended: 8
Summary: Structure and arithmetic are sound (points ladder, B/D/E/E2/G/H and the example fill all reproduce; no registry conflicts). Blockers are one wrong test value, a fill-schema contradiction with the notable-placement rule, inconsistent capability ownership (#9 orphaned), and unspecified rounding in the validator.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Acceptance Criteria (AC-KMD-44): q_desp at S=0.70, q=0.90 is 0.9333, not 0.95
- [BLOCKING] Formulas F step 1 vs rule 6 / AC-KMD-21: "k highest-power huyệt become notables" ignores fixed notable slots
- [BLOCKING] Dependencies / Interactions: capability #9 has no host; Combat ownership contradicts host list; #14 has two hosts
- [BLOCKING] Formulas F: rounding precision has no direction or step; AC-KMD-35 can fail by rounding up
- [RECOMMENDED] Missing Tuning Knobs (safe ranges) and Player Fantasy (advisory)
- [RECOMMENDED] Rule 4 x1.5 multiplier applies after caps; state post-multiplier ceilings
- [RECOMMENDED] phi_r is a dead parameter (not in repair order, never binds)
- [RECOMMENDED] Rule 10 "route length" undefined (use C_enter)
- [RECOMMENDED] d_entry vs link depth wording; expansion-band linkage to cluster interiors
- [RECOMMENDED] E2 allows ~0.80 success at edge vs 0.70 target; state intent
- [RECOMMENDED] AC-KMD-54 hardware-dependent; AC-KMD-58 vague
- [RECOMMENDED] Stale text (status line, "proposed for Phase 5", concept update outstanding)
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md e4911c60ace94a7da7020ac494a4cc7f2d639b8e
Reviewed-Content-Hash: design/registry/entities.yaml 07f0a4c69584db64645867b671c54ba79b6c35fa
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 1e19d8772a8f7a098184d3223d3e9d86b4a9a261

## Review — 2026-11-03 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 13
Summary: All 4 prior blockers were fixed and the arithmetic reproduces (points ladder, premium, budgets, E2 guard, NPC chance, tree sizing). One new blocker: Formulas F step 10 (quantize and replace) could push a fill above B and left per-stat precision undefined. The GDD was revised in the same session (see Resolution); the hashes below are of the version that was reviewed, before those edits, so the next review runs in full.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Formulas F step 10: a stat that rounds to 0 is replaced after the budget scale, so power can exceed B; precision per stat is undefined, so AC-KMD-35 is untestable
- [RECOMMENDED] AC-KMD-44: q_desp case uses q > S, which the AC itself says cannot occur
- [RECOMMENDED] Formulas F: lifespan_years has no per-cluster cap (n 15 budget allows 22% of L_r); breakthrough_chance has per-cluster caps only
- [RECOMMENDED] Dependencies / Interactions: capability set owner unnamed; two different host lists; "capability hosts" reused in AC-20
- [RECOMMENDED] States and Transitions: no Pending state
- [RECOMMENDED] Rules 3 and 5: ties between equally short routes undefined
- [RECOMMENDED] Rule 10 route length and d_entry vs link depth still undefined (carried)
- [RECOMMENDED] Rule 14 / AC-KMD-48: ascending-id rolls favour low cluster ids
- [RECOMMENDED] Formulas A2, B: inner cost 5-12 should be 6-13; Trúc Cơ 120-point example; no-rescale figure 4,100 W should be 4,270 W
- [RECOMMENDED] AC-KMD-41 asserts provisional tiers
- [RECOMMENDED] AC-KMD-54 has no reference hardware; AC-KMD-58 bundles five behaviours; AC-KMD-33 table row broken
- [RECOMMENDED] E2: intent of the 0.80 edge-life ceiling unstated; #22 text says x2
- [RECOMMENDED] Missing Player Fantasy, Tuning Knobs (safe ranges), target unseals per life (advisory at standard)
- [RECOMMENDED] Stale text: systems-index proposal block, concept cross-reference
Resolution (same day, user-approved): step 10 replaced by a test-before-caps rule plus a budget-and-quantize loop with a precision table; φ_r made the per-cluster lifespan ceiling; tree-wide breakthrough_chance ceiling of 8 pp added; route ties broken by total value then lowest ids; all 13 recommended items addressed; Player Fantasy and Tuning Knobs drafted; Open Questions 10-13 added. Re-review pending.
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 729788d9850eb86e50454850cac6bb1a6309b9c6
Reviewed-Content-Hash: design/registry/entities.yaml 07f0a4c69584db64645867b671c54ba79b6c35fa
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 1e19d8772a8f7a098184d3223d3e9d86b4a9a261
Reviewed-Content-Hash: design/gdd/systems-index.md 07ad3aad5fca8c963a86a0438c534f2bdb1e1ced
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 9a0d75dc0b6082a4ec34474342cd299edfc8fbbd
