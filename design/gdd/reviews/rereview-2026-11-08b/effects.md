# Re-review: Effects System (Hiệu Ứng), `design/gdd/effects.md` (#41)

Date: 2026-11-08 (evening, after commit 9400de1). Method: `/design-review`, lean mode, workflow `standard`.
Autonomous: no question could be asked, so each prompt took its recommended option (noted at the end).

## Verdict: NEEDS REVISION

The 24 answers from the daytime re-review are in the GDD, and nearly all of them are applied cleanly. The three old
blockers are closed. Every read and action they named is now on rule 5's and rule 6's lists. The qi-tick path matches
Combat Damage Types rule 4 and AC-DT-30. Rule 11 and Formulas C now say a last act is won on overkill. Three new
defects block. (1) The user allowed conversion modifiers (`convert_pct`, re-review DT 2), but this GDD was not
updated. Three starter conversions are now plain scoped numbers, which rule 3 says are modifiers, never Effects.
(2) Rule 6's new "enforce a closing rule" action lists only the four closes the last review named. Called Blow's
lowered crit cap and Formation Within a Formation's doubled upkeep still have no action. (3) AC-EF-50 uses
`c_comp_cap` 0.35, but Combat Formulas J sets it at 1.0, so the test cannot pass. The other findings are wording,
cross-references and missing ACs. I recomputed every number in the GDD by hand, and they all hold apart from
AC-EF-50.

**Counts:** 3 BLOCKING, 7 RECOMMENDED, 6 NIT. 12 SAFE, 4 DECISION.

## Completeness (workflow `standard`): 6/6 required sections present

Overview, Detailed Design, Formulas, Edge Cases, Dependencies and Acceptance Criteria are all present. Tuning Knobs is
present too. Player Fantasy is absent, which is advisory at `standard` (Game Feel covers it). This was logged before.

## Dependency graph

All five named dependency GDDs exist: modifiers, combat, combat-defence, combat-damage-types and character-stats.
Talismans, Formations, Alchemy, Spirit Beasts, the Event Engine and NPC Builds have no GDD. Open Question 10 records
this, as the user decided.

## Registry values

I searched effects.md for every registry entry name, matching `_` as `[_ ]`. The names that matched are
`cooldown_min`, `counted_chance`, `curse_bounds`, `curse_heal_taken_max`, `curse_soul_shred_max`, `dot_pool_cap`,
`dot_pulse_cap`, `down_step`, `heal_pulse_cap`, `layer_caps`, `qi_deviation_chance`, `resist_floor` (−0.5),
`soul_lockout`, `standing_status` and `body_guard`. `body_guard` appears once, in the list
of retired mechanics. All of their values agree with the registry. `counted_chance` now reads
`floor(counted_start/1000 + sum p)`, as answer EF 17 asked. `c_comp_cap` has no registry entry. Combat Formulas J
holds it at 1.0 (see EF-03).

## How the answers were applied (check of `rereview-2026-11-08-decisions.md` items 1–24)

- Applied correctly: items 1, 3, 4, 5, 6, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21 (the CDT sentence is gone),
  22, 23 and 24.
- Item 2 (actions): applied, but the closing action is narrower than the answer (EF-02).
- Item 7 (order and overkill): applied, but with the wrong name for the side that goes first (EF-04). The both-Down
  case is left open (EF-05).
- Item 13 (an AC for each new read and action): eight new ACs were added. A death in an event, the stage read and
  the cultivation-base report still have none (EF-07).
- Not an item, but a consequence: the DT 2 answer (conversion modifiers allowed) did not reach this GDD (EF-01, EF-09).

## Findings

### EF-01 · BLOCKING · DECISION. Three starter conversions are now modifiers under rule 3

**Location:** Starter Effects, "Conversion and overflow" (lines 350–352); Core Rules rule 3 (line 80).

**Problem:** Rule 3 says: "If a piece is a plain number on one stat, optionally narrowed by tags, it is a modifier
(Modifier System), never an Effect." After answer DT 2, conversion is the ordinary stat `convert_pct`. Modifier
System rule 8 says "A scope narrows it by the art's tags", and its Stat List says "A conversion with a condition is
still an Effect." None of these three has a condition:
- Flame-Tempered Edge: "40 % of the Physical in your sword hits becomes Fire." This is `convert_pct` Physical → Fire,
  scope [sword].
