# Provinces (#48) — Review Log

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 6 | Recommended: 12
Summary: Structure and standing decisions hold; all blockers are local. Rule 11 and F6 disagree on usage (price in usage makes a loop and breaks the start floor); F4 double-counts province buildings already in Travel & Map Formula H's G_f; F2 multi-hop wilderness routing, F3 branches (fed, safe, tide, war base) and the building lifecycle (ruin_seasons, Cancelled, who pays) are undefined. Revised in the same unattended run.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Rule 11 / F6: usage uses base value in the rule but market price P[m,k] in the formula; usage_0 undefined.
- [BLOCKING] F4 / F1: province buildings counted twice (out[b] and Travel & Map G_f inside out_H).
- [BLOCKING] F2: wild_hops multi-hop routing undefined (cycles, partial shares).
- [BLOCKING] F3: no base P' for war-only branch, no tide term, fed/safe/war-touched undefined, C=0 guard, "range to C" wording.
- [BLOCKING] Rule 8 / States: ruin_seasons has no value, no Cancelled state, payer and cost timing unstated.
- [BLOCKING] F4 outpost staff: ambiguous when several provinces gather one wilderness.
- [RECOMMENDED] Edge Cases line "settlement founded later" contradicts the fixed world.
- [RECOMMENDED] F5 slots must be max(formula, buildings standing); AC-PV-19 needs min(1, ...).
- [RECOMMENDED] F3 "about 1 %" is 0.75 %; variable tables lack P, P0, prod_wild, level_b.
- [RECOMMENDED] strained_access and province_full_fit undefined (latter lives in design/ux/hud.md).
- [RECOMMENDED] Seat kind for a province with several settlements; AC-PV-07 ids depend on OQ 3; AC-PV-21/22/23 wording; rules without ACs.
- [RECOMMENDED, not applied] pooled staff, upkeep priority and grace, one building per kind, slot contention, imports vs access, building-cost destination, carry arbitrage (new rules: balance pass / user).
Reviewed-Content-Hash: design/gdd/provinces.md 370e1ea1a4b50ffb41d3e0c06db9b6efebc3c4ec
Reviewed-Content-Hash: design/registry/entities.yaml 30336d428ef6ef8f70750e88edb0a13d56cc4a18
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 2bee9c3562f57f51a9be9582500c38b0f4404b0c
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 9 | Recommended: 11
Summary: Round 1 fixes hold and none is reversed. Remaining blockers are local: F4's prod_wild drops multi-hop wilderness output and wilderness modifiers (F1/F2/AC-13/AC-22 disagree with F4), the outpost staff at d>=2 is 0, AC-PV-15's war case contradicts F3, rule 9 has no cap track for granary and great projects, AC-PV-22 names a sink RET does not have, cover_st and D_loc units have no stated source, and the States table contradicts the player-funded edge case. Revised in the same unattended run.
Prior verdict resolved: Yes (round 1 blockers B1-B6 resolved; new items found)
Findings:
- [BLOCKING] F4/F2/F1: prod_wild is own output only, so output from wilderness at d>=2 never reaches a settlement.
- [BLOCKING] F4 / Edge Cases: a blight on a wilderness province has no term in F4; wilderness must add 0 to region sums beyond its gatherers (AC-PV-21).
- [BLOCKING] F4: outpost staff at d>=2 resolves to a wilderness province with P=0.
- [BLOCKING] AC-PV-15: war case expects 10.05*0.95, F3 gives 10*0.95 = 9.5.
- [BLOCKING] Rule 9: granary and great-project stages have no track to cap them.
- [BLOCKING] AC-PV-22: "kept in local stock" sink does not exist in Regional Economy & Trade; (1-acc) share is lost in carriage.
- [BLOCKING] F3: cover_st has no stated source.
- [BLOCKING] F6: usage subtracts D_loc (base value) from prod (quantity).
- [BLOCKING] States table: Cancelled on holder change contradicts the player-funded-building edge case.
- [RECOMMENDED] F3 clamp wording (falls by f_fam a year above C) and range line.
- [RECOMMENDED] Rule 4: main and secondary fixed at generation; F1 secondaries only when main value > 0.
- [RECOMMENDED] Stale Dependencies row (last season's market price).
- [RECOMMENDED] AC-PV-02, 05, 07, 14, 17, 19, 23 rewrites; new ACs for rule 9 caps and rule 11 shipped share.
- [RECOMMENDED, not applied] "pavilions" in rule 9 (user's mapping; open question), access coupling to cover_st (OQ 8), rule 12 stats with no formula term, P_set_now.
Reviewed-Content-Hash: design/gdd/provinces.md 7b0f27bd8e815078987feb932c103ca41275b590
Reviewed-Content-Hash: design/registry/entities.yaml 52cea6ba26cc6ce338251aaa689a38d5b58a42af
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 2bee9c3562f57f51a9be9582500c38b0f4404b0c
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 8 | Recommended: about 20
Summary: Rounds 1-2 fixes hold. Blockers are local: prod_wild can go negative, AC-PV-04 gives wilderness an access and price, the Overview promises famine from poor access (F3 reads market cover), F3's time windows disagree with Dependencies, an Unpaid building has no formula term, rule 11 and RET B disagree on what ships (and two values are both called access), AC-PV-22 double counts consumption and omits h_f, shockS and Imp/Exp, AC-PV-14's fixture is impossible (and AC-PV-07 is garbled). Revised in the same unattended run.
Prior verdict resolved: Yes (round 2 blockers resolved; new items found)
Findings:
- [BLOCKING] F4: prod_wild has no clamp on 1 + sum(inc); can go negative.
- [BLOCKING] AC-PV-04/25: wilderness required to have infrastructure, access, local price.
- [BLOCKING] Overview: "famine felt first" contradicts F3 market-wide cover_st.
- [BLOCKING] F3: safe/cover_st windows ("this year", "last year") vs Dependencies/OQ 9 ("last season").
- [BLOCKING] F4/F6/F3: Unpaid building has no formula term (level_b).
- [BLOCKING] Rule 11 / F6: D_loc vs RET B shipped value; two values both called access.
- [BLOCKING] AC-PV-22 (and 29): local consumption double counted; h_f, shockS, Imp/Exp omitted.
- [BLOCKING] AC-PV-14 impossible fixture; AC-PV-07 garbled text.
- [RECOMMENDED] F1 none when max value 0, explicit wilderness recursion, k = Item DB class; F3 range and percent-of-C wording; fed when neither class trades; staff_lvl and famine_cover > 0; infra[b] per level; outpost staff 0 if none reached; F5 standing and range; Planned trigger; AC-09, 12, 15, 21, 28 rewrites; new ACs for clamp, Unpaid, landing, river_cap; OQ 8 and OQ 10 additions.
- [RECOMMENDED, not applied] famine-with-low-access AC, pooled staff, stuck-below-strained metric, cap on sum cap_b (balance pass); AC-23/24/26/27 rewrites; AC-08 split.
Reviewed-Content-Hash: design/gdd/provinces.md f9188a2ada02adf600798aec6883a19a941857ae
Reviewed-Content-Hash: design/registry/entities.yaml 52cea6ba26cc6ce338251aaa689a38d5b58a42af
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 2bee9c3562f57f51a9be9582500c38b0f4404b0c
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: full · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 3 | Recommended: about 16
Summary: Rounds 1-3 fixes hold. Three local blockers: an upgrade of an Active building zeroes level_b (no upgrade path), Provinces' Unpaid/Ruined states contradict Travel & Map Formula J's fade for the same shared works, and the workshop's crafted goods have no Item Database class (double count with Trade Goods). Revised in the same unattended run.
Prior verdict resolved: Yes (round 3 blockers resolved; new items found)
Findings:
- [BLOCKING] F4/States: an upgrade of an Active building sets level_b to 0 for the build (infra, cap_b, out lost).
- [BLOCKING] Rule 8/States: Unpaid (effect stops, Ruined after 3) vs Travel & Map Formula J / AC-TM-106 (a level lost every 2nd unpaid season).
- [BLOCKING] Rule 8/F4: workshop "crafted goods" has no raw class; out[b] would double count Trade Goods' crafting.
- [RECOMMENDED] Spirit-stone veins outside prod/usage/access (RET I reads Inc_mine); AC-PV-19 same-tick wording; AC-PV-22 tautology; AC-PV-05 off-by-one; AC-PV-07 tolerance; fixture line for (guess) knobs; AC-PV-14 numbers; AC-PV-16 permanent fixture; AC-PV-09 read time; rule 7 outpost kind names; registry province_market_access expression; feedback loop downward note; rule 14 carry pointer; start floor holds at generation before modifiers; caps gate orders only.
- [RECOMMENDED, not applied] pooled staff, upkeep on holder change, local lord caps, cost destination, construction materials, cover_st min vs mean, G_f lag, F3 clamp under mild famine, AC splits and extra boundary cases (OQ 2/8/10 or balance pass).
Reviewed-Content-Hash: design/gdd/provinces.md 8d378963525f6d9cb216d57da52dec7a40eb006a
Reviewed-Content-Hash: design/registry/entities.yaml 52cea6ba26cc6ce338251aaa689a38d5b58a42af
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 2bee9c3562f57f51a9be9582500c38b0f4404b0c
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c

## Review — 2026-11-23 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: none (lean, single session)
Blocking items: 0 | Recommended: 4
Summary: Round 5. Full read of the revised text; arithmetic of every worked example and AC fixture re-checked (F3, F4, F5, F6, AC-PV-14 to 19); dependency files exist; registry valid. The round 4 fixes (upgrade keeps level_b, Unpaid/Ruined owned here, workshop outside prod) hold and add no contradiction. No blocker found.
Prior verdict resolved: Yes (round 4 blockers resolved)
Findings:
- [RECOMMENDED] Registry province_slots: output_range [1, 9] and expression omit F5's "no cap" and the max with buildings standing.
- [RECOMMENDED] Edge Cases / AC-PV-21: "until RET is revised" wording is stale beside the Amendments list (RET Formulas C and L1 still pending, OQ 9).
- [RECOMMENDED] ruin_seasons and strained_access are defined inline, not in a variable table.
- [RECOMMENDED] AC-PV-09 "seasons left" read-time wording is dense; split into two lines in the balance pass.
Reviewed-Content-Hash: design/gdd/provinces.md d8bab6bcd392d4e0b1c06eafa2391db86bc56e30
Reviewed-Content-Hash: design/registry/entities.yaml 7fb27b3136d2605356946a5868dc9f8a4d9ebe5f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 2bee9c3562f57f51a9be9582500c38b0f4404b0c
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c

## Review — 2026-11-23 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: none (lean, single session)
Blocking items: 1 | Recommended: 5
Summary: Round 6, after the user's F6 amendment (usage counts goods brought in). Rule 11, F6, Overview and AC-PV-18b already carry it. One blocker: F6 sums over "k" without saying which classes, so a crafted-class demand (Provinces make no crafted goods) would count as import load for every province. Stale text: the "worst case" seed 7 measurement predates imports, and the "until RET is revised" Edge Case. Revised in the same unattended run.
Prior verdict resolved: Yes (round 5 approved with 0 blockers; this round reviews the amendment)
Findings:
- [BLOCKING] F6: usage sums over k with no class set; crafted demand D_loc would be counted as imports (RET L1 and D_loc apply to raw classes only).
- [RECOMMENDED] F6 Measured: "usage = whole production value, the worst case" is no longer a worst case once imports count; seed 7 numbers need a re-measure (OQ 1).
- [RECOMMENDED] Edge Cases: no case for a poorly connected province short of a good (imports, price above P in peace).
- [RECOMMENDED] Edge Cases: "Until Regional Economy & Trade is revised" is stale beside the Amendments list.
- [RECOMMENDED] OQ 9: RET text still says a short province trades at P in peace (rule 16 note, example line, famine edge case); owed in RET.
- [RECOMMENDED] Registry province_slots: output_range and expression omit "no cap" and max with buildings standing; header Last Updated stale.
Reviewed-Content-Hash: design/gdd/provinces.md 820236103df1fc70cf2e6c629d896dd2e5860eea
Reviewed-Content-Hash: design/registry/entities.yaml 6362e6e0e63016d0b49cb1624811b06b9ae4b1fd
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 59b7692b86935d63ccd4eda96d4f0b7997aca937
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c

## Review — 2026-11-23 — Verdict: APPROVED
Review mode: lean · Workflow: standard
Scope signal: L (rough; producer to verify)
Specialists: none (lean, single session)
Blocking items: 0 | Recommended: 3
Summary: Round 7. Full read of the GDD after the round 6 revision. The F6 usage class set (raw classes) holds; imports in usage read the same in rule 11, F6, Overview, the short-province Edge Case and AC-PV-18b; arithmetic of F3, F4, F5, F6 examples and AC fixtures re-checked. Dependency files all exist; registry validates. No blocker.
Prior verdict resolved: Yes (round 6 blocker resolved)
Findings:
- [RECOMMENDED] Interactions table: the Regional Economy & Trade row lists only the local price as input; Dependencies also names D_loc and the staple cover.
- [RECOMMENDED] Rule 10 / AC-PV-07: the start floor holds at generation (D_loc 0); once imports count, a province can sit below 0.5 after the first economy tick (OQ 1 re-measure) — say so in rule 10.
- [RECOMMENDED] Registry province_market_access lists variable P_market, which no longer appears in F6.
Reviewed-Content-Hash: design/gdd/provinces.md 9ac50486025115a27a3fbe5d19f8d71a3269fa51
Reviewed-Content-Hash: design/registry/entities.yaml ca55c0128329ac74148b7230d2e87822c420af09
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 59b7692b86935d63ccd4eda96d4f0b7997aca937
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/living-world-tick.md b8421b482da0502827d0651f9cb9e7d51899752c
