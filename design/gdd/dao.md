# The Way (Đạo)

> **Status**: Approved (design-review 2026-11-06, fifth pass, lean: no blockers)
> **Author**: user + Claude
> **Last Updated**: 2026-11-06
> **Last Verified**: 2026-11-06
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
specialisation the character pays for, and its premium is deliberate. Every node costs a flat 3 of the same points that buy acupoints
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
   form, a requirement (rule 5), its theme stats (rule 12) and 19–22 nodes (default 20): three
   branches of six or seven, and a keystone. A node has a kind and its effect. Adding a Dao is a data change,
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
   multiply the whole cultivation rate, lifespan or breakthrough chance. A stat line is an
   additive modifier and is not a multiplier, but cultivation speed has no ceiling, so one Dao's
   `cultivation_speed_pct` lines are held to `dao_rate_cap_pct` (10 %) by the lint (Formulas D1
   part 4; user decision 2026-11-06). Realms & Bottlenecks'
   gate odds are calibrated without them, and re-running that calibration is the price of
   adding one. Any breakthrough chance a node gives counts under the q-extras ceiling
   (`q_extras_ceiling_pp`, 10 pp) and nowhere else: it is a separate q-extras source, not the
   Meridian Map tree's contribution, so the tree's 8 pp cap (`tree_breakthrough_cap`) neither
   limits it nor is raised by it (user decision 2026-11-06). Realms & Bottlenecks lists the Way
   among the q extras.
5. **Requirement.** A Dao names what it needs from the root and technique: elements at a
   minimum purity, a variant, or a technique kind. The old mutation's parents are the natural
   start (Lava: Fire and Earth). The requirement is checked at the glimpse (rule 6), not again.

**Gaining a Dao**

6. **A glimpse opens a Dao.** An event effect `dao_glimpse` presents an offer of up to `dao_offer_size` (3) Daos
   the character qualifies for and has not glimpsed (Formulas D2). The player's pick is made
   inside the effect, before it resolves, and the effect opens exactly that one Dao (Event
   Engine, provisional contract). A glimpse
   gives only the tree to look at: no points and no stats. At most `dao_glimpses_per_realm`
   are given per realm, so a Dao stays an event in a life. Points already spent on acupoints are
   gone, so the Guidance Layer's Advisor tells the player, from the first realm that allows a
   glimpse, that this realm's glimpse is still unused and that Dao nodes need unspent points (UI
   Requirements; user decision 2026-11-06). The Way reserves nothing.
7. **Points buy nodes.** A node is bought with the same skill points that buy Meridian Map
   acupoints (Kinh Mạch points, paid by Realms & Bottlenecks' levels and breakthroughs). Every
   node costs a flat `dao_node_cost`, 3 points, whatever it gives (user decision 2026-11-06).
   There is no separate currency and no study time (user decision 2026-11-05). A character buys a node only in a Dao it has glimpsed.
8. **Order within a tree.** A node needs the one before it in its branch. The keystone needs
   one whole branch and at least one node in each other branch, so it takes at least 9 nodes,
   27 points (user decision 2026-11-06). A bought node is never refunded (as on the Meridian Map).
9. **Glimpses cap the count, points cap the depth.** One glimpse a realm from Foundation
   Establishment (rule 6) means at most one new Dao per realm: four in a life on the current ladder, Foundation
   Establishment to Deity Transformation. How deep each goes is what the
   character's points allow, and each point spent here is not spent on an acupoint (user
   decision 2026-11-05). No other rule limits the count or the depth.
10. **A Dao node beats the acupoints it replaces.** The Meridian Map averages about 2.07 W per
    point, so 3 points buy about 6 W there. A Dao node averages about twice that, 12 W (user
    decision 2026-11-06, replacing the earlier neutral pricing), so a Dao feels special and is
    extra power by design. At about 4.1 W per point it also beats the map's best clusters
    (about 2.5–3.4 W per point). Formulas D1 sets the budget, and lints each branch and the
    route to the keystone as well as the whole tree, so the premium holds for the nodes a
    player actually buys and not only for the full tree. The extra should stop at the gates:
    rule 4 still holds and the gate odds read no power stat, but a stat line that speeds
    cultivation or brewing could still shift them, so AC-DAO-10 tests it.

