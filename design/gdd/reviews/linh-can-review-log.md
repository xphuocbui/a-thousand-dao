# Review Log: Spiritual Roots (Linh Căn)

Note: the GDD header cites an earlier review on 2026-11-04 (NEEDS REVISION, 3 blockers: RNG order, Awakening alignment, pair-bonus dependency). It was not logged here; this is the first logged entry.

## Review — 2026-11-04 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Numbers, draw order and ACs reproduce and match the data files and the registry; the three blockers cited in the header are fixed. Remaining items are cross-document bookkeeping (Awakening trigger path, Realms consumer entry) and balance work the GDD already flags (retune, fruit frequency, bot run).
Prior verdict resolved: Yes (per GDD header; prior review not logged)
Findings:
- [RECOMMENDED] Dependencies: "No cycles" claim and the Awakening trigger path (Realms `breakthrough_succeeded` via the Meridian Map capability) are not stated; Realms' GDD does not list Spiritual Roots as a consumer
- [RECOMMENDED] Formulas F: "those new pairs give 7/13/19/25 %" is the expected new-mutation chance, not the pair bonus
- [RECOMMENDED] Acceptance Criteria (AC-LC-25) / Open Question 1: nine mutations lack target values; travel speed, alchemy_yield and presence weights are local guesses
- [RECOMMENDED] Core Rules 11 / Open Question 9: Linh Căn Quả has no per-life cap or named owner
- [RECOMMENDED] Core Rules 13: unclear whether NPCs get Mutation Awakening
- [RECOMMENDED] Acceptance Criteria (AC-LC-30): ±0.6 pp over 16,000 draws is about 3.2 SE, below the stated four-SE convention
- [RECOMMENDED] Housekeeping: AC-LC-45 to 47 out of order; saved mutation purities contradict recompute-on-load; registry lacks element_count_curve and root-change parameters, and the generating_pair_bonus entry lacks notes and added

Reviewed-Content-Hash: design/gdd/linh-can.md a229f14f4afcfc2d45c72d42055d1a714c0ea7c3
Reviewed-Content-Hash: design/registry/entities.yaml 0e33010f7fdb8dbb534ca36378b788609dea94ba
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/canh-gioi.md fd4adf4dcafa97384ecda6d65b2df4150246e95c
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb

## Review — 2026-11-04 (second) — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 2 | Recommended: 10
Summary: Numbers, draw order, the 29-mutation catalogue and the AC-LC-31 chains reproduce from the data files and the registry, and cross-review blocker C1 (Awakening trigger path) is resolved. Two blockers remained: the Awakening figure (61 % after 4 breakthroughs is unreachable; at most 2 passes, at most 43 %) and the Tẩy Tủy Đan quick spec contradicting rule 9. Both were fixed the same day, together with 8 of the recommended items, after user decisions (rare roots meant to win, Self-made convergence accepted, Linh Căn Quả rare by design with no per-life counter).
Prior verdict resolved: Partly (C1 resolved; D5 found and fixed here)
Findings:
- [BLOCKING] Formulas D / Open Question 5: "about 61 % after 4 breakthroughs" is unreachable (Meridian Map rule 16 leaves two passes); corrected to at most 43 %, cap of 2 stated in rule 9 (fixed)
- [BLOCKING] Core Rules 11 / quick spec phu-luc-linh-thu-thanh-tuu.md: Tẩy Tủy Đan "re-checks mutation" contradicted rule 9 (fixed)
- [RECOMMENDED] Formulas C: "no tier dominates" rested on whole-life years only; reworded, Open Question 11 added (fixed)
- [RECOMMENDED] Edge Cases: Self-made convergence recorded as accepted (fixed)
- [RECOMMENDED] Core Rules 11 / Open Question 9: Linh Căn Quả had no cap; now rare by design, frequency owned by Event Engine budgets, both modes (fixed)
- [RECOMMENDED] Formulas F: 7/13/19/25 % are new-mutation chances, not the pair bonus (fixed)
- [RECOMMENDED] Acceptance Criteria: AC-LC-19 mean mutations had no tolerance; AC-LC-30 tolerance was 3.1 SE (fixed)
- [RECOMMENDED] Tuning Knobs: "50–60 W keystone range" not in registry (fixed)
- [RECOMMENDED] Registry: element_count_curve and root-change parameters (fixed)
- [RECOMMENDED] Rule 9 / Edge Cases: Awakening RNG stream, Deity Transformation Tribulation timing, handler order and NPC Awakening unspecified (open)
- [RECOMMENDED] Open Question 1: nine mutations lack target values; travel speed, alchemy_yield, presence and lifespan_pct weights are guesses (open)
- [RECOMMENDED] Stage-group boundary: surplus rescaling across a multi-level season is undefined (Realms-owned, open)

