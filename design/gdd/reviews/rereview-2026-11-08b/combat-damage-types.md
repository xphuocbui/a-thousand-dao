# Re-review — Combat Damage Types (Loại Sát Thương), #21b — 2026-11-08 (evening)

Target: `design/gdd/combat-damage-types.md` (as of commit 9400de1). Method: `/design-review`, lean mode, workflow
`standard`, run unattended. No file other than this one was edited.

## Verdict: NEEDS REVISION

The user's answers from the last round are in the GDD, and most of them are applied well. Conversion modifiers
(`convert_pct`) are now an ordinary modifier and sit in the modifier step. The root is now Primordial Chaos (Hỗn Độn),
and the damage type keeps the name Chaos (Tà). The qi-tick path, the order inside a step, removing a part at share 0,
rejecting a conversion to its own type, the free-hit rule, the fixed order of types and the Light colour are all in.
Every number was recomputed by hand and holds. One blocker is new, and it comes from allowing conversion modifiers.
Modifiers of one stat add up (Modifier System rules 4–5), so several `convert_pct` records have no "slot order,
then record id" of their own. The GDD does not say whether they count as one conversion or many, or in what order
two different keys run. The other findings are smaller. Some places were not updated to match the decisions: the
registry, Combat Defence's path table, and the list of files to rename. A few wording gaps let the limit of 2 be
read two ways.

Counts: 1 blocking, 9 recommended, 4 nit. 10 SAFE, 4 DECISION.

## Checks

- **Completeness (workflow `standard`): 6/6 required sections present.** These are Overview, Detailed Design, Formulas
  (required, because the system has numeric rules), Edge Cases, Dependencies and Acceptance Criteria. Tuning Knobs is
  also present. Player Fantasy is absent. That is advisory at `standard`, and Game Feel covers most of it.
- **Dependency graph.** These GDDs exist: combat.md, combat-defence.md, linh-can.md, modifiers.md, effects.md,
  cong-phap.md, thien-kiep.md and item-database.md.
- **Applied decisions checked.**
  - DT 1, order inside a step: applied, but see DT-01 to DT-03.
  - DT 2, conversion modifiers: applied in rule 6, Formulas A, Interactions and AC-DT-31. modifiers.md has the
    matching Stat List row and AC-MD-32.
  - DT 3, the qi tick: applied in rule 4, AC-DT-30, effects.md's Qi Disruption row and AC-EF-26. Combat Defence
    is not updated (DT-05).
  - DT 5, penetration scope: applied, and it agrees with Modifier rule 8.
  - DT 6, Light's colour: applied (checked below).
  - DT 7, free hits: applied.
  - DT 12, Primordial Chaos: applied in rule 3 and OQ 1. The rename list is incomplete (DT-09).
  - DT 15 (share 0), DT 16 (ticks) and DT 17 (the fixed order) are applied. effects.md's Sundered and Modifier
    rule 8 both cite the fixed order.
  - DT 19 (element-relation Effects): applied.
- **Arithmetic, recomputed by hand. All of it holds.**
  - Formulas A, first example: 0.6 × 1.3 + 0.2 × 1.7 + 0.2 × 1.9 = 0.78 + 0.34 + 0.38 = 1.50, so 150.
  - Lava: 0.78 + 0.68 = 1.46, so 146.
  - The thể tu example and AC-DT-19:
    - Physical 41.3 × 0.6 × 0.4 = 9.912, and Fire 41.3 × 0.4 × 0.7 = 11.564. The sum is 21.476.
    - Block splits 5.57 by size: 5.57 × 9.912 / 21.476 = 2.571 and 5.57 × 11.564 / 21.476 = 2.999.
    - What is left is 7.341 + 8.565 = 15.906. That rounds to 15.91, and all of it goes into the 109.0 shield.
    - With Chaos in place of Fire, the Chaos part is 8.565 → 8.56 and goes to health, and 7.34 goes into the
      shield. (8.565 shows as 8.57 under round-half-up. The ±0.01 tolerance covers it.)
  - AC-DT-16 and AC-DT-27: 70 / 120 = 0.583 and 50 / 120 = 0.417.
  - The part bound: with 2 conversions, each part of the source type spawns at most one new part. So n parts become
    at most 3n, and with 3 conversions at most 4n, as the Tuning Knobs say.
  - AC-MD-32: 1.2 × 1.5 / 0.8 = 2.25, floored to 2 pp. 8 × 1.5 / 0.8 = 15 pp. The family has 7 × 6 = 42 keys.
  - Colours, using the nearest xterm cube level (0, 95, 135, 175, 215, 255) or the grey ramp:

    | Type | Hex | 256-colour code |
    |---|---|---|
    | Physical | #E6E6E6 | 254 (grey ramp) |
    | Force | #9FE8E8 | 152 |
    | Fire | #FF5533 | 203 |
    | Cold | #7FC8FF | 117 |
    | Lightning | #FFE14D | 221 |
    | Light | #FFF2B3 | 229 |
    | Chaos | #A35CFF | 135 |
    | Soul | #FF66CC | 206 |

    All eight codes differ.
