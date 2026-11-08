# Third review: Effects System (Hiệu Ứng), `design/gdd/effects.md` (#41)

Date: 2026-11-08 (night, after commit b5ca784). Method: `/design-review`, lean mode, workflow `standard`, fresh session.
Autonomous: no question could be asked, so each prompt took its recommended option (listed at the end).
Nothing was edited. This file is the only output.

## Verdict: APPROVED

The 16 fixes and 3 user decisions from the second re-review (2026-11-08b) are in the GDD, and they are applied correctly.
The three old blockers are closed. EF-01 (conversions now `convert_pct`), EF-02 (closing-rule action), EF-03
(AC-EF-50) and EF-05 and EF-06 (overkill, one qi burn pool) all match the answers. I found **no blocking problem**.
The new findings are small. The biggest is that the overkill decision reached rule 11 and AC-EF-28, but not Formulas C
or the Edge Cases, and AC-EF-28's double-knockout case is not self-contained. Four closing-rule actions have no test.
One real design question is new: with the three conversions now plain modifiers, nothing limits how much Physical can
become Chaos, which passes body shields. I recomputed every number in the GDD. All hold, including the new
AC-EF-28, AC-EF-48 and AC-EF-50 cases. One test, AC-EF-52, would fail a correct build about 3 times in 100.

**Counts:** 0 BLOCKING, 7 RECOMMENDED, 5 NIT. 11 SAFE, 1 DECISION.

## Completeness (workflow `standard`): 6/6 required sections present

Overview, Detailed Design, Formulas, Edge Cases, Dependencies and Acceptance Criteria are present. Tuning Knobs is
present. Player Fantasy is absent, which is advisory at `standard` (Game Feel covers it). This was logged before.

## Dependency graph

Exist: modifiers.md, combat.md, combat-defence.md, combat-damage-types.md, character-stats.md, canh-gioi.md (Realms),
kinh-mach-do.md (Meridian Map), dao.md, cong-phap.md, item-database.md.
No GDD yet: Talismans, Formations, Alchemy, Spirit Beasts, Event Engine, NPC Builds. Open Question 10 records this, as
the user decided.

## Registry values

I searched effects.md for every registry entry name, with `_` matched as `[_ ]`. Matches: `counted_chance`,
`standing_status`, `down_step`, `curse_heal_taken_max`, `curse_soul_shred_max`, `cooldown_min`, `dot_pulse_cap`,
`heal_pulse_cap`, `resist_floor`, `soul_lockout`, `overkill_epsilon` (named in AC-EF-28 only). Values agree.
- `counted_chance` reads `floor(counted_start/1000 + sum p)`, as Formulas A does.
- `c_comp_cap` has no registry entry. Combat Formulas J holds it at 1.0 (guess), and AC-EF-50 now uses 1.0.
- The 5 % qi burn cap has **no** registry entry and no Tuning Knobs row (EF-10).

## How the 2026-11-08b answers were applied (commit b5ca784)

| Item | Result |
|---|---|
| EF-01 (conversions to `convert_pct`, option A) | Applied. Three rows removed, the line under the table added, rule 2's example and rule 6's action reworded, Scope line updated, the three names dropped from the tier list, AC-EF-58 added. Left over: the inventory-filter count, the now-unused action, the Interactions row, no Edge Case (EF-12). |
| EF-02 (closing-rule action) | Applied exactly as proposed. The six payload cells and Formation Within a Formation name the action. Numeric closes still have no named path (EF-04). |
| EF-03 (AC-EF-50) | Applied. Correct against Combat Formulas J (see numbers). |
| EF-04 (requesting side) | Applied in rule 11 and AC-EF-28. Matches Combat rule 10. |
| EF-05 (last acts add to overkill, option A) | Applied in rule 11 and AC-EF-28. Not in Formulas C or Edge Cases (EF-01). |
| EF-06 (one qi burn pool, option A) | Applied in rule 6, the Qi Disruption row, Spillover's limits and AC-EF-48. Combat #43 restates Formulas F later, as agreed. |
| EF-07 (ACs 56, 57) | Applied. |
| EF-08 (AC-EF-52 sample) | Applied, but the tolerance is too tight (EF-06). |
| EF-09 to EF-16 | Applied. EF-12 is partly done: AC-EF-44 moved, but AC-EF-45 to 47 still sit after AC-EF-58 (they are under "Data and UI", so I did not flag it). |