**NPCs**

11. **NPCs hold Daos from Core Formation** by an abstract roll, like their breakthrough fate
    (user decision 2026-11-05). An NPC holds **at most one Dao**: it keeps its first
    successful roll and later rolls are ignored (review decision 2026-11-05). The Dao points
    `P_npc` (Formulas D3) are deducted from the points the Meridian Map allocator gives the
    NPC, and those points are worth `dao_premium` times what they buy on the map, the same
    premium the player gets (rule 10; user decision 2026-11-06). The Dao's effect is a power
    multiplier, not the tree, and it emits no per-season simulation. The Dao's id is stored in
    the NPC's record and written to the World Database as a fact when it is rolled, so the
    world can name a Sword master (Pillar 5; AC-DAO-25).

**Theme**

12. **A tree belongs to its Dao.** Every node comes from its Dao's theme (user decision
    2026-11-06): with the name hidden, a player can tell the Dao from its nodes. Sword's tree is
    blades and cutting, Pill Fire's is the furnace, Time's is years and ageing.
    - **Stat lines** use only the Dao's `theme_stats`, a list in its data. There is no filler:
      a line any Dao could hold belongs on the Meridian Map instead.
    - **Passives** belong to one Dao. No passive id appears in two trees.
    - **Each branch** is a named facet of the theme, and the **keystone** is the Dao's
      signature, the effect the build is named for.
    - **Theme comes before combat value.** A craft Dao such as Spirit Farming needs no attack
      line. It still meets the node-value lint (Formulas D1), through its own stats and passives.
      Its ceilinged craft keys (`alchemy_success`, `herb_growth_pct`) carry only their headroom
      (D1 part 4), so most of a craft Dao's value is passives.

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
| Mastered | — | Terminal | A Dao is never lost and never refunded. The one exception is a data change that adds nodes: states are derived, so the Dao reads as Keystoned until the new nodes are bought (Edge Cases) |

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
| World Database | out | a glimpse and a Keystoned Dao are recorded as events; an NPC's Dao is recorded as a fact on its record (Pillar 5) | World Database |
| Save/Load | out | per character: the Daos glimpsed and the nodes bought; per NPC: its Dao id | Save/Load |
| Guidance Layer, Debug Terminal, Game UI | out | the Dao list, each tree with costs and what is unaffordable, the glimpse notice, and the unused-glimpse heads-up | Guidance Layer |

## Formulas

Values marked *guess* need a bot run and a content pass before they are trusted. Stat lines
are priced with the Meridian Map's weights (its Formulas F1, in W: 1 W is the value of +1 %
attack).

### D1. A Dao's cost and value

The dao_node_value formula is defined as:

`cost(n) = c` ; `V̄ = m · c · w̄` ; `C_dao = c · N`

and a data lint on every Dao, four parts:
1. `19 ≤ N ≤ 22` and `0.9 · V̄ ≤ Σ W(n) ÷ N ≤ 1.1 · V̄` (the whole tree);
2. `(1 − t) · V̄ ≤ mean W of each branch ≤ (1 + t) · V̄`, with `t` = `dao_branch_tol` 0.2 (each
   branch, so no facet is a trap and none is a jackpot);
3. for each of the three branches b, the keystone route R(b) (all of branch b, the first node
   of each other branch, and the keystone) averages at least `dao_route_floor` · V̄, 0.9 (the
   cheapest way to the signature is not a bad deal);
4. **key headroom.** For each stat key k, the W a Dao's stat lines put on k is at most the key's
   headroom H(k), so a node is never priced for a line the stat sheet will clamp (added by
   design-review 2026-11-06, third pass; user decision on the rate cap):
   - a key under a Character Stats rule 14 ceiling: H = ceiling × the key's F1 weight.
     `alchemy_success` is 3 pp × 2.7 = 8.1 W, `herb_growth_pct` is 10 × 0.9 = 9 W, and
     `lifespan_years` likewise;
   - `cultivation_speed_pct`, which has no ceiling: H = `dao_rate_cap_pct` × 2.2 = 22 W, so one
     Dao gives at most +10 % cultivation speed (rule 4);
   - every other key: no headroom limit.
   A craft Dao therefore cannot be built from ceilinged keys alone. Its value above the
   headroom must come from passives and uncapped keys. Time's herb ageing routes through
   `herb_growth_pct` (its old root factor is deprecated), so it counts under the same headroom.