- **Registry search.** Searched for: `damage_parts`, `defence_resistance`, `defence_shield`, `defence_block`,
  `defence_ehp`, chaos, convert, soul. No value conflicts with the registry. The `damage_parts` entry is stale
  (DT-06).

## Findings

### DT-01 — BLOCKING — DECISION — How conversion modifiers count, and their order in the modifier step

**Location:** Core Rule 6, "At most 2 conversions per hit" and "Order inside a step" (lines 130–139). Formulas A,
`c_k` row (line 211).

**Problem.** Rule 6 says "Each conversion counts" and "Conversions in one step are taken in a stable compile order:
slot order, then record id." Modifiers do not work that way. Modifier System rules 4–5 add every record of one stat
into one sum. `convert_pct` is keyed by from → to type, so each pair is its own stat. Two items that each give
`convert_pct` Physical → Fire +15 pp add up to one stat value of 30 pp. They have no slot and no single record id.
This leaves two questions open:

- Does that sum count as **one** conversion or **two** toward the limit of 2?
- When the modifier step holds two or more keys (for example Physical → Fire and Force → Lightning), which runs
  first? This decides which one the limit drops.

Also, nothing says how the pp value turns into `c_k`.

**Options.**

- **A (recommended).** Each `convert_pct` key is one conversion in the modifier step. Its `c_k` is the sum of the
  matching records / 100. Keys run in the fixed type order of rule 1: by from type, then by to type. This follows
  Modifier rules 4–5 and the user's DT 17 decision, and it adds no new mechanism.
- **B.** Each record is its own conversion, ordered by host slot, then record id. Two small items with the same key
  would then use up the whole limit of 2. Modifiers would also stop summing like every other stat.
- **C.** Each key is one conversion, as in A, but keys run in descending `c_k` (ties by the fixed order). Large
  conversions win, but the order shifts when a build changes.

**Proposed text (option A).** Add after "Order inside a step" in rule 6:

> - **The modifier step.** All `convert_pct` records of one from → to key that match the hit add up (Modifier
>   System rules 4, 8). Each key with a sum above 0 is one conversion, with `c_k` = the sum / 100. Keys are taken
>   by from type, then by to type, in rule 1's fixed order.

In Formulas A's `c_k` row, change "(slot order, record id)" to "(slot order, record id; in the modifier step, one
conversion per `convert_pct` key, by from type and then to type in rule 1's order)". Add an AC: "**GIVEN** two items
that each give `convert_pct` Physical → Fire +15 pp, and one that gives Force → Lightning +20 pp, **THEN** the
modifier step holds 2 conversions (Physical → Fire 0.30 first, then Force → Lightning 0.20), and both count toward
the 2."

### DT-02 — RECOMMENDED — DECISION — "Slot order" is not defined for most hosts of conversion Effects

**Location:** Core Rule 6, "Order inside a step" (lines 137–139). AC-DT-27 (line 368).

**Problem.** "Slot order" exists in Combat only for art slots and ward slots (Combat rule 13; Defence rule 9). The
conversion Effects in effects.md (Flame-Tempered Edge, Thunder Palm and Rot Seeps In) are hosted on items, Way
nodes and techniques. Way nodes and techniques have no slot. An art's own step can also list two conversions in one
record, and those share a record id. Record id still makes the order fixed, but a programmer has to guess:

- where unslotted hosts sort;
- how to order two conversions inside one record.

This keeps the user's DT 1 answer ("slot order, then record id"). It only defines the term for every host.

**Options.**

- **A (recommended).** Slotted hosts come first, in slot order: art slots, then artifact slots. Hosts with no slot
  come next: technique, Way node, tree node. Then order by record id, then by the order the conversions are listed
  inside the record.
- **B.** Use record id alone for hosts with no slot, mixed in with the slotted ones. This is simpler, but a
  designer's id choice then decides gameplay.

