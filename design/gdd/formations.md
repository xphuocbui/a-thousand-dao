# Formations (Trận Pháp)

> **Status**: Approved (design-review round 6, 2026-11-21, lean)
> **Author**: user + Claude
> **Last Updated**: 2026-11-21 (design-review round 6: APPROVED, no edit to the rules)
> **Last Verified**: 2026-11-21
> **Implements Pillar**: 3 (Power Is Built, Not Given), 2 (Every Number Is Bounded and Visible)
> **Creative Director Review (CD-GDD-ALIGN)**: REVISED 2026-11-21 — Pillar 1 concern (diagram diversity) answered by a harness diversity check in Open Question 6

## Summary

Formations (Trận Pháp) cover two things. The first is the standing arrays a cultivator raises at a cave abode or a site (Tụ Linh, Thanh Mộc, Hộ Sơn, teleport and protective arrays). The second is the combat formation diagrams (trận đồ) that replace Combat's plain row of art slots. A diagram is a graph of nodes, each an art slot with a positive, negative or conditioned rule, and links that let arts read or feed each other. It has its own linh lực reservation and burns linh thạch when it is laid, so the arrangement of arts becomes the build. The system exists to reward preparation (Pillar 3) and to give linh thạch a lasting, visible sink (Pillar 2).

> **Quick reference** — Layer: `Feature` · Priority: `Alpha` · Key deps: `Combat, Combat Defence & Healing, Item Database, Character Stats, Modifier System, Effects System, Regional Economy`

## Overview

Formations (Trận Pháp) are arrangements of linh thạch-fuelled arrays, in two parts that share one grammar of grade, level and fuel.

**Home and world arrays** are standing works. The player raises them over years at a cave abode or a place (Tụ Linh, Thanh Mộc, Hộ Sơn, plus teleport and protective arrays). They burn linh thạch as upkeep or fuel and feed cultivation, the economy, travel and defence.

**Combat formation diagrams (trận đồ)** replace Combat's plain row of art slots. A diagram is a graph of nodes. Each node is an art slot with its own rule: a positive effect, a negative effect, or a condition. Links between nodes let arts feed each other. Diagrams come in many shapes (a ring plus a centre, a chain, a fork) and are not tied to an element. A player obtains them by crafting (positions rolled like an artifact's affixes) or by being taught them from công pháp and formation manuals. Laying a diagram for a foreseen fight burns linh thạch by its size and grade, and a diagram that is not laid works at Combat's carried-ground share (70 % in a foreseen fight or an ambush, 50 % blind); a laid diagram works at 100 %.

**Player fantasy:** the player studies a diagram, slots arts into its nodes, accepts the cost of a weak node for a strong centre, and watches the arrangement pay off in the fight. The arrangement is the build (Pillar 3). Every slot rule and every stone spent is visible in the fight's Breakdown (Pillar 2). Without Formations the game loses a build axis that rewards preparation, and linh thạch loses its formation-fuel sink (World Economy decision 7).

## Detailed Design

### Core Rules

**Part I: Combat formation diagrams (trận đồ)**

1. **A diagram is a record**: id, grade, level, node list, link list, source, the realm and Trận Pháp skill it requires (rule 8), the sects that teach it (Sects owns which), and its own `reserve_share` (rule 9a). `fuel_frac` and `cost_lt` are looked up by grade in the data file, not stored in the record. Nodes are numbered from 1. Each node has a **polarity** (positive, negative or conditioned), one **rule**, and a `node_score` (F4).
2. **The default line diagram ("Plain Row")** is known to everyone and is the diagram of any combatant that lays none. It has `slot_count` plain nodes, no rules, no links and no fuel. A character with only the default line behaves exactly as Combat rule 13 does today.
3. **Node budget.** `slot_count` (Combat Formulas A2, including `bonus_slots`) is the budget. A diagram of N nodes can be set (so neither laid nor carried) only if N ≤ `slot_count`. The remaining `slot_count − N` slots are **plain slots**: unlinked, no rule, placed after the diagram's nodes. Kind-locked slots (`free_slots[kind]`) stay outside the pool and the diagram. The art pool's size therefore never changes; the diagram changes only how it is arranged and what each slot does.
4. **Slot order is the node index.** Each node's art is placed by the player (or the NPC generator). The node index replaces Combat's separate order for diagram nodes; plain slots keep the player's order after them (Combat rule 13, amended 2026-11-21).
5. **Node rules** act on the art slotted in the node, in three forms:
   - A **Modifier node**: one plain number on a stat of that art, tag-scoped (damage, art cost `art_cost_pct`, art speed `art_speed_pct`; there is no separate cooldown key: a faster art is `art_speed_pct`, and Combat A2 divides the cooldown by it). Positive or negative.
   - An **Effect node**: a rule with its own Effect record, e.g. "the art fires one extra time when health is below 40 %". Conditioned nodes read a Combat guard-vocabulary condition (health or linh lực share, a status, fight time).
   - A **gate node**: the art in it fires or counts only while a condition holds. It is a conditioned node with the cost-of-power role.

   An empty node does nothing but still counts toward N. Magnitudes are scaled by diagram strength (rule 7).
6. **Links** come in two kinds, declared per link:
   - **Adjacency** (undirected): a node rule may read its linked nodes' arts (their tags, whether they are filled). It moves no timers.
   - **Feed** (directed): when the source node's art fires, the target node's art timer drops by the amount the link declares. A feed is **one hop per instant** (a fed art's firing does not feed again in the same instant), and does nothing to an art that is already ready. The new timer is `min(timer, max(timer − feed, cooldown_min))` (`cooldown_min` is Combat's value): a feed never takes a timer below `cooldown_min` and never raises one that is already below it. The floor is deliberate: a feed shortens a wait but never makes an art ready in the same instant, and a feed larger than `timer − cooldown_min` gains nothing more (a bounded brake; Open Question 10).
