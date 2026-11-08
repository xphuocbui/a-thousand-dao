# Modifier System

> **Status**: Designed 2026-11-07; `/design-review` 2026-11-08 (lean, passes 1–4): NEEDS REVISION, see `reviews/modifiers-review-log.md`. Resumed after Combat Defence & Healing (#21a) and Combat Damage Types (#21b); the Stat List, price table and General Catalogue were rebuilt for them (damage-type scopes, resistance, block, body shield, healing stats, penetration; body guard retired).
> **Author**: user + agents
> **Last Updated**: 2026-11-08
> **Last Verified**: 2026-11-07
> **Implements Pillar**: Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2); Your Dao, Your Name (1)
> **Scope**: Modifiers only, meaning plain numbers on a stat ("+X" or "X % increased / more"), optionally narrowed by tags. Effects (conditions, scaling, triggers, conversion, keystones, enablers) are a separate system with their own GDD (user decision 2026-11-07).
> **Reference only**: `design/quick-specs/modifier-inventory.md`. This GDD is designed from scratch, and inventory entries are adopted only where they pass this design's rules.

## Summary

The Modifier System is the shared vocabulary of plain numbers every build piece is made of: "+X" or "X %
increased / more" on one stat, optionally narrowed by tags such as a damage type, an element or a form. One
price list in W, five breadth tiers and one conversion formula size every modifier the same way, wherever
the tree, a technique, an item, a pill or an Effect grants it. Rules (conditions, triggers, keystones) are
Effects, a separate system.

> **Quick reference** — Layer: `Foundation` · Priority: `MVP` · Key deps: `Combat, Character Stats`

## Overview

The Modifier System is the shared vocabulary of plain numbers that every build piece is made from. A
**modifier** adds a number to one stat: "+6 % maximum health", "+12 % Fire damage", "+0.5 crit chance",
"+3 ngộ tính". Each one has an operation (flat, increased, or "more" into a damage layer), a value priced
in W, an optional scope of required tags, and classification tags that designers use to group the
library and players use to filter it. The Meridian Map (Kinh Mạch Đồ), the Way (Đạo), cultivation
techniques (công pháp), artifacts (pháp bảo), pills, formations (trận pháp), talismans (phù lục), spirit
beasts (linh thú) and quests all grant modifiers drawn from this one catalogue, so a "+12 % Fire damage"
means the same thing and costs the same wherever it appears.

The player never operates the system directly. They meet it on every node, item and technique they
read, and in every Breakdown that explains a number. Without it, each system invents its own keys and
sizes, the same bonus is priced differently in two places, and builds cannot be compared (Pillar 2).

This system owns the modifier record, the three operations and how they stack, scope matching, the tag
vocabulary and its families, breadth, the list of modifiable stats with their W prices, and the general
catalogue. What a stat *does* stays with the GDD that owns it (Combat for damage layers and caps,
Character Stats for the sheet and its ceilings). Anything with a rule in it (a condition, scaling, a
trigger, a conversion, a keystone or an enabler) is an **Effect**, which belongs to the separate Effects
system. An Effect grants modifiers from this catalogue as its payload.

## Detailed Design

### Core Rules