**Proposed text (option A).** Replace "slot order, then record id" in rule 6 with:

> slot order for hosts in a slot (art slots, then artifact slots), then hosts with no slot (technique, Way, tree);
> then record id; then the order the conversions are listed within one record.

Mirror it in the `c_k` row. In AC-DT-27, add: "**GIVEN** one art record listing Physical → Fire and then Physical →
Cold, **THEN** Physical → Fire comes first."

### DT-03 — RECOMMENDED — SAFE — The limit of 2 must skip conversions that move nothing, and must count earlier steps

**Location:** Core Rule 6, "Order inside a step" (line 138): "The limit of 2 is applied first, in that order; only
the conversions kept are then scaled". Edge Cases (line 255).

**Problem.** Read literally, "applied first, in that order" keeps the first two conversions in the step, even when
one of them moves nothing. Take one step with three conversions in this order:

1. Fire → Lightning, when Fire's share at the start of the step is 0. This moves nothing.
2. Physical → Fire.
3. Physical → Cold.

The literal reading keeps 1 and 2 and drops 3. The rule just above says a conversion that moves nothing "does not
count", so 3 should be kept. AC-DT-28 already relies on the second reading. The sentence also reads as if each step
had its own limit of 2. But the limit is per hit, so conversions kept in earlier steps use it up.

**Proposed text.** Replace line 138's sentence with:

> The limit of 2 is applied first, in that order. A conversion that moves nothing, judged on the shares at the step's
> start, is skipped and does not count. Conversions kept in earlier steps count toward the 2. Only the conversions
> kept are then scaled to 100 % if they exceed it.

In Edge Cases (line 255), change "the first two in compile order are kept" to "the first two in compile order that
move something are kept, less any already kept in earlier steps".

### DT-04 — RECOMMENDED — SAFE — Rule 4's "Any tick" row overlaps the qi-tick row, and rule 7 lets a shield undo it

**Location:** Core Rule 4 table (lines 112–113). Core Rule 7, "Any shield may author a different list" (line 159).

**Problem.** Line 112 says "Any tick | resistance → shields that do not let it pass → health". Line 113 adds Qi
Disruption, which ticks linh lực and passes every shield. The two rows overlap. The user's DT 3 answer was "passing
**every** shield". But rule 7 says "Any shield may author a different list", which would let a shield soak a qi
tick.

**Proposed text.**

- Line 112: change "Any tick" to "Any tick on health".
- Rule 7, after "Any shield may author a different list.", add: "A tick on linh lực passes every shield, whatever
  its list (rule 4)."

### DT-05 — RECOMMENDED — SAFE — Combat Defence does not have the qi-tick path yet

**Location:** Cross-References row "Rules 4, 7, Formulas A | combat-defence.md rules 1, 9, …" (line 316). The fix
goes in combat-defence.md.

**Problem.** Defence rule 1's path table has only "Over-time tick | resistance → the shields that do not let it pass
→ health". By Defence rule 9's defaults, a body shield is passed only "by Soul and Chaos". So by Defence's own text, a
body shield soaks a Force qi tick. That is the opposite of DT 3 and of AC-DT-30, which says "both shields are
unchanged". This GDD says Defence owns the path (Interactions row), so the two documents disagree.

**Proposed text.** In combat-defence.md rule 1's table, add this row after "Over-time tick":

> | Tick on linh lực (Qi Disruption) | resistance (Force) → linh lực, passing every shield. Skips evade and block (Combat Damage Types rule 4) |

In rule 9, after "body shields by Soul and Chaos", add: "A tick on linh lực passes every shield (Combat Damage Types
rule 4)."

### DT-06 — RECOMMENDED — SAFE — The registry entry `damage_parts` is stale

**Location:** `design/registry/entities.yaml`, entry `damage_parts` (lines 1175–1191). This GDD's Formulas A
(line 202).

**Problem.** The expression still reads "conversion X->Y share c_k spawns s_j*c_k of type Y with hist + {X}". It
lacks the end-of-step update `s_j ← s_j·(1 − Σ c_k)`. Its notes also lack the decisions made since:

- order inside a step, with the limit applied before scaling;
- a part at share 0 is removed;
- a conversion to its own type is rejected;
- `convert_pct` as the modifier tier.

`referenced_by` also leaves out modifiers.md and effects.md, though both cite rule 6.

**Proposed text.**

- Expression: append "; at the step's end s_j <- s_j*(1 - sum c_k over that step's conversions that apply to j); a
  part at share 0 is removed".
