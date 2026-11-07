# The Held Door (Trì Môn)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Two wards at once, and what that breaks." Order 4: 2 or more new wards, a report on rule 22, set in a plague ward, fear as the mood.
> **Direction**: The seed is kept and turned. Two wards on one body lost in every reading tried, so the second ward stands around the enemy instead: a sealed sickroom, held shut from outside. Both readings are run and reported.
> **Realm span**: Qi Refining – Foundation Establishment, defined at Qi Refining · **Power level**: ordinary · **Use**: player build, or a frightened nurse the town owes everything
> **Fit**: 5 Fits today · 7 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: the status lint is passed on paper and broken by the seal, on purpose, and the stats below come to about 118 W against the 106 anchor)

## The Spine

- **The channel:** ticks, inside every ward, on L1 to L4. 82 % of the damage in the mixed fight.
- **The enabler:** Twin Wards (Song Hộ), the catalogue's keystone, which breaks "one ward at a time". It closes your own hits, which the sealed room stops as well.
- **The loop:** shut the room, get three sicknesses in, and pay to keep the door shut until it is over.
- **The engine:** Formulas F prices a status by `c_tick · duration`. A status that lasts two pulses is cheap. Inside the sealed room durations do not run, so the cheapest, sharpest fever never breaks.
- **The sacrifice:** the basic attack and every art hit lose 32 %. No burst, no fighting upward, and a pool that must never fall below the room's upkeep.
- **The arc:** at Qi Refining a sitter who found out what a closed door does. At Foundation, a fourth fever and a little less fear.

## The Legend

Bùi Cẩn sat nights at the fever-house of a garrison town, carrying water and changing cloths, and they were afraid every hour of it. They had a Qi Refining root and one ward a fortune-teller had sold them. In the second month the physician ran. By then they knew what the soldiers did not: a sickness kept in a room with the door shut does not break and does not leave. So the town was saved by someone shaking too hard to lift the bar, who lifted it, and held the room closed with their own breath for twenty-two days while the people inside called to them by name.

They are still frightened. They wash in vinegar until their hands crack. They learned that what they did to a house they can do around one person, and they only do it to those who come for the town. They stand outside it and say they are sorry, and they stay until it is finished, because the physician did not. They check every door twice at night.

## How It Fights

The Sealed Room shuts at t = 0, and the enemy's own regeneration stops with it. At 1 s Sweat, Chill and Flux go in together, and again at 2 s. Each is a two-pulse sickness that should be gone by 4 s. None is. From then on no art fires: Cẩn will not cast below 60 % of their pool, so all that is left is the Vinegar Cloth paying for each blow and the room paying for each pulse, while Widening Wound opens the cap from 8 % toward 15 %. The enemy's bar falls by 13, 10, 14, 15 and then 16 points a second.

**Signature moment:** at 5 s you have cast nothing for three seconds, you are on 62 %, and a sickness that should have ended at 4 s is taking the enemy down faster than it did. You cannot stop now. If the door falls, all of it ends.

## Enabler

**Twin Wards (Song Hộ).** Catalogue keystone, unchanged in its promise: "a second ward stays up at half strength." Read here as: only half of each hit meets the second ward. A second ward may stand on you, or, with a ward made for it, around the enemy.

## The Wards

| Ward | Model | Pass, body / qi | Cost | Stands | Fit |
|---|---|---|---|---|---|
| Sealed Room (Cách Ly Hộ) | Per pulse | 0.55 / 0.55 | `upkeep_share` 0.03 | Around the enemy. Hits out and hits in both meet it | Needs rule |
| Vinegar Cloth (Thố Cân Hộ) | Per hit | 0.34 / 0.24 | `hit_cost_share` 0.04 | On you. The ward slot's spell | Needs key |
| Soiled Gown (Ô Y Hộ) | Drain | 0.55 / 0.45 | Drain 1.2 / 1.5 | On you, over a first ward. The literal reading, for the tests | Needs key |

