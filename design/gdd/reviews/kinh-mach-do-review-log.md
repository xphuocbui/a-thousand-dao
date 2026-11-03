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

## Review — 2026-11-03 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 13
Summary: All arithmetic reproduces (points ladder incl. L=266/267/300, A2, B, C, D, E, E2, F budgets, G, H; 25 capabilities map to 13 hosts once each) and there are no registry conflicts. Three narrow blockers remain in the validator and test spec: step 9's "fixed huyệt" can re-add a stat above step 8's compounding caps; the validator has no sealed mode so T3 capability notables break AC-KMD-39; AC-KMD-34 states a cut value that step 6's rounding contradicts. The GDD is revised in the same session; the hashes below are of the version reviewed, before those edits.
Prior verdict resolved: Yes (step 10 blocker replaced by the step 9 loop; its recommended items addressed)
Findings:
- [BLOCKING] Formulas F step 9: "within every cap" is false for compounding/lifespan caps (field_plots on a notable at n<9; three 0.1 breakthrough_chance smalls at n=3); AC-KMD-35 does not test compounding caps
- [BLOCKING] Formulas F / AC-KMD-39: no sealed-cluster validator mode; T3 capability notable (0 W) conflicts with step 3 and the capability ban, so "zero repairs" cannot pass
- [BLOCKING] AC-KMD-34: +30% attack cuts to 2.2 W (0.1 precision), not 2.264 W; "cut to 4" is inexact after floor rounding
- [RECOMMENDED] Formulas C: tail clamp is about 1.4%, not 0.5%
- [RECOMMENDED] Tree breakthrough_chance (up to 8 pp) not reconciled with the 0.30/0.70 targets or E2's "at most 0.80"
- [RECOMMENDED] Formulas F variables B range 13-67 vs registry 10.7-67.2
- [RECOMMENDED] Capability table #23 "10 years" vs max(10, 5% of L_r)
- [RECOMMENDED] AC-KMD-54 reference machine undefined
- [RECOMMENDED] Formulas A2 S0/N0 not derivable from the stated formula; old mean 7.55 uses prototype notable share
- [RECOMMENDED] Formulas F step 9 rescale base unspecified
- [RECOMMENDED] Formulas E2 S=1 division by zero
- [RECOMMENDED] Tuning Knobs missing g1/g2, cap_min_n, delta_desp, q_max, burn share, point-ladder inputs; cluster_count range vs fixed 9-14 inner window
- [RECOMMENDED] lifespan_years has no tree-wide ceiling
- [RECOMMENDED] Rule 6 "inner or middle band" vs link depth 3-7
- [RECOMMENDED] Open Question 12 (map topology) still open; blocks rule 1 implementation
- [RECOMMENDED] Stale status line
Resolution (same day, user chose revise now): step 9 fixed huyệt now uses an uncapped stat and step 8 removes stats whose cluster cap floors below one unit; sealed validator mode added (AC-39 updated); AC-34 values corrected plus two new fixtures; AC-35 checks compounding caps. 11 of 13 recommended items addressed; the lifespan tree-wide ceiling became Open Question 14 and Open Question 12 (map topology) stays open. Re-review pending.
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 54636a89564cc77628c1e06047cfdc9a5d1b1620
Reviewed-Content-Hash: design/registry/entities.yaml 9053a343477e76a35a65d691a14af0723c40b4f2
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 1e19d8772a8f7a098184d3223d3e9d86b4a9a261
Reviewed-Content-Hash: design/gdd/systems-index.md 73444200e81715b32bc897444dea673498d811ac
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 9a0d75dc0b6082a4ec34474342cd299edfc8fbbd

## Closure — 2026-11-03 — Status: Designed (no fourth pass)
The user decided to stop the review loop after the third pass. The blockers went 4, then 1, then 3, all narrowing to fill-validator rounding details, and the core design has been stable since review 2. The remaining validator details are finalised during implementation against AC-KMD-31..39. Not a formal APPROVED verdict. Open Question 12 (map layout) blocks the rule 1 build.