7. **Diagram strength.** The magnitudes of positive and conditioned nodes, and every link's feed amount, are scaled by S (Formulas F1: grade, level and `formation_power_pct`); the magnitude of a **negative-polarity node** (a drawback, rule 1's polarity field, not the sign of the number: a −20 % `art_cost_pct` node is a benefit) is not. A node whose authored number is a price is negative-polarity whatever its condition; conditioned polarity is for benefits behind a condition. S and the share multiply **authored numbers only**: Modifier values, feed seconds and an Effect's numeric magnitude. Conditions, thresholds, counts ("one extra time") and gates are never scaled. A diagram has its own level, raised at the abode like an array (F3); taught diagrams start at L1. The effective level is `L_eff = min(L, min(max_level, Trận Pháp skill + 1) + 2 with the keystone Formation Within a Formation, +0 without)`: the keystone's 2 levels are added after both caps. A scaled `art_speed_pct` still passes through Combat A2's `cooldown_min` floor (A2 divides, so a cooldown never goes negative), and every other scaled Modifier value keeps its key's bounds in the Modifier System (F1).
8. **Sources.** A diagram is **crafted** (a Trận Pháp craft yields an item whose node rules are rolled like an artifact's affixes, within the grade cap) or **taught** (a công pháp or formation manual teaches a fixed authored diagram, owned as a known id). Both need realm and skill as the record says, so players unlock diagrams as they become able to.
9. **Laying, carrying and fuel** (Combat rule 12). In a **foreseen** fight the player may **lay** the diagram: it pays the lay fuel in linh thạch (Formulas F2: by N, grade, level and the realm budget), when the fight begins, and all node and link magnitudes count at 100 %. A diagram that is **carried** (not laid, or in an ambush or a blind fight) is the same loadout and pays no fuel, and its magnitudes run at Combat's `carried_ground_share`: 70 % in a foreseen fight not laid (by choice or because the fuel is short) or in an ambush, 50 % blind. Laying is the paid way to reach full strength; carrying is the free fallback.
9a. **Reservation cost** (user decision 2026-11-21). Every diagram record authors a `reserve_share` of maximum linh lực that its specific shape costs (a lean 3-node chain a few percent, a large ring more; the default line 0). It is held from t = 0 for the whole fight under Combat Defence & Healing rule 10, whenever the diagram is **laid or carried**, and it is **never scaled** by S, level or the carried share: it is the price of having the shape up. Reservation efficiency applies as it does for wards, the effective share counts toward `reserve_cap` (90 %) together with any ward reservations, and a diagram that would pass the cap cannot be set. The usable maximum is `qi_max × (1 − Σ reserved)`, so a costly diagram means fewer casts (Combat Defence rule 10).
10. **One diagram per side.** A side has exactly one diagram in a fight. It never competes under Combat's "one formation per side away from home", which picks one ground object besides it (a laid ground array or a carried ground), whichever is stronger (Combat rule 12, amended 2026-11-21). At the player's own abode every standing home array (Part II) also counts beside the diagram.
11. **Visibility** (Pillar 2). Each node's and link's contribution appears as lines in the fight's opening Breakdown, together with the lay fuel burnt, the share (100 / 70 / 50 %) and the linh lực reserved (rule 9a), and each feed that fires is logged in the fight record with its source, target and seconds taken off.
12. **NPCs.** The NPC generator picks, from the diagrams its sect and Trận Pháp skill allow, the one with the best **fit score** against its arts' tags (Formulas), and places arts in the nodes by greedy fit. With no better fit it uses the default line. An NPC lays for foreseen fights and carries otherwise. An NPC that lays pays F2 from its own purse when the fight begins; Formula H books the season's sum as one line (`burn_formation`), not per NPC.

**Part II: Home and world arrays**

13. **An array record**: id, kind (**standing**, **teleport**, **protective**), grade, level, where it stands (cave abode, a place, or a sect's seat), fuel model. Level, build cost and the Trận Pháp skill cap follow the quick spec (`cost_lt × cost_growth^(L−1)` plus materials; max level `min(max_level, skill + 1)`).
14. **Standing arrays** (Tụ Linh, Thanh Mộc, Hộ Sơn) keep the current yearly upkeep `Σ levels × upkeep_lt_per_level`, cut by Thổ purity; one that goes unpaid drops a level. **Cave Abode rules 9 and 10 apply first:** a **dormant** array (rule 9, slot lost) owes no upkeep, keeps its level and never Lapses; an array **left behind** (rule 10) stops counting, owes no Formations upkeep and fades on Cave Abode's clock (one level every `fade_seasons`, gone at 0, and gone on a claim, rule 11), so the yearly Lapse applies only to arrays at the owner's current home; the abode's own seasonal works upkeep (Cave Abode rule 8) does not bill arrays. Tụ Linh still counts once as a layer-1 work for Travel & Map. Standing arrays are **home works** at the abode: each takes one slot (`design/gdd/cave-abode.md` rule 4, F3), and its level cannot pass the abode's level ceiling; build cost, upkeep and the skill cap stay here.
15. **Teleport arrays** link two sites. The jump fee, the travel time (0.05 of a season) and who may use the array are Travel & Map rule 11 and Formula K and Sects #26; Formations adds **no second burn**, and the share of the fee that #43 burns (`f_burn`) is the array's fuel. **Protective arrays** burn linh thạch each time they trigger (what triggers them is set in Interactions).
16. **Sect-owned arrays** belong to the Sects GDD; Formations defines only the record shape they use.
17. **Every stone burnt** by rules 9, 13, 14 and the protective part of 15 (laid diagrams, build and raise stones of every array kind and of diagrams (F3), standing upkeep, protective triggers) is a sink booked in #43 Formula H as `burn_formation`. **Teleport fuel is not booked here**: it stays in `burn_fees` via `f_burn` (rule 15), so it is never booked twice. Formations books all other array and diagram stones; the abode's `burn_abode` covers its grade, slots, fields and claims only, and holds no array cost (back-link owed in Cave Abode rule 14 and Regional Economy's `burn_formation` row). Linh thạch stays money only, so no stat is priced in stones.

### States and Transitions

**Combat diagram (per owned diagram and per fight)**

| State | Meaning | Enters from | Leaves to |
|---|---|---|---|
| Unknown | Not learned or owned | none | Known (taught, crafted or found) |
| Known | In the collection; can be set as the loadout if N ≤ `slot_count` | Unknown, Set (swapped out) | Set; Unknown only if a crafted item is lost or sold |
| Set | Chosen as the loadout, arts placed in nodes (preparation screen); stays Set across fights until swapped | Known, In fight | Known (swapped), Laid, Carried |
| Laid | Foreseen fight, fuel paid, magnitudes 100 % | Set, in a foreseen fight, fuel affordable | In fight |
| Carried | Not laid, or ambush or blind; no fuel, share 70 % or 50 % | Set | In fight |
| In fight | Node and link rules run; feeds fire | Laid, Carried | Set (the fight ends; the loadout persists) |

A fight never consumes a diagram. The lay fuel is paid when the fight begins, so a fight declined or cancelled before it starts burns nothing (Edge Cases).

**Array (per owned array)**

| State | Meaning | Transition |
|---|---|---|
| Unbuilt | Level 0 | Build → Standing at level 1 (stones + materials, one season, at its site) |
| Standing (L) | Effects apply; yearly upkeep due | Raise → L+1 (to the skill cap); upkeep unpaid → Lapsed |
| Lapsed | Upkeep unpaid on the yearly tick | Drops one level at once, then Standing (L−1); at level 0 it is Unbuilt |
| Armed (protective) | Standing and waiting | Trigger → Fired, burns stones; fuel short → does not trigger |
| Fired | One trigger spent for this event | Armed again after the event |
| Idle (teleport) | Standing | Jump → Idle again after the travel time; the fee is Travel & Map Formula K; the owner may refuse the user (Sects) |

### Interactions with Other Systems

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Combat | out | The diagram: the node list (stat modifiers, Effects, gates), link list, strength-scaled magnitudes, and the share (100 / 70 / 50 %). Combat compiles it into the loadout and runs it. | Formations owns the record; Combat owns what happens in the fight |
| Combat | in | `slot_count`, `carried_ground_share`, the guard vocabulary, `cooldown_min`, the situation (foreseen, ambush, blind) | Combat |
| Combat Defence & Healing | out / in | Out: the diagram's `reserve_share`. In: rule 10 (reservation, efficiency, `reserve_cap`), which holds it | Combat Defence & Healing |
| Item Database | in | Item and affix rolling for crafted diagrams and array materials | Item Database |
| Character Stats | in | Trận Pháp skill (level cap), Thổ purity (upkeep cut) | Character Stats |
| Time & Turn | in | The yearly upkeep tick; the season a build takes; the travel time of a jump | Time & Turn |
| Modifier System #40 | in | Modifier node shape: plain number, tag-scoped; `formation_power_pct`, `formation_upkeep_pct` | Modifier System |
| Effects System #41 | in | Effect node records, conditions, the keystone +2 levels, Earth Vein Tap ("while your own formation stands") | Effects System |
| Cultivation Techniques | in | Taught diagrams: which công pháp or manual teaches which diagram | Cultivation Techniques |
| Regional Economy #43 | out | Stones burnt (laid diagrams, array and diagram build and raise stones, upkeep, triggers) as sinks in Formula H; jump fees stay in `burn_fees`; NPC fuel as an aggregate | Regional Economy owns the ledger |
| Travel & Map | out | Tụ Linh as a layer-1 work; teleport arrays as links between sites | Travel & Map owns travel time and density; Formations owns the array |
| Sects | in/out | Sect-owned arrays use this record shape; sects teach diagrams | Sects |
| NPC Builds | out | The catalogue and fit score; NPC Builds owns who gets which | NPC Builds |
| Events | in | A raid or attack on a site triggers its protective array | Events |
| UI (preparation screen) | out | Diagram shape, node rules, fuel cost and share to display | Formations owns data; UI owns layout |

The protective-array trigger and its strength are **provisional**: a protective array adds `defense_pct` to its site's defenders for one event, by its level and half of `formation_power_pct` (as Field Walls counts half of formation power as ward strength); Formulas F5.

## Formulas

Starting values are **guesses** for the balance harness to derive.

### F1. Diagram strength

The diagram_strength formula is defined as:

`S = clamp(grade_mult[g] × level_growth^(L−1) × (1 + formation_power_pct / 100), S_min, S_max)`

An authored number `v` on a positive or conditioned node, or a feed's seconds, becomes `v × S × share`. The number on a **negative-polarity node** (a drawback; polarity is rule 1's field, not the sign: a −20 % `art_cost_pct` node is positive) is **not** scaled by S (levelling a diagram must not make its price worse), but it is multiplied by `share` like everything else, so a carried diagram is a weaker version of the same trade and never a worse one. Conditions, thresholds, counts and gates are not numbers S scales (rule 7). `L` is `L_eff` (rule 7). **Bounds after scaling:** a scaled `art_speed_pct` goes through Combat A2 (`cd / (1 + art_speed_pct / 100)`, floored at `cooldown_min`, so the cooldown is never negative), and every other scaled Modifier value is clamped to its key's bounds in the Modifier System.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| g | int | 0–4 | diagram record | Grade (the Item Database's five grades) |
| grade_mult[g] | float | 1.0 / 1.15 / 1.3 / 1.5 / 1.75 | data file *(guess)* | Base strength of a grade |
| L | int | 1 to `max_level` (5) + 2 from the keystone | calculated | Level, limited to Trận Pháp skill + 1 |
| level_growth | float | 1.25 | data file *(guess)* | Strength per level |
| formation_power_pct | float | −50 to about 200 | Modifier System | The existing key |
| S_min, S_max | float | 0.25, 8 | data file *(guess)* | Bounds (Pillar 2) |
| share | float | 1.0 / 0.7 / 0.5 | Combat `carried_ground_share` | Laid / carried (foreseen not laid, or ambush) / blind |

