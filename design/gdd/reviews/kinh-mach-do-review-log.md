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

## Post-closure change — 2026-11-03 — topology (not reviewed)
Open Questions 12 (map topology) and 10 (center keystone) were resolved after the closure, by user decision with systems-designer numbers:
- kinh lộ highways (3 radials per sector, 3 ring roads), hội junctions, 1–3 entries per cluster;
- flexibility limits, 5 crossings per border, 8 shape templates, generator spec G1–G8;
- visible tree 802 (map about 1,475), H0 = 1.2, Đan Điền exempt at degree 6;
- AC-KMD-06/10/11/12 updated and AC-KMD-60..66 added.

These sections (rule 1, Formulas A2, B, D d_entry, H, Tuning Knobs, Parameter keys) have NOT had an independent /design-review. Review them before the tree generator is built.

## Review — 2026-11-03 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 7
Summary: Full re-review, including the topology added after the closure. All arithmetic reproduces (points ladder, visible tree sizing of 802, skeleton edges 506, degree split 40/45, premium, budgets, E2 guard, NPC unseal chance, cluster-size distribution) and the registry has no conflicts. All three third-pass blockers are resolved. One new blocker in the shape catalogue: the 2-step notable rule cannot be met for some (shape, n, E) combinations, so AC-KMD-66 could not pass. The GDD was revised in the same session (see Resolution); the hashes below are of the version reviewed, before those edits, so the next review runs in full.
Prior verdict resolved: Yes (third-pass blockers fixed; the post-closure topology is now reviewed)
Findings:
- [BLOCKING] Topology G6 / AC-KMD-66: notable_min_entry_dist 2 is unsatisfiable for Ring n 5 (E 3, and the bridge pair v0,v2) and Star n 5 (E 3); "supports n and E" ignored it
- [RECOMMENDED] Formulas A2 / Rule 1: the center keystone (d 1, 50 W, 1 point) is about +47% of a Luyện Khí tree; keystone drawbacks unpriced; AC-KMD-07 silent on 5-element lives
- [RECOMMENDED] Tuning Knobs: g1 range 5-7 conflicts with cap_min_n 7 (g1 = 7 gates an n = 7 capability cluster at Trúc Cơ)
- [RECOMMENDED] G7 link capacity: about 150 kinh lộ host slots, not 175, so the ratio is about 1.27 against a 1.25 margin; inner and middle unchecked; no expansion capacity stated for rule 19
- [RECOMMENDED] Generator feasibility: combined seed acceptance rate unknown against seed_max_attempts 64; G8.3 repair does not re-run the local checks
- [RECOMMENDED] Formulas F step 9 vs AC-KMD-35: a dropped sole stat plus an attack_pct fix can leave fewer than 3 distinct stats
- [RECOMMENDED] Text: "wheels" undefined; Open Question 6 "10 more keystones" arithmetic; Formulas H hard-coded radial counts; "about 4%" lifespan figure is 4.7%
- [RECOMMENDED] Open Questions 5, 9 and 14 still open (capability tiers, #14 two-cluster requirement, tree-wide lifespan ceiling)
Resolution (same day, user chose revise now): "supports" now includes the notable-distance test with unsupported and supported fixtures in AC-KMD-66 (user chose this over relaxing the rule at n 5); AC-KMD-67 added for generator acceptance (at least 10% of 200 seeds); center keystone kept and marked intended, 5-element lives excluded from AC-KMD-07's median (user's choice); g1 range 5-6; link capacity recounted to 1.27 with an expansion note; G8.3 repair re-runs local checks; step 9 variety re-check added; text items fixed. Open Questions 5, 9 and 14 stay open. Re-review pending.
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md da0d3b4866255a7ebe335fc9db118ac9dd3155a9
Reviewed-Content-Hash: design/registry/entities.yaml 62f8c116bf16e792b73237ee632743d092a6079d
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 1e19d8772a8f7a098184d3223d3e9d86b4a9a261
Reviewed-Content-Hash: design/gdd/systems-index.md f939cd73cd055edcfa4cb425c6816c07349d8a0e
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 9a0d75dc0b6082a4ec34474342cd299edfc8fbbd