## Findings

### EF-01 · RECOMMENDED · SAFE. The overkill decision did not reach Formulas C or the Edge Cases

**Location:** Formulas C, variables table, "follow-up check" row (line 517). Edge Cases, "Life costs and Down" (lines 568–569).

**Problem:** Rule 11 now says "A last act's damage counts toward its target's overkill for the instant (Combat Formulas
C), whether or not the target is already Down … Equal shares within `overkill_epsilon` are a draw." Formulas C still reads:
"A Down side keeps its overkill, so a last act wins only if the enemy's overkill share is larger (user decision
2026-11-08)." The Edge Case reads: "If a last act's damage downs the other side: … each side keeps its overkill: the last
act wins only if the enemy's overkill share is larger." Neither says the damage adds to a target that is already Down,
or that equal shares draw. A programmer who reads only Formulas C will not build the double-knockout swing.

**Fix (replace the Formulas C row text):**
> | follow-up check | step | — | Combat rule 10 | Uses Combat's overkill and draw rules. A Down side keeps its overkill. A last act's damage is added to its target's `damage_in_instant` (Combat Formulas C) whether or not that target is already Down, so a last act wins only if the enemy's overkill share ends larger than its own, and shares within `overkill_epsilon` are a draw (user decisions 2026-11-08 and 2026-11-08b, EF-05) |

**Fix (add one Edge Case after line 569):**
> - **If a last act hits a side that is already Down**: its damage adds to that side's overkill for the instant, so it
>   can swing a double knockout (rule 11). Equal shares within `overkill_epsilon` are a draw.

### EF-02 · RECOMMENDED · SAFE. AC-EF-28's double-knockout case is not self-contained, and its draw has no numbers

**Location:** AC-EF-28 (line 701).

**Problem:** The last given reads: "both sides Down in one instant with B the requesting side … B at −10 (share 0.10) hit by
a last act of 20 ends at share 0.30, against A's 0.20, so A wins." Three things are not stated in that given: `health_max`
(100 is only stated in the earlier given), A's 0.20 (also stated earlier) and that B has no last act of its own. B resolves
first, so a B last act would raise A's share before A acts. The draw case also has no numbers.

**Working:** B at −10 with `health_max` 100 has overkill 10 / 100 = 0.10. Adding 20 gives 30 / 100 = 0.30. 0.30 > 0.20, so
B loses and A wins. ✓. For the draw: B standing at 4, a last act of 24 gives (24 − 4) / 100 = 0.20 = A's 0.20, so a draw.
The 44 and 14 cases also hold: (44 − 4) / 100 = 0.40 and (14 − 4) / 100 = 0.10.

**Fix (replace the last two sentences of AC-EF-28 from "WHEN B's share equals" onward):**
> **WHEN** the last act deals 24, B's share is 0.20, equal to A's within `overkill_epsilon`, so it is a draw. **GIVEN**
> both sides Down in one instant, `health_max` 100 on each, B the requesting side with no last act, A at overkill share
> 0.20 and B at −10 (share 0.10), **THEN** B's step resolves first, and A's last act of 20 adds to B's overkill: B's
> share is 0.30 against A's 0.20, so A wins.

### EF-03 · RECOMMENDED · SAFE. Four of the new closing rules have no test

**Location:** Acceptance Criteria; rule 6, "Enforce a closing rule" (line 140).

