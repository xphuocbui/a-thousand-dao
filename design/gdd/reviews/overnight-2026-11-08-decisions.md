# Overnight decisions — 2026-11-08 (autonomous mode)

Questions for the user from the unattended review passes. Each comes with a recommended answer; nothing
here is applied until the user decides.

## design/gdd/combat-defence.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; first review). Log:
`design/gdd/reviews/combat-defence-review-log.md`. Systems index #21a set to Needs Revision.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Systems-index update: took [A], marked Needs Revision.
- Review-log append: took [A], created the log.
- Revise now: took [B] for design items (no design choices made unattended); only safe fixes applied.
- Next step: fix the two blockers, then re-run `/design-review design/gdd/combat-defence.md` in a fresh session.

All worked examples, fixtures and acceptance-criteria numbers were recomputed and match the formulas. All
23 registry constants owned by this GDD match.

### Blocking findings (not fixed)

1. **Registry `defence_shield` output range.** The registry says "0 to 1.0 x health_max per side";
   Formulas B allows 2.0 × (1 × ward shields under `shield_total_cap`, plus 1 × body shield under
   `body_shield_cap`).
   - Q: Should the registry entry read "0 to 2.0 x health_max per side (1.0 ward, 1.0 body)"?
   - Recommended: yes. The GDD's two-cap rule is the later user decision ("separate shield caps").
2. **Drain billing for non-resistance payloads.** Formulas C defines a drain bill only for resistance
   (`prevented_w = D · r_eff · r_w / R_pos`). Rule 8 lets any non-shield ward be drain-paid, and Formulas G
   already uses `rate_w · B_w / D_ref` for a drain-paid block.
   - Q: How does a drain ward bill a block, evade, status or soul payload?
   - Recommended: bill block at `rate_w` × the block points it actually took (as G assumes). Make drain
     invalid for evade, status and soul payloads (the price check rejects them), since "prevented damage"
     has no clean value for them.

### Recommended findings (not fixed)

3. **Shield cap timing.** It does not say whether `shield_total_cap` clips maximum sizes at compile or live
   totals (for example a cast shield refiring while the other shields are full).
   - Q: Clip at compile on maximum sizes, or live on current totals?
   - Recommended: clip maximum sizes at compile (later slots first), so a refire never exceeds its clipped
     maximum. That is simpler, deterministic and readable.
4. **Stall-check counterfactual.** Formulas E says a heal floor of 0.25 lasts "41 s". A continuous model
   gives about 43.8 s (the 0.10 case gives about 37.4 s against the stated 37.6 s). The conclusion, a
   stall, still holds.
   - Q: Recompute the 41 s figure with the discrete pulse model?
   - Recommended: yes, through the harness (AC-CD-45). The value is not changed tonight because the
     discrete model was not available to check against.