- Notes: append "Inside a step: compile order, the limit of 2 before scaling. Never to its own type. Modifier tier =
  `convert_pct` (user decision 2026-11-08)."
- `referenced_by`: add `design/gdd/modifiers.md` and `design/gdd/effects.md`.
- Set `revised: 2026-11-08`.

### DT-07 — RECOMMENDED — DECISION — The three conversion Effects are now plain scoped modifiers

**Location:** Core Rule 6, "(… a plain conversion share is a modifier, not an Effect)" (line 129). Interactions,
Effects row (line 190). effects.md, Conversion and overflow (Flame-Tempered Edge, Thunder Palm, Rot Seeps In).

**Problem.** Modifier rule 8 now says of `convert_pct`: "A scope narrows it by the art's tags". Look at what the
three Effects say:

- "40 % of the Physical in your sword hits becomes Fire": this is `convert_pct` Physical → Fire, scope [sword].
- "50 % of the Force in your palm hits becomes Lightning": scope [palm].
- "25 % of the Physical in your Wood-element hits becomes Chaos": scope [moc].

None of them has a condition. Under the user's decision, a plain conversion share is a modifier. But effects.md
still lists them as Effects. That puts them in the Effects step, not the modifier step, and the step changes the
result (AC-DT-28). It is not clear which step they belong in.

**Options.**

- **A (recommended).** Move all three to scoped `convert_pct` modifiers on their hosts. Keep the names as named
  modifiers or affixes. The Effects step then holds only conversions with a condition. This follows the Modifier vs
  Effect rule ("tag-scoped" is still a modifier).
- **B.** Keep them as Effects, and say in rule 6 that a named conversion may be an Effect so that it runs in the
  Effects step. This bends the DT 2 wording.
- **C.** Leave them until the library pass (modifiers, then Đạo, then công pháp), and add an Open Question.

**Proposed text (option A).** Rule 6, line 129: add "A tag scope is not a condition, so a scoped share such as '40 %
of the Physical in sword hits becomes Fire' is `convert_pct` with scope [sword]." In effects.md, replace the three
rows' "Convert a share" with a pointer to the modifier. In the Interactions Effects row, say "Conversion Effect records
(conditional conversions only)".

### DT-08 — RECOMMENDED — SAFE — Two rows still name Combat as owner of the conversion order

**Location:** Dependencies, Combat row: "Hits, layers, crit, conversion order, the tag families" (line 262).
Cross-References: "Rule 6, Formulas A | combat.md rule 6, Formulas C | Conversion order, at most 2 per hit, …"
(line 318).

**Problem.** The Interactions row (line 184) now says, per DT 8, that this GDD owns "the conversion rules and steps,
which Combat cites after #43". The two rows above still describe Combat as the source.

**Proposed text.**

- Dependencies (line 262), "What this system needs": change it to "Hits, layers, crit, the tag families".
- Cross-References (line 318): change "Conversion order, at most 2 per hit, `part_j`, the Lava example | Read;
  example rewritten" to "The no-convert-back rule, `part_j`'s layers and crit, the Lava example | Read; example
  rewritten; Combat cites rule 6 for order and the limit after #43".

### DT-09 — RECOMMENDED — SAFE — The Primordial Chaos rename list leaves out three files

**Location:** Open Question 7 (line 384). OQ 1 (line 378).

**Problem.** OQ 7 lists combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md. Three more files
still call the root "Chaos":

- `canh-gioi.md` line 490: "the Chaos root variant's `breakthrough_chance`";
- `kinh-mach-do.md` lines 415 and 1403: "Chaos (Hỗn Độn)";
- `game-concept.md` line 156: "Chaos (Hỗn Độn) from all five".

The #43 sweep would miss them.

**Proposed text.** OQ 7: "Back-references in combat.md, linh-can.md, cong-phap.md, thien-kiep.md and
item-database.md, and the Primordial Chaos (Hỗn Độn) name in linh-can.md, canh-gioi.md, kinh-mach-do.md and
game-concept.md (re-review DT 14, DT 12)".

### DT-10 — RECOMMENDED — DECISION — `convert_pct`'s precision grid conflicts between documents

**Location:** Core Rule 6 / Formulas A `c_k` (line 211). The sources are modifiers.md (Stat List row and AC-MD-32)
and character-stats.md (Formulas I precision).

**Problem.** Character Stats says "0.1 for `pct` keys". AC-MD-32 says `convert_pct` is "floored on the 1 pp grid".
The Stat List row for `convert_pct` names no grid, and Character Stats does not list it as an exception. A small grant
is 2.25 pp before rounding. That gives 2.2 on the 0.1 grid and 2 on the 1 pp grid. Both cannot be true.