**Problem:** EF-02's fix named seven kinds of close. Tests exist for the flags (AC-EF-40), a lowered cap (AC-EF-41), a scaled
cost (AC-EF-51) and no regeneration (AC-EF-49). Nothing tests: a forbidden slot kind (Paid in Advance), a shared floor
(Blood Casting with Withering), a scaled pool (Glass Meridians' body shields) or a forbidden companion (Beast Soul Union).
Under the user's answer 13 each new action needs a test.

**Fix (add after AC-EF-58):**
> - **AC-EF-59** [Logic] Paid in Advance (forbid a slot kind). **GIVEN** Paid in Advance and a loadout with a sword art
>   in a slot, **WHEN** compiled, **THEN** it is rejected and names the art; a loadout of talismans, wards and the escape
>   art compiles.
> - **AC-EF-60** [Logic] Blood Casting with Withering (shared floor). **GIVEN** Blood Casting (−50 % healing taken) and
>   Withering (−50 %) on one side and a heal of 100, **THEN** 50 is received, not 0 and not 25, and the Breakdown names
>   the floor.
> - **AC-EF-61** [Logic] Glass Meridians (scale a pool). **GIVEN** a body shield pool of 200 before the keystone,
>   **THEN** it is 100 with it, and maximum health is 25 % lower.
> - **AC-EF-62** [Logic] Beast Soul Union (forbid a companion). **GIVEN** two companions in the loadout, **WHEN**
>   compiled, **THEN** it is rejected and names the second.

Row 140 says "scale a named … pool (… Glass Meridians' body shields)", so AC-EF-61 reads "holds half" as half the pool.

### EF-04 · RECOMMENDED · SAFE. Numeric closes have no named path

**Location:** Rule 14 (line 258); rule 6, "Enforce a closing rule" (line 140). Unyielding Breath (line 380), Glass
Meridians (line 383), Heart Demon's Blade (line 384).

**Problem:** Row 140 lists what a closing rule "may" do: forbid, set flags, lower a cap, scale a named cost or pool, set a
floor. Three `closes` are plain numbers on a stat: Unyielding Breath "Maximum health −15 %", Glass Meridians "Maximum health
−25 %" and Heart Demon's Blade "Qi deviation chance × 2". None is an action, and none is in a payload column, so it is
unclear where the engine applies them. This is the same kind of gap as the old blocker, but here the answer is in the
Modifier System: they are modifiers on live stats (`khi_huyet_pct`, op I; `qi_deviation_pct`, op I; Stat List lines 302
and 365). I rate it RECOMMENDED because rule 3 already allows a payload modifier.

**Fix (add to rule 14):**
> A cost in `closes` that is a plain number on a Stat List stat is granted as a payload modifier at compile, using that
> stat's allowed operation: Unyielding Breath `khi_huyet_pct` −15, Glass Meridians `khi_huyet_pct` −25, Heart Demon's
> Blade `qi_deviation_pct` +100. A close that is a report uses rule 10, and every other close uses the closing-rule action.

Add `khi_huyet_pct` −15, `khi_huyet_pct` −25 and `qi_deviation_pct` +100 to those three Payload cells.

### EF-05 · RECOMMENDED · DECISION. Nothing limits Chaos conversion now

**Location:** Starter Effects, note under "Conversion and overflow" (lines 359–363); Combat Damage Types rules 5–7;
Modifier System Stat List, Damage conversion row (line 284).

**Problem:** Rot Seeps In (25 % Physical → Chaos) was written "low because Chaos passes body shields". It is now a plain
`convert_pct` that "a build reaches … by stacking sources" (line 362). The conversion row is not rare, so any number of
notables can grant Physical → Chaos at +15 pp each. Damage Types rule 6 sums every record on one key and caps the total only
at 100 %. About 7 notables (7 × 15 = 105) turn all Physical into Chaos, which passes body shields by default (Damage Types
rule 4) and is answered only by Chaos or all resistance, which is rare by its row. The old 25 % ceiling was the only
guard, and the user's answer did not say to drop it.

**Options:**
- **A (recommended).** Accept it and record it. It follows the user's PoE-style direction ("slightly OP builds are fine"),
  Chaos resistance is already rare so the answer exists, and the end-of-project balance pass will measure it (Open Question
  1). Add one line under the note: "Stacked conversion into Chaos is watched in the balance pass; Chaos passes body shields."
- **B.** Make the conversion rows that end in Chaos `rare` in the Stat List, like Chaos resistance, so only rare sources carry
  them. Needs a Modifier System edit and a new price check.
- **C.** Cap the share that may become Chaos in one hit (for example 50 %) in Damage Types rule 6. This adds a rule that
  exists for one type.

### EF-06 · RECOMMENDED · SAFE. AC-EF-52's tolerance fails a correct build about 3 times in 100

**Location:** AC-EF-52 (line 728).

**Problem:** "over seeds 1–10,000 the share … is between 0.29 and 0.31". The seed set is fixed, so each build either passes
or fails for good, but the chance a correct 30 % build lands outside the band is not small.

**Working:** n = 10,000, p = 0.3. Standard deviation = √(0.3 × 0.7 / 10,000) = √0.000021 = 0.00458. The band edge is 0.01
away: z = 0.01 / 0.00458 = 2.18. Two-sided chance outside = about 2 × 0.0146 = 0.029, so 2.9 %. The last report called this
"about 2.2 σ" and accepted it, but it was never shown to be a pass-rate problem. A failure would push someone to change
the seed list until it passes.

**Fix:** change "between 0.29 and 0.31" to "between 0.28 and 0.32". Then z = 0.02 / 0.00458 = 4.36, and the chance a correct
build fails is about 0.0013 % (1.3 × 10⁻⁵).

### EF-07 · RECOMMENDED · SAFE. Dependencies table still says the Modifier System "Needs revision"

**Location:** Dependencies, Modifier System row (line 585).

**Problem:** The systems index records Modifier System (#40) as **APPROVED** after the 2026-11-08b re-review. The cell says
"Needs revision". The Combat Defence & Healing and Combat Damage Types cells ("Needs revision") are right: both are still open.

**Fix:** change the cell to "Approved (2026-11-08b)".

### EF-08 · NIT · SAFE. AC-EF-45's lint does not check `domain` and `tags`, and statuses carry no tier

**Location:** AC-EF-45 (line 738); "Domain and tags" (lines 406–411); line 312.

**Problem:** The Domain and tags paragraph says "the smoke check's lint (AC-EF-45) checks they match this rule". AC-EF-45
lists rule-1 fields, price, tier, `closes`, tick type and curse rule, but not `domain` or `tags`. It also says "every Effect
has … a valid `tier`", yet line 312 says "Statuses carry no tier". Statuses are Effects (Overview), so the lint's scope is
unclear.

**Fix:** in AC-EF-45, replace "every Effect has all rule-1 fields with `price: unpriced` and a valid `tier`" with "every
Effect other than a status has all rule-1 fields with `price: unpriced` and a valid `tier` (statuses carry none), every
Effect's `domain` and `tags` match the Domain and tags rule and use only tags in the shared vocabulary (Modifier System rule
9)". Apply the same "other than a status" to the tier sentence in rule 4's Edge Case (line 537).

### EF-09 · NIT · SAFE. The kind-tag list omits `status`

**Location:** "Domain and tags" (lines 408–409).

**Problem:** Each record's tags are "its kind (`conditional`, `scaling`, `trigger`, `conversion`, `overflow`, `rule_change`,
`keystone`, `enabler`)". That is 8 kinds. Rule 2 and Modifier System rule 9's "effect kind" row both list 9, including `status`.

