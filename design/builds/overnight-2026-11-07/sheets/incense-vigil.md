# The Incense Vigil (Hương Thủ Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A stalemate counts as a win: the immovable saint who only has to last."
> **Direction**: The seed is kept and given a price. Every blow becomes a slow wound, Combat's own tick cap protects the saint from anything, and what the wound cannot collect in time is paid in years of life. A saint's real health bar is their lifespan.
> **Realm span**: Foundation Establishment – Nascent Soul, and no further · **Power level**: strong at standing, nothing at winning · **Use**: player build, or a sect's gate guardian
> **Fit**: 6 Fits today · 8 Needs key · 6 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức and Đạo node values not totalled. Scaling: the anchors measure damage, and this build has none)

## The Spine

- **The channel:** none. No damage reaches anyone. The win arrives at `time_limit`, by the Incense Vow.
- **The enabler:** the Incense Vow makes a stalemate a win when the other side came to you, and closes all your hits.
- **The loop:** stand. Each hit joins the ledger, the ledger pays a little each pulse, and small curses starve the enemy's arts so the ledger grows more slowly.
- **The engine:** Slow Wound turns hits into a tick, and ticks have a cap. Any blow, from anyone, takes at most 5 % of health a pulse. Still Sea cuts that by more than half while linh lực is full. So the ward, the thing every other build needs, is what kills a saint: it drains the pool.
- **The sacrifice:** no knockouts, so no capability #9 and no bounty. It cannot start a fight. It cannot cross Heavenly Tribulation. Every hard fight costs decades.
- **The arc:** a keeper who holds a gate with a ward up. Then a saint who switches the ward off, ages a century in a season, and finally stops at the door of Deity Transformation because Heaven does not honour incense.

## The Legend

In the old duelling law of the river counties, a challenger lit one stick. If the one challenged still stood when
it fell, the challenge had failed, and no one might lift a hand against them again that year. It was meant to spare
the weak. Then a gate-keeper of a poor sect learned to stand through anything, and found out what standing costs.

The keepers of the law still hold mountain passes, and they are easy to know: thirty years old by their sect's
records, and white-haired. Those who send them against a stronger enemy know the sum in advance, and so do the
keepers. Several have won a duel, bowed, and died of old age on the spot. Nobody has ever called that a loss.

## How It Fights

The saint does nothing that looks like fighting. Blows land and nothing seems to happen, except that they grow
slightly paler each second. The attacker spends everything and the saint's pool never moves, because the ward is
off. The stick burns down. **The signature moment:** a Core Formation keeper stands the full forty seconds against
a top-end Nascent Soul elder and wins by law, and the owed 962 years fall due as the ash drops. A Core Formation life holds 500.

## Enabler

**Incense Vow (Hương Thệ).** The keystone of the Way of Keeping. Sworn, not found.

- **Opens:** a stalemate counts as a win for you when the other side is the requesting side (Combat rule 10). The
  one who comes must prove something, and the one who stands need only stand. A win here takes the success branch.
- **Closes:** your hits deal nothing, basic attack included. It cannot apply when you opened the fight, so a saint
  cannot hunt. Stalemates still fail a tribulation (Thiên Kiếp rule 8), which is the point.

## The Stack

