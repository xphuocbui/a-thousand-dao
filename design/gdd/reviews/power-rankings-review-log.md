# Power Rankings: Review Log

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 5 | Recommended: 6
Summary: All six required sections are present and every formula example and AC number checks out by hand. The blockers were gaps in the rules: a conflict with Combat rule 17 on NPC duels, a season budget that ignored the ~64,000-fight world-generation panel backlog and steady-state panel demand, a States table that disagreed with the breakthrough and data-version edge cases, an ambiguous "rated", and a seed key without the fight index. All five were resolved in the same session (user decisions: world-generation panels at load, `panel_budget_share` 0.5, "rated" = any state, the Combat rule 17 amendment noted here and owed by combat.md); a fresh re-review decides Approved.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Core Rules 11 / Dependencies: world fights by rating roll contradict Combat rule 17 and the registry's `rating_clash` note (NPC duels run the full fight); only `display_power` was listed as owed. Resolved: rule 17 added to the owed Combat amendment.
- [BLOCKING] Formulas, Season budget / rule 14: world generation leaves ~64,000 panel fights (6–7 seasons of budget, no matchmaking meanwhile); ~110 panels a season was an unstated 2 % build-change rate. Resolved: rule 16 (panels at load), `panel_budget_share` 0.5, stated assumed rate, Kết Đan round robin moved after matchmaking.
- [BLOCKING] States and Transitions: breakthrough → Provisional, old save → Provisional, and data-version change on Provisional fighters missing; rule 5 listed realm change as Stale. Resolved.
- [BLOCKING] Core Rules 8, 9, Edge Cases: "rated" ambiguous between the Rated state and any rating. Resolved: any state.
- [BLOCKING] Core Rules 13: seed key lacked the fight index (ADR-0003 decision 4 has it), so repeated fights of one pair in a season shared a seed. Resolved; AC-PR-23 extended.
- [RECOMMENDED] Dependencies: bidirectional notes (Combat, Realms, Sects, Living World Tick), registry entries for this GDD's formulas, `display_power` deprecation. Systems index row added (#44).
- [RECOMMENDED] Tuning Knobs: section absent (advisory at standard); constants and safe ranges scattered in Formulas tables.
- [RECOMMENDED] Formulas G: rationale said 131 and "within 4"; 400·log10(1.45²) is 129, 45/stage is within 6. Fixed.
- [RECOMMENDED] Season budget: population figures (28 top fighters, 200 Kết Đan) did not match world_generation.json weights (~30, ~190). Fixed.
- [RECOMMENDED] Edge Cases: world fights ignore injury (the old duel's `injured_power_floor`); state whether an injured NPC fights at full rating.
- [RECOMMENDED] Acceptance Criteria: add a minimum spread of panel base ratings per realm on a generated world (Open Question 1: Luyện Khí panels saturate near 760).
Follow-up: ADR-0003 needs a short amendment for rule 16 (panels at load) and `panel_budget_share`.
Reviewed-Content-Hash: design/gdd/power-rankings.md c31ffa950e6f8bc1baab18ead8cf443ebf3a9921
Reviewed-Content-Hash: design/registry/entities.yaml 8b69ba1acdd496e1dd852edcdb95bed4ba7903b5
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 16f6c74f5052fba36d5d31a7bfaf34afa96697d3
Reviewed-Content-Hash: design/gdd/systems-index.md a82ace6d07fefa9092f1e1257b3f5856951d9b1b
Reviewed-Content-Hash: assets/data/world_generation.json 040a8757ebf71a85c03c9d77378017171d65e7d0
Reviewed-Content-Hash: assets/data/combat_rules.json 4c701ffe5141439b8630a1bf9a83216a6de7b00e
Reviewed-Content-Hash: docs/architecture/adr-0003-fight-based-power-ratings.md b30db2db16fddede47802be41831042410b6e707

## Review — 2026-11-14 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 7
Summary: Re-review after the first review's five blockers were resolved. All formula examples and AC numbers check by hand, registry values match, and Combat (rule 17, Formulas K, AC-CB-65) and ADR-0003 (decisions 9-11) carry their amendments. Remaining items are stale tracking notes and small text fixes.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Dependencies: Combat row still said an amendment was owed; combat.md is amended. Fixed.
- [RECOMMENDED] systems-index #44: same stale note. Fixed with the status change to Approved.
- [RECOMMENDED] Formulas D: `n ← n + 1` after each fight was never stated (AC-PR-21 relies on it). Fixed.
- [RECOMMENDED] Formulas F example: E 0.3995 should be 0.4000 (AC-PR-34a already 0.400). Fixed.
- [RECOMMENDED] Registry: K_0, K_min, n_half, prior_games, calibration_fights, match_fights, match_window have no constant entries; add with combat_rankings.json.
- [RECOMMENDED] Open Question 1: Luyện Khí panels saturate; keep AC-PR-54 a hard gate before the flag is switched on.
- [RECOMMENDED] Player Fantasy: no own section (advisory at standard).
Reviewed-Content-Hash: design/gdd/power-rankings.md 08b62ef0aeb43a7decad3c7cbbd1725ed4db587d
Reviewed-Content-Hash: design/registry/entities.yaml 897f3b862f76cabafe28ebe395bd68a938e4c068
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 2f65070a8b08768605352ae3a41836cc934b5e5d
Reviewed-Content-Hash: design/gdd/systems-index.md 7c9f758dd4c649fcb721d766697faed2722f7c24
Reviewed-Content-Hash: assets/data/world_generation.json 040a8757ebf71a85c03c9d77378017171d65e7d0
Reviewed-Content-Hash: assets/data/combat_rules.json 4c701ffe5141439b8630a1bf9a83216a6de7b00e
Reviewed-Content-Hash: docs/architecture/adr-0003-fight-based-power-ratings.md 22879fbc9c947417c066118df93304a02d03e02b

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 1 | Recommended: 8
Summary: Re-review of the same-day ladder revision (measured anchors, ladder panel, coarse panels at load). Every worked example and AC number checks by hand and the budget arithmetic reconciles. The one blocker was that rule 13 and ADR-0003 decision 4 keyed seeds on fighter pairs only, so ladder-panel fights (a rung, not a second fighter) had no defined seed. Fixed in the same session; the GDD changed after this review, so a fresh re-review decides Approved.
Prior verdict resolved: Yes (prior APPROVED covered the pre-ladder text)
Findings:
- [BLOCKING] Core Rules 13 / ADR-0003 decision 4: no seed key for panel fights. Resolved: keyed on game seed, season, fighter id, realm, rung, fight index (season 0 at world generation); AC-PR-23 extended; ADR amended.
- [RECOMMENDED] Tuning Knobs: rung_div and k_max tuned independently; reach could drop to x8. Resolved: k_max / rung_div >= 6, AC-PR-56.
- [RECOMMENDED] Edge Cases, beasts: stale "12 fights". Resolved.
- [RECOMMENDED] Formulas C example: odds 3.420 should be 3.431. Resolved.
- [RECOMMENDED] AC-PR-15: "id band" undefined. Resolved (tenth of the realm in id order).
- [RECOMMENDED] Formulas C compute cost mixed fight.py and Godot figures. Resolved.
- [RECOMMENDED] UI example 819 Trúc Cơ vs 835. Resolved.
- [RECOMMENDED] Registry: K_0, K_min, n_half, prior_games, calibration_fights, match_fights, match_window still have no constant entries; add with combat_rankings.json. Open.
- [RECOMMENDED] AC and Open Question numbering out of sequence (53 before 52, 54/55 among Formulas, OQ 6 after 8). Open, cosmetic.
Reviewed-Content-Hash: design/gdd/power-rankings.md b12793a007ae16a1b78ad9c7f3e62be1dfa8675d
Reviewed-Content-Hash: design/registry/entities.yaml d9a8f57cf6626230081b6c247368dd4942fafd94
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 72b483c4ca7795f7be805af929dc2983d454547f
Reviewed-Content-Hash: design/gdd/systems-index.md 5d6c63dc878577f79c1c56ede12af4692e6db9b4
Reviewed-Content-Hash: assets/data/world_generation.json 040a8757ebf71a85c03c9d77378017171d65e7d0
Reviewed-Content-Hash: assets/data/combat_rules.json 4c701ffe5141439b8630a1bf9a83216a6de7b00e
Reviewed-Content-Hash: docs/architecture/adr-0003-fight-based-power-ratings.md 58104e301fe7c3fb2c20d1e8d473e37cfbe913a3

## Review — 2026-11-14 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean)
Blocking items: 0 | Recommended: 6
Summary: Re-review of the ladder revision after the previous entry's one blocker (no seed key for panel fights) was fixed: rule 13, AC-PR-23 and ADR-0003 decision 4 now key panel fights on game seed, season, fighter, realm, rung and fight index. Every worked example and AC number, the search traces (AC-PR-06, AC-PR-29) and the season-budget arithmetic check by hand; all 22 registry constants match, including the ones earlier reviews found missing. Remaining items are a tuning risk and small text fixes.
Prior verdict resolved: Yes
Findings:
- [RECOMMENDED] Formulas A / Season budget: the refinement drain (~80,000 fights against ~1,800-5,000 a season, higher realms first) can leave Luyện Khí on coarse bases (±3 rungs, ~720 Elo, beyond offset_cap) for years; state the expected early ordering accuracy or give Luyện Khí a minimum panel share.
- [RECOMMENDED] Status header and systems-index #44 still said re-review pending. Fixed with this approval.
- [RECOMMENDED] Formulas A: realm_step "about 4,400" vs 4,100 for A_4 - A_3 in the illustrative anchors; say 4,100 to 4,400.
- [RECOMMENDED] Dependencies: bidirectional note cites ADR-0003 decisions 9-11; the ladder revision's decision 12 supersedes parts of them; cite 9-12.
- [RECOMMENDED] Registry: no entries for health_elo or v_c.
- [RECOMMENDED] Tuning Knobs: safe ranges of k_max and rung_div allow a pair (24 / 8) that AC-PR-56 refuses; state the pair constraint there.
Reviewed-Content-Hash: design/gdd/power-rankings.md 18710f326f7d01e740afe52d265389e6222253d5
Reviewed-Content-Hash: design/registry/entities.yaml 4e3aa15522ae3f2341b11d6717256ac3d9f23a0a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat.md 72b483c4ca7795f7be805af929dc2983d454547f
Reviewed-Content-Hash: design/gdd/systems-index.md 06a0048cac063dbaf726c1616bbe42859e83d979
Reviewed-Content-Hash: assets/data/world_generation.json 040a8757ebf71a85c03c9d77378017171d65e7d0
Reviewed-Content-Hash: assets/data/combat_rules.json 4c701ffe5141439b8630a1bf9a83216a6de7b00e
Reviewed-Content-Hash: docs/architecture/adr-0003-fight-based-power-ratings.md 58104e301fe7c3fb2c20d1e8d473e37cfbe913a3