**Fix:** add `status` after `overflow`... in rule 2's order: `conditional`, `scaling`, `trigger`, `conversion`, `overflow`,
`rule_change`, `status`, `keystone`, `enabler`.

### EF-10 · NIT · SAFE. The 5 % qi burn cap is not a knob and has no registry entry

**Location:** Tuning Knobs (lines 646–654); registry.

**Problem:** The cap is now an Effects rule with its own AC (AC-EF-48), but it appears only in text. Combat owns the number
and #43 will restate it. Nothing in the registry names it.

**Fix:** add a Tuning Knobs row: "`qi_burn_cap` | 5 % of the target's `qi_max` per pulse, one pool for all burns | 3–10 % |
How much linh lực one pulse can burn | Rule 6; Combat Formulas F". Ask the registry owner to add a constant `qi_burn_cap`
(0.05, source Combat Formulas F, referenced by effects.md, combat-damage-types.md and combat.md). The range is a design
estimate. This GDD should not edit the registry.

### EF-11 · NIT · SAFE. The "Last Updated" line is stale

**Location:** Header, line 5.

**Problem:** "2026-11-08 (re-review answers applied; see `reviews/rereview-2026-11-08-decisions.md`)". The Status line (line 3)
already covers the 2026-11-08b round.

**Fix:** "2026-11-08 (second re-review 2026-11-08b applied; see `reviews/rereview-2026-11-08b/effects.md`)".