**Output Range:** 0.5 (grade 0, L1, power −50 %; 1.0 with no power; `S_min` 0.25 is a safety bound that the stated power range does not reach) to 8 (clamped; the unclamped maximum, grade 4 at L7 with +100 % power, is 1.75 × 3.81 × 2 = 13.3).
**Example:** grade 2, L3, power +20 %: 1.3 × 1.5625 × 1.2 = 2.44, so a +10 % art-speed node gives +24.4 % laid and +17.1 % in an ambush.

### F2. Fuel to lay a diagram

The lay_fuel formula is defined as:

`fuel = ceil(N × fuel_frac[g] × fuel_growth^(L−1) × linh_thach_max[realm] − 1e-6)`

The `− 1e-6` is the project's rounding tolerance (as Regional Economy's formulas): it keeps a product that is exact in decimal (288) from becoming 289 through floating-point error.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| N | int | 1 to `slot_count` | diagram record | Node count (the default line pays no fuel) |
| fuel_frac[g] | float | 0.002 / 0.003 / 0.0045 / 0.007 / 0.01 | data file *(guess)* | Share of the realm budget per node |
| fuel_growth | float | 1.6 | data file *(guess)* | Per level; above `level_growth`, so each level costs more per point of strength |
| linh_thach_max[realm] | int | 80 / 600 / 5,000 / 40,000 / 300,000 | `events_budgets.json` (as Travel & Map K) | The layer's realm budget; keeps fuel meaningful at every realm |

