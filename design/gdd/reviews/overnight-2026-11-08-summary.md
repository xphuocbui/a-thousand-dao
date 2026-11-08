# Overnight summary — 2026-11-08

Four `/design-review` passes ran unattended on four GDDs (lean mode, workflow `standard`). Every pass
returned **NEEDS REVISION**, and each GDD has the same 2 blockers it had after pass 1. They need design
choices, and none were made unattended. Only safe fixes were applied (wording, stale terms, cross-references,
status lines). Passes 3 and 4 found nothing new: the documents were unchanged apart from status lines.

Full detail: `overnight-2026-11-08-decisions.md` (questions and answers) and the four review logs in this folder.

## Per GDD

| GDD | Final verdict | Passes | Safe fixes (p1 / p2 / p3 / p4 = total) | Blocks approval |
|---|---|---|---|---|
| Combat Defence & Healing (`combat-defence.md`, #21a) | NEEDS REVISION | 4 | 14 / 11 / 3 / 1 = **29** | Registry shield range; drain billing |
| Combat Damage Types (`combat-damage-types.md`, #21b) | NEEDS REVISION | 4 | 10 / 7 / 1 / 1 = **19** | Mixed Soul hits; same-step conversions |
| Modifier System (`modifiers.md`, #40) | NEEDS REVISION | 4 | 7 / 2 / 1 / 1 = **11** | Rule 8 targets; typed-resistance price |
| Effects System (`effects.md`, #41) | NEEDS REVISION | 4 | 5 / 4 / 1 / 1 = **11** | Rule 5 reads; rule 6 actions |

Every worked example, fixture and AC number in all four GDDs was recomputed and matches. The registry
constants each GDD owns match too. The math is sound. The blockers are rules an implementer would have to guess.

## Decisions waiting for you

Blockers come first in each group. Every recommendation is the reviewer's suggestion, and nothing has been applied.

### Modifier System (modifiers.md)

1. **BLOCKER: rule 8 has no targets for heal, reservation, outgoing status, basic attack or outgoing soul hit.**
   Recommended: add them. Outgoing status matches the status's own tags. A heal matches its source art's tags.
   Reservation matches the reserving ward's or art's tags. Basic attack and outgoing soul hit are "outgoing hit"
   narrowed by their implied tag.
2. **BLOCKER: the typed-resistance price is ambiguous.** The Stat List's 1.0 / 0.83 already includes breadth, so
   Formulas C counts breadth twice (+1.5 pp instead of +1.2 pp). Recommended: store one price, 1.25, in
   `modifier_prices`, and describe 1.0 / 0.83 as effective prices. The catalogue and generator are already right.
3. The rare list is missing ward slots (30 W) and the resistance cap raise (5 W). Recommended: add ward slots to rule
   13 and the Rare table, widen the range to 10–30 W, and treat the cap raise as rare by its row.
4. Chaos resistance is listed as an ordinary family row. Recommended: mark it rare, to match Damage Types rule 5.
5. Cross-References has no effects.md row. Recommended: add one (rules 1, 6, 15 ↔ effects.md rules 1, 3, 15).
6. Interactions has no #21a or #21b rows. Recommended: add them.
7. The Formulas C range says 60 W but computes at 25.8 W. Recommended: "about 215 units in-tree, up to 500 at 60 W".
8. The note "reservation kept as Pending" is stale. Recommended: say it is Designed (Defence rule 10).
9. Rule 4 says regeneration is "per second". Recommended: "per second or per pulse (Stat List)".
10. Formulas D writes `L_i_typ(r)`. Recommended: drop the (r), unless Combat gives per-realm values.
11. OQ 8 is mostly done. Recommended: narrow it to registering the full price table in `stat_power_weights`.
12. Back-references are missing in many reader GDDs. Recommended: add them in the #43 and Meridian Map sweeps.
13. Tuning Knobs is absent (advisory). Recommended: add a table at the revision.
14. Player Fantasy is absent (advisory). Recommended: optional, since Game Feel covers it.
15. *(Found outside scope, not edited)*: combat-defence.md line 228 cites "(Modifier System; Formulas H)", and this
    GDD has no Formulas H. Recommended: "(Modifier System Formulas A–C; this GDD's Formulas H for wards)".

### Effects System (effects.md)

1. **BLOCKER: the starter Effects read things that rule 5's readable list doesn't have** (ward payments, regeneration
   clip, `dot_pulse_cap` clip, stack count). Recommended: add "a cap's clipped amount (per named cap)", "ward payments
   against your hits" and "a status's stack count on the target", each with its read time. Clips and payments are
   events, and stack count is live.
2. **BLOCKER: the starter Effects use actions that rule 6's action list doesn't have** (add a tag or a slot, skip a
   roll, multiply a sheet share, fire an art as a last act, raise a host cap, change a life output, refusal, counted
   chance). Recommended: add them as named actions, which keeps the list closed and checkable by AC-EF-06.
3. Starter reads have no read times, and the life table has no Reads column. Recommended: add them (conditionals
   instant start, sheet reads compile, events none).
4. Blood Casting and Withering each give −50 % healing taken. Recommended: they don't stack; there is one floor of −50 %.
5. Sundered on a hit with several parts: which part decides? Recommended: the largest part after conversion, with
   ties going to the first type in Damage Types' order.
6. Corpse Rot has no duration, so it can't meet the duration lint. Recommended: exempt standing statuses. The tick
   caps, the upkeep and `c_tick ≤ 0.15` limit them instead.
7. Token costs. Recommended: Called Blow's 0.35 crit cap is its whole cost, so drop the fortune clause.
   **You decide** Soul Leaves the Body's cost.
8. Rule 7 paraphrases the trigger budget and leaves out its floor. Recommended: cite Combat Formulas G instead.
9. The capability count doesn't add up (6 + ~12 + "the other 19" > 25). Recommended: say "the remaining ~7" once
   OQ 4 settles.
10. AC-EF-10 uses the retired body-ward model. Recommended: mark it a test fixture now and restate it in #43.
11. `counted_start` range. Recommended: state it as 0–999 per mille.
12. The systems index says 44 starter Effects, but the GDD holds 46. Recommended: correct the index.
13. One-way dependencies. Recommended: add back-references as each host GDD is revised, starting with #43.
14. Tuning Knobs and Player Fantasy are absent (advisory). Recommended: add a Tuning Knobs table only, with no values changed.

### Combat Defence & Healing (combat-defence.md)

1. **BLOCKER: the registry's `defence_shield` range says 1.0 × health_max, but Formulas B allows 2.0.** Recommended:
   change the registry to "0 to 2.0 x health_max per side (1.0 ward, 1.0 body)".
2. **BLOCKER: drain billing is incomplete.** It has no bill for drain-paid block, evade, status or soul payloads. It
   goes negative when r_eff < 0 and is undefined at R_pos = 0. Recommended: bill block at `rate_w` × the block points
   the ward actually took. Make drain invalid for evade, status and soul payloads. Use `max(0, r_eff)`, and bill 0
   when R_pos = 0. This also settles item 10.
3. Shield cap timing. Recommended: `shield_total_cap` clips the maximum sizes at compile, later slots first.
4. Thể tu (body cultivator) fixture: R_Physical is 0.30, but the named sources give 0.20. Recommended: the other 0.10
   is Black Iron Armour's Physical affix; name it in Formulas G.
5. Stall check "41 s" recomputes to about 43.8 s. Recommended: recompute it in the harness (AC-CD-45).
6. Fast-kit exact D. Recommended: state D = 24.75.
7. OQ 1 scope. Recommended: narrow it to checking modifiers.md's defence prices against Formulas I.
8. OQ 10 and OQ 14. Recommended: close them, keeping only "retire `ward_block` and `body_guard_pct` with #43".
9. AC order (53–58 sit between 46 and 47). Recommended: move that block under AC-CD-52 without renumbering.
10. Drain bill when r_eff is floored. Recommended: bill 0 (part of blocker 2).
11. Back-references are missing in six GDDs. Recommended: add them in the #43 sweep.
12. Tuning Knobs and Player Fantasy are absent (advisory). Recommended: add a Tuning Knobs table with safe ranges.
    Player Fantasy is optional.

### Combat Damage Types (combat-damage-types.md)

1. **BLOCKER: hits that mix Soul with other types are undefined.** Recommended: they aren't allowed. A hit is either
   all Soul or has no Soul part, and compile rejects a mixed hit. AC-DT-22 becomes two hits.
2. **BLOCKER: same-step conversions are undefined.** Recommended: conversions from one type in one step all read the
   share at the start of the step. A step is one source tier (the art, then Effects, then modifiers), so 0.583 +
   0.417 leaves 0 Physical, as AC-DT-16 expects.
3. Does a conversion that moves nothing count toward the limit of 2? Recommended: no, matching the Soul rule.
4. Does conversion change a status tick's type? Recommended: no. A status keeps its record's type, and changing that
   takes an Effect.
5. The registry's `defence_resistance` still lists R_gen, R_kind, R_elem. Recommended: change it to R_all + R_type(final),
   together with Defence blocker 1 (both are registry edits).
6. The systems-index row 21b description is stale (kinds, element cycle). Recommended: rewrite it in the next index sweep.
7. OQ 4 is partly answered by effects.md. Recommended: narrow it once effects.md passes review.
8. The Formulas A bound says 4 × the authored parts, but the tight bound is 3 ×. Recommended: tighten it after blocker 2.
9. Back-references are missing in five GDDs. Recommended: add them in the #43 sweep.
10. Tuning Knobs is absent (advisory). Recommended: add a table (conversion limit 2, type colours) with the blocker fix.
11. Player Fantasy is absent (advisory). Recommended: optional.

## What failed or did not run

- **No pass failed.** All 16 passes (4 GDDs × 4 passes) completed and wrote their log entries.
- **Passes 2–4 were not full re-reviews.** The freshness check found each GDD unchanged except for safe fixes. As the
  skill directs, the verdict was carried over and only cross-document facts were re-checked.
- **No specialist agents ran** (lean mode).
- **Registry not edited**: Defence blocker 1 and Damage Types item 5 were out of scope tonight.
- **Harness not run**: the Defence stall-check recompute (AC-CD-45) waits for your go-ahead.
- **Not edited (out of scope)**: the combat-defence.md line 228 citation (Modifier System item 15).
- **Edited besides the GDDs**: `systems-index.md` (status cells only). Nothing was committed.

## Next step

1. **Approve or change the decisions above.** Start with the 8 blockers. Further unattended passes would only repeat
   tonight's verdict, so they are not worth running until these are answered.
2. Apply the answers, then re-run `/design-review` on each GDD in a fresh session.
3. **Combat revision (#43).** Most back-reference and retirement items above are routed into it (AC-EF-10, OQ 10/14,
   `ward_block` / `body_guard_pct`, dependency sweeps).
4. **Meridian Map redesign.**
