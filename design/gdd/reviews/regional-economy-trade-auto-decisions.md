# Regional Economy & Trade: auto-decisions (unattended review loop)

## Round 1 — 2026-11-23 (design-review 12, full)
- FX-RE-B / Formula A example: R2 usage 8,000, infrastructure 5,833.6 (inf unchanged 0.7292), because usage cannot exceed output under Provinces F6; all downstream figures unchanged.
- Short-good local-price examples (L1, AC-RE-45/55/67): rebuilt as war-zone cases at access 0.60 (inf 1, war_v 1); chose to say plainly that a short province trades at P in peace over adding inbound load to F6 (a new mechanic that rewrites Provinces F6). Recomputed values: ore 1.33, 1.030, carried 1.117; famine 1.105 / 1.027 (the director's "about 1.15" used ε 0.2; ore ε is 0.4).
- Rule 7: rewritten to match Formula B and Provinces rule 11 (access share reaches the market, rest lost) over splitting B by `D_loc`.
- Trade 0 edge case: caps gate new orders only, standing buildings keep level (Provinces rule 8); no access floor. Added AC-RE-69.
- Wilderness: no `acc_v`, left out of B and I, place `price_index` = P (one line in rule 7, A, AC-RE-08b).
- Units: r = province in B, G, I, L1, fixtures and ACs by one units-note sentence plus targeted renames; AC-RE-44 re-sized to 273 provinces (141 settlement).
- Recommended applied: A's piecewise usage 0, Military-at-inf-1 note, mine stones left out of usage, rule 19 lag clause, AC-RE-08 split (08b), AC-RE-04 province and markup, ρ and basket in examples, FX-RE-PLAYER tie-break, Last Verified, rule 3 repetition, Open Questions 18 (owed in Provinces, Travel & Map, Sects) and 19.
- Not applied: `inf_v` in the L1 exponent (war pricing is the one remaining shortage signal); `D_loc` from actual fill (tuning note only); AC-RE-49 route-pair rule beyond the tie-break (harness run, OQ 19); splitting compound ACs 16, 45, 55; `short_own` cash note; the Military floor term.

## Round 2 — 2026-11-23 (design-review 13, full)
- Access one number per province: reworded rule 16 / L1 to "no net surplus in any class" and said a mixed glut/short province prices its short good above P (Victoria 3 behaviour); chose wording over the economy-designer's per-good access (a new mechanic near the rejected `min(prod, D_loc)` split), per the creative-director.
- Crafted classes: L1 raw only, crafted `p_loc` = P (smallest rule that removes the tiny-bal artifact); Formula G's `loc_band_fin` clamp note adjusted.
- Price breakdown (rule 17, UI Requirements, AC-RE-25): added the local factor `p_loc / P` with its reason.
- AC-RE-69: added safety term and numbers (infra 900, usage 1,800, Military 0: inf 0.5, acc 0.475; usage 2,250: inf 0.4, acc 0.38).
- `n[r,rl]`: named as the contract's `pop_cultivators` read per province; Travel & Map change stays tracked in Open Question 18.
- Recommended applied: acc rounding (0.4255, 0.7095 from the unrounded safe); rule 16 names the wearing end; AC-RE-49 reports the share of provinces under 0.82 P (the game-designer's check over the qa-lead's forced-access fixture); new AC-RE-70 (short province in peace, mixed province) and AC-RE-71 (rule 19 last-season `D_loc`); AC-RE-16 R2 price 0.809; AC-RE-45 `set_w`/fill; AC-RE-02 provinces wording; AC-RE-04 clause removed; ρ over settlement provinces; Formula G peace carry ~1.64×; FX-RE-B seat marked injected; stale "region" wording; Open Question 19 gains the oscillation check and a re-derive note for H/I estimates.
- Not applied: splitting AC-RE-45 and 08b (user accepts compound ACs, smallest fix); showing `bal_r` in the ledger (UI addition left to the UI session); the R2-only B-share and wilderness-S ACs; AC-RE-44 arithmetic note.

## Round 3 — 2026-11-23 (design-review 14, full)
- Finished-goods carry: marked G's 1.4x/2.5x paragraphs superseded by crafted p_loc = P; `loc_band_fin` kept as a dormant knob (user decision 2026-11-14), dropped the AC-RE-45 clause, AC-RE-49's finished-goods run asserts margin <= 0 inside one market (creative-director: no between-market run, it would collide with "untariffed").
- Mixed-province access: "may have access below 1 (when surplus usage exceeds infrastructure)"; AC-RE-70 given infra 4,000 (usage 6,000, inf 0.6667, acc 0.6444, ore p_loc 1.29).
- AC-RE-02 rewritten per class with S_X 20,000, S_R2 4,000, stock_X 5,000; price read after step (b), before step (e).
- Construction cost: one sentence and one Formula H table row (inside `burn_works`, not derived); forfeited payments need no booking (already burned); `burn_craft` added to AC-RE-07's identity.
- Recommended applied: bs in L1 D_r; famine wording (local price moves only in war); G real-spread 1.33x peace; rule 19(c) reads inf_v from the contract; A/B variable rows; war_v and start_access_min floor owed (Open Question 18); Cross-References rules; AC wording fixes (03, 21, 24, 25, 45, 55, 69 = 0.376, 08b, 05 line break); typo 0.55; stale access 0.8 marked a harness item; wilderness mine owner line; UI reason line at factor 1.0; OQ 19 gains the low-access spiral check.
- Not applied: split of B/I by D_loc (reverses round 1); forfeited money to commons pool; route-rotation and local-price-loop ACs (harness, OQ 19); war counted thrice; "prices elsewhere" for provinces (UI session); AC-RE-44 percentiles; compound AC splits.
- Also: `d_reach` knob row renamed key `econ_d_reach` (Sects has its own `d_reach`; a prefix is the smallest fix); wilderness mine owner line (worked = holder's `Inc_mine`, unworked = wild site); AC-RE-49 (c) now needs a 10 % fall; Open Question 18 gains the Provinces/Sects owed items (`start_access_min` floors `inf`, construction in `burn_works`, per-province `war_v`).

## Round 4 — 2026-11-23 (design-review 15, full)
- ρ vs Provinces F6: reworded rule 16 / L1 asymmetry (p_loc > P in peace also for a surplus province with bal_r < 1 and surplus load over infrastructure); kept F6 and L1 as they are (creative-director: F6 reading ρ is cross-GDD, dropping ρ reverses round 3); AC-RE-72 (ρ 1.5, p_loc 1.057); owed in Provinces note in Open Question 18.
- Player Fantasy reworded (game-designer option a): glut end = poor-road discount, famine end = market price, war and shocks lift one place; access model untouched.
- Formula H: lost-stash pool added to holders; F_mine row states the wild-site half split; player-funded building = transfer booked in player_net, cost burned once via spend_T, lord pays from own treasury; surplus budget stated (55–60k a season) and put into Open Question 19.
- ACs: 06/26 (8 raw band classes + crafted), 53 (Military mix 0.28: 1,400 / 900 / 1,080), 25 (unrounded product, ±1, fixture), 49 (1M / 2M runs, flat-world rule), 67 (untestable sentence cut), 69 and 71 Integration, 71 acc 0.9707, 70 herb p_loc 0.708, new AC-RE-72, AC-RE-73 (cargo loss on death, heirless burn).
- Recommended applied: Formula A output range (0.275 start), D_loc kind sum, Dp guard, G 2.4x labelled war only, rule 16 access-1 and main-loop sentence, Tuning Knobs pl_mem and inv_frac.
- Not applied: province-panel and own-effect ledger lines (UI session); AC-RE-44 machine detail; AC-RE-45/55/16/02 wording tweaks and the FX-RE-B 0.25 comment (small, left to next pass); extra ACs for Embargoed member exemption, Openness 0, other-class spoilage; AC splits.

## Round 5 — 2026-11-23 (design-review 16, lean)
- Imports in usage (user decision 2026-11-23, after round 4): rewrote every "short province trades at P in peace / shortage shows locally only in war" sentence (Player Fantasy, rules 16, 20, 22, edge case famine, `sub_floor` knob, L1 asymmetry, G output range, AC-RE-67, AC-RE-70, Open Question 19); this reverses round 1's choice to say a short province trades at P in peace, as the user decided.
- Formula A `inf_v` row says usage counts goods brought in; no formula change (L1 already raises a short, poorly connected province's price through `bal^(−ε(1−acc))`).
- New peace examples: ore-short province, usage 2,500, infrastructure 1,250, Military 0: acc 0.475, p_loc 1.456; AC-RE-67/70 herb case usage 215, infrastructure 107.5: acc 0.475, p_loc 1.140; mixed province in AC-RE-70 now usage 8,500, infrastructure 5,100: acc 0.576, ore 1.355, herb 0.663 (usage includes the ore shortfall).
- Formula G: the 1.64x and 1.33x peace figures withdrawn; peace carry between a glut province and a short, poorly connected one is about 1.8x; 2.4x is the band-edge upper bound.
- Open Question 18: owed-in-Provinces note rewritten (F6 already amended); Open Question 19 gains a harness report of short provinces under access 0.5 and the shortest decile's peace price.
- Header Status, Last Verified, systems-index row set to In Review.
- Not applied: AC splits; re-measuring access (Provinces' script, harness); FX-RE-B R2's other-class balance note.

## Round 6 — 2026-11-23 (design-review 17, lean)
- Verdict APPROVED, 0 blocking: round 5's rewrites hold and all amendment examples recompute; per the run rule no other edit was made (systems-index row set to Approved).
- Not applied (recommended, left for any later pass): Cross-References Provinces row add rules 3 and 16; knob `λ_war` wording "region" to "province"; Dependencies Provinces row status text.