### EF-12 · NIT · SAFE. Leftovers from moving the three conversions out

**Location:** Rule 6, "Convert a share of a hit, under a condition" (line 141); Interactions, Combat Damage Types row (line
452); Inventory filter (lines 417–428); Edge Cases, Records (line 535).

**Problem:** (1) No starter uses the "convert a share of a hit, under a condition" action now: Field Walls grants `defense_pct`
and does not convert a hit. (2) The Interactions row still says "Conversion Effect records" with no "none yet".
(3) The inventory filter still counts the three as kept ("about 55 kept", "about 25 are plain numbers") — the earlier review
asked for it to match. (4) There is no Edge Case for the case AC-EF-58 tests.

**Fix:**
1. Row 141: append "(none in the starter set yet)", as Damage Types rule 8 does for element-relation Effects.
2. Row 452: "Conditional conversion Effect records (none yet); statuses' damage types".
3. Change "About 55 inventory rows were kept" to "About 52", and "about 25 are plain numbers" to "about 28 are plain numbers
   (including the three scoped conversions)". The sum stays: 52 + 28 + 30 + 130 + 30 + 20 + 40 + 30 = 360.
4. Add to Edge Cases, Records: "**If an Effect's only payload is an unconditional, tag-scoped conversion share**: it is
   flagged as a `convert_pct` modifier, not an Effect (rule 3; AC-EF-58)."

## Advisory (no action needed)

- Player Fantasy is absent (advisory at `standard`; Game Feel covers it).
- Formulas C's example uses Parting Curse, which is not in the catalogue (logged in pass 2). Formulas C numbers wounds as
  step 4 and rule 11 as step 3 (logged in pass 2). Both still stand.
- Systems index row 41's first sentence still says "46 starter Effects" while its last sentence says 43. The index is outside
  this review; 43 is right (see the count below).
- The Part 2 reference says "361 effect candidates"; the inventory filter sums to 360. The filter says "about" throughout, so
  I did not raise it.
- Overheat's Reads cell says "the art's cooldown". Rule 5's wording is "an art's authored record (cooldown, cost, parts)".
  Same meaning; adopt the wording when the record is next touched.

## Numbers recomputed

All hold unless noted.

- **Starter count:** Conditional 5 + Scaling 4 + Trigger 9 + Conversion and overflow 4 + Rule change 5 + Keystones 7 +
  Enablers 5 + Life 4 = 43 ✓ (the commit message and the index say 43). Statuses: 7 ticks + 9 curses = 16 ✓.
- **Tiers:** 13 `major` named (Flowing Water, Echo, Shattering Ward, Blood Drinker, Final Clause, Marked Prey, Gorged, Field
  Walls, Overheat, Elemental Fist, Measured Stroke, Talisman Sleeve, Great Essence-Draining Art); each exists. Keystones 7 +
  2 life keystones = 9; enablers 5; the rest minor: 43 − 13 − 9 − 5 = 16.
- **Capabilities:** 25 − 6 − 12 = 7. The 6 are #5, #9, #11, #15, #17, #25 (all in the tables); the 12 listed at line 414
  number 12 ✓.
- **Formulas A:** 0.3, 0.6, 0.9, 1.2 → crit, 0.2; 0.5, 0.8, 1.1 → crit, 0.1; 0.4, 0.7, 1.0 → crit, 0. Crits on hits 4, 7 and 10;
  floor(0 + 10 × 0.3) = 3 ✓ (AC-EF-30). 0.2875 → 287.5 → 288 half up ✓.
