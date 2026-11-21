# Formations (Trận Pháp) — Review Log

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, economy-designer; senior reviewer creative-director
Blocking items: 6 | Recommended: 12
Summary: The two-part design (diagram as art loadout, standing/teleport/protective arrays) is sound and the formula arithmetic checks out (288, 2,294, 2.44, 33 %/60, 0.09/910). Six contradictions or unbuildable rules remain: the share of a foreseen-but-unlaid diagram, "negative" read as a sign instead of a drawback, what S × share multiplies (Effect nodes, gates, feed seconds), the keystone/skill-cap order, a feed floor that can raise a timer, and unbooked/double-booked array stones. All are fixable inside current mechanics. Unattended run: revision applied the same day under the user's standing authorisation (round 1).
Prior verdict resolved: First review
Findings:
- [BLOCKING] Overview / rule 9 / F1 share row / AC-08: share of a foreseen fight fought without laying is stated as 1.0 in some places and 0.7 in others
- [BLOCKING] Rule 7 / F1 / AC-04 / AC-18: "negative magnitudes are not scaled" reads as a sign, so a −20 % cooldown benefit would escape S; must key on polarity (drawback)
- [BLOCKING] Rule 7 / F1 / AC-05: what S × share multiplies is undefined for Effect nodes, gates, conditions and feed seconds
- [BLOCKING] Rule 7 / F1 / F2 / AC-20: order of the keystone's +2 levels and the skill/max_level cap is unwritten
- [BLOCKING] Rule 6 / feed edge case / AC-05: floor at `cooldown_min` can raise a timer already below it
- [BLOCKING] Rule 14 / rule 17 / F3: array and diagram build/raise stones are booked nowhere; array upkeep claimed by both `burn_formation` and Cave Abode rule 14
- [RECOMMENDED] F1: output range minimum is 0.5 (power −50 %), AC-17 tests −90 % outside the stated range; S_min is a safety bound
- [RECOMMENDED] AC-04: "above 50 %" vs "≥ 50 %" boundary
- [RECOMMENDED] F4: m = 1 for an unscoped node; links not scored
- [RECOMMENDED] F2: output range omits keystone L7 (117 % of budget at grade 4, N 7); fuel trivial at Qi Refining (harness, OQ 6)
- [RECOMMENDED] F5: no stated maximum; sect-owned owner realm undefined
- [RECOMMENDED] Boundary checks: loop claim does not hold for carried diagrams (brake is raise cost, reservation, the 30 % loss)
- [RECOMMENDED] Rule 11: log Effect-node triggers
- [RECOMMENDED] F2 rounding method (6 decimals before ceil); F3 direction and AC-13 upkeep inputs
- [RECOMMENDED] Rule 4: node index doubles as payment priority (state as intended)
- [RECOMMENDED] Many ACs lack numbers; AC-07 needs seed/range; AC-23 misordered; rules without an AC (flight at t=0, mid-fight empty node, tag scope timing, id-order upkeep)
- [RECOMMENDED] Protective burn has no per-season cap; NPC fuel aggregate has no formula (Regional Economy)
- [RECOMMENDED] Usable maximum below the cheapest art: preparation-screen warning
- [RECOMMENDED] Formations yearly upkeep (rule 14) vs Cave Abode seasonal upkeep (rule 8)
- [RECOMMENDED] Teleport: recipient of the non-burnt fee share is Travel & Map's to name
Reviewed-Content-Hash: design/gdd/formations.md 5a479ec40a488e589952cfa5e9c1f8d2eb21bcc7
Reviewed-Content-Hash: design/registry/entities.yaml 575c10bc85887562249fb5046503df1be9a53c08
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/character-stats.md 77c25a612cda9fc53403073f77ff85acc2141728
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/effects.md 94a69453e243a295af6615f81aa495f12faa665f
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b

