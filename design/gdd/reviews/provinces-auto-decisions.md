# Provinces — auto decisions (unattended review-and-revise loop)

## Round 1 (2026-11-23, full review, NEEDS REVISION)
- B1 usage: dropped P[m,k], usage = base value val[k] only; usage_0 = usage at generation with D_loc 0 — matches rule 11 and the Victoria 3 base-value rule, removes price loop, keeps start floor.
- B2 double count: out[b] is only the non-site part; site gain counted once via G_f in Travel & Map H — creative-director's reading of Formula H; owed in Travel & Map (OQ 9).
- B3 F2: breadth-first distance to nearest settlement, output moves only to d-1 neighbours split by border, static matrix at generation, counted once in gatherers — smallest rule with no cycles. Region-local restriction NOT added (new restriction; shares are static so holder change does not reshuffle them).
- B4 F3: fed = cover >= famine_cover; safe = no war/tide this year; fed-but-unsafe P'=P; f_war reused for tides (no new knob); C=0 guard; range wording fixed.
- B5 lifecycle: ruin_seasons = 3 (guess), Cancelled state, cost paid evenly over build seasons, upkeep by holder/local lord via works_due in S5.
- B6 outpost staff: gatherer with largest share, lowest id on tie.
- Recs applied: F5 max(formula, standing); seat sets slots and infra0; strained_access 0.7 (guess); province_full_fit pointer to hud.md; staff 0 at level 0; more-factors clamped >= 0; P/P0/C, prod_wild, level_b table rows; 0.75 % note; removed "settlement founded later"; AC-05, 07, 13, 15, 19, 21, 22, 23, 25 reworded/extended; OQ 8 and 9 added.
- Not applied: pooled staff, upkeep priority and grace, one building per kind, slot contention, imports vs access, cost destination, carry arbitrage (new rules; OQ 8); acc floor (no effect with infra0 > 0); AC for every rule (listed gap); AC-24 wall-clock rewrite (OQ 5); AC-26/27 rewrites (playtest/screenshot bars, balance pass).