**Options.**

- **A (recommended).** 1 pp grid. It matches AC-MD-32, keeps conversion shares in whole percents in the Breakdown,
  and keeps AC-DT numbers simple. Add "grid 1" to the Stat List row. Add `convert_pct` to Character Stats' list of
  exceptions, next to `field_plots`.
- **B.** 0.1 grid, like other `pct` keys. Change AC-MD-32 to +2.2 pp. Notables stay at 15.0.

**Proposed text (option A).** In modifiers.md's Stat List row, change "F (pp of the from type's share)" to "F (pp of
the from type's share; grid 1)". In character-stats.md's precision line, add "`convert_pct` (whole pp)" to the
integer list.

### DT-11 — NIT — SAFE — AC-DT-21's "fixed order" now names two different orders

**Location:** AC-DT-21 (line 362): "only the first two in the fixed order apply".

**Problem.** Rule 1 now defines "the fixed order of the types". The conversion order is step order, then compile
order. A tester could read "fixed order" as the type order.

**Proposed text.** "only the first two in step order, then compile order (rule 6), that move something apply".

### DT-12 — NIT — SAFE — A negative `convert_pct` sum is not handled

**Location:** Formulas A, `c_k` range "0–1" (line 211).

**Problem.** Modifier rule 3 allows negative values. A penalty could bring a key's sum below 0, which would give a
negative `c_k`, outside its stated range.

**Proposed text.** Add to the `c_k` row: "A key whose `convert_pct` sum is 0 or less is no conversion and does not
count."

### DT-13 — NIT — SAFE — AC-DT-31's "any host" cannot be tested

**Location:** AC-DT-31 (line 372): "it compiles on any host and applies in the modifier step".

**Proposed text.** "**GIVEN** a Physical → Lightning 20 pp `convert_pct` on an item, on a tree notable and on a Way
node, **THEN** each compiles, and on an all-Physical hit each gives parts of 0.8 Physical and 0.2 Lightning, applied
in the modifier step."

### DT-14 — NIT — SAFE — Interactions lists the Modifier System twice

**Location:** Interactions table (lines 186 and 189).

**Proposed text.** Merge the two rows into one: "Modifier System (#40) | in / out | Out: damage-type and element
scopes for damage, resistance and penetration. In: conversion modifiers (`convert_pct`, from → to type) | Modifier
System (the rows and prices); this GDD (the conversion rules)".

## Not reopened

These items are settled user decisions, so this review does not reopen them:

- conversion modifiers allowed (DT 2);
- the Primordial Chaos name (DT 12);
- the qi-tick path (DT 3);
- "slot order, then record id" (DT 1), which DT-02 only defines further;
- the step tiers (art, Effects, modifiers);
- same-step reads at the step's start.

Two nice-to-haves from earlier passes stay advisory:

- Edge Cases' "authored or modified to mix Soul";
- the absent Player Fantasy section.

## Autonomous decisions

- Freshness check: the target GDD changed, so a full review ran.
- Phase 5 prompts were not asked. Revise now → [B]. Systems-index and review-log updates were skipped, because this
  run may edit no existing file. The next step is for the user to answer DT-01, DT-02, DT-07 and DT-10, then apply
  the SAFE fixes.

## Receipt

```
Reviewed-Content-Hash: design/gdd/combat-damage-types.md f7345f06383f80850cb4d93e1897e1f2d47c8cba
Reviewed-Content-Hash: design/registry/entities.yaml ac878f4ba052784ff9d30c5644895fa02b2a749f
Reviewed-Content-Hash: .claude/skills/design-review/SKILL.md a63d8fba9b7142eeb43791f061e2e1533c429b43
Reviewed-Content-Hash: design/gdd/combat-defence.md 60f394cb00c668833ff5cd7f23537f7de99c8ec1
Reviewed-Content-Hash: design/gdd/combat.md 1bb3c01f55e9047849d0eb7d565c94695474adba
Reviewed-Content-Hash: design/gdd/modifiers.md ed917d95c2d6f5c192bc64e2c69ffd46bd1446d4
Reviewed-Content-Hash: design/gdd/effects.md 14e81c39b84bff5c990bc5107238b04d02ee1057
Reviewed-Content-Hash: design/gdd/character-stats.md ccaf54f7567702bdf35d889ddc679f30f55edd77
```
