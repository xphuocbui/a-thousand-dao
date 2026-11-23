# Review Log: Regional Economy & Trade

## Review — 2026-11-14 — Verdict: NEEDS REVISION
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 8
Summary: Thorough and numerically careful; worked examples reproduce. Three narrow blockers (intra-market price spread, missing bmix in Formula C, undefined flow order). All three were resolved in-session the same day; the revised GDD awaits a re-review.
Prior verdict resolved: First review
Findings:
- [BLOCKING] Formulas G/L1, rule 16: cross-region carrying inside one market is untariffed. RESOLVED by user decision: kept as an intended reward for travel time, documented, bounded, AC-RE-49 added (profit vs realm pay, PROPOSAL band).
- [BLOCKING] Formula C: per-class demand omitted bmix[k]. RESOLVED: bmix added, d_scale range widened to ~0.5–3, fixture d_scale[herb] 2.2 (all example numbers unchanged).
- [BLOCKING] Formula F: S_pre vs Imp/Exp circularity and link/class order undefined. RESOLVED: S_pre, ascending (id_A,id_B) order, herb/ore/beast/special, avail depletion; AC-RE-50 added.
- [RECOMMENDED] Formula F: Q_close omits the 1/c factor. RESOLVED 2026-11-14: c floored at c_short 0.5; example/AC-RE-18 now Q 859.3, tariff 134.1.
- [RECOMMENDED] Rule 2 vs Edge Cases timing. RESOLVED (same season's tick).
- [RECOMMENDED] Formula I: 142k in-and-out does not reconcile (135.8k out, ~85–89k in from this system). RESOLVED: the ~50–55k from Sects F3 market tax, fees and tribute named.
- [RECOMMENDED] Formulas C/D: 250k supply anchor not reconciled with demand; add a calibration-feasibility check. RESOLVED: rough world estimate (mean d_scale ~1.2–2.1) and AC-RE-51.
- [RECOMMENDED] Travel & Map status/Open Question 1, Item Database origin_market, Realms stone/provision handoffs not applied. RESOLVED as notes: Travel & Map status and Open Question 1 answered; Item DB Open Question 25; Realms Open Question 24 (formula change waits on the Realms revision).
- [RECOMMENDED] Acceptance Criteria: missing type tags on AC-RE-36..43, ordering, PROPOSAL thresholds. RESOLVED: tags added, sections regrouped, AC-RE-40 windows defined; PROPOSAL thresholds remain by design.
- [RECOMMENDED] Rule 11 "Formula H" ambiguous with this GDD's Formula H. RESOLVED: qualified as Travel & Map Formula H.
- [RECOMMENDED] Player Fantasy and Tuning Knobs sections (advisory at standard). RESOLVED: both sections added.
Reviewed-Content-Hash: design/registry/entities.yaml d9a8f57cf6626230081b6c247368dd4942fafd94
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md 832eaa5c9220352d07981a78efc16d71ab83aff3
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 79988e97bb4b0b0226e0d4fc9f2a14e20464c47c
Reviewed-Content-Hash: design/gdd/canh-gioi.md 1b5876d891267e47c57e810b5d34d44bcf2aa15b
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (second review; revisions applied the same day, awaiting re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 7
Summary: Prior 3 blockers confirmed resolved. Three new narrow blockers: basket funding capped by s_spend contradicted rules 21-22, per-region demand D_r was undefined, and the Formula B/D example mis-added. All three, plus Recommended 1-4, were revised in-session the same day.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Formulas L2/J vs rules 21-22: basket capped at 0.3 of excess, so stipend-only NPCs fill ~30%. RESOLVED: basket paid from the whole excess over reserve; s_spend governs stones only; J example now 525 stones / 26.25 tu vi; AC-RE-31 extended.
- [BLOCKING] Formula L1: D_r undefined. RESOLVED: D_r given from C's population and works terms (d_scale, bmix, last season's fill), bal_r normalised by market ratio rho; AC-RE-45 extended.
- [BLOCKING] Formulas B/D, AC-RE-10/12: S 15,662.4 and stock' 3,017.1 wrong. RESOLVED: S 15,663.2, stock' 3,017.8 (D, P', D_f unchanged).
- [RECOMMENDED] Formula C: fill timing. RESOLVED: previous season's fill.
- [RECOMMENDED] Formula F/H: inter-market payment and tau undefined. RESOLVED: importing pool pays exporting pool P_A*Q; tau is a threshold only.
- [RECOMMENDED] Formula C: meaning of d_scale. RESOLVED: unsimulated mortal/crafting/wastage demand, goods only, no payer.
- [RECOMMENDED] Formula G/AC-RE-49: finished-goods carry about 2.5x. RESOLVED as PROPOSAL (AC-RE-49 runs raw and finished; charm/standing limit or lower loc_band for finished goods, economy-designer to choose).
- [RECOMMENDED] Rule 22 wording vs J: resolved by the basket fix.
- [RECOMMENDED] AC-RE-25/26/40/44/49 provisional or PROPOSAL thresholds: remain by design.
- [RECOMMENDED] Seven dependencies with no GDD (Market, Time & Turn, Living World Tick, Event Engine, LLM GM, Game UI, Balance Harness): note #43 when each is written.
Reviewed-Content-Hash: design/registry/entities.yaml 4e3aa15522ae3f2341b11d6717256ac3d9f23a0a
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (third review; blocker and Recommended 1-2 revised the same day, awaiting re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 7 (4 resolved)
Summary: Second-review blockers confirmed resolved; worked examples (A-F, AC-RE-13 price runs) recompute. One bookkeeping blocker: three registry entries still carried pre-revision formulas. Fixed in-session with Recommended 1 and 2; items 3 and 4 are pending user decisions.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Registry: provision_basket (0.3 cap on basket), stone_cultivation (basket outside the max), local_price (no rho, no D_r) contradicted the GDD. RESOLVED: entries updated.
- [RECOMMENDED] Formula E: price_index = P' contradicted rule 11 / L1. RESOLVED: now p_loc (P' at access 1).
- [RECOMMENDED] FX-RE-SECT: collect not pinned; AC-RE-30 reproduces only at 0.323. RESOLVED: pinned.
- [RECOMMENDED] Formula G: undecided PROPOSAL for finished-goods carry (~2.5x) and AC-RE-49 band. RESOLVED same day by user decision (see Summary).
- [RECOMMENDED] Loose cultivators (~1,700): no stipend, starting purse and income unspecified, so basket fill and stone burn are unclear. RESOLVED same day by user decision (see Summary).
- [RECOMMENDED] Seven dependencies with no GDD (Market, Time & Turn, Living World Tick, Event Engine, LLM GM, Game UI, Balance Harness): carried.
- [RECOMMENDED] PROPOSAL/provisional ACs (25, 26, 40, 44, 49, FX-RE-WORLD burn-in): remain by design.
- [RECOMMENDED] Handoffs pending: Realms stone term and (1+prov), Event Engine loot draw, Item DB origin_market: carried.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 55570dcc101169814bfeeccf1a22f9abb696e9b1
Reviewed-Content-Hash: design/registry/entities.yaml cdec21632e19134bf3463056cdb0e9a43e2b5ce9
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (fourth review; blocker and recommended 1-6 revised the same day, awaiting re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 7 (5 resolved)
Summary: Worked examples all recompute. Registry entries market_price and shop_price still carried pre-revision formulas (price_index = P', P not p_loc, no loc_band_fin); fixed in-session with the restock, player-stone, P_eff-class and acceptance-criteria clarifications.
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Registry: market_price (price_index = P', stray P*) and shop_price (P, no loc_band_fin) contradicted Formulas E and G. RESOLVED: entries updated.
- [RECOMMENDED] Rule 19(g)/Edge Cases/AC-RE-35: restock vs pooled stock undefined. RESOLVED by user decision: shelves are a view, stock' unchanged.
- [RECOMMENDED] Formula J: player stone cultivation unspecified. RESOLVED by user decision: player chooses, same spt and absorb_cap, outside M.
- [RECOMMENDED] AC-RE-49: cross-market carry untested. RESOLVED by user decision: harness extended to linked and unlinked market pairs.
- [RECOMMENDED] Formula G: finished goods' P_eff class. RESOLVED: main input's class.
- [RECOMMENDED] AC-RE-18 gap rounding (-0.0284) and AC-RE-47 fill timing. RESOLVED.
- [RECOMMENDED] Seven dependencies with no GDD (Market, Time & Turn, Living World Tick, Event Engine, LLM GM, Game UI, Balance Harness); pending Realms, Event Engine, Item DB handoffs: carried.
- [RECOMMENDED] PROPOSAL/provisional ACs (25, 26, 40, 44, 49, FX-RE-WORLD burn-in), Open Questions 8 and 14: remain by design.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md cf8fe52e01557e11897fa39c58eddb1caa7e3af9
Reviewed-Content-Hash: design/registry/entities.yaml 9bb6179aa1c1ea999dc3f0932c48d8a5c9cc6f17
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (fifth review; blocker and recommended 1, 3, 4 revised the same day, awaiting re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 | Recommended: 6 (3 resolved)
Summary: Fourth-review fixes hold and all worked examples recompute. One design inconsistency: sect own-use goods and kind stipends were deducted from goods sold (Formula I) and also paid for in cash to the commons (Formula H). Fixed by user decision: in kind only; cash out falls to about 82k, leaving about 60k a season for treasuries (Open Question 15).
Prior verdict resolved: Yes
Findings:
- [BLOCKING] Formulas H/I/C: own_use and kind_stipend counted in kind and in cash. RESOLVED: in kind only; H, I, goods_frac rows and registry sect_income updated.
- [RECOMMENDED] States/AC-RE-14: war under Embargo undefined. RESOLVED by user decision: war still widens every ceiling.
- [RECOMMENDED] Formula G carry example mixed herb and ore. RESOLVED.
- [RECOMMENDED] Status header out of sync with systems-index. RESOLVED.
- [RECOMMENDED] Fill 1 at season 0 versus loose cultivators at fill 0: carried (Open Question 14).
- [RECOMMENDED] Seven dependencies with no GDD; Realms, Event Engine, Item DB handoffs pending: carried.
- [RECOMMENDED] PROPOSAL/provisional ACs (25, 26, 40, 44, 49, FX-RE-WORLD burn-in): remain by design.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 475fd486ae0dc6d714b55a90b2c36cfe54f01b7e
Reviewed-Content-Hash: design/registry/entities.yaml 491ff097bd1935815cc45983157c93157b9e6915
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (sixth review, first full review; 5 blockers revised the same day, awaiting re-review)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 5 (all resolved) | Recommended: 7
Summary: The core is sound (one faucet, ledgered holders, cover-based prices, harness as judge), but the money loop did not close. After the fifth-review fix about 60k a season piled up in treasuries with no rule to spend it, and the 60-75k stone sink had no income behind it because basket equals stipend. Player trading never wore out a route, and the harness criteria could pass on a frozen or broken economy. Creative-director: fix rules and criteria, leave numbers to the harness; new number disputes go to the harness, not back into review.
Prior verdict resolved: Yes (fifth-review in-kind fix confirmed: goods are consumed once; the game-designer's goods double-count claim was rejected by the main review and the creative-director)
Findings:
- [BLOCKING] Formula H/I: no spending rule above a treasury reserve; stone sink unfunded. RESOLVED by user decision: treasury band tb_seasons 4, tb_spend 0.5, half burned in cash works (burn_band), half posted as missions; money table relabelled unverified.
- [BLOCKING] Rule 16, Formulas G/L1: player trades never move p_loc; selling unbounded. RESOLVED by user decision: player flows enter bal_r (uncapped, loc_band bounds), sell slippage per place per season; AC-RE-49 band 0.5-1.5x with reinvestment over 40 seasons.
- [BLOCKING] Formula I: own use beyond what the sect collected taken free from stock. RESOLVED: Buy_short, bought in cash at P from the commons pool.
- [BLOCKING] Acceptance Criteria: in-kind fix not pinned. RESOLVED: AC-RE-52, AC-RE-53.
- [BLOCKING] Acceptance Criteria: harness ACs pass on a broken economy; AC-04/07/17/51 text errors. RESOLVED: liveness in AC-RE-37/38/39/41/42, special-class shock in 40, AC-RE-54 to 56, Formula D per-market starting stock.
- [RECOMMENDED] Formula E: "no overshoot" stability claim unsound with stock carry. RESOLVED: claim replaced, harness tests it.
- [RECOMMENDED] Formula C: calibration at fill 1 ignores ~1,700 loose cultivators at fill 0: carried (Open Question 14).
- [RECOMMENDED] Rule 4: raw-to-finished arbitrage and crafted-goods origin: carried (new Open Question 17).
- [RECOMMENDED] UI: breakdown lists P while rule 15 prices at p_loc; member/outsider undefined for embargo: carried.
- [RECOMMENDED] Missing money ACs (link payment, heirless split, wild-site split, unposted mission): carried.
- [RECOMMENDED] Carry capacity and cargo loss undefined: carried (new Open Question 16).
- [RECOMMENDED] Compound ACs to split (14, 15, 18, 31, 45, 46, 47, 49), tag mismatches (33, 36, 40), UI screenshot per screen, AC-43 1 vs N threads: carried.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 475fd486ae0dc6d714b55a90b2c36cfe54f01b7e
Reviewed-Content-Hash: design/registry/entities.yaml 491ff097bd1935815cc45983157c93157b9e6915
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (seventh review, second full review; 7 blockers revised the same day, awaiting a lean re-review)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: game-designer, systems-designer, economy-designer, qa-lead, creative-director (senior)
Blocking items: 7 (all resolved) | Recommended: 12
Summary: The architecture holds, but the money loop was still open: Formula H's treasury band stacked a second spender on the excess Sects F3 already invests, so a sect sat about 2N above its band and AC-RE-37 failed by construction, and several F3 income lines named no payer. The no-shock world was not at steady state (herb drifted to ~1.33), D = 0 was unguarded, and a poor famine region paid the least, breaking the Player Fantasy. Creative-director: rule, ledger and criterion fixes plus four user decisions; numbers stay with the harness; next pass lean and limited to these blockers.
Prior verdict resolved: Yes (review 6's five blockers stand; its treasury band was replaced, not kept)
Findings:
- [BLOCKING] Formula H: two treasury spenders (band rule and Sects F3 invest); AC-RE-37 unsatisfiable. RESOLVED by user decision: F3 invest is the only spender, inv_miss 0.5 posted as missions, rest to tracks; E* = N(1 - c_inv*inv_frac)/(c_inv*inv_frac); AC-54 rewritten, AC-60 added; Sects note.
- [BLOCKING] Formula H: F3 market tax, mission fee, tribute, head draw, war cost and unburned teleport fees had no payer. RESOLVED: one payer each, no fee on a sect's own-board treasury missions; AC-07 updated, AC-63 added.
- [BLOCKING] Formula C/D: no-shock world not at rest. RESOLVED: calibration to world S/D = 1 + dk*(c_ref - 1); AC-57.
- [BLOCKING] Formulas D/E/F: D = 0 gave inf/NaN; edge case contradicted D's cap. RESOLVED: D_min = max(1, 0.05*calibrated D) in D, E, F; AC-62.
- [BLOCKING] Rule 22, Formula C: a poor famine region priced low. RESOLVED by user decision: sub_floor herb 0.5, beast 0.5 (unpaid need, no money); C and L1; AC-58.
- [BLOCKING] Acceptance Criteria: AC-37 split (59-61), year = 4 seasons, FX-RE-SECT completed, AC-52/54 state, AC-21/24 slip stubbed, AC-49 fixed-capital wear test and FX-RE-PLAYER, AC-38 clamp checks dropped, AC-39 fill report moved to OQ 14, PROPOSAL owner economy-designer. RESOLVED.
- [BLOCKING] Rule 3 contradicted rule 20. RESOLVED: one market price, local price per place.
- [DECISION] Cargo (OQ 16): storage-item carry cap, cargo lost or looted on death via Formula K (rule 16, edge case). Player head cannot take own treasury missions; draw under F13 (edge case, AC-64).
- [REJECTED] economy-designer "heirless 70% unrouted": Edge Cases already route it to the death market's commons pool.
- [RECOMMENDED] Basket credits own goods at value but costs at p_loc: carried.
- [RECOMMENDED] origin_market laundering (gathering, craft, gift); craft arbitrage (OQ 17); "outsider" undefined for embargo: carried.
- [RECOMMENDED] Route wear has no memory; seat-side wear only via slip; buys never slipped; slip path-dependent (stack vs item): carried.
- [RECOMMENDED] S can go negative; state G_coll within S; kind stipend vs spent: carried.
- [RECOMMENDED] Price visibility on a fixed map (OQ 7): carried.
- [RECOMMENDED] Carried QA items: compound ACs, tags 06/33/36/40, missing money ACs (link payment, wild-site split, unposted mission), AC-43 threads, embargo-member path, Embargoed shortage ceiling, Visual/Audio, Game Feel and UI ACs, one screenshot per screen.
- [HARNESS] P* jump at c_short and 2-season oscillation; P above P_max after Strained; village slip severity and floor-of-1 dumping; basket +15% and fill at mean price 1.15; pool drain; stone-sink capacity (add a reporting AC).
Receipt note: the target GDD and design/registry/entities.yaml were revised in this session before this entry, and the reviewed text was not retained, so they are not stamped here; the next check compares them against review 6's stamps and reads CHANGED, which forces the re-review (the safe direction).
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-14 — Verdict: NEEDS REVISION (eighth review, lean re-review of review 7; 2 small blockers revised the same day, awaiting a re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 2 (both revised) | Recommended: 6
Summary: All 7 review-7 blockers are resolved in the text; the recomputed figures (E*, AC-52, 54, 55, 56, 57, 58, 31, 62) match. The two new blockers were propagation and fixture gaps: Sects F3 still subtracted the whole invest in Tr, which would fail AC-RE-54 and AC-RE-60 by construction, and AC-RE-63 did not state the mission fee, the teleport-fee payer or the head type that its figures depend on.
Prior verdict resolved: Yes (all 7 review-7 blockers)
Findings:
- [BLOCKING] Dependencies, Formula H: Sects F3 Tr and example subtracted all of invest. RESOLVED: F3 now subtracts c_inv * invest, with the treasury-rule note and a recomputed example.
- [BLOCKING] AC-RE-63: fixture lacked the fee rate, teleport-fee payer and head type. RESOLVED: stated (fee 0.20, NPC payers, NPC head).
- [RECOMMENDED] Formula H: does a treasury mission nobody takes pay out at posting or on completion (AC-54 assumes same season)? Carried in Open Question 15.
- [RECOMMENDED] Edge Cases vs AC-RE-62: D = 0 gave two outcomes. RESOLVED: edge case now says which.
- [RECOMMENDED] AC-RE-57: world-level S/D only; no per-market drift bound. Carried.
- [RECOMMENDED] AC-RE-58: no AC for the famine-region price outcome (Player Fantasy). Carried.
- [RECOMMENDED] Formulas H and I: whether F3 Cost already counts the in-kind share (possible double count in N). Carried in Open Question 15.
- [RECOMMENDED] Carried from reviews 6 and 7: compound ACs, tag mismatches, UI screenshot per screen, basket cost versus credit, origin_market laundering, outsider undefined, route-wear memory.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md df9ff9116edc16c10d5946564b6b4dd93114e92a
Reviewed-Content-Hash: design/registry/entities.yaml dd83e32cf457b9f81a39c05b8ce0639eea442974
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 23340bfe31c50189aa2357e438b635f7efa03194
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Receipt note: the hashes stamp the text this review read, before the revisions above; the next check reads CHANGED for the GDD and sects.md, which forces the re-review.

## Review — 2026-11-14 — Verdict: NEEDS REVISION (ninth review, lean re-review of review 8; 1 blocker revised the same day, awaiting a re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 (revised) | Recommended: 7
Summary: Both review-8 blockers are resolved: Sects F3 subtracts c_inv · invest, and AC-RE-63 states the fee, the payers and the head type (its arithmetic re-checked: ΔM −200). The one new blocker was stale propagation in sects.md: AC-SM-08 still gave Tr' 65,580 (all of invest subtracted) while F3's own example gives 68,145, so the Sects test would fail against Formula H. Registry spot check (bulk_spread, openness_tariff, provision_basket, local and market price bands) found no conflict.
Prior verdict resolved: Yes (both review-8 blockers)
Findings:
- [BLOCKING] Dependencies (Sects AC-SM-08): Tr' 65,580 contradicts F3's example 68,145 (c_inv 0.75). RESOLVED: AC-SM-08 now reads 68,145.
- [RECOMMENDED] Open Questions: row 13 sat after row 17. RESOLVED: reordered.
- [RECOMMENDED] AC-RE-54 and the Sects F3 example use different fixtures for the same rule; state one shared fixture.
- [RECOMMENDED] Compound ACs (AC-RE-13, 18, 31, 45, 49) bundle independent assertions; split or tag sub-cases.
- [RECOMMENDED] AC-RE-44 sits after AC-RE-64 under Performance; numbering is out of order (cosmetic).
- [RECOMMENDED] Visual/Audio, Game Feel and UI have no ACs beyond the two provisional UI screenshots.
- [RECOMMENDED] Open Question 15: if F3's Cost already counts the in-kind track share, N and E* are double-counted; settle before the harness run.
- [RECOMMENDED] Carried from reviews 6–8: origin_market laundering, "outsider" undefined, route-wear memory, basket cost vs credit, famine-region price AC, per-market drift bound.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 7a340cb6a0a036fc662573f321a04ac608bfb270
Reviewed-Content-Hash: design/registry/entities.yaml dd83e32cf457b9f81a39c05b8ce0639eea442974
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/sects.md 8a7a847f87fc8771c784075a70e4bdae9cdbbc85
Receipt note: the hashes stamp the text this review read, before the revisions above; the next check reads CHANGED for the GDD and sects.md, which forces the re-review.

## Review — 2026-11-14 — Verdict: NEEDS REVISION (tenth review, lean re-review of review 9; 1 blocker, revised the same day, awaiting a re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 1 (revised) | Recommended: 9
Summary: The review-9 blocker is resolved (Sects AC-SM-08 reads Tr' 68,145). The registry shows no conflict and the worked examples recomputed (A, D, E, F, G, AC-RE-13, 31, 52, 57, 58, 62, 63) all match. The one new blocker is a tick-order gap: Formula C's D includes spend_T, which includes the track share of Sects F3 invest, and invest reads Inc from this season's prices and flows, with no stated lag.
Prior verdict resolved: Yes (the review-9 blocker)
Findings:
- [BLOCKING] Rule 19, Formulas C and H: spend_T and invest in tick step (c) depend on Inc written in step (f); no rule says which season's values are used. RESOLVED in the revision: previous season's committed values.
- [RECOMMENDED] Rule 14: says standing applies at the shop; Formula G exempts raw goods. Narrow to finished goods.
- [RECOMMENDED] AC-RE-03: value_lt is per class; state the stock and pool split per class.
- [RECOMMENDED] Compound ACs (AC-RE-13, 18, 31, 45, 49); AC-RE-44 numbering out of order.
- [RECOMMENDED] Visual/Audio, Game Feel and UI have no ACs beyond the two provisional screenshots.
- [RECOMMENDED] Open Question 15: F3 Cost may already count the in-kind track share; untaken treasury missions' payout timing.
- [RECOMMENDED] AC-RE-54 and the Sects F3 example use different fixtures for one rule.
- [RECOMMENDED] Carried: origin_market laundering, outsider undefined, route-wear memory, basket cost vs credit, famine-region price AC, per-market drift bound.
- [RECOMMENDED] Dependencies with no GDD (Market, Time & Turn, Living World Tick, Event Engine, Game UI, Harness): noted in the doc, no action here.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 9283f9093300cf3becfd65f10d4e0adca135a075
Reviewed-Content-Hash: design/registry/entities.yaml dd83e32cf457b9f81a39c05b8ce0639eea442974
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 8caf0f5cd437bd93ef475732bdb0a562a234daec
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3
Receipt note: the hashes stamp the text this review read, before the revisions above; the next check reads CHANGED for the GDD, which forces the re-review.

## Review — 2026-11-14 — Verdict: APPROVED (eleventh review, lean re-review of review 10)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 9
Summary: The review-10 blocker (tick order of Sects F3 invest and spend_T) is resolved by rule 19's previous-season paragraph. The registry shows no conflict, and every worked example recomputed (Formulas A–J, L1; AC-RE-04, 05, 08–13, 18, 21, 30, 31, 45, 52, 55–58, 62, 63) matches. Remaining items are specification clarity and cross-document tidying; numbers stay guesses until the harness run.
Prior verdict resolved: Yes (the review-10 blocker)
Findings:
- [RECOMMENDED] Formulas H and I: `spend_T` and `own_use` carry no season qualifier; only D lags (rule 19). Say "this season's actual" in H and I.
- [RECOMMENDED] Rule 19: no AC checks that an Inc change in season s first reaches D in season s+2; add a Logic AC.
- [RECOMMENDED] Rule 14, Formula G: registry's sect_standing_price notes "no sale at St <= -30"; the GDD treats St -100–100 as always tradable.
- [RECOMMENDED] Formula E: P_maxeff says "while Strained", but Embargoed with shortage or war also widens ceilings (States).
- [RECOMMENDED] Registry: sect_mission_fee referenced_by lists only sects.md; add this GDD.
- [RECOMMENDED] Compound ACs (AC-RE-13, 18, 31, 45, 49); AC-RE-44 numbering out of order (cosmetic).
- [RECOMMENDED] AC-RE-33 is a code-inspection check; make it an explicit static check.
- [RECOMMENDED] Visual/Audio and Game Feel have no ACs beyond the two provisional UI screenshots.
- [RECOMMENDED] Carried: Open Question 15 (F3 Cost vs in-kind share), origin_market laundering, outsider undefined, route-wear memory, basket cost vs credit, famine-region price AC, per-market drift bound.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md ae3eb34d0ba20b4038fa873c00c11e4c66c487ce
Reviewed-Content-Hash: design/registry/entities.yaml dd83e32cf457b9f81a39c05b8ce0639eea442974
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/travel-map.md f415ce9c2d5100def8c40c8cb51cacef8ce83ea6
Reviewed-Content-Hash: design/gdd/sects.md 8caf0f5cd437bd93ef475732bdb0a562a234daec
Reviewed-Content-Hash: design/gdd/item-database.md 1742ab337d3d545765af3912c13a9848028b836f
Reviewed-Content-Hash: design/gdd/canh-gioi.md 27b622e32719f9923ae966aed1948b3277f683bc
Reviewed-Content-Hash: design/gdd/game-concept.md 49d71013c64d03b68e058d74fa88f8c2c4e1b7a3

## Review — 2026-11-23 — Verdict: NEEDS REVISION (twelfth review, full, of the Provinces #48 amendment; 6 blocking groups, revised the same day by the unattended loop, awaiting a re-review)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: game-designer, systems-designer, economy-designer, qa-lead; senior: creative-director
Blocking items: 6 | Recommended: 14
Summary: The amendment's arithmetic is right (Formula A, B, C, E recompute) but its examples and a few rules contradict Provinces F6 and rules 8 and 11. FX-RE-B's usage exceeds its output; the ore-short and famine local-price examples need access below 1 for a province that is short of a good, which F6 (outbound load only) never gives it; rule 7 says an under-connected province uses part locally while B ships the whole output times access; the Trade 0 edge case contradicts Provinces rule 8 (caps gate new orders); wilderness access is undefined; region and province units are mixed (AC-RE-44 still says ~20 regions). No new mechanic is needed.
Prior verdict resolved: Yes (review 11 was APPROVED; this reviews the amendment)
Findings:
- [BLOCKING] FX-RE-B, AC-RE-08, Formula A example: R2 usage 10,000 exceeds its 8,000 output; use infrastructure 5,833.6 against usage 8,000 (first tick, D_loc 0).
- [BLOCKING] Rules 16, 20, Formula L1, AC-RE-45/55/67: a province short of a good has usage 0 and access 1 (F6), so peace gives it the market price; rebuild the short-good examples as war cases (access 0.6) and say so.
- [BLOCKING] Rule 7: contradicts Formula B and Provinces rule 11; rewrite to match B.
- [BLOCKING] Trade 0 edge case: contradicts Provinces rule 8; caps gate new orders, standing buildings keep their level; add an AC.
- [BLOCKING] Formulas A, B, I, Edge Cases: wilderness province has no acc_v, is left out of B and I.
- [BLOCKING] Units: r indexes provinces in B, I, L1, G (Dp), FX-RE-PLAYER, AC-RE-04/49, interactions row; AC-RE-44 says ~20 regions (273 provinces, 141 settlement).
- [RECOMMENDED] Formula A: use F6's piecewise form (usage 0); rule 19: D_loc and fill are last season's; mine stones excluded from usage; Military does nothing at inf 1 in peace (intended); split AC-RE-08 by branch; ρ in ore examples; Trade 0 AC; FX-RE-PLAYER tie-break; AC-RE-49 route pair; short_own cash note; holder unit; Last Verified; rule 3 repetition.
- [REJECTED by creative-director] inbound load in F6 usage; min(prod, D_loc) split in B; Trade 0 access floor; inf_v in the L1 exponent.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 2bee9c3562f57f51a9be9582500c38b0f4404b0c
Reviewed-Content-Hash: design/registry/entities.yaml 7fb27b3136d2605356946a5868dc9f8a4d9ebe5f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/provinces.md d8bab6bcd392d4e0b1c06eafa2391db86bc56e30
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Receipt note: the hashes stamp the text this review read, before the revisions below.

## Review — 2026-11-23 — Verdict: NEEDS REVISION (thirteenth review, full, round 2 of the Provinces #48 amendment; 5 blocking, revised the same day by the unattended loop, awaiting a re-review)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: systems-designer, economy-designer, game-designer, qa-lead; senior: creative-director
Blocking items: 5 | Recommended: 14
Summary: Round 1's fixes hold and every worked example recomputes (Formulas A–E, G, I, L1; two 4-digit rounding drifts in A's war and Military 0 values). Remaining blockers are text contradictions, not new mechanics: access is one number per province (Provinces F6 sums classes) yet rule 16 and L1 call it per good; L1 has no rule for crafted classes; the price breakdown (rule 17, AC-RE-25) omits the local factor; AC-RE-69 leaves out the safety term; L1's per-province head count has no named source.
Prior verdict resolved: Yes (review 12 blockers confirmed resolved)
Findings:
- [BLOCKING] Rule 16, Formula L1, AC-RE-67: "a province short of a good has access 1" is false for a glut-in-one-good, short-in-another province (F6 sums usage over classes); reword to "no net surplus in any class". Creative-director rejected the per-good access alternative (a new mechanic).
- [BLOCKING] Formula L1, G: value_lt of crafted classes is 0, so bal is tiny and war pushes p_loc to the band top; state L1 applies to raw classes, crafted p_loc = P.
- [BLOCKING] Rule 17, UI Requirements, AC-RE-25: breakdown lacks the local factor p_loc / P, so parts do not multiply to the price.
- [BLOCKING] AC-RE-69: acc = infra/usage omits safe; rewrite with numbers (inf 0.5, acc 0.475; usage 2,250 inf 0.4).
- [BLOCKING] Formula L1: n[r,rl] has no named source per province.
- [RECOMMENDED] Formula A / AC-RE-08: war acc 0.4255 and Military 0 acc 0.7095 (unrounded safe).
- [RECOMMENDED] Rule 16, AC-RE-49: name the wearing end (buy end in peace); report the share of provinces at p_loc < 0.82 P; OQ 19 as a numeric harness check.
- [RECOMMENDED] Standalone short-province-in-peace AC; rule 19 last-season D_loc AC; AC-RE-16 R2 number; AC-RE-45 set_w and fill; AC-RE-02/03 province wording; AC-RE-04 "may differ" clause.
- [RECOMMENDED] Formula G Output Range stale (peace carry cap); ρ over settlement provinces; FX-RE-B seat inf injected; stale "region" wording; Formula H/I estimates to re-derive; acc ↔ D_loc oscillation harness check; show bal_r in the ledger.
- [NOT APPLIED] split of AC-RE-45 and 08b; fixture forcing acc ≤ 0.75 in FX-RE-PLAYER (game-designer's report instead).
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 0b61c47a5adfe5f607d3d172ca19170e5685eec8
Reviewed-Content-Hash: design/registry/entities.yaml 7fb27b3136d2605356946a5868dc9f8a4d9ebe5f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/provinces.md d8bab6bcd392d4e0b1c06eafa2391db86bc56e30
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Receipt note: the hashes stamp the text this review read, before the revisions above.

## Review — 2026-11-23 — Verdict: NEEDS REVISION (fourteenth review, full, round 3 of the Provinces #48 amendment; 4 blocking, revised the same day by the unattended loop, awaiting a re-review)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: systems-designer, economy-designer, game-designer, qa-lead; senior: creative-director
Blocking items: 4 | Recommended: 16
Summary: Rounds 1-2 hold and every worked example recomputes. The remaining blockers are leftovers of round 2's rule that crafted classes price at P in every province (the finished-goods carry text, AC-RE-45 and AC-RE-49 still assume a within-market gap), a mixed-province access claim that is only true when surplus usage exceeds infrastructure (AC-RE-70 had no infrastructure), an untestable AC-RE-02, and Formula H naming no home for Provinces' construction cost (plus AC-RE-07's identity omitting `burn_craft`). All are text and AC fixes; no standing decision reopened. The creative-director rejected the economy-designer's split of B by `D_loc` (reverses round 1) and sending forfeited construction money to the commons pool (would undo a burn).
Prior verdict resolved: Yes (review 13 blockers confirmed resolved)
Findings:
- [BLOCKING] Formula G (finished-goods carry), AC-RE-45, AC-RE-49, `loc_band_fin`: contradict crafted `p_loc` = P; the within-market finished-goods gap does not exist.
- [BLOCKING] Rule 16, L1, AC-RE-70: "mixed province has access below 1" only when surplus usage exceeds infrastructure; AC-RE-70 needs infra 4,000 (acc 0.6444, ore 1.29).
- [BLOCKING] AC-RE-02: not derivable (per class, which `h_f`, before or after the move, price step).
- [BLOCKING] Formula H / AC-RE-07: Provinces construction cost has no stated home (inside `burn_works`); AC-RE-07 omits `burn_craft`.
- [RECOMMENDED] L1 `D_r` lacks `bs[κ,b]`; rule 22 / Edge Cases / `sub_floor` / AC-RE-67 famine wording (local price moves only in war); G "real spreads" about 1.33× in peace; rule 19(c) reads `inf_v` from the contract; Formula A and B variable rows; `war_v` owed in Sects; Cross-References rules; AC-RE-03/45/55/24/21/25/69/08b/05 wording and numbers; stale access 0.8 in the rough world check; "0.55 P · 1.10" typo; wilderness mine money owner; UI reason line at factor 1.0.
- [REJECTED by creative-director] splitting B and I by `D_loc` (reverses round 1); forfeited construction money to the commons pool.
- [NOT APPLIED] route rotation and local-price loop ACs (harness, Open Question 19), war counted thrice (guess values), "prices elsewhere" for provinces (UI session), AC-RE-44 percentiles.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md c80f17a4e56fe932211d171804c3bc2c968597e5
Reviewed-Content-Hash: design/registry/entities.yaml 7fb27b3136d2605356946a5868dc9f8a4d9ebe5f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/provinces.md d8bab6bcd392d4e0b1c06eafa2391db86bc56e30
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/trade-goods.md 4114de5549c4bfffef3fe811c59a175c6cac4188
Receipt note: the hashes stamp the text this review read, before the revisions below.

## Review — 2026-11-23 — Verdict: NEEDS REVISION (fifteenth review, full, round 4 of the Provinces #48 amendment; 4 blocking, revised the same day by the unattended loop, awaiting a re-review)
Review mode: full · Workflow: standard
Scope signal: XL
Specialists: systems-designer, economy-designer, game-designer, qa-lead; senior: creative-director
Blocking items: 4 | Recommended: 14
Summary: Rounds 1-3 hold and every amendment example recomputes. Remaining blockers are claim-versus-formula text: rule 16 / L1 say a province with a surplus prices at or below P in peace, but L1 centres on the market ratio ρ while Provinces F6 does not, so a surplus province under ρ can price above P; Formula H has no payer for player-funded or local-lord construction and omits the lost-stash pool; the Player Fantasy promises a famine end that peace does not give; several ACs are stale (4 classes, old Military mix, rounding, mixed one/two-market fixture). The creative-director rejected changing F6 to read ρ·D_loc (cross-GDD) and dropping ρ from L1 (reverses round 3): fix the sentence.
Prior verdict resolved: Yes (review 14 blockers confirmed resolved)
Findings:
- [BLOCKING] Rule 16, Formula L1: "in peace p_loc > P only for a mixed province" is false when bal_r < 1 (a surplus province under the market ratio, ρ about 1.5) with infrastructure under usage; reword, add an AC with ρ 1.5.
- [BLOCKING] Player Fantasy: the peace famine end does not exist; reword to the glut route, war and shocks.
- [BLOCKING] Formula H: no payer for player-funded building or a local lord's construction; lost-stash pool missing from the holder list; "commons gets the rest" contradicts the wild-site half.
- [BLOCKING] AC-RE-06, 26 (4 classes), 53 (old Military mix), 25 (rounding), 49 and FX-RE-PLAYER (one-market and two-market mixed).
- [RECOMMENDED] Formula A output range (0.275 at start) and FX-RE-B comment; D_loc per class sum; G Dp zero-shop guard and "0.55 P" garble; G stale 2.4x/1.8x; rule 16 access-1 wording and main-loop sentence; H surplus budget for undefined sinks; Tuning Knobs pl_mem, inv_frac; AC-RE-16, 45, 55, 71, 69, 70, 67, 02, 49 tweaks; ACs for cargo loss and no-heir burn.
- [NOT APPLIED] province-panel and own-effect ledger lines (UI session); AC splits; AC-RE-44 machine detail.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 89a14ab40a5d86cfbcc3169eecf1f5338593ee02
Reviewed-Content-Hash: design/registry/entities.yaml 7fb27b3136d2605356946a5868dc9f8a4d9ebe5f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/provinces.md d8bab6bcd392d4e0b1c06eafa2391db86bc56e30
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/trade-goods.md 4114de5549c4bfffef3fe811c59a175c6cac4188
Receipt note: the hashes stamp the text this review read, before the revisions above.

## Review — 2026-11-23 — Verdict: NEEDS REVISION (sixteenth review, lean, round 5 of the Provinces #48 amendment; 3 blocking, revised the same day by the unattended loop, awaiting a re-review)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 3 | Recommended: 4
Summary: Rounds 1-4 hold. The user decision of 2026-11-23 (after round 4: Provinces F6 usage counts goods brought in as well as shipped out) makes a poorly connected province short of a good under-connected, so its local price rises above P in peace too. The GDD still says in a dozen places that a short province has access 1 and trades at P in peace and that local shortages show only in war; those sentences, the examples built on them and two ACs now contradict Provinces F6 and L1.
Prior verdict resolved: Yes (review 15 blockers confirmed resolved)
Findings:
- [BLOCKING] Rule 16, rule 20, rule 22, Player Fantasy, Edge Cases (famine), Tuning Knobs `sub_floor`: "a short province has access 1 and trades at P in peace; shortage shows locally only in war" is wrong under F6 with imports.
- [BLOCKING] Formula A and L1 (notes and examples), Formula G output range: A does not say usage counts goods brought in; L1's peace ore-short example and G's "sell end at most P in peace" (1.64x, 1.33x) contradict it.
- [BLOCKING] AC-RE-67 and AC-RE-70 (and Open Questions 18, 19): assert usage 0, access 1, p_loc = P for a short province in peace; need a peace case with usage = shortfall.
- [RECOMMENDED] Header Status and Last Verified; Open Question 18's owed-in-Provinces note is done in Provinces and is rewritten; Open Question 19 sentence "in peace only glut provinces sit below P"; price-breakdown reason line wording.
- [NOT APPLIED] AC splits; harness-measured figures.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md 59b7692b86935d63ccd4eda96d4f0b7997aca937
Reviewed-Content-Hash: design/registry/entities.yaml ca55c0128329ac74148b7230d2e87822c420af09
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/provinces.md 9ac50486025115a27a3fbe5d19f8d71a3269fa51
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/trade-goods.md 4114de5549c4bfffef3fe811c59a175c6cac4188
Receipt note: the hashes stamp the text this review read, before the revisions above.

## Review — 2026-11-23 — Verdict: APPROVED (seventeenth review, lean, round 6 of the Provinces #48 amendment; 0 blocking, 3 recommended, none applied)
Review mode: lean · Workflow: standard
Scope signal: XL
Specialists: none (lean)
Blocking items: 0 | Recommended: 3
Summary: Round 5's three blockers (stale "a short province trades at P in peace" statements) are resolved: rules 16, 20, 22, Player Fantasy, the famine edge case, Formula A's `inf_v` row, L1's examples and asymmetry, G's output range and AC-RE-45/55/67/69/70/71/72 now agree with Provinces F6 counting goods brought in. Every worked example in A, B, L1 and the amendment's ACs was recomputed and matches (0.7172, 0.4255, 0.7095, 0.656, 1.33, 1.456, 0.836, 1.030, 1.105, 1.027, 1.140, 1.355, 0.663, 1.057, 0.9707, 0.475, 0.376). No contradiction with Provinces F6 or the registry found.
Prior verdict resolved: Yes (review 16 blockers confirmed resolved)
Findings:
- [RECOMMENDED] Cross-References: the Provinces row omits rules 3 and 16, which the amendment also touched.
- [RECOMMENDED] Tuning Knobs `λ_road`, `λ_war`: "loss in a region at war" reads per province now (`war_v`).
- [RECOMMENDED] Dependencies, Provinces row: "pending review" status is stale next to Provinces' own In Review header.
Reviewed-Content-Hash: design/gdd/regional-economy-trade.md f9319169b8ba2958f864b181b6ddd0427151d128
Reviewed-Content-Hash: design/registry/entities.yaml ca55c0128329ac74148b7230d2e87822c420af09
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md 4dcc8b81162613c757144532f1b72708ab3ba27f
Reviewed-Content-Hash: design/gdd/provinces.md 9ac50486025115a27a3fbe5d19f8d71a3269fa51
Reviewed-Content-Hash: design/gdd/travel-map.md 34615ef6a3454d058bdb1e8551ec4973f909d1b2
Reviewed-Content-Hash: design/gdd/sects.md 9db8041d244fe5e1ec55f9e9b146782b6ea0d653
Reviewed-Content-Hash: design/gdd/item-database.md ec553379489fd19353c568d7143e918b3d6cc355
Reviewed-Content-Hash: design/gdd/canh-gioi.md c8ae4f305d1c42ce24da5873f1133394a0652175
Reviewed-Content-Hash: design/gdd/game-concept.md b497f52abf8ff59cc59b08839a90ad20b0a36572
Reviewed-Content-Hash: design/gdd/trade-goods.md 4114de5549c4bfffef3fe811c59a175c6cac4188
Receipt note: the hashes stamp the text this review read (no revision was made).