5. **Bidirectional dependencies still missing**: combat.md (#43 revision), character-stats.md (Parameter
   keys), thien-kiep.md rule 7 (`no_heal`), item-database.md (body-gear mapping).
   - Q: Fold these into the Combat revision (#43) pass?
   - Recommended: yes. Do thien-kiep rule 7 and character-stats keys in the same sweep.
6. **Open Questions 10 and 14 look done.** The registry already holds resist_cap … defence_lambda_min and
   defence_block, and it marks body guard and the old ward superseded.
   - Q: Close OQ 10 and 14, keeping only "retire `ward_block` and `body_guard_pct` once Combat #43 lands"?
   - Recommended: yes.
7. **OQ 1 and Formulas I are stale.** Both say "when the Modifier System resumes", but modifiers.md is
   designed and its Stat List carries the new keys.
   - Q: Narrow OQ 1 to checking modifiers.md's defence rows against Formulas I's prices?
   - Recommended: yes.
8. **Header status line** still reads "pending an independent /design-review".
   - Q: Update it after the blockers are fixed?
   - Recommended: yes, at the re-review.
9. **AC order.** AC-CD-53 to 58 sit between 46 and 47.
   - Q: Renumber?
   - Recommended: no. Leave the numbers, because OQ 3 and 11 cite them; just move the block under AC-CD-52.
10. **Tuning Knobs section absent** (advisory at standard). The knobs sit in the variable tables without safe
    ranges.
    - Q: Add a consolidated Tuning Knobs table?
    - Recommended: yes, at the re-review, listing each data-file knob with a range and the effect it tunes.
11. **Player Fantasy section absent** (advisory at standard).
    - Q: Add one?
    - Recommended: optional. Game Feel covers most of it; a three-line fantasy (the warded cultivator,
      the thể tu wall) would do.

### Safe fixes applied to combat-defence.md (14)

1. Rule 6 payload table: shields soak "after resistance and block" (rule 9), not "after resistance".
2. Rule 12: body pieces are sized inside their W price (Modifier System; Formulas H), not "the price check
   (rule 20)", which Formulas H says does not price them.
3. States table, Broken row: counts as Up for the default-ward fallback (rule 11 states this).
4. States note: the default ward is Up "for a hit part" when no other ward is Up for that part (rule 11).
5. Interactions, Combat row: "kind, final element" became "final damage type, elements" (kind retired by
   Combat Damage Types rule 9).
6. Interactions, Modifier System row: removed the retired "body guard" stat.
7. Interactions, Techniques / Way row: "guard modifiers" became "block modifiers".
8. Dependencies, Modifier System row: status Designed 2026-11-07; it now lists this system.
9. Dependencies, Combat Damage Types row: stale "kinds, elements and variants" became damage types; status
   Designed; it lists this system (rules 4, 5, 7).
10. Dependencies, Effects System row: status Designed 2026-11-08; it lists this system (rule 6).
11. Dependencies, Heavenly Tribulation row: "Thunder" became "Lightning", matching Edge Cases and
    AC-CD-50.
12. Game Feel: "per threat kind" became "per damage type".
13. AC fixtures: Common Ward "general r 0.50" became "all r 0.50".
14. Open Questions: row 12 moved into numeric order (before 13 and 14).

## design/gdd/combat-damage-types.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; first review). Log:
`design/gdd/reviews/combat-damage-types-review-log.md`. Systems index #21b set to Needs Revision.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Systems-index update: took [A], marked Needs Revision (status cell only; the stale description is item 7).
- Review-log append: took [A], created the log.
- Revise now: took [B] for design items (no design choices made unattended); only safe fixes applied.
- Next step: settle the two blockers, then re-run `/design-review design/gdd/combat-damage-types.md` in a
  fresh session.

Every worked example and AC number was recomputed. All agree except one rounding (fixed). The thể tu
fixture matches combat-defence.md. The registry's `damage_parts` entry matches Formulas A.

### Blocking findings (not fixed)

1. **Hits that mix Soul with other types.** Rule 1 lets a hit carry several parts, and AC-DT-22 needs a hit
   with all 8 types. But Soul skips evade and block and uses Combat Formulas E2, not C. Nothing says how one
   hit with a Soul part and a Physical part rolls evade, splits block, or rolls crit.
   - Q: Can one hit have a Soul part alongside other types?
   - Recommended: no. A hit is either all Soul (a soul art, Formulas E2) or has no Soul part. Compile
     rejects mixed records. Rewrite AC-DT-22 as two hits: one with the 7 non-Soul types and one Soul hit.
2. **Two conversions from one type in the same step.** Formulas A applies conversions one at a time
   (`s_j ← s_j · (1 − c_k)`). Done that way, Physical → Fire 0.583 then Physical → Cold 0.417 leaves
   0.243 Physical. The edge case and AC-DT-16 expect 0. "Step" is never defined either.
   - Q: Within a step, do conversions from the same source type all read the part's share at the start of
     the step?
   - Recommended: yes. Define a step as one source tier (the art's own, then Effects, then modifiers). In a
     step, conversions from one type read the share at the start of the step and are scaled to sum to
     at most 1. Steps then apply in order.

### Recommended findings (not fixed)

3. **Does a conversion that changes nothing count toward the 2?** Soul conversions explicitly do not
   count. A back-conversion (AC-DT-17), or a conversion with no part of its source type, is not covered.
   - Q: Count it?
   - Recommended: no. Only a conversion that moves a share counts, which matches the Soul rule.
4. **Conversion and ticks.** Whether "Physical → Fire" turns a bleed tick into Fire is not stated.
   - Q: Do conversions reach ticks?
   - Recommended: no. Conversion acts on a hit's parts, and a status keeps the type its record names.
     Any change to that is an Effect (#41).
5. **Rule 6 omits penetration.** Its bullet says resistance and block read the final type. Edge Cases and
   AC-DT-08 add penetration.
   - Q: Add "and penetration" to the rule 6 bullet?
   - Recommended: yes (wording only).
6. **Header ownership line** still says the GDD owns "its element, its mode". Elements belong to Spiritual
   Roots and Combat rule 6, and Combat rule 6 owns mode.
   - Q: Narrow it to "its damage types, how conversion changes them, and the rule that elements give no
     bonus in a fight"?
   - Recommended: yes.
7. **Systems-index row 21b description is stale.** It still names kinds (body, qi, soul), the element cycle,
   enemy elements and "resistance by kind and element".
   - Q: Rewrite the row to match the designed GDD?
   - Recommended: yes, in the next index sweep.
8. **Registry `defence_resistance` variables** still list R_gen, R_kind and R_elem. The expression and notes
   already use R_all and R_type.
   - Q: Replace those three with R_all and R_type?
   - Recommended: yes, as part of the combat-defence registry fix (its blocker 1).
9. **Open Question 4 is partly answered.** effects.md has 16 statuses, and Light's status (Exposed) has no
   tick.
   - Q: Narrow OQ 4 to whatever statuses are still missing?
   - Recommended: yes.
10. **Dependencies table**: one row lists four systems (Techniques, The Way, Item DB, Talismans) with three
    statuses, and Talismans (#18) is missing from the Interactions table.
    - Q: Split the row per system and add Talismans to Interactions?
    - Recommended: yes.
11. **Bidirectional dependencies missing**: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and
    item-database.md do not list this system.
    - Q: Fold these into the Combat revision (#43) sweep?
    - Recommended: yes, together with combat-defence's item 5.
12. **Tuning Knobs section absent** (advisory at standard). The conversion limit (2) and the type colours
    are knobs.
    - Q: Add a short Tuning Knobs table?
    - Recommended: yes, at the re-review.
13. **Player Fantasy section absent** (advisory at standard).
    - Q: Add one?
    - Recommended: optional. Game Feel already covers it.
14. **Header status line** still reads "pending an independent /design-review".
    - Q: Update it after the blockers are fixed?
    - Recommended: yes, at the re-review.

### Safe fixes applied to combat-damage-types.md (10)

1. Header ownership line: "its kind" became "its damage type" (kind retired by rule 9).
2. Rule 5: penetration now cites Combat Defence & Healing rules 3 and 4. Penetration is rule 4, not 3.
3. Rule 8: the generating and overcoming relations cite Spiritual Roots rule 1, not rule 3 (tier and
   effective count).
4. Cross-References, Rule 3 row: linh-can.md rules 1, 9–12 (was 3, 9–12).
5. Cross-References, Rule 8 row: linh-can.md rule 1 (was 3).
6. Formulas A thể tu example: the body shield soaks 15.91, not 15.90 (21.476 − 5.57 = 15.906).
7. AC-DT-19: the same 15.91.
8. Dependencies, Combat Defence & Healing status: "In revision" became "Needs revision" (systems index).
9. Dependencies, Modifier System: "Unfinished, paused / Not yet" became "Designed, pending review / Yes".
   modifiers.md lists #21b.
10. Dependencies, Effects System: "Not started / Will" became "Designed, pending review / Yes". effects.md
    lists #21b.

(The Last Updated header line was also bumped to 2026-11-08. That is bookkeeping and isn't counted.)

## design/gdd/modifiers.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; first review). Log:
`design/gdd/reviews/modifiers-review-log.md`. Systems index #40 set to Needs Revision.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Systems-index update: took [A], marked Needs Revision.
- Review-log append: took [A], created the log.
- Revise now: took [B] for design items (no design choices made unattended); only safe fixes applied.
- Next step: settle the two blockers, then re-run `/design-review design/gdd/modifiers.md` in a fresh session.

Every catalogue value (all 195 rows), the Formulas B–D examples, the Formulas D realm table, realm drift
k_r, the lifespan-years example and AC-MD-04/05/06/16–20 were recomputed, and all match. Running
`python -I tools/design/modifier_catalogue.py` reproduces the General Catalogue exactly (AC-MD-27). The
registry entries this GDD owns match it.

### Blocking findings (not fixed)

1. **Rule 8 is missing targets the Stat List uses.** These are "heal (its tags)" (healing), "reservation",
   "outgoing status" (status duration, scoped [curse] and [poison] in the catalogue), "basic attack" and
   "outgoing soul hit". Rule 8 lists only incoming status.
   - Q: Add these targets to rule 8, each with what it matches?
   - Recommended: yes. Outgoing status matches the status's own tags (mode, effect, damage type). A heal
     matches its source art's tags. Reservation matches the reserving ward's or art's tags. Basic attack and
     outgoing soul hit are outgoing hit narrowed by their implied tag.
2. **Typed resistance's price is ambiguous.** The Stat List W reads "1.0 Physical/Force; 0.83 others (per
   pp effective)". The generator prices it as 1.25 with breadth (1.25/1.25 = 1.0, 1.25/1.5 = 0.83). Formulas
   C applied literally to 1.0 and ×1.25 gives +1.5 pp, against the catalogue's +1.2 pp.
   - Q: Should `modifier_prices` hold one resistance price of 1.25, with 1.0 / 0.83 described as
     effective prices after breadth?
   - Recommended: yes. Put 1.25 in the W column for every resistance row, and add a note that the per-type
     effective price is 1.25 / breadth_mult. The catalogue and generator are already right.

### Recommended findings (not fixed)

3. **Rare list incomplete.** Ward slots (`bonus_ward_slots`, 30 W) and the resistance cap raise (5 W) are
   marked rare in the Stat List but are missing from rule 13 and the Rare table. Rule 13 also says rare
   costs 10–25 W.
   - Q: Add both to rule 13 and the Rare table, and widen the range to 5–30 W?
   - Recommended: add ward slots and widen to "10–30 W". Treat the resistance cap raise as rare by its own
     row, because it is a cap rather than a count, and note that in rule 13.
4. **Chaos resistance in the catalogue.** It is listed as an ordinary family row, which contradicts "Chaos
   only from rare sources" (Open Question 6).
   - Q: Split Chaos out of the resistance family row and mark it rare (keystones, named items, quest
     rewards, capstones)?
   - Recommended: yes. Use a rare flag on the Chaos-scoped resistance row, enforced by the rule 13 check.
5. **Formulas C range.** B is "0 to about 60 W", but the Output Range uses 25.8 W (215 units).
   - Q: Restate the range for 60 W (500 units), or cap B at about 25.8 W for this formula?
   - Recommended: state both: "about 215 units in-tree (25.8 W), up to 500 at 60 W".
6. **Stale reservation note.** The Formulas consultation note says "reservation kept as Pending", while
   `reserve_eff_pct` is Designed.
   - Q: Change the note to "reservation efficiency kept (Designed, Combat Defence & Healing rule 10)"?
   - Recommended: yes.
7. **Rule 4 regeneration unit.** It says "regeneration as a share of maximum per second", but health
   regeneration is per pulse.
   - Q: Change it to "regeneration as a share of maximum per second or per pulse (Stat List)"?
   - Recommended: yes.
8. **Interactions table** has no rows for Combat Defence & Healing (#21a) or Combat Damage Types (#21b).
   - Q: Add the two rows?
   - Recommended: yes. #21a: defence, heal and ward stats and their prices. #21b: damage-type scopes and the
     final-type rule.
9. **Bidirectional dependencies.** Many readers do not list this system yet, among them Character
   Stats, Meridian Map, The Way, Techniques, Item DB and NPC Builds.
   - Q: Fold this into the Combat revision (#43) and Meridian Map redesign sweeps?
   - Recommended: yes, together with combat-defence item 5 and combat-damage-types item 11.
10. **OQ 8 is mostly done.** The registry already holds this GDD's formulas, grades and breadth multipliers,
    and stat_power_weights has moved here.
    - Q: Narrow OQ 8 to registering the full price table (new stats) in `stat_power_weights`?
    - Recommended: yes. The registry value still lists only the old Meridian Map weights.
11. **Header status line** still says "pending an independent /design-review".
    - Q: Update it after the blockers are fixed?
    - Recommended: yes, at the re-review.
12. **Formulas D notation.** `L_i_typ(r)` is written as realm-indexed, but its values are fixed.
    - Q: Write it as `L_i_typ`, or give per-realm values?
    - Recommended: drop the (r), unless Combat Formulas B gives realm-specific typical layers.
13. **Tuning Knobs section absent** (advisory at standard).
    - Q: Add a table for the breadth multipliers, grades, the 15 % rounding lint, the 2-tag scope limit and
      the derived-tag thresholds?
    - Recommended: yes, at the re-review.
14. **Player Fantasy section absent** (advisory at standard).
    - Q: Add one?
    - Recommended: optional. Game Feel covers it.

### Safe fixes applied to modifiers.md (7)

1. Rule 6: merged the duplicated L5 statements (stated twice, once with "no plain modifier writes to
   either"). The meaning is unchanged.
2. Stat List: the artifact attack and defence targets now use the role tags `weapon`, `ward_gear` and
   `body_gear` (rule 8), where defence had read "(ward, body)".
3. General Catalogue: added the missing blank line before the **Combat: offence** heading. It had run into
   the paragraph above.
4. Dependencies, Combat Defence & Healing (#21a) status: "Designed" became "Needs revision" (systems index).
5. Dependencies, Combat Damage Types (#21b) status: "Designed" became "Needs revision" (systems index).
6. Dependencies, Effects System (#41): "Not started / Will" became "Designed 2026-11-08, pending review /
   Yes". effects.md cites this GDD throughout.
7. Interactions: "Effects (new, separate GDD)" became "Effects System (#41)".

(The Last Updated header was bumped to 2026-11-08. That is bookkeeping and isn't counted.)

## design/gdd/effects.md, pass 1

**Verdict: NEEDS REVISION** (lean, workflow standard; first review). Log:
`design/gdd/reviews/effects-review-log.md`. Systems index #41 set to Needs Revision.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Systems-index update: took [A], marked Needs Revision.
- Review-log append: took [A], created the log.
- Revise now: took [B] for design items (no design choices made unattended); only safe fixes applied.
- Next step: settle the two blockers, then re-run `/design-review design/gdd/effects.md` in a fresh session.

Every worked number was recomputed and matches: Formulas A (crits on hits 4, 7, 10), B (5.181), C, and
AC-EF-05/07/18/21/24/27/30/36/37/38/41/43. The status catalogue fits Combat Formulas F and the registry's
curse bounds. The registry entries this GDD owns (`counted_chance`, `standing_status`, `down_step`,
`curse_heal_taken_max`, `curse_soul_shred_max`) match it.

### Blocking findings (not fixed)

1. **Starters read things rule 5 does not list.** Water Table reads ward payments. Still Water reads the
   regeneration clip. Spillover reads the `dot_pulse_cap` clip. Rime Lock reads a status's stack count. Overflow,
   as a kind, reads cap clips. Under the GDD's own Edge Cases and AC-EF-05, all of these are rejected.
   - Q: Extend rule 5's readable list with "a cap's clipped amount (per named cap)", "ward payments against
     your hits" and "a status's stack count on the target"?
   - Recommended: yes, add all three as engine additions in rule 5, each with its read time (clips and ward
     payments are events; stack count is live).
2. **Starters use actions rule 6 does not list.** The list is closed ("may use only"), but these actions are
   missing from it: add a tag (Elemental Fist), add a slot (Talisman Sleeve), skip the evade and crit rolls
   (Measured Stroke), double the companion share (Beast Soul Union), fire an art at Down (Final Clause), raise
   a level cap (Formation Within a Formation) and change an item's output (Strange Pill Reborn). Refusal
   (rule 11) and counted chance (rule 12) are not in the table either.
   - Q: Add these as named actions in rule 6, or rule that a rule-change, keystone or enabler Effect may
     define its own one-off action that this GDD lists at the Effect itself?
   - Recommended: add them to the table as named actions (an extra tag, an extra slot, skip a roll, a
     multiplier on a sheet share, fire an art as a last act, a host cap raise, a life-output change, refuse
     Down, a counted chance). This keeps the list closed and checkable by AC-EF-06.

### Recommended findings (not fixed)

3. **Missing read times.** Many starter `reads` give no read time (Blood Casting, Water Table, Called Blow,
   and others), and the life table has no Reads column, so AC-EF-01/45 would reject the shipped data.
   - Q: Add a read time to every starter read and a Reads column to the life table?
   - Recommended: yes. Conditionals take instant start (rule 8), events need none, and sheet reads are
     compile.
4. **Token closes.** Called Blow's "fortune never shifts your crits" restates rule 12, which is true of all
   counted chance. Soul Leaves the Body's closes repeats its payload.
   - Q: Is the crit cap drop to 0.35 enough as Called Blow's cost, and what does Soul Leaves the Body close
     beyond the stage loss?
   - Recommended: keep the 0.35 cap as Called Blow's real cost and drop the fortune clause from `closes`.
     Treat the stage loss as Soul Leaves the Body's closes and its payload as "survive". The user decides.
5. **Blood Casting vs Withering.** Healing taken −50 % equals `curse_heal_taken_max`, and the GDD doesn't
   say whether the two stack.
   - Q: Does Blood Casting's −50 % stack with Withering?
   - Recommended: no. Both count toward one healing-taken floor of −50 %, so a Blood Caster ignores
     Withering.
6. **Corpse Rot vs the tick lint.** With no duration, Corpse Rot can't be checked against
   `c_tick · duration ≤ 1.2 · c_art`.
   - Q: How are standing statuses linted?
   - Recommended: exempt them from the duration lint. They are bound instead by the tick caps and the upkeep
     cost, and by `c_tick ≤ 0.15`.
7. **Sundered's damage type.** A hit has several typed parts, so "the damage type of the hit that applied
   it" is ambiguous.
   - Q: Which part's type does Sundered take?
   - Recommended: the hit's largest part after conversion, ties going to the first in Combat Damage Types'
     order.
8. **AC-EF-10's fixture is stale.** It reuses Combat Formulas G's 15.9 / 21.7 / 7.9, which come from the
   retired body-ward model.
   - Q: Restate the numbers after the Combat revision (#43), or mark them a test fixture now?
   - Recommended: mark them a *test fixture* now and restate them in #43.
9. **One-way dependencies.** Seven Dependencies rows say the other GDD doesn't list Effects yet. Talismans,
   Formations, Alchemy, Spirit Beasts, Event Engine and NPC Builds have no GDD file.
   - Q: Add the back-references when each host GDD is next revised?
   - Recommended: yes. Combat #43 and the Meridian Map redesign come first.
10. **Advisory sections absent.** Player Fantasy and Tuning Knobs are missing (advisory at `standard`), and
    the tunable values are scattered.
    - Q: Add a short Tuning Knobs table (`standing_cost`, `counted_start` and the starter limits)?
    - Recommended: yes, a table only. No values change.
11. **Starter count mismatch.** systems-index row #41 says 44 starter Effects, but the GDD's tables hold 46.
    - Q: Correct the index to 46?
    - Recommended: yes. The count was left unchanged tonight because only the status was in scope.
12. **Rule 7's trigger budget paraphrase.** "At most half of the direct damage" leaves out Formulas G's
    floor, `max(direct, 0.5 · U · stage)`.
    - Q: Cite Formulas G instead of paraphrasing it?
    - Recommended: yes.
13. **`counted_start` range.** The range 0–0.99 doesn't match per-mille storage.
    - Q: State it as 0–999 per mille?
    - Recommended: yes.

### Safe fixes applied (effects.md only)

1. Header: Status now records this review. Last Updated is 2026-11-08, matching the Status line.
2. Rule 11: the "both saved" sentence now says the fight goes on, matching Edge Cases and AC-EF-29. Before,
   it said that case went to the overkill and draw rules.
3. Starter Effects legend: added "Root spiritual root". Elemental Fist uses it, and rule 13 lists it.
4. Cross-References: the modifiers.md row now cites rule 6 (L5 is Effects-only) and covers rule 15.
5. Cross-References: the capabilities row now says "keystones or rule-change Effects", matching rule 13. Before,
   it said "keystones".

## design/gdd/combat-defence.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review). Log:
`design/gdd/reviews/combat-defence-review-log.md`. Systems index #21a kept at Needs Revision (status cell updated
for pass 2).

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: the target doc had CHANGED (pass-1 safe fixes only), so a full re-review ran, as the skill requires.
- Revise now: took [B] for design items (no design choices unattended); only safe fixes applied.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Next step: the user settles blockers 1 and 2, then `/design-review design/gdd/combat-defence.md` runs in a fresh session.

All worked examples, the 14-ward catalogue's price-check ratios, the block table and AC-CD-01 to 58 were
recomputed again. One prose figure was wrong and has been fixed (safe fix 6).

### Blocking findings (not fixed)

1. **Registry `defence_shield` output range** reads "0 to 1.0 x health_max per side", against Formulas B's
   2 × health_max (1 × ward shields, 1 × body shield). The GDD's rule 9 wording is now aligned (safe fix 5); the
   registry is not.
   - Q: Change the registry's output_range to "0 to 2.0 x health_max per side (1.0 ward, 1.0 body)"?
   - Recommended: yes.
2. **Drain billing is incomplete.** (a) No bill is defined for drain-paid block, evade, status or soul
   payloads, though Formulas G assumes `rate_w · B_w / D_ref` for block. (b) New this pass:
   `prevented_w = D · r_eff · r_w / R_pos` goes negative when penetration or curses push r_eff below 0, which
   refunds linh lực and breaks "every payment ≥ 0". It is also undefined at R_pos = 0.
   - Q: How are these cases billed?
   - Recommended: bill block at `rate_w` × the block points the ward actually took; make drain invalid for
     evade, status and soul payloads (the price check rejects them); use `max(0, r_eff)` in `prevented_w`, and
     bill 0 when R_pos = 0.

### Recommended findings (not fixed)

3. **Shield cap timing.** Does `shield_total_cap` clip maximum sizes at compile, or live totals?
   - Recommended: maximum sizes at compile, later slots first (matches AC-CD-30 and the edge case).
4. **Stall-check "41 s"** (Formulas E) recomputes to about 43.8 s continuous.
   - Q: Recompute with the discrete pulse model? Recommended: yes, via the harness (AC-CD-45).
5. **Bidirectional dependencies** are still missing in combat.md, character-stats.md, thien-kiep.md rule 7,
   item-database.md, cong-phap.md and dao.md.
   - Q: Fold them into the Combat revision (#43) sweep? Recommended: yes.
6. **Open Questions 10 and 14** mostly done in the registry.
   - Q: Close them, keeping only "retire `ward_block` and `body_guard_pct` with #43"? Recommended: yes.
7. **OQ 1 / Formulas I "when the Modifier System resumes"** is stale; modifiers.md carries the keys.
   - Q: Narrow OQ 1 to checking modifiers.md's defence prices against Formulas I? Recommended: yes.
8. **AC order** (53–58 between 46 and 47).
   - Q: Move the block under AC-CD-52 without renumbering? Recommended: yes.
9. **Thể tu fixture's Physical resistance.** The fixture uses R_Physical 0.30, but the named sources give only
   0.20 (Iron Body tier 3 at 6.7 pp per tier).
   - Q: Is the other 0.10 Black Iron Armour's Physical affix? Recommended: yes; name it in Formulas G.
10. **Fast-kit D.** The A2 table's thể tu fast hit 4.33 implies D ≈ 24.75, while the text says 24.8 (which
    gives 4.35).
    - Q: State the exact D? Recommended: yes, 24.75 (within tolerance either way).
11. **Tuning Knobs / Player Fantasy sections** absent (advisory at standard).
    - Q: Add a consolidated Tuning Knobs table with safe ranges? Recommended: yes. Player Fantasy: optional.

### Safe fixes applied to combat-defence.md (11)

1. Header status: "pending an independent /design-review" became the 2026-11-08 review result (Needs Revision,
   with a log pointer).
2. Header Last Updated: 2026-11-07 became 2026-11-08 (edited by tonight's passes).
3. Summary: payload list now includes evade (rule 6).
4. Overview: "what it carries" now includes evade (rule 6).
5. Rule 9: "A side's shields together … `shield_total_cap`" became separate ward and body caps, matching Formulas B
   and the user decision "separate shield caps".
6. Rule 3: "makes a tag harmless" became "makes a damage type harmless" (resistance is per damage type).
7. Formulas A2: the fast kit against block builds, "×0.66 to ×0.75", became "×0.57 to ×0.75" (the table's
   0.39 / 0.68 = 0.57; 0.63 / 0.84 = 0.75).
8. Edge Cases: the default ward is up "only when no ward is" became per part (rule 11).
9. Edge Cases: ticks pass ward shields "by default" (rule 9: the pass list is data on the shield).
10. Dependencies, Modifier System and Combat Damage Types rows: "pending review" became Needs Revision (2026-11-08
    reviews).
11. Dependencies, Effects System row: the same status update.

## design/gdd/combat-damage-types.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review of pass 1). Log:
`design/gdd/reviews/combat-damage-types-review-log.md`. Systems index #21b stays Needs Revision; its
status cell now says two passes, with both blockers still open.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: the GDD, the registry and the skill were UNCHANGED since pass 1. Only combat-defence.md,
  modifiers.md and effects.md had CHANGED, so I took the skill's path of re-checking the facts this GDD
  takes from those files instead of re-running the full review. Their diffs are status lines and wording
  fixes. The thể tu fixture, defence rules 1–4, 9 and 12, the shield defaults, and every citation of this
  GDD's rules 1, 2, 4–7 and 9 still agree. No conflict, so the pass 1 verdict stands.
- Systems-index update: took [A], kept Needs Revision.
- Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer blockers 1 and 2 below, then re-run `/design-review design/gdd/combat-damage-types.md`
  in a fresh session.

### Blocking findings (not fixed, carried from pass 1)

1. **Hits that mix Soul with other types** (Core Rules 1, 4, 6; AC-DT-22).
   - Q: Can one hit have a Soul part alongside other types?
   - Recommended: no. A hit is either all Soul (Formulas E2) or has no Soul part, and compile rejects a
     mixed hit. AC-DT-22 becomes two hits: the 7 non-Soul types, and one Soul hit.
2. **Same-step conversions from one type** (Formulas A; Edge Cases; AC-DT-16).
   - Q: In one step, do conversions from the same source type all read the part's share at the start of
     the step?
   - Recommended: yes. A step is one source tier (the art, then Effects, then modifiers). That way 0.583 + 0.417
     leaves 0 Physical, as AC-DT-16 expects.

### Recommended findings (not fixed)

3. **No-op conversions and the limit of 2** (rule 6).
   - Q: Does a conversion that moves no share count toward the 2? Recommended: no, matching the Soul rule.
4. **Conversion and ticks** (rule 6).
   - Q: Does a conversion change a status tick's type? Recommended: no. A status keeps its record's type;
     changing that is an Effect.
5. **Systems-index row 21b description** still names kinds (body, qi, soul), the element cycle and
   "resistance by kind and element".
   - Q: Rewrite the description to match the GDD? Recommended: yes, in the next index sweep.
6. **Registry `defence_resistance`** still lists R_gen, R_kind, R_elem.
   - Q: Update it to R_all + R_type(final)? Recommended: yes, with combat-defence.md's registry pass.
7. **Open Question 4** is partly answered by effects.md (16 statuses; Light's status is Exposed, with no
   tick).
   - Q: Narrow OQ 4 to the open per-type status choices? Recommended: yes, once effects.md passes review.
8. **Bidirectional dependencies**: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md
   do not list this system.
   - Q: Add them in the Combat revision (#43) sweep? Recommended: yes.
9. **Tuning Knobs absent** (advisory at standard).
   - Q: Add a table (conversion limit 2, the type colours, compile rejects as non-knobs)? Recommended: yes,
     with the blocker fix.
10. **Player Fantasy absent** (advisory at standard).
    - Q: Add one? Recommended: optional; Game Feel covers it.
11. **Nice-to-have:** the Formulas A output range says at most 4 × the authored parts. The tight bound is 3 ×.
    - Q: Tighten it (and AC-DT-15)? Recommended: yes, after blocker 2 settles how steps split parts.

### Safe fixes applied to combat-damage-types.md (7)

1. Header status: "pending an independent /design-review" became the 2026-11-08 result (Needs Revision, log
   pointer).
2. Header ownership: dropped "its element, its mode". Element tags belong to Combat rule 6 and Spiritual
   Roots, as rule 2 and the Interactions table say.
3. Rule 6: "Resistance and block read only its final type" now includes penetration, matching Edge Cases
   and AC-DT-08.
4. Interactions: added Talismans (#18) to the content row, matching Dependencies.
5. Dependencies, Modifier System row: status became Needs revision (its 2026-11-08 review).
6. Dependencies, Effects System row: the same status update.
7. Dependencies, #9/#39/#13/#18 row: four statuses for four systems ("In review; approved; approved;
   implemented").

## design/gdd/modifiers.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review). Log: `design/gdd/reviews/modifiers-review-log.md`.
Systems index #40 kept at Needs Revision (pass-2 note added; the Progress table row's stale "pending review" now
reads "Needs Revision 2026-11-08").

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: modifiers.md, the registry, the skill and `tools/design/modifier_catalogue.py` were UNCHANGED
  since pass 1; only effects.md was CHANGED. I took the skill's path for that case: the prior verdict stands, and
  only cross-document facts were re-verified. effects.md's new citations (modifiers.md rules 1, 6, 9, 16; L5 only
  from Effects; spiritual roots as a host) agree with this GDD. No new conflict, so no full re-review.
- Systems-index update: took [A] (kept Needs Revision). Review-log append: took [A].
- Revise now: took [B]. No design choices made unattended; safe fixes only.
- Next step: the user settles the blockers below, then `/design-review design/gdd/modifiers.md` in a fresh session.

### Blocking findings (not fixed; unchanged from pass 1)

1. **Rule 8 is missing targets the Stat List uses** (heal, reservation, outgoing status, basic attack, outgoing
   soul hit).
   - Q: Add these targets to rule 8, each with what it matches? Recommended: yes. Outgoing status matches the
     status's own tags, a heal its source art's tags, reservation the reserving ward's or art's tags; basic attack
     and outgoing soul hit are outgoing hit narrowed by their implied tag.
2. **Typed resistance's price is ambiguous** (Stat List W 1.0 / 0.83 already includes breadth; Formulas C gives
   +1.5 pp against the catalogue's +1.2 pp).
   - Q: Store one resistance price of 1.25 in `modifier_prices`, with 1.0 / 0.83 described as effective prices?
     Recommended: yes. The catalogue and generator are already right.

### Recommended findings (not fixed)

3. Rare list incomplete (ward slots 30 W, resistance cap raise 5 W). Q: Add ward slots to rule 13 and the Rare
   table, widen to 10–30 W, treat the cap raise as rare by its row? Recommended: yes.
4. Chaos resistance listed as an ordinary family row. Q: Mark the Chaos-scoped row rare? Recommended: yes.
5. Formulas C range (60 W vs 25.8 W). Q: State both? Recommended: "about 215 units in-tree, up to 500 at 60 W".
6. Stale "reservation kept as Pending" note. Q: Say it is Designed (Combat Defence & Healing rule 10)?
   Recommended: yes.
7. Rule 4 regeneration "per second". Q: Say "per second or per pulse (Stat List)"? Recommended: yes.
8. Interactions table lacks #21a and #21b rows. Q: Add them? Recommended: yes.
9. Bidirectional dependencies missing in many readers. Q: Fold into the Combat revision (#43) and Meridian Map
   sweeps? Recommended: yes.
10. OQ 8 mostly done. Q: Narrow it to registering the full price table in `stat_power_weights`? Recommended: yes.
11. Formulas D `L_i_typ(r)` notation. Q: Drop the (r)? Recommended: yes, unless Combat gives per-realm values.
12. Tuning Knobs section absent (advisory). Q: Add a table? Recommended: yes, at the revision.
13. Player Fantasy section absent (advisory). Q: Add one? Recommended: optional; Game Feel covers it.
14. **New:** Cross-References has no effects.md row, though effects.md cites rules 1, 6, 9, 16. Q: Add a row
    (rules 1, 6, 15 ↔ effects.md rules 1, 3, 15: payloads, L5 only from Effects)? Recommended: yes.

### Safe fixes applied to modifiers.md (2)

1. Header status line: "pending an independent /design-review" now records the 2026-11-08 reviews and the
   NEEDS REVISION verdict (pass-1 item 11).
2. Dependencies, Effects System (#41) status: "Designed 2026-11-08, pending review" became "Needs revision"
   (systems index #41).

## design/gdd/effects.md, pass 2

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review of pass 1). Log:
`design/gdd/reviews/effects-review-log.md`. Systems index #41 stays Needs Revision; its status cell now says
two passes, with both blockers still open.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: effects.md, the registry and the skill were UNCHANGED since pass 1. Only modifiers.md,
  combat-defence.md and combat-damage-types.md had CHANGED, so I took the skill's path of re-checking the facts
  this GDD takes from those files instead of re-running the full review. Their diffs are status lines and
  wording fixes, with no renumbered rules. Every citation still matches: modifiers.md rules 1, 6, 9, 16;
  combat-defence.md rules 5–10, 16–19; combat-damage-types.md rules 1, 6. No conflict, so the pass 1 verdict
  stands.
- Systems-index update: took [A], kept Needs Revision. Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer blockers 1 and 2 below, then re-run `/design-review design/gdd/effects.md` in a fresh session.

Every AC number was recomputed again and matches (AC-EF-05/07/18/21/24/27/30/36/37/38/41/43). AC-EF-10's
21.7 is Combat Formulas G's own rounding (6 × 3.617).

### Blocking findings (not fixed, carried from pass 1)

1. **Reads missing from rule 5** (Water Table's ward payments, Still Water's regeneration clip, Spillover's
   `dot_pulse_cap` clip, Rime Lock's stack count; overflow in general reads cap clips).
   - Q: Add "a cap's clipped amount (per named cap)", "ward payments against your hits" and "a status's stack
     count on the target" to rule 5? Recommended: yes, each with its read time (clips and payments are
     events; stack count is live).
2. **Actions missing from rule 6** (add a tag, add a slot, skip a roll, multiply a sheet share, fire an art as a
   last act, raise a host cap, change a life output; refusal and counted chance).
   - Q: Add them as named actions in rule 6? Recommended: yes. That keeps the list closed and checkable by
     AC-EF-06.

### Recommended findings (not fixed)

3. Missing read times on starter reads, and the life table has no Reads column. Q: Add them? Recommended: yes
   (conditionals instant start, sheet reads compile, events none).
4. Token closes (Called Blow's fortune clause; Soul Leaves the Body). Q: Is the 0.35 crit cap Called Blow's
   whole cost? Recommended: yes, and drop the fortune clause; the user decides Soul Leaves the Body's cost.
5. Blood Casting vs Withering. Q: Do the two −50 % stack? Recommended: no; one healing-taken floor of −50 %.
6. Corpse Rot vs the duration lint. Q: Exempt standing statuses? Recommended: yes; the tick caps, the upkeep and
   `c_tick ≤ 0.15` bind them instead.
7. Sundered's damage type for a multi-part hit. Q: Which part decides? Recommended: the largest part after
   conversion, ties to the first in Combat Damage Types' order.
8. AC-EF-10's fixture comes from the retired body-ward model. Q: Mark it a *test fixture* now? Recommended: yes,
   and restate it in Combat #43.
9. One-way dependencies (seven hosts don't list Effects; six have no GDD). Q: Add back-references as each host
   is revised? Recommended: yes, Combat #43 first.
10. Player Fantasy and Tuning Knobs absent (advisory). Q: Add a Tuning Knobs table? Recommended: yes, a table
    only, with no values changed.
11. Systems-index row #41 says 44 starter Effects; the GDD holds 46. Q: Correct the index? Recommended: yes.
12. Rule 7 paraphrases the trigger budget without Formulas G's floor. Q: Cite G instead? Recommended: yes.
13. `counted_start` range 0–0.99 vs per-mille storage. Q: State it as 0–999 per mille? Recommended: yes.
14. **New:** the capability arithmetic doesn't add up. Six capabilities are in the tables (#5, #9, #11, #15, #17,
    #25), and about 12 are named rule changes. The inventory filter still calls "the other 19 capabilities"
    deferred (6 + 12 + 19 > 25).
    - Q: Should the deferred line read "the remaining ~7 capabilities", with the ~12 rule changes counted
      separately? Recommended: yes, once Open Question 4 settles which ones close nothing.

### Safe fixes applied to effects.md (4)

1. Dependencies, Modifier System (#40) status: "Designed" became "Needs revision" (systems index).
2. Dependencies, Combat Defence & Healing (#21a) status: the same.
3. Dependencies, Combat Damage Types (#21b) status: the same.
4. Header Status: records review passes 1 and 2.

## design/gdd/combat-defence.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review). Log:
`design/gdd/reviews/combat-defence-review-log.md`. Systems index #21a kept at Needs Revision (status cell now
says three passes).

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: this GDD, the registry and the skill were UNCHANGED since pass 2; only combat-damage-types.md,
  modifiers.md and effects.md had CHANGED. Took the skill's path: the prior verdict stands except for
  cross-document facts, which were re-checked against those files' diffs. No conflict was found (no renumbered
  rule this GDD cites; the 15.90→15.91 rounding in AC-DT-19 is not restated here).
- Revise now: took [B] for design items (no design choices unattended); only safe fixes applied.
- Systems-index update: took [A], Needs Revision.
- Review-log append: took [A].
- Next step: the user settles blockers 1 and 2, then `/design-review design/gdd/combat-defence.md` runs in a
  fresh session. A fourth unattended pass would find the same thing; skip it until the blockers are answered.

### Blocking findings (not fixed)

1. **Registry `defence_shield` output range** reads "0 to 1.0 x health_max per side"; Formulas B allows
   2 × health_max (1 × ward shields, 1 × body shield).
   - Q: Change the registry's output_range to "0 to 2.0 x health_max per side (1.0 ward, 1.0 body)"?
   - Recommended: yes.
2. **Drain billing is incomplete**: there is no bill for drain-paid block, evade, status or soul payloads;
   `prevented_w` goes negative when r_eff < 0 and is undefined at R_pos = 0.
   - Q: How are these billed?
   - Recommended: bill block at `rate_w` × the block points the ward actually took; make drain invalid for
     evade, status and soul payloads; use `max(0, r_eff)`; bill 0 when R_pos = 0.

### Recommended findings (not fixed)

3. **Shield cap timing.** Q: Does `shield_total_cap` clip maximum sizes at compile or live totals?
   Recommended: maximum sizes at compile, later slots first.
4. **Stall-check "41 s"** (Formulas E). Q: Recompute with the discrete pulse model? Recommended: yes, via the
   harness (AC-CD-45).
5. **Bidirectional dependencies** missing in six GDDs. Q: Fold into the Combat revision (#43) sweep?
   Recommended: yes.
6. **Open Questions 10 and 14.** Q: Close them, keeping only "retire `ward_block` and `body_guard_pct` with #43"?
   Recommended: yes.
7. **Open Question 1 scope.** Q: Narrow it to checking modifiers.md's existing defence prices against Formulas I?
   Recommended: yes.
8. **AC order** (53–58 between 46 and 47). Q: Move the block under AC-CD-52 without renumbering?
   Recommended: yes.
9. **Thể tu fixture R_Physical 0.30** vs 0.20 from named sources. Q: Is the other 0.10 Black Iron Armour's
   Physical affix? Recommended: yes; name it in Formulas G.
10. **Fast-kit exact D.** Q: State D = 24.75? Recommended: yes.
11. **Drain at floored r_eff** (part of blocker 2). Q: Bill 0? Recommended: yes.
12. **Tuning Knobs / Player Fantasy** absent (advisory). Q: Add a Tuning Knobs table with safe ranges?
    Recommended: yes; Player Fantasy optional.

### Safe fixes applied to combat-defence.md (3)

1. Formulas I intro: "when it resumes" became "which was rebuilt for this GDD on 2026-11-07; Open Question 1
   checks them against it" (modifiers.md's own status records the resume and rebuild).
2. Open Question 1 timing cell: "When the Modifier System resumes" became "With the Modifier System's review
   (#40; resumed and rebuilt 2026-11-07)".
3. Header status: "two passes" became "three passes".

## design/gdd/combat-damage-types.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review of pass 2). Log:
`design/gdd/reviews/combat-damage-types-review-log.md`. Systems index #21b stays Needs Revision; its
status cell now says three passes, with both blockers still open.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: the GDD, the registry and the skill were UNCHANGED since pass 2. Only combat-defence.md,
  modifiers.md and effects.md had CHANGED, so I took the skill's path: re-check the cross-document facts and
  re-issue the verdict. The thể tu fixture (Physical 0.60, Fire and Chaos 0.30, block 5.57, body shield
  109.0), the block split by after-resistance size (Formulas A2, AC-CD-53), defence rules 1, 3, 4, 9 and 12,
  the resistance limits 0.75 / 0.90 / −0.50, modifiers.md's damage-type tag family and effects.md's
  citations of rules 1 and 6 all still agree. AC-DT-19 recomputed and correct. No conflict found.
- Revise now: took [B] for design items; only safe fixes applied.
- Systems-index update: took [A], kept Needs Revision.
- Review-log append: took [A].
- Next step: answer blockers 1 and 2, then re-run `/design-review design/gdd/combat-damage-types.md` in a
  fresh session. A fourth unattended pass would find the same thing, so skip it until the blockers are answered.

### Blocking findings (not fixed, carried from pass 1)

1. **Hits that mix Soul with other types** (Core Rules 1, 4, 6; AC-DT-22).
   - Q: Can one hit have a Soul part alongside other types?
   - Recommended: no. A hit is either all Soul (Formulas E2) or has no Soul part, and compile rejects a
     mixed hit. AC-DT-22 becomes two hits: one with the 7 non-Soul types, and one Soul hit.
2. **Same-step conversions from one type** (Formulas A; Edge Cases; AC-DT-16).
   - Q: In one step, do conversions from the same source type all read the part's share at the start of
     the step?
   - Recommended: yes. A step is one source tier (the art, then Effects, then modifiers), so 0.583 + 0.417
     leaves 0 Physical, as AC-DT-16 expects.

### Recommended findings (not fixed)

3. **No-op conversions and the limit of 2** (rule 6). Q: Does a conversion that moves no share count toward
   the 2? Recommended: no, matching the Soul rule.
4. **Conversion and ticks** (rule 6). Q: Does a conversion change a status tick's type? Recommended: no. A
   status keeps its record's type; changing that is an Effect.
5. **Systems-index row 21b description** still names kinds, the element cycle and "resistance by kind and
   element". Q: Rewrite it to match the GDD? Recommended: yes, in the next index sweep.
6. **Registry `defence_resistance`** still lists R_gen, R_kind, R_elem. Q: Update to R_all + R_type(final)?
   Recommended: yes, with combat-defence.md's registry pass.
7. **Open Question 4** is partly answered by effects.md (Light's status is Exposed, with no tick). Q: Narrow
   it to the open per-type status choices? Recommended: yes, once effects.md passes review.
8. **Bidirectional dependencies**: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do
   not list this system. Q: Add them in the Combat revision (#43) sweep? Recommended: yes.
9. **Tuning Knobs absent** (advisory). Q: Add a table (conversion limit 2, type colours)? Recommended: yes,
   with the blocker fix.
10. **Player Fantasy absent** (advisory). Q: Add one? Recommended: optional; Game Feel covers it.
11. **Nice-to-have:** the Formulas A output range (and AC-DT-15) says at most 4 × the authored parts; the
    tight bound is 3 ×. Q: Tighten it? Recommended: yes, after blocker 2 settles how steps split parts.

### Safe fixes applied to combat-damage-types.md (1)

1. Header Status and Last Updated: "two passes" / "passes 1 and 2" became "three passes" / "passes 1–3".

## design/gdd/modifiers.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review). Log: `design/gdd/reviews/modifiers-review-log.md`.
Systems index #40 kept at Needs Revision; its status cell now records passes 2 and 3.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: modifiers.md, the registry, the skill and `tools/design/modifier_catalogue.py` were UNCHANGED
  since pass 2. Only effects.md was CHANGED, and its diff is its own pass-2 status-line fixes. I took the skill's
  path for that case: the prior verdict stands, and only cross-document facts were re-verified.
  - effects.md still cites modifiers.md rules 1, 6, 9 and 16 correctly, and "L5 only from Effects" matches rule 6.
  - AC-EF-03's `body_shield_pct` is in the Stat List.
  - The rule numbers this GDD cites in combat-defence.md (rules 2–4, 6, 9–12; Formulas A–E, I) and in
    combat-damage-types.md (rules 1, 2, 6, 9) still name the intended rules.
  - No conflict, so no full re-review.
- Stale-term sweep: every "body guard" mention is a retirement record, and "kind" in rule 13 means source-record
  kind (not the retired damage kind). Nothing to fix.
- Systems-index update: took [A] (kept Needs Revision). Review-log append: took [A].
- Revise now: took [B]. No design choices made unattended; safe fixes only.
- Next step: the user settles the blockers below, then `/design-review design/gdd/modifiers.md` in a fresh session.
  A fourth unattended pass on an unrevised document would only repeat this verdict.

### Blocking findings (not fixed; unchanged from pass 1)

1. **Rule 8 is missing targets the Stat List uses** (heal, reservation, outgoing status, basic attack, outgoing
   soul hit).
   - Q: Add these targets to rule 8, each with what it matches? Recommended: yes. Outgoing status matches the
     status's own tags, a heal its source art's tags, reservation the reserving ward's or art's tags; basic attack
     and outgoing soul hit are outgoing hit narrowed by their implied tag.
2. **Typed resistance's price is ambiguous** (Stat List W 1.0 / 0.83 already includes breadth; Formulas C gives
   +1.5 pp against the catalogue's +1.2 pp).
   - Q: Store one resistance price of 1.25 in `modifier_prices`, with 1.0 / 0.83 described as effective prices?
     Recommended: yes. The catalogue and generator are already right.

### Recommended findings (not fixed; unchanged from pass 2)

3. Rare list incomplete (ward slots 30 W, resistance cap raise 5 W). Q: Add ward slots to rule 13 and the Rare
   table, widen to 10–30 W, treat the cap raise as rare by its row? Recommended: yes.
4. Chaos resistance listed as an ordinary family row. Q: Mark the Chaos-scoped row rare? Recommended: yes.
5. Formulas C range (60 W vs 25.8 W). Q: State both? Recommended: "about 215 units in-tree, up to 500 at 60 W".
6. Stale "reservation kept as Pending" note. Q: Say it is Designed (Combat Defence & Healing rule 10)?
   Recommended: yes.
7. Rule 4 regeneration "per second". Q: Say "per second or per pulse (Stat List)"? Recommended: yes.
8. Interactions table lacks #21a and #21b rows. Q: Add them? Recommended: yes.
9. Bidirectional dependencies missing in many readers. Q: Fold into the Combat revision (#43) and Meridian Map
   sweeps? Recommended: yes.
10. OQ 8 mostly done. Q: Narrow it to registering the full price table in `stat_power_weights`? Recommended: yes.
11. Formulas D `L_i_typ(r)` notation. Q: Drop the (r)? Recommended: yes, unless Combat gives per-realm values.
12. Tuning Knobs section absent (advisory). Q: Add a table? Recommended: yes, at the revision.
13. Player Fantasy section absent (advisory). Q: Add one? Recommended: optional; Game Feel covers it.
14. Cross-References has no effects.md row, though effects.md cites rules 1, 6, 9, 16. Q: Add a row (rules 1, 6,
    15 ↔ effects.md rules 1, 3, 15: payloads, L5 only from Effects)? Recommended: yes.

### Safe fixes applied to modifiers.md (1)

1. Header status line: "passes 1 and 2" became "passes 1–3".

## design/gdd/effects.md, pass 3

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review of pass 2). Log:
`design/gdd/reviews/effects-review-log.md`. Systems index #41 stays Needs Revision; its status cell now says
three passes, with both blockers still open.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: effects.md, the registry and the skill were UNCHANGED since pass 2. Only modifiers.md,
  combat-defence.md and combat-damage-types.md had CHANGED (their own pass-3 safe fixes), so I took the skill's
  path: re-check the cross-document facts and re-issue the verdict. Every citation still matches: modifiers.md
  rules 1, 6, 9, 16; combat-defence.md rules 5–10, 16–19 and Formulas E; combat-damage-types.md rules 1, 6. The
  separate ward and body shield caps and evade as a ward payload (combat-defence.md) don't conflict with
  effects.md. No conflict was found, so the pass-2 verdict stands.
- Stale-term sweep: "kind" is the Effect kind (rule 2), "guard" is Combat's guards, and "body guard" appears only
  as a retirement record. Nothing to fix.
- Systems-index update: took [A], kept Needs Revision. Review-log append: took [A].
- Revise now: took [B] for design items; only safe fixes applied.
- Next step: answer blockers 1 and 2, then re-run `/design-review design/gdd/effects.md` in a fresh session. A
  fourth unattended pass would find the same thing, so skip it until the blockers are answered.

### Blocking findings (not fixed, carried from pass 1)

1. **Reads missing from rule 5** (Water Table's ward payments, Still Water's regeneration clip, Spillover's
   `dot_pulse_cap` clip, Rime Lock's stack count; overflow in general reads cap clips).
   - Q: Add "a cap's clipped amount (per named cap)", "ward payments against your hits" and "a status's stack
     count on the target" to rule 5? Recommended: yes, each with its read time (clips and payments are events;
     stack count is live).
2. **Actions missing from rule 6** (add a tag, add a slot, skip a roll, multiply a sheet share, fire an art as a
   last act, raise a host cap, change a life output; refusal and counted chance).
   - Q: Add them as named actions in rule 6? Recommended: yes. That keeps the list closed and checkable by
     AC-EF-06.

### Recommended findings (not fixed; unchanged from pass 2)

3. Missing read times on starter reads; the life table has no Reads column. Q: Add them? Recommended: yes
   (conditionals instant start, sheet reads compile, events none).
4. Token closes (Called Blow's fortune clause; Soul Leaves the Body). Q: Is the 0.35 crit cap Called Blow's whole
   cost? Recommended: yes, and drop the fortune clause; the user decides Soul Leaves the Body's cost.
5. Blood Casting vs Withering. Q: Do the two −50 % stack? Recommended: no; one healing-taken floor of −50 %.
6. Corpse Rot vs the duration lint. Q: Exempt standing statuses? Recommended: yes; the tick caps, the upkeep and
   `c_tick ≤ 0.15` bind them instead.
7. Sundered's damage type for a multi-part hit. Q: Which part decides? Recommended: the largest part after
   conversion, ties to the first in Combat Damage Types' order.
8. AC-EF-10's fixture comes from the retired body-ward model. Q: Mark it a *test fixture* now? Recommended: yes,
   and restate it in Combat #43.
9. One-way dependencies (seven hosts don't list Effects; six have no GDD). Q: Add back-references as each host is
   revised? Recommended: yes, Combat #43 first.
10. Player Fantasy and Tuning Knobs absent (advisory). Q: Add a Tuning Knobs table? Recommended: yes, a table
    only, with no values changed.
11. Systems-index row #41 says 44 starter Effects; the GDD holds 46. Q: Correct the index? Recommended: yes.
12. Rule 7 paraphrases the trigger budget without Formulas G's floor. Q: Cite G instead? Recommended: yes.
13. `counted_start` range 0–0.99 vs per-mille storage. Q: State it as 0–999 per mille? Recommended: yes.
14. Capability arithmetic (6 in tables + ~12 rule changes + "the other 19" deferred > 25). Q: Should the deferred
    line read "the remaining ~7 capabilities"? Recommended: yes, once Open Question 4 settles which close nothing.

### Safe fixes applied to effects.md (1)

1. Header Status: "passes 1 and 2" became "passes 1–3".

(Tracking only, done as the skill directs: systems index row #41 now says three passes and 12 recommendations;
design-order row 42 says "Needs Revision 2026-11-08" instead of "pending review".)

## design/gdd/combat-defence.md, pass 4

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review). Log:
`design/gdd/reviews/combat-defence-review-log.md`. Systems index #21a kept at Needs Revision (status cell now
says four passes).

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: this GDD, the registry, the skill, combat.md, thien-kiep.md and game-concept.md were UNCHANGED
  since pass 3. Only combat-damage-types.md, modifiers.md and effects.md had CHANGED, and each change was its own
  pass-3 header status line. Took the skill's path: the prior verdict stands except for cross-document facts. None
  moved (no cited rule, value or rule number changed), so there was no full re-review.
- Revise now: took [B] for design items (no design choices made unattended); safe fixes only.
- Systems-index update: took [A], Needs Revision. Review-log append: took [A].
- Next step: the user answers blockers 1 and 2, then `/design-review design/gdd/combat-defence.md` runs in a
  fresh session. Passes 3 and 4 both repeated the verdict on an unrevised document; skip further unattended
  passes until the blockers are answered.

### Blocking findings (not fixed, carried from pass 1)

1. **Registry `defence_shield` output range** reads "0 to 1.0 x health_max per side"; Formulas B allows
   2 × health_max (1 × ward shields, 1 × body shield).
   - Q: Change the registry's output_range to "0 to 2.0 x health_max per side (1.0 ward, 1.0 body)"?
   - Recommended: yes.
2. **Drain billing is incomplete**: no bill for drain-paid block, evade, status or soul payloads;
   `prevented_w` goes negative when r_eff < 0 and is undefined at R_pos = 0.
   - Q: How are these billed?
   - Recommended: bill block at `rate_w` × the block points the ward actually took; make drain invalid for
     evade, status and soul payloads; use `max(0, r_eff)`; bill 0 when R_pos = 0.

### Recommended findings (not fixed, carried)

3. **Shield cap timing.** Q: Does `shield_total_cap` clip maximum sizes at compile or live totals?
   Recommended: maximum sizes at compile, later slots first.
4. **Stall-check "41 s"** (Formulas E). Q: Recompute with the discrete pulse model? Recommended: yes, via the
   harness (AC-CD-45).
5. **Bidirectional dependencies** missing in six GDDs. Q: Fold into the Combat revision (#43) sweep?
   Recommended: yes.
6. **Open Questions 10 and 14.** Q: Close them, keeping only "retire `ward_block` and `body_guard_pct` with #43"?
   Recommended: yes.
7. **Open Question 1 scope.** Q: Narrow it to checking modifiers.md's existing defence prices against Formulas I?
   Recommended: yes.
8. **AC order** (53–58 between 46 and 47). Q: Move the block under AC-CD-52 without renumbering?
   Recommended: yes.
9. **Thể tu fixture R_Physical 0.30** vs 0.20 from named sources. Q: Is the other 0.10 Black Iron Armour's
   Physical affix? Recommended: yes; name it in Formulas G.
10. **Fast-kit exact D.** Q: State D = 24.75? Recommended: yes.
11. **Drain at floored r_eff** (part of blocker 2). Q: Bill 0? Recommended: yes.
12. **Tuning Knobs / Player Fantasy** absent (advisory). Q: Add a Tuning Knobs table with safe ranges?
    Recommended: yes; Player Fantasy optional.

### Safe fixes applied to combat-defence.md (1)

1. Header status: "three passes" became "four passes".

## design/gdd/combat-damage-types.md, pass 4

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review of pass 3). Log:
`design/gdd/reviews/combat-damage-types-review-log.md`. Systems index #21b stays Needs Revision; its
status cell now says four passes, with both blockers still open.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: the GDD, the registry and the skill were UNCHANGED since pass 3; only combat-defence.md,
  modifiers.md and effects.md had CHANGED. I took the skill's path: re-check the cross-document facts and
  re-issue the verdict. The thể tu fixture (R_all 0.30 + R_Physical 0.30 = Physical 0.60; Fire and Chaos
  0.30; block 5.57; body shield 109.0), block split after resistance (Formulas A2), defence rules 1, 3, 4, 9,
  12 and 13, the 0.75 / 0.90 / −0.50 limits, modifiers.md's damage-type family and effects.md's rule 1 and 6
  citations all still agree. The examples (150, 146) and AC-DT-19 were recomputed and are correct. No conflict.
- Revise now: took [B] for design items; only safe fixes applied.
- Systems-index update: took [A], kept Needs Revision.
- Review-log append: took [A].
- Next step: answer blockers 1 and 2, then re-run the review in a fresh session. Further unattended passes
  will keep reaching this same result until the blockers are answered.

### Blocking findings (not fixed, carried from pass 1)

1. **Hits that mix Soul with other types** (Core Rules 1, 4, 6; AC-DT-22).
   - Q: Can one hit have a Soul part alongside other types?
   - Recommended: no. A hit is either all Soul (Formulas E2) or has no Soul part, and compile rejects a
     mixed hit. AC-DT-22 becomes two hits: one with the 7 non-Soul types, and one Soul hit.
2. **Same-step conversions from one type** (Formulas A; Edge Cases; AC-DT-16).
   - Q: In one step, do conversions from the same source type all read the part's share at the start of
     the step?
   - Recommended: yes. A step is one source tier (the art, then Effects, then modifiers), so 0.583 + 0.417
     leaves 0 Physical, as AC-DT-16 expects.

### Recommended findings (not fixed)

3. **No-op conversions and the limit of 2** (rule 6). Q: Does a conversion that moves no share count toward
   the 2? Recommended: no, matching the Soul rule.
4. **Conversion and ticks** (rule 6). Q: Does a conversion change a status tick's type? Recommended: no. A
   status keeps its record's type; changing that is an Effect.
5. **Systems-index row 21b description** still names kinds, the element cycle and "resistance by kind and
   element". Q: Rewrite it to match the GDD? Recommended: yes, in the next index sweep.
6. **Registry `defence_resistance`** still lists R_gen, R_kind, R_elem. Q: Update to R_all + R_type(final)?
   Recommended: yes, with combat-defence.md's registry pass.
7. **Open Question 4** is partly answered by effects.md (Light's status is Exposed, with no tick). Q: Narrow
   it to the open per-type status choices? Recommended: yes, once effects.md passes review.
8. **Bidirectional dependencies**: combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md do
   not list this system. Q: Add them in the Combat revision (#43) sweep? Recommended: yes.
9. **Tuning Knobs absent** (advisory). Q: Add a table (conversion limit 2, type colours)? Recommended: yes,
   with the blocker fix.
10. **Player Fantasy absent** (advisory). Q: Add one? Recommended: optional; Game Feel covers it.
11. **Nice-to-have:** the Formulas A output range (and AC-DT-15) says at most 4 × the authored parts; the
    tight bound is 3 ×. Q: Tighten it? Recommended: yes, after blocker 2 settles how steps split parts.

### Safe fixes applied to combat-damage-types.md (1)

1. Header Status and Last Updated: "three passes" / "passes 1–3" became "four passes" / "passes 1–4".

## design/gdd/modifiers.md, pass 4

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review). Log: `design/gdd/reviews/modifiers-review-log.md`.
Systems index #40 kept at Needs Revision; its status cell now records passes 2–4.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: modifiers.md, the registry, the skill and `tools/design/modifier_catalogue.py` were UNCHANGED
  since pass 3. effects.md, combat-defence.md and combat-damage-types.md were CHANGED (their own overnight safe
  fixes). I took the skill's path for that case: the prior verdict stands, and only cross-document facts were
  re-verified.
  - combat-damage-types.md rule 2 now says penetration reads only the final type. The Stat List's
    `resist_pen_pct` row ("type scope matches the final type") already says the same.
  - combat-defence.md still cites rule 13 for ward slots. Its variable tables name `resist_pct`,
    `resist_pen_pct`, `reserve_eff_pct`, `healing_pct`, `healing_taken_pct`, `health_regen_pct`,
    `bonus_ward_slots` and `body_shield_pct`, and every one is in the Stat List. Its dependency row no longer
    lists body guard.
  - effects.md still cites rules 1, 6, 9 and 16 correctly.
  - No conflict, so no full re-review.
- Systems-index update: took [A] (kept Needs Revision). Review-log append: took [A].
- Revise now: took [B]. No design choices made unattended; safe fixes only.
- Noticed outside scope (not edited): combat-defence.md line 228 reads "(Modifier System; Formulas H)". This
  GDD has no Formulas H, and the ward price check is combat-defence.md's own Formulas H, so that citation is
  ambiguous. Q: Change it to "(Modifier System Formulas A–C; this GDD's Formulas H for wards)"? Recommended:
  yes, in combat-defence.md's next pass.
- Next step: the user settles the blockers below, then `/design-review design/gdd/modifiers.md` in a fresh session.
  A fifth unattended pass on an unrevised document would only repeat this verdict.

### Blocking findings (not fixed; unchanged from pass 1)

1. **Rule 8 is missing targets the Stat List uses** (heal, reservation, outgoing status, basic attack, outgoing
   soul hit).
   - Q: Add these targets to rule 8, each with what it matches? Recommended: yes. Outgoing status matches the
     status's own tags, a heal its source art's tags, reservation the reserving ward's or art's tags; basic attack
     and outgoing soul hit are outgoing hit narrowed by their implied tag.
2. **Typed resistance's price is ambiguous** (Stat List W 1.0 / 0.83 already includes breadth; Formulas C gives
   +1.5 pp against the catalogue's +1.2 pp).
   - Q: Store one resistance price of 1.25 in `modifier_prices`, with 1.0 / 0.83 described as effective prices?
     Recommended: yes. The catalogue and generator are already right.

### Recommended findings (not fixed; unchanged from pass 3)

3. Rare list incomplete (ward slots 30 W, resistance cap raise 5 W). Q: Add ward slots to rule 13 and the Rare
   table, widen to 10–30 W, treat the cap raise as rare by its row? Recommended: yes.
4. Chaos resistance listed as an ordinary family row. Q: Mark the Chaos-scoped row rare? Recommended: yes
   (Combat Damage Types rule 5 and its Open Question 3).
5. Formulas C range (60 W vs 25.8 W). Q: State both? Recommended: "about 215 units in-tree, up to 500 at 60 W".
6. Stale "reservation kept as Pending" note. Q: Say it is Designed (Combat Defence & Healing rule 10)?
   Recommended: yes.
7. Rule 4 regeneration "per second". Q: Say "per second or per pulse (Stat List)"? Recommended: yes.
8. Interactions table lacks #21a and #21b rows. Q: Add them? Recommended: yes.
9. Bidirectional dependencies missing in many readers. Q: Fold into the Combat revision (#43) and Meridian Map
   sweeps? Recommended: yes.
10. OQ 8 mostly done. Q: Narrow it to registering the full price table in `stat_power_weights`? Recommended: yes.
11. Formulas D `L_i_typ(r)` notation. Q: Drop the (r)? Recommended: yes, unless Combat gives per-realm values.
12. Tuning Knobs section absent (advisory). Q: Add a table? Recommended: yes, at the revision.
13. Player Fantasy section absent (advisory). Q: Add one? Recommended: optional; Game Feel covers it.
14. Cross-References has no effects.md row, though effects.md cites rules 1, 6, 9, 16. Q: Add a row (rules 1, 6,
    15 ↔ effects.md rules 1, 3, 15: payloads, L5 only from Effects)? Recommended: yes.

### Safe fixes applied to modifiers.md (1)

1. Header status line: "passes 1–3" became "passes 1–4".

## design/gdd/effects.md, pass 4

**Verdict: NEEDS REVISION** (lean, workflow standard; re-review of pass 3). Log:
`design/gdd/reviews/effects-review-log.md`. Systems index #41 stays Needs Revision; its status cell now says
four passes, with both blockers still open.

Autonomous-path decisions taken (logged in place of the skill's prompts):
- Freshness check: effects.md, the registry and the skill were UNCHANGED since pass 3. modifiers.md,
  combat-defence.md and combat-damage-types.md had CHANGED, but only by their own pass-4 header status lines. I
  took the skill's path: re-check the cross-document facts and re-issue the verdict. Every rule this GDD cites
  still says what it did (modifiers.md 1, 6, 9, 16; combat-defence.md 5–10, 16–19; combat-damage-types.md 6;
  combat.md is unchanged). The Dependencies status column still matches (#40, #21a and #21b are Needs revision
  and each lists this system). No conflict, so the pass-3 verdict stands.
- Stale-term sweep (body guard, general resistance, [qi], R_gen/R_kind/R_elem): the only hit is line 365, which
  is a record of what was retired. Nothing to fix.
- Systems-index update: took [A], kept Needs Revision. Review-log append: took [A].
- Revise now: took [B] for design items. I made no design choices unattended and applied safe fixes only.
- Next step: answer blockers 1 and 2, then re-run `/design-review design/gdd/effects.md` in a fresh session.
  Passes 2–4 all repeated the verdict on an unrevised document. Skip further unattended passes until the
  blockers are answered.

### Blocking findings (not fixed, carried from pass 1)

1. **Reads missing from rule 5** (Water Table's ward payments, Still Water's regeneration clip, Spillover's
   `dot_pulse_cap` clip, Rime Lock's stack count; overflow in general reads cap clips).
   - Q: Add "a cap's clipped amount (per named cap)", "ward payments against your hits" and "a status's stack
     count on the target" to rule 5? Recommended: yes, each with its read time (clips and payments are events;
     stack count is live).
2. **Actions missing from rule 6** (add a tag, add a slot, skip a roll, multiply a sheet share, fire an art as a
   last act, raise a host cap, change a life output; refusal and counted chance).
   - Q: Add them as named actions in rule 6? Recommended: yes. That keeps the list closed and checkable by
     AC-EF-06.

### Recommended findings (not fixed; unchanged from pass 3)

3. Missing read times on starter reads; the life table has no Reads column. Q: Add them? Recommended: yes
   (conditionals instant start, sheet reads compile, events none).
4. Token closes (Called Blow's fortune clause; Soul Leaves the Body). Q: Is the 0.35 crit cap Called Blow's whole
   cost? Recommended: yes, and drop the fortune clause; the user decides Soul Leaves the Body's cost.
5. Blood Casting vs Withering. Q: Do the two −50 % stack? Recommended: no; one healing-taken floor of −50 %.
6. Corpse Rot vs the duration lint. Q: Exempt standing statuses? Recommended: yes; the tick caps, the upkeep and
   `c_tick ≤ 0.15` bind them instead.
7. Sundered's damage type for a multi-part hit. Q: Which part decides? Recommended: the largest part after
   conversion, ties to the first in Combat Damage Types' order.
8. AC-EF-10's fixture comes from the retired body-ward model. Q: Mark it a *test fixture* now? Recommended: yes,
   and restate it in Combat #43.
9. One-way dependencies (seven hosts don't list Effects; six have no GDD). Q: Add back-references as each host is
   revised? Recommended: yes, Combat #43 first.
10. Player Fantasy and Tuning Knobs absent (advisory). Q: Add a Tuning Knobs table? Recommended: yes, a table
    only, with no values changed.
11. Systems-index row #41 says 44 starter Effects; the GDD holds 46. Q: Correct the index? Recommended: yes.
12. Rule 7 paraphrases the trigger budget without Formulas G's floor. Q: Cite G instead? Recommended: yes.
13. `counted_start` range 0–0.99 vs per-mille storage. Q: State it as 0–999 per mille? Recommended: yes.
14. Capability arithmetic (6 in tables + ~12 rule changes + "the other 19" deferred > 25). Q: Should the deferred
    line read "the remaining ~7 capabilities"? Recommended: yes, once Open Question 4 settles which close nothing.

### Safe fixes applied to effects.md (1)

1. Header Status: "passes 1–3" became "passes 1–4".

(Tracking only, done as the skill directs: systems index row #41 now says four passes.)