Sizes on new modifiers are first guesses. A defensive build climbs the same ladder, read as "what reaches me".

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Maximum health (`khi_huyet_pct`) | Debts are shares of maximum health, so health saves years | Increased | any | none | ● | Tree, technique | thể tu builds |
| Rate | Short Stick (Đoản Hương) | Foreseen fights only: `time_limit` falls by half | Cap shift | any | none | ○ | Formation | any burst build hunting Late Bloom or a tick clock |
| Multiplier | Body guard (`body_guard_pct`) | +60, and every point shrinks the ledger | Flat | any | none | ● | Tree, armour | thể tu builds |
| Multiplier | Turned Blade (Đảo Phong) | With no hit to deal, half your L1 and L3 points add to `body_guard_pct`: +112 here. A saint carries a sword for its weight | Borrow | any | none | ○ | Đạo | any support with no attacks |
| Multiplier | Iron Marrow (Thiết Tủy) | Catalogue keystone: body guard rises as health falls | Per | any | none | ○ | Sealed cluster | catalogue |
| Certainty | Unyielding Breath (Bất Khuất) | Catalogue keystone: once per fight, a killing blow leaves 1 health. Here, it is the margin for the last pulse | Rule swap | any | none | ○ | Tree | catalogue |
| Past the cap | **Slow Wound (Hoãn Thương)** | Hit damage past ward and guard enters a ledger, not your health. The ledger pays at most `dot_pool_cap` of maximum health a pulse, after ticks, on its own cap | Rule swap | incoming | none | ○ | Technique | any tick clock that must outlive its own clock, as a partial share |
| Past the cap | Still Sea (Tĩnh Hải) | The Slow Wound cap falls by 0.55 × your linh lực share | Per | incoming | none | ○ | Sealed cluster | any Slow Wound user |
| Past the cap | Years Owed (Thọ Trái) | When the fight ends, each 100 % of maximum health left in the ledger costs 1 % of the realm's base lifespan, from your remaining years | Overflow | any | none | ○ | Technique | anything else a cap clips and a life could pay for |
| Past the cap | Fair Measure (Công Lượng) | 25 % fewer years owed | Increased | any | none | ○ | Đạo | any Years Owed user |
| Fuel | Regeneration (`linh_luc_regen_pct`) | +3 % a second: the pool must stay full | Flat | any | none | ● | Tree, Measured Breath | sustain builds |
| Fuel | Art cost (`art_cost_pct`) | −10 % | Flat | any | none | ● | Tree | sustain builds |
| Answers | Soul resistance, thần thức | `soul_res_pct` +30, sense ×2, the one thing that skips the ledger | Flat | soul | none | ● | Tree, Đạo | any soul defence |

**Identity piece:** Slow Wound. Without it (`--without slow_wound`) the same body dies in 5 s to a typical enemy one realm up.
**Empty rungs:** Crit and Reach are sacrifices: nothing is dealt. Evade is a sacrifice too: a saint is hit by choice.

Hit layers are empty on purpose, so `m_static` is 1.00. L1 and L3 are still bought, and Turned Blade spends them.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth and Wood, with the new Amber variant | Guard for the ledger; Earth meets the Đạo's requirement |
| Key talents | Physique, then Soul | Health, guard, then the soul answer |
| The Way (Đạo) | Keeping, proposed below | Holds the Vow |

**New root: Amber (Hổ Phách).** Origin: Convergence. Requirement: owns Wood and Earth. Resin caught in the ground:
an unused overcoming pair, like Thunder and Darkness. A derived variant reaches purity 80 at most.