The cost is flat, so strong and weak nodes cost the same, and the lint holds the average at
three scales and the stat-line mix at the ceilings. The ceilings are character-wide, so
several Daos on one key still share them; the Advisor's clamp warning (Edge Cases) covers that.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| c | int | 3 | data file (`dao_node_cost`) | Points per node, flat (user decision 2026-11-06) |
| m | float | 2 | data file (`dao_premium`) | How much a Dao node beats the acupoints it replaces (user decision 2026-11-06) |
| `dao_rate_cap_pct` | float | 10 | data file, *guess* | Most `cultivation_speed_pct` one Dao may give, in percent (user decision 2026-11-06); about the size of the whole map's 10.6 % |
| w̄ | float | 2.07 | Meridian Map Formulas A2 (`w̄_target`) | Mean W per point on the map |
| N | int | 19–22 | data file (`dao_node_count` 20) | Nodes in a Dao, keystone included: three branches of 6 or 7, plus the keystone (user decision 2026-11-06, 19–22 on review) |
| t | float | 0.2 | data file (`dao_branch_tol`), *guess* | How far a branch's mean W may sit from V̄ (review decision 2026-11-06) |
| `dao_route_floor` | float | 0.9 | data file, *guess* | Least mean W, as a share of V̄, on any keystone route R(b) |
| W(n) | float | 3–34 at the defaults | calculated | A node's value: its stat lines by F1, or the credit of its ability tier |
| credit(T) | float | T1 10, T2 18, T3 30 | data file (`dao_ability_credit`), *guess* | W credited to a passive ability or art by tier; the capability tiers (T1 narrow, T2 build-shaping, T3 survival or breakthrough). Set for the defaults (cost 3, premium 2). V̄ moves with both knobs, so the lint uses credit(T) × `dao_premium` × `dao_node_cost` ÷ 6, or it cannot be met. A credit is the value a tier must deliver, so a passive's parameters are retuned with it |
| V̄ | float | 12.42 | calculated | Target mean W per node |
| C_dao | int | 57–66 | calculated (`dao_full_points` 60) | Points a fully built (Mastered) Dao costs: N × c |

**Output Range:** at the defaults (c 3, m 2), a node averages 11.2–13.7 W, a branch 9.9–14.9 W, and a keystone route at least
11.2 W; the bands are 0.9, 1.1, 0.8, 1.2 and 0.9 times V̄ = m · c · w̄, so they move with the knobs. A Mastered Dao costs about 60 points and is worth about 250 W, about 124 W more than the
same points buy on the map. The uplift over the map is a fixed number of W, so as a share of a
life it is largest early. With the points saved for it (the figures use w̄ 2.07 W per map point
and 4.14 W per Dao point):
- one Mastered Dao at Core Formation entry (161 points): 101 × 2.07 + 60 × 4.14 = 457 W against
  333 W map-only, about +37 %;
- two Mastered Daos at Core Formation great perfection (216 points): 96 × 2.07 + 120 × 4.14 =
  696 W against 447 W, about +56 %;
- four Mastered Daos by Deity Transformation (240 of 566 points): about +500 W on the map's
  1,100–1,300 W, about +40 %.

An NPC with one Dao gains +25 % to +11 % (D3). Open Question 4 checks the player figures
against combat and NPC power.

**Example:** a Dao of 20 nodes, V̄ = 12.42. Branch A (6 nodes): 3 stat lines at 8 W, 2 T1
passives (10 W) and 1 T2 passive (18 W), 62 W, mean 10.3. Branch B (6): 3 stat lines, 1 T1, 2 T2,
70 W, mean 11.7. Branch C (7): 4 stat lines, 2 T1, 1 T2, 70 W, mean 10.0. The keystone is a T3
ability and a 4 W line (34 W). The total is 62 + 70 + 70 + 34 = 236 W, a mean of 11.8 W per node,
inside 11.2–13.7. All three branch means are inside 9.9–14.9. Each branch opens with an 8 W
stat line, so R(A) = 62 + 8 + 8 + 34 = 112 W over 9 nodes (12.4), R(B) = 120 W over 9 (13.3) and
R(C) = 120 W over 10 (12.0), all at least 11.2. It costs 20 × 3 = 60 points, and the shortest
route to the keystone is 9 nodes, 27 points.

