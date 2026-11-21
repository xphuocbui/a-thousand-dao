# Formations — auto decisions (unattended review-and-revise loop)

## Round 1 — 2026-11-21 (design-review full; NEEDS REVISION)

- Share of a foreseen fight not laid: carried at 0.7 (laid 1.0, ambush 0.7, blind 0.5); the user's standing decision, wording fixed in Overview, rule 9, F1, AC-08.
- "Negative" in rule 7 / F1: keyed on the polarity field (negative-polarity node = drawback), not the sign; a −20 % cooldown node is a positive-polarity benefit and scales. Smallest fix, uses the existing rule 1 field.
- What S × share multiplies: only authored numbers (Modifier values, feed seconds, an Effect's numeric magnitude); conditions, thresholds, counts and gates never scale (option 4a, Recommended).
- Keystone order: the keystone's +2 applies after both caps, `L_eff = min(L, min(max_level, skill + 1) + 2 with keystone)` (option 2a, Recommended).
- Feed floor: `new = min(timer, max(timer − feed, cooldown_min))`; a feed never raises a timer. `cooldown_min` is Combat's value (registry 0.5 s), not restated as a Formations constant.
- Stone booking: Formations books every array and diagram stone (build, raise, upkeep, lay fuel, triggers) in `burn_formation` (option 3a, Recommended). Back-links owed: Cave Abode rule 14 (except Formations' standing arrays), Regional Economy line 511 (builds and raises).
- Corrections folded in: F1 minimum 0.5, AC-17 tests power −50 % (S = 0.5), S_min stays as a safety bound; AC-04 "at or above 50 %"; F4 m = 1 for an unscoped node, links not scored.

not applied (Recommended only): F2 L7 range note, F5 maximum, loop-claim rewording for carried diagrams, Effect-trigger logging, F2 rounding method, F3 direction note, node-index priority note, AC number additions and renumbering, protective-array per-season cap, NPC fuel aggregate formula, usable-maximum warning, yearly vs seasonal upkeep note, teleport fee recipient.

## Round 2 — 2026-11-21 (design-review full; NEEDS REVISION)

- Keystone inert: F3 gains "with the keystone a diagram's maximum level is cap + 2" (headroom, as Effects defines it); rule 7's L_eff expression from round 1 stays unchanged, AC-FO-20 rewritten to a reachable stored L7; F2 range extended to L7 (117 %, above 100 % means carried); registry diagram_strength and lay_fuel mirrored. The systems-designer's `min(L, cap) + 2` was rejected: it reverses round 1 and gives free levels.
- Set diagram dropped after a fight: States table In fight → Set (the loadout persists); Known/Set entry columns adjusted. Smallest fix, one cell.
- Dormant or left standing arrays: rule 14 says Cave Abode rules 9-10 apply first (no upkeep, keeps its level, never Lapses) and the abode's seasonal works upkeep (rule 8) does not bill arrays; no new state. Back-link owed widened to Cave Abode rule 8.
- F4: placement defined (nodes by descending |node_score|, ties by index; each takes the unplaced art with the highest node_score × m, ties by pool order); `fit_min` read "at or below". Registry fit-score expression left as it is (it already says greedy by |node_score|).
- Folded in as wording: "laid" → "set (neither laid nor carried)" for N above slot_count (rule 3, edge case, AC-FO-02); F3 states raise_cost(L) is the cost to reach L from L−1 (375 for Tụ Linh L2); registry diagram_strength output range reads 0.5 (S_min a safety bound), as the GDD.

not applied (Recommended only): scaled-modifier clamp sentence, sect-owned array booking clause, F2 rounding method, F5 maximum and sect owner realm, mutual-feed cycle lockout, dangling "(Formulas D.)", AC-FO-16 "one season", AC-FO-13/14/26 input rewrites, AC-FO-05 cycle clause, other AC splits and new ACs, F3 variable table and diagram cost values, always-lay and flat-upkeep harness checks, protective per-season cap and hostile-party condition, Hộ Sơn vs protective array record, arrays at a place vs the abode slot rule, adjacency plus feed on one pair.

## Round 3 — 2026-11-21 (design-review full; NEEDS REVISION)

- Rule 17 / Interactions: books build and raise stones of every array kind plus diagrams, lay fuel, upkeep and protective triggers; teleport fuel stays in `burn_fees` (not booked twice). Smallest fix, matches Regional Economy's ledger.
- Scaled cooldown floor: one sentence in rule 7 and F1: stops at `cooldown_min`; other scaled Modifier values clamp to their key's bounds. No new mechanic.
- F2: keystone maximum corrected to 5,873; rounding `ceil(x − 1e-6)` (the project's tolerance convention); AC-FO-19 gains the 5,873 case.
- Rule 1 record: adds requirement (realm, skill), teaching sects (Sects owns), per-node `node_score`; `fuel_frac`/`cost_lt` are data-file lookups by grade.
- Rule 11: opening Breakdown also prints lay fuel, share and reservation; the per-node post-fight tally is NOT added (new mechanic) and goes to new Open Question 9; Game Feel bullet trimmed.
- ACs: AC-04 (laid S = 1, Effect-node oracle), AC-12 ("at or below"), AC-13 (named inputs; 375 is the L2 cost), AC-16 (yearly span, one summed sink), AC-19. States: Known entry "Set (swapped out)".

not applied (Recommended only): player-paid burn vs `player_net`, NPC fuel formula, F5 sect owner realm and per-season cap, raise without an abode, empty-drawback dominance check, vacuous one-hop clause rewording, loop-claim rewording, AC-03/21/25/26/23/10/11/01/07 rewrites, new ACs for rules with none, Set → default-line state row, F1 L range note on `slot_count`.

## Round 4 — 2026-11-21 (design-review full; NEEDS REVISION)

- "Cooldown %" Modifier: no such key (the user replaced it with `art_speed_pct` 2026-11-06). Restated rule 5, F1, rule 7, AC-FO-04 (+25 % art speed, 10 s → 8 s), AC-FO-18 (−20 % `art_cost_pct` node as the polarity-not-sign example, plus a scaled art-speed case floored at `cooldown_min` by Combat A2) and the registry expression. A new cooldown key was rejected: it would undo the user's decision.
- Left arrays: rule 14 now says a dormant array keeps its level and never Lapses (Cave Abode rule 9), a left array stops counting, owes no Formations upkeep and fades on Cave Abode's clock and is gone on a claim (rules 10, 11). Corrects round 2's paraphrase of Cave Abode rule 10; Cave Abode itself is not edited (back-link owed: rule 11 names arrays).
- Price on a conditioned node: one authoring sentence in rule 7 (a node whose authored number is a price is negative polarity whatever its condition). No new field.
- Feed floor kept (round 1 decision); one sentence in rule 6 says it is deliberate; whether a feed may ready an art goes to the user as Open Question 10.
- NPC lay fuel: one clause in rule 12 (paid from its purse at fight start, Formula H books the season sum as one line). No new formula.

not applied (Recommended only): Tuning Knobs section (advisory at standard), rule 10 ground-object definition, Effect magnitude bounds, crafted start level, empty-drawback dominance, F4 links and drawback order, F2 range per node, F5 Output Range and clamp, upkeep formula and F3 variable table, feed-cycle boundary, keystone wording, AC-FO-16 build/NPC scope, reservation ordering for a Set diagram, registry `revised` fields, Formula H AC identity and player-paid burns, upkeep cadence and partial payment, carried-at-70 % dominance, reserve-vs-strength lint, protective cap, teleport wording, sink projection, the 12 qa-lead AC additions.

## Round 5 — 2026-11-21 (design-review lean; NEEDS REVISION)

- AC-FO-04 stale "−20 % cooldown" Modifier: reworded to "+25 % `art_speed_pct`" (the key the same criterion's oracle already uses; rule 5 says there is no cooldown key). One-phrase fix, no new mechanic.

not applied (Recommended only): AC-FO-23 ordering, rule 6 one-hop clause (vacuous under the feed floor; matters only if Open Question 10 is answered yes), Tuning Knobs section (advisory at standard).

## Round 6 — 2026-11-21 (design-review lean; APPROVED)

- No blocking item: round 5's AC-FO-04 fix held; no contradiction found. Header status and systems-index row set to Approved; no other edit.

not applied (Recommended only): AC-FO-23 / Open Question 10 ordering, rule 6 one-hop clause (vacuous under the feed floor), Tuning Knobs section (advisory at standard).
