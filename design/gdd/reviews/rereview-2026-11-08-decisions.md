# Re-review decisions — 2026-11-08 (daytime)

Unattended `/design-review` re-reviews after the user's answers to the overnight review. Nothing here has
been decided: each question has a recommendation for the user to accept or change.

## design/gdd/combat-defence.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; full fresh review). Log:
`design/gdd/reviews/combat-defence-review-log.md`. Systems index #21a updated: still Needs Revision.

**Overnight blockers:** both resolved.
- Registry `defence_shield` range: resolved. The registry now describes uncapped shields, matching rule 9 and Formulas B.
- Drain billing: resolved as answered (Formulas C, rule 8, AC-CD-60, registry `ward_payment`). Blocker 3 below is a
  gap the answer did not reach.

**Autonomous-path decisions** (logged in place of the skill's prompts):
- Systems-index update: took [A], Needs Revision, with this review's outcome in the status cell of row 21a.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the four blockers, then re-run `/design-review design/gdd/combat-defence.md` in a fresh session.

**How the numbers were checked:** by hand, because a scratch script's permission prompt had no one to answer it
(not run: `%TEMP%\cd_review\cd_check.py`, outside the repo). Recomputed: Formulas A–H examples, the ward catalogue's
ratios and limits, the block table, the fast-kit table, the thể tu ehp and the AC fixtures.
Not recomputed: AC-CD-46's other-realm mirrors and the "446 against top-end hits" figure, which need harness data.

### Blocking findings (not fixed)

1. **The soul shield has no formula.** Rule 9 calls a shield a pool; rule 6 and Soul-Guarding Lamp give a share
   ("soaking 50 %"). Rule 6 scales it by ward strength, so 50 % reaches 100 % at ws 100 (immune to soul hits) and
   250 % at ws 400. Combat rule 24 and E2 say soul hits ignore every ward.
   - Q: How does a soul shield work?
   - Recommended: as the Combat revision draft's D3 says: it takes `soul_shield_share × pct` off each pool loss after
     E2's `pct`, and its own bar is spent first. Add a cap on the share below 1, and let ws scale the bar, not the share.
2. **`ws`, `we`, `a_w` and `a_b` lose their home.** Rule 1 and Dependencies replace "all of Combat Formulas D", while
   OQ 2 says "the ward half". Formulas A sources ws from `defense_pct` only, but the anchor ws 30.8 needs D's gear
   term; `we`, `ward_floor`, `a_w` and `a_b` are defined only in D.
   - Q: Where do these definitions live once #43 removes Formulas D?
   - Recommended: move them into Defence Formulas A and leave a stub in Combat D (the draft's D1), then make rule 1,
     Dependencies and OQ 2 say the same thing.
3. **Drain billing has two cases left.** (a) `blk_w` is "the block points this ward's payload took", but block adds
   from flesh, gear and wards, and nothing says whose points a partly used block spends. (b) A short pool's unpaid
   share "leaks through", but it does not say whether that leak then meets block and shields, or what a short pool does
   to a drain-paid block.
   - Q: How are shared block and a short pool billed?
   - Recommended: (a) split the points taken by each source's share of B_hit. (b) Add the leak to a_j before block,
     so it meets block and shields like any damage; a drain-paid block's unpaid share is simply not taken. Add AC cases for both.
4. **AC-CD-59 cannot pass, and its remedy would not help.** FX-U's basic hit is 6.31. The kit's block is about
   4.95 points (rating 78.4: flesh 4.4, gear 24, tier 5 50), and its Iron Body resistance cuts the hit to about 4.2
   first, so every hit deals 0 and the side never falls. A shield cap does not change that: block stops the hit before
   shields are reached. Also, at we 400 Mountain Screen recharges 291 per second, so any attacker with gaps above
   `recharge_delay` is never tested.
   - Q: Which attacker should the shield-stall check use?
   - Recommended: the realm's typical attacker (FX-T offence) and a slow-hitter variant with gaps above 2 s. Keep the
     cap knobs as the first fix for a real stall, and allow `recharge_delay` or `shield_recharge` as a fix too.

### Recommended findings (not fixed)

5. **Cast ward wording.** Rule 8 says "Its duration lasts, or its shield holds"; Edge Cases say a cast ward stays up
   "until its duration ends or its shield breaks"; States keeps non-shield payloads up on a broken shield.
   - Q: Does a broken shield end a cast ward with other payloads?
   - Recommended: no. Only the shield is broken, and the duration ends the ward (matches States and rule 11).
6. **Shield states.** It is unstated whether a standing shield starts full, and what an unpaid upkeep ward's shield
   does while Down.
   - Q: What are the start and Down behaviours?
   - Recommended: starts full; while Down it keeps its value, does not soak and does not recharge.
7. **`b` = 0 in Formulas G.** A side with only reserved wards makes `x = Q_use / b` divide by 0.
   - Q: Define x for b = 0?
   - Recommended: yes, treat the wards as never falling, so ehp = P / λ_all.
8. **Rule 11's default-ward trap.** A status-only or soul-only ward counts as Up, so it switches off the default
   ward's 0.30 against every other hit. Clear Heart Ward and Soul-Guarding Lamp would cost a side its base protection.
   - Q: Should wards with no resistance, block or shield payload for that part suppress the default ward?
   - Recommended: no, they should not suppress it. If the current rule is intended, add a compile warning instead.
9. **a_b's range.** "0–1.0 at top end", but Output Range, AC-CD-30 and AC-CD-59 use 2.0.
   - Q: Is a_b 2.0 legal?
   - Recommended: state 1.0 as the top end for one piece and say how 2.0 is reached, or lower those cases to the true maximum.
10. **`a_w`'s meaning** (consistency N1, draft D2). A2 says "ward-role" defence; Combat D, Item DB and the 0.85
    anchor count all non-body defence.
    - Q: Which is it?
    - Recommended: all non-body defence, as the anchor assumes; update A2's wording with the D2 role-tag rename.
11. **No Ward flags.** effects.md OQ 3 and AC-EF-40 wait on "cannot slot wards" and "no default ward" here.
    - Q: Add both flags to rules 5 and 11?
    - Recommended: yes.
12. **Pending Modifier rows.** modifiers.md cites this GDD for typed block ("after the shared pool"), foe-scoped
    resistance and a body shield I op; no rule here defines them.
    - Q: Define them now or when those rows leave Pending?
    - Recommended: when they leave Pending, and note it in Open Questions now.
13. **Registry.** `defence_ehp`'s ">= H" contradicts the floor (P / 1.5), `default_resist`'s note says "general
    resistance", and `dot_pool_cap` is unregistered. Not edited: out of scope for this pass.
    - Q: Apply these three registry edits?
    - Recommended: yes.
14. **Tuning Knobs gaps.** `ward_resist_max`, σ max, `ward_block_max`, `ward_cap`, `hregen_cap`, α_m and `T_ref` are missing.
    - Q: Add them with safe ranges?
    - Recommended: yes, with no value changed.
15. **Cross-References gaps.** No row for effects.md or Modifier System rule 13, though rules 5, 10 and 16 cite them.
    - Q: Add both rows?
    - Recommended: yes.
16. **Back-references** are still missing in the #43 sweep's GDDs (carried).
    - Q: Keep them in the #43 sweep?
    - Recommended: yes, as already planned.
17. **Stall figure label.** Formulas E's "continuous model" note covers both figures, but 37.6 s recomputes to 37.4 s
    continuous (43.8 s holds). AC-CD-45's ±1.0 covers both.
    - Q: Reword once the harness has run?
    - Recommended: yes; no change until then.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to combat-defence.md (11)

1. Header status: records the same-day revision and this re-review's verdict.
2. Calibration and Formulas C example: drain rate 0.958 became 0.959 (1.64 / 1.308² = 0.9586).
3. Formulas A: R_all, R_type and R_x,other ranges "≥ −0.5" became "any; only the final r is floored" (AC-CD-09 uses a sum of −0.80).
4. Formulas A2 table: typical slow hit 22.61 became 22.62.
5. Formulas A2 and AC-CD-58: fast kit ratio ×1.27 became ×1.26 (exact 1.263 from D 24.75).
6. Formulas F: rejoined the V_w table row, which a line break had split.
7. Formulas G: ehp's lower bound "P" became "P / 1.5" (resistance floor).
8. Formulas H: Thousand-Layer Cloud ratio 0.661 became 0.662.
9. Formulas H: Golden Light Shield ratio 0.749 became 0.750.
10. Formulas I: block price "0.4 / point" became "0.4 / rating point" (Formulas H's Iron Body value and the Modifier System's unit).
11. Cross-References: Damage Types row now includes rule 2, which rule 3 cites.

## design/gdd/combat-damage-types.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; full fresh review). Log:
`design/gdd/reviews/combat-damage-types-review-log.md`. Systems index #21b updated: still Needs Revision.

**Overnight blockers:** both resolved.
- Mixed Soul hits: resolved (rule 1, Edge Cases, AC-DT-22, AC-DT-25, registry `damage_parts`).
- Same-step conversions: resolved (rule 6, AC-DT-16, registry). Formulas A's leftover sequential update was a safe fix below.
  Blocker 1 below is a gap the answer did not reach.

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Systems-index update: took [A], Needs Revision, with this review's outcome in the status cell of row 21b.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the three blockers, then re-run `/design-review design/gdd/combat-damage-types.md` in a fresh session.

**How the numbers were checked:** by hand. Recomputed: both Formulas A totals, the thể tu example and AC-DT-19, AC-DT-16's
scaling, the 3 × and 4 × part bounds, and the type colours' nearest 256-colour codes. All hold except the colours (item 6).

### Blocking findings (not fixed)

1. **Order inside a step.** The fixed order names only tiers (art, Effects, modifiers). With three conversions in one
   tier, nothing says which two apply (AC-DT-21's "first two"), or whether scaling comes before the limit. A build
   can carry several conversion Effects (Flame-Tempered Edge, Rot Seeps In), so the result would depend on how the code happens to order them.
   - Q: How are conversions ordered inside one tier, and does scaling run before or after the limit of 2?
   - Recommended: order by a stable compile order (slot order, then record id). Apply the limit first, then scale only
     the kept conversions that apply to that part. Add this to rule 6 and an AC case.
2. **Modifier conversions cannot exist.** Rule 6, Formulas A, the Tuning Knobs, AC-DT-26 and the registry's `damage_parts`
   list modifiers as the third tier. modifiers.md ("Conversion share: this is an Effect") and the Modifier vs Effect
   decision make every conversion an Effect, so the tier has no source and AC-DT-26's modifier conversion cannot be built.
   Your step answer named this tier, so the two decisions collide.
   - Q: Can a modifier carry a conversion?
   - Recommended: no. Steps are the art's own conversions, then Effects. Change rule 6, Formulas A, the knob, AC-DT-26
     and the registry to match.
3. **Qi Disruption does not fit the tick path.** Rule 4 sends "any tick" through resistance and shields to health.
   effects.md's Qi Disruption is a Force tick that hits linh lực, not health, up to 5 % of `qi_max` a pulse. By rule 7's
   defaults a body shield would soak it, and nothing says what soaking a qi burn means.
   - Q: What path does a tick on linh lực follow?
   - Recommended: Force resistance → linh lực, passing every shield. Add a rule 4 row and an AC case, and state it on the
     effects.md status row.

### Recommended findings (not fixed)

4. **"Curses' damage."** Rule 1 lists it as a Chaos source; Combat rule 8 and Defence rule 1 say curses never deal damage.
   - Q: Remove "curses' damage" from the Chaos row?
   - Recommended: yes.
5. **Penetration scope.** Rule 6 and Edge Cases say penetration reads only the final type. Defence rule 4 and the
   Modifier System also allow penetration scoped by another tag, such as an element.
   - Q: Does the "final type only" limit apply just among damage types?
   - Recommended: yes. Say "of a part's damage types", so element and form scopes still apply.
6. **Lightning and Light look the same.** #FFE14D and #F5C542 are close hues and both round to 256-colour code 221, so
   AC-DT-22's terminal check cannot tell them apart. The Tuning Knobs require the 8 to stay distinct.
   - Q: Change one colour?
   - Recommended: yes. Move Light to a pale near-white gold that rounds to another code, and add a distinct-codes check to AC-DT-22.
7. **Free hits have no type rule.** Only arts and statuses must name a type (Edge Cases, AC-DT-20, AC-DT-24). Echo's free hit
   has "same tags" and Shattering Ward's is "Free Force hit"; parts and conversion are unstated.
   - Q: What sets a free hit's parts?
   - Recommended: its record names a type, or copies its source art's authored parts, then converts like any hit. Compile
     rejects it otherwise; extend AC-DT-20 and AC-DT-24.
8. **Interface rows.** The Effects row disagrees with effects.md on direction and owner. Combat is still named owner of
   conversion order, though rule 6 now defines the steps.
   - Q: Who owns these?
   - Recommended: this GDD owns the conversion rules and steps, and Effects own the conversion records (direction in). Combat cites rule 6 after #43.
9. **AC gaps.** Nothing tests a same-step chain (Physical → Fire with Fire → Lightning moves no new Fire to Lightning) or a
   later step reading what an earlier step left.
   - Q: Add both cases?
   - Recommended: yes.
10. **Cross-References gaps.** No rows for modifiers.md or effects.md, though rules 2, 5, 6, 8 and the Tuning Knobs cite them.
    - Q: Add both rows?
    - Recommended: yes.
11. **OQ 4.** Its remainder is whether Light gets a tick; effects.md already says it does not.
    - Q: Close OQ 4?
    - Recommended: yes, once effects.md passes review.
12. **OQ 1 is due.** "Chaos" the damage type and "Chaos" the root were to be settled before content is authored; Chaos
    content now exists in effects.md and modifiers.md.
    - Q: Keep both names, or rename one?
    - Recommended: decide now. My suggestion is to keep the damage type "Chaos" and call the root "Primordial Chaos (Hỗn Độn)" in player text.
13. **Systems-index row 21b.** The dependency cell still says "resistance by kind and element". Only the status cell was in scope.
    - Q: Rewrite it to "resistance by final damage type"?
    - Recommended: yes.
14. **Back-references** are missing in combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md (carried).
    - Q: Keep them in the #43 sweep?
    - Recommended: yes, as already planned.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it). Rule 5's "rarer sources" reads
softer than "rare sources only" in the Tuning Knobs and OQ 3; settle it with OQ 3's Item DB rule.

### Safe fixes applied to combat-damage-types.md (9)

1. Header: status records the same-day revision and this re-review; Last Updated and Last Verified updated.
2. Rule 6: a zero-move conversion's target is checked against the history of source-type parts, not "every part" (Formulas A; AC-DT-17).
3. Formulas A: same-step update is now `s_j · (1 − Σ c_k)` at the step's end, which AC-DT-16's 0 left requires.
4. Formulas A example: the Lightning chain now names the later step its 0.2 needs.
5. AC-DT-14: the same later step.
6. States: conversion happens after the evade roll and before resistance, not "before defence" (Combat Formulas C; Defence rule 1).
7. Cross-References: rule 4 row adds Defence rule 13 (evade).
8. Cross-References: rule 5 row adds Defence rule 4 (penetration), which rule 5 cites.
9. Cross-References: the Soul row now reads Rules 1, 4 ↔ Combat rule 24, Formulas E2, as those rules cite.

## design/gdd/modifiers.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; full fresh review). Log:
`design/gdd/reviews/modifiers-review-log.md`. Systems index #40 updated: still Needs Revision.

**Overnight blockers:** both resolved.
- Rule 8 targets: resolved. Heal, reservation, outgoing status, basic attack and outgoing soul hit are all defined.
- Typed-resistance price: resolved. One stored price of 1.25 in Formulas A, the Stat List, the Rare table and the generator.
  The catalogue's +1.2 pp at small holds.

The overnight recommendations are resolved too, except back-references (item 9 below) and Player Fantasy (advisory).

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Systems-index update: took [A], Needs Revision, with this review's outcome in the status cell of row 40.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the two blockers, then re-run `/design-review design/gdd/modifiers.md` in a fresh session.

**How the numbers were checked:**
- By hand: Formulas B–D and realm drift, the examples, AC-MD-04/05/06/16–20, the lifespan sizes, a sample of catalogue
  values, and the defence prices against Combat Defence Formulas I.
- Catalogue (AC-MD-27): the generator ran and its output, including the 224 count, was compared with the GDD **by eye**.
  Scripted diffs needed a permission prompt that no one could answer.
- AC-MD-28: all `labels` keys were checked by hand against the Stat List and "Keys that move to Effects".
- Registry: **not** the skill's full whole-document search of all 278 entry names (same permission limit). I searched
  23 modifier, cap and price names (23 matching lines) and read the whole GDD. No conflict found.

### Blocking findings (not fixed)

1. **Type scopes on stats that apply to a whole hit or a whole art.** Rule 8 matches crit against "the hit part's tags", but
   Combat rolls crit once per hit, even on a two-part hit (Formulas C, AC-CB-22). So nothing says whether +12 pp Fire crit
   chance counts on a hit that is 60 % Physical and 40 % Fire. Art speed and art cost have the same gap: an art can have
   several types, and conversion happens later. Seven crit modifiers and four art modifiers (speed and cost, Physical and Force) are Designed in the catalogue.
   - Q: How does a damage-type scope work on crit chance, art speed and art cost?
   - Recommended: crit counts the scope if the hit's largest part carries that type or has it in its history (ties go to
     the first type in Damage Types' order, as Effects item 5 proposed for Sundered). Art speed and cost read the art's authored
     parts: any authored part matches, and conversion does not change it. Add an AC case for each.
2. **The resistance row [type + family tag], e.g. [fire, over_time].** The row is Designed in the catalogue and in Defence
   Formulas I at ×2.0, but rule 8 says resistance matches the final damage type only, and Defence rule 3 sums only all
   resistance plus the final type. Rule 8's validation would reject the row. Nothing defines how a part would match `over_time`.
   - Q: Keep resistance scoped by type plus a mode, or remove it?
   - Recommended: remove it here, in Defence Formulas I and in the generator. Status resistance and status duration on you
     already answer ticks, and "one resistance per part" stays simple. Foe pairs stay Pending under their own rule.

### Recommended findings (not fixed)

3. **Effect payloads and W.** Rule 12 and the Summary say every value is priced in W, but Effects rules 3–4 make payload
   values the designer's, with no W at all. Rule 13's source kinds also omit Effects.
   - Q: Are Effect payloads exempt from rule 12, and may they carry rare modifiers?
   - Recommended: exempt them (stat, op and grid still validate). A rare modifier is allowed only when the Effect's host is on
     rule 13's list, such as a keystone or a named item.
4. **Tag vocabulary gaps.** Rule 11 and the Pending rows use status tags and [body_shield], but rule 9 has no family for them.
   Effects' status tags do not match: Burn carries `fire`, Frostbite `cold`, and Qi Disruption has no `qi_burn`.
   - Q: Who owns the status tags, and what are they?
   - Recommended: add a "status" family owned by the Effects Status Catalogue, one tag per status, and rename `qi_burn` to
     match Qi Disruption. Treat [body_shield] as a heal-source tag owned by Defence.
5. **No floor on cheap lower-is-better stats.** Two notables of formation upkeep or talisman ink (−53.3 % each) make the cost
   free, and rule 5 floors at 0. Status duration on you can reach −100 % with three notables at −40 %. Rule 7 leaves caps to
   the owners, but only the sell price names a guard.
   - Q: Must an owner name a floor before these rows leave Pending?
   - Recommended: yes, for all of them. Formations, Talismans, Combat and Market each set one. Prices are unchanged.
6. **Two prices on one key.** `body_shield_pct` has F 1.0 and I 0.6; `attack_pct` shares its key across scopes and
   `damage_more` has points. AC-MD-21 expects one `modifier_prices` entry per row.
   - Q: Should `modifier_prices` be keyed by key and op?
   - Recommended: yes, and say so in Formulas A and AC-MD-21.
7. **AC gaps.** No AC tests the targets added this morning (heal, reservation, outgoing status, basic, soul) or the rare-by-row rule
   (Chaos resistance or a cap raise on a notable).
   - Q: Add cases to AC-MD-10 and AC-MD-23?
   - Recommended: yes.
8. **Missing dependency rows.** Market, Time & Turn, Realms, Spirit Herbs, Sects and Travel own Stat List rows, but are not in
   Dependencies or Interactions.
   - Q: Add them?
   - Recommended: yes, as soft dependencies that read this system.
9. **Back-references** are still missing in the reader GDDs (carried from overnight).
   - Q: Keep them in the #43 and Meridian Map sweeps?
   - Recommended: yes, as already planned.
10. **The rounding lint flags catalogue rows.** Breakthrough at small loses 16.7 %, typed block broad at small 20 %, and
    density at small floors to 0. The 15 % threshold is also not in Tuning Knobs.
    - Q: Accept these as known exceptions?
    - Recommended: yes. List them in Formulas E and add the threshold as a knob; values unchanged.
11. **Damage Types rule 5 wording.** It calls rare Chaos resistance "a content guideline, not a cap", while rule 13 and your
    OQ 6 answer enforce it in validation. Rule 6 there also lists modifier conversions (that GDD's blocker 2).
    - Q: Update Damage Types rule 5 to "rare by its row (Modifier System rule 13)"?
    - Recommended: yes, with that GDD's other answers.
12. **Defence Open Question 1 can close.** It waits on this re-review. All its defence prices match Formulas I, and Defence's
    Dependencies row should now cite rule 7 too.
    - Q: Close it?
    - Recommended: yes.
13. **Registry price table** (OQ 8, carried). `stat_power_weights` still lacks the full table, including `resist_pct` 1.25 and the
    variety rows. `modifier_value`'s range also stops at 215 units, not the 500 at 60 W. Not edited: out of scope.
    - Q: Apply these registry edits?
    - Recommended: yes, once the blockers are answered.
14. **Realm drift default** (OQ 1) is still "proposed, not yet a user decision".
    - Q: No deflator until the bot has measured the drift?
    - Recommended: yes.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to modifiers.md (21)

Please check 14 and 20 first. They are the two that add the most text, though neither changes a value.

1. Header: status records the revision and this re-review; Last Verified updated.
2. Rule 1: `layer` allows L5 in an Effect's payload (rule 6, Stat List, AC-EF-44).
3. Edge Cases: the `more` layer rejection has the same L5 exception.
4. AC-MD-06: rejects L5 only on a source that is not an Effect; it contradicted rule 6.
5. Rule 7: names the resistance and health regeneration caps, as Edge Cases and AC-MD-07 do.
6. Rule 8, outgoing hit: a type scope on penetration reads the final type only (Stat List, Edge Cases, Damage Types rule 6).
7. Rule 8, ward: names recharge delay and cast ward duration as unscoped (Stat List, catalogue).
8. Rule 8, status: includes status duration on you, whose Stat List target is incoming status.
9. Rule 8: the list of scope families now includes artifact role, foe and activity, which its own bullets use.
10. Rule 9: re-indented the foe and activity rows, which broke the list-nested table.
11. Rule 10: a Pending stat "still needs a key or rule", since several Pending stats now have keys.
12. AC-MD-13: same stale "no key" wording.
13. Rule 11: names shield recharge delay and cast ward duration as implied family, as the catalogue and generator have them.
14. Formulas A: added the 10 Stat List prices it lacked, which AC-MD-21 requires. Values are from the Stat List; the G mark is from
    `design/overnight-2026-11-08/modifier-variety.md` ("every value here is a guess"). Typed block and foe rows reuse existing prices.
15. Formulas A: block's unit is "rating point" (Stat List, Defence Formulas I).
16. Formulas C: price range starts at 0.15, not 0.3. The output range still holds, since the 0.15 stats are unscoped (172 units in the tree, 400 at 60 W).
17. Cross-References: rule 7 row adds combat-defence.md Formulas A, E.
18. Cross-References: rule 8 row adds Defence rule 7, which the Stat List cites.
19. Cross-References: new row, rule 13 ↔ Damage Types rule 5.
20. Open Questions, OQ 4: lists the Pending variety rows and their owners, from the Stat List.
21. Cross-References: effects.md row now reads rules 1, 6, 9, 15, 16, matching what effects.md cites.

## design/gdd/effects.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; full fresh review). Log:
`design/gdd/reviews/effects-review-log.md`. Systems index #41 updated: still Needs Revision.

**Overnight blockers:** both resolved as named, but the same kind of gap remains (blockers 1 and 2 below).
- Reads: ward payments, regeneration clip, `dot_pulse_cap` clip and stack count are all on rule 5's list now.
- Actions: every action the overnight review named is on rule 6's list now.
- The overnight recommendations you answered are all in the GDD: read times, Blood Casting and Withering, Sundered's type,
  the Corpse Rot lint, token costs, rule 7, the capability count, AC-EF-10, `counted_start` and the Tuning Knobs. The
  back-references are still open, as you planned (item 19).

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Systems-index update: took [A], Needs Revision, with this review's outcome in the status cell of row 41.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the three blockers, then re-run `/design-review design/gdd/effects.md` in a fresh session.

**How the numbers were checked:** by hand. Recomputed: Formulas A's example and AC-EF-30, Formulas B's upkeep and regeneration,
and AC-EF-05, 07, 24, 27, 36, 37, 38, 41 and 43. All hold. Compared with the registry and sibling GDDs: `resist_floor`,
`heal_pulse_cap`, `dot_pulse_cap`, `cooldown_min`, `soul_lockout`, `c_trig`, `c_comp_cap` and the Stat List keys. All match.
This was a search of the keys this GDD uses, not of all 278 registry names. AC-EF-12 and AC-EF-41's crit caps (0.50, 0.35)
were not re-traced to Combat today; the overnight passes checked them.

### Blocking findings (not fixed)

1. **More reads are missing from rule 5's closed list.** Under the Edge Cases and AC-EF-05, these starters are rejected: main
   root's element (Elemental Fist), formation level (Formation Within a Formation), own stage (Great Essence-Draining Art),
   a failed brew (Strange Pill Reborn), a death in an event (Soul Leaves the Body), and the Down-step events (Unyielding
   Breath, Final Clause). Called Blow reads crit chance live, but rule 5 says sheet reads are always compile.
   - Q: Add these reads to the list?
   - Recommended: yes. Add them as sheet reads (root element, formation level, stage), events (Down step, failed brew, death
     in an event), and "the chance about to be rolled, live" for counted chance.
2. **More actions are missing from rule 6's closed list.** Spillover burns linh lực and no action does that. Soul Leaves the
   Body survives a death, which "change a life output" only arguably covers. No action backs what `closes` forbids: No Ward's
   ward ban, Paid in Advance's slot limit, Beast Soul Union's companion limit, Water Table's regeneration stop.
   - Q: Add "burn linh lực" and "forbid a slot, a companion or a regeneration"? Does surviving a death count as a life output?
   - Recommended: yes to all three. Add "burn linh lực (inside the 5 % cap)" and "enforce a closing rule at compile", and name
     "an event's outcome" under the life-output action.
3. **The path of a linh lực tick is undefined.** Qi Disruption and Spillover hit linh lực, and nothing says whether resistance or
   shields apply. This is the same question as combat-damage-types.md blocker 3, so one answer closes both.
   - Q: What path does a tick on linh lực follow?
   - Recommended: Force resistance → linh lực, passing every shield. State it on the Qi Disruption row and in AC-EF-26. For
     Spillover, the clipped amount burns with no second resistance step.

### Recommended findings (not fixed)

4. **AC-EF-16 rejects shipped curses.** It requires a strength; Sealed Meridian, Silence and Stagnation have none.
   - Q: Is strength required only where the status has a number?
   - Recommended: yes. Change rule 9 and AC-EF-16 to match.
5. **Sundered with no hit.** It reads "the applying hit", but a talisman, the ground or a trigger can apply a status, and an
   all-Soul hit has no resistance Sundered can lower.
   - Q: What type does Sundered lower then?
   - Recommended: the applying record must name a type, and an all-Soul hit cannot apply Sundered (Slackened Soul is its Soul counterpart).
6. **"Costs no linh lực" is built on a refund.** First Move and Paid in Advance still need the cost in the pool to fire, and drain
   wards see the dip.
   - Q: Do they waive the cost, or pay and refund it?
   - Recommended: waive it. The rule text promises no cost. Add "waive an art's cost" to rule 6.
7. **Last acts: order and overkill.** Rule 11 gives slot order within a side, but no order between sides or for their draws. It also
   does not say a Down side keeps its overkill for the follow-up check, so a last act that downs the enemy might win the fight.
   - Q: Can a last act win, and which side goes first?
   - Recommended: requesting side first (Combat rule 10). The overkill is kept, so a last act can win only if the enemy's overkill
     share is larger. Add a case to AC-EF-28.
8. **Great Essence-Draining Art's kind.** It is a Trigger with a `closes` value. Rule 1 keeps `closes` to keystones and enablers, and
   rule 13 lets capabilities become only keystones or rule changes.
   - Q: Keep it as a Trigger?
   - Recommended: yes. Move "+2 heart demon reported" into its payload, and let rule 13 say "or another kind".
9. **Rule 10's list is short.** It omits cultivation base and stage, which Great Essence-Draining Art and Soul Leaves the Body report.
   - Q: Add both?
   - Recommended: yes.
10. **Rounding p.** Formulas A holds p in whole thousandths but gives no rule for 0.2875.
    - Q: How does p round?
    - Recommended: to the nearest thousandth, half up, matching Combat's time rounding. The fraction is lost, so the rate stays within 0.0005.
11. **Tie-breaks.** Final Clause's longest cooldown, Rime Lock's least time left and Soul Wound's next ready art can all tie.
    - Q: Use slot order for every such tie?
    - Recommended: yes, as one sentence in rule 7.
12. **Stacking "None".** Sealed Meridian and Silence use a value rule 9 doesn't list, and a recast while one runs is undefined.
    - Q: What does a recast do while it runs?
    - Recommended: nothing. Add "none: a recast does nothing while it runs" to rule 9.
13. **AC gaps.** Nothing tests most of today's additions: the cap clip and ward payment events, multiply a share, raise a cap, change a
    life output, add a slot, skip a roll.
    - Q: Add a criterion for each?
    - Recommended: yes, using Spillover, Water Table, Beast Soul Union, Formation Within a Formation, Strange Pill Reborn, Talisman Sleeve and Measured Stroke.
14. **`domain` and `tags`.** No starter gives them, though rule 1 and AC-EF-45 require them.
    - Q: Fill them in now, or at implementation?
    - Recommended: now, as a column or a short list, before data entry starts.
15. **Two ways to pay in health.** Blood Casting can put you Down; Combat's `body_cost_share` cannot take health below 1.
    - Q: Keep both rules?
    - Recommended: yes. An authored art stays safe and Blood Casting is the dangerous enabler. Record the difference in the #43 revision.
16. **No Ward's flags (carried).** AC-EF-40 and OQ 3 still wait on "cannot slot wards" and "no default ward" in combat-defence.md.
    - Q: Add both when Defence is revised?
    - Recommended: yes. Same answer as combat-defence.md item 11.
17. **Registry `counted_chance`.** Its output range reads `floor(counted_start + sum p)`, which is wrong by a factor of 1,000 now that
    Formulas A divides by 1000. The registry was out of scope.
    - Q: Update the registry?
    - Recommended: yes, to `floor(counted_start / 1000 + sum p)`.
18. **Seal of Full Payment with a standing status.** "Linh lực pays for nothing" leaves Corpse Rot's upkeep undefined.
    - Q: Can stones pay upkeep?
    - Recommended: no. Linh lực still pays it, so a Seal build can't hold a standing status unless its linh lực regenerates.
19. **Dependencies (carried).** Talismans, Formations, Alchemy, Spirit Beasts, Event Engine and NPC Builds have no GDD file, back-references
    remain one-way, and the Combat Damage Types interface row disagrees on direction and owner.
    - Q: Keep these for the host sweeps?
    - Recommended: yes. Settle the interface row with combat-damage-types.md item 8.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to effects.md (13)

1. Header: status records the same-day revision and this re-review; Last Verified updated.
2. Beneath Notice: read time is now instant start, as rule 5 requires of a conditional. The realm gap doesn't change in a fight, so the result is the same.
3. Blood Casting: "cannot be refused" replaced with rule 6's wording, since rule 6 and AC-EF-07 let a refusal save the side.
4. Life table: separator row had 8 columns for a 9-column table.
5. Formulas A: `meter_0` and the output range now divide `counted_start` by 1000, since it is stored in per mille.
6. Formulas A variables: `p` and `meter` types now say "held as per-mille int", as the Output Range states.
7. Cross-References: modifiers.md row adds rule 8, which rule 6 cites.
8. Cross-References: combat.md row now covers rules 5–8 and 11, adding rule 6 and Formulas A2, C, I and J, as those rules cite.
9. Cross-References: combat-defence.md row adds Formulas E, which the Formulas intro cites.
10. Cross-References: combat-damage-types.md row adds rule 1, which rule 9 and the Status Catalogue cite.
11. Cross-References: decisions row now reads rules 9–12, because decision 11 sits in rule 9.
12. AC-EF-01: fixture is now Steady Breath, because Flowing Water's event read has no read time to remove; it also notes `closes` is for keystones and enablers only. Intent unchanged.
13. OQ 8: marked done; every entity it names is in the registry.

## design/gdd/combat-defence.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/combat-defence-review-log.md`.
Systems index #21a updated: still Needs Revision, with this pass noted.

**Method:** the GDD, registry and skill were byte-identical to pass 1, and only `combat-damage-types.md`, `modifiers.md`
and `effects.md` had changed, so the skill's path is a cross-document re-check that keeps the prior verdict unless a
conflict appears. None did. The whole GDD was also re-read and its numbers recomputed by hand. An inline script needed a
permission prompt no one could answer, so it did not run. Not recomputed (needs realm or harness data): AC-CD-46's
other-realm mirrors, "446 against top-end hits", and the other realms' typical-block shares.

**Autonomous-path decisions** (logged in place of the skill's prompts):
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/combat-defence.md`.

### Blocking findings (not fixed; carried from pass 1, full detail there)

1. **Soul shield has no formula.** Q: How does a soul shield work? Recommended: it takes `soul_shield_share × pct` off each pool loss after E2's `pct`, its bar is spent first, the share is capped below 1, and ws scales the bar, not the share.
2. **`ws`, `we`, `a_w`, `a_b` lose their home.** Q: Where do they live once #43 removes Formulas D? Recommended: move them into Defence Formulas A with a stub in Combat D, and make rule 1, Dependencies and OQ 2 agree.
3. **Drain billing has two cases left.** Q: How are shared block and a short pool billed? Recommended: split points taken by each source's share of B_hit; add the leak to a_j before block; a drain-paid block's unpaid share is not taken; add AC cases.
4. **AC-CD-59 cannot pass.** Q: Which attacker should the shield-stall check use? Recommended: the realm's typical attacker plus a slow hitter with gaps above 2 s; keep cap knobs as the first fix and allow `recharge_delay` or `shield_recharge` as a fix too.

### Recommended findings (not fixed)

5. **Cast ward with a broken shield.** Also covers States' Up row, "or shield broken". Q: Does a broken shield end a cast ward with other payloads? Recommended: no; only its duration ends the ward.
6. **Shield states.** Q: What does a standing shield start at, and what does it do while its ward is Down? Recommended: starts full; while Down it keeps its value, does not soak and does not recharge.
7. **`b` = 0 in Formulas G.** Q: Define x for b = 0? Recommended: yes, the wards never fall, so ehp = P / λ_all.
8. **Rule 11's default-ward trap.** Q: Should wards with no resistance, block or shield payload for a part suppress the default ward? Recommended: no.
9. **a_b's range.** Q: Is a_b 2.0 legal? Recommended: state 1.0 as one piece's top end and say how 2.0 is reached, or lower those cases.
10. **`a_w`'s meaning.** Q: Ward-role defence or all non-body defence? Recommended: all non-body, as the 0.85 anchor assumes.
11. **No Ward flags.** Q: Add "cannot slot wards" and "no default ward" to rules 5 and 11? Recommended: yes.
12. **Pending Modifier rows.** Now also recharge delay, cast ward duration and the [body_shield] scope (modifiers.md OQ 4). That row also says a cast ward's duration stays below its cooldown, which this GDD does not state. Q: Define them now or when they leave Pending? Recommended: when they leave Pending, noted in Open Questions now, and decide the duration limit then.
13. **Registry.** Q: Apply the `defence_ehp` range, `default_resist` note and `dot_pool_cap` edits? Recommended: yes.
14. **Tuning Knobs gaps.** Q: Add the seven missing knobs with safe ranges? Recommended: yes, no value changed.
15. **Cross-References gaps.** Q: Add rows for effects.md and Modifier System rule 13? Recommended: yes.
16. **Back-references.** Q: Keep them in the #43 sweep? Recommended: yes.
17. **Stall figure label.** Q: Reword the "continuous model" note after the harness runs? Recommended: yes; no change until then.
18. **New: artifact defence on body gear.** modifiers.md's price row says "about 0.35 on body gear", while Formulas B and I here raised body gear to parity with ward gear (0.648 W per defence point, AC-CD-57). The two may use different bases; this was not verified. Q: Is that note stale? Recommended: recheck it at the Modifier revision and, if stale, restate the row after the raised mapping (modifiers.md, so not edited here).

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to combat-defence.md (7)

1. Header: status now reads "two passes", and Last Verified is 2026-11-08.
2. Rule 1: "Offence is resolved first" contradicted its own "evade before anything else" and Combat Formulas C's order; it now says evade is rolled first, then conversion, layers, crit and suppression.
3. Calibration: "becomes weaker against Force" contradicted Formulas G (360.8 became 368.5); it now says the thể tu stays weaker against Force and is weakest against Chaos, with G's figures.
4. Formulas D: the +2-slot example's +81 % gives 157.47, below the 157.5 step; now +82 % (158.3).
5. Formulas F and AC-CD-40: Golden Bell's C of 193.4 became 193.5 (8 × 0.14 × 172.74 = 193.47; the ratio is unchanged).
6. Visual/Audio: "the ward's element colour" became the final damage type's colour (rule 3: elements never enter resistance; Combat Damage Types owns hit-number colours).
7. Dependencies: the Modifier System row now lists rule 7, which modifiers.md's Cross-References cite since its pass 1.

## design/gdd/combat-damage-types.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/combat-damage-types-review-log.md`.
Systems index #21b updated: still Needs Revision, with this pass noted.

**Method:** the GDD, registry and skill were byte-identical to pass 1, and only `combat-defence.md`, `modifiers.md` and
`effects.md` had changed, so the skill's path is a cross-document re-check that keeps the prior verdict unless a conflict
appears. None did. The whole GDD was also re-read, and its worked examples and AC numbers were recomputed by hand; they hold.
The registry search covered the combat, defence and modifier entries only: a search over all 278 names needed a permission
prompt no one could answer. The entries left out cover other systems.

**Autonomous-path decisions** (logged in place of the skill's prompts):
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/combat-damage-types.md` in a fresh session.

### Blocking findings (not fixed; carried from pass 1, full detail there)

1. **Order inside a step.** Q: How are conversions ordered inside one tier, and does scaling run before or after the limit of 2? Recommended: stable compile order (slot order, then record id); apply the limit first, then scale only the kept conversions; add it to rule 6 and an AC case.
2. **Modifier conversions cannot exist.** Q: Can a modifier carry a conversion? Recommended: no; steps are the art's own conversions, then Effects; change rule 6, Formulas A, the knob, AC-DT-26 and the registry to match.
3. **Qi Disruption does not fit the tick path.** Q: What path does a tick on linh lực follow? Recommended: Force resistance → linh lực, passing every shield; add a rule 4 row and an AC case, and state it on the effects.md status row.

### Recommended findings (not fixed)

4. **"Curses' damage."** Q: Remove it from the Chaos row, since curses never deal damage? Recommended: yes.
5. **Penetration scope.** Q: Does "final type only" apply just among damage types? Recommended: yes; reuse Defence Formulas A's wording, "a type scope matches the final type only", so element and form scopes still apply.
6. **Lightning and Light look the same.** Q: Change one colour? Recommended: yes; move Light to a pale near-white gold on another 256-colour code, and add a distinct-codes check to AC-DT-22.
7. **Free hits have no type rule.** Q: What sets a free hit's parts? Recommended: its record names a type or copies its source art's authored parts, then converts like any hit; compile rejects it otherwise; extend AC-DT-20 and AC-DT-24.
8. **Interface rows.** Q: Who owns the conversion rules and records? Recommended: this GDD owns the rules and steps, Effects own the records (direction in), and Combat cites rule 6 after #43.
9. **AC gaps.** Q: Add a same-step chain case and a later-step case? Recommended: yes.
10. **Cross-References gaps.** Q: Add rows for modifiers.md and effects.md? Recommended: yes.
11. **OQ 4.** Q: Close it, since effects.md gives Light no tick? Recommended: yes, once effects.md passes review.
12. **OQ 1 is due.** Q: Keep both "Chaos" names, or rename one? Recommended: keep the damage type "Chaos" and call the root "Primordial Chaos (Hỗn Độn)" in player text.
13. **Systems-index row 21b.** Q: Rewrite the dependency cell to "resistance by final damage type"? Recommended: yes.
14. **Back-references** in combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md. Q: Keep them in the #43 sweep? Recommended: yes.
15. **New: a part at share 0.** A 100 % conversion leaves its source part at 0. If the part survives, a later conversion from that type "moves" 0 yet could count toward the 2, and Combat Formulas C's at-least-1 floor could deal 1 from nothing. Q: Is a part at share 0 removed? Recommended: yes, at the end of its step, so it spawns nothing, counts for nothing and deals nothing; add an AC case.
16. **New: changing a status's type.** Rule 6 says changing a tick's type "takes an Effect", but effects.md's action table lists no such action. Q: Add the action, or drop the sentence? Recommended: drop the sentence until an Effect needs it, since a different status record can already carry another type.
17. **New: the order of the types.** effects.md's Sundered breaks ties by "Combat Damage Types' order", but this GDD never calls rule 1's table a fixed order. Q: Declare it? Recommended: yes, one line in rule 1: the table's order is the fixed order.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it). Rule 5's "rarer sources" reads
softer than "rare sources only"; settle it with OQ 3's Item DB rule. A conversion from a type to itself passes Formulas A's test (reject it at
compile when rule 6 is next revised). Edge Cases' "modified to mix Soul" cannot be caught at compile if the change happens at the hit, and no such
Effect exists today.

### Safe fixes applied to combat-damage-types.md (2)

1. Header: status now reads "lean, two passes".
2. Cross-References: the defence row now also cites this GDD's rule 7 and Formulas A, and Defence Formulas A2, which the Formulas note names.

## design/gdd/modifiers.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/modifiers-review-log.md`.
Systems index #40 updated: still Needs Revision, with this pass noted.

**Method:** the GDD, registry, skill, generator and `combat.md` were byte-identical to pass 1, and only `effects.md`,
`combat-defence.md` and `combat-damage-types.md` had changed, so the skill's path is a cross-document re-check that keeps the
prior verdict unless a blocking conflict appears. None did; the re-check added one non-blocking finding (item 15). The whole GDD was also re-read.
- By hand: every catalogue row against Formulas A–C, Formulas B–D, realm drift, the examples and the numeric ACs. All hold.
- Catalogue (AC-MD-27): the generator ran and its output, including the 224 count, was compared with the GDD **by eye**. A scripted diff needed a permission prompt no one could answer.
- Registry: all 278 entry names were searched this time (74 hits on 17 terms; many long names were searched by a shared prefix), and the caps and grades among them were checked. No conflict. `body_guard` stays active in the registry because Combat owns it until #43.

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Freshness path: took the cross-document re-check, plus a full re-read.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/modifiers.md` in a fresh session.

### Blocking findings (not fixed; carried from pass 1, full detail there)

1. **Type scopes on whole-hit and whole-art stats.** Q: How does a damage-type scope work on crit chance, art speed and art cost? Recommended: crit counts the scope if the hit's largest part carries that type or has it in its history (ties go to the first type in Damage Types' order); art speed and cost read the art's authored parts, unchanged by conversion; add an AC case for each.
2. **The resistance row [type + family tag].** Q: Keep resistance scoped by type plus a mode, or remove it? Recommended: remove it here, in Defence Formulas I and in the generator; foe pairs stay Pending under their own rule.

### Recommended findings (not fixed)

3. **Effect payloads and W.** Q: Are Effect payloads exempt from rule 12, and may they carry rare modifiers? Recommended: exempt them (stat, op and grid still validate); a rare modifier only when the Effect's host is on rule 13's list.
4. **Tag vocabulary gaps.** Q: Who owns the status tags, and what are they? Recommended: a "status" family owned by the Effects Status Catalogue, one tag per status; rename `qi_burn` to match Qi Disruption; [body_shield] is a heal-source tag owned by Defence.
5. **No floor on cheap lower-is-better stats.** Q: Must an owner name a floor before these rows leave Pending? Recommended: yes, for all of them; prices unchanged.
6. **Two prices on one key.** Q: Should `modifier_prices` be keyed by key and op? Recommended: yes, and say so in Formulas A and AC-MD-21.
7. **AC gaps.** Q: Add cases to AC-MD-10 and AC-MD-23 for the five targets and the rare-by-row rule? Recommended: yes.
8. **Missing dependency rows.** Q: Add Market, Time & Turn, Realms, Spirit Herbs, Sects and Travel? Recommended: yes, as soft dependencies that read this system.
9. **Back-references.** Q: Keep them in the #43 and Meridian Map sweeps? Recommended: yes.
10. **The rounding lint flags catalogue rows.** Q: Accept breakthrough small, typed block broad small and density small as known exceptions? Recommended: yes; list them in Formulas E and add the 15 % threshold as a knob.
11. **Damage Types rule 5 wording.** Q: Update it to "rare by its row (Modifier System rule 13)"? Recommended: yes, with that GDD's other answers. Its rule 6 still lists modifier conversions (that GDD's blocker 2).
12. **Defence Open Question 1.** Q: Close it? Recommended: yes; all defence prices in its Formulas I match, except the open artifact defence note in item 15.
13. **Registry price table.** Q: Apply the `stat_power_weights` and `modifier_value` range edits? Recommended: yes, once the blockers are answered.
14. **Realm drift default.** Q: No deflator until the bot has measured the drift? Recommended: yes.
15. **New: artifact defence basis.** Formulas A says "0.51 through ward gear, about 0.35 on body gear"; Defence Formulas I and AC-CD-57 say 0.648 per defence point on both, by your 2026-11-07 decision. This answers combat-defence.md item 18 as far as it can: the note looks stale, but the bases differ (% of the stat here, defence points there), so the 0.6 price was not judged. Q: Should the price be re-derived after the raised body-gear mapping? Recommended: yes, when Item DB adopts the mapping; keep 0.6 until then and restate the basis.
16. **New: the regeneration grid.** `health_regen_pct` and `linh_luc_regen_pct` use the 0.01 grid (Formulas A, Formulas C's example, the generator), but the registry's `stat_precision_grid` says pct keys are 0.1 and names neither. Q: Record them as 0.01 in the Stat List, Character Stats and the registry? Recommended: yes; no value changes, and it matches the catalogue's +0.40 and +0.15.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to modifiers.md (3)

1. Header: status now reads "two passes".
2. Formulas A: added the Damage, increased row at 1.0 (rule 12's anchor, Stat List), the one price AC-MD-21 needs that pass 1's additions missed.
3. Cross-References: the effects.md row now adds this GDD's rule 8 and effects.md rules 6 and 9, matching effects.md's own row and rule 8's Status Catalogue citation.

## design/gdd/effects.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/effects-review-log.md`.
Systems index #41 updated: still Needs Revision, now two passes and 20 recommendations.

**Method:** the GDD, registry and skill were byte-identical to pass 1, and only `modifiers.md`, `combat-defence.md` and
`combat-damage-types.md` had changed, so the skill's path is a cross-document re-check that keeps the prior verdict unless a
conflict appears. None did. The whole GDD was also re-read and its numeric ACs recomputed by hand; they hold, apart from the
AC-EF-38 fix below. The crit caps pass 1 left untraced now trace to Combat Formulas C (`crit_chance_cap` 0.5).
The registry search covered the entries this GDD uses (`cooldown_min`, `soul_lockout`, `dot_pulse_cap`, `curse_bounds`,
`layer_caps`, `heal_pulse_cap`, `resist_floor`, `reserve_cap` and the curse bounds), not all 278 names. No conflict.

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Freshness path: took the cross-document re-check, plus a full re-read.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/effects.md` in a fresh session.

### Blocking findings (not fixed; carried from pass 1, full detail there)

1. **More reads are missing from rule 5's closed list.** New this pass: Measured Stroke and Overheat read an art's authored cooldown, which is not on the list. Q: Add the pass-1 reads and this one? Recommended: yes; add "an art's authored record, compile" alongside pass 1's sheet reads, events and "the chance about to be rolled, live".
2. **More actions are missing from rule 6's closed list.** Q: Add "burn linh lực", "enforce a closing rule at compile", and an event's outcome under life outputs? Recommended: yes to all three. Glass Meridians' "your body shields hold half" also falls under the closing-rule action.
3. **The path of a linh lực tick is undefined.** Q: What path does a tick on linh lực follow? Recommended: Force resistance → linh lực, passing every shield; for Spillover, the clipped amount burns with no second resistance step. One answer also closes combat-damage-types.md blocker 3.

### Recommended findings (not fixed)

4. **AC-EF-16 rejects shipped curses.** Q: Is strength required only where the status has a number? Recommended: yes.
5. **Sundered with no hit.** Q: What type does it lower when no hit applies it, or the hit is all Soul? Recommended: the applying record names a type, and an all-Soul hit cannot apply it.
6. **"Costs no linh lực" is built on a refund** (First Move, Paid in Advance). Q: Waive the cost, or pay and refund it? Recommended: waive it; add "waive an art's cost" to rule 6.
7. **Last acts: order and overkill.** Q: Can a last act win, and which side goes first? Recommended: requesting side first; the overkill is kept, so it wins only if the enemy's overkill share is larger; add a case to AC-EF-28.
8. **Great Essence-Draining Art's kind.** Q: Keep it as a Trigger? Recommended: yes; move "+2 heart demon reported" into its payload and let rule 13 say "or another kind".
9. **Rule 10's list is short.** Q: Add cultivation base and stage? Recommended: yes.
10. **Rounding p.** Q: How does p round? Recommended: to the nearest thousandth, half up.
11. **Tie-breaks.** Q: Use slot order for every tie (Final Clause, Rime Lock, Soul Wound)? Recommended: yes, one sentence in rule 7.
12. **Stacking "None".** Q: What does a recast do while it runs? Recommended: nothing; add it to rule 9's options.
13. **AC gaps.** Q: Add a criterion for each reviewed read and action that has none? Recommended: yes, using the starters pass 1 named.
14. **`domain` and `tags`.** Q: Fill them in now, or at implementation? Recommended: now, before data entry starts.
15. **Two ways to pay in health.** Q: Keep Blood Casting's and `body_cost_share`'s different rules? Recommended: yes; record the difference in #43.
16. **No Ward's flags.** Q: Add both when Defence is revised? Recommended: yes, same answer as combat-defence.md item 11.
17. **Registry `counted_chance`.** Q: Update its output range? Recommended: yes, to `floor(counted_start / 1000 + sum p)`.
18. **Seal of Full Payment with a standing status.** Q: Can stones pay upkeep? Recommended: no; linh lực still pays it.
19. **Dependencies.** Q: Keep the missing host files and one-way back-references for the host sweeps? Recommended: yes; settle the interface row with combat-damage-types.md item 8.
20. **New: restoring linh lực.** Rule 6 says "restores count as healing", but Defence Formulas E's cap and decay are in health and cover only health and body shields. Water Table's "up to your maximum" also ignores the usable maximum under reservation (Defence rule 10). Q: Does a linh lực restore count as healing? Recommended: no; limit the parenthetical to health and body shields, and clip linh lực at the usable maximum.
21. **New: changing a tick's type.** Combat Damage Types rule 6 says this "takes an Effect", but rule 6 here has no such action. Q: Add the action, or drop that sentence? Recommended: drop it, same answer as combat-damage-types.md item 16.
22. **New: status tags.** Modifier System rule 8 reads a status's "mode and effect tags" from the Status Catalogue, which records only cleanse tags. Q: Add a tags column to the catalogue and rule 9? Recommended: yes, answered with modifiers.md item 4.
23. **New: Field Walls' timing.** The rule says "while your formation stands" but reads at compile, so a formation that falls mid-fight is undefined. Q: Is it fixed for the fight? Recommended: yes, if formations cannot fall in a fight; reword it to "if your formation is prepared".

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it). The inventory filter names about 20 of its "about 30" deferred Effects (13 named plus ~7 capabilities), while OQ 5 adds "and others". Rule 9's list of who places a status omits an item (Grave-Silk Shroud). Formulas C numbers wounds as step 4 and rule 11 as step 3; both agree on steps 1 and 2. Parting Curse in Formulas C's example is not a catalogue entry.

### Safe fixes applied to effects.md (7)

1. Header: status now reads "two passes".
2. Conversion table: Flame-Tempered Edge, Thunder Palm and Rot Seeps In read "(at the hit)", not a read time rule 1 allows; now "live (at the hit)", the pattern Blood Casting and Called Blow use.
3. UI Requirements: the tooltip line said `closes` came both last and "first"; it now leads with `closes`, as rule 14, Game Feel and AC-EF-46 require.
4. AC-EF-31: "a non-keystone host" became "an Effect that is not a keystone", because rule 12 limits the Effect, and hosts are where Effects sit.
5. AC-EF-38: added "at t = 0 (no decay)"; later in a fight Defence Formulas E's decay shrinks the restore, and below d = 0.5 the 10 no longer holds.
6. Cross-References: the combat.md row now covers Formulas B and adds Combat Formulas A, the source of `qi_max_caster`.
7. Interactions: "Down refusals" moved from the Combat Defence & Healing row to the Combat row; that GDD never mentions refusals, and they act at Combat rule 10's defeat check under rule 11.

## design/gdd/combat-defence.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/combat-defence-review-log.md`.
Systems index #21a updated: still Needs Revision, with this pass noted.

**Method:** the GDD, registry and skill were byte-identical to pass 2. Only `combat-damage-types.md`, `modifiers.md` and
`effects.md` had changed (their pass 2 safe fixes), and none moved a value or rule this GDD depends on. The whole GDD was
re-read and its worked numbers recomputed by hand; an inline script needed a permission prompt no one could answer, so it
did not run. Not recomputed (needs realm or harness data): AC-CD-46's other-realm mirrors, "446 against top-end hits", and
the other realms' typical-block shares. The stall (37.6 s, 43.8 s) and upkeep (25–27 s, 36 s, 18 s) timings were not
re-derived this pass, because the script for them did not run.

**Dependency files:** present: combat, character-stats, modifiers, combat-damage-types, effects, thien-kiep, cong-phap
(Cultivation Techniques), dao (The Way), item-database. No GDD of their own, as this GDD's Dependencies table says:
Talismans, Formations, Alchemy (quick specs), NPC Builds (implemented), Artifact Refining, Game UI, Debug Terminal.

**Registry:** this GDD's formula and constant entries were compared; the only conflicts are the three in question 13.

**Autonomous-path decisions** (logged in place of the skill's prompts):
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/combat-defence.md`.

### Blocking findings (not fixed; 1–4 carried from pass 1, full detail there)

1. **Soul shield has no formula.** Q: How does a soul shield work? Recommended: it takes `soul_shield_share × pct` off each pool loss after E2's `pct`, its bar is spent first, the share is capped below 1, and ws scales the bar, not the share.
2. **`ws`, `we`, `a_w`, `a_b` lose their home.** Q: Where do they live once #43 removes Formulas D? Recommended: move them into Defence Formulas A with a stub in Combat D, and make rule 1, Dependencies and OQ 2 agree.
3. **Drain billing has two cases left.** Q: How are shared block and a short pool billed? Recommended: split points taken by each source's share of B_hit; add the leak to a_j before block; a drain-paid block's unpaid share is not taken; add AC cases.
4. **AC-CD-59 cannot pass.** Q: Which attacker should the shield-stall check use? Recommended: the realm's typical attacker plus a slow hitter with gaps above 2 s; keep cap knobs as the first fix and allow `recharge_delay` or `shield_recharge` as a fix too.
19. **New: the price check rejects a catalogue ward.** Formulas F gives a shield a per-firing V when cast, but resistance, block and evade always use the full T. Literally, Black Tortoise Shell has V = 0.33 × 36.5 × 8 = 96.4 and C = 25.9, ratio 3.72, far over 0.953, so AC-CD-41 fails. The catalogue's 0.930 needs V = 0.33 × 36.5 × 2 s = 24.1. Q: What T does a cast ward's non-shield payload use? Recommended: its up time inside T_ref (firings × duration), which reproduces the catalogue. It stays unfixed because it changes a formula's wording.

### Recommended findings (not fixed; 5–18 carried, full detail in passes 1 and 2)

5. **Cast ward with a broken shield.** Q: Does a broken shield end a cast ward with other payloads? Recommended: no; only its duration ends the ward.
6. **Shield states.** Q: What does a standing shield start at, and what does it do while its ward is Down? Recommended: starts full; while Down it keeps its value, does not soak and does not recharge.
7. **`b` = 0 in Formulas G.** Q: Define x for b = 0? Recommended: yes, the wards never fall, so ehp = P / λ_all.
8. **Rule 11's default-ward trap.** Q: Should wards with no resistance, block or shield payload for a part suppress the default ward? Recommended: no.
9. **a_b's range.** Q: Is a_b 2.0 legal? Recommended: state 1.0 as one piece's top end and say how 2.0 is reached, or lower those cases.
10. **`a_w`'s meaning.** Q: Ward-role defence or all non-body defence? Recommended: all non-body, as the 0.85 anchor assumes.
11. **No Ward flags.** Q: Add "cannot slot wards" and "no default ward" to rules 5 and 11? Recommended: yes.
12. **Pending Modifier rows.** Q: Define typed block, foe-scoped resistance, the body shield I op, recharge delay, cast ward duration and [body_shield] now or when they leave Pending? Recommended: when they leave Pending, noted in Open Questions now, and decide the duration limit then.
13. **Registry.** Q: Apply the `defence_ehp` range, `default_resist` note and `dot_pool_cap` edits? Recommended: yes.
14. **Tuning Knobs gaps.** Q: Add the seven missing knobs with safe ranges? Recommended: yes, no value changed.
15. **Cross-References gaps.** Q: Add rows for effects.md and Modifier System rule 13? Recommended: yes.
16. **Back-references.** Q: Keep them in the #43 sweep? Recommended: yes.
17. **Stall figure label.** Q: Reword the "continuous model" note after the harness runs? Recommended: yes; no change until then.
18. **Artifact defence on body gear.** Q: Is modifiers.md's "about 0.35 on body gear" stale? Recommended: recheck it at the Modifier revision and, if stale, restate it after the raised mapping (modifiers.md, so not edited here).
20. **New: "compiled once" against live changes.** Edge Cases say every defence sum is compiled once at the start, but rule 3 and Interactions have curses lowering resistance, and effects.md's action table lets an Effect raise or lower a ward while a condition holds. AC-CD-49 only tests thần thức. Q: What may change a defence sum mid-fight? Recommended: slots and base sums are compiled once; curses and Effects apply live on top, at the read times effects.md sets.
21. **New: refusals and "the defeat check is final".** Rule 19 and Edge Cases do not mention Effects' Down step, whose refusal sets health to 1. The registry's `down_step` lists this GDD as a reference, but the GDD never names it. Q: Does a refusal count as healing for `no_heal` and the heal cap? Recommended: no, it is not a heal, so it works under `no_heal`; rule 19 should cite Effects rule 11. Check this against Tribulation's intent.
22. **New: cast ward state names.** Rule 7, AC-CD-17 and Formulas F call a cast ward between firings "down", while States calls it Expired, and States has no state before its first firing. Q: Which name, and what is the state before the first firing? Recommended: keep Expired after a firing, add "Waiting" before the first, and use those names in rule 7 and AC-CD-17.
23. **New: `[fire, over_time]` resistance.** Formulas I prices a type-plus-tag resistance, but rule 3 and modifiers.md's incoming-hit scope match resistance on the final damage type only, so nothing could read it. Q: Does type-plus-tag resistance exist? Recommended: no for now; drop the row, or mark it Pending with the foe-tag row if you want it later.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to combat-defence.md (3)

1. Header: status now reads "three passes".
2. Formulas A2: "(Open Questions 3)" became "(Open Question 3)".
3. Formulas C: `r_w`'s "payload on the part's tags" became "on the part (all, or the part's final damage type)", as Formulas A's `r_w,x`, rule 3 and rule 6 say: resistance payloads are all or by type, and tags never enter.

## design/gdd/combat-damage-types.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/combat-damage-types-review-log.md`.
Systems index #21b updated: still Needs Revision, with this pass noted.

**Method:** the GDD, registry and skill were byte-identical to pass 2, and only `combat-defence.md`, `modifiers.md` and
`effects.md` had changed (their own safe fixes), so the skill's path is a cross-document re-check that keeps the prior verdict
unless a conflict appears. No conflict with a recorded value appeared. The whole GDD was also re-read and its worked examples
and AC numbers recomputed by hand; they hold (150, 146, 9.91, 11.56, 2.57/3.00, 15.91, 8.56, 7.34, 0.583/0.417). The rule
numbers in Cross-References point at the right rules, and the Dependencies status cells match the index.
The registry search covered 37 entry names (combat, defence, soul, curse, element and conversion), by term, not all 278: a
search built from every name was refused by a permission check no one could answer. The entries left out cover other systems.

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Freshness path: took the cross-document re-check, plus a full re-read.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/combat-damage-types.md` in a fresh session.

### Blocking findings (not fixed; carried from pass 1, full detail there)

1. **Order inside a step.** Q: How are conversions ordered inside one tier, and does scaling run before or after the limit of 2? Recommended: stable compile order (slot order, then record id); apply the limit first, then scale only the kept conversions; add it to rule 6 and an AC case.
2. **Modifier conversions cannot exist.** Q: Can a modifier carry a conversion? Recommended: no; steps are the art's own conversions, then Effects; change rule 6, Formulas A, the knob, AC-DT-26 and the registry to match.
3. **Qi Disruption does not fit the tick path.** Q: What path does a tick on linh lực follow? Recommended: Force resistance → linh lực, passing every shield; add a rule 4 row and an AC case, and state it on the effects.md status row. The same answer closes effects.md blocker 3.

### Recommended findings (not fixed; 4–17 carried, full detail in passes 1 and 2)

4. **"Curses' damage."** Q: Remove it from the Chaos row, since curses never deal damage? Recommended: yes.
5. **Penetration scope.** Q: Does "final type only" apply just among damage types? Recommended: yes; reuse Defence Formulas A's wording, "a type scope matches the final type only", so element and form scopes still apply.
6. **Lightning and Light look the same.** Q: Change one colour? Recommended: yes; move Light to a pale near-white gold on another 256-colour code, and add a distinct-codes check to AC-DT-22.
7. **Free hits have no type rule.** Q: What sets a free hit's parts? Recommended: its record names a type or copies its source art's authored parts, then converts like any hit; compile rejects it otherwise; extend AC-DT-20 and AC-DT-24.
8. **Interface rows.** Q: Who owns the conversion rules and records? Recommended: this GDD owns the rules and steps, Effects own the records (direction in), and Combat cites rule 6 after #43.
9. **AC gaps.** Q: Add a same-step chain case and a later-step case? Recommended: yes.
10. **Cross-References gaps.** Q: Add rows for modifiers.md and effects.md? Recommended: yes.
11. **OQ 4.** Q: Close it, since effects.md gives Light no tick? Recommended: yes, once effects.md passes review.
12. **OQ 1 is due.** Q: Keep both "Chaos" names, or rename one? Recommended: keep the damage type "Chaos" and call the root "Primordial Chaos (Hỗn Độn)" in player text.
13. **Systems-index row 21b.** Q: Rewrite the dependency cell to "resistance by final damage type"? Recommended: yes.
14. **Back-references** in combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md. Q: Keep them in the #43 sweep? Recommended: yes.
15. **A part at share 0.** Q: Is a part at share 0 removed? Recommended: yes, at the end of its step, so it spawns nothing, counts for nothing and deals nothing; add an AC case.
16. **Changing a status's type.** Q: Add the action to effects.md, or drop rule 6's sentence? Recommended: drop the sentence until an Effect needs it, since a different status record can already carry another type.
17. **The order of the types.** Q: Declare rule 1's table the fixed order, as effects.md's Sundered and modifiers.md blocker 1 assume? Recommended: yes, one line in rule 1.
18. **New: typed block.** Rule 4 says block is "taken once per hit, split across its parts by size", but modifiers.md's Pending typed-block row has a typed rating block only matching parts, after the shared pool. Q: Should rule 4 change now or when the row leaves Pending? Recommended: when it leaves Pending, answered with combat-defence.md item 12.
19. **New: element-relation Effects.** Rule 8, Interactions and Dependencies name element-relation Effects, but effects.md has none, and its rule 5 closed read list has no element-relation read. Q: Keep this as a future permission? Recommended: yes; reword the Interactions and Dependencies cells to "none yet", and add the read to effects.md rule 5 when the first such Effect is designed.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it). Rule 5's "rarer sources" reads
softer than "rare sources only"; settle it with OQ 3's Item DB rule. A conversion from a type to itself passes Formulas A's test (reject it at
compile when rule 6 is next revised). Edge Cases' "modified to mix Soul" cannot be caught at compile if the change happens at the hit, and no such
Effect exists today.

### Safe fixes applied to combat-damage-types.md (1)

1. Header: status now reads "three passes".

## design/gdd/modifiers.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/modifiers-review-log.md`.
Systems index #40 updated: still Needs Revision, with this pass noted.

**Method:** the GDD, registry, skill, generator and `combat.md` were byte-identical to pass 2, and only `effects.md`,
`combat-defence.md` and `combat-damage-types.md` had changed, so the skill's path is a cross-document re-check that keeps the
prior verdict unless a conflict appears. None did. The whole GDD was also re-read.
- By hand: every catalogue row against Formulas A–C, the Count column (sums to 224), Formulas B–D, realm drift, the examples, the numeric ACs and the Formulas A basis notes.
- Cross-document: Defence Formulas I prices, rules 2–4 and the cited sections, Damage Types rules 1, 2, 5, 6 and 9, the Effects rules cited, Combat rule numbers and caps, and the Dependencies status cells against the systems index.
- Catalogue (AC-MD-27): the generator ran and its output was compared with the GDD **by eye**. A scripted diff again needed a permission prompt no one could answer.
- Registry: **not re-run**. The registry and this GDD were byte-identical to pass 2's search of all 278 names, which found no conflict; the same permission limit blocked a scripted search. The safe fixes below touch no registry value.

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Freshness path: took the cross-document re-check, plus a full re-read.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/modifiers.md` in a fresh session.

### Blocking findings (not fixed; carried from pass 1, full detail there)

1. **Type scopes on whole-hit and whole-art stats.** Q: How does a damage-type scope work on crit chance, art speed and art cost? Recommended: crit counts the scope if the hit's largest part carries that type or has it in its history (ties go to the first type in Damage Types' order); art speed and cost read the art's authored parts, unchanged by conversion; add an AC case for each.
2. **The resistance row [type + family tag].** Q: Keep resistance scoped by type plus a mode, or remove it? Recommended: remove it here, in Defence Formulas I and in the generator; foe pairs stay Pending under their own rule.

### Recommended findings (not fixed; 3–16 carried, full detail in passes 1 and 2)

3. **Effect payloads and W.** Q: Are Effect payloads exempt from rule 12, and may they carry rare modifiers? Recommended: exempt them (stat, op and grid still validate); a rare modifier only when the Effect's host is on rule 13's list.
4. **Tag vocabulary gaps.** Q: Who owns the status tags, and what are they? Recommended: a "status" family owned by the Effects Status Catalogue, one tag per status; rename `qi_burn` to match Qi Disruption; [body_shield] is a heal-source tag owned by Defence.
5. **No floor on cheap lower-is-better stats.** Q: Must an owner name a floor before these rows leave Pending? Recommended: yes, for all of them; prices unchanged.
6. **Two prices on one key.** Q: Should `modifier_prices` be keyed by key and op? Recommended: yes, and say so in Formulas A and AC-MD-21.
7. **AC gaps.** Q: Add cases to AC-MD-10 and AC-MD-23 for the five targets and the rare-by-row rule? Recommended: yes.
8. **Missing dependency rows.** Q: Add Market, Time & Turn, Realms, Spirit Herbs, Sects and Travel? Recommended: yes, as soft dependencies that read this system.
9. **Back-references.** Q: Keep them in the #43 and Meridian Map sweeps? Recommended: yes.
10. **The rounding lint flags catalogue rows.** Q: Accept breakthrough small, typed block broad small and density small as known exceptions? Recommended: yes; list them in Formulas E and add the 15 % threshold as a knob.
11. **Damage Types rule 5 wording.** Q: Update it to "rare by its row (Modifier System rule 13)"? Recommended: yes, with that GDD's other answers. Its rule 6 still lists modifier conversions (that GDD's blocker 2).
12. **Defence Open Question 1.** Q: Close it? Recommended: yes; all defence prices in its Formulas I match, except the open artifact defence note in item 15.
13. **Registry price table.** Q: Apply the `stat_power_weights` and `modifier_value` range edits? Recommended: yes, once the blockers are answered.
14. **Realm drift default.** Q: No deflator until the bot has measured the drift? Recommended: yes.
15. **Artifact defence basis.** Q: Should the 0.6 price be re-derived after the raised body-gear mapping? Recommended: yes, when Item DB adopts the mapping; keep 0.6 until then and restate the basis.
16. **The regeneration grid.** Q: Record `health_regen_pct` and `linh_luc_regen_pct` as 0.01 in the Stat List, Character Stats and the registry? Recommended: yes; no value changes.
17. **New: no stat-to-tags mapping.** Rule 9 derives each modifier's family tags and domain from the Stat List, but the Stat List has no such column, and AC-MD-14 and AC-MD-15 depend on the result. Tags only drive search and filters, so this changes no combat number. Q: Add family tags and domain to the Stat List? Recommended: yes, as one column per table, or one domain per table heading.
18. **New: the scope of a resistance cap raise.** Rule 8's incoming-hit bullet names resistance only, but `resist_cap_pct` shares the target, and Defence rule 3 lets a rare raise apply to one damage type or to all. Q: Does rule 8 cover `resist_cap_pct` with the same final-type match? Recommended: yes, and breadth applies as usual through Formulas C.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it).

### Safe fixes applied to modifiers.md (6)

Please check 3 and 4 first. They correct basis notes in Formulas A; neither price changed.

1. Header: status now reads "three passes".
2. Rule 11: the family row lists artifact role, which the catalogue's role row and the generator already treat as family.
3. Formulas A, Evade: 2.07 → 2.11 at the 0.40 cap (0.01 / 0.6 / 0.00791). The price stays 1.5.
4. Formulas A, Art cost: the basis now reads the slope of ln(1/(1 − r)), on log damage as in the Anchor. That gives 1.17, which matches the 1.2 price; the old wording gives 1.69. The price stays 1.2.
5. Formulas B: the source of `I` is rule 11; the Stat List has no implied-tag column.
6. Dependencies: Quests' status is Approved, as in the systems index (was Designed).

## design/gdd/effects.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard). Log: `design/gdd/reviews/effects-review-log.md`.
Systems index #41 updated: still Needs Revision, now three passes and 21 recommendations.

**Method:** the GDD, registry, skill and `combat.md` were byte-identical to pass 2, and only `modifiers.md`, `combat-defence.md` and `combat-damage-types.md` had changed, so the skill's path is a cross-document re-check that keeps the prior verdict unless a conflict appears. No value conflict appeared. The whole GDD was also re-read.
- By hand: the status and starter counts (16 and 46), the tier list, curse bounds, Formulas A and B, and the numeric ACs. All hold.
- Cross-document: the rule numbers cited in Defence, Damage Types, Modifiers and Combat; the Stat List keys and scope tags used; system numbers and Dependencies status cells against the systems index.
- Registry: searched every entry name, which earlier passes had not done. 10 names matched (`cooldown_min`, `dot_pulse_cap`, `curse_soul_shred_max`, `curse_heal_taken_max`, `standing_status`, `soul_lockout`, `resist_floor`, `counted_chance`, `heal_pulse_cap`, `down_step`), and their values agree apart from item 17. The search matched exact names only, not the spaced forms the skill asks for ("soul lockout").

**Autonomous-path decisions** (logged in place of the skill's prompts, and in `production/session-logs/decision-log.md`):
- Freshness path: took the cross-document re-check, plus a full re-read.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer the blockers below, then re-run `/design-review design/gdd/effects.md` in a fresh session.

### Blocking findings (not fixed; carried, full detail in passes 1 and 2)

1. **More reads are missing from rule 5's closed list.** Q: Add the reads passes 1 and 2 named? Recommended: yes; add sheet reads (root element, formation level, stage), "an art's authored record, compile", events (Down step, failed brew, death in an event) and "the chance about to be rolled, live".
2. **More actions are missing from rule 6's closed list.** Q: Add "burn linh lực", "enforce a closing rule at compile", and an event's outcome under life outputs? Recommended: yes to all three.
3. **The path of a linh lực tick is undefined.** Q: What path does a tick on linh lực follow? Recommended: Force resistance → linh lực, passing every shield; for Spillover, the clipped amount burns with no second resistance step. One answer also closes combat-damage-types.md blocker 3.

### Recommended findings (not fixed; 4–23 carried, full detail in passes 1 and 2)

4. **AC-EF-16 rejects shipped curses.** Q: Is strength required only where the status has a number? Recommended: yes.
5. **Sundered with no hit.** Q: What type does it lower when no hit applies it, or the hit is all Soul? Recommended: the applying record names a type, and an all-Soul hit cannot apply it.
6. **"Costs no linh lực" is built on a refund** (First Move, Paid in Advance). Q: Waive the cost, or pay and refund it? Recommended: waive it; add "waive an art's cost" to rule 6.
7. **Last acts: order and overkill.** Q: Can a last act win, and which side goes first? Recommended: requesting side first, as Combat rule 10 orders hits; the overkill is kept, so it wins only if the enemy's overkill share is larger; add a case to AC-EF-28.
8. **Great Essence-Draining Art's kind.** Q: Keep it as a Trigger? Recommended: yes; move "+2 heart demon reported" into its payload and let rule 13 say "or another kind".
9. **Rule 10's list is short.** Q: Add cultivation base and stage? Recommended: yes.
10. **Rounding p.** Q: How does p round? Recommended: to the nearest thousandth, half up.
11. **Tie-breaks.** Q: Use slot order for every tie (Final Clause, Rime Lock, Soul Wound)? Recommended: yes, one sentence in rule 7.
12. **Stacking "None".** Q: What does a recast do while it runs? Recommended: nothing; add it to rule 9's options. Corpse Rot's "Single" is the same case.
13. **AC gaps.** Q: Add a criterion for each reviewed read and action that has none? Recommended: yes, using the starters pass 1 named.
14. **`domain` and `tags`.** Q: Fill them in now, or at implementation? Recommended: now, before data entry starts.
15. **Two ways to pay in health.** Q: Keep Blood Casting's and `body_cost_share`'s different rules? Recommended: yes; record the difference in #43.
16. **No Ward's flags.** Q: Add both when Defence is revised? Recommended: yes, same answer as combat-defence.md item 11. Defence still has neither.
17. **Registry `counted_chance`.** Q: Update its output range? Recommended: yes, to `floor(counted_start / 1000 + sum p)`.
18. **Seal of Full Payment with a standing status.** Q: Can stones pay upkeep? Recommended: no; linh lực still pays it.
19. **Dependencies.** Q: Keep the missing host files and one-way back-references for the host sweeps? Recommended: yes; settle the interface row with combat-damage-types.md item 8.
20. **Restoring linh lực.** Q: Does a linh lực restore count as healing? Recommended: no; limit rule 6's parenthetical to health and body shields, and clip linh lực at the usable maximum.
21. **Changing a tick's type.** Combat Damage Types rule 6 still says this "takes an Effect". Q: Add the action, or drop that sentence? Recommended: drop it, same answer as combat-damage-types.md item 16.
22. **Status tags.** Modifier System rule 8 still reads "mode and effect tags" from the catalogue. Q: Add a tags column to the catalogue and rule 9? Recommended: yes, answered with modifiers.md item 4.
23. **Field Walls' timing.** Q: Is it fixed for the fight? Recommended: yes, if formations cannot fall in a fight; reword it to "if your formation is prepared".
24. **New: Bare Rack's [basic] scope adds nothing yet.** `basic` is a derived art tag, and Modifier System rule 10 says modifiers scoped by those are accepted, marked Pending, and add nothing until Combat adopts them. So Bare Rack's basic-attack half does nothing today. Q: Should #43 adopt `basic`? Recommended: yes, `basic` at least; until then mark that half of Bare Rack Pending.

Advisory, no decision needed: Player Fantasy is absent (advisory at `standard`; Game Feel covers it). The advisories in pass 2 stand. Light having no tick here while Damage Types Open Question 4 leaves it open is already logged under that GDD.

### Safe fixes applied to effects.md (2)

1. Header: status now reads "three passes".
2. Cross-References: the combat-damage-types.md row now also cites rules 4 and 7, which the Status Catalogue's Burn, Poison and Bleed rows depend on (how a tick meets the defence path, what passes a shield).
