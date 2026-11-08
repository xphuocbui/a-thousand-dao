# Re-review summary — 2026-11-08 (daytime)

All four GDDs are still **NEEDS REVISION**. All 8 overnight blockers are resolved, but the re-review found **13 new
blockers**, and only you can settle them. No pass failed. Nothing was committed, and the registry was not edited.

Reasoning for every item: `rereview-2026-11-08-decisions.md`. Item numbers below match that file.

## Per GDD

| GDD | Final verdict | Passes | Safe fixes (p1 / p2 / p3 = total) | Open decisions | What still blocks approval |
|---|---|---|---|---|---|
| Combat Defence & Healing (`combat-defence.md`, #21a) | NEEDS REVISION | 3 | 11 / 7 / 3 = **21** | 23 (5 blockers) | Soul shield formula; home of `ws`, `we`, `a_w`, `a_b`; drain billing for shared block and a short pool; AC-CD-59 cannot pass; price check rejects a catalogue ward |
| Combat Damage Types (`combat-damage-types.md`, #21b) | NEEDS REVISION | 3 | 9 / 2 / 1 = **12** | 19 (3 blockers) | Modifier conversions cannot exist; path of a qi (linh lực) tick; order of conversions inside a step |
| Modifier System (`modifiers.md`, #40) | NEEDS REVISION | 3 | 21 / 3 / 6 = **30** | 18 (2 blockers) | Type scopes on crit, art speed and art cost; the `[fire, over_time]` resistance row |
| Effects System (`effects.md`, #41) | NEEDS REVISION | 3 | 13 / 7 / 2 = **22** | 24 (3 blockers) | Reads missing from rule 5; actions missing from rule 6; path of a qi tick |

The 85 safe fixes correct wording, worked figures, cross-references and status lines to match what was already decided,
with no new design choice. Some do touch formulas or figures: Damage Types pass 1 fix 3 rewrites Formulas A's same-step
update to match your answer, and Defence pass 1 fix 2 changes the drain rate from 0.958 to 0.959.

Please check four in `modifiers.md` first: pass 1 fixes 14 and 20 add the most text (fix 14 adds 10 prices from the Stat
List, with its G mark taken from a file that calls every value a guess), and pass 3 fixes 3 and 4 correct the basis notes
for evade and art cost. No price changed in those last two.

## Decisions waiting for you

There are 84 items, but only about 75 separate questions, because some repeat across GDDs (listed next). If most of the
recommendations look right, reply "accept all except ..." as you did this morning. These four are the ones to read:

- **DT 2** reverses your own answer from this morning.
- **CD 21** depends on what you intend for Tribulation (Thiên Kiếp).
- **DT 12** is a naming choice.
- **EF 7** decides whether a last act can win a fight.

**You already answered three of these this morning** (D1–D3 in `combat-revision-draft.md`, recorded there as decided),
though the re-review lists them as open:

- **CD 2** is D1 and **CD 10** is D2. Both only need applying.
- **CD 1** is D3, plus two new parts that need your answer: a cap on the share, and `ws` scaling the bar instead of the share.

**One answer closes both items:**

- DT 3 = EF 3
- MD 2 = CD 23
- CD 11 = EF 16
- DT 16 = EF 21
- MD 4 = EF 22
- CD 12 = DT 18
- CD 18 = MD 15
- DT 8 = the interface row in EF 19

The back-reference items (CD 16, DT 14, MD 9, part of EF 19) are also one question. DT 17 (fixed order of types) is
needed by MD 1 and EF 5, and MD 11 follows DT 2.

### Combat Defence & Healing

Blockers:

- **CD 1. How does a soul shield work?** Takes `soul_shield_share × pct` off each pool loss after E2's `pct`; its bar is spent first; the share is capped below 1; `ws` scales the bar, not the share.
- **CD 3. How are shared block and a short pool billed?** Split points taken by each source's share of `B_hit`; add the leak to `a_j` before block; a drain-paid block's unpaid share is not taken; add AC cases.
- **CD 4. Which attacker should the shield-stall check (AC-CD-59) use?** The realm's typical attacker plus a slow hitter with gaps above 2 s. Cap knobs stay the first fix, and `recharge_delay` or `shield_recharge` may also fix a stall. Shields stay uncapped.
- **CD 19. What T does a cast ward's non-shield payload use?** Its up time inside `T_ref` (firings × duration), which reproduces the catalogue. Black Tortoise Shell scores 3.72 as written, so AC-CD-41 fails.
- **CD 2. Where do `ws`, `we`, `a_w`, `a_b` live after #43?** Defence Formulas A, with a stub in Combat D; rule 1, Dependencies and OQ 2 then agree.

Others:

- **CD 20. What may change a defence sum mid-fight?** Slots and base sums compile once; curses and Effects apply live on top.
- **CD 21. Does a Down refusal count as healing?** No, so it works under `no_heal`; rule 19 cites Effects rule 11. Check against Tribulation's intent.
- **CD 8. Should a ward with no resistance, block or shield payload for a part suppress the default ward?** No.
- **CD 5. Does a broken shield end a cast ward with other payloads?** No; only its duration ends the ward.
- **CD 6. Standing shield start and Down behaviour?** Starts full; while Down it keeps its value, does not soak and does not recharge.
- **CD 22. Cast ward state names?** Keep Expired after a firing, add Waiting before the first, and use them in rule 7 and AC-CD-17.
- **CD 23. Does type-plus-tag resistance exist?** No for now; drop the row, or mark it Pending if you want it later.
- **CD 11. Add the No Ward flags to rules 5 and 11?** Yes.
- **CD 9. Is `a_b` 2.0 legal?** State 1.0 as one piece's top end and say how 2.0 is reached, or lower those cases.
- **CD 10. What does `a_w` mean?** All non-body defence.
- **CD 7. Define `x` for `b` = 0?** Yes; the wards never fall, so ehp = P / λ_all.
- **CD 12. Define the Pending Modifier rows now?** When they leave Pending; note it in Open Questions now, and decide the duration limit then.
- **CD 18. Is "about 0.35 on body gear" stale?** Recheck at the Modifier revision and restate it if so.
- **CD 13. Apply the three registry edits (`defence_ehp` range, `default_resist` note, `dot_pool_cap`)?** Yes.
- **CD 14. Add the seven missing Tuning Knobs?** Yes, no value changed.
- **CD 15. Add Cross-References rows for effects.md and Modifier System rule 13?** Yes.
- **CD 16. Keep back-references in the #43 sweep?** Yes.
- **CD 17. Reword the stall figure's label?** Yes, after the harness runs; no change until then.

### Combat Damage Types

Blockers:

- **DT 2. Can a modifier carry a conversion?** No; steps are the art's own conversions, then Effects. This changes the tier list you accepted this morning (art, Effects, modifiers), but it matches your Modifier vs Effect decision, which makes every conversion an Effect.
- **DT 3. What path does a tick on qi follow?** Force resistance, then qi, passing every shield.
- **DT 1. How are conversions ordered inside a tier, and does scaling run before the limit of 2?** Stable compile order (slot order, then record id); apply the limit first, then scale only the kept conversions.

Others:

- **DT 7. What sets a free hit's parts?** Its record names a type or copies its source art's authored parts, then converts as usual; compile rejects it otherwise.
- **DT 15. Is a part at share 0 removed?** Yes, at the end of its step, so it spawns, counts and deals nothing.
- **DT 12. Keep both "Chaos" names?** Keep the damage type "Chaos", and call the spiritual root (linh căn) "Primordial Chaos (Hỗn Độn)" in player text.
- **DT 5. Does "final type only" apply just among damage types?** Yes; element and form scopes still apply.
- **DT 16. Add an action for changing a status's type, or drop the sentence?** Drop it until an Effect needs it.
- **DT 17. Declare rule 1's table the fixed order of types?** Yes.
- **DT 4. Remove "curses' damage" from the Chaos row?** Yes.
- **DT 6. Change Lightning's or Light's colour?** Yes; move Light to a pale near-white gold on another 256-colour code, and add a check to AC-DT-22.
- **DT 8. Who owns conversion rules and records?** This GDD owns the rules and steps, Effects own the records, and Combat cites rule 6 after #43.
- **DT 18. Change rule 4 for typed block now?** When the row leaves Pending, with CD 12.
- **DT 19. Keep element-relation Effects as a future permission?** Yes; the cells say "none yet".
- **DT 9. Add same-step chain and later-step AC cases?** Yes.
- **DT 10. Add Cross-References rows for modifiers.md and effects.md?** Yes.
- **DT 11. Close OQ 4?** Yes, once effects.md passes review.
- **DT 13. Rewrite index row 21b's dependency cell?** Yes, to "resistance by final damage type".
- **DT 14. Keep back-references in the #43 sweep?** Yes.

### Modifier System

Blockers:

- **MD 1. How does a damage-type scope work on crit, art speed and art cost?** Crit counts it if the hit's largest part carries that type or has it in its history (ties go to the first type in Damage Types' order). Art speed and cost read the art's authored parts, unchanged by conversion.
- **MD 2. Keep resistance scoped by type plus a mode?** Remove it here, in Defence Formulas I and in the generator; foe pairs stay Pending.

Others:

- **MD 3. Are Effect payloads exempt from rule 12?** Yes, which matches your "Effects unpriced" decision; a rare modifier is allowed only when the Effect's host is on rule 13's list.
- **MD 4. Who owns the status tags?** A "status" family owned by the Effects Status Catalogue, one tag per status; rename `qi_burn`; `[body_shield]` is a heal-source tag owned by Defence.
- **MD 5. Must an owner name a floor for cheap lower-is-better stats before they leave Pending?** Yes, for all of them. Two notables make formation (trận pháp) upkeep or talisman (phù lục) ink free today.
- **MD 18. Does rule 8 cover `resist_cap_pct`?** Yes, with the same final-type match.
- **MD 6. Key `modifier_prices` by key and op?** Yes.
- **MD 14. No realm-drift deflator until the bot has measured it?** Yes.
- **MD 15. Re-derive the 0.6 artifact defence price?** Yes, when Item DB adopts the raised mapping; keep 0.6 until then.
- **MD 16. Record the regeneration stats on the 0.01 grid?** Yes; no value changes.
- **MD 17. Add family tags and domain to the Stat List?** Yes; this changes no combat number.
- **MD 7. Add AC cases for the five targets and the rare-by-row rule?** Yes.
- **MD 10. Accept the three rounding-lint rows as known exceptions?** Yes; list them and make the 15 % threshold a knob.
- **MD 11. Update Damage Types rule 5 to "rare by its row"?** Yes, with that GDD's answers.
- **MD 12. Close Defence Open Question 1?** Yes, apart from the note in MD 15.
- **MD 13. Apply the registry price-table edits?** Yes, once the blockers are answered.
- **MD 8. Add the six missing dependency rows?** Yes, as soft dependencies.
- **MD 9. Keep back-references in the #43 and Meridian Map (Kinh Mạch Đồ) sweeps?** Yes.

### Effects System

Blockers:

- **EF 1. Add the missing reads to rule 5?** Yes: root element, formation level, stage, an art's authored record, the Down step, a failed brew, a death in an event, and the chance about to be rolled (live).
- **EF 2. Add the missing actions to rule 6?** Yes: burn qi (inside the 5 % cap), enforce a closing rule at compile, and an event's outcome under life outputs.
- **EF 3. What path does a tick on qi follow?** Same as DT 3; for Spillover, the clipped amount burns with no second resistance step.

Others:

- **EF 6. Waive the cost, or pay and refund it (First Move, Paid in Advance)?** Waive it; add the action to rule 6.
- **EF 7. Can a last act win, and who goes first?** Requesting side first; overkill is kept, so it wins only if the enemy's overkill share is larger.
- **EF 20. Does restoring qi count as healing?** No; clip at the usable maximum.
- **EF 5. What type does Sundered lower with no hit, or on an all-Soul hit?** The applying record names a type, and an all-Soul hit cannot apply it.
- **EF 18. Can stones pay upkeep under Seal of Full Payment?** No; qi still pays it.
- **EF 24. Should #43 adopt the `basic` tag?** Yes; until then, mark that half of Bare Rack Pending, because it does nothing today.
- **EF 4. Is strength required only where a status has a number?** Yes; AC-EF-16 currently rejects shipped curses.
- **EF 8. Keep Great Essence-Draining Art as a Trigger?** Yes; move "+2 heart demon reported" into its payload, and let rule 13 say "or another kind".
- **EF 12. What does a recast do under stacking "None"?** Nothing; add it to rule 9.
- **EF 23. Is Field Walls fixed for the fight?** Yes, if formations cannot fall in a fight.
- **EF 11. Use slot order for every tie?** Yes.
- **EF 10. How does `p` round?** To the nearest thousandth, half up.
- **EF 9. Add cultivation base and stage to rule 10?** Yes.
- **EF 15. Keep the two ways to pay in health?** Yes; record the difference in #43.
- **EF 16. Add the No Ward flags when Defence is revised?** Yes, same as CD 11.
- **EF 21. Add an action for changing a tick's type?** No, same as DT 16.
- **EF 22. Add a tags column to the Status Catalogue?** Yes, with MD 4.
- **EF 14. Fill in `domain` and `tags` now?** Yes, before data entry.
- **EF 13. Add a criterion for each untested read and action?** Yes.
- **EF 17. Fix the registry's `counted_chance` range?** Yes, to `floor(counted_start / 1000 + sum p)`.
- **EF 19. Keep missing host files and back-references for the host sweeps?** Yes; settle the interface row with DT 8.

## What failed or did not run

- **No pass failed.** All 12 passes finished and wrote a log entry.
- **Passes 2 and 3 were not full fresh reviews.** Each was a cross-document re-check plus a full re-read and hand recompute. Pass 3 still found a new Defence blocker (CD 19), so more issues may turn up.
- **Harness (`tools/balance/autoplay.gd`):** no log records a run, so no fights or W prices were measured.
- **Defence scratch script (`cd_check.py`) and inline scripts:** did not run, because a permission prompt had no one to answer it. The numbers were worked by hand.
- **Not recomputed in Defence:** AC-CD-46's other-realm mirrors, "446 against top-end hits", and the other realms' typical-block shares. The stall and upkeep timings were also not re-derived in pass 3.
- **Modifier catalogue check (AC-MD-27):** the generator ran, but its output was compared with the GDD by eye; the scripted diff did not run.
- **Registry search was only complete for some GDDs:**
  - Modifiers searched all 278 names once, in pass 2, many by shared prefix.
  - Effects searched all names, exact forms only.
  - Damage Types searched 37 names.
  - Defence compared its own entries.
- **Specialist agents:** none ran (lean mode).
- **`production/session-logs/decision-log.md`:** Defence's autonomous choices are not there; they are in the decisions file.
- **`project.local.yaml`:** present while this summary was written. The driver should remove it when the run ends. If it is still there, delete it.
- **Edited besides the four GDDs:** their review logs, the `systems-index.md` status cells, the decisions file and `decision-log.md`.

## Overnight blockers

All 8 are resolved. The new blockers in the last column come from gaps in or next to those answers.

| GDD | Overnight blocker | Now | Still open nearby |
|---|---|---|---|
| Defence | Registry shield range | Resolved (registry reads uncapped) | CD 4: the stall check for uncapped shields cannot pass |
| Defence | Drain billing | Resolved as you answered | CD 3: shared block and a short pool |
| Damage Types | Mixed Soul hits | Resolved | — |
| Damage Types | Same-step conversions | Resolved | DT 1: order inside a step; DT 2: the modifier tier |
| Modifiers | Rule 8 targets | Resolved | MD 1: type scopes on whole-hit and whole-art stats |
| Modifiers | Typed-resistance price | Resolved (one stored price, 1.25) | — |
| Effects | Rule 5 reads | Resolved as named | EF 1: more starters read things not on the list |
| Effects | Rule 6 actions | Resolved as named | EF 2: more starters use actions not on the list |

## Next step

1. **You approve or change the decisions above**, blockers first. More unattended passes won't help until then.
2. **Apply the answers** to the four GDDs and the registry, then re-run `/design-review` on each in a fresh session.
3. **Pre-#43 edits:** D1 (move `ws`, `we` and the rest into Defence Formulas A), D2 (Item DB role tags), D3 (soul shield formula).
4. **Combat revision (#43)**, which also takes N3 (Tribulation main damage type) and the Head of Water Effect with its Combat E note.
5. **Meridian Map redesign.**

**Order to confirm:** the session checkpoint (`production/session-state/active.md`) records a proposal to do the tree redesign *before* #43,
which you hadn't objected to. This list follows the order in this run's brief, #43 first. Tell me if you want the tree first.