> `game-designer` and `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**The record**

1. **A modifier is a plain number on one stat.** Its record holds:
   - `stat`: an id from the Stat List below; unknown stats fail data validation.
   - `op`: `flat`, `increased` or `more`, which must be one the stat allows.
   - `value`: a number on the stat's precision grid (Character Stats Formulas I). Off-grid values fail validation.
   - `layer`: only for `more`, either `L2` or `L4`.
   - `scope`: a set of required tags, possibly empty.
   - `tags`: classification tags (rule 9).

   A modifier has no condition, no duration, no trigger, no count it scales with and no rule of its own.
   A piece that needs any of those is an Effect, and the Effect grants this modifier as its payload (user
   decision 2026-11-07). "+12 % sword damage while linh lực is above 50 %" is a conditional Effect whose
   payload is the modifier "+12 % damage, scope [sword]".

2. **A modifier lasts exactly as long as its source.** A tree node, an equipped artifact, a learned
   technique, a laid formation, a pill in effect or an Effect whose condition holds is the source. This
   system defines no lifetimes. A timed pill or a fight-only talisman is its source's job.

3. **Modifiers may be negative.** Penalties (a drawback on a keystone, a heavy artifact's speed cost) use
   the same record with a negative value. Each stat names its *better* direction (Stat List), so
   "−3 % art cost" reads as a bonus and "+3 % art cost" as a penalty. Penalties apply after ceilings, as
   Character Stats rule 14 already does.

**Operations and stacking**

4. **Flat** adds the value to the stat in its own unit: +1 art slot, +5 ngộ tính, +10 years of lifespan,
   +0.5 percentage points of crit chance. A stat that is already a chance or a share (crit chance, evade,
   regeneration as a share of maximum per second or per pulse, as the Stat List says) takes flat modifiers in
   percentage points.

5. **Increased** adds percentage points to the stat's one increased sum. That sum multiplies the stat
   once: `stat = (base + Σ flat) · max(0, 1 + Σ increased / 100)`. This is today's `_pct` key behaviour
   (Character Stats Formulas I), unchanged. For damage, the increased sum *is* Combat's layer L1.

6. **More** exists only for damage. It adds points to Combat layer **L2** (arts, techniques, Way art
   nodes) or **L4** (preparation and ground: formations, talismans, pills, coatings). Combat Formulas B
   multiplies the layers, so `more` stacks multiplicatively against `increased`. L3 is computed from gear,
   so no modifier writes to it. **L5** (cap 100) is granted only as an Effect's payload (Effects System,
   user decision 2026-11-07), never by a plain modifier. Every other stat has no "more", which keeps one
   multiplier per stat.

7. **Caps and ceilings belong to the stat's owner.** Combat's layer caps (400/300/250/150/100 and the L1
   knee), the crit, evade and escape caps, and Character Stats' ceilings (`breakthrough_chance`,
   `herb_growth_pct`, `alchemy_success`, lifespan) all apply after the modifiers are summed. A clipped sum
   shows the clip in the Breakdown. This system never caps a stat itself.

**Scope**

8. **Scope narrows a modifier by required tags.** A scoped modifier applies to a thing only when every
   scope tag is among that thing's tags (Combat rule 6). Which thing is matched depends on the stat's
   *target* (Stat List):
   - **outgoing hit**: damage, crit, pierce, accuracy and resistance penetration match the hit part's tags:
     its damage type and earlier types (Combat Damage Types rule 6) and the art's element, form, mode and
     source tags.
   - **outgoing soul hit** and **basic attack**: an outgoing hit narrowed by its implied tag (rule 11), so
     soul attack damage matches as [soul] plus the soul art's tags, and basic attack speed as [basic].
   - **art**: art speed and art cost match the art's tags.
   - **heal**: healing matches the tags of the art that heals (a Wood-element heal art matches [moc]).
   - **reservation**: reservation efficiency matches the tags of the ward or art that reserves.
   - **outgoing status**: status duration and status stack cap match the status's own tags (its damage type,
     mode and effect tags, Effects System Status Catalogue), so a [fire] scope reaches Burn.
   - **incoming hit**: resistance matches the incoming part's **final damage type** only, so "+12 % Fire
     resistance" defends against Fire parts (Combat Defence & Healing rule 3).
   - **status**: status resistance matches the incoming status.
   - **ward**: ward strength and ward efficiency are unscoped; they scale every ward's payloads and payments
     (Combat Defence & Healing rule 6).
   - **artifact**: artifact stats match the artifact's role tags (`weapon`, `ward_gear`, `body_gear`, `utility`).
   - **foe** (Pending, variety 2026-11-08): an outgoing hit also matches the **defender's** foe tag, and resistance
     the **attacker's**. Combat stamps one foe tag on each fight profile at compile (rule 9's foe family), so
     this is a fixed tag match, like a damage type, never a condition.
   - **cultivation season** (Pending, variety 2026-11-08): cultivation speed matches the season's activity tag
     (`secluded` for closed-door cultivation, bế quan; `travelling`), which Time & Turn stamps on each season.
   - **none**: sheet stats such as maximum health or ngộ tính cannot be scoped.

   A scope holds at most **two** tags, drawn from the damage type family and Combat's families (element,
   form, mode, source, effect) and the derived art tags (rule 10). There is one stat per idea, never one key per tag:
   "+12 % Fire damage" and "+12 % sword damage" are the same stat with different scopes. A scope the
   stat's target can never match fails validation. For example, damage scoped [soul] never applies,
   because soul attacks skip the damage layers and use soul attack damage instead (Combat E2).

**Tags**

9. **Every modifier carries classification tags from one vocabulary shared with Combat** (user decision
   2026-11-07). Its tags are the union of:
   - the stat's family tags (Stat List);
   - its scope tags;
   - its domain (`combat`, `cultivation`, `crafting`, `travel`, `social`);
   - any extras a designer adds, but only from the vocabulary.

   The first three are derived and cannot be removed. Unknown tags fail validation. A node, item or
   technique holding several modifiers carries the union of their tags, so a "+6 % health, +4 % ward
   strength" node is found under both `health` and `ward`. Tags exist for designers to group and search
   the library and for players to filter nodes, items and the Breakdown. They never change what a modifier
   does; only scope does.

   | Family | Tags | Owner |
   |---|---|---|
   | damage type | physical, force, fire, cold, lightning, light, chaos, soul | Combat Damage Types rule 1 (replaces Combat's kind family) |
   | element | kim, moc, thuy, hoa, tho (Metal, Wood, Water, Fire, Earth) and the root variants. Art tags only: never defence | Combat rule 6; Combat Damage Types rule 2 |
   | form | sword, palm, seal, beast, formation | Combat rule 6 |
   | mode | hit, over_time, curse, ward | Combat rule 6 |
   | source | art, artifact, talisman, formation, companion | Combat rule 6 |
   | effect | pierce, lock, poison, cleanse, escape | Combat rule 6 |
   | derived art tags | basic, quick, slow, cheap, costly | proposed to Combat (rule 10) |
   | artifact role | weapon, ward_gear, body_gear, utility | Item DB (Combat's role tags; Item DB renames `ward`/`body`, combat revision D2) |
| foe | cultivator, creature (Pending until Combat stamps them; `demonic` and `tribulation` held) | Combat rules 2, 18 (variety 2026-11-08) |
| activity | secluded, travelling (Pending) | Time & Turn, Realms (variety 2026-11-08) |
   | stat family | damage, crit, accuracy, speed, cost, linh_luc, than_thuc, health, ward, resistance, block, shield, healing, evade, soul, status, gear, preparation, companion, escape, fortune, realm, cultivation, lifespan, heart_demon, toxicity, crafting, economy, travel, attribute, slots | this GDD |
   | domain | combat, cultivation, crafting, travel, social | this GDD |

10. **Derived art tags** let a modifier key off what an art is like without a condition. These are a
    proposal to Combat, which would own them and assign them when an art is compiled. The thresholds are
    provisional.
    - `basic`: the basic attack.
    - `quick`: authored cooldown under 2 s.
    - `slow`: authored cooldown of 6 s or more.
    - `cheap`: cost share of 5 % or less.
    - `costly`: cost share of 20 % or more.

    Until Combat adopts them, modifiers scoped by them are accepted, marked **Pending**, and add nothing.
    This differs from a Pending *stat* (Stat List), which has no key yet and cannot be authored at all.

**Breadth and size**

11. **Breadth is derived from scope and sets the size, in five tiers** (user decision 2026-11-07):

    | Tier | Scope |
    |---|---|
    | universal | empty |
    | broad | damage type `physical` or `force`, mode `hit`, source `art`, or foe `cultivator` |
    | family | damage type `fire`, `cold`, `lightning`, `light` or `chaos`; one base element; form; other mode or source; derived art tag; foe `creature`; an activity tag |
    | narrow | one variant element or effect tag; one status tag; or two family tags |
    | pinpoint | two tags, one narrow and the other family or narrower |

    - **Two tags:** a second tag that is only broad adds nothing, so [art, sword] is family.
    - **Implied tags:** a stat that only one build family uses carries an implied tag that counts toward
      its tier. Soul attack damage counts as [soul] (broad), basic attack speed as [basic], status duration
      as [over_time], and element affinity as family.

    Narrower modifiers get bigger values for the same price (Formulas B). The Meridian Map leans on
    universal and broad modifiers because every build crosses it, but narrower ones are allowed. The mix
    is the tree's decision, not this system's.

12. **Every value is priced in W** (1 W = the value of +1 % increased damage). A modifier's value is its
    source's W budget, times its breadth multiplier, divided by the stat's price, and floored to the
    stat's precision (Formulas C). Each source GDD owns its budgets: an acupoint, a notable, a technique
    tier, an artifact affix, a pill. This system owns the prices and the conversion. The two reference
    grades used in the catalogue are **small** (1.2 W, an acupoint) and **notable** (8 W).

    **`more` is budgeted in layer points, not W** (user decision 2026-11-07). Arts, techniques, Way art
    nodes, formations, talismans and pills size their L2 and L4 points against Combat's layer anchors.
    The realm-indexed exchange rate (Formulas D) is used only when W must buy points, as for the LLM
    Game Master, quests and NPC Builds. The Meridian Map never grants `more`.

13. **Rare modifiers appear only where the budget can pay for them** (user decision 2026-11-07). A rare
    modifier raises a count that has no cap of its own: art slots, artifact slots, ward slots, beast slots,
    talisman stock, status stack cap, field plots and pills per brew. A few stats are also **rare by their
    row** in the Stat List, because they would break a limit if common: the resistance cap raise and Chaos
    resistance (Combat Damage Types rule 5). A rare count costs 10–30 W, more than a notable holds.
    It may appear only on a source whose own budget covers its price: a keystone, a named item, a quest
    reward or a Way capstone. It never appears on an acupoint, a tree notable or a rolled affix. Validation
    reads the **source record's kind** (acupoint, notable, affix, keystone, named item, quest reward,
    capstone); the modifier record itself carries no source. This
    keeps slot counts bounded (catalogue "Limits").

**Display and the world**

14. **Every applied modifier shows in the Breakdown** with its source, stat, operation, scope and value,
    in the stat's display precision. A modifier that matched nothing in a fight is not listed for that
    hit. A clipped sum names the cap that clipped it (rule 7).

15. **NPCs use the same modifiers.** NPC Builds draws from this catalogue with the same prices, so an
    NPC's profile reads in the same words as the player's (Pillar 2, catalogue "Same rules for NPCs").

16. **The LLM Game Master may grant only catalogue modifiers**, sized from a W budget the engine sets.
    A proposed value above what the budget buys is clamped down to the Formulas C value. A proposal with an
    unknown stat, an operation the stat does not allow or an unknown tag grants nothing.

#### Stat List

Every stat a modifier can touch. **Ops**: F flat, I increased, M more. **Target** is what scope matches
(rule 8); "none" means the stat cannot be scoped. **W** is the price per displayed unit (per percentage point for pp stats, per point of reduction for
lower-is-better stats). Values from the Meridian Map's Formulas F weight table move here unchanged (user
decision 2026-11-07); the rest come from Formulas A, which marks each as derived or a guess. **Status**:
- *Live*: in game data today.
- *Designed*: the key is defined in a GDD but not built.
- *Pending*: needs a key or rule from the named owner before modifiers on it may be authored; until then
  validation rejects them. (Pending derived-tag *scopes* are different: rule 10.)

**Combat: offence**

| Stat | Key | Ops | Target | Better | W | Owner (what it does) | Status |
|---|---|---|---|---|---|---|---|
| Damage | `attack_pct` (I); `damage_more` (M, L2/L4; L5 as an Effect payload only; grid 0.1 points) | I, M | outgoing hit | higher | 1.0 (I); points (Formulas D) | Combat B | Live (I); Designed (M) |
| Crit chance | `crit_chance_pct` | F (pp) | outgoing hit | higher | 1.0 | Combat C | Designed |
| Crit damage | `crit_damage_pct` | F (pp of multiplier) | outgoing hit | higher | 0.3 | Combat C | Designed |
| Accuracy | `accuracy_pct` | F (pp) | outgoing hit | higher | 0.5 | Combat I | Designed |
| Realm pierce | `pierce_pct` | F (pp) | outgoing hit | higher | 1.0 | Combat H | Designed |
| Resistance penetration | `resist_pen_pct` | F (pp) | outgoing hit (type scope matches the final type) | higher | 3.0 | Combat Defence & Healing rule 4 | Designed |
| Soul attack damage | `x_soul` | I | outgoing soul hit | higher | 1.0 | Combat E2 | Designed |
| Art speed | `art_speed_pct` | I | art | higher | 0.6 | Combat A2 | Designed |
| Art cost | `art_cost_pct` | I | art | lower | 1.2 | Combat E | Designed |
| Basic attack speed | — | I | basic attack | higher | 0.4 | Combat A2 (`basic_cooldown` is fixed today) | Pending |
| Status duration | — | I | outgoing status | higher | 0.6 | Combat F (duration is fixed per status) | Pending |
| Status stack cap | — | F, rare | outgoing status | higher | 10 | Combat F (`stack_cap` 5) | Pending |
| Damage against a foe | `attack_pct` scoped [cultivator] or [creature] | I | outgoing hit (defender's foe tag) | higher | 1.0 | Combat rules 2, 18: foe tags on profiles (variety 2026-11-08) | Pending |

**Combat: defence**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Resistance, all | `resist_pct` (no scope) | F (pp) | incoming hit | higher | 1.25 | Combat Defence & Healing A | Designed |
| Resistance, one damage type | `resist_pct` (scoped by type) | F (pp) | incoming hit (final type) | higher | 1.25 stored (one price in `modifier_prices`); effective 1.0 Physical/Force, 0.83 others after breadth | Combat Defence & Healing A. Chaos resistance is rare (rule 13) | Designed |
| Resistance against a foe | `resist_pct` scoped [cultivator] or [creature], may pair with a type | F (pp) | incoming hit (attacker's foe tag) | higher | 1.25 stored | Combat Defence & Healing rule 3 and foe tags (variety 2026-11-08) | Pending |
| Resistance cap | `resist_cap_pct` | F (pp), rare | incoming hit | higher | 5 | Combat Defence & Healing A (to 90 %) | Designed |
| Block | `block_rating` | F (rating, grid 1) | none | higher | 0.4 | Combat Defence & Healing A2 | Designed |
| Block against one damage type | `block_rating` scoped by type (not Chaos) | F (rating) | incoming hit part (final type) | higher | 0.4 | Combat Defence & Healing A2: a typed rating blocks only matching parts, after the shared pool (variety 2026-11-08) | Pending |
| Body shield | `body_shield_pct` | F (pp of health_max); I (Pending) | none | higher | 1.0 (F); 0.6 / % (I) | Combat Defence & Healing B; the I op multiplies the summed body shield (variety 2026-11-08) | Designed (F); Pending (I) |
| Shield recharge delay | `recharge_delay_pct` | I | ward | lower | 0.6 | Combat Defence & Healing B (`recharge_delay` 2.0 s) (variety 2026-11-08) | Pending |
| Cast ward duration | `cast_ward_duration_pct` | I | ward | higher | 0.5 | Combat Defence & Healing rule 7; a cast ward's duration stays below its cooldown (variety 2026-11-08) | Pending |
| Ward strength | `defense_pct` | I | ward | higher | 1.0 | Combat Defence & Healing rule 6 (scales ward payloads) | Live |
| Ward efficiency | `ward_efficiency_pct` | I | ward | higher | 1.0 | Combat Defence & Healing rule 6 (lowers ward payments) | Designed |
| Maximum health (khí huyết) | `khi_huyet_pct` | I | none | higher | 1.2 | Character Stats C | Live |
| Evade | `evade_pct` | F (pp) | none | higher | 1.5 | Combat I | Designed |
| Soul resistance | `soul_res_pct` | F (pp) | none | higher | 0.6 | Combat E2 | Designed |
| Status resistance | `status_resist_pct` | F (pp) | incoming status | higher | 0.4 | Combat F. Scopes by one status (burn, bleed, frostbite, qi_burn) wait on status tags (variety 2026-11-08) | Designed |
| Status duration on you | `status_duration_taken_pct` | I | incoming status | lower | 0.3 | Combat F (`duration`, `curse_duration_max`); the answer to statuses that always land (variety 2026-11-08) | Pending |
| Health regeneration | `health_regen_pct` | F (pp of maximum per pulse, cap 2) | none | higher | 3.0 | Combat Defence & Healing E | Designed |
| Healing | `healing_pct` | I | heal (its tags) | higher | 0.5 | Combat Defence & Healing E. A [body_shield] scope on restores waits on that tag (variety 2026-11-08) | Designed |
| Healing taken | `healing_taken_pct` | I | none | higher | 0.5 | Combat Defence & Healing E | Designed |
| Ward slots | `bonus_ward_slots` | F, rare | none | higher | 30 | Combat Defence & Healing D | Designed |
| ~~Body guard~~ | `body_guard_pct` | — | — | — | retired | Replaced by block and body shield (Combat Defence & Healing rule 12) | Retired |

**Resources**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Maximum linh lực | `linh_luc_pct` | I | none | higher | 1.0 | Character Stats C | Live |
| Linh lực regeneration | `linh_luc_regen_pct` | F (pp of maximum per second) | none | higher | 8 | Combat E | Designed |
| Thần thức | `than_thuc_pct` | I | none | higher | 1.3 | Character Stats C | Live |
| Linh lực reservation efficiency | `reserve_eff_pct` | I (counts to 50) | reservation | higher | 0.8 | Combat Defence & Healing rule 10. Kept by user decision 2026-11-07, overriding overnight `decisions.md` decision 12 (reservation as a pure cost) | Designed |

**Gear and loadout**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Artifact power | `artifact_power_pct` | I | artifact | higher | 1.3 | Item DB / Artifact Refining | Live |
| Artifact attack | `artifact_attack_pct` | I | artifact (`weapon`) | higher | 0.6 | Item DB | Live |
| Artifact defence | `artifact_defense_pct` | I | artifact (`ward_gear`, `body_gear`) | higher | 0.6 | Item DB | Live |
| Element affinity | `element_affinity_pct` | I | artifact | higher | 1.3 | Item DB | Live |
| Artifact thần thức cost | `than_thuc_cost_pct` | I | artifact | lower | 0.8 | Item DB | Live |
| Art slots | `bonus_slots` | F, rare | none | higher | 20 | Combat A2 | Designed |
| Artifact slots | — | F, rare | none | higher | 25 | Item DB (capability #2 today) | Pending |

**Preparation and companions**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Formation power | `formation_power_pct` | I | none | higher | 1.0 | Formations | Live |
| Pill effect | `pill_effect_pct` | I | none | higher | 1.0 | Alchemy / Character Stats | Live |
| Talisman power | — | I | none | higher | 0.7 | Talismans | Pending |
| Talisman keep chance | — | F (pp) | none | higher | 0.3 | Talismans (capability #13 today) | Pending |
| Talisman stock | — | F, rare | none | higher | 10 | Talismans | Pending |
| Companion power share | — | F (pp) | none | higher | 0.4 | Spirit Beasts / Combat J | Pending |
| Beast slots | — | F, rare | none | higher | 15 | Spirit Beasts (capability #16 today) | Pending |
| Formation upkeep | `formation_upkeep_pct` | I | none | lower | 0.15 | Formations (`upkeep_lt_per_level`) (variety 2026-11-08) | Pending |
| Talisman ink cost | `talisman_ink_pct` | I | none | lower | 0.15 | Talismans (`ink_lt`) (variety 2026-11-08) | Pending |

**Escape and fortune**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Escape chance | `escape_pct` (feeds `escape_bonus`) | F (pp) | none | higher | 1.0 | Combat I | Designed |
| Stealth | `stealth` | F | none | higher | 1.5 | Character Stats | Live |
| Fortuitous encounter rate (cơ duyên) | `co_duyen_pct` | I | none | higher | 0.3 | Progression Edges | Live |

**Cultivation and life**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Cultivation speed (tu luyện) | `cultivation_speed_pct` | I | none; cultivation season (Pending) | higher | 2.2 | Realms / Character Stats. Scoped by activity, [secluded] or [travelling], once seasons carry the tag (variety 2026-11-08) | Live (unscoped) |
| Breakthrough chance | `breakthrough_chance` | F (pp) | none | higher | 5 | Realms (tree cap 8 pp) | Live |
| Lifespan (thọ nguyên), years | `lifespan_years` | F (years) | none | higher | 300 / L_r per year | Realms rule 14 | Live |
| Lifespan, share | `lifespan_pct` | I | none | higher | 3.0 | Realms rule 14 | Live |
| Heart demon resistance (tâm ma) | `tam_ma_resist_pct` | I | none | higher | 1.5 | Character Stats E | Live |
| Qi deviation chance | `qi_deviation_pct` | I | none | lower | 1.0 | Character Stats E | Live |
| Pill toxicity resistance (đan độc) | `dan_doc_resist_pct` | I | none | higher | 1.6 | Character Stats D | Live |
| Pill toxicity fading | `dan_doc_decay` | F | none | higher | 8 | Character Stats D | Live |
| Spirit qi density (linh khí) | `density_bonus` | F | none | higher | 140 | Realms | Live |

**Crafting, travel and economy**

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Alchemy success (luyện đan) | `alchemy_success` | F (pp) | none | higher | 2.7 | Alchemy | Live |
| Pills per brew | `alchemy_yield` | F, rare | none | higher | 20 | Alchemy | Live |
| Refining success (luyện khí) | `refining_success` | F (pp) | none | higher | 2.0 | Artifact Refining | Live |
| Herb growth | `herb_growth_pct` | I | none | higher | 0.9 | Spirit Herbs | Live |
| Spirit field plots (linh điền) | `field_plots` | F, rare | none | higher | 20 | Spirit Herbs | Live |
| Talisman drawing success | — | F (pp) | none | higher | 2.0 | Talismans | Pending |
| Taming chance | — | F (pp) | none | higher | 1.0 | Spirit Beasts | Pending |
| Mission income | `mission_income_pct` | I | none | higher | 0.7 | Sects | Live |
| Travel speed | `travel_speed_pct` | I | none | higher | 0.3 | Travel | Live |
| Pill quality chance | `pill_quality_chance` | F (pp) | none | higher | 1.0 | Alchemy; Item DB `quality` 0–3 (one grade up, never past 3) (variety 2026-11-08) | Pending |
| Artifact grade chance | `refine_grade_chance` | F (pp) | none | higher | 1.5 | Artifact Refining; shifts the grade roll one step up (variety 2026-11-08) | Pending |
| Buy price | `buy_price_pct` | I | none | lower | 0.3 | Market (#20) (variety 2026-11-08) | Pending |
| Sell price | `sell_price_pct` | I | none | higher | 0.3 | Market (#20). Guard: the sell price never reaches the buy price (variety 2026-11-08) | Pending |

**Attributes (thiên phú)**: flat points on the effective talent (Character Stats Formulas B).

| Stat | Key | Ops | Target | Better | W | Owner | Status |
|---|---|---|---|---|---|---|---|
| Comprehension (ngộ tính) | `ngo_tinh` | F | none | higher | 5 | Character Stats | Live |
| Fortune (khí vận) | `khi_van` | F | none | higher | 5 | Character Stats H | Live |
| Root bone (căn cốt) | `can_cot` | F | none | higher | 3.0 | Character Stats | Live |
| Soul (thần hồn) | `than_hon` | F | none | higher | 3.0 | Character Stats | Live |
| Dao heart (đạo tâm) | `dao_tam` | F | none | higher | 3.0 | Character Stats | Live |
| Presence (mị lực) | `mi_luc` | F | none | higher | 1.0 | Character Stats H | Live |

**Keys that move to Effects.** These live keys are not plain modifiers, so the Effects GDD takes them
over. They keep working unchanged until then.
- `single_artifact`, `safe_failure` and `dan_doc_no_penalty` are flags, so they are rule changes.
- `cultivation_speed_per_element_pct` scales with a count.

**Left out on purpose** (from `modifier-inventory.md`):
- *Status chance*: a status's chance is part of the art record, not a stat.
- *Damage while X* and *damage to an enemy with no linh lực*: these are conditions, so they are Effects.
- *First firing sooner*: there is no Combat key for it.
- *Conversion share*: this is an Effect.
- *Trigger limit*: this belongs with Effects.
- The overnight run's build-specific "points" rows: these are narrow conditional or scaling pieces, so
  they are Effects.


#### General Catalogue

The standard plain modifiers, generated from Formulas A–C by `tools/design/modifier_catalogue.py`.
Change the prices or tiers in this GDD, then regenerate; never hand-edit the numbers. One row stands for
one modifier per tag in its scope list (Count). Values are at the two reference grades. Sources scale them
with their own budgets (rule 12). Scoped rows are *Designed* even on a Live key, because scope matching
belongs to Combat, which is not built yet.

The rows were rebuilt on 2026-11-07 for Combat Damage Types (#21b) and Combat Defence & Healing (#21a): damage
and penetration are scoped by damage type or by element tag, resistance by damage type, and body guard is gone.
The rows were chosen to pass four tests:
- the number does something today or in a designed GDD;
- the scope can match the stat's target (rule 8);
- the stat is universal or broad, or a family that several build concepts share;
- a reader can say in one line what it is for.

The inventory (`design/quick-specs/modifier-inventory.md`) was the reference. Its rule-pieces are Effects
and are not here.

**Combat: offence**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Damage, increased (`attack_pct`) | — | universal | +1.2 % | +8.0 % | Live | 1 |
| Damage, increased (`attack_pct`) | type: physical or force | broad | +1.5 % | +10.0 % | Designed | 2 |
| Damage, increased (`attack_pct`) | mode: hit | broad | +1.5 % | +10.0 % | Designed | 1 |
| Damage, increased (`attack_pct`) | source: art | broad | +1.5 % | +10.0 % | Designed | 1 |
| Damage, increased (`attack_pct`) | type: fire, cold, lightning, light, chaos | family | +1.8 % | +12.0 % | Designed | 5 |
| Damage, increased (`attack_pct`) | element (art tag): kim, moc, thuy, hoa, tho | family | +1.8 % | +12.0 % | Designed | 5 |
| Damage, increased (`attack_pct`) | form: sword, palm, seal, beast, formation | family | +1.8 % | +12.0 % | Designed | 5 |
| Damage, increased (`attack_pct`) | source: artifact, talisman, formation, companion | family | +1.8 % | +12.0 % | Designed | 4 |
| Damage, increased (`attack_pct`) | mode: over_time (ticks) | family | +1.8 % | +12.0 % | Designed | 1 |
| Damage, increased (`attack_pct`) | derived: basic, quick, slow (Pending) | family | +1.8 % | +12.0 % | Pending | 3 |
| Damage, increased (`attack_pct`) | one variant element | narrow | +2.4 % | +16.0 % | Designed | 8 |
| Damage, increased (`attack_pct`) | effect: poison | narrow | +2.4 % | +16.0 % | Designed | 1 |
| Damage, increased (`attack_pct`) | foe: cultivator (Pending) | broad | +1.5 % | +10.0 % | Pending | 1 |
| Damage, increased (`attack_pct`) | foe: creature (Pending) | family | +1.8 % | +12.0 % | Pending | 1 |
| Damage, increased (`attack_pct`) | two tags, e.g. [over_time, hoa], [sword, kim] | narrow | +2.4 % | +16.0 % | Designed | — |
| Crit chance (`crit_chance_pct`) | — | universal | +1.2 pp | +8.0 pp | Designed | 1 |
| Crit chance (`crit_chance_pct`) | source: art | broad | +1.5 pp | +10.0 pp | Designed | 1 |
| Crit chance (`crit_chance_pct`) | type: physical or force | broad | +1.5 pp | +10.0 pp | Designed | 2 |
| Crit chance (`crit_chance_pct`) | type: fire, cold, lightning, light, chaos | family | +1.8 pp | +12.0 pp | Designed | 5 |
| Crit chance (`crit_chance_pct`) | element (art tag) | family | +1.8 pp | +12.0 pp | Designed | 5 |
| Crit chance (`crit_chance_pct`) | form | family | +1.8 pp | +12.0 pp | Designed | 5 |
| Crit chance (`crit_chance_pct`) | derived: basic, quick, slow (Pending) | family | +1.8 pp | +12.0 pp | Pending | 3 |
| Crit damage (`crit_damage_pct`) | — | universal | +4.0 pp | +26.6 pp | Designed | 1 |
| Crit damage (`crit_damage_pct`) | source: art | broad | +5.0 pp | +33.3 pp | Designed | 1 |
| Crit damage (`crit_damage_pct`) | element | family | +6.0 pp | +40.0 pp | Designed | 5 |
| Crit damage (`crit_damage_pct`) | form | family | +6.0 pp | +40.0 pp | Designed | 5 |
| Accuracy (`accuracy_pct`) | — | universal | +2.4 pp | +16.0 pp | Designed | 1 |
| Realm pierce (`pierce_pct`) | — | universal | +1.2 pp | +8.0 pp | Designed | 1 |
| Realm pierce (`pierce_pct`) | source: art | broad | +1.5 pp | +10.0 pp | Designed | 1 |
| Resistance penetration (`resist_pen_pct`) | — | universal | +0.4 pp | +2.6 pp | Designed | 1 |
| Resistance penetration (`resist_pen_pct`) | type: physical or force | broad | +0.5 pp | +3.3 pp | Designed | 2 |
| Resistance penetration (`resist_pen_pct`) | type: fire, cold, lightning, light, chaos | family | +0.6 pp | +4.0 pp | Designed | 5 |
| Resistance penetration (`resist_pen_pct`) | element (art tag) | family | +0.6 pp | +4.0 pp | Designed | 5 |
| Soul attack damage (`x_soul`) | — (implied soul) | broad | +1.5 % | +10.0 % | Designed | 1 |
| Soul attack damage (`x_soul`) | element (art tag) | family | +1.8 % | +12.0 % | Designed | 5 |
| Art speed (`art_speed_pct`) | — | universal | +2.0 % | +13.3 % | Designed | 1 |
| Art speed (`art_speed_pct`) | type: physical or force | broad | +2.5 % | +16.6 % | Designed | 2 |
| Art speed (`art_speed_pct`) | element | family | +3.0 % | +20.0 % | Designed | 5 |
| Art speed (`art_speed_pct`) | form | family | +3.0 % | +20.0 % | Designed | 5 |
| Art speed (`art_speed_pct`) | mode: curse | family | +3.0 % | +20.0 % | Designed | 1 |
| Art speed (`art_speed_pct`) | source: talisman | family | +3.0 % | +20.0 % | Designed | 1 |
| Art speed (`art_speed_pct`) | derived: quick, slow (Pending) | family | +3.0 % | +20.0 % | Pending | 2 |
| Art cost (`art_cost_pct`) | — | universal | -1.0 % | -6.6 % | Designed | 1 |
| Art cost (`art_cost_pct`) | type: physical or force | broad | -1.2 % | -8.3 % | Designed | 2 |
| Art cost (`art_cost_pct`) | element | family | -1.5 % | -10.0 % | Designed | 5 |
| Art cost (`art_cost_pct`) | form | family | -1.5 % | -10.0 % | Designed | 5 |
| Art cost (`art_cost_pct`) | mode: curse | family | -1.5 % | -10.0 % | Designed | 1 |
| Art cost (`art_cost_pct`) | derived: slow, costly (Pending) | family | -1.5 % | -10.0 % | Pending | 2 |
| Art cost (`art_cost_pct`) | effect: poison | narrow | -2.0 % | -13.3 % | Designed | 1 |
| Basic attack speed | — (implied basic) | family | +4.5 % | +30.0 % | Pending | 1 |
| Status duration | — (implied over_time) | family | +3.0 % | +20.0 % | Pending | 1 |
| Status duration | mode: curse | narrow | +4.0 % | +26.6 % | Pending | 1 |
| Status duration | effect: poison | pinpoint | +5.0 % | +33.3 % | Pending | 1 |

**Combat: defence**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Resistance (`resist_pct`) | — (all resistance) | universal | +0.9 pp | +6.4 pp | Designed | 1 |
| Resistance (`resist_pct`) | against type: physical or force | broad | +1.2 pp | +8.0 pp | Designed | 2 |
| Resistance (`resist_pct`) | against type: fire, cold, lightning, light | family | +1.4 pp | +9.6 pp | Designed | 4 |
| Resistance (`resist_pct`) | against type: chaos (rare, rule 13: never on acupoints, notables or rolled affixes) | family | +1.4 pp | +9.6 pp | Designed | 1 |
| Resistance (`resist_pct`) | against foe: cultivator (Pending) | broad | +1.2 pp | +8.0 pp | Pending | 1 |
| Resistance (`resist_pct`) | against foe: creature (Pending) | family | +1.4 pp | +9.6 pp | Pending | 1 |
| Resistance (`resist_pct`) | against type + one family tag, e.g. [fire, over_time] | narrow | +1.9 pp | +12.8 pp | Designed | — |
| Block (`block_rating`) | — | universal | +3 rating | +20 rating | Designed | 1 |
| Block (`block_rating`) | against type: physical or force (Pending) | broad | +3 rating | +25 rating | Pending | 2 |
| Block (`block_rating`) | against type: fire, cold, lightning, light (Pending) | family | +4 rating | +30 rating | Pending | 4 |
| Body shield (`body_shield_pct`) | — | universal | +1.2 pp of health | +8.0 pp of health | Designed | 1 |
| Body shield, increased (`body_shield_pct`, I) | — | universal | +2.0 % | +13.3 % | Pending | 1 |
| Shield recharge delay (`recharge_delay_pct`) | — (implied shield) | family | -3.0 % | -20.0 % | Pending | 1 |
| Cast ward duration (`cast_ward_duration_pct`) | — (implied ward) | family | +3.6 % | +24.0 % | Pending | 1 |
| Ward strength (`defense_pct`) | — | universal | +1.2 % | +8.0 % | Live | 1 |
| Ward efficiency (`ward_efficiency_pct`) | — | universal | +1.2 % | +8.0 % | Designed | 1 |
| Maximum health (`khi_huyet_pct`) | — | universal | +1.0 % | +6.6 % | Live | 1 |
| Health regeneration (`health_regen_pct`) | — | universal | +0.40 pp/pulse | +2.66 pp/pulse | Designed | 1 |
| Healing (`healing_pct`) | — | universal | +2.4 % | +16.0 % | Designed | 1 |
| Healing (`healing_pct`) | restores: body_shield (Pending) | narrow | +4.8 % | +32.0 % | Pending | 1 |
| Healing taken (`healing_taken_pct`) | — | universal | +2.4 % | +16.0 % | Designed | 1 |
| Evade (`evade_pct`) | — | universal | +0.8 pp | +5.3 pp | Designed | 1 |
| Soul resistance (`soul_res_pct`) | — | universal | +2.0 pp | +13.3 pp | Designed | 1 |
| Status resistance (`status_resist_pct`) | — | universal | +3.0 pp | +20.0 pp | Designed | 1 |
| Status resistance (`status_resist_pct`) | against mode: over_time or curse | family | +4.5 pp | +30.0 pp | Designed | 2 |
| Status resistance (`status_resist_pct`) | against effect: poison | narrow | +6.0 pp | +40.0 pp | Designed | 1 |
| Status resistance (`status_resist_pct`) | against status: burn, bleed, frostbite, qi_burn (Pending) | narrow | +6.0 pp | +40.0 pp | Pending | 4 |
| Status duration on you (`status_duration_taken_pct`) | — (all statuses) | universal | -4.0 % | -26.6 % | Pending | 1 |
| Status duration on you (`status_duration_taken_pct`) | mode: over_time or curse | family | -6.0 % | -40.0 % | Pending | 2 |

**Resources**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Maximum linh lực (`linh_luc_pct`) | — | universal | +1.2 % | +8.0 % | Live | 1 |
| Linh lực regeneration (`linh_luc_regen_pct`) | — | universal | +0.15 pp/s | +1.00 pp/s | Designed | 1 |
| Thần thức (`than_thuc_pct`) | — | universal | +0.9 % | +6.1 % | Live | 1 |
| Reservation efficiency (`reserve_eff_pct`) | — | universal | +1.5 % | +10.0 % | Designed | 1 |

**Gear**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Artifact power (`artifact_power_pct`) | — | universal | +0.9 % | +6.1 % | Live | 1 |
| Artifact power (`artifact_power_pct`) | role | family | +1.3 % | +9.2 % | Designed | 4 |
| Artifact attack (`artifact_attack_pct`) | — | universal | +2.0 % | +13.3 % | Live | 1 |
| Artifact defence (`artifact_defense_pct`) | — | universal | +2.0 % | +13.3 % | Live | 1 |
| Element affinity (`element_affinity_pct`) | — | family | +1.3 % | +9.2 % | Live | 1 |
| Artifact thần thức cost (`than_thuc_cost_pct`) | — | universal | -1.5 % | -10.0 % | Live | 1 |

**Preparation and companions**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Formation power (`formation_power_pct`) | — | universal | +1.2 % | +8.0 % | Live | 1 |
| Pill effect (`pill_effect_pct`) | — | universal | +1.2 % | +8.0 % | Live | 1 |
| Talisman power | — | universal | +1.7 % | +11.4 % | Pending | 1 |
| Talisman keep chance | — | universal | +4.0 pp | +26.6 pp | Pending | 1 |
| Formation upkeep (`formation_upkeep_pct`) | — | universal | -8.0 % | -53.3 % | Pending | 1 |
| Talisman ink cost (`talisman_ink_pct`) | — | universal | -8.0 % | -53.3 % | Pending | 1 |
| Companion power share | — | universal | +3.0 pp | +20.0 pp | Pending | 1 |

**Escape and fortune**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Escape chance (`escape_pct`) | — | universal | +1.2 pp | +8.0 pp | Designed | 1 |
| Stealth (`stealth`) | — | universal | +0.8 | +5.3 | Live | 1 |
| Cơ duyên rate (`co_duyen_pct`) | — | universal | +4.0 % | +26.6 % | Live | 1 |

**Cultivation and life**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Cultivation speed (`cultivation_speed_pct`) | — | universal | +0.5 % | +3.6 % | Live | 1 |
| Cultivation speed (`cultivation_speed_pct`) | activity: secluded or travelling (Pending) | family | +0.8 % | +5.4 % | Pending | 2 |
| Breakthrough chance (`breakthrough_chance`) | — | universal | +0.2 pp | +1.6 pp | Live | 1 |
| Lifespan, share (`lifespan_pct`) | — | universal | +0.4 % | +2.6 % | Live | 1 |
| Heart demon resistance (`tam_ma_resist_pct`) | — | universal | +0.8 % | +5.3 % | Live | 1 |
| Qi deviation chance (`qi_deviation_pct`) | — | universal | -1.2 % | -8.0 % | Live | 1 |
| Pill toxicity resistance (`dan_doc_resist_pct`) | — | universal | +0.7 % | +5.0 % | Live | 1 |
| Pill toxicity fading (`dan_doc_decay`) | — | universal | +0.15 | +1.00 | Live | 1 |
| Spirit qi density (`density_bonus`) | — | universal | — | +0.05 | Live | 1 |

**Crafting, travel and economy**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Alchemy success (`alchemy_success`) | — | universal | +0.4 pp | +2.9 pp | Live | 1 |
| Refining success (`refining_success`) | — | universal | +0.6 pp | +4.0 pp | Live | 1 |
| Talisman drawing success | — | universal | +0.6 pp | +4.0 pp | Pending | 1 |
| Taming chance | — | universal | +1.2 pp | +8.0 pp | Pending | 1 |
| Herb growth (`herb_growth_pct`) | — | universal | +1.3 % | +8.8 % | Live | 1 |
| Mission income (`mission_income_pct`) | — | universal | +1.7 % | +11.4 % | Live | 1 |
| Travel speed (`travel_speed_pct`) | — | universal | +4.0 % | +26.6 % | Live | 1 |
| Pill quality chance (`pill_quality_chance`) | — | universal | +1.2 pp | +8.0 pp | Pending | 1 |
| Artifact grade chance (`refine_grade_chance`) | — | universal | +0.8 pp | +5.3 pp | Pending | 1 |
| Buy price (`buy_price_pct`) | — | universal | -4.0 % | -26.6 % | Pending | 1 |
| Sell price (`sell_price_pct`) | — | universal | +4.0 % | +26.6 % | Pending | 1 |

**Attributes (thiên phú)**

| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |
|---|---|---|---|---|---|---|
| Comprehension (`ngo_tinh`) | — | universal | +0.24 | +1.60 | Live | 1 |
| Fortune (`khi_van`) | — | universal | +0.24 | +1.60 | Live | 1 |
| Root bone (`can_cot`) | — | universal | +0.40 | +2.66 | Live | 1 |
| Soul (`than_hon`) | — | universal | +0.40 | +2.66 | Live | 1 |
| Dao heart (`dao_tam`) | — | universal | +0.40 | +2.66 | Live | 1 |
| Presence (`mi_luc`) | — | universal | +1.20 | +8.00 | Live | 1 |

Concrete modifiers listed: 224 (two-tag rows not counted).

Two sizes need care. A notable of health regeneration (+2.66 pp per pulse) is above the stat's own 2 pp cap
(Combat Defence & Healing Formulas E), so a source should carry it at small size or as part of a larger piece.
A notable of crit chance (+8 pp) is a sixth of the 50 % cap. Both are listed in Open Questions.

**Damage, more (L2 and L4).** These are budgeted in layer points by their sources, not in W (rule 12), so they
have no grade sizes here.

| Modifier | Scope | Sources | Typical points | Status |
|---|---|---|---|---|
| Damage, more L2 (`damage_more`) | arts and their tags: damage type, element, form, art | techniques, arts, Way art nodes | 5–50 per piece; a build's typical L2 is +40, the cap 300 | Designed |
| Damage, more L4 (`damage_more`) | preparation: formation, talisman, pill coating, ground tags | formations, talismans, pills, coatings | a build's typical L4 is +20, the cap 150 | Designed |

**Rare.** Counts come one unit each; rare-by-row stats are sized by Formulas C from the source's budget. Only on sources whose budget covers the price (rule 13).

| Modifier | Unit | W | Allowed sources | Status |
|---|---|---|---|---|
| Art slots (`bonus_slots`) | +1 slot | 20 | keystones, named items, quest rewards, Way capstones | Designed |
| Ward slots (`bonus_ward_slots`) | +1 slot | 30 | same | Designed |
| Resistance cap raise (`resist_cap_pct`) | per pp (to 90 %) | 5 / pp | same | Designed |
| Chaos resistance (`resist_pct` [chaos]) | per pp | 1.25 / pp stored (0.83 effective) | same, and Chaos-themed named items | Designed |
| Artifact slots | +1 slot | 25 | same | Pending |
| Beast slots | +1 beast kept | 15 | same | Pending |
| Talisman stock | +1 use | 10 | same, and named talisman sleeves | Pending |
| Status stack cap | +1 stack | 10 | same | Pending |
| Spirit field plots (`field_plots`) | +1 plot | 20 | same | Live |
| Pills per brew (`alchemy_yield`) | +1 pill | 20 | same | Live |

**Lifespan in years** (`lifespan_years`) is priced per realm (300 / L_r W per year). At Qi Refining
(L_r 120) a small buys +0.4 years and a notable +3.2 years; at Nascent Soul (L_r 1,000), +4.0 and +26.6
years.

**Retired:** body guard (`body_guard_pct`), replaced by block and the body shield.

### States and Transitions

None. A modifier is a static record with no state of its own: it is applied while its source is active
and absent otherwise (rule 2). Activation, expiry and timing are each source's states (a node allocated,
an artifact equipped, a pill in effect, a formation laid, an Effect's condition holding).

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Combat (#21) | out | Damage modifiers into L1 (increased) and L2/L4 (more); crit, accuracy, pierce, art speed, art cost, ward, resistance, block, body shield, evade, soul, status and escape stats; scope matching against hit, art and status tags | Combat (formulas, caps, tags); this system (records, ops, scope) |
| Character Stats (#7) | out | Every sheet stat's flat and increased sums through the provider interface; precision grid and ceilings | Character Stats |
| Meridian Map (#10) | out | The catalogue, W prices and breadth for acupoints and notables; the tree sets its own budgets and mix | Meridian Map (budgets, layout); this system (prices) |
| The Way (Đạo) (#39) | out | Catalogue modifiers for Way nodes, including `more` L2 on art nodes | The Way |
| Cultivation Techniques (#9) | out | Technique bonuses and art "more" (L2) as catalogue modifiers | Cultivation Techniques |
| Item DB (#13), Artifact Refining (#16) | out | Affix modifiers and artifact stats; rare modifiers only on named items | Item DB |
| Alchemy (#15), Formations (#17), Talismans (#18) | out | Pill, formation and talisman modifiers, mostly `more` L4 and preparation stats | each system |
| Spirit Beasts (#19) | out | Companion and beast stats (Pending) | Spirit Beasts |
| Progression Edges (#11), Spiritual Roots (#6) | out | Perk and root bonuses as catalogue modifiers | each system |
| Quests (#31), LLM Game Master | out | W prices to size rewards; catalogue-only grants (rule 16) | Quests; LLM GM (budgets) |
| NPC Builds | out | The same catalogue and prices (rule 15) | NPC Builds |
| Effects System (#41) | out | Effects grant catalogue modifiers as payloads; the flag and scaling keys move there | Effects |
| Combat Defence & Healing (#21a) | out | Resistance, penetration, block, body shield, ward strength and efficiency, reservation, healing and ward-slot modifiers; scope matching on incoming parts' final type | Combat Defence & Healing (formulas); this system (records, prices) |
| Combat Damage Types (#21b) | in | The damage-type tag family, history tags on converted parts, element tags as art tags | Combat Damage Types |
| Debug Terminal, Game UI (#37) | out | Breakdown lines and tag filters | Game UI |

## Formulas

> `systems-designer` consulted 2026-11-07 for prices, breadth, the `more` exchange rate and grades.
> The user chose five breadth tiers, points plus an exchange rate for `more`, rare stats on big-budget
> sources only, and reservation kept (now Designed, Combat Defence & Healing rule 10). Every price marked G is a guess until
> `tools/balance/autoplay.gd` measures it.

**Anchor.** Prices are marginal values at Combat's Qi Refining typical anchor (Combat Formulas B). There,
x1 = 26.5 and L1 = 1.265, so one W of L1 adds 0.791 % to log damage. A stat's price is its marginal value
divided by that, **per unit, to a build that uses the stat**. Stats with their own multiplier (crit, art
speed, soul attack damage, evade, basic attack speed) are not diluted by the L1 sum, which is why some are
worth more per point than a point of L1.

### A. Price table

The stat_price values are defined as a data table (`modifier_prices`), one W price per displayed unit.
The Meridian Map's Formulas F weights move here unchanged. **D** marks a price derived from the owning
formula; **G** marks a guess.

| Stat | W / unit | | Basis |
|---|---|---|---|
| Crit chance | 1.0 / pp | D | 0.97 at a committed anchor (chance 0.3, ×2.0); 0.80 at typical (15 %, ×1.7). The old catalogue size (about 3.0) was a trap |
| Crit damage | 0.3 / pp | D | 0.29 at chance 0.3, and 0 with no chance (base chance is 0): a support stat |
| Accuracy | 0.5 / pp | G | Worth 0.01 / (1 − evade), and only against evade; no GDD sets the enemy evade mix |
| Realm pierce | 1.0 / pp | D | 0.14 / 0.42 / 1.26 at gap 1 / 2 / 3; priced near gap 3 to protect the "never three realms up" target |
| Soul attack damage | 1.0 | D | Its own sum: 1.265 × the soul share of damage. Implied [soul] |
| Art speed | 0.6 | D | 0.85 when linh lực is not the limit (arts are about 2/3 of damage), near 0 when it is |
| Art cost | 1.2 / pp reduced | D | Mean slope of 1/(1 − r) over 0–50 % on the arts' 2/3 share |
| Basic attack speed | 0.4 | D | The basic attack is about 0.35 of the hit rate, own multiplier, no cost. Implied [basic] |
| Status duration | 0.6 | G | Own multiplier on tick count for a status build. Implied [over_time] |
| Status stack cap | 10 / stack, rare | G | 5 → 6 stacks is +20 %, under the pool caps |
| Ward strength | 1.0 | — | Meridian Map table |
| Ward efficiency | 1.0 | G | Combat's guess kept; an effective-health proxy gives 1.17× health's value (Combat Open Question 14) |
| Maximum health | 1.2 | — | Meridian Map table |
| Body guard | retired | — | Replaced by block and the body shield (Combat Defence & Healing) |
| Resistance, all and by type | 1.25 / pp, one stored price; the effective prices after breadth are 1.0 (Physical, Force: 1.25 / 1.25) and 0.83 (other types: 1.25 / 1.5). Formulas C applies breadth once, to the stored price | D | Combat Defence & Healing Formulas I (user decision 2026-11-08) |
| Resistance cap raise; penetration | 5 / pp, rare; 3.0 / pp | D | Combat Defence & Healing Formulas I |
| Block rating | 0.4 / point | D | 0.41 to a thể tu, 0.22 to a typical side |
| Body shield | 1.0 / pp of health_max | D/G | Pegged to health; Chaos passes it and it never refills |
| Health regeneration | 3.0 / pp per pulse | D/G | Combat Defence & Healing Formulas I |
| Healing taken | 0.5 / % | G | |
| Ward slots | 30 / slot, rare | D/G | |
| Evade | 1.5 / pp | D | 0.01 / (1 − p): 1.26 at 0, 2.07 at the 0.40 cap |
| Soul resistance | 0.6 / pp | D/G | Through rho^−2 against a soul attacker; about 0 otherwise |
| Status resistance | 0.4 / pp | D/G | Applies only to chance statuses; chance-1 statuses ignore it |
| Healing | 0.5 / % | G | No heal-build anchor yet (Combat Defence & Healing Formulas I) |
| Maximum linh lực | 1.0 | — | Meridian Map table |
| Linh lực regeneration | 8 / pp | D | +1 pp/s over a typical 8 s fight is about +8 % of the pool. Uses the 0.01 grid |
| Reservation efficiency | 0.8 / % (counts to 50) | D | At a 50 % total reservation (Combat Defence & Healing Formulas I) |
| Thần thức | 1.3 | — | Meridian Map table |
| Artifact power | 1.3 | — | Meridian Map table |
| Artifact attack | 0.6 | D | 0.36 at typical L3 1.4, about 0.6 near the 250 cap, 0 at the cap |
| Artifact defence | 0.6 | D | 0.51 through ward gear, about 0.35 on body gear; attack + defence ≈ artifact power |
| Element affinity | 1.3 | D | Same multiplier as artifact power, on matched artifacts only. Implied family |
| Artifact thần thức cost | 0.8 / pp reduced | G | The capacity part of thần thức's 1.3 |
| Art slots | 20 / slot, rare | G | Mostly choice; the gain is held back by cost shares (Combat A2) |
| Artifact slots | 25 / slot, rare | G | |
| Formation power | 1.0 | — | Meridian Map table |
| Pill effect | 1.0 | G | Pills feed both cultivation and L4 |
| Talisman power | 0.7 | G | Fills L4 like formation power, but talismans are used up |
| Talisman keep chance | 0.3 / pp | G | Economy value only |
| Talisman stock | 10 / use, rare | G | |
| Companion power share | 0.4 / pp | D | +1 pp is c_comp +0.01: 0.01 of a basic hit per second against a hit rate of about 3 |
| Beast slots | 15 / slot, rare | G | |
| Escape chance | 1.0 / pp | G | Its worth is a death avoided, outside the fight; `escape_bonus` caps it at 0.3 |
| Stealth | 1.5 | — | Meridian Map table |
| Fortuitous encounter rate, travel speed | 0.3 | G | Kept from Spiritual Roots Formulas E |
| Cultivation speed | 2.2 | — | Meridian Map table |
| Breakthrough chance | 5 / pp | — | Meridian Map table |
| Lifespan, years | 300 / L_r per year | — | Meridian Map table |
| Lifespan, share | 3.0 / pp | D | 1 % of L_r is L_r / 100 years × 300 / L_r |
| Heart demon resistance | 1.5 | — | Meridian Map table |
| Qi deviation chance | 1.0 / pp reduced | D/G | A plain ×(1 + q) on the deviation chance, weaker than heart demon resistance |
| Pill toxicity resistance, fading | 1.6; 8 | — | Meridian Map table |
| Spirit qi density | 140 | — | Meridian Map table |
| Alchemy success, refining success | 2.7; 2.0 | — | Meridian Map table |
| Pills per brew | 20 / pill, rare | G | Same convention as field plots |
| Herb growth, field plots | 0.9; 20, rare | — | Meridian Map table |
| Talisman drawing success | 2.0 / pp | G | Same as refining success |
| Taming chance | 1.0 / pp | G | |
| Mission income | 0.7 | — | Meridian Map table |
| Comprehension, fortune | 5 | — | Meridian Map table |
| Root bone (căn cốt) | 3.0 | D | +1 at talent 45 is +2.22 % health on its own multiplier |
| Soul (thần hồn) | 3.0 | D | +2.22 % thần thức; soul builds gain double through rho² |
| Dao heart (đạo tâm) | 3.0 | G | Raises the deviation threshold by 0.5 per point; other uses not checked |
| Presence (mị lực) | 1.0 | G | About 0.4 % better trade both ways; social value undefined |

### B. Breadth multiplier

The breadth_mult formula is defined as:

`breadth_mult = m[tier(S ∪ I)]`, where `tier(∅) = universal`; one tag gives `tier(t)`; two tags give
`min(pinpoint, tier(narrower) + [tier(other) ≥ family])`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| S | tag set | 0–2 tags | modifier record | The modifier's scope |
| I | tag set | 0–1 tag | Stat List (rule 11) | Implied tag of a one-family stat |
| tier(t) | enum | universal, broad, family, narrow, pinpoint | tag vocabulary (rule 11) | Tier of each tag |
| m | float | 1.0 / 1.25 / 1.5 / 2.0 / 2.5 | data file (`breadth_mult`) | Multiplier per tier |

**Output Range:** 1.0 to 2.5. The pinpoint tier caps it.

**Example:** [physical] 1.25 · [hoa] 1.5 · [physical, hoa] 1.5 (a broad second tag adds nothing) · [sword, hoa] 2.0 ·
[poison, hoa] 2.5 · [art, sword] 1.5 · soul attack damage with no scope counts as [soul], so 1.25.

### C. Modifier value

The modifier_value formula is defined as:

`modifier_value = d · floor(B · breadth_mult / (price · u) + 1e-6) · u`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| B | float | 0 to about 60 W (a notable is 8 W; rare sources up to 60) | source GDD | The W budget spent on this modifier |
| breadth_mult | float | 1.0–2.5 | Formulas B | Breadth premium |
| price | float | 0.3–140 W per unit | Formulas A | W per displayed unit |
| u | float | 0.01 / 0.1 / 1 | Character Stats Formulas I | The stat's precision grid |
| d | int | +1 or −1 | Stat List "Better" | −1 for lower-is-better stats (art cost, qi deviation) |

**Output Range:** about 215 units in the tree (25.8 W on a 0.3 W stat at ×2.5), and up to 500 at the 60 W top of B. If the floor gives 0 units, the
stat cannot be carried at that budget: the source picks another stat, and the value is never raised to
one unit. A penalty is authored as a value and is worth |value| · price / breadth_mult W, with no floor.

**Example:**
- A notable (8 W) of universal crit chance: 8 · 1.0 / 1.0 = **+8.0 pp**.
- A small (1.2 W) of Fire damage: 1.2 · 1.5 / 1.0 = **+1.8 %**.
- A notable of art cost: 8 / 1.2 = 6.67, floored to **−6.6 %**.
- A small of regeneration on the 0.01 grid: 1.2 / 8 = **+0.15 pp/s**. On the 0.1 grid it would floor to
  0.1 and lose a third.

### D. The `more` exchange rate

The more_price formula is defined as:

`more_price(i, r) = L1_typ(r) / (σ(r) · L_i_typ)`, where `σ = 1` if `x1_typ(r) ≤ l1_soft_start`, else
`l1_soft_slope`. No trade is allowed when `x_i_typ` is at or above `cap_i`.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| i | enum | L2, L4 | modifier record | Target layer |
| r | enum | Qi Refining to Deity Transformation | the source's realm tier | Realm |
| L1_typ(r) | float | 1.265–3.465 | Combat Formulas B typical anchor | L1 at 25 % of tree W |
| L_i_typ | float | L2 1.4, L4 1.2 | Combat Formulas B | Typical layer value |
| σ(r) | float | 1 or 0.5 | Combat Formulas B (`l1_soft_start` 200, `l1_soft_slope` 0.5) | L1 slope past the knee |

**Output Range:** 0.90 to 5.78 W per point.

| Realm | QR | FE | CF | NS | DT |
|---|---|---|---|---|---|
| L2 | 0.90 | 1.16 | 1.51 | 2.03 | 4.95 |
| L4 | 1.05 | 1.35 | 1.76 | 2.37 | 5.78 |

Sources that budget `more` in points (rule 12) size them against Combat's anchors: L2 typical +40, up to
the 300 cap at the top end; L4 typical +20, up to the 150 cap. This answers Combat Open Question 5.

The table is rounded to 2 decimals for display; calculations use the unrounded rate, and W results round to
0.1. Points are on a 0.1 grid.

**Example:** a Way art node of +20 L2 at Core Formation is worth 20 × 1.513 = **30.3 W**. A Qi Refining W
budget of 8 W buys floor(8 / 0.904 / 0.1) × 0.1 = **8.8 L2 points**.

### E. Reference grades

| Grade | Budget B | Where |
|---|---|---|
| small | 1.2 W (S0) | One acupoint at premium 1 |
| notable | 8 W (N0) | One tree notable at premium 1 |

The Meridian Map applies its own premium (1.25–1.75, and up to about 2.15 in shrunk clusters) and root
scaling (×1.5), so in-tree values are 1.5–2.1 W and 10–14 W, and at most about 25.8 W. Other sources
publish their own budgets in W. A lint flags any stat and grade pair that loses more than 15 % to
rounding.

**Example:** at the two reference grades, universal damage is +1.2 % / +8 %, Fire damage +1.8 % / +12 %,
crit chance +1.2 / +8 pp, art speed +2.0 % / +13.3 %, and maximum health +1.0 % / +6.6 %.

### Realm drift

One W of L1 is worth less at higher realms, because L1 grows and passes its knee. The ratio is
k_r = 1.0 / 1.28 / 1.67 / 2.25 / 5.48 from Qi Refining to Deity Transformation. Every stat with its own
multiplier is fixed at its Qi Refining price, so it grows relatively cheaper as realms rise: crit chance is
worth about 4.4 W per point at Deity Transformation. **Proposed default (2026-11-07, not yet a user
decision):** the balance bot measures the drift first, and no deflator is applied until it has (Open
Questions).

## Edge Cases

> `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**Records and validation**
- **If a record names an unknown stat, an operation the stat does not allow, or `more` on a stat other than
  damage**: data validation rejects it and names the record.
