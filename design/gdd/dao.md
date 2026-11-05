# The Way (Đạo)

> **Status**: Designed (2026-11-05, awaiting a fresh /design-review)
> **Author**: user + Claude
> **Last Updated**: 2026-11-06
> **Last Verified**: 2026-11-05
> **Implements Pillar**: Pillar 1 (Your Dao, Your Name), Pillar 3 (Power Is Built, Not Given), Pillar 4 (Every Season Counts); touches Pillar 5 (A World That Remembers)

## Summary

The Way (Đạo) is the system of Daos: Sword, Space, Time, Yin and Yang, and many more. A
character glimpses a Dao through an event, picks it from three offered, and builds its small
tree with the same skill points that buy Meridian Map acupoints, at a flat 3 points a node.
A node is worth about twice what those points buy on the map, so a Dao feels special. A
Dao defines a build with stat lines and passive abilities (arts wait on a combat system), and
NPCs from Core Formation hold Daos too. It exists because Pillar 1 wants distinct builds, and
a Dao is the strongest way to tell two lives apart.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha (provisional)` · Key deps: `Spiritual Roots (Linh Căn), Meridian Map (Kinh Mạch Đồ), Character Stats, Event Engine`; soft: `Cultivation Techniques, Realms & Bottlenecks, Combat (arts only)`

## Overview

The Way (Đạo) is the system of comprehended Daos (ngộ đạo): Sword, Space, Time, Yin and
Yang, and many more. A Dao is not rolled into the root. An event gives a character a glimpse
of one, and the character then builds it up by spending skill points on its tree: stat
lines, passive abilities and arts (active techniques) that define the build. A Dao is a
specialisation, not a bonus. Every node costs a flat 3 of the same points that buy acupoints
on the Meridian Map (Kinh Mạch Đồ), and is worth about twice what 3 acupoints give, so a point
spent on a Dao is the best point a life spends. The root and the cultivation technique (công pháp)
are prerequisites, never the source. One glimpse a realm caps a life at four Daos, and the
points cap how deep each one goes. From Core Formation (Kết Đan), an NPC may hold one Dao,
rolled abstractly like its breakthrough fate, so a Sword master or a Space god can exist in
the world.

The system exists because Pillar 1 asks for more distinct builds, and the Way is where the
strongest distinction lives: two lives with the same root and technique can diverge by Dao,
and two lives with the same Dao can diverge by branch. It serves Pillar 3, since a Dao is
built by choosing nodes, and Pillar 4, since the points come from levels and breakthroughs,
which cost seasons. The arts need a combat system that does not exist yet (Dependencies). It also gives the 22 mutations
moved out of the root (Spiritual Roots rule 16) a home, with new Daos added beside them.

## Detailed Design

### Core Rules

**What a Dao is**

1. **A Dao is a small tree.** Each Dao (data: `dao.json`) has an id, a name with its Hán-Việt
   form, a requirement (rule 5) and about 20 nodes: three branches of six or seven, and a
   keystone. A node has a kind and its effect. Adding a Dao is a data change,
   never a rule change.
2. **The catalogue** is the 22 mutations moved out of the root (Spiritual Roots rule 16: Lava,
   Gravity, Life, Poison, Mist, Sword, Heavenly Thunder, Destruction, Death, Pill Fire, Spirit
   Farming, Refined Metal, Array, Soul, Illusion, Stars, Space, Yin, Yang, Reincarnation, Taiji
   and Time) plus new Daos beside them (user decision 2026-11-05). The old effects of a seed
   (Pill Fire's `alchemy_success`, Time's herb ageing) become nodes in its tree, under rule 4.
3. **Three node kinds.**
   - **Stat line:** modifiers on the stat sheet, with the Dao as their source (Character Stats'
     provider interface), priced in W.
   - **Passive ability:** a hook into something the game already does, in the same record
     shape as a Meridian Map capability (id, tier, parameters, and a simplified `npc_effect`).
   - **Art:** an active technique used in combat. **On hold** (user decision 2026-11-05):
     combat is a power ratio today, and a real combat system is needed first. The data format
     supports art nodes, but no shipped tree holds one until that system exists, so a player
     never spends points on a node that does nothing.
4. **No ceiling raises and no root factors.** A Dao may not raise a Character Stats ceiling or
   multiply the whole cultivation rate, lifespan or breakthrough chance. Realms & Bottlenecks'
   gate odds are calibrated without them, and re-running that calibration is the price of
   adding one. Any breakthrough chance a node gives counts under the q-extras ceiling.
5. **Requirement.** A Dao names what it needs from the root and technique: elements at a
   minimum purity, a variant, or a technique kind. The old mutation's parents are the natural
   start (Lava: Fire and Earth). The requirement is checked at the glimpse (rule 6), not again.

**Gaining a Dao**

6. **A glimpse opens a Dao.** An event effect `dao_glimpse` presents an offer of up to three Daos
   the character qualifies for and has not glimpsed (Formulas D2). The player's pick is made
   inside the effect, before it resolves, and the effect opens exactly that one Dao (Event
   Engine, provisional contract). A glimpse
   gives only the tree to look at: no points and no stats. At most `dao_glimpses_per_realm`
   are given per realm, so a Dao stays an event in a life.
7. **Points buy nodes.** A node is bought with the same skill points that buy Meridian Map
   acupoints (Kinh Mạch points, paid by Realms & Bottlenecks' levels and breakthroughs). Every
   node costs a flat `dao_node_cost`, 3 points, whatever it gives (user decision 2026-11-06).
   There is no separate currency and no study time (user decision 2026-11-05). A character buys a node only in a Dao it has glimpsed.
8. **Order within a tree.** A node needs the one before it in its branch. The keystone needs
   one whole branch and at least one node in each other branch, so it takes at least 9 nodes,
   27 points (user decision 2026-11-06). A bought node is never refunded (as on the Meridian Map).
9. **Glimpses cap the count, points cap the depth.** One glimpse a realm from Foundation
   Establishment (rule 6) means at most four Daos in a life. How deep each goes is what the
   character's points allow, and each point spent here is not spent on an acupoint (user
   decision 2026-11-05). No other rule limits the count or the depth.
10. **A Dao node beats the acupoints it replaces.** The Meridian Map averages about 2.07 W per
    point, so 3 points buy about 6 W there. A Dao node averages about twice that, 12 W (user
    decision 2026-11-06, replacing the earlier neutral pricing), so a Dao feels special and is
    extra power by design. At about 4.1 W per point it also beats the map's best clusters
    (about 2.5–3.4 W per point). Formulas D1 sets the budget. The extra should stop at the gates:
    rule 4 still holds and the gate odds read no power stat, but a stat line that speeds
    cultivation or brewing could still shift them, so AC-DAO-10 tests it.

**NPCs**

11. **NPCs hold Daos from Core Formation** by an abstract roll, like their breakthrough fate
    (user decision 2026-11-05). An NPC holds **at most one Dao**: it keeps its first
    successful roll and later rolls are ignored (review decision 2026-11-05). The Dao points
    `P_npc` (Formulas D3) are deducted from the points the Meridian Map allocator gives the
    NPC, so an NPC's Dao is point-neutral: the player's premium (rule 10) does not apply to NPCs
    yet (Open Question 5). The Dao's effect is a power
    multiplier, not the tree, and it emits no per-season simulation.

**What the player cannot do:** buy a node in a Dao it has not glimpsed; refund a node; make a
node raise a ceiling or multiply a whole rate; hold an art before the combat system exists.

### States and Transitions

Each Dao is in one of four states for a character. Nothing is ever lost.

| State | Becomes | When | Guard |
|---|---|---|---|
| Unknown | Glimpsed | A `dao_glimpse` event effect resolves on this Dao | The requirement is met, the Dao is not already glimpsed, and this realm's glimpses are under `dao_glimpses_per_realm` |
| Glimpsed | Glimpsed (node bought) | The player buys a node | The node before it in its branch is bought, and the character has `dao_node_cost` unspent points |
| Glimpsed | Keystoned | The keystone is bought while other nodes remain | One whole branch and one node in each other branch are bought |
| Glimpsed or Keystoned | Mastered | The last remaining node is bought | Every node of the tree is bought (a full tree costs about `dao_full_points`) |
| Mastered | — | Terminal | A Dao is never lost and never refunded |

Keystoned and Mastered are derived from the nodes bought, not stored. The keystone can be the
last node bought (rule 8 does not ask for every node), and then the Dao goes from
Glimpsed straight to Mastered. **The World Database event is written when the keystone is
bought, whatever else is bought**, so that purchase writes exactly one event whether it leaves
nodes or completes the tree (AC-DAO-14). Reaching Mastered by any other node writes none.

"Fully built" in this GDD means Mastered. Keystoned is reachable far earlier: the shortest route to
the keystone is 9 nodes, 27 of a tree's 60 points. An NPC goes Unknown → Glimpsed by
its roll (rule 11) and has no per-node state.

### Interactions with Other Systems

Only Spiritual Roots (`linh-can.md`), Character Stats, Cultivation Techniques, Realms &
Bottlenecks and the Meridian Map have GDDs. Every other interface is provisional.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Meridian Map (Kinh Mạch Đồ) | in / out | in: the character's points (its Formulas A) and its W-per-point target. Out: the points spent on Dao nodes, which are not available for acupoints. One shared pool | Meridian Map (the points); this GDD (Dao costs) |
| Spiritual Roots (Linh Căn) | in | the root as a read-only requirement: elements, purities, variants | Spiritual Roots |
| Cultivation Techniques (Công Pháp) | in | a technique's kind and tier, as a requirement | Cultivation Techniques |
| Character Stats | out | the Dao's stat lines as modifiers, with the Dao and node as their source; passive abilities through the capability-style record | Character Stats (provider interface); this GDD (the lines) |
| Realms & Bottlenecks | in | the realm, for the glimpse limit; the gate calibration this GDD must not break (rule 4) | Realms & Bottlenecks |
| Event Engine | in | the `dao_glimpse` effect, which grants access to a Dao | Event Engine (provisional; no GDD) |
| Combat | out | passive hooks that touch power, and arts (**on hold**: needs a full combat system) | Combat (not designed) |
| NPC Builds, Living World Tick | out / in | an NPC's Dao roll at Core Formation, and its simplified `npc_effect` | NPC Builds |
| World Database | out | a glimpse and a Keystoned Dao are recorded as events (Pillar 5) | World Database |
| Save/Load | out | per character: the Daos glimpsed and the nodes bought | Save/Load |
| Guidance Layer, Debug Terminal, Game UI | out | the Dao list, each tree with costs and what is unaffordable, and the glimpse notice | Guidance Layer |

## Formulas

Values marked *guess* need a bot run and a content pass before they are trusted. Stat lines
are priced with the Meridian Map's weights (its Formulas F1, in W: 1 W is the value of +1 %
attack).

### D1. A Dao's cost and value

The dao_node_value formula is defined as:

`cost(n) = c` ; `V̄ = m · c · w̄` ; `C_dao = c · N`

and a data lint on every Dao: `18 ≤ N ≤ 22` and `0.9 · V̄ ≤ Σ W(n) ÷ N ≤ 1.1 · V̄`. The cost is
flat, so strong and weak nodes cost the same, and the lint holds the average.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | int | 3 | data file (`dao_node_cost`) | Points per node, flat (user decision 2026-11-06) |
| m | float | 2 | data file (`dao_premium`) | How much a Dao node beats the acupoints it replaces (user decision 2026-11-06) |
| w̄ | float | 2.07 | Meridian Map Formulas A2 (`w̄_target`) | Mean W per point on the map |
| N | int | 18–22 | data file (`dao_node_count` 20) | Nodes in a Dao, keystone included (user decision 2026-11-06) |
| W(n) | float | 3–34 | calculated | A node's value: its stat lines by F1, or the credit of its ability tier |
| credit(T) | float | T1 10, T2 18, T3 30 | data file (`dao_ability_credit`), *guess* | W credited to a passive ability or art by tier; the capability tiers (T1 narrow, T2 build-shaping, T3 survival or breakthrough) |
| V̄ | float | 12.42 | calculated | Target mean W per node |
| C_dao | int | 54–66 | calculated (`dao_full_points` 60) | Points a fully built (Mastered) Dao costs |

**Output Range:** a node averages 11.2–13.7 W. A Mastered Dao costs about 60 points and is worth
about 250 W, about 124 W more than the same points buy on the map. A life that masters all four
Daos it can glimpse spends 240 of its 566 points and gains about 500 W over the map, on top of
the map's 1,100–1,300 W at the end of the ladder, so about +40 %.

**Example:** a Dao of 20 nodes: 10 stat lines at 8 W, 5 T1 passives (10 W each), 4 T2 passives (18
W each), and a keystone with a T3 ability and a 4 W line (34 W). The total is 80 + 50 + 72 + 34 =
236 W, a mean of 11.8 W per node, inside 11.2–13.7. It costs 20 × 3 = 60 points, and the shortest
route to the keystone is 9 nodes, 27 points.

### D2. The glimpse offer

The dao_offer formula is defined as:

`E = {d : requirement(d) met, d not yet glimpsed}` ; `offer = the first min(3, |E|) entries of a uniform shuffle of E`

A character is given `dao_glimpses_per_realm` glimpses in each realm from `dao_glimpse_realm_min`
(Foundation Establishment); the glimpse happens when an event resolves it (the Event Engine
owns the rate). The shuffle is a Fisher–Yates over E in catalogue order, one uniform draw per
swap, so the offer is reproducible from the seed. Exactly: with k = min(3, |E|), for i = 0 … k−1
take j = i + randint(|E| − i) and swap entries i and j; the offer is entries 0 … k−1. That is k
draws (two for |E| = 2, even though the last has one outcome), from the seeded stream named
`dao_offer`, so no other stream shifts.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `dao_glimpses_per_realm` | int | 1 | data file | Glimpses a realm allows (user decision 2026-11-05) |
| `dao_glimpse_realm_min` | int | 1 | data file | First realm that allows one: Foundation Establishment (user decision 2026-11-05) |
| `dao_offer_size` | int | 3 | data file | Daos shown per glimpse; the player picks one (user decision 2026-11-05) |
| `dao_open_min` | int | 6 | data file lint | Daos with no root or technique requirement, so E always holds at least 3 after up to 3 earlier glimpses |
| \|E\| | int | 6+ | calculated | Daos on offer |

**Output Range:** an offer of 3 whenever the catalogue holds six open Daos. A life gets up to four
glimpses (Foundation Establishment to Deity Transformation).

**Example:** a character qualifies for 9 Daos and has already glimpsed 2 of them, so |E| = 7.
Three draws pick the offer from those 7. The player takes one, and the other two return to E.

### D3. An NPC's Dao

The npc_dao formula is defined as:

`P_npc = min(C_dao, ⌊npc_dao_share · points_total(level)⌋)` ; `map_points = points_total − P_npc` ;
`power_mult = points_total ÷ map_points`

An NPC rolls once per realm entered from Core Formation, with chance `npc_dao_chance`, until
its first success (rule 11: at most one Dao). On success it takes one Dao uniformly from those
it qualifies for. The Meridian Map allocator gets `map_points`, and `power_mult` multiplies the
resulting combat power, as a capability's `npc_effect` does. `power_mult` is the point-neutral
value: it restores the W the deducted points would have bought on the map, so an NPC with a Dao
is as strong as one without, with a different shape. Review decision 2026-11-05; assumes map
power is close to linear in points, which a bot run must confirm (Open Question 5).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `npc_dao_chance` | float | 0.5 | data file, *guess* | Chance of a Dao per realm from Core Formation, until the first success |
| `npc_dao_share` | float | 0.25 | data file, *guess* | Share of an NPC's points it has put into its Dao |
| points_total(level) | int | 161–566 | Meridian Map Formulas A | The NPC's points: an NPC's level is the first level of its stage |
| P_npc | int | 40–60 | calculated | Points put into the Dao, deducted from the map |
| map_points | int | 121–506 | calculated | Points the Meridian Map allocator gets |

**Output Range:** `power_mult` 1.00 (no Dao) to about 1.33. Below the cap it is a plateau
of 1.331–1.333 (161 points: 1.331; 164, 216 and 240 points: 1.333), and it falls once the
60-point cap binds above 240 points (566 points: 1.119).
The ratio `P_npc ÷ points_total` never exceeds `npc_dao_share`, so `power_mult` never exceeds
1 ÷ (1 − 0.25) = 1.333. `npc_dao_power_max` is retired.

**Example:** a Core Formation NPC at level 41 has 161 points, so P_npc = min(60, ⌊40.25⌋) = 40,
map_points = 121 and power_mult = 161 ÷ 121 = **1.331**. A Nascent Soul NPC at level 87 has 304
points, so ⌊76.0⌋ caps at 60, map_points = 244 and power_mult = 304 ÷ 244 = **1.246**.

## Edge Cases

**Glimpses**

- **If fewer than three Daos qualify:** the offer shows what exists. The catalogue lint keeps
  six Daos open, so an empty offer cannot happen in shipped data. If E were empty, the glimpse
  is skipped and the realm's allowance is kept.
- **If a glimpse event arrives after the realm's allowance is used:** the Event Engine's
  validator refuses the effect, and the event plays without it.
- **If the character skips a realm's glimpse:** the allowance is lost with the realm. It does not
  carry forward.
- **If the player declines all three offered Daos:** nothing is granted and the allowance is used.
  Self-made lives glimpse like any other life, and no life has a Dao at birth.

**Buying**

- **If a node costs more than the character's unspent points:** the buy is refused and the
  shortfall is shown. A glimpsed Dao is always visible, with every cost.
- **If a node's stat line would sit above a Character Stats ceiling:** it is clamped, and the
  sheet shows the clamp line, as for every other source. Before the buy, the Advisor warns that
  the line will not count, as it does for a lifespan pill.
- **If a Dao passive does the same thing as a Meridian Map capability:** both apply and stack. A
  Dao passive has its own id range, and the data lint prices each by tier.
- **If the character has points but no glimpsed Dao:** the points go to the Meridian Map as
  before. The Way never forces a spend.
- **There is no respec.** A bought node stays, and a point spent here is never returned to the map.

**Requirements and changes**

- **If the root or technique changes after a glimpse:** the Dao stays. The requirement was
  checked once, at the glimpse (rule 5). A root never loses anything (Spiritual Roots rule 14).
- **If a Dao's data changes between versions:** a node bought under the old data keeps its points,
  and a save refers to nodes by id. A removed node is refunded as unspent points, the one case a
  refund happens. A node that needed the removed one keeps its purchase: the prerequisite is
  checked only at buy time, so nothing already bought is lost or locked.

**Arts**

- **If an art node is authored before the combat system exists:** the data lint rejects it in the
  shipped catalogue (rule 3). Test data may carry one.

**NPCs**

- **If an NPC is generated at Core Formation or higher:** it rolls once for its current realm, not
  for earlier ones.
- **If an NPC dies:** its Dao stays in its record. The World Database keeps it as history.
- **If a world is small:** a 3,000-cultivator world has about 1.7 Deity Transformation NPCs, so a
  Dao held only by Deity Transformation NPCs may not exist in that world. That is allowed.

## Dependencies

Spiritual Roots (`linh-can.md`), Character Stats, Cultivation Techniques, Realms &
Bottlenecks and the Meridian Map have GDDs. Every other interface is provisional. When each
remaining GDD is written, it must list the Way in its own Dependencies section.

**Upstream: this system cannot work without them (hard)**

| # | System | What the Way needs from it |
|---|---|---|
| 1 | Data-Driven Config | `dao.json`: the catalogue, trees, requirements and the keys in Formulas |
| 2 | Deterministic Simulation Core | The seeded shuffle for the offer, the NPC roll, and Breakdown for every cost and line |
| 6 | Spiritual Roots (Linh Căn) | The root as a read-only requirement: elements, purities and variants |
| 7 | Character Stats | The stat sheet that takes a Dao's lines as modifiers, with their source |
| 10 | Meridian Map (Kinh Mạch Đồ) | The points a character has (its Formulas A) and the W-per-point target node values are set against |
| 23 | Event Engine | The `dao_glimpse` effect: without it no character can gain a Dao |

**Upstream: needed for a part of the system (soft)**

| # | System | What it supplies | Without it |
|---|---|---|---|
| 9 | Cultivation Techniques | A technique's kind and tier, as a requirement | A Dao can only require roots |
| 8 | Realms & Bottlenecks | The realm, for the glimpse allowance; the gate odds Daos must not break | No glimpse allowance by realm |
| 21 | Combat | The system an art would act in | No art nodes ship |
| 24 / 28 | NPC Build Generation, Living World Tick | The NPC roll at Core Formation | Only the player holds Daos |
| Progression Edges (design order #21) | A birth or sect edge that grants an early glimpse (Open Question 6) | The glimpse allowance stays at `dao_glimpses_per_realm` |

**Downstream: systems that depend on the Way**

| # | System | What it takes |
|---|---|---|
| 10 | Meridian Map | The points spent on Dao nodes, which its unspent figure subtracts |
| 6 | Spiritual Roots | Open Question 9 is answered here: the relocated mutations are Daos |
| 9 | Cultivation Techniques | Open Question 11 closes: no shipped template names a relocated id |
| 23 | Event Engine | A new effect, `dao_glimpse`, with a per-realm limit |
| 21 | Combat | Passive hooks that touch power, and later the arts |
| 35 / 36 / 37 | Guidance Layer, Debug Terminal, Game UI | The Dao list, trees with costs and the glimpse offer |
| 5 | Save/Load | The Daos glimpsed and the nodes bought |

**Cycle and how it is broken:** the Way and the Meridian Map share one pool of points. The
Meridian Map owns the total (its Formulas A); the Way keeps its own count of points spent, and
the map's unspent figure is the total minus both counts. Neither system calls the other each turn.

## Tuning Knobs

All live in `dao.json` (Formulas D1–D3). Safe ranges are guesses until the bot run (Open
Question 4, 5).

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `dao_node_cost` | 3 | 3–5 | Points per node, flat. Moves a Dao's total cost with it |
| `dao_premium` | 2 | 1.5–3 | How much a node beats the acupoints it replaces. 3 lets Daos outshine the map |
| `dao_node_count`, `dao_full_points` | 20, 60 | 18–22, 54–66 | How much of a life's points a Dao takes (4 Daos = 240 of 566), and the authoring load |
| `dao_ability_credit` | 10 / 18 / 30 W | ±30 % | What a passive counts for in the node-value lint |
| `dao_glimpses_per_realm` | 1 | 1–2 | Daos per life (4 at 1) |
| `dao_glimpse_realm_min` | 1 (Foundation Establishment) | 1–2 | When the first Dao can come |
| `dao_offer_size` | 3 | 2–4 | Choice at a glimpse; needs `dao_open_min` ≥ offer size + 3 |
| `dao_open_min` | 6 | 6–10 | How many Daos anyone can be offered |
| `npc_dao_chance` | 0.5 | 0.2–0.8 | How common Dao-holding NPCs are |
| `npc_dao_share` | 0.25 | 0.1–0.30 | NPC points in the Dao; `power_mult` caps at 1 ÷ (1 − share), so 0.30 gives 1.43 |

## Visual/Audio Requirements

Deferred. Each Dao will want an identity (colour, sigil and sound) when the Game UI and Audio
are designed.

## Game Feel

Not specified at this tier. Intent for later work:
- **A glimpse** is a moment: three Daos offered, one chosen, and a tree to look at.
- **A node** feels like a real purchase: 3 points, and clearly better than 3 acupoints.
- **A keystone** is the payoff that names the build.

## UI Requirements

Specified for the Debug Terminal now and the Game UI later.
- **The Dao list** shows each Dao as unknown (not shown), glimpsed, keystoned or mastered.
- **A tree** shows every node with its kind (stat, passive) and what it gives, the flat cost,
  and the shortfall when the character cannot afford one.
- **The offer** lists three Daos with their requirements and a one-line description.
- **The Advisor** warns before a buy when a stat line would sit above a ceiling.
- **The shared pool:** the unspent count is the same figure the Meridian Map shows.

## Cross-References

| Document | What it must say or do |
|---|---|
| `design/gdd/linh-can.md` | Open Question 9 is answered by this GDD, and rule 16 points here |
| `design/gdd/cong-phap.md` | Open Question 11 closes: no shipped template names a relocated mutation |
| `design/gdd/kinh-mach-do.md` | List the Way in Dependencies: its unspent points subtract the Way's spent count |
| `design/gdd/character-stats.md` | A Dao is a new modifier source on the stat sheet |
| `design/gdd/canh-gioi.md` | The gate calibration holds because Daos add no ceiling raise (rule 4) |
| `design/gdd/systems-index.md` | Row 39 and the design order |
| `design/registry/entities.yaml` | The keys and formulas above |

## Acceptance Criteria

Evidence: Logic and Integration tests under `tests/unit/dao/`, Config/Data checks of `dao.json`,
and UI transcripts under `production/qa/evidence/debug-terminal/`.

**Costs and data**

- **AC-DAO-01** [Config/Data] Every Dao in `dao.json` has 18–22 nodes and a mean node value of
  11.2–13.7 W, no shipped node is an art, at least six Daos have no root or technique
  requirement, and no node carries a ceiling raise or a root factor.
- **AC-DAO-02** [Logic] Formulas D1: every node costs 3 points, whether a 4 W line or a 34 W
  keystone, and V̄ is 12.42 W.
- **AC-DAO-03** [Logic] The Formulas D1 example Dao totals 60 points and 236 W, a mean of 11.8 W
  per node, and passes the lint.

**Glimpses**

- **AC-DAO-04** [Logic] With |E| = 7 the offer holds three distinct Daos and draws one value per
  entry offered. With |E| = 2 it holds two. The same seed gives the same offer.
- **AC-DAO-05** [Logic] A Qi Refining character is given no glimpse. From Foundation
  Establishment, each realm allows one; a second `dao_glimpse` in the same realm is refused, and
  an unused allowance does not carry into the next realm.
- **AC-DAO-06** [Logic] A Dao whose requirement the root does not meet is never offered. A
  glimpsed Dao stays after a technique change.

**Buying**

- **AC-DAO-07** [Logic] A node in an unglimpsed Dao is refused. A node needs the one before it in
  its branch. The keystone is refused until one whole branch and one node in each other branch
  are bought. A buy below cost is refused and
  names the shortfall. No node is ever refunded.
- **AC-DAO-08** [Integration] A character with 120 points who masters a 60-point Dao has 60
  left, and the Meridian Map allocation sees 60. The map refuses a 61st acupoint.
- **AC-DAO-09** [Logic] A stat line above a Character Stats ceiling is clamped and the sheet
  shows the clamp line.
- **AC-DAO-10** [Bot] `autoplay.gd --edge on --perk dao_cot --dao <id>` (the Đạo Cốt perk is
  AC-CG-31's fixture, not a Dao). The `--dao` flag is a test hook: it grants the glimpse of
  `<id>` on entering Foundation Establishment, bypassing the Event Engine, and buys that tree in
  branch order until Mastered. For each of three stat-line-only test Daos, the Realms gate runs
  stay inside AC-CG-31's windows, so no Dao has moved the gate calibration.

**NPCs**

- **AC-DAO-11** [Logic] Formulas D3: a Core Formation NPC at level 41 has P_npc 40, map_points
  121 and power_mult 1.331 (±0.001). A Nascent Soul NPC at level 87 has P_npc 60, map_points
  244 and power_mult 1.246 (±0.001). An NPC with no Dao has power_mult 1.000.
- **AC-DAO-12** [Logic] Over 16,000 NPC rolls at `npc_dao_chance` 0.5, 50 % ± 1.6 pp succeed. An
  NPC generated at Core Formation rolls once, for its current realm only. An NPC that has a Dao
  makes no further roll in later realms and still holds exactly that one Dao.

**Persistence and the world**

- **AC-DAO-13** [Integration] A save round trip keeps every Dao glimpsed and node bought. A node
  removed from the data comes back as unspent points.
- **AC-DAO-14** [Integration] A glimpse and the keystone purchase each write one World Database
  event. Buying the keystone as the last node (Glimpsed straight to Mastered) writes exactly one
  event. Buying the last non-keystone node of a Keystoned Dao writes none.

**Added by the 2026-11-05 review**

- **AC-DAO-16** [Integration] An NPC with a Dao (Formulas D3): the Meridian Map allocator is
  called with `map_points`, not `points_total`, and the resulting combat power is multiplied by
  `power_mult`. An NPC with no Dao is called with `points_total` and a multiplier of 1.000.
- **AC-DAO-17** [Logic] With E empty the glimpse is skipped and the realm's allowance is kept; a
  declined offer uses the allowance and leaves all three Daos in E.
- **AC-DAO-18** [Integration] A Dao passive and a Meridian Map capability that give the same
  breakthrough chance both apply, and the summed extras stay under the 10 pp q-extras ceiling and
  the tree's 8 pp cap.
- **AC-DAO-19** [Logic] A node removed by a data change is refunded, and a node that needed it
  stays bought.

**UI**

- **AC-DAO-15** [UI] A transcript shows the Dao list, a tree with costs and the unaffordable ones
  marked, the three-Dao offer, and the Advisor's ceiling warning before a buy.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | The `dao_glimpse` contract: which events grant it, how often (the rate), and what the validator checks | Event Engine | Any Dao in play |
| 2 | The catalogue: a tree of about 20 nodes for each of the 22 seeds and the new Daos, so 440+ nodes. Which new Daos, and what each requirement is | game-designer, user | Content pass |
| 3 | The combat system. Arts are on hold until it exists, and the ability credit for an art tier needs its own pricing then | Combat (not designed), user | Art nodes |
| 4 | `dao_ability_credit` (10 / 18 / 30 W) is a guess. `dao_premium` 2 makes a fully built life about 40 % stronger in tree power than the map alone: check that against combat and NPC power once trees exist | systems-designer | A content pass and a bot run |
| 5 | Should NPC Daos get the player's premium (rule 10)? They are point-neutral for now, so a player's Dao is worth more than an NPC's. `npc_dao_chance` and `npc_dao_share` are guesses, and so is the assumption behind `power_mult = points_total ÷ map_points` (map power close to linear in points). A bot run must confirm that an NPC with a Dao is as strong as one without, and check the combined NPC uplift with cluster holders (Meridian Map AC-KMD-49) | NPC Builds, bot run | AC-DAO-11, 12 |
| 6 | May a perk or a sect grant an early glimpse (a birth edge)? It would touch Progression Edges | game-designer | The edge |
| 7 | Do Dao trees sit on the Meridian Map screen or on their own? | ux-designer | The UI |
| 8 | The Way is Alpha (provisional) in the index. Should the first release ship Daos before Combat exists, with stat lines and passives only? | user | Scope |