## Review — 2026-11-03 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 7
Summary: Full re-review of the revision made after the fourth pass. The prior blocker (notable distance vs AC-KMD-66) is resolved: the Ring and Star n=5 fixtures check out by hand, as do the recounted link capacity (about 150 kinh lộ slots, ratio 1.27), the hội and degree split (40 and 45), the 802 total, the 2.36 average degree and the AC-KMD-12, 29, 30, 34 and 63 fixtures. The registry has no conflicts. One new blocker: the step 9 "variety after the loop" re-check added last pass compares against B_rest, which ignores the unfixed huyệt, and does not check the per-huyệt cap, so it can exceed B or a huyệt cap; AC-KMD-35 does not assert the per-huyệt cap. The GDD was revised in the same session (see Resolution); the hashes below are of the version reviewed, before those edits, so the next review runs in full.
Prior verdict resolved: Yes (fourth-pass blocker fixed)
Findings:
- [BLOCKING] Formulas F step 9 variety re-check: tests B_rest (not the cluster's real total) and ignores the huyệt power cap, so a result can exceed B or a cap; AC-KMD-35 has no per-huyệt cap assertion
- [RECOMMENDED] G6 "supports" depends on role (bridge slots) and k (visible vs hidden); AC-KMD-66 enumerated only (shape, n, E); no check that some shape always supports
- [RECOMMENDED] link_capacity_margin: G7 says report-only above 1.0, Tuning Knobs said it rejects the launch map; AC-KMD-67 listed it as a rejection reason
- [RECOMMENDED] entry_count_weights range 1.8-2.3 "derived from margin 1.25" is wrong: the margin caps the mean at about 2.03; AC-KMD-65's 2.15 gives a ratio of about 1.18
- [RECOMMENDED] Name collision: right radial R (R2 at G1, R9, R17) vs ring roads R1-R3
- [RECOMMENDED] G8.3 shape conversion does not say how entries move to the new shape's slots
- [RECOMMENDED] ring_anchor_depths safe range (K1 4-6, K2 13-15) breaks the hard-coded hội spacing of G2 / AC-KMD-61
- [RECOMMENDED] Open Questions 4, 5, 9 and 14 still open; map size stated as 1,475 and 1,477
Resolution (same day, user chose revise now): variety unit now needs a single-stat huyệt, room under its cap and the cluster's real total plus the unit at or below B, else the pool fill; AC-KMD-35 asserts the huyệt cap and AC-KMD-34 has three variety fixtures; "supports" is evaluated per role and k, with a coverage property and two new fixtures in AC-KMD-66; link margin is report-only everywhere (user's choice); entry mean range 1.8-2.15 with the derivation corrected; rings renamed K1-K3 (user's choice); G8.3 maps entries by slot index; ring anchors fixed at 5 / 14 / 20 (user's choice); 1,477 explained; extra hội hosts noted in G7. Open Questions 4, 5, 9 and 14 stay open. Re-review pending.
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md fb0a2d39d413b52356d569e0ad421f322d6e21c6
Reviewed-Content-Hash: design/registry/entities.yaml 62f8c116bf16e792b73237ee632743d092a6079d
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 1e19d8772a8f7a098184d3223d3e9d86b4a9a261
Reviewed-Content-Hash: design/gdd/systems-index.md a0191fa9c6b5e4a48bd28e8ffd9253732c7a8acf
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 9a0d75dc0b6082a4ec34474342cd299edfc8fbbd