- Thunder Palm: "50 % of the Force in your palm hits becomes Lightning." This is `convert_pct` Force → Lightning,
  scope [palm].
- Rot Seeps In: "25 % of the Physical in your Wood-element hits becomes Chaos." This is `convert_pct` Physical →
  Chaos, scope [moc].

So by the GDD's own rule 3 and the user's Modifier vs Effect rule, these three are modifiers. Field Walls stays an
Effect, because it has a condition ("if your formation is prepared") and counts one quantity as another.

**Working (what they would cost as modifiers):** price 0.8 W per pp, with damage conversion's implied family breadth
×1.5 (AC-MD-32: 1.2 × 1.5 / 0.8 = 2.25, floored to +2 pp; a notable is 8 × 1.5 / 0.8 = +15 pp). So 40 pp needs
40 × 0.8 / 1.5 = 21.3 W, 50 pp needs 26.7 W, and 25 pp needs 13.3 W. All three are above a notable (8 W).

**Options:**
- **A (recommended).** Move all three to the Modifier System as `convert_pct` grants at catalogue grades (+15 pp on
  a notable). A build reaches 40–50 % by stacking sources, inside the 2-per-hit limit, as in PoE. Remove the three
  rows here and add one line under the table: "Plain scoped conversions are `convert_pct` modifiers (re-review DT 2);
  only conditional conversions are Effects." Update the inventory-filter count to match.
- **B.** Keep them as Effects by giving each a real rule, for example "while your linh lực is above half" or "on
  your first sword art each pulse". Each keeps its size and tier, but gains a condition it may not need.
- **C.** Keep them as written and add an exception to rule 3: "a conversion above a notable's grade is an Effect."
  This adds a second exception to the Modifier vs Effect rule, so it is not recommended.

### EF-02 · BLOCKING · SAFE. The closing-rule action misses closes that starters use

**Location:** Core Rules rule 6, action table (line 140). Called Blow (line 372). Formation Within a Formation
(line 397). Glass Meridians (line 376). Blood Casting (line 384).

**Problem:** The action reads: "Enforce a closing rule at compile: forbid a ward, a slot kind, a companion or
regeneration, or set Combat Defence & Healing's `cannot_slot_wards` and `no_default_ward` flags." The answer to item 2
was "enforce a closing rule at compile". The applied text lists only the four closes the last review named. Other
closes still have no action:
- Called Blow, "Crit chance cap 0.50 → 0.35". Lowering a cap is not an action; rule 6 can only "Raise a host's cap".
- Formation Within a Formation, "Upkeep for those levels × 2". `formation_upkeep_pct` is unscoped and Pending, so it
  cannot reach only two levels.
- Glass Meridians, "your body shields hold half". The only modifier path is `body_shield_pct` I, which is Pending
  and adds nothing today.
- Blood Casting, "one floor with Withering: together they never go below −50 %". A shared floor is a rule, not a
  modifier.

Under the Edge Cases ("uses an action not on the action list: it is rejected"), Called Blow and Formation Within a
Formation would be rejected. This is the same class of defect as the old blocker 2.

**Fix (replacement text for that action row):**
> | Enforce a closing rule at compile: the `closes` of a keystone or enabler, applied for the whole fight. It may
> forbid (a ward, a slot kind, a companion, regeneration), set Combat Defence & Healing's `cannot_slot_wards` and
> `no_default_ward` flags, lower an owner's cap (Called Blow's crit cap), scale a named cost or pool (Formation
> Within a Formation's upkeep, Glass Meridians' body shields), or set a shared floor (Blood Casting with Withering)
> (re-review EF 2) | the rule's owner |

Add "Enforce a closing rule" to the Payload column of Called Blow, Glass Meridians, Blood Casting, Paid in Advance,
Water Table and Beast Soul Union, and the life version to Formation Within a Formation. This matches No Ward, which
already names it.

### EF-03 · BLOCKING · SAFE. AC-EF-50 uses a `c_comp_cap` that Combat does not have

**Location:** Acceptance Criteria, AC-EF-50 (line 718).

**Problem:** "GIVEN a strongest companion share of 0.20 and `c_comp_cap` 0.35, THEN the share is 0.35, clipped by
its owner's cap." Combat Formulas J defines `c_comp = min(c_comp_cap, share / (B_p · stage_mult))` with
`c_comp_cap` = **1.0 (guess)**. The cap clips `c_comp`, not the share, and the registry has no `c_comp_cap` entry.