**Nothing Leaves (Bất Xuất), on the Sealed Room.** While it stands, statuses you applied to the enemy do not lose duration, and the enemy does not regenerate. If it cannot be paid at a pulse it falls for the fight, and every status you applied ends at once. Only a door's holder pays. Ticks are inside any ward already (Formulas F), so the room never stops them.

Two fixed prices are why the pair works. With a drain ward inside (`drain-inner`) the fight is lost at 7 s with the enemy on 12 %: the pool goes on what the blows weigh. With the Cloth, Cẩn can count what is left.

## The Stack

Plain rows, all of them on the ward. There are no damage rows. Two stacks of c_tick 0.5 reach every cap at this realm, so `damage-rows`, with +50 and +30 on the sicknesses, is the same fight to the point: 8 s on 28 %. The Second Sickness's path was tried here and cut. A player who knows this spends nothing on damage and everything on holding on.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | c_tick 0.5, duration 2 | The top of Formulas F's range, for the shortest time | Flat base | tick | none | ○ | Art | any short status |
| Past the cap | Widening Wound (Khoát Thương) | Half of what the pulse cap clips adds to it, to 15 % with three sicknesses | Overflow | tick | none | ◐ reused | Capability | Thousand Scales |
| Fuel | Maximum linh lực, Regeneration | Plain rows, +40 and +1 | Increased | any | none | ● | Tree | everyone |
| Survival | Ward strength, Ward efficiency, Body guard | Plain rows, +25, +25, +10, with gear making ws and we 50 | Increased | any | none | ● | Tree | everyone |
| Identity | Nothing Leaves (Bất Xuất) | Above | Rule swap | tick | none | ○ | Ward | any curse build, any holding formation |

**Identity piece:** the Sealed Room. `--without twin_ward` loses at 8 s with the enemy on 33 %. With the room and no seal (`no-seal`) it loses at 12 s with the enemy on 45 %, so a second ward alone buys time and no win. The same ward on your own body (`self-pulse`) also loses, at 14 s, enemy on 30 %.
**The plain test:** with 20 less linh lực and 20 less on each ward stat (`lean-wards`) the home fight is 8 s on 14 %, half the health left. The rows are what the margin is made of.
**Unplanned reuse:** Widening Wound was written for seven wounds on a blade. Here it is three fevers in a shut room. `--without widening_wound`: 11 s on 12 %, where the home fight is 8 s on 28 %. `--without flux`, its third status: 10 s on 14 %.
**Empty rungs:** Crit and Reach do not apply to ticks. L5 is empty, a sacrifice: ticks do not read it. Rate is a sacrifice: nothing fires after 2 s.

| Layer | Points at Qi Refining | Multiplier | Sources |
|---|---|---|---|
| L1 | 0 | ×1.00 | Sacrifice: past the caps, it buys nothing |
| L2 | 0 | ×1.00 | The same |
| L3 | 15 | ×1.15 | Gear |
| L4 | 0 | ×1.00 | The same, and no coatings at this rank |
| L5 | 0 | ×1.00 | Ticks do not read it |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any plain root | Nothing here asks for one. A nurse has what they were born with |
| Key talents | None | The path is the tree |
| The Way (Đạo) | None | |

## Công Pháp

### Night-Sitter's Method (Thủ Dạ Quyết) — main, Hoàng giai

Breathing for someone who must stay awake in bad air.