### D2. The glimpse offer

The dao_offer formula is defined as:

`E = {d : requirement(d) met, d not yet glimpsed}` ; `offer = the first min(dao_offer_size, |E|) entries of a uniform shuffle of E`

A character is given `dao_glimpses_per_realm` glimpses in each realm from `dao_glimpse_realm_min`
(Foundation Establishment); the glimpse happens when an event resolves it (the Event Engine
owns the rate). The shuffle is a Fisher–Yates over E in catalogue order, one uniform draw per
swap, so the offer is reproducible from the seed. Exactly: with k = min(`dao_offer_size`, |E|), for i = 0 … k−1
take j = i + randint(|E| − i) and swap entries i and j; the offer is entries 0 … k−1. That is k
draws (two for |E| = 2, even though the last has one outcome), from the seeded stream named
`dao_offer`, so no other stream shifts.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `dao_glimpses_per_realm` | int | 1 | data file | Glimpses a realm allows (user decision 2026-11-05) |
| `dao_glimpse_realm_min` | int | 1 | data file | First realm that allows one: Foundation Establishment (user decision 2026-11-05) |
| `dao_offer_size` | int | 3 | data file | Daos shown per glimpse; the player picks one (user decision 2026-11-05) |
| `dao_open_min` | int | 6 | data file lint | Daos with no root or technique requirement. Invariant, linted on the data: `dao_open_min ≥ dao_offer_size + 4·dao_glimpses_per_realm − 1`, so E always holds a full offer after every earlier glimpse (4 realms allow a glimpse). At the defaults 3 + 4 − 1 = 6 |
| \|E\| | int | 6+ | calculated | Daos on offer |

**Output Range:** an offer of 3 whenever the catalogue holds six open Daos. A life gets up to four
glimpses (Foundation Establishment to Deity Transformation).

**Example:** a character qualifies for 9 Daos and has already glimpsed 2 of them, so |E| = 7.
Three draws pick the offer from those 7. The player takes one, and the other two return to E.

### D3. An NPC's Dao

The npc_dao formula is defined as:

`P_npc = min(C_dao, ⌊npc_dao_share · points_total(level)⌋)` ; `map_points = points_total − P_npc` ;
`power_mult = (map_points + dao_premium · P_npc) ÷ map_points`

An NPC rolls once per realm entered from Core Formation, with chance `npc_dao_chance`, until
its first success (rule 11: at most one Dao). On success it takes one Dao uniformly from those
it qualifies for. The Meridian Map allocator gets `map_points`, and `power_mult` multiplies the
resulting combat power, as a capability's `npc_effect` does. `power_mult` restores the W the
deducted points would have bought on the map and adds the premium, so an NPC with a Dao is
stronger than one without, as a player's is (user decision 2026-11-06, on the deduction from
review decision 2026-11-05). It assumes map power is close to linear in points, which a bot run
must confirm (Open Question 5).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `npc_dao_chance` | float | 0.5 | data file, *guess* | Chance of a Dao per realm from Core Formation, until the first success |
| `npc_dao_share` | float | 0.25 | data file, *guess* | Share of an NPC's points it has put into its Dao |
| `dao_premium` | float | 2 | data file (Formulas D1) | What a Dao point is worth against a map point, the player's value |
| points_total(level) | int | 161–566 | Meridian Map Formulas A | The NPC's points: an NPC's level is the first level of its stage |
| P_npc | int | 40–60 | calculated | Points put into the Dao, deducted from the map |
| map_points | int | 121–506 | calculated | Points the Meridian Map allocator gets |

**Output Range:** `power_mult` 1.00 (no Dao) to about 1.67. Below the cap it is a plateau
of 1.652–1.667 (161 points: 1.661; 179: 1.652; 216 and 240: 1.667), and it falls once the
60-point cap binds above 240 points (304 points: 1.492; 566 points: 1.237).
The ratio `P_npc ÷ points_total` never exceeds `npc_dao_share`, so `power_mult` never exceeds
1 + 2 × 0.25 ÷ 0.75 = 1.667.
`power_mult` acts on the smaller map allocation, so the gain over an NPC of the same level with
no Dao is `(points_total + (dao_premium − 1) · P_npc) ÷ points_total`: at most +25 %, falling to
about +11 % at 566 points. `npc_dao_power_max` is retired.

