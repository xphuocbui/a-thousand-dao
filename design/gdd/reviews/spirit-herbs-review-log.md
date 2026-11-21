# Review Log: Spirit Herbs & Spirit Fields (Linh Thảo & Linh Điền)

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, godot-specialist, creative-director (senior)
Blocking items: 8 | Recommended: 12
Summary: No new mechanic is needed; every blocker is a contradiction, a wrong number or an ambiguous rule that can be fixed by rewording. Plots are fractional, Frozen is only half defined, mastery xp trigger contradicts itself, the seed market and sale payer are wrong or missing, two stated checks are false, F1's fit range and the zero-rate case are undefined, the season tick order is missing, AC-07 mixes a factor with years.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas F2 / Rule 3: field_plots is a float, only part of the sum is floored; floor the whole sum (Character Stats G back-link)
- [BLOCKING] States / Edge Cases / AC-03: Frozen only defined for a dormant field; make it derived (plot index >= plots holding a herb), Frozen -> Locked on harvest, exit when plots rise
- [BLOCKING] States / Rule 9 / F4: "harvest xp" vs growth xp; every Planted non-Frozen herb earns xp on real Δage, Mature included
- [BLOCKING] Rules 5, 8, F3: seed market undefined; sale payer wrong (commons pool, balance-capped, not Formula H purse); tag old home market on move
- [BLOCKING] Boundary checks / F4 example: "Dominant purchase: none" is false inside the realm gate; "40-75 years" mastery 9 is wrong (~490 yrs at 3 plots, ~68 at 12 plots)
- [BLOCKING] F1: fit_growth range 0.24-1.2 contradicts planted herbs growing at 0-1.2; seasons-to-target undefined at rate 0
- [BLOCKING] Rule 6: season tick order missing (modifiers/dormancy, then grow, then xp; actions between ticks)
- [BLOCKING] AC-07: 0.12 is a factor, not years (0.03 years a season)
- [RECOMMENDED] AC-04/10/14/17/18/19 wording; ACs for Frozen->Locked, rounding, tick order, mature xp
- [RECOMMENDED] growth_rate vs h naming; F3 max(0,..) and stale "twelve plots"; mastery carries across a move
- [RECOMMENDED] Player Fantasy says "tends" and plants a slow herb in season 1 past the seed gate
- [RECOMMENDED] Tuning Knobs section absent (advisory at standard)
- [RECOMMENDED] Implementation: built grow() ages all Planted herbs, must skip Frozen; move-home harvest needs a path bypassing must-be-home; mastery storage key
- [NOT APPLIED] Transplant-past-seed-gate, hold-is-dominant, plots-replace-waiting: standing decisions / intended (creative-director disagreed with specialists)
Reviewed-Content-Hash: design/gdd/spirit-herbs.md 0ce72141d5327914f755c55451f82cc1c8c4e77d
Reviewed-Content-Hash: design/registry/entities.yaml 61c5990c59af7babee82a2b8d7e58b2fad8b7df6
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/character-stats.md 78520f32564589b434d0eeac4815ad53684ea63d
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 8fa82e308700d1c33a681acb39b8aab2aa4870f9
Reviewed-Content-Hash: design/gdd/cave-abode.md 686108dc48b21102dd2d563e70cb4801be6cd773
Reviewed-Content-Hash: design/gdd/trade-goods.md edcd2bd45e5706324fecd4b6aa18e23f2f36f56e
Reviewed-Content-Hash: design/gdd/formations.md ce010b074bbcfd5d90ace66a2db8c34ad268857f

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 6 | Recommended: 12
Summary: Round 1's eight blockers are resolved. Round 2 found text-level contradictions only, no new mechanic needed: a wrong floor example (8.5 -> 8), a double floor between rule 4 and F2, rule 11's dormancy wording against the derived Frozen state, an ambiguous origin_market tag on transplant, stale "back-link owed" cells after the back-links were added, and capability #14 / #12 mismatches in AC-SH-05, AC-SH-01 and AC-SH-17.
Prior verdict resolved: Yes (round 1's 8 blockers fixed)
Findings:
- [BLOCKING] Formulas F2 / AC-SH-02: field_plots 0.5 gives 3+2+0.5+3 = 8.5, floor 8, not 9
- [BLOCKING] Rule 4 vs F2: field work floored per modifier and again on the whole sum; keep the one floor
- [BLOCKING] Rule 11: "herbs in its plots stop ageing" contradicts derived Frozen (index >= plots)
- [BLOCKING] Rules 5, 8: origin_market on transplant and re-harvest undefined; tag only if empty
- [BLOCKING] Dependencies / Cross-References: "back-link owed" / "note owed" cells stale after 2026-11-21 back-links
- [BLOCKING] Rule 10 / AC-SH-05 / AC-SH-01 / AC-SH-17: capability #14 actions vs planting; ACs need "without capability #12"
- [RECOMMENDED] Boundary check "Faucet: none" reword (no mint; value moves from the pool to the grower)
- [RECOMMENDED] Rule 6 tick-order AC; F1 example 26 seasons rounded up; F4 ~469 years; h range floor; F3 50 is catalogue-bound
- [RECOMMENDED] Free -> Locked in States; seed gate uses the buyer's realm; fantasy "tends"; AC wording passes; Tuning Knobs absent (advisory)
Reviewed-Content-Hash: design/gdd/spirit-herbs.md c0f093769bea804632645f4a890566cfdd5b8f91
Reviewed-Content-Hash: design/registry/entities.yaml 61c5990c59af7babee82a2b8d7e58b2fad8b7df6
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/character-stats.md 78520f32564589b434d0eeac4815ad53684ea63d
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 8fa82e308700d1c33a681acb39b8aab2aa4870f9
Reviewed-Content-Hash: design/gdd/cave-abode.md 686108dc48b21102dd2d563e70cb4801be6cd773
Reviewed-Content-Hash: design/gdd/trade-goods.md edcd2bd45e5706324fecd4b6aa18e23f2f36f56e
Reviewed-Content-Hash: design/gdd/formations.md ce010b074bbcfd5d90ace66a2db8c34ad268857f

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 4 | Recommended: 14
Summary: Round 2's six blockers are resolved; every example and AC number recomputes correctly except AC-SH-06. The four blockers are one-sentence text fixes: no-qi ground has no planting rule, rule 4 contradicts Open Question 8 on upkeep, AC-SH-06 says 25 seasons where F1 rounds up to 26, and a dead owner's herbs may carry no origin_market tag.
Prior verdict resolved: Yes (round 2's 6 blockers fixed)
Findings:
- [BLOCKING] Edge Cases / Rule 5: no-qi ground (fit_growth x1) never says whether plant_floor applies (as built: always plantable, no fit word); balance note that x1 beats real fit below ~0.83 goes to the user
- [BLOCKING] Rule 4 vs Open Question 8: rule 4 says upkeep follows Cave Abode's work rules, OQ8 says the field has none
- [BLOCKING] AC-SH-06: "25 (±1)" contradicts F1's 26 (25.4 rounded up)
- [BLOCKING] Edge Cases (death): origin_market tag at death undefined; tag as at harvest
- [RECOMMENDED] AC-SH-02 clamp case needs base_plots overridden to 0; AC-SH-03 Locked->Free and refused planting into Locked/Frozen; AC for rule 6 tick order; AC-SH-04 split and wording; AC-SH-01 home has a market; AC-SH-09 tag; AC-SH-18, AC-SH-19 wording; missing ACs (no free plot, no-qi, mastery across a move)
- [RECOMMENDED] Rule 5 transplant of a Frozen herb must pass plant_floor; capability #14 seed purchase sentence; Interactions sale-payout row; faucet line seed-price wording; 36 years is a best case; F1/F3 output maxima hold at sum+ ~150; variable table rows; float floor; mastery xp farming note
Reviewed-Content-Hash: design/gdd/spirit-herbs.md 310b3eaea60ac2916fc3d912d62f639083b5b696
Reviewed-Content-Hash: design/registry/entities.yaml e5ea4ccfe8e23585764cf37d3f10c4f8a9ba25ed
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/character-stats.md 78520f32564589b434d0eeac4815ad53684ea63d
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 8fa82e308700d1c33a681acb39b8aab2aa4870f9
Reviewed-Content-Hash: design/gdd/cave-abode.md 686108dc48b21102dd2d563e70cb4801be6cd773
Reviewed-Content-Hash: design/gdd/trade-goods.md edcd2bd45e5706324fecd4b6aa18e23f2f36f56e
Reviewed-Content-Hash: design/gdd/formations.md ce010b074bbcfd5d90ace66a2db8c34ad268857f

## Review — 2026-11-21 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 2 | Recommended: 16
Summary: Round 3's four blockers are resolved and every number recomputes. Two one-line blockers remain: Core Rules says 0.8 per purity where F1 uses 0.008 (0.8 %), and AC-SH-03 states 9 and 6 plots without the Thổ 50 and field_plots 1 inputs that produce them. Forced harvest on move and no-qi x1 are standing decisions, not findings.
Prior verdict resolved: Yes (round 3's 4 blockers fixed)
Findings:
- [BLOCKING] Core Rules intro: "0.8 per purity" is 100x F1's 0.008 (0.8 %)
- [BLOCKING] AC-SH-03 / AC-SH-16: 9 and 6 plots need Thổ 50 and field_plots 1 stated in the GIVEN
- [RECOMMENDED] AC-SH-14 typed Logic but asserts a screen; AC-18 garbled; AC-16 totals; AC-02 stat vs field level; AC-13 query; ACs for tick order, Locked/Frozen refusal, no free plot, no-qi, death, mastery across a move
- [RECOMMENDED] F1/F3 max(0,..) guards, result rows in variable tables, F3 catalogue-bound range and stone-sale-only, F4 12 plots an illustration, rule 4 lost grade = dormant, States Growing/Mature to Frozen
- [RECOMMENDED] Dominance claim scoped to harvest at maturity; pool-shopping by sale place; pool sink and mastery pacing to harness
- [RECOMMENDED] Feel: ready notice, dormancy and move warnings; tending is empty
Reviewed-Content-Hash: design/gdd/spirit-herbs.md 51360064ea14198c52bd4775899b5a207a6f7831
Reviewed-Content-Hash: design/registry/entities.yaml e5ea4ccfe8e23585764cf37d3f10c4f8a9ba25ed
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/character-stats.md 78520f32564589b434d0eeac4815ad53684ea63d
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 8fa82e308700d1c33a681acb39b8aab2aa4870f9
Reviewed-Content-Hash: design/gdd/cave-abode.md 686108dc48b21102dd2d563e70cb4801be6cd773
Reviewed-Content-Hash: design/gdd/trade-goods.md edcd2bd45e5706324fecd4b6aa18e23f2f36f56e
Reviewed-Content-Hash: design/gdd/formations.md ce010b074bbcfd5d90ace66a2db8c34ad268857f

## Review — 2026-11-21 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L
Specialists: none (lean, single-session)
Blocking items: 0 | Recommended: 4
Summary: Round 4's two blockers are resolved. Every example and AC number recomputes (F1 26 seasons, F2 9/8/19, F3 50, F4 4,500 xp and +15.3 hgp, AC-SH-03 9 to 6 plots). No contradiction or unbuildable rule remains; the open items are tracked (OQ 1 capability #12, OQ 3 floor back-link and starting values, OQ 4 catalogue, OQ 5-8).
Prior verdict resolved: Yes (round 4's 2 blockers fixed)
Findings:
- [RECOMMENDED] Rule 5: says plant_floor always applies; the no-qi exception sits only in Edge Cases (add "except no-qi ground")
- [RECOMMENDED] Rule 5: a transplanted Frozen herb must still pass plant_floor (unstated)
- [RECOMMENDED] Character Stats Formulas G floors only the Thổ term and types field_plots as an integer; this GDD floors the whole sum (OQ 3 back-link owed, tracked)
- [RECOMMENDED] Missing ACs from earlier rounds (tick order, Locked/Frozen refusal, no free plot, no-qi, death, mastery across a move); Tuning Knobs section advisory at standard
Reviewed-Content-Hash: design/gdd/spirit-herbs.md ddea8effa00923d0ce7c376a69341a79daac9629
Reviewed-Content-Hash: design/registry/entities.yaml e5ea4ccfe8e23585764cf37d3f10c4f8a9ba25ed
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/character-stats.md 78520f32564589b434d0eeac4815ad53684ea63d
Reviewed-Content-Hash: design/gdd/travel-map.md 8816f859bd959bd6df8c88ac098569a8070c2266
Reviewed-Content-Hash: design/gdd/item-database.md caf253aa4579f0507ed920045ac9c622d6d0193b
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 8fa82e308700d1c33a681acb39b8aab2aa4870f9
Reviewed-Content-Hash: design/gdd/cave-abode.md 4248441103ff889cd7cefc2e381c1214ffaa3ad4
Reviewed-Content-Hash: design/gdd/trade-goods.md edcd2bd45e5706324fecd4b6aa18e23f2f36f56e
Reviewed-Content-Hash: design/gdd/formations.md ce010b074bbcfd5d90ace66a2db8c34ad268857f
