# NPC Relationships — auto decisions (unattended review loop)

Standing user decisions (not reopened): caps bound hook payouts not bond counts; favour repaid by a deed (call-in event), stones optional; ân tình its own debt part; soft reserve 2/4; hook pass at end of S8b; cause + event-log link per part; met list 500; flat master/đạo lữ cultivation rows (CD-GDD-ALIGN 2026-11-20); no LLM needed; linh thạch is money only; slightly OP builds fine.

Round 1 (this file's first round; design-review round 3 of the GDD, 2026-11-21):
- R1 / record shape: enmity and blood feud stored per direction (strength, set season, cause, inherited each); friend and rival share one strength. Why: creative-director direction; smallest change that makes both-way enmity storable.
- R1 / F3 Grudge stack: F3 takes min(Grudge target, feud + enmity value) as one term. Why: stops −110.
- R1 / betrayal and repay: written in place on the existing record, needing no room. Why: avoids a dropped betrayal.
- R1 / S8b order: ends, lost-notability evictions, strength changes, new parts, hardening, hook pass. Why: evictions compare current strengths; matches log order.
- R1 / known kills: tick and Power Rankings kills are known unless an event flags them secret. Why: otherwise NPC kills never feud.
- R1 / favour call-in: scheduled, outside budgets, B = 0, answered = accepted and attempted, unpresentable call-in clears with no slight. Why: no unearned punishment, no payout loop.
- R1 / causes: payload copied into the cause; link optional; ends write a tie_end entry with a reason. Why: log pruning.
- R1 / errand_margin: 1.0 (was 1.25). Why: items used at full price made errands a profit.
- R1 / Formula E: arithmetic corrected, "hard bound" renamed per-source bounds; NPC-kill share stays tracked outside. Why: user accepted as tracked.
- R1 / not applied (Recommended only): player part-ways verb, friend fade speed, lazy met-list eviction, b_v scope, extra ACs beyond the four wrong ones and 15c, registry additions beyond edits, errand-cost transfer instead of burn (OQ 7 is the user's).

Round 2 (unattended loop; design-review round 4 of the GDD, 2026-11-21):
- R2 / per-direction enmity: comparisons (rule 7 eviction, rule 10 replace) read the larger direction; fade, writes, sweep and hardening run per direction; replacing kind wipes both; rules 11/13 remove only the holder's direction. Why: creative-director fix direction; smallest change that makes both-way storage coherent.
- R2 / over the limit: in-place betrayal/repay, hardening and later pinned adds may leave a person over the soft-only limit; the next soft-only add evicts down to one below the limit (each strictly weaker) or is refused. Why: keeps the add rule 7 one rule; exception named in AC-NR-28/48.
- R2 / favour clock: call-in presented within favour_call_seasons of the join, or the first reachable season; flag and p_help 0 stay until then; only the sibling's death clears without a deed; no second deadline; answered = accepted task ends Completed or Failed; refusal or lapsed/dropped task = slight (deed). Overrides round-1 "unpresentable call-in clears with no slight". Why: round 1 let seclusion dodge the standing "repaid by a deed" decision; this is not a user decision.
- R2 / avengers: pinned feud holders count as avengers (first); an avenger's feud is re-set as their own (inherited false, cause kill). Why: otherwise a new kill could not renew a vendetta.
- R2 / mourners: floor applies only to enmity already held toward the killer; against a friend or rival it is another soft kind (dropped if weaker); a mourner who takes nothing still uses the slot; `outside_cap` marker stored on the record; ties broken by lower person id.
- R2 / feud ends: new reason and news kind `slain` / `feud_end_slain` for a kill by anyone but the holder's side; tie_end carries the ending death's payload.
- R2 / verbs: declare enmity = +30 enmity both ways, an ordinary soft write (not a deed); repay a debt the player owes = the creditor offers a B = 0 deed (same machinery as the call-in), completing it clears the debt and sets repay_friend, no new stone sink. Why: creative-director direction; flagged for the user to confirm.
- R2 / errands: stone share of a resolved errand's reward is refunded out of the burn (the payer), items from the market commons; "never a profit" reworded (a discount on goods up to ~1.4 x at market buy prices); errand_margin stays 1.0 (retune belongs to the OQ 3 balance run).
- R2 / numbers: Formula E 18,760 / 22,160 / 12,388; registry tie_bound and tie_hooks (0.85 -> 0.68) updated; AC-NR-37 budget 20; AC-NR-30/31/50/51 fixed; new AC-NR-52..57.
- R2 / not applied (Recommended only): tie_end schema and parted split, avenger-loop exit, lawful-kill flag, heir order (đạo lữ), avenger enmity floor, integer arithmetic, hardening on exact strength, stip_r floor, gratitude payer, errands_max wording, met-list eviction exempting the player, UX-spec brief, split AC-NR-51, notice templates, fade silence.
- R2 / dropped as noise: "sweep then new part" and "two deltas one season" (rules 4, 9, 10 already answer), inheritance slot order (rule 13 states it), FX-FAM override, AC-NR-28 flakiness.

Round 3 (unattended loop; design-review round 5 of the GDD, 2026-11-21):
- R3 / same-season deaths: the season's whole queued dead set is struck first (heirs, avengers, mourners, feud targets); the same-season no-pass sentence is dropped. Why: creative-director direction; log-order reading lost a massacre's feud.
- R3 / hook pass: reconciles `tie` rows by source and visits people named in step 1/2 changes. Why: record removal orphaned rows; standing decision (hook pass at end of S8b) kept.
- R3 / errands: B_errand = floor(errand_margin x errand_cost), no min with B_quests; items are raw commons, bound 1.08 (bulk 1.10); errand_margin stays 1.0. Why: creative-director pick over economy's 0.7; the bulk bound is near break-even; OQ 3 still tunes it.
- R3 / inherited feud passes: to the same heirs and mourners as soft enmity at the floor, held outside the cap on the target's side; cause carries origin + generation. Why: keeps O_kill 8 per death; text survives generations. AC-NR-20 gets FX-FAM-2.
- R3 / end reasons: one table (reason, producer, news kind); added `holder_died`, `partner_died`; `parted` produced by companion dismissal, sư đồ expulsion or an Event Engine tie_end; `avenged` needs the holder or someone holding feud/enmity toward the target; secret kills write no killer; old age vs failed breakthrough text split. Why: AC-NR-56 was unrunnable.
- R3 / favour state: awaiting / presented (forced accept-or-refuse, no deadline of its own) / accepted (task deadline); refuse cost shown as the branch that applies. Why: 15c named a deadline 15a does not have.
- R3 / ACs: 20, 54, 56, 37, 06 reworded, 52 independent WHENs, FX-FAM-2 added. Overruled as noise: AC-NR-12 stale (adds up in whole units), AC-NR-06 enmity 100 unreachable (a verb writes at once).
- R3 / not applied (Recommended only): gratitude pays the debt down, declare-enmity cooldown, met-list exemption for the player, step 4/5 log order, notability evictions first, composite tie-break, hundredths note, favour_cost realm, avenger minimum, đạo lữ/kết nghĩa/master as heirs, sanctioned-kill flag, stale Overview line, FX-STUBS gaps, UI AC split, missing ACs, E5/E6 payout bounds.

Round 4 (unattended loop; design-review round 6 of the GDD, 2026-11-21):
- R4 / stale log-order and AC-NR-54: Edge Case rewritten to the struck dead set; AC-NR-54 uses FX-FAM-2 (C1's pre-season inherited feud passes only as soft enmity). Why: creative-director direction.
- R4 / feud count: per death, per target (Edge Case, AC-NR-48). Why: Formula D/E already say so.
- R4 / favour and parting: `favour_owed` survives `parted`/`tie_end` (record may hold only the flag, call-in stays, slight as usual); only death or betrayal clears it. Why: creative-director pick over the designer's "clear it", which let a parting dodge the standing "repaid by a deed" decision.
- R4 / end reasons: added `replaced`, `cancelled`; `faded` covers a Δ to 0; target's reason wins over `holder_died` when both die the same season. Why: closes the table.
- R4 / errands_max: counts errands in progress at once; failed or lapsed errand pays nothing; items minted at price (no market stock or NPC purse); stone share floor(0.2 x B). Why: one meaning; conservation line.
- R4 / outside_cap: kept clearing when another part joins, but named in rule 1 and rule 5's exceptions. Why: smallest change that makes the cap text true.
- R4 / numbers: met_notable_max safe 100-650; soft_reserve rejected above its cap, cap_ordinary safe 2-6; cap-3 total about 15,788; registry notes updated. Why: 1,000 gave 24,660 records over the 23,000 target.
- R4 / not applied (Recommended only): call-in fire season and slight write time, shared friend strength slight, killing-blow enmity vs step 1, per-target slot lists, hook-pass row index, errand-pay AC additions, AC-NR-21/51/56 and fixture rewrites, new ACs.

Round 5 (unattended loop; design-review round 7 of the GDD, 2026-11-21):
- R5 / favour answered: read from the Quests end state: Completed or a lost `defeat` stage = answered; abandoned, lapsed, dropped, item disposed, target killed by the player's side = slight; call-ins only (a refused or abandoned repay deed leaves the debt, no slight). Overrides the round 2/3 "Completed or Failed". Why: creative-director direction; Quests counts abandon as Failed so it was a free clear. Not a user decision.
- R5 / pay favour_cost: cancels a scheduled, presented or accepted call-in (Withdrawn, no slight). Why: needed by the item above.
- R5 / pools: avenger and gratitude draws count against player_events_per_season_max and the chain budget; gratitude paying the debt down stays declined. Why: creative-director narrowing of the economy finding.
- R5 / favour_owed record: counts as pinned for rules 5, 6, 7 (never evicted, not soft-only, lowers the soft-only limit by one). Why: creative-director pick; otherwise rule 7 evicted it first.
- R5 / mourners: the master follows đạo lữ, before other kin. Why: creative-director direction.
- R5 / hardening: step 6 also tests every record a verb wrote since the previous S8b. Why: verbs write outside the tick.
- R5 / ACs: AC-NR-54 last case rewritten (H feud toward T, C1 feud toward K) plus a master-order case; AC-NR-56 gains (k) replaced, (l) cancelled, (m) same-season precedence; AC-NR-49 gains abandon and pay-after-presented cases. FX-PAIR "ordinary" finding overruled (a GIVEN describes state).
- R5 / not applied (Recommended only): safe ranges for cap_notable, inherit_feud_max, mourner_max; -70 minimum vs rule 10; line 598 wording; one call-in per season; heirs split a debt; sư đồ ending mid-errand; Formula D avenger order; tie-break direction; AC-NR-20 generation; AC-NR-52 sweep; p_help stubs; AC-NR-49/51 splits; missing ACs.
- R5 / back-link owed: Event Engine, pool draws count against the budgets (listed under rule 15b; user accepts back-links as tracked).

Round 6 (unattended loop; design-review round 8 of the GDD, 2026-11-21):
- R6 / outside_cap: on its marked side the record is neither counted nor an eviction candidate; the other side may evict it. Why: creative-director picked game-designer's fix; rule 5 weakest-first would otherwise delete mourner enmity freeing no slot.
- R6 / per-target slots: slots, struck sets and de-duplication per target; a person may take one part toward each target; O_kill "8 per target per death". Why: creative-director direction; two lists in one death were ambiguous.
- R6 / call-in vs favour: sibling death or betrayal Withdraws any call-in, no slight; a slight never writes to a removed record; flag-only record writes its slight in place before removal (steps 4/5). Why: creative-director direction.
- R6 / generation: known kill = 0, each hand-down = holder's + 1; FX-FAM-2 gives C1 generation 0. Why: AC-NR-20 expectation not derivable; qa-lead option.
- R6 / added ACs: call-in withdrawn, outside_cap not a candidate, two targets, favour_owed counts as pinned.
- R6 / downgraded: economy sell-back valuation (items valued at Item Database price; regional arbitrage bounded by errands_max, slightly OP fine).
- R6 / not applied (Recommended only): AC hygiene (21/25/26/43/44/48/50/53/54), repay-refused and companion ACs, shown vs threshold, integer opinion rounding, stale registry notes, Formula D feud-holders-first, -70 floor sentence, hook-pass row index, player-kill source, met-list exemption (declined before).

Round 7 (unattended loop; design-review round 9 of the GDD, 2026-11-21):
- R7 / FX-FAM-2 and AC-NR-20: origin names an already-dead W outside the fixture, not the living H; generation 1 kept. Why: qa-lead blocker, creative-director confirmed; fixture was unbuildable.
- R7 / rule 13 "Who takes it": relabelled "Who takes an inherited feud", wording scoped to the soft-enmity pass. Why: game-designer blocker, creative-director confirmed; wording only.
- R7 / repay verb with several open obligations: not a blocker, a Dialogue menu detail; added to back-links. Why: creative-director ruling.
- R7 / not applied (Recommended only): stale errands-a-season wording, AC-NR-55, Formula D max, cap_notable range, Formula C Δ=0, gratitude bound, 1.08 at cost 3, OQ3 metrics, favour_cost in the clock lines, rule 12 scope, record-size label, AC-NR-01/49, FX-PAIR note, AC-NR-28 bound.

Round 8 (unattended loop; design-review round 10 of the GDD, 2026-11-21):
- R8 / debt inheritance: the debtor is struck from a debt's heirs (next in line takes the slot); a debt whose debtor is in the season's dead set is cancelled. Why: creative-director picked strike over cancel-outright, matching the feud-target rule; no self-debts or orphans.
- R8 / costs: favour_cost and errand_cost = ceil(stip_r x mult); range 3-2,500 stated at multiplier 1.0. Why: creative-director chose ceil over raising the safe floor; stip_r >= 3 so no max(1,...).
- R8 / notability eviction: runs only if the person is still not notable when S8b runs. Why: rule 6 evicted regained notables, contradicting rule 5.
- R8 / dead set: a queued change naming a person in the season's dead set is dropped; AC-NR-48 gains a no-orphan, no-self-pair bullet. Why: step 5 rebuilt a record for the dead.
- R8 / betrayal: removes every pinned kết nghĩa, đạo lữ and sư đồ the pair holds; AC-NR-17 two-kind case. Why: one betrayal breaks the whole bond.
- R8 / ACs: AC-NR-48 last bullet bounds soft enmity toward a target by inherit_feud_max + mourner_max (fits inherited-feud hand-down); AC-NR-49 seclusion begins after the join.
- R8 / not applied (Recommended only): repay-verb clock, Formula D feud-holders-first, kin tie_end, declare-enmity cooldown, outside_cap label, stale registry notes, FX-FAM notable, AC-NR-20 H/C2, AC-NR-29 fields, missing ACs, errand "at most" wording, 1.10 at cost 3, state-table rows 454/456, step-1 adds vs step-3 eviction.

Round 9 (unattended loop; design-review round 11 of the GDD, 2026-11-21):
- R9 / FX-PAIR: ties a GIVEN line sets are written directly as authored records; rule 6's gate is for the add path. Why: AC-NR-04/05/17 held bonds rule 6 refuses; creative-director confirmed, matches FX-FAM-2.
- R9 / step 1 deaths: apply in ascending dead-person id. Why: shared heirs' slots made the result order-dependent; one clause.
- R9 / heir order: "eldest first" by World DB birth season, ties by lower id, for children and disciples; "longest-held" dropped everywhere; children = World DB parent is the dead. Why: no formed-season field exists and none is added (smallest fix; creative-director pick over storing a season).
- R9 / favour flag: answer or favour_cost clears it at once; a refusal or unanswered end clears it in the same S8b change as its slight; enmity remainder written in place so the record survives; a record with no flag and no part is removed in that change. Why: lines 380 vs 388 conflicted and nothing said when the flag cleared.
- R9 / cap data change: a person over the new limit is over the limit under rule 5, no unconditional eviction. Why: line 707 contradicted rule 5.
- R9 / downgraded: faded-unswept part vs room tests (a 0 part is always a strictly weaker candidate; same outcome, only the reason differs).
- R9 / not applied (Recommended only, creative-director: end the loop, review once after all GDDs): sweep before room test, errand "a season" wording, conservation "at most", cost fixed at send, 1.10 at cost 3, Overview line 36 met list, AC-NR-55 K-at-limit and favour GIVEN, AC-NR-21 slots, AC-NR-52 lazy sweep, AC-NR-25 wording, FX-EV-T kill rate vs O_kill, Formula D feud holders first, floats in floor/ceil, state-table gaps, step 3 vs step 1 limit, eviction tie-break, debt heir with no room, friend direction wording, tie_end on kin/feud, declare-enmity spam (Dialogue's).

Round 10 (unattended loop; design-review round 12 of the GDD, 2026-11-21):
- R10 / flag-only record: survives a refusal or lapse (slight enmity written in place); removed only on answer, payment or sibling death; Edge Case and rule 15a now say the same. Why: creative-director; Edge Case contradicted 15a.
- R10 / end reasons: a friend tie lost to a slight is `faded` only, struck from `replaced`. Why: one event, one reason.
- R10 / flag clear: flag clears and the empty-record test runs after the slight's last write (step 5 when a remainder exists). Why: step 4/5 split slight was order-dependent.
- R10 / set_season: inherited and new-part writes set set_season = season_now (Formula C and registry tie_soft_strength). Why: creative-director rated Recommended; cheap clause, applied.
- R10 / not applied (Recommended only): AC-NR-02/20/35/38/44/54 wording, Summary hook wording, flag-only slight and parted-kind soft-only exceptions, feud_threshold and errand_cost_mult ranges, gratitude per-debt cap, heir debt weight, errand refund ledger note, hook-pass row index, mourner_max vs inherit_feud_max wording.

Round 11 (unattended loop; design-review round 13 of the GDD, 2026-11-21, lean):
- R11 / verdict: APPROVED, no blockers. Why: full read and hand recomputation of formulas and numeric ACs found no contradiction; the three round-12 fixes are consistent across rule 15a, Edge Cases, state table and AC-NR-49.
- R11 / Formula D avenger order vs rule 13: kept Recommended, as in rounds 6, 8 and 9 (rule 13 governs, a feud has no strength to order by). Why: consistency with earlier rulings; one-line alignment left for the single review after all GDDs.
- R11 / no GDD edit: approval path makes no other edit; only the systems-index row and the logs changed.