**Example:** a Core Formation NPC at level 41 has 161 points, so P_npc = min(60, ⌊40.25⌋) = 40,
map_points = 121 and power_mult = (121 + 80) ÷ 121 = **1.661**, about +25 % over a Dao-less NPC
of that level. A Nascent Soul NPC at level 87 has 304 points, so ⌊76.0⌋ caps at 60,
map_points = 244 and power_mult = (244 + 120) ÷ 244 = **1.492**, about +20 %.

## Edge Cases

**Glimpses**

- **If fewer Daos qualify than `dao_offer_size`:** the offer shows what exists. The catalogue lint
  keeps `dao_open_min` Daos open, so an empty offer cannot happen in shipped data. If E were empty, the glimpse
  is skipped and the realm's allowance is kept.
- **If a glimpse event arrives after the realm's allowance is used:** the Event Engine's
  validator refuses the effect, and the event plays without it.
- **If the character skips a realm's glimpse:** the allowance is lost with the realm. It does not
  carry forward.
- **If the player declines every offered Dao:** nothing is granted and the allowance is used.
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
- **If a data change adds nodes to a Dao the character has Mastered:** nothing is taken away.
  The Dao reads as Keystoned again (states are derived; the keystone stays bought), the new nodes are buyable,
  and the keystone's World Database event is not written a second time.
- **If a glimpsed Dao is deleted from the catalogue:** its bought nodes are refunded as unspent
  points (the same single refund case), and it leaves the Dao list. A save that refers to it
  loads without error. The catalogue lint still has to hold `dao_open_min` after the deletion.
- **If a glimpsed Dao's requirement changes in the data:** the Dao stays (the requirement was
  checked once, at the glimpse). Only Daos not yet glimpsed are offered under the new requirement.

**Arts**

- **If an art node is authored before the combat system exists:** the data lint rejects it in the
  shipped catalogue (rule 3). Test data may carry one.

**NPCs**

- **If an NPC is generated at Core Formation or higher:** it rolls once for its current realm, not
  for earlier ones.