**Working:** 0.20 × 2 = 0.40. Against the real cap of 1.0, nothing is clipped, so the test fails as written.

**Fix (replacement text):**
> **AC-EF-50** [Logic] Beast Soul Union (multiply a share). **GIVEN** a strongest companion whose
> `share / (B_p · stage_mult)` is 0.40, **THEN** its `c_comp` is 0.80. **GIVEN** 0.60, **THEN** 1.20 is clipped to
> 1.0 (`c_comp_cap`, Combat Formulas J) and the Breakdown names the cap.

### EF-04 · RECOMMENDED · SAFE. "The side that requested the defeat check" is not a Combat term

**Location:** Core Rules rule 11, "Order and overkill" (line 225). AC-EF-28 (line 694).

**Problem:** Rule 11 says "the side that requested the defeat check resolves first (Combat rule 10)". AC-EF-28 says
"with B requesting the check". No side requests a defeat check. In Combat rule 10, the **requesting side** is "the one
the Event Engine names as opening the fight, the player's side when the player did, else side A". Formulas C already
says this correctly: "the requesting side first (Combat rule 10)".

**Fix:** In rule 11, replace "the side that requested the defeat check resolves first (Combat rule 10)" with "the
requesting side (the side that opened the fight, Combat rule 10) resolves first". In AC-EF-28, replace "with B
requesting the check" with "with B the requesting side".

### EF-05 · RECOMMENDED · DECISION. In a double knockout, does last-act damage add to overkill?

**Location:** Core Rules rule 11 (lines 215–227). Formulas C (line 502). AC-EF-28 (line 694).

**Problem:** Rule 11 says "a last act that downs the enemy wins the fight only if the enemy's overkill share is
larger than its own". When both sides are already Down in one instant, neither last act "downs" anyone. The GDD does
not say whether a last act's damage then adds to the other side's overkill share. AC-EF-28 mixes the two cases: it
gives "both sides Down in one instant", then has "A's last act then downs B". It also has no case for equal shares,
which Combat rule 10 calls a draw (within `overkill_epsilon`).

**Options:**
- **A (recommended).** Last-act damage always counts in Combat Formulas C's `damage_in_instant` for its target. Its
  overkill is measured against health at the instant's start. So a last act can swing a double knockout, which fits
  the user's "overkill can win the last act". Add to rule 11: "A last act's damage counts toward its target's overkill
  for the instant (Combat Formulas C), whether or not the target is already Down."
- **B.** A last act against a side already Down changes nothing. Only a standing enemy can be downed by it.

**AC fix, for either option.** Split AC-EF-28 into two givens. (i) "A Down, B standing at 4 with `health_max` 100. A's
last act deals 44: B's share is 0.40 against A's 0.20, so A wins. If it deals 14, B's share is 0.10, so B wins. If
B's share equals A's to within `overkill_epsilon`, it is a draw." Check: (44 − 4) / 100 = 0.40, and (14 − 4) / 100 =
0.10. (ii) "Both Down, B the requesting side. B's step resolves first," then the case for whichever option is chosen.

### EF-06 · RECOMMENDED · DECISION. Is the 5 % qi burn cap per tick, per source, or one pool per pulse?

**Location:** Rule 6, "Burn linh lực" (line 139). Status Catalogue, Qi Disruption (line 277). Spillover (line 354).

**Problem:** Combat Formulas F reads "A qi burn status ticks linh lực instead, capped at 5 % of `qi_max`", which is a
per-tick cap. Effects reads "at most 5 % of `qi_max` a pulse" and "inside the 5 % qi burn cap per pulse". With Qi
Disruption alone the two readings agree, because it ticks once a pulse. With Spillover in the same pulse they differ:
up to 5 % plus Spillover's burn, or 5 % in total.

**Options:**
- **A (recommended).** One pool: all linh lực burns on one target in one pulse (Qi Disruption ticks and Spillover)
  total at most 5 % of `qi_max`. The excess is clipped and logged "qi burn cap". Combat #43 restates Formulas F to
  match. Add a Spillover case to AC-EF-48.
- **B.** 5 % per source per pulse, so the two can reach 10 % together.

### EF-07 · RECOMMENDED · SAFE. Answer 13's ACs miss two reads and one report

**Location:** Acceptance Criteria, AC-EF-48 to 55 (lines 716–723).