## Review — 2026-11-03 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 8
Summary: Full re-review after the step 9 variety fix. The prior blocker is resolved: the variety unit needs a single-stat huyệt, room under its cap, and the cluster's real total plus the unit at or below B. Recomputed by hand with no discrepancy: every AC-KMD-01 row and AC-02/03, the 802 total, 430 kinh lộ, 85 hội (40/45), 506 skeleton and 946 total edges (mean degree 2.36), AC-KMD-66 fixtures, link capacity 1.27, AC-30 budgets, E2 examples, AC-47. The registry has no conflicts. Remaining items are wording and specification detail, not design gaps.
Prior verdict resolved: Yes (fifth-pass blocker fixed)
Findings:
- [RECOMMENDED] AC-KMD-34: "lifespan_years at L_r = 120 is at most 5.03 years" holds only for the n 9, d_entry 19 cluster; at P 1.75 the cap is 5.6 years (consistent with the 4.7% in Formulas F). Name the cluster or state 5.6
- [RECOMMENDED] Formulas F step 9 variety unit: no rule for which qualifying huyệt receives it, whether to try the next stat when the highest-power stat's unit does not fit, or whether candidates come from the theme pool or all fill_stats
- [RECOMMENDED] Formulas F step 9: "each pass fixes at least one huyệt" is false for the last pass; state that the loop ends when a pass leaves no huyệt empty
- [RECOMMENDED] Formulas A2 keystone note points to Open Question 4 (themes); keystone content is Open Question 6, which omits the center keystone Ngũ Hành Luân Chuyển
- [RECOMMENDED] Symbol collisions: ring K1-K3 vs cluster K (C_enter(K), AC-22..25); radial L/C/R vs level L, link L_i and Formulas C
- [RECOMMENDED] G7 link capacity is global; hidden clusters in a rim region can use only that sector's K3 hosts (about 4 per sector plus degree-3 hội); add a per-region estimate
- [RECOMMENDED] AC-KMD-66 repeats one sentence; Tuning Knobs entry mean 1.8-2.15 vs AC-KMD-65 1.85-2.15 needs a note
- [RECOMMENDED] Open Questions 4, 5, 9 and 14 still open
Resolution: GDD status header and systems-index row 10 set to Approved in the same session (header text only, so the hash below covers the approved content). The recommended items are not yet applied.
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 0ceac03087eb94201cd31665418675d96f8b7fd8
Reviewed-Content-Hash: design/registry/entities.yaml 62f8c116bf16e792b73237ee632743d092a6079d
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/game-concept.md 1e19d8772a8f7a098184d3223d3e9d86b4a9a261
Reviewed-Content-Hash: design/gdd/systems-index.md 4c91de89f41daa69aaff5f2a664a519f30e5b8bf
Reviewed-Content-Hash: design/quick-specs/progression-and-edges.md 9a0d75dc0b6082a4ec34474342cd299edfc8fbbd

## Cleanup — 2026-11-04 (no new review)
Cross-GDD review 04e W-D: the capability catalogue no longer names a nonexistent Lifespan system; #7 touches Time & Turn (aging) and #23 Realms, with its burned years added to age (Realms rule 18). No values changed.

## Cleanup — 2026-11-04 (E2 talisman guard, user decision; no new review)
Realms & Bottlenecks rule 8 allows one breakthrough talisman per realm step (τ 0.05) on a held pill attempt, which may be the #22 Last Radiance attempt. The old guard then allowed a lift of 0.1·0.8775/0.8275 = 0.106 at q 0.1225, over δ_max 0.10. Formulas E2 now carries τ_a (0 or τ, the talisman on the #22 attempt; q is the chance without it): `q_desp = min(2q, q + Δ_desp, q_max − τ_a, q + δ_max·(1 − q − τ_a)/(1 − S))`, attempt chance q_desp + τ_a, `S'_22 = 1 − (1 − S)·(1 − q_desp − τ_a)/(1 − q − τ_a)`. The lift is ≤ δ_max by construction; τ_a = 0 gives the old formulas exactly; q_retry is unchanged (#23's extra roll never carries a talisman). Updated: E2 attempt model, formula, derivation, variables (τ_a, q_desp), output range, a talisman example (S = q = 0.1225: q_desp = 30439/140400 ≈ 0.2168020, attempt 0.2668020, lift 0.100), AC-KMD-44 (new clamp line; property test covers τ_a in {0, 0.05}), and the Dependencies row for Realms & Bottlenecks. No tuned values changed. Status unchanged; re-review is the main session's call.