**Output Range:** 0.2 % of the budget (N=1, grade 0, L1) to 45.9 % (N=7, grade 4, L5; 2,294 at Core Formation) without the keystone, and 117 % (N=7, grade 4, L7 with the keystone; 5,873 at Core Formation) with it. Above 100 % the diagram is simply carried (fuel short), which is the intended brake.
**Example:** Core Formation, N=5, grade 2, L3: 5 × 0.0045 × 2.56 × 5,000 = **288** (5.8 % of the budget; a Travel & Map jump of 450 tiles costs 1,375).

### F3. Raising a diagram or array a level

The raise_cost formula is defined as:

`raise_cost(L) = cost_lt[id or grade] × cost_growth^(L−1)` linh thạch, plus `materials_per_level × L` units of rarity ≥ `material_rarity`.

Max level = `min(max_level, Trận Pháp skill + 1)`; **with the keystone Formation Within a Formation a diagram's maximum level is that cap + 2** (headroom, as the Effects System defines the keystone), so a stored L can reach cap + 2 and rule 7's `L_eff` then adds nothing beyond it. `raise_cost(L)` is the cost to reach L from L−1 (L2 of Tụ Linh = 150 × 2.5 = 375). For the three arrays this is the existing quick-spec formula unchanged (Tụ Linh 150 × 2.5^(L−1), Thanh Mộc 120, Hộ Sơn 100; `crafting_formations.json`). A diagram has its own level, raised at the abode like an array with `cost_lt[grade]` (values set with the first catalogue); a taught diagram starts at L1.

### F4. NPC fit score

The fit_score formula is defined as:

`fit(d) = Σ over nodes n of node_score[n] × m(art_n, n)`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| node_score[n] | float | signed | diagram record | Authored value of a node for an art that matches its scope (negative for a drawback) |
| m(art, n) | int | 0 or 1 | calculated | 1 if the placed art satisfies the node's tag scope, or the node has no tag scope (an Effect or gate node); links are not scored |
| fit_min | float | 0 | data file *(guess)* | At or below this the NPC uses the default line (a diagram that scores exactly `fit_min` is no better fit) |

Arts are placed greedily: take the nodes in descending `|node_score|` (ties by node index) and give each the unplaced art with the highest `node_score × m` (ties by pool order). An NPC takes the highest-fit diagram among those its sect and Trận Pháp skill allow; ties go to fewer nodes, then lower id.

### F5. Protective array

The protective_array formula is defined as:

`defense_pct = per_level × L × (1 + 0.5 × formation_power_pct / 100)` for one event; `trigger_burn = trigger_frac × L × linh_thach_max[owner realm]`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| per_level | float | 10 | `crafting_formations.json` (as Hộ Sơn) | Defence per level |
| trigger_frac | float | 0.004 | data file *(guess)* | Share of the owner's realm budget burnt per level per trigger |

**Example:** Core Formation owner, L3: defence +30 %, burn 60 stones. Below `trigger_burn` the array does not trigger.

### F6. Reservation cost

The diagram_reservation formula is defined as:

`reserved = reserve_share[d] × (1 − min(reservation_efficiency, 50) / 100)` of maximum linh lực; usable maximum = `qi_max × (1 − Σ reserved)`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| reserve_share[d] | float | 0 to 0.30 | diagram record (authored per formation) *(guess)* | The share the specific formation holds; 0 for the default line |
| reservation_efficiency | float | 0–50 | Combat Defence & Healing Formulas C | Capped at 50 % there |
| reserve_cap | float | 0.90 | Combat Defence & Healing rule 10 | Total across diagram and wards |

**Output Range:** 0 to 0.30 held per diagram (0.15 with 50 % efficiency). **Example:** a 5-node ring with `reserve_share` 0.12 and 25 % efficiency holds 0.09 of `qi_max`; at `qi_max` 1,000 the usable maximum is 910. **Boundary:** a diagram plus wards that total more than 0.90 effective cannot be set.

### Boundary and loop checks

- N=0 and L=0 cannot occur: a diagram has N ≥ 1 and L ≥ 1; a level-0 array is Unbuilt and has no effect.
- `formation_power_pct` at −50 % and S_min 0.25 keep a drained diagram from going negative; the +200 % case is bounded by S_max.
- **Positive loop:** stones → higher grade and level → stronger in fights → more loot and stones. It is intended, damped by `fuel_growth` > `level_growth`, by the realm-scaled fuel and by the unscaled negatives. The highest grade at the highest affordable level is not a free dominant purchase because fuel grows faster than strength.