**Problem:** Answer 13 was "add a criterion for each reviewed read and action that has none". No AC covers these:
the event "a death in an event" and the event's outcome (Soul Leaves the Body); the stage read before the fight; and
the reported cultivation base and heart demon (Great Essence-Draining Art). Rule 10 newly lists "cultivation base or
stage" (answer 9), but no AC tests it.

**Fix (add):**
> **AC-EF-56** [Integration] Soul Leaves the Body (death in an event; change a life output). **GIVEN** an event that
> would kill the character, **THEN** they survive at 5 % vitality, the result reports one stage lost, and a second
> death in the same realm kills.
>
> **AC-EF-57** [Integration] Great Essence-Draining Art (stage read before the fight; rule 10). **GIVEN** a stage
> whose span is S cultivation base (*test fixture*), **WHEN** the side knocks out a cultivator, **THEN** the result
> reports +0.05 · S base and +2 heart demon, the sheet is unchanged until the caller applies it, and a creature
> knockout reports nothing.

### EF-08 · RECOMMENDED · SAFE. AC-EF-52's "30 % of seeds" has no sample or tolerance

**Location:** AC-EF-52 (line 720).

**Problem:** "30 % of seeds yield a lesser pill instead of ash" cannot pass or fail without a sample size and a
tolerance.

**Fix (replacement text):** "...**THEN** over seeds 1–10,000 the share that yields a lesser pill is between 0.29 and
0.31, the same seed always gives the same result, and a fight's stream is untouched." With n = 10,000, the binomial
standard deviation is √(0.3 · 0.7 / 10,000) = 0.0046, so ±0.01 is about 2.2 σ. The seed set is fixed, so the result
is deterministic.

### EF-09 · RECOMMENDED · SAFE. Rule 2's Conversion example is now a modifier

**Location:** Core Rules rule 2, Kind table, Conversion row (line 73).

**Problem:** The example "40 % of Physical damage becomes Fire" is an unconditional `convert_pct`, so it is a
modifier (Modifier System Stat List, re-review DT 2). This holds whichever option EF-01 takes.

**Fix:** Replace the example with "while your formation is prepared, half your formation power counts as ward
strength". Add to the "It…" cell: "with a condition or a rule; a plain share converted is the `convert_pct` modifier".

### EF-10 · RECOMMENDED · SAFE. Final Clause's reads omit the cooldown it picks by

**Location:** Starter Effects, Final Clause (line 344).

**Problem:** It fires "your longest-cooldown art", but its Reads column holds only "Down step 2 (event)". The read
"an art's authored record (cooldown, cost, parts)" was added for exactly this (answer 1; Measured Stroke uses it).

**Fix:** Change Reads to "Down step 2 (event); an art's authored record (cooldown), compile". Note in the rule that
"longest" means the authored cooldown.

### EF-11 · NIT · SAFE. One edge case omits stacking "none"

**Location:** Edge Cases, Statuses (line 550).

**Problem:** "it refreshes the duration, unless the record says it stacks or the stronger wins." Line 564 and rule 9
add "none".

**Fix:** "...unless the record says it stacks, the stronger wins, or none (then nothing happens)."

### EF-12 · NIT · SAFE. AC-EF-44 sits after AC-EF-55

**Location:** Acceptance Criteria (lines 716–724).

**Fix:** Move AC-EF-44 above AC-EF-48, so the order is 43, 44, 48–55.

### EF-13 · NIT · SAFE. Rule 11 does not cite Defence's "a refusal is not healing"

**Location:** Core Rules rule 11, step 1 (line 211).

**Fix:** Append to step 1: "A refusal is not healing: it works under `no_heal` and takes no decay or cap (Combat
Defence & Healing rule 19)." Add rule 19 to the combat-defence.md Cross-References row (line 627).

### EF-14 · NIT · SAFE. The Character Stats interaction row lists fewer outputs than rule 10

**Location:** Interactions with Other Systems, Character Stats and Realms row (line 446).

**Problem:** "Out: reported heart demon, years, toxicity, purity". Rule 10 also reports seasons, spirit stones,
cultivation base and stage.

**Fix:** "Out: reported heart demon, lifespan years, seasons, toxicity, spirit stones, root purity, cultivation base
and stage (applied by the caller; rule 10)".

### EF-15 · NIT · SAFE. Effect kind tags are not in the shared vocabulary

