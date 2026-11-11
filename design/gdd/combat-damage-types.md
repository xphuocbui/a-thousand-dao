# Combat Damage Types (Loại Sát Thương)

> **Status**: Designed 2026-11-07. Design review 2026-11-08 (lean, overnight, four passes): Needs Revision; revised the same day with the user's answers (no mixed Soul hits; same-step conversions read the step's start). Re-review 2026-11-08 (lean, three passes): Needs Revision, see `reviews/combat-damage-types-review-log.md`; revised the same day with the user's answers to all 19 items (conversion modifiers allowed; the qi-tick path; order inside a step; "Primordial Chaos" for the root). Second re-review 2026-11-08b (fresh session): all 14 findings applied (modifier step, host order, scoped conversions as modifiers, whole-pp grid); see `reviews/rereview-2026-11-08b/combat-damage-types.md`. Third re-review 2026-11-08c: findings applied, with the user's answers to DT-01 (host order) and DT-04 (per-part scaling); a fourth pass is in `reviews/rereview-2026-11-08c/pass1-combat-damage-types.md`. Revised 2026-11-10 after the review in `reviews/combat-review-2026-11-10/combat-damage-types.md`: resistance in points with no cap or floor (user decision 2026-11-10), the thể tu fixture re-based, Frostbite and Shock retired (#44)
> **Author**: user + agents
> **Last Updated**: 2026-11-10 (resistance in points, fixture re-based, retired statuses). Earlier: 2026-11-08 (third re-review and pass 1 applied; see the review log)
> **Last Verified**: 2026-11-10 (confirming review, `reviews/combat-review-2026-11-10/round2/`: approved with minor fixes, applied)
> **Implements Pillar**: Your Dao, Your Name (1); Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2)
> **Parent system**: Combat (#21, `design/gdd/combat.md`). This is sub-system #21b. It owns what a blow *is*: its damage type, how conversion changes it, and the rule that elements give no bonus in a fight (element tags belong to Combat rule 6 and Spiritual Roots). Combat Defence & Healing (#21a, `design/gdd/combat-defence.md`) owns what the blow meets.

## Summary

Combat Damage Types, a sub-system of Combat, says what a blow physically is. There are eight types:
Physical, Force, Fire, Cold, Lightning, Light, Chaos and Soul. Every part of every hit and tick has one, and
resistance, block and shields read it. The five elements stay as art tags for roots, techniques and
modifiers, so a Fire-root cultivator chooses which damage types to throw and a defender reads a threat by
its type alone.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat, Combat Defence & Healing, Spiritual Roots`

## Overview

A damage type says what a blow physically *is*, and so what stops it. There are eight:
- **Physical**, from blades, fists, stone and the weight of water;
- **Force**, raw spiritual force and wind;
- **Fire**;
- **Cold**;
- **Lightning**;
- **Light**;
- **Chaos**: poison, corruption and darkness;
- **Soul**.

Every part of every hit and every tick has exactly one of them. Resistance, block and shields read the
type. Soul damage skips all of them and meets only the soul's own defences.

Damage types are not the five elements (ngũ hành). An element stays a tag on the art, and it is what
spiritual roots, techniques and many modifiers care about. The damage type is what the defender cares
about. A Metal sword art deals Physical damage and carries the Metal tag. A Water art may crush
(Physical) or freeze (Cold), as its author chooses. This split lets a Fire-root cultivator build around
the Fire element while choosing which damage types to throw, and lets a defender read a threat from
its type alone.

The player meets damage types on every art and item they read, in the resistance panel, and in each
hit's Breakdown. Without them, defence would key on the elements and the roots at once, and "Water"
would have to mean both a crushing wave and a freezing mist.

## Detailed Design

### Core Rules

> `game-designer` and `systems-designer` not consulted for this section — Lean mode. Review manually before production.

1. **Eight damage types, one per part** (user decisions 2026-11-07).

   | Type | Hán-Việt | What it is | Typical sources |
   |---|---|---|---|
   | Physical | Vật lý | Cutting, crushing, piercing | Swords, fists, Metal and Earth arts, a wave's weight, thorns, bleeding |
   | Force | Kình lực | Raw spiritual force with no substance | Palm shockwaves, plain qi blasts, Wind |
   | Fire | Hỏa | Flame and heat | Fire arts, burns |
   | Cold | Hàn | Freezing | Ice arts, freezing Water arts |
   | Lightning | Lôi | Lightning | Thunder arts, tribulation lightning |
   | Light | Quang | Radiance | Light arts |
   | Chaos | Tà | Poison, corruption, darkness | Poisons, Darkness arts, corrupting Wood arts |
   | Soul | Thần hồn | An attack on the soul itself | Soul arts (Combat rule 24) |

   - **The table's order is the fixed order of the types** (re-review DT 17). Wherever a rule needs one type
     before another (a tie, a listing), it uses this order: Physical, Force, Fire, Cold, Lightning, Light, Chaos, Soul.
   - Every part of a hit has exactly one type.
   - A hit may be authored with several parts (for example 60 % Physical and 40 % Fire), or gain parts by
     conversion (rule 6).
   - **A hit is either all Soul or has no Soul part** (user decision 2026-11-08). Soul uses its own damage
     formula and defence path (rule 4), so compile rejects a hit that mixes Soul with another type. An art that
     wants both deals two hits. **One exception** (Đạo shared rule R11, 2026-11-11): a non-soul art may carry an
     **added Soul part** of at most 30 % of its damage, worked as an ordinary part that meets only soul defence
     (Combat Formulas E2). Converting to Soul stays forbidden.
   - Every tick has one type: a burn is Fire, a poison Chaos, a bleed Physical, Qi Disruption Force. Except a named Soul tick that meets only soul defence (Effects rule 16), no status deals
     Soul damage.
   - The Breakdown names the type of every part.

2. **Elements are art tags, not damage types** (user decision 2026-11-07). The five elements (Metal, Wood,
   Water, Fire, Earth) and the root variants stay as tags on arts, techniques and items, for spiritual
   roots, technique affinity and modifier scopes. They never decide defence. An art record therefore has:
   - **damage parts** with their types (this GDD);
   - **element tags** (Combat rule 6), possibly none.

   A Modifier System scope may name a damage type ("+12 % Fire damage") or an element ("+12 % damage on
   Fire-element arts"). These are two different modifiers.

3. **Authoring guide: element to damage type.** This is guidance, not a rule. An art's author may choose
   any type that fits the art.

   | Element or variant | Usual damage types |
   |---|---|
   | Metal (Kim) | Physical |
   | Wood (Mộc) | Physical (thorns, roots); Chaos (rot, poison) |
   | Water (Thủy) | Physical (a crushing wave); Cold (a freezing mist) |
   | Fire (Hỏa) | Fire |
   | Earth (Thổ) | Physical |
   | Thunder (Lôi), Ice (Băng), Light (Quang) | Lightning, Cold, Light |
   | Wind (Phong) | Force or Physical, depending on the art |
   | Darkness (Ám) | Chaos |
   | Blood and Void (archived 2026-11-09), Primordial Chaos roots (Huyết, Hư Không, Hỗn Độn) | No type of their own; their arts use whatever is authored |

   **Naming** (user decision 2026-11-08, re-review DT 12): the damage type is **Chaos (Tà)**. The spiritual root
   is called **Primordial Chaos (Hỗn Độn)** in player text, so the two never share a name.

   The overnight content's "Lava" is not a damage type. A lava art deals Fire, Physical or both.

4. **How each type meets the defence path** (Combat Defence & Healing, #21a):

   | Threat | Path |
   |---|---|
   | Physical, Force, Fire, Cold, Lightning, Light hit | evade → resistance → block → shields → health |
   | Chaos hit | the same, but passes body shields by default (rule 7) |
   | Any tick on health | resistance → shields that do not let it pass → health. Never evade, never block |
   | A tick on linh lực (Qi Disruption) | all + Force resistance (rule 5; Combat Defence rule 3) → linh lực, passing every shield (user decision 2026-11-08, re-review DT 3). Never evade, never block |
   | Soul hit | soul resistance and soul wards only, then a share of health and linh lực (Combat Formulas E2) |

   - Evade applies to every hit except Soul.
   - Block is taken once per hit, split across its parts by size, and never from ticks (user decision
     2026-11-07).

5. **Resistance is one value per damage type**, plus **all resistance**, which applies to every type except
   Soul. Soul keeps its own soul resistance (Combat Formulas E2). Resistance is counted in **points with no cap or
   floor** (damage ÷ (1 + R/100) when R ≥ 0, and × (1 + |R|/100) below 0), and penetration lowers it, as in Combat Defence &
   Healing rules 3 and 4 (user decision 2026-11-10). **Chaos resistance is rare by its row** in the Modifier
   System's Stat List (rule 13), so it comes only from rare sources and Chaos stays the threat that resistance
   stacking answers last. That is a content rule, not a cap.

6. **Conversion changes a part's type.** An art, Effect or modifier may convert a share of a hit's parts from
   one type to another (Physical → Fire, Force → Lightning). A **conversion modifier** is an ordinary Modifier
   System row, `convert_pct` keyed by its from and to types, that any host may carry (user decision 2026-11-08,
   re-review DT 2: a plain conversion share is a modifier, not an Effect). A tag scope is not a condition, so a
   scoped share such as "40 % of the Physical in sword hits becomes Fire" is `convert_pct` with scope [sword]
   (user decision 2026-11-08b, DT-07). Only a conversion with a real condition is an Effect. A capstone or major
   Effect may name the target **`least_resisted`**: the type the defender resists least among the non-Soul types,
   chosen when the hit lands (ties go to the first type in this GDD's order); it counts as one of the 2
   conversions (Đạo shared rule R10, 2026-11-11). The limits:
   - **At most 2 conversions per hit.** Each conversion counts, including two from one type in the same step.
     A conversion that moves nothing (no part of its source type is left, or its target is already in the
     history of every part of its source type) does not count, matching the Soul rule below.
   - **Steps.** A step is one source tier: the art's own conversions, then Effects, then modifiers. Every
     conversion from one type in one step reads that type's share **at the start of the step** (user decision
     2026-11-08), and if the ones that apply to a part sum above 100 %, they are scaled down to 100 % for that part
     (user decision 2026-11-08c, DT-04). Later steps read what earlier steps
     left. A type cannot be converted back in the same hit (Combat rule 6).
   - **Order inside a step** (re-review DT 1). The modifier step is the one exception: it sums by key and uses the
     key order below, not host order. In the art and Effects steps, conversions are taken in a stable compile order: hosts
     in a slot first (art slots in slot order, then equipped pieces in equip order, Item Database rule 11, then
     talismans in slot order), then every other host in the order of Effects rule 13's list (user decision
     2026-11-08c, DT-01); then record id; then the order the conversions are listed within one record (user decision 2026-11-08b,
     DT-02). The limit of 2 is applied first, in that order. A conversion that moves nothing, judged on the
     shares at the step's start, is skipped and does not count. Conversions kept in earlier steps count toward
     the 2. Only the conversions kept are then scaled to 100 % if they exceed it.
   - **The modifier step** (user decision 2026-11-08b, DT-01). All `convert_pct` records of one from → to key
     that match the hit add up (Modifier System rules 4, 8). Each key with a sum above 0 is one conversion, with
     `c_k` = the sum / 100. Keys are taken by from type, then by to type, in rule 1's fixed order. A key whose
     sum is 0 or less is no conversion and does not count. A key whose sum is above 100 pp counts as 100 pp, and
     the Breakdown shows the clip.
   - **A part at share 0 is removed** at the end of its step (re-review DT 15), so it spawns nothing, counts for
     nothing and deals nothing.
   - **A conversion from a type to itself** is rejected at compile.
   - **Conversion never changes a status tick's type.** A status keeps its record's type (re-review DT 16).
   - **A converted part keeps its earlier types as tags** for offence modifiers, so "+Physical" and "+Fire"
     modifiers both reach a Physical-to-Fire part. Resistance and block read only its **final type**, and a
     damage-type scope on penetration matches the final type only (re-review DT 5); element and form scopes on
     penetration still apply, as they read the art's tags.
   - **Element tags never convert.** They belong to the art, not the part.
   - **Nothing converts to or from Soul**, because Soul uses a different damage formula. Such a conversion is
     ignored, logged, and does not count toward the 2.

7. **Shields decide what passes them.** Combat Defence & Healing merges ward shields and body armour into
   one **shield** concept (user decision 2026-11-07). Each shield record lists the types and modes that pass
   it. The defaults:
   - **ward shields** are passed by Soul and by ticks;
   - **body shields** (from body techniques, body gear and căn cốt) are passed by Soul and by Chaos;
   - so a burn wears down a body shield, and a poison passes it;
   - **soul shields** are the reverse: passed by everything except Soul (Combat Defence Formulas B).

   Any shield may author a different list. A tick on linh lực passes every shield, whatever its list (rule 4).

8. **No element cycle in fights** (user decision 2026-11-07). The generating and overcoming relations
   (Spiritual Roots rule 1) give no damage bonus or penalty in combat; defence is resistance-based only.
   Effects (#41) may still use element relations, for example a keystone that rewards arts fired in
   generating order. None exists yet (re-review DT 19); the first one adds its read to Effects rule 5.

9. **Tags in Combat rule 6.** Combat's "kind" family (body, qi, soul) is replaced by the **damage type**
   family (physical, force, fire, cold, lightning, light, chaos, soul). The element family stays, with the
   five elements and the root variants. Form, mode, source and effect are unchanged. The Combat revision
   (systems-index #43) makes this edit.

10. **Migrating today's content.** A body-kind art becomes Physical and a qi-kind art becomes Force, unless
    its author picks a better type. Soul stays Soul. Combat's examples ("Fire to Lava", "body to qi") are
    rewritten as Physical → Fire and Physical → Force.

### States and Transitions

None. A damage type is a fixed property of a part. It changes only by conversion, inside one hit, after the
evade roll and before resistance (rule 6; Combat Formulas C).

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Combat (#21) | in / out | In: art records, hit parts. Out: each part's type and type tags | Combat (hits); this GDD (the types, and the conversion rules and steps, which Combat cites after #43) |
| Combat Defence & Healing (#21a) | out | Each part's final type, read by resistance, block and shields; tick types | Combat Defence & Healing |
| Modifier System (#40) | in / out | Out: damage-type and element scopes for damage, resistance and penetration. In: conversion modifiers (`convert_pct`, from → to type) | Modifier System (the rows and prices); this GDD (the conversion rules) |
| Spiritual Roots (#6) | in | The element and variant tags | Spiritual Roots |
| Cultivation Techniques (#9), The Way (#39), Item DB (#13), Talismans (#18) | out | Each art's damage parts and element tags | each system |
| Effects System (#41) | in | Conversion Effect records (conditional conversions only); element-relation Effects (none yet) | Effects System (the records); this GDD (the conversion rules and steps) |
| Heavenly Tribulation (#22) | out | Tribulation lightning deals Lightning | Heavenly Tribulation |

## Formulas

> `systems-designer` consulted 2026-11-07. Block's split across parts is defined in Combat Defence & Healing
> (Formulas A2); this GDD defines the parts it splits.

### A. Parts and conversion

The damage_parts formula is defined as:

`conversion k (X → Y, share c_k)`: for every part j with type X and Y ∉ hist_j, spawn a part with `s = s_j · c_k`, type Y, `hist = hist_j ∪ {X}` ; a step is one source tier (art, then Effects, then modifiers) ; every c_k of one source type in one step reads s_j at the start of the step, and they sum to at most 1, scaled down if over ; at the end of the step `s_j ← s_j · (1 − Σ c_k)`, over that step's conversions that apply to part j ; `part_j = base · s_j · M(tags ∪ hist_j ∪ {type_j}) · crit` ; resistance and block read `type_j` only

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| base | float | ≥ 0 | Combat Formulas C (`U_att · stage_att · c_art`) | The hit before layers |
| s_j | float | 0–1, Σ = 1 | art record (authored split), then conversion | Share of the hit in part j |
| type_j | enum | the eight types | art record; conversion | The part's final damage type |
| c_k | float | 0–1 | art, Effect or modifier (`convert_pct`) | Conversion share. Which conversions apply, in what order, and how many, is Core Rule 6 (see "Conversion order" below) |
| hist_j | tag set | ⊆ the eight types | calculated | Earlier types of the part, kept as tags for offence modifiers |
| tags | tag set | — | art record | The art's element, form, mode, source and effect tags (Combat rule 6) |
| M(·) | float | 0.1–350 | Combat Formulas B | Layers summed over modifiers whose scope is in the part's tags, history and type |
| crit | float | 1 or `crit_mult` | Combat Formulas C | One roll per hit |

**Conversion order** (a restatement of Core Rule 6, no new content):
1. At most 2 conversions per hit, taken in step order (art, Effects, modifiers), then compile order (art slots in slot order, equipped pieces in equip order, talismans in slot order, then every other host in Effects rule 13's list order, then record id, then listing order). Scaling is per part: the kept conversions that apply to a part are summed and scaled if over 100 %, for that part. The limit is applied before scaling.
2. In the modifier step, one conversion per `convert_pct` key, by from type and then to type in rule 1's order. A key whose sum is 0 or less is no conversion and does not count; a sum above 100 pp counts as 100 pp.
3. Never to or from Soul, never to its own type, never back to a type already in hist_j.
4. A part left at share 0 is removed at the end of its step.

**Output Range:** shares always sum to 1, and a hit has at most (knob + 1) × its authored parts, so 3 × at the default 2 conversions (each conversion spawns at most one part per existing part of its source type).

**Example:**
- Base 100, all Physical, with +30 % Physical, +40 % Fire and +20 % Lightning modifiers. Physical → Fire 40 %,
  then Fire → Lightning 50 % in a later step, gives parts of 0.6, 0.2 and 0.2: 0.6 × 1.3 + 0.2 × 1.7 + 0.2 × 1.9 = **150**.
- Combat's old "Lava" example becomes Physical → Fire 40 %: 0.6 × 1.3 + 0.4 × 1.7 = **146**.
- **Against a thể tu** (Combat Defence & Healing's thể tu fixture: Physical resistance 96.1 points, Fire and
  Chaos 60 points, block 5.57, body shield 436.1): an authored hit of D 41.3, 60 % Physical and 40 % Fire. After
  resistance the parts are 12.64 (24.78 ÷ 1.961) and 10.32 (16.52 ÷ 1.60). Block takes 3.07 and 2.50, and the
  body shield soaks the remaining 17.39, so **0** reaches health. The same hit with Chaos instead of Fire: the
  Chaos part of **7.82** after block passes the body shield and reaches health, and the Physical 9.57 goes into
  the body shield.

## Edge Cases

- **If an art has no authored split**: it is one part of its declared type. **If it declares no type**: compile
  rejects it. Every damaging art names a type.
- **If conversions from one type in one step sum above 100 % for a part**: they are scaled down to sum to
  100 % for that part. Another part of the same type, whose history blocks one of them, is scaled on its own.
- **If a conversion targets a type already in a part's history**: it does not apply to that part, so nothing
  converts back.
- **If a third conversion applies**: it is ignored and logged with its source. A hit takes at most 2. A
  conversion that moved nothing is not counted, so a later one may still apply.
- **If a hit is authored or modified to mix Soul with another type**: compile rejects it and names the record.
- **If a conversion meets a status tick**: it does not apply. Ticks keep their record's type.
- **If a conversion would turn a part into Soul, or a Soul part into another type**: it is ignored. Soul uses
  Combat Formulas E2.
- **If an element-scoped modifier meets a part whose damage type differs** ("+12 % damage on Fire-element arts"
  on a Physical part of a Fire-element art): it applies, because element scopes read the art's tags.
- **If a converted part's final type has negative resistance** (Sundered, Exposed): the part is amplified by
  (1 + |R| / 100), with no floor, so conversion can move damage onto a weakened type on purpose.
- **If a type-scoped modifier meets a converted part**: offence modifiers read the part's type and its
  history; resistance and block read the final type only, and a type scope on penetration matches the final
  type only.
- **If old content still carries `body` or `qi` kind tags**: they load as Physical and Force (rule 10), with a
  migration warning.
- **If a tick's status names no type**: compile rejects the status record.
- **If a free hit is granted** (an Effect's extra hit, such as Echo's or Shattering Ward's): its record names a
  type, or copies its source art's authored parts; it then converts like any hit. Compile rejects a free hit
  that does neither (re-review DT 7).
- **If a conversion leaves a part at share 0**: the part is removed at the end of the step; a later conversion
  from that type moves nothing and does not count, and nothing is dealt from it.
- **If three conversions meet one step**: the first two in compile order that move something are kept, less any
  already kept in earlier steps, then scaled if they exceed 100 %; the third is logged as ignored.

## Dependencies

| System | Kind | What this system needs | Status | Lists this system? |
|---|---|---|---|---|
| Combat (#21) | Hard, parent | Hits, layers, crit, the tag families | Approved for rules | Yes (since the Combat revision #43) |
| Combat Defence & Healing (#21a) | Hard | Resistance, block and shields read each part's final type | Approved 2026-11-08c; revised for #44 2026-11-09/10 | Yes |
| Spiritual Roots (#6) | Soft | Element and variant tags | In review | Not yet |
| Modifier System (#40) | Soft | Damage-type and element scopes; the `convert_pct` row | Approved 2026-11-08c; revised for #44 2026-11-09/10 | Yes |
| Effects System (#41) | Soft | Conditional conversion records; element-relation Effects (none yet) | Approved 2026-11-08c; revised for #44 2026-11-09/10 | Yes |
| Cultivation Techniques (#9), The Way (#39), Item DB (#13), Talismans (#18) | Soft | Damage types on every art and status record | In review; approved; approved; implemented | Not yet |
| Heavenly Tribulation (#22) | Soft | Tribulation lightning deals Lightning | Approved for rules | Not yet |

## Visual/Audio Requirements

> `art-director` not consulted — Lean mode; the current client is the text Debug Terminal.

Each damage type has a fixed colour and icon, used in hit numbers, the Breakdown, resistance panels and item
text, so a player reads a threat by colour:

| Type | Colour | Icon idea |
|---|---|---|
| Physical | `#E6E6E6` | crossed blades |
| Force | `#9FE8E8` | ripple |
| Fire | `#FF5533` | flame |
| Cold | `#7FC8FF` | snowflake |
| Lightning | `#FFE14D` | bolt |
| Light | `#FFF2B3` (pale near-white gold, 256-colour 229; Lightning is 221) | sunburst |
| Chaos | `#A35CFF` | skull drop |
| Soul | `#FF66CC` | eye |

The Debug Terminal maps each to its nearest 256-colour code; no two types may share a code (re-review DT 6).

The element colours of Spiritual Roots stay on element tags. Where an art shows both, the type is the number's
colour and the element is a small tag beside it.

## Game Feel

- **Reading a threat should be instant.** An enemy's damage types show on its profile in foreseen fights, so
  preparing resistance is a real choice.
- **Conversion should feel like a build's signature.** A sword that turns half its blow to Lightning shows two
  coloured numbers on every hit.
- **Chaos should feel dangerous to body cultivators.** It passes their body shields, and the Breakdown says so.

## UI Requirements

- Every art, item and status shows its damage parts with type colours and shares, and its element tags apart.
- Hit numbers are split by part and coloured by final type; a converted part shows its history on hover or in
  the Breakdown.
- The resistance panel (Combat Defence & Healing) lists all resistance and the seven type resistances, with
  Soul resistance separate.

## Cross-References

| This document | References | Value or rule | Use |
|---|---|---|---|
| Rule 1 | combat.md rules 4, 7 | Kinds and ticks | Replaced (kinds become types) |
| Rules 2, 9 | combat.md rule 6 | Tag families | Replaced (kind family); read (others) |
| Rule 3 | linh-can.md rules 1, 9–12; `character_elements.json` | Elements and variants | Read |
| Rules 4, 7, Formulas A | combat-defence.md rules 1, 9, 12, 13, Formulas A2 | The defence path, shields, block and its split across parts, evade | Read |
| Rule 5 | combat-defence.md rules 3, 4 | Resistance in points (÷ (1 + R/100) when R ≥ 0, × (1 + |R|/100) below 0), no cap or floor; penetration in points | Read |
| Rule 6, Formulas A | combat.md rule 6, Formulas C | The no-convert-back rule, `part_j`'s layers and crit, the Lava example | Read; example rewritten; Combat cites rule 6 for order and the limit after #43 |
| Rule 8 | linh-can.md rule 1 | Generating and overcoming relations | Not used in combat (user decision) |
| Rules 1, 4 | combat.md rule 24, Formulas E2 | Soul attacks | Read, unchanged |
| Rules 2, 5, 6, Tuning Knobs | modifiers.md rules 8, 13, Stat List (`convert_pct`, Chaos resistance row) | Type and element scopes; conversion modifiers; rare by row | Read |
| Rules 4, 6, 8 | effects.md rules 5, 6, Status Catalogue | Conversion Effect records; tick types (Qi Disruption's Force tick on linh lực); element-relation reads (none yet) | Read |

## Tuning Knobs

Added 2026-11-08; no value changed. Safe ranges are design estimates.

| Knob | Default | Safe range | What it tunes | Source |
|---|---|---|---|---|
| Conversions per hit | 2 | 1–3 (3 grows parts to 4 × and the Breakdown gets hard to read) | How deep conversion builds can chain | Rule 6, Formulas A |
| Conversion step order | art, Effects, modifiers | fixed | Which source converts first | Rule 6 |
| Type colours and icons | Visual/Audio table | any, if the 8 stay distinct for colour-blind players | Reading threats at a glance | Visual/Audio |
| Chaos resistance rarity | rare sources only | content rule | How late Chaos is answered | Rule 5, Modifier System rule 13 |

## Acceptance Criteria

> Drafted by `qa-lead` 2026-11-07. Its gaps are closed in Core Rules 1 and 6, Formulas A, Visual/Audio and
> Cross-References. Numbers match to ±0.01. Tests: `tests/unit/combat_damage_types/` and
> `tests/integration/combat_damage_types/`. The **thể tu fixture** is Combat Defence & Healing's: Physical
> resistance 96.1 points, Fire and Chaos 60 points, block 5.57, body shield 436.1.

- **AC-DT-01** [Logic] Rule 1. **GIVEN** an art authored 60 % Physical and 40 % Fire, **WHEN** it is compiled, **THEN** it has exactly 2 parts, each with one type, with shares 0.6 and 0.4. **GIVEN** burn, poison, bleed and Qi Disruption ticks, **THEN** their types are Fire, Chaos, Physical and Force.
- **AC-DT-02** [Logic] Rule 2. **GIVEN** a Fire-element art with one Physical part of 100, **WHEN** "+12 % Fire damage" applies, **THEN** the part stays 100. **WHEN** "+12 % damage on Fire-element arts" applies instead, **THEN** it is 112.
- **AC-DT-03** [Integration] Rules 2, 8. **GIVEN** one Physical hit of D 41.3 from a Metal art and the same hit from a Fire art, against the same defender, **THEN** the damage and the resistance line of the Breakdown are identical.
- **AC-DT-04** [Logic] Rule 3. **GIVEN** a Water art authored Cold and a Fire art authored Physical, **WHEN** compiled, **THEN** both are accepted with no warning. **GIVEN** an art declaring the type `lava`, **THEN** compile rejects it as an unknown type.
- **AC-DT-05** [Integration] Rule 4. **GIVEN** a Soul hit on a defender with evade 0.40, **THEN** no evade roll is drawn, and only soul resistance and soul wards appear in its Breakdown. **GIVEN** a Fire hit, **THEN** the steps are evade, resistance, block, ward shields, body shield, health, in that order.
- **AC-DT-06** [Integration] Rules 4, 7. **GIVEN** a Fire tick of 10 on a defender with block 5.57 and a full ward shield, **THEN** no evade roll and no block are logged and the ward shield is unchanged. **GIVEN** a Chaos hit on a defender with a full body shield, **THEN** the body shield is unchanged.
- **AC-DT-07** [Logic] Rule 5. **GIVEN** all resistance 20 points and Fire resistance 10 points, **THEN** a Fire part of 100 has R 30 and takes 76.92 (÷ 1.30), a Cold part of 100 has R 20 and takes 83.33 (÷ 1.20), and a Soul part reads only soul resistance. **GIVEN** a resistance sum of 1,900 points, **THEN** a part of 100 takes 5.00 (÷ 20; no cap). **GIVEN** a sum of −50 points, **THEN** it takes 150 (× 1.5; no floor).
- **AC-DT-08** [Logic] Rule 6. **GIVEN** a Physical → Fire part with Physical resistance 96.1 points, Fire resistance 0, no all resistance and Physical penetration 20 points, **THEN** it uses R 0, and Physical penetration does not apply to it.
- **AC-DT-09** [Logic] Rule 6. **GIVEN** a Fire-element art with Physical → Cold 50 %, **THEN** both parts keep the Fire element tag, and no part gains Cold as an element tag.
- **AC-DT-10** [Integration] Rule 7. **GIVEN** a body shield authored as passed by Fire, **WHEN** a Fire hit lands, **THEN** that shield is unchanged. **GIVEN** a default body shield, **WHEN** a burn tick lands, **THEN** the shield loses the tick's after-resistance amount.
- **AC-DT-11** [Integration] Rule 8. **GIVEN** a Fire hit of D 41.3 against Metal-root, Water-root and Fire-root defenders with the same stats, **THEN** all three take the same damage, and no Breakdown has an element-relation line.
- **AC-DT-12** [Config/Data] Rule 9. **GIVEN** the tag registry, **THEN** it has a damage-type family of exactly the 8 types and no `kind` family; the element family lists the 5 elements and the root variants; form, mode and source are unchanged, and the effect family gains `bleed` and `seal` as cleanse tags (Combat revision D17).
- **AC-DT-13** [Logic] Rule 10. **GIVEN** legacy arts tagged `body`, `qi` and `soul`, **WHEN** they load, **THEN** they become Physical, Force and Soul, with a migration warning for each `body` and `qi` art. **GIVEN** a `body` art whose author set Cold, **THEN** it stays Cold.
- **AC-DT-14** [Logic] Formulas A. **GIVEN** base 100, all Physical, with +30 % Physical, +40 % Fire and +20 % Lightning, **WHEN** Physical → Fire 40 % then, in a later step, Fire → Lightning 50 % apply, **THEN** the parts are 0.6, 0.2 and 0.2 and the total is 150. **WHEN** only Physical → Fire 40 % applies, **THEN** the total is 146.
- **AC-DT-15** [Logic] Formulas A. **FOR** each conversion case in AC-DT-14, 16, 17, 27, 28, 29, 31, 32 and 33, **THEN** the part shares sum to 1 and the part count is at most (knob + 1) × the authored parts: 3 × at the default 2, and 4 × in AC-DT-33, whose knob is 3.
- **AC-DT-16** [Logic] Formulas A. **GIVEN** Physical → Fire 70 % and Physical → Cold 50 % in one step, **THEN** they are scaled to 0.583 and 0.417, the Physical share left is 0, and both count toward the 2.
- **AC-DT-17** [Logic] Formulas A. **GIVEN** Physical → Fire 40 % then Fire → Physical 50 %, **THEN** the parts stay 0.6 Physical and 0.4 Fire. **GIVEN** Physical → Soul or Soul → Fire, **THEN** it is ignored, logged and not counted, and the shares do not change.
- **AC-DT-18** [Logic] Formulas A. **GIVEN** a Physical → Fire part, **THEN** "+Physical" and "+Fire" offence modifiers both apply to it, and resistance reads only Fire.
- **AC-DT-19** [Integration] Formulas A. **GIVEN** the thể tu fixture and a hit of D 41.3, 60 % Physical and 40 % Fire, **THEN** after resistance the parts are 12.64 and 10.32, block takes 3.07 and 2.50, the body shield soaks 17.39, and 0 reaches health. **GIVEN** the same hit with Chaos instead of Fire, **THEN** 7.82 reaches health and the body shield soaks 9.57.
- **AC-DT-20** [Logic] Edge Cases. **GIVEN** a damaging art, a damaging status, or a free hit with no declared type and no source art to copy, **WHEN** compiled, **THEN** compile rejects it and names the record. **GIVEN** a free hit that copies its source art's parts (60 % Physical, 40 % Fire), **THEN** it has those parts and converts like any hit.
- **AC-DT-21** [Logic] Edge Cases. **GIVEN** three conversions on one hit, **THEN** only the first two in step order, then compile order (rule 6), that move something apply, and the third is logged as ignored with its source.
- **AC-DT-22** [UI] Visual/Audio. **GIVEN** two hits in the Debug Terminal Breakdown, one with the 7 non-Soul types and one Soul hit (a hit cannot mix Soul, rule 1), **THEN** each part's number is shown in its table colour (nearest 256-colour code), with the element tag beside it in its element colour, and no two of the 8 types share a 256-colour code; a screenshot is kept in `production/qa/evidence/`.
- **AC-DT-23** [UI] UI Requirements. **GIVEN** a Physical → Fire → Lightning part, **THEN** its Breakdown line shows its final type and its history ("Lightning ← Fire ← Physical"); a screenshot is kept.
- **AC-DT-24** [Config/Data] Rule 1. **GIVEN** every art, status and free-hit record in data, **WHEN** the data scan runs, **THEN** it reports how many records it scanned and finds 0 damaging records without a damage type (a free hit may copy its source art's parts instead).
- **AC-DT-25** [Logic] Rule 1. **GIVEN** an art authored 60 % Physical and 40 % Soul, **WHEN** compiled, **THEN** compile rejects it and names the record. **GIVEN** a Soul art and a Physical art, **THEN** both compile.
- **AC-DT-26** [Logic] Rule 6. **GIVEN** a Fire-only hit with an Effect converting Physical → Cold 50 %, **THEN** nothing moves, it is not counted, and a later modifier conversion still applies. **GIVEN** a Burn tick and a Physical → Fire modifier conversion, **THEN** the tick stays Fire and unchanged.
- **AC-DT-27** [Logic] Rule 6 (order inside a step). **GIVEN** three Effect conversions in one step from Physical, in slots 1, 2 and 3 (to Fire 70 %, to Cold 50 %, to Lightning 30 %), **THEN** only slots 1 and 2 are kept, they are scaled to 0.583 and 0.417, and slot 3 is logged as ignored. **GIVEN** two conversions in the same slot, **THEN** the lower record id comes first. **GIVEN** one art record listing Physical → Fire and then Physical → Cold, **THEN** Physical → Fire comes first. **GIVEN** an Effect conversion on an equipped piece and one on a technique, **THEN** the piece's comes first (slotted hosts before unslotted, DT-02). **GIVEN** a conversion Effect on a formation and one on a Way node, **THEN** the Way node's comes first (Effects rule 13's order, DT-01 of 2026-11-08c). **GIVEN** an all-Physical hit and, in one step, Fire → Lightning (it moves nothing), then Physical → Fire 40 % and Physical → Cold 30 %, **THEN** both Physical conversions are kept, and the parts are Physical 0.30, Fire 0.40 and Cold 0.30 (DT-03).
- **AC-DT-28** [Logic] Rule 6 (same-step chain). **GIVEN** Physical → Fire 40 % and Fire → Lightning 50 % in the same step on an all-Physical hit, **THEN** Fire's share at the step's start is 0, so the second moves nothing and is not counted; the parts are 0.6 Physical and 0.4 Fire. **GIVEN** the same two with Fire → Lightning in the next step, **THEN** the parts are 0.6, 0.2 and 0.2.
- **AC-DT-29** [Logic] Rule 6 (a part at share 0). **GIVEN** Physical → Fire 100 % in the art's step and a Physical → Cold 50 % modifier conversion, **THEN** the Physical part is removed at the end of the first step, the modifier conversion moves nothing and is not counted, and the hit deals nothing as Physical (Combat Formulas C's at-least-1 floor does not apply to a removed part).
- **AC-DT-30** [Integration] Rule 4 (qi tick). **GIVEN** Qi Disruption ticking on a defender with `no_default_ward`, a full ward shield and a full body shield, **WHEN** Force resistance is 20 points, **THEN** the tick is divided by 1.20; **GIVEN** all resistance 10 points and Force resistance 20 points, **THEN** it is divided by 1.30 (no cap). In both cases, both shields are unchanged, and the rest comes off linh lực in full, with no cap per pulse (`qi_burn_cap` removed, #44; Effects Status Catalogue).
- **AC-DT-31** [Logic] Rule 6. **GIVEN** a conversion from Fire to Fire, **WHEN** compiled, **THEN** compile rejects it and names the record. **GIVEN** a Physical → Lightning 20 pp `convert_pct` on an item, on a tree notable and on a Way node, **THEN** each compiles, and on an all-Physical hit each gives parts of 0.8 Physical and 0.2 Lightning, applied in the modifier step.
- **AC-DT-32** [Logic] Rule 6 (the modifier step; user decision 2026-11-08b, DT-01). **GIVEN** two items that each give `convert_pct` Physical → Fire +15 pp, and one that gives Force → Lightning +20 pp, on a hit of 0.5 Physical and 0.5 Force, **THEN** the modifier step holds 2 conversions (Physical → Fire 0.30 first, then Force → Lightning 0.20), both count toward the 2, and the parts are 0.35 Physical, 0.15 Fire, 0.40 Force and 0.10 Lightning. **GIVEN** two records on `convert_pct` Physical → Fire, +10 pp and −15 pp (sum −5 pp), **THEN** that key is no conversion, does not count toward the 2, and the Physical part is unchanged. **GIVEN** a key whose sum is 120 pp, **THEN** `c_k` is 1.0 and the Breakdown shows the clip.
- **AC-DT-33** [Logic] Rule 6 (scaling per part; user decision 2026-11-08c, DT-04). **GIVEN** the knob at 3, an art of 50 % Force and 50 % Physical with Force → Physical 100 % in the art step (part A is Physical 0.5 with no history, part B is Physical 0.5 with history {Force}), then in the Effects step Physical → Force 70 % (applies to A only) and Physical → Cold 50 % (applies to both), **THEN** B sees only the Cold 50 %, sum 0.5, no scaling, and B's Cold share is 0.25 and its Physical share is 0.25.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | ~~"Chaos" shares its name with the Chaos root~~ **Resolved 2026-11-08:** the damage type is Chaos (Tà); the root is "Primordial Chaos (Hỗn Độn)" in player text. Spiritual Roots renames it in the #43 back-reference sweep | user | Done |
| 2 | The Combat revision (#43) replaces Combat rule 6's kind family with damage types, rewrites rule 4 and the conversion examples, and migrates `body` and `qi` content to Physical and Force | user + systems-designer | Combat revision |
| 3 | ~~Chaos resistance should come only from rare sources (rule 5)~~ **Closed 2026-11-10:** the Modifier System marks it rare, and Item DB rule 19 bars it (and every rare modifier) from the rolled affix pool; only named items carry it | systems-designer | Item DB revision |
| 4 | Answered by the Effects System's Status Catalogue: Burn (Fire), Poison and Corpse Rot (Chaos), Bleed (Physical), Qi Disruption (Force); Frostbite (Cold) and Shock (Lightning) retired in #44, so Cold, Lightning and Light have no tick. Closes when effects.md passes review | user | effects.md approval |
| 5 | Every enemy profile should list its damage types, so foreseen fights let the player prepare resistance (Game Feel). NPC Builds and the Event Engine need to expose them | systems-designer | NPC Builds revision |
| 6 | Typed block: the Modifier System's Pending typed-block row blocks only matching parts, after the shared pool, while rule 4 splits block across parts by size. Rule 4 changes when that row leaves Pending (re-review DT 18 with Defence CD 12) | systems-designer | When the typed-block row leaves Pending |
| 7 | Back-references in combat.md, linh-can.md, cong-phap.md, thien-kiep.md and item-database.md, and the Primordial Chaos (Hỗn Độn) name in linh-can.md, canh-gioi.md, kinh-mach-do.md and game-concept.md (re-review DT 14, DT 12; 2026-11-08b DT-09) | systems-designer | Combat revision (#43) sweep |