## Edge Cases

**Diagram, laying and fuel**

- **If a diagram's N exceeds `slot_count`** (a bonus source ends, or the realm is lower than a taught diagram assumed): it cannot be set (so neither laid nor carried); the preparation screen warns first and the fight uses the default line. It is never truncated, because a diagram missing nodes breaks its links.
- **If the fuel is short when the player wants to lay a diagram in a foreseen fight**: the diagram is carried at the 70 % share and burns nothing. A foreseen fight in which the player chooses not to lay is the same: carried at 70 %, 0 burnt.
- **If a foreseen fight is declined, avoided or cancelled before it starts**: nothing is burnt. Fuel is paid when the fight begins, with the opening Breakdown. A fight that begins and ends at once (flight at t=0) has already burnt its fuel.
- **If a diagram's effective reservation plus the side's ward reservations would pass `reserve_cap`**: the diagram cannot be set (as a ward cannot be slotted); the preparation screen says which reservation to drop, and the fight uses the default line.
- **If the Trận Pháp skill cap falls below a diagram's level L**: the effective level is `L_eff` (rule 7, `min(L, cap)` without the keystone) for strength and fuel until the skill recovers; the stored level is not lowered.
- **If the keystone gives L above `max_level`**: effective L is `L_eff` (rule 7), at most `max_level + 2`, and both strength and fuel use it.
- **If a feed's target timer is already below `cooldown_min`**: the feed does nothing; it never raises a timer (rule 6).
- **If a crafted diagram is lost or sold while it is the Set diagram**: the loadout becomes the default line. A taught diagram cannot be lost.
- **If `formation_power_pct` is negative or very high**: S stays within `S_min` 0.25 and `S_max` 8.

**Nodes and links**

- **If a node is empty**: its rule and its links as a source are inert, its links as a target do nothing, and adjacency reads see "empty". A drawback cannot be dodged by an empty node, because the empty node still costs an art slot, and a rule that grants a bonus to neighbours needs an art in it to work.
- **If the art in a node is used up or killed mid-fight** (a talisman spent): the node counts as empty from then on.
- **If a feed's target is ready already**: nothing happens. **If it is cooling**: its timer drops by the amount, floored at `cooldown_min`.
- **If feeds form a cycle (A→B→A)**: each feed is one hop per instant; the second hop waits for the next firing.
- **If two sources feed one target in the same instant**: both apply in node-index order, with the floor applied after each.
- **If a gate node's condition is false**: its art stays ready and does not fire; it fires the moment the condition turns true. The basic attack always runs, so a fight can never stall on gates.
- **If a node scope names a tag** (an element or form): it is read from the art's compiled tags at compile time (Combat rule 6), so mid-fight tag changes do not move arts in or out of a scope. Guard-vocabulary conditions are live.

**Sides and places**

- **If both sides have a diagram**: each side's runs for that side only; there is no interaction unless an Effect says so.
- **If the fight is at the player's own abode**: the diagram and every standing home array count together, and their modifiers stack as ordinary Modifier System sources.
- **If a protective array is attacked by several raiders in one event**: it triggers once per event and burns once. **If the owner cannot pay `trigger_burn`**: it does not trigger and the event runs without it.
- **If several arrays' upkeep is unpaid on the same tick**: each drops one level, in array id order; none drops twice in one tick.
- **If a teleport array's owner refuses the character**: Travel & Map's rule applies (the jump is refused, nothing is charged).
- **If an NPC has no allowed diagram, or cannot afford the lay fuel**: it uses the default line, or carries (as for the player).

## Dependencies