- **If a value is off its stat's precision grid**: validation rejects it (Character Stats Formulas I).
- **If a scope holds three or more tags, an unknown tag, or a tag the stat's target can never match**
  (damage scoped [soul], resistance scoped by an element tag): validation rejects it.
- **If a designer adds a classification tag outside the vocabulary**: rejected. Derived tags cannot be
  removed.
- **If a modifier is `more` with no layer, or a layer other than L2 or L4**: rejected.

**Values**
- **If the conversion floors to 0 units** (a small budget on an expensive stat): the stat cannot be carried at
  that budget; the source picks another stat, and the value is never raised to one unit (Formulas C).
- **If a modifier is negative**: it uses the same record. Penalties apply after ceilings (Character Stats
  rule 14), and the Breakdown shows them as penalties in the stat's better direction.
- **If a stat's sum passes its owner's cap** (Combat's layer caps, crit 0.5, evade 0.40, resistance 0.75,
  health regeneration 2 pp, Character Stats' ceilings): the owner clips it, and the Breakdown names the cap.
  This system never caps.
- **If a single modifier is larger than its stat's cap** (a notable of health regeneration is 2.66 pp against
  a 2 pp cap): it is legal but wasteful. A source GDD should size it below the cap.
- **If a rare modifier appears on an acupoint, a tree notable or a rolled affix**: validation rejects it
  (rule 13).