## Round 2 (2026-11-23, full review, NEEDS REVISION)
- A AC-PV-15 war case: set to 9.5 (F3 gives no growth when unsafe, round 1 B4 stands).
- B/C F4 prod_wild: own output with w's own modifiers plus inflow from d+1, high d down, only d <= wild_hops; a blight on w cuts only its own output (creative-director reading), gatherer modifiers apply on arrival.
- D outpost staff: follow the largest-share hop (lowest id on a tie) to a settlement province; extends B6.
- E rule 9: granary -> Holdings, great-project stages -> Institutions (provisional, OQ 10); "pavilions" left in place (user's mapping), OQ 10 asks to name or drop it.
- F AC-PV-22: (1 - acc) share is "lost in carriage" (RET B as written); no new local-stock rule.
- G cover_st: raw market cover c[m,k] (herbs, beast parts); access coupling added to OQ 8, not applied (new rule).
- I F6 usage: prod * val - D_loc in base value; D_loc base value stated.
- J States table: player-funded building exception to Cancelled.
- Recs applied: F3 clamp wording and range line, F1 secondaries only if main value > 0, main/secondary fixed at generation, stale RET dependency row, AC-02, 07, 14 (boundary + multi-hop + blight + outpost), 17, 19 (numbers), 21, 23 wording; new AC-28 (rule 9 caps), AC-29 (shipped share); OQ 8 extended, OQ 9 extended, OQ 10 added.
- Not applied: AC-05 split into several ACs (the three behaviours stay in one AC; balance pass), AC-23 numeric fixture (waits on RET A/L1), rule 12 stats with no formula term and P_set_now (new terms; listed in OQ 8), access times cover_st.

## Round 3 (2026-11-23, full review, NEEDS REVISION)
- B1 prod_wild/prod: max(0, 1 + sum inc) in both — one clamp, no new field.
- B2 AC-PV-04/25: split settlement and wilderness clauses; wilderness has no infra, usage, access or local price (rule 3, F6).
- B3 Overview: "shortage shows first in its local price" (famine from poor access stays in OQ 8).
- B4 F3 windows: cover_st = last season's c[m,k] read at the yearly step; safe = war state and tide modifier read at the step (no history kept) — matches Dependencies and OQ 9, creative-director's reading.
- B5 Unpaid: level_b is the effective level (Active only; permanent works keep gains); out, staff, infra, cap_b read it.
- B6 rule 11/F6: D_loc only lowers usage (load); RET B still takes the whole output times acc_v; F6 acc[v] = RET inf_v, RET A's acc_v adds the safety term; AC-29 pinned to peace, D_loc 0, h_f 1.
- B7 AC-PV-22: narrowed to what Provinces owns (no local consumption term; h_f, shockS, Imp/Exp are RET's); stated per class with no modifiers.
- B8 AC-PV-14 fixture rewritten (d=1 and d=2 forests, 30+50=80); AC-PV-07 stray text removed.
- Recs applied: F1 none when max 0 and wild recursion, k = Item DB class; F3 range and percent-of-C wording, fed when neither class trades; staff_lvl and famine_cover > 0; infra[b] per level; outpost staff 0 if none reached; F5 standing counts all states but Cancelled, range wording; Planned trigger; D_loc 0 first season; value_lt = prod·val; AC-09, 12, 15 (P0, famine+war), 16 (clamp, Unpaid), 21 tolerance, 23 marked fixture-dependent; new AC-30, AC-31; OQ 8 and OQ 10 extended.
- Not applied: famine-with-low-access AC, pooled staff, stuck-below-strained metric, cap on sum cap_b (balance pass); AC-08 split, AC-24/26/27 rewrites, AC-20 payer (OQ 8); missing ACs for infra_old no-slot and beast-tide branch.

## Round 4 (2026-11-23, full review, NEEDS REVISION)
- B1 upgrade: level_b stays at the built level while an Active building is upgraded; only first build and repair start at 0; Cancelled upgrade keeps built level (States, F4, level_b row, AC-PV-05).
- B2 Unpaid vs Travel & Map Formula J: Provinces' Unpaid/Ruined states win for province buildings (rounds 1/3 kept); Formula J/AC-TM-106 change owed in Travel & Map (OQ 9).
- B3 workshop: no output class; a craft-capacity effect Trade Goods reads (OQ 2); out[b] raw classes only; veins stay outside prod/usage/access (RET I as before).
- Recs applied: caps gate orders only (rule 9); outpost kinds named as rule 8 (rule 7); AC-PV-19 same-tick, AC-05 ruin count, AC-07 tolerance, AC-09 read time, AC-14 numbers, AC-22 rewritten (conservation + supply, not a tautology), fixture-knob line; start floor before modifiers; downward access loop; rule 14 points to RET rule 16; registry province_market_access expression.
- Not applied: pooled staff, upkeep on holder change, local lord caps, cost destination and construction materials (OQ 8), cover_st min vs mean, G_f lag, F3 clamp under mild famine, AC-31 split, extra boundary ACs, AC-26/27 bars, AC-16 permanent fixture (needs Travel & Map kind), Planned slot reservation.

## Round 5 (2026-11-23, lean review, APPROVED)
- Verdict: APPROVED, no blockers; worked examples and AC fixtures re-checked and hold. Approval log entry appended and systems index set to Approved; no GDD edit (approved path).
- Not applied (recommended, in the log): registry province_slots range and expression, stale "until RET is revised" wording, inline ruin_seasons and strained_access, AC-PV-09 wording.

## Round 6 (2026-11-23, lean review, NEEDS REVISION)
- B1 F6 usage class set: sum over raw classes only (matches RET D_loc and L1; Provinces make no crafted goods) — smallest fix, no new term.
- Recs applied: "worst case" measurement reworded as the D_loc 0 start state, re-measure noted in the text (OQ 1 already covers the balance pass); Edge Case for a short, poorly connected province (price above P in peace); stale "until RET is revised" edge case reworded; OQ 9 lists the RET statements owed (short province trades at P in peace); registry province_slots range/expression and market_access class wording; header Last Updated and Status.
- Not applied: registry/inline definitions of ruin_seasons and strained_access in a variable table, AC-PV-09 wording split, an AC for crafted-class exclusion (balance pass), imports-aware access effect on cover_st (OQ 8).

## Round 7 (2026-11-23, lean review, APPROVED)
- Verdict: APPROVED, no blockers; examples and AC fixtures re-checked and hold. Approval log entry appended and systems index set to Approved; no GDD or registry edit (approved path).
- Not applied (recommended, in the log): RET row of the Interactions table (add D_loc and staple cover), rule 10 note that the start floor holds at generation before imports count, registry province_market_access variable P_market.