| Key | Per purity | At 50 | At 100 | W at 50 | W at 100 |
|---|---|---|---|---|---|
| `body_guard_pct` | +0.45 | +22.5 | +45 | +22.5 (1 W a point is Combat's guess) | +45 |
| `cultivation_speed_pct` | −0.10 | −5 | −10 | −11 | −22 |
| **Total** | | | | **11.5 W** | **23 W** |

It sits in the 10 to 30 W band. **Its cost** is the second line: what is preserved does not grow quickly. It needs a
Meridian Map sector (rule 12).

## Công Pháp

### Standing Stele Sutra (Lập Bi Kinh) — main, Địa giai

A manual carved on a stele by someone who wanted to be read after they were gone.

```json
{"id": "lap_bi_kinh", "name": "Lập Bi Kinh", "tier": 2, "tech_kind": "main",
 "names": ["tho", "moc"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 15},
             {"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "slow_wound", "unlock_layer": 4},
               {"ability_id": "stale_incense", "unlock_layer": 7},
               {"ability_id": "closed_gate", "unlock_layer": 9},
               {"ability_id": "stilled_hand", "unlock_layer": 11}],
 "seal_clusters": ["unmoved_body"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/15 + 15/20 + 15/15 = 2.75 of 3.0. `dia` reaches Nascent Soul, which is as far as this path goes. Slow Wound's share is 50 % until layer 10, then 100 %. A body technique with `t_b` 3 takes an auxiliary slot.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Stale Incense (Trần Hương) | Sutra, 7 | qi, curse | 0 | 0.04 | 3 s | none | Needs key |
| Closed Gate (Bế Môn) | Sutra, 9 | qi, curse | 0 | 0.04 | 3 s | none | Needs key |
| Stilled Hand (Định Thủ) | Sutra, 11 | qi, curse | 0 | 0.04 | 3 s | none | Needs key |

- **Stale Incense.** **Effect:** the enemy's art costs rise by 50 % for 5 pulses. **Description:** Old smoke, hard to breathe.
- **Closed Gate.** **Effect:** blocks the enemy's regeneration for 5 pulses, so once dry they stay dry. **Description:** It was always going to close.
- **Stilled Hand.** **Effect:** locks one enemy layer for 2 pulses (`curse_layer_lock_max`). `rules/layer_lock.py` takes the enemy's largest layer, a first guess. **Description:** The arm is lifted. It does not fall.

None of these wins anything. Together they cut the years owed: against a top-end at the same realm with guard at 60, the first two take it from 497 years to 400 (`variants/incense-vigil-guard-60-no-curses.fight.json`, `variants/incense-vigil-guard-60.fight.json`), and each year saved is a year lived. Stilled Hand does more than either: at guard 172 it takes the same fight from 311 years to 169 (`variants/incense-vigil-stilled-hand.fight.json`), for a pool of 94 % instead of 98 %. The main file leaves it out, so the numbers below are for the first two curses.

## Loadout by Realm

The ward slot is the decision of the build, made before the fight (rule 22 lets a player switch it off).

| Stance | When | Against a typical one realm up | Against a top-end at the same realm | File, in `variants/` |
|---|---|---|---|---|
| Ward on, stick lit | Foreseen | Stands, 20 % health, owes 0.7 years | Stands, 8 % health, owes 177 | `incense-vigil-ward-on-short-stick.fight.json` |
| Ward off, stick lit | Foreseen | Stands, 57 % health, owes 10 | Stands, 57 % health, owes 187 | `incense-vigil-short-stick.fight.json` |
| Ward off | Ambush or blind | Stands, 11 % health, owes 16 | Stands, 11 % health, owes 311 | `sheets/incense-vigil.fight.json` |
| Ward on | Peers only: a same-realm typical costs 16 % of health and no years | Down at 26 s | Down at 23 s | `incense-vigil-ward-on.fight.json` |

"Ward on" is a common drain ward at ws 300, we 300.

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation | 4 | Stale Incense | On | Slow Wound at half share |
| Core Formation | 5 | Stale Incense, Closed Gate, Stilled Hand | By stance | Two slots hold soul and burn answers |
| Nascent Soul | 6 | As above | By stance | The last realm |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Short Stick (Đoản Hương Trụ) | Formation, prepared | new | Halves `time_limit`. It lets a ward survive to the end, and it halves the ledger. Lost in an ambush | Needs rule |
| Any armour | Artifact, body | `giap`, generated | `a_b` | Fits today |
| An undrawn sword | Artifact, weapon | Generated | L3 for Turned Blade, and only that | Fits today |

The Short Stick is the same strip of cedar the old law used, cut in half by people who had done the arithmetic.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Unmoved Body, sealed cluster | Below | Still Sea is the build | Needs key |
| 2 | Measured Breath (Điều Tức), from Ninth Bell | Regeneration | The pool must stay full | Needs key |
| 3 | Soul resistance notables | +6 | A soul-piercer is the worst day | Fits today |

### Hidden cluster idea: Unmoved Body (Bất Động Thân)

Theme: body refinement. Earth affinity, outer, sealed. Seal condition: a technique that lists it. Size 10, so two
notables, and no capability. The small acupoints give body guard, health and regeneration. The notables are
**Still Sea** and **Iron Marrow**. Any thể tu could want the body lines even with no Vow.

## Đạo

**Way of Keeping (Thủ Đạo), proposed.** New. **Requirement:** Earth at purity 40 and a `body` technique.
**`theme_stats`:** `body_guard_pct`, `khi_huyet_pct`, `linh_luc_regen_pct`, `soul_res_pct`, `lifespan_years`. Twenty nodes.

- **The Gate (Môn), 7 nodes:** standing in the way. `body_guard_pct` and `khi_huyet_pct` lines, ending in **Turned Blade** (T2).
- **The Held Breath (Bế Khí), 6 nodes:** the sea kept still. `linh_luc_regen_pct` and `soul_res_pct` lines, a T1 passive that gives a slotted curse art −1 s, and an art node for Stale Incense for those without the Sutra.
- **The Long Count (Trường Số), 6 nodes:** what standing costs. `lifespan_years` lines within Dao Formulas D1 part 4 headroom, ending in **Fair Measure** (T2).
- **Keystone: Incense Vow** (T3).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation | A tough gate-keeper, ward on, half share. Holds a peer at 55 % health and loses to one realm up in 10 s | Slow Wound at half | Holding the first gate |
| Core Formation | The real saint. Ward off stands up to anything, at a price | Full share, Vow, Still Sea | The first white hair |
| Nascent Soul | The same stance, with a 1,000-year purse | Stilled Hand | Standing at the last door, and not crossing |

**The end of the road.** Heavenly Tribulation clears only on a knockout, and a saint's hits deal nothing. They can
break the Vow, lose its keystone's power, and try to cross as a mortal with a very thick skin, or they can stay and
keep the gate for as long as they have years.

## Matchups

Ward off, 40 s, Core Formation, unless noted. Each row is read from `--matrix` on the file named, in `variants/` unless it says `main`, which is `sheets/incense-vigil.fight.json`. Years come from the `years_owed` line, before Fair Measure.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical, same realm | Wins, owes 1.6 years; ward on owes none | A peer barely fills the ledger | main; `incense-vigil-ward-on.fight.json` |
| Typical, one realm up | Wins, owes 16 | The defining fight | main |
| Typical, two realms up | Wins, owes 58 | Bad, and survivable | main |
| Top-end, same realm | Wins, owes 311 | Most of a life | main |
| Top-end, one realm up | Wins, owes 962, and dies of it | More than the realm's 500 years | main |
| Poisoner, one realm up | Loses, 17 s | Ticks go straight to health, beside the ledger | `incense-vigil-poisoner.fight.json` |
| Soul-piercer, one realm up | Loses, 7.5 s; 38 s with sense ×2 and `soul_res_pct` 30 | Soul skips everything, and the answer buys time without saving the fight | `incense-vigil-soul.fight.json`, `incense-vigil-soul-answer.fight.json` |
| Drainer, one realm up | Stands at 1 health, owes 26.5 | A falling pool raises the wound's cap. It is Down at 40 s without Unyielding Breath, which takes the last pulse | `incense-vigil-drainer.fight.json`; `--without unyielding_breath` |

**Counter:** a soul-piercer or a poisoner, and Burial Shroud is the natural predator. So is anyone who simply
declines to fight: the saint cannot make them. A drainer takes the saint to the last pulse and no further.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.75 of 3.0; arts have `c_art` 0, so the lint has nothing to check; slots 2 of 5 in the file. Thần thức and Đạo node values not totalled |
| Validity | PASS | Earth and Wood, `dia`, `giap`, every ● key; `lifespan_years` 15 is in the pool. Amber is in band |
| Stack | PASS | Seven forms. Identity test: `--without slow_wound` turns every stand into a knockout |
| Scaling | NOT ASSESSED | `m_static` 1.00 by design. Formulas B anchors measure damage, and nothing yet anchors a stall |
| The fight | PASS | Constants 60 of 60, selftest clean. `rules/slow_wound.py` and `rules/still_sea.py` run the engine against the real hits, with no stand-in. The Vow's check of who opened the fight is not simulated, so a stalemate is a win only on that condition |
| Reuse | PASS | Iron Marrow and Unyielding Breath from the catalogue, Measured Breath from Ninth Bell. Second homes named |
| NPC use | PASS | Passive, with one stance flag. One Breakdown line: "Blow deferred; 412 % owed." A guardian NPC is a natural use |
| Counterplay | PASS | Soul-piercer and poisoner each win at one realm up. A drainer does not, though it spends Unyielding Breath |
| Originality | PASS | The law, names and pieces are invented for this sheet |

## Fight Results

Input: `sheets/incense-vigil.fight.json`, rules `slow_wound`, `still_sea`, `incense_vow` and `unyielding_breath`. Observations from `_tools/fight_x.py`, a paper model, not the game. A `stalemate` is a win only under the Vow. A hit's dealt damage goes to a ledger. Each pulse pays `0.05 × (1 − 0.55 × pool share)` of maximum health.

Each cell is own health at the end, then the ledger left, as a share of maximum health. 100 % owed is 5 years here. Columns: the main file, then `variants/incense-vigil-short-stick.fight.json`, `variants/incense-vigil-ward-on.fight.json` and `variants/incense-vigil-ward-on-short-stick.fight.json`.

| Enemy | Ward off | Ward off, 20 s | Ward on | Ward on, 20 s |
|---|---|---|---|---|
| typical gap 0 | 11 %, owes 33 % | 57 %, 30 % | 84 %, 0 % | 91 %, 0 % |
| typical gap 1 | 11 %, 321 % | 57 %, 202 % | Down, 26 s | 20 %, 14 % |
| typical gap 2 | 11 %, 1,162 % | 57 %, 707 % | Down, 23 s | 9 %, 507 % |
| top_end gap 0 | 11 %, 6,227 % | 57 %, 3,746 % | Down, 23 s | 8 %, 3,545 % |
| top_end gap 1 | 11 %, 19,242 % | 57 %, 11,555 % | Down, 23 s | 8 %, 11,355 % |
| top_end gap 2 | 11 %, 61,384 % | 57 %, 36,841 % | Down, 23 s | 8 %, 36,640 % |

`--without slow_wound`, the same body with no Slow Wound: typical same realm Down at 33 s, one up at 5 s, two up at 2 s, top-end at 1 s.

**What the repair changed.** The ward-off columns came back exactly from the plug-ins. Three things moved. The stand-in in `enemy_overrides` is gone, so the file now runs the real hits. Unyielding Breath is in the file, so every Down is a pulse later than a run without it. The enemy shapes and the ward-on ward were not kept from the first pass and were rebuilt, so those rows are new: the soul-piercer is much faster than first written and the soul answer no longer holds, and the drainer no longer wins. The ward-on ward is a first guess at ws 300.

**The surprise.** The plan was a fortress ward. Numbers said the ward is the danger: its drain empties the pool,
which lifts the wound's cap, and it dies at 23 s to anything strong. With the ward off the pool stays at 98 % and
the saint stands against everything. The ward now buys years, not survival, which is what made the stance a choice.
Without Still Sea (`--without still_sea`) the saint with the ward off is Down at 22 to 34 s.

**Other realms.** Nascent Soul, ward off, pools and guard scaled by W (`variants/incense-vigil-nascent.fight.json`): owes 0.9 years to a same-realm typical, 21 to a typical one up, 453 to a top-end. Foundation, ward on at ws 150, half share (`variants/incense-vigil-foundation.fight.json`): a peer held at 55 % health, Down at 10 s one realm up. Their stats are a first guess.

**Unmodelled:** Iron Marrow, which has no size in the catalogue; Fair Measure, a caller effect like Years Owed, so years here are before it; the Vow's check of who opened the fight.

## New Concepts

**Deferred damage (the ledger).** Damage held and paid over time.

- **Rule needed:** Combat rule 4 and Formulas C and F: hits may enter a ledger, paid at the pulse on its own cap.
  Combat rule 14 reports what is left, and Realms takes the years.
- **Bounds:** paid at most `dot_pool_cap` a pulse; years owed end a life but never go past it.
- **Breakdown line:** "Blow deferred; 412 % owed."
- **Other builds:** a tick clock that must survive its own clock (Burial Shroud, at a partial share); backlog 60, the
  one who never wins and never dies.
- **Question for the user:** does the ledger carry between Tribulation waves? Rule 7 says health carries exactly.

**Winning by standing.** The Vow changes an ending the GDDs name twice as a failure.

- **Rule needed:** Combat rule 14 and Edge Cases ("a stalemate gives no win"), AC-CB-62 and the Event Engine's branch. Thiên Kiếp rule 8 stays as it is.
- **Bounds:** only when the other side is the requesting side.
- **Other builds:** backlog 70, a healer who wins by keeping a fight going; any sect's gate guardian.
- **Question for the user:** Combat lists stalling under degenerate strategies. Is a stall that costs decades and cannot start a fight now acceptable, or should it live on NPC guardians only?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Incense Vow | Needs rule | Combat rule 14, Edge Cases, AC-CB-62 |
| Slow Wound, Years Owed | Needs rule | Combat rules 4, 14, Formulas C, F; Realms rule 14 for a lifespan loss |
| Short Stick | Needs rule | Combat rule 10: `time_limit` per fight, and rule 12 for its preparation |
| Turned Blade | Needs rule | Compile: L1 and L3 points feed `body_guard_pct` |
| Unyielding Breath | Needs rule | As the catalogue says; Thiên Kiếp says Combat has no revive effect |
| Still Sea, Iron Marrow, Fair Measure | Needs key | Keys on the wound cap, guard by health, years owed |
| Amber | Needs key | A `variants` row, `variant_effects`, a Meridian sector |
| Standing Stele Sutra, three arts, Way of Keeping | Needs key | Art format and ability catalogue (Open Question 13); `dao.json` |

## Also Considered

- **The Short Stick alone:** a build of nothing but a shorter fight. Kept as one piece, because alone it is only a ward with a timer.
- **Banked Blows:** blocked damage stored and released at t = 39, one strike at the end. Dropped: it breaks the Vow's whole meaning, and backlog 34 owns it.