- **If an NPC's roll succeeds but it qualifies for no Dao:** it holds none, and the roll counts as
  failed, so it rolls again in its next realm. The `dao_open_min` lint keeps Daos with no
  requirement in the catalogue, so this cannot happen in shipped data.
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
| 11 Progression Edges (design order #10) | A birth or sect edge that grants an early glimpse (Open Question 6) | The glimpse allowance stays at `dao_glimpses_per_realm` |

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

**Combat sub-systems (back-references added by the Combat revision #43, 2026-11-08).** This system and the four
systems split out of Combat depend on each other as follows.

- **Modifier System (#40):** Way nodes carry catalogue modifiers at its W prices, including `more` on L2.
- **Effects System (#41):** Way nodes and capstones host Effects (conditions, triggers, keystones).
- **Combat Damage Types (#21b):** a Way art node declares its damage parts and types.
- **Combat Defence & Healing (#21a):** ward spells and heal arts may be Way content.

## Tuning Knobs

All live in `dao.json` (Formulas D1–D3). Safe ranges are guesses until the bot run (Open
Question 4, 5).

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `dao_node_cost` | 3 | 3–5 | Points per node, flat. Moves a Dao's total cost, the lint bands (V̄ = premium × cost × 2.07) and the ability credits (Formulas D1) with it |
| `dao_premium` | 2 | 1.5–3 | How much a node beats the acupoints it replaces, for the player and for NPCs. 3 lets Daos outshine the map. The ability credits rescale with it (Formulas D1) |
| `dao_node_count`, `dao_full_points` | 20, 60 | 19–22, 57–66 at cost 3 (N × cost elsewhere) | How much of a life's points a Dao takes (4 Daos = 240 of 566), and the authoring load |
| `dao_rate_cap_pct` | 10 | 5–15 | Most cultivation speed one Dao may give (Formulas D1 part 4). Higher lets a Dao speed the climb and could shift the gate calibration |
| `dao_branch_tol` | 0.2 | 0.1–0.3 | How far a branch may sit from the mean node value. Wider lets a branch be a jackpot or a trap |
| `dao_route_floor` | 0.9 | 0.8–1.0 | How good the cheapest route to the keystone must be, as a share of the mean |
| `dao_ability_credit` | 10 / 18 / 30 W | ±30 % | What a passive counts for in the node-value lint, at cost 3 and premium 2; it scales by premium × cost ÷ 6 (Formulas D1) |
| `dao_glimpses_per_realm` | 1 | 1 (2 only if `dao_open_min` ≥ offer + 7, so at offer 3 and not at offer 4, which needs 11 against a ceiling of 10) | Daos per life (4 at 1) |
| `dao_glimpse_realm_min` | 1 (Foundation Establishment) | 1–2 | When the first Dao can come |
| `dao_offer_size` | 3 | 2–4 | Choice at a glimpse; the invariant in Formulas D2 must hold (at 4 it needs `dao_open_min` ≥ 7) |
| `dao_open_min` | 6 | 6–10, and never below `dao_offer_size + 4·dao_glimpses_per_realm − 1` | How many Daos anyone can be offered |
| `npc_dao_chance` | 0.5 | 0.2–0.8 | How common Dao-holding NPCs are |
| `npc_dao_share` | 0.25 | 0.1–0.30 | NPC points in the Dao; `power_mult` caps at 1 + `dao_premium` × share ÷ (1 − share), so 0.30 gives 1.86 |

## Visual/Audio Requirements

Deferred. Each Dao will want an identity (colour, sigil and sound) when the Game UI and Audio
are designed.

## Game Feel

Not specified at this tier. Intent for later work:
- **A glimpse** is a moment: three Daos offered, one chosen, and a tree to look at.
- **A node** feels like a real purchase: 3 points, and clearly better than 3 acupoints.
- **A keystone** is the payoff that names the build.
- **A tree** reads as its Dao: every node sounds like Sword, or Time, and like nothing else.

## UI Requirements

Specified for the Debug Terminal now and the Game UI later.
- **The Dao list** shows each Dao as unknown (not shown), glimpsed, keystoned or mastered.
- **A tree** shows every node with its kind (stat, passive) and what it gives, the flat cost,
  and the shortfall when the character cannot afford one.
- **The offer** lists `dao_offer_size` Daos (three at the default) with their requirements and a one-line description.
- **The Advisor** warns before a buy when a stat line would sit above a ceiling.
- **The unused-glimpse heads-up:** from Foundation Establishment, while the realm's glimpse is
  unused, the Advisor says so, shows the character's unspent points, and notes that a Dao tree
  is 57–66 points. It is information only and never forces or blocks a spend.
- **The shared pool:** the unspent count is the same figure the Meridian Map shows.

## Cross-References

| Document | What it must say or do |
|---|---|
| `design/gdd/linh-can.md` | Open Question 9 is answered by this GDD, and rule 16 points here |
| `design/gdd/cong-phap.md` | Open Question 11 closes: no shipped template names a relocated mutation |
| `design/gdd/kinh-mach-do.md` | List the Way in Dependencies: its unspent points subtract the Way's spent count |
| `design/gdd/character-stats.md` | A Dao is a new modifier source on the stat sheet |
| `design/gdd/canh-gioi.md` | The gate calibration holds because Daos add no ceiling raise (rule 4); a Dao's breakthrough chance is a q-extras source under the 10 pp ceiling only (added 2026-11-06) |
| `design/gdd/systems-index.md` | Row 39 and the design order |
| `design/registry/entities.yaml` | The keys and formulas above |

## Acceptance Criteria

Evidence: Logic and Integration tests under `tests/unit/dao/`, Config/Data checks of `dao.json`,
and UI transcripts under `production/qa/evidence/debug-terminal/`.

**Costs and data**

- **AC-DAO-01** [Config/Data] Every Dao in `dao.json` has 19–22 nodes and, at the defaults
  (cost 3, premium 2), a mean node value of 11.2–13.7 W; each of its three branches has a mean
  within 9.9–14.9 W; and each keystone route R(b) averages at least 11.2 W (Formulas D1). A
  fixture tree with one branch at 5 W per node and another at 20 W fails the lint. With
  `dao_premium` 3 at cost 3 the bands scale to 16.8–20.5 W and the credits to 15 / 27 / 45 W.
  With `dao_node_cost` 5 at premium 2 the bands scale to 18.6–22.8 W and the credits to
  16.7 / 30 / 50 W.
- **AC-DAO-26** [Config/Data] Key headroom (Formulas D1 part 4). A fixture Dao with 12
  `alchemy_success` lines of 8 W fails the lint (8.1 W is the headroom); a fixture Dao whose
  `cultivation_speed_pct` lines sum to 11 % fails at the default `dao_rate_cap_pct` 10 and passes
  at exactly 10 %. A fixture Dao with the same lines on an uncapped key passes.
- **AC-DAO-21** [Config/Data] At least `dao_open_min` Daos have no root or technique
  requirement, and `dao_open_min ≥ dao_offer_size + 4·dao_glimpses_per_realm − 1` holds. The
  lint also fails when a deletion drops the open count below the invariant.
- **AC-DAO-22** [Config/Data] No shipped node is an art, none carries a ceiling raise or a root
  factor, and none multiplies a whole cultivation rate, lifespan or breakthrough chance (rule 4).
- **AC-DAO-23** [Config/Data] Every stat line uses only its Dao's `theme_stats`, and no passive id
  appears in two Daos.
- **AC-DAO-02** [Logic] Formulas D1: every node costs 3 points, whether a 4 W line or a 34 W
  keystone, and V̄ is 12.42 W.
- **AC-DAO-03** [Logic] The Formulas D1 example Dao totals 60 points and 236 W, a mean of 11.8 W
  per node; its branch means are 10.3, 11.7 and 10.0 W; R(A), R(B) and R(C) are 112, 120 and
  120 W over 9, 9 and 10 nodes; and it passes the lint.

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
- **AC-DAO-10** [Integration, Bot: `autoplay.gd`] `autoplay.gd --edge on --perk dao_cot --dao <id>` (the Đạo Cốt perk is
  AC-CG-31's fixture, not a Dao). The `--dao` flag is a test hook: it grants the glimpse of
  `<id>` on entering Foundation Establishment, bypassing the Event Engine, and buys that tree in
  branch order until Mastered. The three stat-line-only test Daos are fixtures in the test data:
  one whose lines are all cultivation speed, one all alchemy and brewing success, and one all
  Dao heart and comprehension, each at the top of the node-value lint (13.7 W mean) so they
  are the worst case for rule 10. They are test data and deliberately exempt from the
  key-headroom part of the lint (AC-DAO-26): they check the gate calibration beyond what
  shipped data can reach. For each, the Realms gate runs stay inside AC-CG-31's
  windows, so no Dao has moved the gate calibration.

**NPCs**

- **AC-DAO-11** [Logic] Formulas D3: a Core Formation NPC at level 41 has P_npc 40, map_points
  121 and power_mult 1.661 (±0.001). A Nascent Soul NPC at level 87 has P_npc 60, map_points
  244 and power_mult 1.492 (±0.001). The boundaries, each ±0.001: at 216 points P_npc 54,
  map_points 162 and power_mult 1.667; at 240 points, where the share meets the cap, P_npc 60,
  map_points 180 and power_mult 1.667; at 566 points P_npc 60, map_points 506 and power_mult
  1.237. An NPC with no Dao has power_mult 1.000.
- **AC-DAO-12** [Logic] Over 16,000 NPC rolls at `npc_dao_chance` 0.5, 50 % ± 1.6 pp succeed. An
  NPC generated at Core Formation rolls once, for its current realm only. An NPC that has a Dao
  makes no further roll in later realms and still holds exactly that one Dao. With test data
  where an NPC qualifies for no Dao, a successful roll leaves it with none and it rolls again in
  its next realm.

**Persistence and the world**

- **AC-DAO-13** [Integration] A save round trip keeps every Dao glimpsed and node bought. A node
  removed from the data comes back as unspent points.
- **AC-DAO-14** [Integration] A glimpse and the keystone purchase each write one World Database
  event. Buying the keystone as the last node (Glimpsed straight to Mastered) writes exactly one
  event. Buying the last non-keystone node of a Keystoned Dao writes none.

**UI**

- **AC-DAO-15** [UI] A retained screenshot or transcript shows, each as its own item: the Dao
  list with unknown / glimpsed / keystoned / mastered states, a tree with every cost and the
  unaffordable nodes marked with their shortfall, the three-Dao offer with requirements and
  one-line descriptions, the Advisor's ceiling warning before a buy, and the unused-glimpse
  heads-up with the unspent count (at Foundation Establishment with the glimpse unused, and
  absent once it is used).

**Added by the 2026-11-05 and 2026-11-06 reviews**

- **AC-DAO-16** [Integration] An NPC with a Dao (Formulas D3): the Meridian Map allocator is
  called with `map_points`, not `points_total`, and the resulting combat power is multiplied by
  `power_mult`. An NPC with no Dao is called with `points_total` and a multiplier of 1.000.
- **AC-DAO-17** [Logic] With E empty the glimpse is skipped and the realm's allowance is kept; a
  declined offer uses the allowance and leaves all three Daos in E.
- **AC-DAO-18** [Integration] A Dao passive and a Meridian Map capability that give the same
  breakthrough chance both apply. The Dao's share counts only under the 10 pp q-extras ceiling:
  with the tree at its 8 pp cap and a Dao line of 4 pp, the extras clamp at 10 pp and the sheet
  shows the clamp line. With the Dao line at 4 pp and the tree at 12 pp offered, the tree
  counts 8 pp and the Dao 4 pp (12 pp, clamped to 10 pp).
- **AC-DAO-19** [Logic] A node removed by a data change is refunded, and a node that needed it
  stays bought.
- **AC-DAO-20** [Config/Data, human sign-off] A content review of the shipped catalogue: for each Dao, shown its
  nodes with the name hidden, at least 2 of 3 reviewers name it, and each branch has a named
  facet of the theme (rule 12). A Dao that fails goes back to the content pass.
- **AC-DAO-24** [Logic] Edge Cases: a data change that adds a node to a Mastered Dao leaves it
  Keystoned and writes no second keystone event. A deleted glimpsed Dao refunds its
  bought nodes and the save loads. A changed requirement leaves a glimpsed Dao in place.
- **AC-DAO-25** [Integration] An NPC that rolls a Dao has its id in its record and one World
  Database fact for it, and the id survives a save round trip. An NPC with no Dao has neither.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | The `dao_glimpse` contract: which events grant it, how often (the rate), and what the validator checks. The Event Engine is already implemented, so read its code before settling the contract. The rate also decides how often the unused-glimpse heads-up fires | Event Engine | Any Dao in play |
| 2 | The catalogue: a tree of about 20 nodes for each of the 22 seeds and the new Daos, so 440+ nodes, each from its Dao's theme (rule 12). Which new Daos, what each requirement is, and each Dao's `theme_stats`. A narrow theme with few stats needs more passives, which adds authoring work | game-designer, user | Content pass |
| 3 | The combat system. Arts are on hold until it exists, and the ability credit for an art tier needs its own pricing then | Combat (not designed), user | Art nodes |
| 4 | `dao_ability_credit` (10 / 18 / 30 W) and the branch and route lint (`dao_branch_tol` 0.2, `dao_route_floor` 0.9) are guesses. `dao_premium` 2 makes a life with Daos stronger in tree power than the map alone: about +37 % with one Dao at Core Formation entry, +56 % with two at its end and +40 % with four at Deity Transformation (Formulas D1). Check that against combat and NPC power once trees exist | systems-designer | A content pass and a bot run |
| 5 | `npc_dao_chance` and `npc_dao_share` are guesses, and so is the assumption behind `power_mult` (map power close to linear in points). A bot run must confirm that a Dao-holding NPC ends up about 11–25 % above a Dao-less NPC of its level, check the combined NPC uplift with cluster holders (Meridian Map AC-KMD-49), and re-run the world census, since stronger NPCs may change who dies | NPC Builds, bot run | AC-DAO-11, 12 |
| 6 | May a perk or a sect grant an early glimpse (a birth edge)? It would touch Progression Edges | game-designer | The edge |
| 7 | Do Dao trees sit on the Meridian Map screen or on their own? | ux-designer | The UI |
| 8 | The Way is Alpha (provisional) in the index. Should the first release ship Daos before Combat exists, with stat lines and passives only? | user | Scope |