## Review — 2026-11-21 — Verdict: NEEDS REVISION (round 2)
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, economy-designer; senior reviewer creative-director
Blocking items: 4 | Recommended: 14
Summary: Round 1's fixes landed, but the keystone is inert as written (F3 caps a raise at the skill cap, so the stored level never passes it and `min(L, cap + 2)` adds nothing), the States table drops the Set diagram after every fight, a dormant or left standing array meets two lapse rules (Cave Abode rules 9-10 against the Lapsed state), and F4's greedy placement has no defined weight. All four are one-sentence or one-cell fixes inside current mechanics. Unattended run: revision applied the same day under the user's standing authorisation (round 2).
Prior verdict resolved: Yes (round 1's six blockers resolved; the keystone fix needed F3 headroom)
Findings:
- [BLOCKING] Rule 7 / F3 / AC-FO-20: keystone adds nothing because a raise stops at the skill cap; L8 in AC-20 unreachable
- [BLOCKING] States and Transitions: In fight → Known drops the Set diagram after each fight, against AC-FO-22 and the lost-while-Set edge case
- [BLOCKING] Rule 14 / Cave Abode rules 8-10: dormant or left standing array meets Lapsed (lose a level) and Cave Abode's keeps-its-level rule
- [BLOCKING] F4: "greedily by weight" has no weight; `fit_min` 0 with "below" lets a zero-fit diagram beat the default line
- [RECOMMENDED] Rule 3 / edge case / AC-FO-02: "laid" where "set" is meant for N above slot_count (folded in as wording)
- [RECOMMENDED] Rule 7 / F1: scaled Modifier magnitudes unbounded; a node writes an existing key and inherits its limits (one sentence added)
- [RECOMMENDED] Rule 16 / 17: sect-owned arrays booked in `burn_formation`, not twice via Sects
- [RECOMMENDED] F3: raise_cost(L) is the cost to reach L; variable table; diagram cost values unset
- [RECOMMENDED] AC-FO-16 says "one season" for a yearly tick; AC-FO-13, -14, -19, -26 inputs; AC-FO-05 cycle clause
- [RECOMMENDED] F2 rounding method and L7 range; F5 maximum and sect owner realm; mutual-feed cycle; dangling "(Formulas D.)"
- [RECOMMENDED] Always-lay dominance, flat upkeep at high realms, protective per-season cap (harness, OQ 6)
- [RECOMMENDED] Hộ Sơn vs protective array record; arrays at a place vs the abode slot rule; adjacency plus feed on one pair
Reviewed-Content-Hash: design/gdd/formations.md 6306157e8e50f3f7bc12e61106f3c599f48c4a88
Reviewed-Content-Hash: design/registry/entities.yaml 23c974e4ddad52565ffebf3522ff360539e574ee
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/character-stats.md 77c25a612cda9fc53403073f77ff85acc2141728
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/effects.md 94a69453e243a295af6615f81aa495f12faa665f
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b

## Review — 2026-11-21 — Verdict: NEEDS REVISION (round 3)
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, economy-designer; senior reviewer creative-director
Blocking items: 3 | Recommended: 14
Summary: Rounds 1-2 fixes held. Three blockers remain, each one sentence: rule 17 lists "standing-array" build/raise stones while claiming all (protective and teleport builds unbooked) and its lead sentence books teleport that Regional Economy keeps in `burn_fees`; a scaled cooldown node has no floor (−20 % at S 8 = −160 %); F2's keystone maximum is 5,873 not 5,872. Several specialist "blocking" items (F2 rounding, AC inputs, rule 1 record fields, rule 11 Breakdown lines) were folded in as one-clause fixes. Unattended run: revision applied the same day (round 3).
Prior verdict resolved: Yes (round 2's four blockers resolved)
Findings:
- [BLOCKING] Rule 17 / Interactions: "all array and diagram stones" vs a list naming only standing-array build/raise; teleport double-booked against `burn_fees`
- [BLOCKING] Rule 5 / F1: a scaled cooldown reduction has no floor (negative cooldown at S >= 5)
- [BLOCKING] F2: keystone maximum 5,872 should be 5,873 (ceil of 5,872.03)
- [RECOMMENDED] F2: rounding method (round to 6 decimals before ceil); AC-FO-19
- [RECOMMENDED] AC-FO-04: inputs (laid, S = 1) and an Effect-node oracle; AC-FO-12 "at or below"; AC-FO-13 sources and wording; AC-FO-16 span and ledger wording
- [RECOMMENDED] Rule 1: record omits requirement and node_score; `fuel_frac`/`cost_lt` are data-file lookups
- [RECOMMENDED] Rule 11: Breakdown lines for fuel paid, share, reservation; Game Feel "after the fight" bullet trimmed to the fight log
- [RECOMMENDED] States: Known entry "In fight (swapped out)"; Rule 7 dangling "(Formulas D.)"
- [RECOMMENDED] Tracked, not applied: per-node tally after a fight, player-paid burn vs `player_net`, NPC fuel formula, F5 sect owner/cap, raise without an abode, empty-drawback dominance, AC additions
Reviewed-Content-Hash: design/gdd/formations.md ca95d2d39d664f32be93cfa5f15c788820668abd
Reviewed-Content-Hash: design/registry/entities.yaml 0f4d07b7024015689c5eade6a12968646434fc68
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/character-stats.md 77c25a612cda9fc53403073f77ff85acc2141728
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/effects.md 94a69453e243a295af6615f81aa495f12faa665f
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b

## Review — 2026-11-21 — Verdict: NEEDS REVISION (round 4)
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, economy-designer; senior reviewer creative-director
Blocking items: 2 | Recommended: about 30
Summary: Round 3 fixes held (arithmetic recomputed by three specialists, no errors). Two blockers: rule 5 / F1 / AC-FO-04 / AC-FO-18 use a "cooldown %" Modifier that does not exist (the user replaced it with `art_speed_pct` 2026-11-06; Combat A2 divides, so the floor is `cooldown_min`); rule 14 says a left array keeps its level and never Lapses, against Cave Abode rules 10-11 (upkept works fade when left, gone on a claim). Creative-director ruled the feed floor (round 1) and the NPC fuel aggregate not blocking; a price on a conditioned node folded in as one authoring sentence. Unattended run: revision applied the same day (round 4).
Prior verdict resolved: Yes (round 3's three blockers resolved)
Findings:
- [BLOCKING] Rule 5 / F1 / AC-FO-04 / AC-FO-18 / registry diagram_strength: "cooldown %" Modifier does not exist; restate in `art_speed_pct` and `art_cost_pct`
- [BLOCKING] Rule 14: left array "keeps its level, never Lapses" contradicts Cave Abode rules 10 and 11 (fading, gone on a claim)
- [RECOMMENDED] Rule 7: a node whose authored number is a price is negative polarity whatever its condition (folded in)
- [RECOMMENDED] Rule 12: NPC lay fuel paid from its purse at fight start, Formula H books the season sum (folded in)
- [RECOMMENDED] Rule 6: feed floor means a feed never readies an art; bounded brake (folded in as a sentence); whether feeds may ready an art goes to the user (new Open Question 10)
- [RECOMMENDED] No Tuning Knobs section (advisory at standard); rule 10 ground object undefined; Effect magnitude bounds; crafted start level; empty drawback node; F4 ignores links
- [RECOMMENDED] F2 range per node; F5 Output Range and clamp; upkeep formula missing; F3 variable table; feed-cycle boundary; registry `revised` empty
- [RECOMMENDED] Economy: Formula H AC identity omits burn_formation/burn_abode; player-paid burns vs delta-M; upkeep cadence and partial payment; carried-at-70 % dominance; reserve vs strength lint; protective cap; sink projection
- [RECOMMENDED] QA: 12 AC additions (rule 10 ground object, unscaled counts at S 2.44, feed share, prerequisites, dormant arrays, boundaries)
Reviewed-Content-Hash: design/gdd/formations.md ef2316191526399659e081f990f364302fc8c8e1
Reviewed-Content-Hash: design/registry/entities.yaml 5a0ba7f742789d35294ddcee9ca04a44dc85b514
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/character-stats.md 77c25a612cda9fc53403073f77ff85acc2141728
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/effects.md 94a69453e243a295af6615f81aa495f12faa665f
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b

## Review — 2026-11-21 — Verdict: NEEDS REVISION (round 5)
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean, single-session)
Blocking items: 1 | Recommended: 3
Summary: Round 4 fixes held. All arithmetic recomputed (F1 13.3 unclamped, F2 288 / 2,294 / 5,873, F5 60 and +33 %, F6 0.09, AC-13 upkeep 14) and matches; registry entries agree with the GDD. One contradiction left from round 4: AC-FO-04 still names a "−20 % cooldown" Modifier, a key that does not exist (rule 5: a faster art is `art_speed_pct`).
Prior verdict resolved: Yes (round 4's two blockers resolved)
Findings:
- [BLOCKING] AC-FO-04: "Modifier node (−20 % cooldown on its art)" contradicts rule 5 (no cooldown key); the same criterion's oracle already uses +25 % `art_speed_pct`
- [RECOMMENDED] Acceptance Criteria: AC-FO-23 listed after AC-FO-26 (ordering only)
- [RECOMMENDED] Rule 6: one-hop-per-instant clause is vacuous while the feed floor keeps a fed art unready (only matters if Open Question 10 is answered yes)
- [RECOMMENDED] No Tuning Knobs section (advisory at standard)
Reviewed-Content-Hash: design/gdd/formations.md d316b422f83029239b78c53354a0469d117fc8d0
Reviewed-Content-Hash: design/registry/entities.yaml ff2fa65467c0a564336fe8d480ba09652509f8a1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/character-stats.md 77c25a612cda9fc53403073f77ff85acc2141728
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/effects.md 94a69453e243a295af6615f81aa495f12faa665f
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b

## Review — 2026-11-21 — Verdict: APPROVED (round 6)
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean, single-session)
Blocking items: 0 | Recommended: 3
Summary: Round 5's one blocker (AC-FO-04 "−20 % cooldown") is resolved: rule 5, F1, AC-FO-04 and AC-FO-18 all use `art_speed_pct`, and no "cooldown %" Modifier remains in the GDD or the registry. Arithmetic re-checked (F1 2.44 / 17.1 / 13.3 → 8, F2 288 / 2,294 / 5,873, F5 60 and +33 %, F6 0.09, AC-13 upkeep 14, AC-18 0.33 s floored 0.5 s) and matches; registry entries agree. No new contradiction found. Six standard sections present; Player Fantasy and Tuning Knobs are advisory at standard (Player Fantasy lives in the Overview). Tracked items (catalogue, starting values, protective triggers, Combat L4 +20, Advisor preset, back-links owed) stay in Open Questions and Dependencies.
Prior verdict resolved: Yes (round 5's blocker)
Findings:
- [RECOMMENDED] Acceptance Criteria: AC-FO-23 listed after AC-FO-26 and Open Question 10 before 9 (ordering only)
- [RECOMMENDED] Rule 6: one-hop-per-instant clause is vacuous under the feed floor (matters only if Open Question 10 is answered yes)
- [RECOMMENDED] No Tuning Knobs section (advisory at standard)
Reviewed-Content-Hash: design/gdd/formations.md 7336d2daa49da598a610bd1f1a096fa7d57180c0
Reviewed-Content-Hash: design/registry/entities.yaml ff2fa65467c0a564336fe8d480ba09652509f8a1
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/combat.md f01e96cdb6a8dcd47fd0bbb11cad19969fa53b0b
Reviewed-Content-Hash: design/gdd/combat-defence.md e24c4a755c34f485ea14030b8d8b4f8ca4118dca
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ccc57386f0a08f2e7d0d1e95d244f1ed869b793b
Reviewed-Content-Hash: design/gdd/cave-abode.md e2953a6b9fc454cf1207364ba36499bb59e043d7
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/sects.md 9b29ec95d08510ff358b0846d12e495de03634a9
Reviewed-Content-Hash: design/gdd/cong-phap.md f4c00b6a38f6319130123a35e1568338d5ba67c0
Reviewed-Content-Hash: design/gdd/character-stats.md 77c25a612cda9fc53403073f77ff85acc2141728
Reviewed-Content-Hash: design/gdd/modifiers.md 97129c6bb39712985feae09e865c38f64922899a
Reviewed-Content-Hash: design/gdd/effects.md 94a69453e243a295af6615f81aa495f12faa665f
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b