**Location:** Rule 1 `domain`, `tags` (line 60). "Domain and tags" (lines 399–404).

**Problem:** The kind tags (`conditional` … `enabler`) are not a family in Modifier System rule 9's table, and that
rule says "Unknown tags fail validation." Rule 1 allows "plus its kind", so this is a gap in the shared table, not a
contradiction.

**Fix:** When modifiers.md is next revised, add the row "effect kind | conditional, scaling, trigger, conversion,
overflow, rule_change, status, keystone, enabler | Effects System rule 2". Until then, AC-EF-45's lint treats kind
tags as valid.

### EF-16 · NIT · SAFE. The "close nothing (about 12)" list leaves out #9 and #11

**Location:** "Capabilities without a closing cost" (lines 406–408).

**Problem:** Great Essence-Draining Art (#9, a Trigger) and Strange Pill Reborn (#11, a rule change) also close
nothing. The count in the inventory filter, 25 − 6 − 12 = 7, still holds, because those two are among the 6.

**Fix:** "...the other live capabilities that close nothing (about 12, ...) are rule-change Effects; #9 and #11 above
are re-expressed already."

## Advisory (no action needed)

- Player Fantasy is absent (advisory at `standard`).
- Formulas C's example uses Parting Curse, which is not in the catalogue (logged in pass 2).
- Heart Demon's Blade's "qi deviation chance × 2" is `qi_deviation_pct` +100. It doubles only when no other source
  is present (Character Stats: "+100 doubles it").

## Numbers recomputed (all hold except AC-EF-50)

- Formulas A: meter 0.3/0.6/0.9/1.2→0.2, 0.5/0.8/1.1→0.1, 0.4/0.7/1.0→0. Crits on hits 4, 7 and 10; floor(0 + 10 ×
  0.3) = 3; the meter reads 0 after hit 10 (AC-EF-30). 0.2875 → 287.5 per mille → 288, half up.
- Formulas B / AC-EF-18: 0.03 × 172.7 = 5.181 (shown 5.2).
- AC-EF-24: 3 × 0.15 + 0.10 = 0.55 → 0.50; −0.20 − 0.50 = −0.70 → −0.50 floor.
- AC-EF-27: 50 − 30 = 20 → L5 +20. AC-EF-36: 0.25 × 0.5 = 0.125. AC-EF-37: 6 % × 200 = 12.
- AC-EF-38: 0.04 × 1,000 = 40 cap; 40 − 30 = 10 < 20. AC-EF-41: p = min(0.50, 0.35) = 0.35. AC-EF-43: 10 % ×
  1,000 = 100.
- AC-EF-49: 0.3 × 20 = 6, room 5 → 5. AC-EF-51: 5 + 2 = 7. AC-EF-21: Bleed duration 4 from pulse 0 → ticks 1–4;
  from pulse 2 → ticks 3–6.
- AC-EF-50: 0.20 × 2 = 0.40, which a cap of 1.0 does not clip (EF-03).
- Inventory filter: 25 − 6 − 12 = 7 capabilities deferred.

## Scope signal

L (multi-system; three formulas; touches Combat #43, Defence, Damage Types and Modifiers). The producer should
verify this.

## Autonomous decisions taken in place of the skill's prompts

- Freshness check: the target doc and the registry had changed, so I ran a full review.
- "Revise now": [B], stop here. This run may not edit the GDD.
- Systems-index update and review-log append: not done. This run may write only this file.
- Next step: the user answers EF-01, EF-05 and EF-06 and applies the SAFE fixes. Then re-run
  `/design-review design/gdd/effects.md`.

## Receipt (files read for cross-document facts)

```
Reviewed-Content-Hash: design/gdd/effects.md 14e81c39b84bff5c990bc5107238b04d02ee1057
Reviewed-Content-Hash: design/registry/entities.yaml ac878f4ba052784ff9d30c5644895fa02b2a749f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/modifiers.md ed917d95c2d6f5c192bc64e2c69ffd46bd1446d4
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/combat-defence.md 60f394cb00c668833ff5cd7f23537f7de99c8ec1
Reviewed-Content-Hash: design/gdd/combat-damage-types.md f7345f06383f80850cb4d93e1897e1f2d47c8cba
Reviewed-Content-Hash: design/gdd/character-stats.md ccaf54f7567702bdf35d889ddc679f30f55edd77
```