- **Formulas B / AC-EF-18:** 0.03 × 172.7 = 5.181 ✓ (5.2). Regeneration 0.02 × 172.7 = 3.454 ✓ (3.45).
- **AC-EF-24:** 3 × 0.15 + 0.10 = 0.55, clipped to 0.50 ✓; −0.20 − 0.50 = −0.70, floored at −0.50 ✓.
- **AC-EF-27:** 50 − 30 = 20 ✓. **AC-EF-36:** 0.25 × 0.5 = 0.125 ✓; 0.8 × 0.8 = 0.64 ✓. **AC-EF-37:** 6 % × 200 = 12 ✓.
- **AC-EF-38:** 4 % × 1,000 = 40; 40 − 30 = 10 < 20 ✓. **AC-EF-39:** 2 % ✓. **AC-EF-41:** min(0.35, 0.50) = 0.35 ✓.
- **AC-EF-43:** 10 % × 1,000 = 100 ✓. **AC-EF-49:** 30 % × 20 = 6, room 5 → 5 ✓.
- **AC-EF-28 (new cases):** (44 − 4)/100 = 0.40 > 0.20 → A wins ✓; (14 − 4)/100 = 0.10 < 0.20 → B wins ✓; B at −10 plus
  20: (10 + 20)/100 = 0.30 > 0.20 → A wins ✓. Overkill follows Combat Formulas C (`max(0, damage_in_instant − health_at_instant_start) /
  health_max`) and rule 10 (larger share loses, epsilon draw).
- **AC-EF-48 (new case):** 5 % × 200 = 10; 7 + 6 = 13; 13 − 10 = 3 clipped ✓.
- **AC-EF-50:** 0.40 × 2 = 0.80 < 1.0 ✓; 0.60 × 2 = 1.20 → 1.0 ✓ (Combat Formulas J: `min(c_comp_cap, share / (B_p · stage_mult))`,
  `c_comp_cap` 1.0).
- **AC-EF-52:** see EF-06 (z = 2.18, 2.9 % false fail at the current band).
- **Curse bounds:** Heavy Breath 2 × 25 % = 50 % ✓; Slackened Soul 2 × 0.15 = 0.30 ✓; Sundered 3 × 0.15 = 0.45.
- **Status lint** `c_tick · duration ≤ 1.2` (per stack): Burn 1.05, Poison 0.75, Bleed 0.80, Frostbite 0.80, Shock 1.00,
  Qi Disruption 0.90 ✓. Corpse Rot `c_tick` 0.15 ≤ 0.15 ✓.
- **AC-EF-10:** 0.5 × 15.9 = 7.95, shown 7.9; the fixture is marked as retired-model numbers, so I did not retrace it.

## Scope signal

L (multi-system; three formulas; touches Combat #43, Defence, Damage Types and Modifiers). The producer should verify this.

## Autonomous decisions taken in place of the skill's prompts

- Freshness check: the GDD (hash changed from the 2026-11-08b review) and the registry changed, so I ran a full review. The
  skill file is unchanged.
- Specialists: none (lean mode).
- Verdict APPROVED, so the "revise now" widget is skipped. The recommended and nit findings are for a later pass.
- Systems-index update and review-log append: not done. This run may write only this file. When the user accepts the
  verdict, the log entry should read: "2026-11-08c third review: APPROVED, 0 blocking, 7 recommended, 5 nits (1 decision, EF-05)".
- Next step: answer EF-05, apply the SAFE fixes (EF-01 to EF-04 and EF-06 to EF-12), then run `/consistency-check` and
  `/review-all-gdds`.

## Receipt (files read for cross-document facts)

```
Reviewed-Content-Hash: design/gdd/effects.md bd7b07768842bc04af19c64ce3abb06c328fd06b
Reviewed-Content-Hash: design/registry/entities.yaml dd26d53922f7d88e4d5d1c95d87e683815659a28
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md e0830493051ab814876c309da6a76af47b1c84c3
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md 55db19db7fc1332510207d5bc2700c484277f31e
Reviewed-Content-Hash: design/gdd/combat-damage-types.md feae748a1ad6e748e9b5c77b91f7b8756f4019f2
Reviewed-Content-Hash: design/gdd/character-stats.md 27472baa013800bfd1910fdede1a3e253e4d4342
```