| System | Type | Interface | State | Lists Formations? |
|---|---|---|---|---|
| Item Database (#13) | Hard | Item and affix rolling for crafted diagrams; array materials | GDD complete | Yes |
| Character Stats (#7) | Hard | Trận Pháp skill, Thổ purity, `formation_power_pct` as a stat key | GDD in review | Yes (its soft sources row 17) |
| Modifier System (#40) | Hard | Modifier node shape, `formation_power_pct`, `formation_upkeep_pct` | GDD approved | Yes |
| Effects System (#41) | Hard | Effect nodes, the keystone +2 levels, Earth Vein Tap | GDD approved | Yes |
| Combat (#21) | Hard | Takes the diagram as the loadout; owns `slot_count`, share, guards, `cooldown_min` | GDD approved | Yes; rules 12 and 13 amended 2026-11-21 |
| Combat Defence & Healing (#21a) | Hard | Rule 10 reservation holds a diagram's `reserve_share` and caps the total; wards read half of `formation_power_pct` (Field Walls); protective array defence | GDD approved | Yes (rule 10 already allows other Effects to reserve) |
| Time & Turn (#4) | Soft | Yearly upkeep tick, season of a build | Built, no GDD | n/a |
| Regional Economy (#43) | Hard (out) | Every stone burnt booked in Formula H as `burn_formation`; NPC fuel aggregate | GDD approved | Yes (added 2026-11-21) |
| Travel & Map (#25) | Soft | Tụ Linh as a layer-1 work; teleport arrays, fee Formula K | GDD designed | Yes |
| Sects (#26) | Soft | Sect-owned arrays use the record; sects teach diagrams | GDD approved | Yes (added 2026-11-21) |
| Cave Abode & Home Works (#47) | Soft | The abode's slots and level ceiling for the standing arrays | Designed 2026-11-21, pending review | Yes |
| Cultivation Techniques (công pháp) | Soft | Taught diagrams | GDD in review | Yes (added 2026-11-21) |
| NPC Builds (#24) | Soft | Catalogue, fit score, diagram per NPC | Built, no GDD | n/a |
| Event Engine (#23) | Soft | Raids trigger protective arrays; `linh_thach_max` budgets | Built, no GDD | n/a |
| Game UI (#37) | Soft | Preparation screen shows the diagram | Not started | n/a |

**Circularity:** none added. Formations reads Combat's constants and exposes a diagram record; Combat compiles it and never writes back (systems index, circular dependency 2 and 4).

**Back-link owed (review 2026-11-21, rounds 1 and 2):** Cave Abode rule 14 should read "except Formations' standing arrays and diagrams", Cave Abode rule 8 should exclude standing arrays from the abode's seasonal works upkeep (their upkeep is Formations' yearly tick, rule 14), and Regional Economy's `burn_formation` row should add build and raise stones of every array kind and of diagrams (rule 17; jump fees stay in `burn_fees`). Back-link owed (round 3, restated round 4): Combat A2 already floors a scaled `art_speed_pct` at `cooldown_min`; nothing is owed there. Round 4: Cave Abode rule 11 should name standing arrays among the faded upkept works a claim loses (Formations rule 14). Not edited here.

Back-links added 2026-11-21 in Regional Economy (Formula H gains `burn_formation`), Sects and công pháp; Character Stats already listed Formations. Combat rules 12 and 13 were amended the same day (the diagram never competes under "one formation per side"; slot order is the node index).

## Visual/Audio Requirements

Today's surface is the Debug Terminal, so these are the terminal's needs plus intent for the Game UI (#37). Assets are deferred with that system. Art bible §1–4 are still placeholders; this section draws on §7 and the pillars.

- **Terminal.** The diagram prints as a numbered node list with each node's rule and polarity mark (`+`, `−`, `?` for conditioned), then its links (`1 → 2 feed 2.0 s`, `1 — 3 adj`). The Breakdown prints one line per node and link contribution; each feed that fires is one log line. Nothing depends on colour alone.
- **Game UI intent.** The diagram is drawn as round nodes on a small graph, reusing the Đạo Đồ node grammar (bronze ring frames, art bible §7.9; in-engine states only, §7.7). A node's polarity is a **shape mark** in the ring (plus, minus, a condition glyph), backed by colour. The slotted art's icon sits inside the node (§7.2). A **feed** is an arrow and **adjacency** a plain line. A carried diagram is drawn dimmed with its share printed. The reservation shows as a locked segment of the linh lực bar.
- **Events that need a visual and a sound later:** laying (stones burnt), a feed firing (a pulse along the arrow), a gate opening, a protective array triggering, an array losing a level to unpaid upkeep.

## Game Feel

The fight is read, not played, so feel means preparation and clarity. **The moment that matters is seeing an arrangement pay off:** a feed chain firing and the centre art going off early.

- **Before the fight:** placing arts in nodes is a small puzzle: strong arts in positive nodes, cheap ones carrying the drawbacks. The screen shows the price of each choice at once: fuel, reservation and the share.
- **During the fight:** feeds and gates are logged by name, so the player can follow why an art fired early or waited.
- **After the fight:** the fight log shows what the diagram did: each feed that fired (source, target, seconds), the lay fuel burnt, the share and the linh lực reserved. A loss should point at a node choice the player can change. A per-node tally of contribution is tracked for the UX spec (Open Question 9), not a rule here.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Diagram collection | Known diagrams: shape, N, grade, level, `reserve_share`, source (crafted or taught), and whether N ≤ `slot_count` | Choose the Set diagram; open a diagram's details |
| Preparation (diagram editor) | The nodes and links, each node's rule and polarity, the art in each node, plain slots after them, the lay fuel against the stones held, the reservation against `reserve_cap`, and the share for this situation | Place and swap arts in nodes; lay or carry; warn when N > `slot_count`, fuel is short (carried at 70 %), or the cap would be passed |
| Fight log | Feed lines (source, target, seconds) and gate openings | Open a node's Breakdown line |
| Abode arrays | Each array's level, effect, yearly upkeep, next raise cost and the skill cap | Build or raise an array; raise a diagram's level |

All of these work in the Debug Terminal first, with numbered menus as elsewhere. Teleport use stays on Travel & Map's travel screen.

> **📌 UX Flag — Formations:** this system has UI requirements. In Pre-Production, run `/ux-design` for the diagram editor and the abode-arrays screen before writing epics. Stories that touch this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | References | What |
|---|---|---|
| Rules 3, 4 | Combat rule 13, Formulas A2 | `slot_count`, slot order (amended 2026-11-21: node index), kind-locked slots |
| Rules 9, 10 | Combat rule 12 | Situations, `carried_ground_share`, one formation per side (amended 2026-11-21: the diagram plus one ground object) |
| Rule 9a, F6 | Combat Defence & Healing rule 10, Formulas C | Reservation, efficiency, `reserve_cap` |
| F5, Interactions | Combat Defence & Healing (Field Walls) | Half of `formation_power_pct` as ward strength |
| Rule 5 | Combat rule 13 guards; Effects System | The guard vocabulary; Effect node records |
| Rule 5, F1 | Modifier System | Modifier node shape; `formation_power_pct`, `formation_upkeep_pct` |
| Rule 7 | Effects System / Đạo Đồ keystone | Formation Within a Formation (+2 levels); Earth Vein Tap |
| Rule 8 | Item Database; Cultivation Techniques | Affix rolling; taught diagrams |
| Rules 13, 14, F3 | Quick spec `design/quick-specs/luyen-khi-and-tran-phap.md` | Build cost, upkeep, skill cap (unchanged) |
| Rule 14 | Travel & Map rule 27 | Tụ Linh as a layer-1 work |
| Rule 15 | Travel & Map rule 11, Formula K; Sects | Teleport fee, access |
| Rule 17 | Regional Economy Formula H | Sink ledger, `f_burn` |
| F2, F5 | Travel & Map K (`events_budgets.json`) | `linh_thach_max` by realm |

## Acceptance Criteria

**Core rules**

- **AC-FO-01** [Logic] Rules 1, 2. **GIVEN** a combatant with no diagram, **THEN** it uses the default line: `slot_count` plain nodes, no rules, no links, fuel 0, and its fight is identical to Combat rule 13's result for the same loadout.
- **AC-FO-02** [Logic] Rule 3. **GIVEN** `slot_count` 5 and a 3-node diagram, **THEN** the pool is 3 diagram nodes plus 2 plain slots, 5 arts in all. **GIVEN** a 6-node diagram and `slot_count` 5, **THEN** it cannot be set (neither laid nor carried), a warning shows, and the fight uses the default line. Kind-locked slots stay outside both.
- **AC-FO-03** [Logic] Rule 4. **GIVEN** arts A, B, C in nodes 1, 2, 3 with equal timers and too little linh lực for all three, **THEN** they pay in node order 1, 2, 3, and plain slots pay after them in the player's order.
- **AC-FO-04** [Logic] Rule 5. **GIVEN** a diagram laid at S = 1 (share 1.0) with an Effect node "the art fires one extra time below 40 % health", **THEN** only its art fires twice at 39.9 % health and once at 40.0 %. **GIVEN** a Modifier node (+25 % `art_speed_pct` on its art), an Effect node and a gate node ("fires only at or above 50 % health"), **THEN** each acts only on the art in its node (a +25 % `art_speed_pct` node takes a 10 s art to 8 s, 10 / 1.25, and leaves its neighbours at 10 s); the gated art stays ready at 49.9 % health and fires on the first instant health is ≥ 50 %. **GIVEN** every art gated and false, **THEN** the basic attack still fires.
- **AC-FO-05** [Logic] Rule 6. **GIVEN** a diagram laid at S = 1 with a feed of 2 s from node 1 to node 2 and node 2's art cooling with 6 s left, **WHEN** node 1's art fires, **THEN** node 2 has 4 s left (a feed scales like any positive number: at S = 2.44 it takes 4.88 s). **GIVEN** `cooldown_min` 0.5 s and its timer 1.0 s, **THEN** it stops at 0.5 s; **GIVEN** its timer 0.3 s, **THEN** it stays 0.3 s (a feed never raises a timer). **GIVEN** its art is ready, **THEN** nothing changes. **GIVEN** feeds 1→2 and 2→1, **WHEN** node 1 fires, **THEN** node 2 is fed once and node 1 is not fed again in that instant.
- **AC-FO-06** [Logic] Rule 6. **GIVEN** an adjacency node "+X while a linked slot holds a Fire art", **THEN** the bonus applies with a Fire art linked and not with an empty or non-Fire neighbour, and no timer moves.
- **AC-FO-07** [Logic] Rule 8. **GIVEN** a crafted diagram at grade cap 2, **THEN** every rolled node is within grade 2's range and the roll is deterministic for the seed. **GIVEN** a taught diagram, **THEN** it is identical for everyone who learns it and starts at L1.
- **AC-FO-08** [Logic] Rule 9. **GIVEN** a foreseen fight, a Core Formation owner (budget 5,000), N=5, grade 2, L3 and enough stones, **WHEN** the fight begins, **THEN** exactly 288 stones are burnt and magnitudes count at 100 %. **GIVEN** an ambush, **THEN** 0 burnt and share 0.7; **GIVEN** blind, 0.5. **GIVEN** a foreseen fight with 100 stones, **THEN** the diagram is carried at 0.7 and 0 burnt. **GIVEN** a foreseen fight, enough stones and the player chooses not to lay, **THEN** 0.7 and 0 burnt.
- **AC-FO-09** [Logic] Rule 9, edge. **GIVEN** a foreseen fight declined before it starts, **THEN** 0 stones are burnt.
- **AC-FO-10** [Integration] Rule 10. **GIVEN** a fight away from home with both sides laid, **THEN** each side counts exactly one diagram. **GIVEN** a fight at the player's abode with Hộ Sơn L3 standing, **THEN** the diagram and Hộ Sơn both count as separate Modifier sources.
- **AC-FO-11** [Logic] Rule 11. **GIVEN** a laid diagram with two non-zero nodes and one feed that fires, **THEN** the opening Breakdown has a line for each node and link contribution, and the fight record has one entry per feed with source, target and seconds taken off.
- **AC-FO-12** [Logic] Rule 12, F4. **GIVEN** an NPC allowed diagrams with fits 4, 7 and 7 (the latter two with 5 and 6 nodes), **THEN** it takes the 5-node one. **GIVEN** the best fit at or below `fit_min` (0, including exactly 0), **THEN** the default line. **GIVEN** its purse below the lay fuel, **THEN** it carries.
- **AC-FO-13** [Logic] Rules 13, 14, F3. **GIVEN** Tụ Linh at L2 with Thổ purity 75 (inputs from the quick spec `luyen-khi-and-tran-phap.md`: `upkeep_lt_per_level` 10, 0.4 % cut per purity point), **THEN** the cost to reach L2 (rule 13's build/raise cost) is 375 stones (L1 is 150) and the upkeep is 14 a year. **GIVEN** the yearly tick with upkeep unpaid, **THEN** it drops exactly one level, and a level-0 array is Unbuilt.
- **AC-FO-14** [Integration] Rule 15. **GIVEN** a Core Formation traveller jumping 450 tiles on a sect array, **THEN** the fee is 1,375 (Travel & Map K), `f_burn` of it is burnt, and Formations charges nothing further.
- **AC-FO-15** [Logic] Rule 15, F5. **GIVEN** a protective array at L3, Core Formation owner, **WHEN** it triggers once for an attack by three raiders, **THEN** defence +30 % (33 % at power +20 %), 60 stones burnt once. **GIVEN** the owner has 59 stones, **THEN** it does not trigger and burns nothing.
- **AC-FO-16** [Integration] Rule 17. **GIVEN** a span that contains a yearly upkeep tick, a laid diagram, an array raise and a protective trigger, **THEN** `burn_formation` in #43 Formula H rises by exactly lay fuel + raise stones + upkeep + trigger burn (one summed sink; a jump fee is not in it, it stays in `burn_fees`) and `ΔM = F_mine − sinks` still holds.

**Formulas (boundaries) and edge cases**

- **AC-FO-17** [Logic] F1. **GIVEN** grade 2, L3, power +20 %, **THEN** S = 2.44 (±0.01); a +10 node is +24.4 laid and +17.1 in an ambush. **GIVEN** grade 0, L1, power 0, **THEN** S = 1.0. **GIVEN** power −50 % (grade 0, L1), **THEN** S = 0.5. **GIVEN** the clamp unit-tested directly with an unclamped value of 0.1, **THEN** S = 0.25. **GIVEN** grade 4, L7, power +100 %, **THEN** S is clamped to 8.
- **AC-FO-18** [Logic] F1. **GIVEN** a negative-polarity node of −15 % at S = 2.44, **THEN** it stays −15 % laid and −10.5 % in an ambush (drawbacks are unscaled by S, scaled by share). **GIVEN** a positive-polarity −20 % `art_cost_pct` node at S = 2.44, **THEN** it is −48.8 % laid (polarity, not sign, decides; inside `art_cost_pct`'s 0 to 0.5 reduction bound). **GIVEN** a +25 % `art_speed_pct` node at S = 8 on a 1 s art, **THEN** the scaled +200 % gives 0.33 s, floored at `cooldown_min` 0.5 s.
- **AC-FO-19** [Logic] F2. **GIVEN** N=1, grade 0, L1, Qi Refining, **THEN** fuel is 1 (the ceil). **GIVEN** N=7, grade 4, L5, Core Formation, **THEN** 2,294. The calculation (with F2's `− 1e-6`) must give exactly 288 for AC-FO-08, not 289 from floating-point error. **GIVEN** N=7, grade 4, L7, Core Formation, **THEN** 5,873.
- **AC-FO-20** [Logic] Edge. **GIVEN** Trận Pháp skill 1 (cap 2) and a diagram stored at L4 without the keystone, **THEN** strength and fuel use L=2 and the stored L is 4. **GIVEN** skill 6, `max_level` 5, the keystone and a stored L7 (reachable: F3 allows cap + 2), **THEN** L=7 is used; **GIVEN** the same diagram without the keystone, **THEN** L=5 is used and the stored L stays 7. **GIVEN** skill 1 and the keystone with a stored L4, **THEN** L_eff = min(4, 2 + 2) = 4.
- **AC-FO-21** [Logic] Edge. **GIVEN** a node with a −20 % drawback left empty, **THEN** the drawback does not apply but the slot holds no art, so the diagram loses one art against a full one.
- **AC-FO-22** [Logic] Edge. **GIVEN** a Set crafted diagram sold, **THEN** the next fight uses the default line; a taught one stays known.

**Reservation**

- **AC-FO-24** [Logic] Rule 9a, F6. **GIVEN** a diagram with `reserve_share` 0.12, 25 % efficiency and `qi_max` 1,000, **THEN** 90 points are held from t=0 and the usable maximum is 910 whether the diagram is laid or carried, and art costs stay a share of the full 1,000. **GIVEN** the default line, **THEN** nothing is held.
- **AC-FO-25** [Logic] Rule 9a. **GIVEN** the same diagram laid at S = 2.44 and carried in a blind fight at share 0.5, **THEN** the reserved amount is 90 points in both.
- **AC-FO-26** [Integration] Rule 9a, Combat Defence rule 10. **GIVEN** wards reserving an effective 0.80 and a diagram reserving 0.12 effective, **THEN** the diagram cannot be set and the fight uses the default line. **GIVEN** efficiency above 50 %, **THEN** 50 % is used.

**Screens**

- **AC-FO-23** [UI] **GIVEN** the preparation screen with a diagram set, **THEN** a screenshot in `production/qa/evidence/` shows the node shape, each node's rule, links (feed arrows distinct from adjacency lines without relying on colour alone), the fuel cost and the share; a fuel shortage shows "carried at 70 %".

**Gaps noted (not criteria):** balance targets (fuel about 5 % of a realm's budget per fight, the S spread) are checks for the balance harness (#33); the catalogue's content (how many diagrams, their node rules) needs a content audit once authored; F4's greedy placement needs the first catalogue to test precisely.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | **Closed 2026-11-21:** Combat rules 12 and 13 amended (the diagram never competes under "one formation per side", which now picks one ground object besides it; slot order is the node index) | user + Combat | Done |
| 2 | **Closed 2026-11-21:** back-links added in Regional Economy (with `burn_formation` in Formula H), Sects and công pháp; Character Stats already listed Formations | user | Done |
| 3 | Combat Formulas B's L4 "typical +20 from formations": ground-laid L4 formations now come only from node rules and home arrays. Does the typical +20 still hold? | Combat + harness | With the first catalogue |
| 4 | The first catalogue: how many diagrams, their shapes, node rules, `reserve_share` and `cost_lt[grade]` | user (hand-authored) | Before implementation |
| 5 | Crafting: node count range by grade and the pool of rolled node rules | Item Database + Formations | With the first catalogue |
| 6 | Starting values (`grade_mult`, `level_growth`, `fuel_frac`, `fuel_growth`, `trigger_frac`, `reserve_share`), and a diversity check: no single diagram (the default line excepted) is Set by more than `diagram_share_max` (guess 25 %) of NPCs at any realm, so the catalogue keeps distinct builds (Pillar 1) | Balance Harness (#33) | Harness pass after the catalogue |
| 7 | Which Event kinds count as an attack that triggers a protective array, and whether sect-seat arrays matter while sect wars stay abstract | Events + Sects | With the Sects follow-up |
| 8 | May the Advisor preset a different diagram for ambush and blind fights than for foreseen ones? | user | Before the preparation UX spec |
| 10 | Should a feed ever be able to make an art ready at once (no remaining-timer floor), so a chain can fire the centre art in the same instant? Today a feed floors at `cooldown_min` (rule 6, round 1 decision) | user + Combat | With the first catalogue and the harness |
| 9 | A per-node contribution tally after a fight (seconds fed, extra fires, gate waits) so the result can name the strongest node | UX + Combat | With `/ux-design` for the diagram editor |