**Scope**
- **If a scoped modifier matches nothing in a fight**: it is not listed for that hit in the Breakdown, and it
  stays on the sheet.
- **If a part was converted**: offence modifiers read its type and history; resistance, block and
  penetration read its final type only (Combat Damage Types rule 6).
- **If a damage-type scope and an element scope both name "Fire"**: they are different modifiers. "+12 % Fire
  damage" reads the part's damage type; "+12 % damage on Fire-element arts" reads the art's element tag.
- **If a derived art tag is not yet adopted by Combat**: modifiers scoped by it are accepted, marked Pending,
  and do nothing (rule 10). A modifier on a Pending *stat* is rejected instead.

**Sources and the world**
- **If a source is removed** (a node unallocated, an artifact unequipped, a pill wearing off, an Effect's
  condition ending): its modifiers vanish at once (rule 2).
- **If the LLM Game Master proposes a stat, operation or tag outside the catalogue**: the engine rejects the
  proposal (rule 16); a budget it cannot spend on catalogue stats is lost.
- **If an NPC is generated**: it draws from the same catalogue at the same prices (rule 15).

## Dependencies

| System | Kind | What this system needs | Status | Lists this system? |
|---|---|---|---|---|
| Combat (#21) | Hard | Layers L1–L5 and caps, tag families, crit, evade, escape, soul formulas | Approved for rules | Partly: its Formulas B names W pricing; the Combat revision (#43) cites this GDD for operations and scope |
| Combat Defence & Healing (#21a) | Hard | What the defence stats do; their prices (Formulas I) | Needs revision | Yes |
| Combat Damage Types (#21b) | Hard | The damage-type family that scopes damage, penetration and resistance | Needs revision | Yes |
| Character Stats (#7) | Hard | The sheet sums, precision grid, ceilings, the provider interface | In review | Not yet: its Parameter keys need the new stats |
| Meridian Map (#10) | Soft (reads this) | Catalogue, prices, breadth; owns its own budgets and mix. The W weight table moves here from its Formulas F | Redesign planned | Not yet: its Formulas F should point here |
| The Way (#39), Cultivation Techniques (#9) | Soft (read this) | Catalogue modifiers, including `more` L2 | Approved; in review | Not yet |
| Item DB (#13), Artifact Refining (#16) | Soft (read this) | Affix modifiers; rare modifiers on named items only | Approved; built | Not yet |
| Alchemy (#15), Formations (#17), Talismans (#18), Spirit Beasts (#19) | Soft (read this) | Preparation stats and `more` L4; Pending stats need their keys | Implemented, quick specs | Not yet |
| Progression Edges (#11), Spiritual Roots (#6) | Soft (read this) | Perk and root bonuses as catalogue modifiers | Implemented; in review | Not yet |
| Quests (#31), LLM Game Master | Soft (read this) | W prices; catalogue-only grants | Designed; implemented | Partly: Quests cites `stat_power_weights` |
| Effects System (#41) | Soft (reads this) | Effects grant catalogue modifiers; the four flag and scaling keys move there | Needs revision | Yes |
| NPC Builds | Soft (reads this) | The same catalogue and prices | Implemented | Not yet |

## Visual/Audio Requirements

> `art-director` not consulted — Lean mode; the current client is the text Debug Terminal.

Modifiers have no effects of their own; they are read. Each modifier line uses its stat family's icon and,
when scoped by a damage type, that type's colour (Combat Damage Types, Visual/Audio). Increased, flat and
more are written differently so a reader can tell them apart at a glance: "+12 % Fire damage", "+20 block",
"+15 more art damage (L2)". No audio.

## Game Feel

- **Reading a node should take one second.** A modifier is one line in a fixed shape: sign, number, unit,
  stat, scope.
- **Stacking should feel like building.** The sheet shows each stat's sum and where it came from, so a player
  sees their build grow line by line.
- **Narrow should feel rewarding.** A Fire-only build sees bigger Fire numbers than a universal one for the
  same tree point, because the breadth premium shows in the value.

## UI Requirements

- **One line per modifier** in a fixed shape: `+12 % Fire damage`, `−6.6 % art cost`, `+20 block`,
  `+15 more art damage (L2)`.
- **Tags as filters:** nodes, items, techniques and the Breakdown can be filtered by any classification tag
  (rule 9). A node with several modifiers shows under each tag. In the Debug Terminal this is a proposed
  `filter <tag>` command; its exact form belongs to the UX spec.
- **Breadth badge:** universal, broad, family, narrow or pinpoint, shown on tree nodes for planning.
- **Sheet:** each stat's flat sum, increased sum, the cap if one binds, and the list of sources.
- **Breakdown:** every applied modifier with its source, operation, scope and value (rule 14).

> **📌 UX Flag — Modifier System**: This system has UI requirements. In Phase 4 (Pre-Production), run
> `/ux-design` for the stat sheet and the tree node tooltip **before** writing epics. Stories that reference
> UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This document | References | Value or rule | Use |
|---|---|---|---|
| Rules 5–6 | combat.md rule 5, Formulas B | Layers L1–L5, caps 400/300/250/150/100, the L1 knee | Read |
| Rule 7 | combat.md Formulas C, I; character-stats.md Formulas I, rule 14 | Crit, evade and escape caps; ceilings; penalties after ceilings | Read |
| Rules 8–9 | combat.md rule 6; combat-damage-types.md rules 1, 2, 6, 9 | Tag families; damage types; elements as art tags | Read |
| Rule 8, Stat List | combat-defence.md rules 2–4, 6, 9–12; Formulas A–E, I | What resistance, block, body shield, ward and healing stats do; their prices | Read |
| Rule 12, Formulas A | kinh-mach-do.md Formulas F | The W weight table | Moved here (user decision 2026-11-07) |
| Formulas D | combat.md Formulas B anchors | Typical L2 1.4, L4 1.2, L1 by realm | Read; answers Combat Open Question 5 |
| Formulas E | kinh-mach-do.md Formulas A–D | Acupoint 1.2 W, notable 8 W, premium P, w̄_target 2.07 | Read |
| Stat List | `character_stat_labels.json`, `meridian_capabilities.json` | Live keys and capabilities | Read |
| Rules 1, 6, 15 | effects.md rules 1, 3, 15 | The Modifier / Effect split; L5 only as an Effect payload; Effects grant catalogue modifiers | Read; shared boundary |

## Tuning Knobs

Added 2026-11-08; no value changed. Safe ranges are design estimates until the balance harness measures
them. Changing a price, tier multiplier or grade means regenerating the General Catalogue (AC-MD-27).

| Knob | Default | Safe range | What it tunes | Source |
|---|---|---|---|---|
| Reference grades | small 1.2 W, notable 8 W | owned by the Meridian Map (Formulas E) | Catalogue sizes; every source's budget scale | Rule 12, Formulas E |
| Breadth multipliers | 1.0 / 1.25 / 1.5 / 2.0 / 2.5 | keep the order; the top tier at most 3.0 | How much bigger narrow modifiers are | Rule 11, Formulas B |
| Tags per scope | 2 | 1–2 (3 makes pinpoint the norm) | How narrow a plain modifier can get | Rule 8 |
| Stat prices (`modifier_prices`) | the Formulas A table | ±30 % per stat, then harness | Which stats are good value | Formulas A |
| Rare price range | 10–30 W | above the notable's 8 W | Where slot and cap stats may appear | Rule 13 |
| Derived art tag thresholds | quick < 2 s, slow ≥ 6 s, cheap ≤ 5 %, costly ≥ 20 % | quick 1.5–2.5 s; slow 5–8 s; cheap 4–6 %; costly 18–25 % | Which arts the derived scopes reach | Rule 10 (Combat to adopt) |
| `more` exchange rate inputs | Combat's L1/L2/L4 anchors, `l1_soft_start` 200, `l1_soft_slope` 0.5 | Combat's | W per `more` point when W must buy points | Formulas D |

## Acceptance Criteria

> Drafted by `qa-lead` 2026-11-07. The gaps it found are fixed in rules 8, 10, 13 and 16, the Stat List,
> Formulas B and D, Edge Cases, Interactions and UI Requirements. Logic tests live in `tests/unit/modifiers/`,
> integration tests in `tests/integration/modifiers/`. Fixtures are fixed, with no randomness and no clock.
> Literal numbers are boundary values or the worked examples of Formulas A–E.

**Record, operations and stacking**

- **AC-MD-01** [Logic] Rule 1. **GIVEN** records with `stat: foo_pct`, with `op: flat` on `art_speed_pct`, and with `crit_chance_pct` value 1.25 on a 0.1 grid, **WHEN** validated, **THEN** each is rejected and the error names the record and the field. **GIVEN** a record with a `condition`, `duration` or `trigger` field, **THEN** it is rejected.
- **AC-MD-02** [Integration] Rule 2. **GIVEN** an equipped artifact granting +12 % Fire damage, **WHEN** it is unequipped (or a node holding it is unallocated), **THEN** the stat drops on the same update and no Breakdown line names that source. **WHEN** it is re-equipped, **THEN** the stat is restored.
- **AC-MD-03** [Logic] Rule 3. **GIVEN** −3 % art cost, **THEN** it is shown as a bonus, and +3 % as a penalty. **GIVEN** a `breakthrough_chance` sum clipped to its ceiling plus a −2 pp penalty, **THEN** the result is ceiling − 2 pp.
- **AC-MD-04** [Logic] Rule 4. **GIVEN** base crit chance 0.15 and flat +0.5 `crit_chance_pct`, **THEN** crit chance is 0.155. **GIVEN** flat +10 `lifespan_years`, **THEN** lifespan rises by exactly 10 years.
- **AC-MD-05** [Logic] Rule 5. **GIVEN** base 100, flats +20 and −5, and increased +30 and +20, **THEN** the stat is 115 · 1.5 = 172.5. **GIVEN** Σ increased = −150, **THEN** the stat is 0, never negative. **GIVEN** `attack_pct` modifiers, **THEN** their increased sum equals the L1 value Combat reads.
- **AC-MD-06** [Logic] Rule 6. **GIVEN** base hit 100, increased +50, `more` L2 +40 and `more` L4 +20, with the other layers at 1, **THEN** damage is 100 · 1.5 · 1.4 · 1.2 = 252. **GIVEN** `more` on `khi_huyet_pct`, or `more` with layer L3, L5 or no layer, **THEN** validation rejects it.
- **AC-MD-07** [Integration] Rule 7. **GIVEN** a crit-chance sum of 62 pp, **THEN** this system outputs 62 pp, Combat applies 50 pp, and the Breakdown names the crit cap. **GIVEN** a resistance sum of 0.95, **THEN** 0.75 is applied and the cap is named.
- **AC-MD-08** [Logic] Edge Cases. **GIVEN** one notable of health regeneration (+2.66 pp against the 2 pp cap), **THEN** validation accepts it and the owner clips it to 2 pp.

**Scope**

- **AC-MD-09** [Logic] Rule 8. **GIVEN** +12 % damage scoped [sword, hoa], **THEN** it applies to a part of a sword art with element hoa, and not to a palm art with element hoa or a sword art with element kim.
- **AC-MD-10** [Logic] Rule 8 targets. **GIVEN** a Physical → Fire part, **THEN** +12 % Fire resistance (on the defender) and +12 % Physical damage (on the attacker) both apply. **GIVEN** a Fire → Physical part, **THEN** +12 % Fire resistance does not apply: resistance reads the final type, offence reads the type history.
- **AC-MD-11** [Logic] Edge Cases. **GIVEN** a Fire-element art with one Physical part of 100, **WHEN** "+12 % Fire damage" (damage-type scope) applies, **THEN** the part stays 100. **WHEN** "+12 % damage, scope element hoa" applies, **THEN** it is 112.
- **AC-MD-12** [Logic] Rule 8 validation. **GIVEN** a scope of three tags, the unknown tag `lava`, damage scoped [soul], resistance scoped [hoa], `defense_pct` scoped [fire], or `khi_huyet_pct` scoped [sword], **THEN** each is rejected.
- **AC-MD-13** [Logic] Rule 10. **GIVEN** +12 % damage scoped [quick] while derived tags are Pending, **THEN** it is accepted, adds 0 to every hit and reads Pending. **GIVEN** the tags are adopted, **THEN** a cooldown of 1.99 s is `quick` and 2.0 s is not, 6.0 s is `slow`, a cost share of 0.05 is `cheap` and 0.20 is `costly`. **GIVEN** a modifier on a Pending stat (one with no key), **THEN** it is rejected.

**Tags**

- **AC-MD-14** [Logic] Rule 9. **GIVEN** "+12 % Fire damage" authored with no tags, **THEN** its tags include `damage`, `fire` and `combat`. **GIVEN** a record that removes one of them, **THEN** it is rejected. **GIVEN** an extra tag `shiny`, **THEN** it is rejected.
- **AC-MD-15** [Logic] Rule 9. **GIVEN** a node with +6 % `khi_huyet_pct` and +4 % `defense_pct`, **THEN** its tags are the union of both, and it is found under both `health` and `ward`. **GIVEN** two modifiers that differ only by an extra classification tag `sword`, **THEN** they give identical results on a palm hit.

**Breadth and pricing**

- **AC-MD-16** [Logic] Rule 11, Formulas B. **GIVEN** these scopes, **THEN** breadth_mult is: ∅ 1.0; [physical] 1.25; [hoa] 1.5; [physical, hoa] 1.5; [art, sword] 1.5; [sword, hoa] 2.0; [poison, hoa] 2.5; `x_soul` unscoped 1.25 (implied [soul]). **FOR** any input, **THEN** it never exceeds 2.5.
- **AC-MD-17** [Logic] Formulas C. **GIVEN** a notable (8 W) of universal crit chance, **THEN** it gives +8.0 pp. **GIVEN** a small (1.2 W) of damage scoped type `fire` or element `hoa`, **THEN** +1.8 %. **GIVEN** a notable of art cost, **THEN** −6.6 % (6.67 floored). **GIVEN** a small of `linh_luc_regen_pct` on the 0.01 grid, **THEN** +0.15 pp/s.
- **AC-MD-18** [Logic] Formulas C floor. **GIVEN** B 1.2 on `density_bonus` (140 W, u 0.01), **THEN** the conversion returns 0 units and the grant is rejected, never raised to 0.01. **GIVEN** B 8 at price 1.0, **THEN** the value is exactly 8.0 (the 1e-6 epsilon holds).
- **AC-MD-19** [Logic] Formulas C penalty. **GIVEN** −5 % universal art speed, **THEN** it is worth 5 · 0.6 / 1.0 = 3.0 W, with no floor.
- **AC-MD-20** [Logic] Formulas D. **GIVEN** more_price rounded to 2 decimals, **THEN** L2 is 0.90 / 1.16 / 1.51 / 2.03 / 4.95 and L4 is 1.05 / 1.35 / 1.76 / 2.37 / 5.78 from Qi Refining to Deity Transformation. **GIVEN** +20 L2 at Core Formation, **THEN** it is worth 30.3 W (unrounded rate). **GIVEN** 8 W at Qi Refining, **THEN** it buys 8.8 L2 points. **GIVEN** a fixture with x_i_typ ≥ cap_i, **THEN** the trade is refused and 0 points are granted.
- **AC-MD-21** [Config/Data] Formulas A, E. **GIVEN** the data, **THEN** the grades are small = 1.2 and notable = 8, and every Stat List row has a `modifier_prices` entry equal to Formulas A. **GIVEN** regeneration at small, **THEN** the rounding lint flags it on a 0.1 grid (a 33 % loss) and passes it on 0.01.
- **AC-MD-22** [Logic] Rule 12. **GIVEN** a Meridian Map acupoint or notable carrying `more`, **THEN** it is rejected.
- **AC-MD-23** [Logic] Rule 13. **GIVEN** +1 `bonus_slots` on a source of kind acupoint, notable or affix, **THEN** it is rejected. **GIVEN** the same on a keystone, a named item, a quest reward or a Way capstone, **THEN** it is accepted.

**Display and the world**

- **AC-MD-24** [Integration] Rule 14. **GIVEN** +12 % Fire damage from an artifact and +12 % sword damage from a node, in a fight with only palm Fire hits, **THEN** each hit's Breakdown lists the Fire line (source, stat, operation, scope, value at display precision) and no sword line, and the sheet still lists both.
- **AC-MD-25** [Integration] Rule 15. **GIVEN** an NPC built from a fixed fixture, **THEN** every modifier on it is a catalogue (stat, op, scope) and its value equals Formulas C at the NPC's budget. **WHEN** one price in a test copy of `modifier_prices` changes, **THEN** the NPC's value changes with it.
- **AC-MD-26** [Integration] Rule 16. **GIVEN** a mocked LLM Game Master proposal with an unknown stat, a disallowed operation or an unknown tag, **THEN** nothing is granted and the budget is lost. **GIVEN** a catalogue stat with a value above its W budget, **THEN** it is clamped to the Formulas C value.

**Data and UI**

- **AC-MD-27** [Config/Data] General Catalogue. **WHEN** `python -I tools/design/modifier_catalogue.py` runs, **THEN** its output matches the General Catalogue tables in this GDD exactly (line endings normalized), including `Concrete modifiers listed: 224`.
- **AC-MD-28** [Config/Data] Stat List. **GIVEN** every key under `labels` in `assets/data/character_stat_labels.json`, **THEN** each appears as a key in the Stat List (any status) or in "Keys that move to Effects".
- **AC-MD-29** [UI] Rule 14, UI Requirements. **GIVEN** a Debug Terminal view of a node holding `+12 % Fire damage`, `−6.6 % art cost`, `+20 block` and `+15 more art damage (L2)`, **THEN** each is one line in the shape sign, number, unit, stat, scope; a screenshot is kept in `production/qa/evidence/`.
- **AC-MD-30** [UI] Rule 9, UI Requirements. **GIVEN** the AC-MD-15 node, **WHEN** the Debug Terminal filters by `health` and then by `ward`, **THEN** the node is listed under both; **WHEN** a `fire` filter is applied to the Breakdown, **THEN** only Fire-scoped lines show; a screenshot is kept in `production/qa/evidence/`.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Realm drift: one W of L1 is worth about 5.5 × less at Deity Transformation, so own-multiplier stats (crit, evade, art speed, soul, `more`) grow cheap. The bot measures it before any deflator (proposed default, not yet a user decision) | systems-designer | Balance harness |
| 2 | Derived art tags (basic, quick, slow, cheap, costly) need Combat to adopt them; until then those scopes are Pending | user | Combat revision (#43) |
| 3 | The Meridian Map's Formulas F must point to this GDD's price table, and Character Stats' Parameter keys must list the new stats | user | Meridian Map redesign; Character Stats revision |
| 4 | Pending stats need keys from their owners: basic attack speed, status duration and stack cap (Combat); talisman power, keep chance, stock and drawing (Talismans); companion power share, beast slots, taming (Spirit Beasts); artifact slots (Item DB) | user | Each owner's GDD |
| 5 | Sizes to watch: a notable of health regeneration (2.66 pp) passes its 2 pp cap; a notable of crit chance is 8 pp; art speed and crit are cheap late (question 1) | systems-designer | Balance harness |
| 6 | Closed 2026-11-08: Chaos resistance is rare by its row (rule 13, Rare table) | — | Closed |
| 7 | Overnight content: filter the 192 special modifiers and 210 plain rows in `modifier-inventory.md` against this catalogue, keeping only what passes the four tests; the rest are Effects or dropped | user + game-designer | Effects System design |
| 8 | Mostly done (the formulas and grades are registered). Left: register the full price table in `stat_power_weights`, with `resist_pct` at its one stored price 1.25 | user | After re-review |