## Cleanup — 2026-11-04 (cross-GDD review 04g fixes; no new review)
User-approved mechanical fixes from `design/gdd/gdd-cross-review-2026-11-04g.md`. C7: the E2 intent now says a capability adds at most δ_max (0.10) to whatever S the life has built (the stale "at most 0.80 / at most 0.40" figures are gone); the baseline note now says the tree as the bot allocates it (about 0.02 of the cap) sits inside the targets, and a maxed tree is Realms & Bottlenecks Open Question 13. C10: the E2 talisman example and the AC-KMD-44 fixture used S = q = 0.1225 with τ_a 0.05, a state that cannot occur (S ≥ q + τ_a); both now use S = 0.1725, q = 0.1225, τ_a = 0.05, giving q_desp = min(0.245, 0.2725, 0.90, 0.2225) = 0.2225, an attempt chance of 0.2725 and a #22 lift of 0.8275·0.10/0.8275 = 0.100 (the old-guard comparison is now q_desp 0.2285, lift 0.106). The AC-KMD-44 property test's q domain is now 0.01–min(S − τ_a, 0.95 − τ_a). C18: E2's S range reads 0 ≤ S < 1 (S_guard capped at 0.95) in both Variables and Output Range. No tuned values changed. Status unchanged; re-review is the main session's call.

## Cleanup — 2026-11-04 (cross-GDD review 04g F11: field_plots 20 W; no new review)
User decision on `design/gdd/gdd-cross-review-2026-11-04g.md` F11. Formulas F weight `field_plots` 10 W → 20 W: one plot is worth about +0.06 S at a breakthrough at the root-free median, about 3.8 pp of q (Realms & Bottlenecks Formulas D; fields are a build), so about 19 W at 5 W per pp, rounded to 20 W. Consequence, from existing rules only: 20 W is over every acupoint's power cap at launch values (tol·E_small ≤ 2.52 W, E_notable ≤ 14 W, capability notable ≤ 7 W), so validator step 6 removes any plot and refills from the theme's pool; no cluster over-spends (B does not depend on w), and the tree gives no plots unless N0·P ≥ 20 W (N0 ≥ 11.43 at P_max, outside the 7.0–9.1 safe range). The `field_plots` compounding cap 1 is kept as the guard for that case. Updated: weight table, precision note, a new "Plot price" note in Formulas F (rationale, fill effect, bot policy), the step 6 and step 8 examples, the AC-KMD-33 repair row, AC-KMD-34 (the plot notable now loses it at step 6; the step-8 case uses a fixture N0 that lifts E_notable to ≥ 20 W), E2's baseline note and AC-KMD-50 (the bot's calibration runs, including Realms AC-CG-30 and AC-CG-60, take no `field_plots` acupoint). Formulas F also states the tree's `breakthrough_chance` is bounded by both `tree_breakthrough_cap` and Realms & Bottlenecks' character-wide q-extras ceiling (its Formulas C), which Realms owns. Registry: W weights row `field_plots` 20. Status unchanged; re-review is the main session's call.

## Cleanup — 2026-11-04 (user decisions after cross-GDD review 04g; no new review)
Realms & Bottlenecks adds failure insight: each failed pill attempt in a realm step adds ι = 0.02 to later attempts in that step, at most 0.04 (`breakthrough.failure_insight_pp` 2, `failure_insight_cap` 4). #23's failed extra roll then raises the next attempt by ι, and the old guard's #23 lift could exceed δ_max (0.1115 at q 0.30 after one failed attempt at 0.28; 0.1009 at the CF→NS baseline, attempts 0.0825 and 0.1025). Formulas E2 now uses `q_retry = min(q, (δ_max − ι_23)/(1 − S))`, where ι_23 = 0 if the step's insight is at the cap, else min(failure_insight_pp, cap − insight). The exact lift is q_retry·(1 − S) + ι_23·(1 − q_retry)·F_0 with F_0 ≤ 1, so it is ≤ δ_max by construction (conservative). The carry reaches only the next attempt, which needs `failure_insight_cap` ≤ 2 × `failure_insight_pp` (true at launch values); above that ι_23 must become the summed carry. q in E2 is now the attempt's chance including insight and excluding τ_a; #22 is unaffected and stays exact. With ι_23 = 0, q_retry equals the old formula. Updated: attempt model, formula line, derivation (new "#23's insight carry" paragraph), variables (q, ι_23, F_0), output range, the two existing examples (labelled ι_23 = 0), a new example (S 0.17654, q 0.1025, ι_23 0.02: q_retry 0.09715, lift 0.0800 + 0.0166 = 0.0966; old guard 0.1009), AC-KMD-44 (new insight line; the property test covers ι_23 in {0, 0.02} at worst-case F_0 = 1), and the Dependencies row for Realms & Bottlenecks. No tuned values changed. Status unchanged; re-review is the main session's call.