```json
{"id": "thu_da_quyet", "name": "Thủ Dạ Quyết", "tier": 0, "tech_kind": "main",
 "names": ["moc"], "layers": 6, "bonuses": [],
 "abilities": [{"ability_id": "sweat", "unlock_layer": 1},
               {"ability_id": "chill", "unlock_layer": 2},
               {"ability_id": "flux", "unlock_layer": 4}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 0 of 1, no bonuses, reaches Foundation.

## Arts

| Art | Kind, tags | c_art | Cost | Cooldown | Guard | Status | Fit |
|---|---|---|---|---|---|---|---|
| Sweat (Hãn Chứng) | Qi, poison | 0.6 | 0.05 | 1 s | Own linh lực 60 % or above | Body tick, c_tick 0.5, 2 pulses | Needs key |
| Chill (Hàn Chứng) | Qi | 0.6 | 0.05 | 1 s | The same | Qi tick, the same | Needs key |
| Flux (Tả Chứng) | Qi | 0.6 | 0.05 | 1 s | The same | Body tick, the same | Needs key |
| Ague (Ngược Chứng) | Qi | 0.6 | 0.05 | 1 s | The same | Qi tick, the same. Foundation | Needs key |

Each passes Formulas F's lint on paper: 0.5 × 2 = 1.0, under 1.2 × 1.6. In the home fight each ticks seven times.

## What Breaks in Rule 22

Each row is a saved variant. Run them with `fight_x.py`.

| Rule 22 or Formulas D says | What two wards do to it | Evidence |
|---|---|---|
| "One ward is up at a time" | The sentence must go, and with it the firing order a ward art, a slot and the default share. Nothing says if the default ward can be a free second | Rule text |
| Nothing, on order | Which ward meets the hit first changes everything. Per-hit outside, drain inside: alive at the 40 s limit on 11 %. The same pair swapped: dead at 18 s | `order-hit-outer`, `order-drain-outer` |
| `pass_min` 0.05: "a ward never blocks everything" | The floor is per ward. A pair at ws 400 passes 0.068 × 0.068. A 3.6 blow takes 6 % of health through one ward, 1 % through two | `floor-one`, `floor-two`, `--timeline`, at 6 s |
| "A per-hit ward pays for each hit" | Two per-hit wards pay twice from one pool: the pool at 12 s is 58 % against one ward's 94 % | `floor-one`, `floor-two` |
| "Ward strength" and "ward efficiency" "act on any ward" | Both count on both wards. "Half strength" has two readings (half of each hit, half of ws and we) and full strength is a third. Here they barely differ: 50, 53 and 50 % of the enemy left, all lost at 6 s, because the pool decides it | `self-block`, `self-stats`, `self-full` |
| `curse_pass_raise_max` ×1.5 | Each ward reads the curse, so a pair takes ×2.25. Two wards under a curse lost at 8 s with the enemy on 45 %, worse than one ward at 8 s with the enemy on 33 % | `curse-self`, `curse-one` |
| Up "while its cost can be paid" | With regeneration above upkeep (0.03 against 0.02) a per-pulse ward can never fall. Only a curse that blocks regeneration brought the door down, at 5 s | `drainer-strong` |
| Formulas F's lint, `c_tick · duration` | A lint on a duration assumes the duration runs. The seal is one sentence that deletes it. The same family as Forum Build's finding | `no-seal` against `mixed` |
| Ward text assumes one body | Rule 22 never says whose ward a ward is. A ward around the enemy is legal in nothing and forbidden by nothing | Rule text |
| Formulas K, rule 16 | The rating profile and the hit log each read one ward | Unmodelled |

**The short answer:** the one-ward rule was not holding up very much. A second ward on one body, in the fights tried, loses, because it spends the pool that was already the limit. What needs a ruling is order, the floor and the curse cap, and whether a ward may stand on the other person.

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm | Wins, 8 s on 28 % | The 6 s volley takes 21 points, and the Cloth pays one hit's price for the heavy art |
| One jab and nothing else (`jab`) | Wins, 8 s on 47 % | Small hits are the Cloth's weak side, and it still holds |
| Abroad, foreseen (`abroad`) | Wins, 8 s on 28 % | No ground piece, so the result is the mixed fight's. The room goes wherever the holder goes |
| A curse on ward pass (`curse-room`) | Wins, 8 s on 13 % | The room still stands. Two on one body lost this |
| Drainer (`drainer`) | Wins, 8 s on 46 %, pool 0 | Regeneration pays the door |
| Drainer that blocks regeneration (`drainer-strong`) | Loses at 6 s, enemy on 60 % | The door falls at 5 s and the sickness ends. If it did not end (`no-door-falls`): enemy on 41 % |
| A cleanser (`cleanser`) | Loses at 17 s, enemy on 14 % | The enemy purges itself every 4 s. It very nearly works anyway |
| Mixed, one up | Loses at 5 s, enemy on 76 % | Blows too large for this pool |
| top_end | Loses at 1 s | |

**Counter:** a cleanse art, or a curse that blocks regeneration. Both are ordinary Rule 18 enemies.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Art lint within, slots 3 of 3, technique 0 of 1. The status lint passes on paper and is what the seal breaks, so a pass would be false. About 118 W against 106, over by a tenth |
| Validity | PASS | Tier 0 reaches Foundation. Pass values inside Formulas D's 0.2 to 0.55. `upkeep_share` and `hit_cost_share` inside 0 to 0.10 |
| Stack | PASS | Five forms: Flat base, Increased, Overflow, Rule swap, and Trade in the door |
| Scaling | PASS | m_static 1.15 against typical 3.27. Ticks at the cap do not need M at this realm |
| The fight | PASS | The loop happens. `dot_pool_cap` clipped 18 times, `dot_pulse_cap` 8, Widening Wound 7 pulses. The door never falls at home |
| Reuse | PASS | Twin Wards, Widening Wound and 5 plain rows reused |
| NPC use | PASS | Two ward records and three arts. A sect's quarantine officer |
| Counterplay | PASS | `cleanser`, `drainer-strong` |
| Originality | PASS | Nothing taken from another work |

## Fight Results

Input: `sheets/held-door.fight.json`, plug-ins `twin_ward` and `widening_wound`. A paper model.

| Enemy | Gap | Result | Time | Own health, pool | Enemy health |
|---|---|---|---|---|---|
| typical | 0 | Win | 8 s | 50 %, 40 % | 0 |
| typical | 1 | Loss | 4 s | 0, 50 % | 82 % |
| typical | 2 | Loss | 2 s | 0, 58 % | 98 % |
| top_end | 0 | Loss | 1 s | 0, 78 % | 97 % |
| top_end | 1 | Loss | 1 s | 0, 78 % | 99 % |
| top_end | 2 | Loss | 1 s | 0, 78 % | 100 % |

Second realm: `held-door-foundation` wins at 7 s on 60 %, `held-door-foundation-mixed` at 7 s on 44 %, and one up it loses at 5 s, enemy on 76 %.

**Unmodelled:** the room's bar on an escape channel (this enemy never flees) and how Twin Wards rates in a mass battle.

## New Concepts

**A ward on the other person.** Rule 22. Bounds: one such ward, paid only by its holder, falling for the fight when unpaid. Breakdown line: "Sealed Room: 32 % of this hit stopped, paid by Bùi Cẩn". Other users: a healer who wards an ally (Sweet Ward's second home), a jailer sect. NPCs can use it.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Twin Wards | Needs rule | Rule 22: the catalogue's keystone, plus order, floor and curse rulings above |
| Sealed Room with Nothing Leaves | Needs rule | Rule 22 and Formulas F: a ward on the enemy, and durations that stop |
| Widening Wound | Needs rule | Already proposed by Thousand Scales |
| Vinegar Cloth, Soiled Gown, four arts, technique | Needs key | Ward records and the arts catalogue |

## Questions

- Should `pass_min` be read on the pair? One line would close the floor.
- Should a lint on `c_tick · duration` count the duration that actually runs? This is Forum Build's "a wait is paid, never deleted", and it may want one sentence for both.
- Should a Sealed Room stop an escape? Best Plan's coward would have nowhere to go, and the rule would want a limit.

## Also Considered

- **The Gown and the Sheet:** two wards on one body, doffing the outer to shed curses. The literal seed, and the tests show the pool cannot pay for it.
- **Triage:** each hit goes to whichever ward is cheaper. Clever, and fear does not triage.