Note: the target GDD and design/registry/entities.yaml are deliberately not stamped below, because both were revised after this review; the next /design-review therefore runs in full.
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/canh-gioi.md 67204d2eb2bcee0dbd806cd79b930c2c7b093202
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb
Reviewed-Content-Hash: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md 5768f5cbf3f675d0cb0078925e30d10feb0c9ff7
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04.md bc6ceef75f67d96fef0bfe089e05ba08a5730918

## Review — 2026-11-04 (third) — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 9
Summary: Full re-review after the second review's fixes. Numbers, draw order, the 29-mutation catalogue, the AC-LC-31 chains and AC-LC-46 purities reproduce from the data files and the registry; no registry conflicts; Realms, Meridian Map and Character Stats list Spiritual Roots in return. Remaining items are specification gaps (RNG stream for Awakening and fruit rolls) and balance work the GDD already tracks as open questions.
Prior verdict resolved: Yes (2 blockers fixed)
Findings:
- [RECOMMENDED] Rules 9 and 11 / Formulas A: RNG stream, handler order and Deity Transformation tribulation timing for Awakening and Linh Căn Quả rolls unspecified
- [RECOMMENDED] AC-LC-19: mean-mutations tolerances say "confirm against the first seeded run"
- [RECOMMENDED] AC-LC-25: expected to fail until Open Question 1; mark pending
- [RECOMMENDED] AC-LC-38: {Wood, Fire} fixture conflicts with the "4 base elements" keystone bullet
- [RECOMMENDED] Cross-References: canh-gioi row says its DT figure "needs correcting" but Open Question 4 is closed
- [RECOMMENDED] Acceptance Criteria: AC-LC-45 to 47 out of order
- [RECOMMENDED] Open Question 11: a five-element root's ~109 W start conflicts with "slow and fragile in Qi Refining"
- [RECOMMENDED] Open Questions 1, 2, 8, 9, 10: retune, bot run, aggregate power cap, fruit frequency, single-root identity still open
- [RECOMMENDED] game-concept.md lines 98 and 172-173: "about 30" mutations and the mutations-count-as-elements question are stale

Reviewed-Content-Hash: design/gdd/linh-can.md 3830e428a2190d178cc469a4e377bf4e688f4f68
Reviewed-Content-Hash: design/registry/entities.yaml e2cecf0f0cfa507b467ba301a020ac3cd2c8333c
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/character-stats.md 812988e463b2de24d385260b023cc4616c0ccdb7
Reviewed-Content-Hash: design/gdd/canh-gioi.md 943bb6c6bb9137d909d4cfd212cb7838bb63dcf5
Reviewed-Content-Hash: design/gdd/kinh-mach-do.md 15bfc056b73de8895c01444f48a17d49e2ad84a3
Reviewed-Content-Hash: design/gdd/game-concept.md 22b0a52bfb634daaf974870d4c706c394ac9b3bd
Reviewed-Content-Hash: assets/data/character_elements.json 01385a80395e4086d65a80043c9f522eea2c90fb
Reviewed-Content-Hash: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md 5768f5cbf3f675d0cb0078925e30d10feb0c9ff7
Reviewed-Content-Hash: design/gdd/gdd-cross-review-2026-11-04.md bc6ceef75f67d96fef0bfe089e05ba08a5730918
