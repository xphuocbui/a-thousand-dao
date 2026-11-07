# The Swidden Road (Hỏa Canh Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 2: Wood's Bramble with Slow Fire, two sicknesses that truly feed each other.
> **Direction**: Thorn stands first, so both fires are born stronger. Their stacks then raise every hit. The wheel says Wood feeds Fire. The farmer adds that the ash feeds what grows next.
> **Realm span**: Nascent Soul – Deity Transformation, defined at Deity · **Power level**: ordinary · **Use**: player path
> **Fit**: 4 Fits today · 16 Needs key · 0 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: nothing prices a ward record; Scaling: `m_static` does not read ticks)

## The Spine

- **The channel:** three ticks under the ward, each with its own 5 % cap beneath the shared 8 %, plus hits that read the stacks.
- **The enabler:** none of its own. It stands on Vinegar Cloth (Thố Cân Hộ), a per-hit ward reused from The Held Door. That is a real dependence, and it is measured below.
- **The loop:** New Shoot every second, Smoulder and Bed of Coals every two. 9.6 % of the pool a second, income 5.9 %.
- **The engine:** a fire born beside Thorn reads Complication and Kindling and comes out ×1.13. Every art reads all three sicknesses' stacks through Stoked and Sick Body.
- **The sacrifice:** burst, and the pool. Most fights take 5 to 8 s, the Wall 18 s, and on the Wall the pool ends on 1 %.
- **The arc:** at Nascent the crossing only matches Slow Fire on the same ward. It pays at 75 nodes.

## The Legend

Phan Reo's clan burns the old bramble on the first dry day of spring, and it is the best day of the year. There is rice wine by noon, drums on the ridge, and children running the firebreaks. Phan Reo found their root at nine by setting light to a hedge from eleven paces, and they have not stopped grinning about it.

They walk the sect roads now in a straw hat, sowing thorn on anyone who will duel them and lighting it on the second beat. Asked what they are doing, they say it is planting season. Thorn takes fire better than dry wood, and ash is the best thing that ever happened to a field. Their opponents have come to know the song.

## How It Fights

At t = 1 a thorn. At t = 2 two coals, and the coals catch on the thorn and burn hotter for it. After that the bars fall on their own, and the fist and the small arts grow with every stack.

**The signature moment:** the Wall, a body no hit will move. At t = 12 you are on 51 %, it is on 43 %. At t = 18 it falls with its pool at 25 % and its ward never broken, and you are on 15 % (`variants/swidden-wall.fight.json --timeline`).

## The Stack

75 nodes, the length of the Evergreen Road, spent across the Wood and Fire border. No new rows.

| # | Row | Take | Total | Form | Layer | Status | From |
|---|---|---|---|---|---|---|---|
| 1 | Wood damage (Mộc Thương), Green Heart | 6 + 1 | +24 | Increased | L1 | ○ reused | Wood trunk |
| 2 | Fire damage (Hỏa Thương), Red Heart | 6 + 1 | +24 | Increased | L1 | ○ reused | Fire trunk |
| 3 | Damage over time (Trì Thương) | 4 + 1 | +20 | Increased | L1 | ○ reused | Bramble |
| 4 | Deep Thorn (Thâm Thích), Deep Coals (Thâm Than) | 2 notables | +12 on each status | More | L2 | ○ reused | Bramble, Fire spur |
| 5 | Status chance, Catching Thorn, Catching Flame | 6 + 2 | +18, so 78 % a stack | Increased | none | ○ reused | Both |
| 6 | **Kindling (Dẫn Nhiên)** | notable | +12 Fire while a Wood status stands | Conditional | L1 | ○ reused | Evergreen's spur, at last in a fight |
| 7 | **Complication (Biến Chứng)** | notable | +12 on a status born beside another | Conditional | L2 | ○ reused | Taken unplanned from The Second Sickness |
| 8 | Stoked (Thiêm Sài), Wood and Fire tags | 2 notables | +3 a stack, each art reads one | Per | L2 | ○ reused | Both |
| 9 | Sick Body (Bệnh Thể) | notable | +2 a stack, arts and fist | Per | L2 | ○ reused | The Second Sickness |
| 10 | Regeneration (Hồi Khí), with Deep Drink and Spring Vein | 6 + 3 | +3.9 | Increased | none | ● | Wood trunk |
| 11 | Wood art cost (Tiết Mộc), Thin Leaf | 3 + 1 | −9 % | Increased | none | ○ reused | Wood trunk |
| 12 | Maximum health (Khí Huyết), Old Bark | 12 + 1 | +18.5 % | Increased | none | ● | Wood trunk |
| 13 | Ward efficiency (Hộ Hiệu) | 6 + 1 | +15.2 | Increased | none | ● | Wood trunk |
| 14 | Ward strength (Hộ Lực) | 6 + 2 | +23.2 | Increased | none | ● | Spent here last |

No status duration: on arts of 1 s and 2 s a status never lapses, as Evergreen found. Maximum linh lực is left off too, since every cost here is a share.

**Identity piece:** New Shoot, which carries the Thorn everything catches on. `--without new_shoot` on `swidden-wall` still wins, at 24 s on 2 %, a third slower. See the feed table.
**Empty rungs:** crit, L4 and L5, sacrifices. Ticks use none of them.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | Attack 176, hits +24 to +36, ticks +44 to +56 | ×2.76 and up, soft-capped past 200 | Tree, rows 1 to 3, 6 |
| L2 | Thorn 12, fires 24, hits +5 a stack, plus the Canon's 20 on Wood | | Rows 4, 7, 8, 9 |
| L3 | 40 | ×1.40 | The typical weapon |
| L4, L5 | 0 | ×1.00 | Sacrifices |

## Foundation and Arts

Wood, any purity. Evergreen Canon as main. Fire comes from one new secret technique, because Two Heats Manual is a main method. Harmony: main generates art, ×1.15, on no bonuses.

```json
{"id": "hoi_lich", "name": "Hôi Lịch", "tier": 2, "tech_kind": "secret", "names": ["hoa"], "layers": 12,
 "bonuses": [], "abilities": [{"ability_id": "smoulder", "unlock_layer": 2}, {"ability_id": "bed_of_coals", "unlock_layer": 3}],
 "seal_clusters": [], "origin": "authored"}
```

**Ash Almanac (Hôi Lịch):** a planting calendar with the burn days marked in red. Its fires are qi ticks, the shape of Bone Steam's heat, not Slow Fire's body ticks. On body ticks the Wall is lost on 6 % (`body-burn-wall`).

| Art | Source | Kind | c_art | Cost | Cooldown | Applies |
|---|---|---|---|---|---|---|
| New Shoot (Tân Manh), thorned form | Evergreen Canon | body, Wood | 1.0 | 0.0455 | 1 s | Thorn: body tick, c_tick 0.15, 3 pulses, 78 % |
| Smoulder (Âm Nhiên) | Ash Almanac | body, Fire | 1.25 | 0.05 | 2 s | Burning: qi tick, c_tick 0.15, 3 pulses, 78 % |
| Bed of Coals (Than Sàng) | Ash Almanac | body, Fire | 1.25 | 0.05 | 2 s | Its own Burning, the same numbers |

**Vinegar Cloth (Thố Cân Hộ):** per-hit, pass 0.34 and 0.24, `hit_cost_share` 0.04, `ws` 107.3, `we` 99.3: 2 % of the pool a hit.

## Matchups

Each cell: result, time, own health. L gives the health the enemy kept. Files are `variants/swidden-[name].fight.json`.

| | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|
| **The Swidden Road** (`mixed` … `fast`) | W 6 s, 52 % | W 7 s, 45 % | **W 18 s, 15 %** | W 8 s, 39 % | W 5 s, 44 % | **5** |
| The Bramble, Deity, its own ward (`bramble-*`) | L 31 % | L 33 % | L 74 % | L 49 % | L 81 % | 0 |
| The Bramble on Vinegar Cloth (`bramble-vinegar-*`) | W 7 s, 54 % | W 8 s, 33 % | **L 56 %** | W 8.2 s, 33 % | W 5.5 s, 38 % | 4 |
| Slow Fire, Nascent, its own ward (`slow-*`) | L 53 % | L 53 % | L 85 % | L 67 % | L 86 % | 0 |
| Slow Fire on Vinegar Cloth (`slow-vinegar-*`) | W 6 s, 33 % | W 6.9 s, 19 % | **L 71 %** | W 7.9 s, 8 % | W 4 s, 10 % | 4 |
| **The Swidden Road at Nascent**, 30 nodes (`nascent-*`) | W 6 s, 24 % | W 7 s, 13 % | L 53 % | W 8 s, 3 % | W 5 s, 4 % | 4 |

**What neither parent can do: the Wall.** On the same ward the Bramble leaves it on 56 %, Slow Fire on 71 %. Almost everything else in the first row belongs to the ward: both parents go from 0 of 5 to 4 of 5 on it.

**At Nascent the crossing buys nothing.** On the same ward Slow Fire wins the same four with more health, and the Swidden Road only gets further into the Wall. Two half roads need 75 nodes to beat one whole one.

**Do they truly feed each other? Half yes.** On the Wall, per second of fight:

| Removed | File | Result | Smoulder's fire | Coals' fire | New Shoot's hit |
|---|---|---|---|---|---|
| Nothing | `wall` | W 18 s, 15 % | 318 | 288 | 128 |
| Feed rows (6 to 9) | `no-feed-wall` | L 20 s, enemy on 3 % | 278 | 230 | 92 |
| Thorn | `no-thorn-wall` | L 20 s, enemy on 25 % | 278 | 230 | 111 |
| Both fires | `no-burn-wall` | L 20 s, enemy on 48 % | | | 108 |

Thorn makes each fire ×1.13 at birth, by the layers. Each side lifts the hits by 15 to 19 %. **Most of the kill is still addition:** three statuses mean three 5 % caps, and removing a side costs a quarter to a half of the Wall.

**Two limits the sheet will not hide.**

- **The feed is one way on the tick.** Thorn is born first, so no fire reaches its tick. A later Thorn does read the fires: Long Root in Bed of Coals' slot closes the circle and loses the Wall on 13 % (`root-*`), because it costs too much pool.
- **Fire alone nearly does it.** `--without new_shoot` kills the Wall at 24 s on 2 %, with no Wood art at all, because New Shoot is the dearest thing on the bar. The crossing buys 6 s and 13 points of health on the Wall, not the kill. And `no-thorn-wall` loses because it pays for a New Shoot that plants nothing.

**Loadouts.** Add Long Root as a fourth art against people: three of the four fights 1 s faster, health up in all four, but the Wall is lost on 10 % (`alt-four-*`). Two arts, no Coals, still wins all five, at 23 s on 10 % on the Wall (`alt-two-*`).

**The ward dependence, measured.** At the common pass (per-hit, 0.54 and 0.36) the same road wins four thinly and loses the Wall (`perhit-common-*`: 24 %, 14 %, L 10 %, 4 %, 12 %). On the common drain ward it loses Mixed on 31 % (`common-ward-mixed`).

**Counter:** many small hits. A Wall with two 0.5 s needles spends the Cloth's pool at 2 % a hit and wins at 8 s on 73 % (`needles-wall`). A cleanser does not save anyone: dead at 6 s (`cleanser`). Top-end at t = 1.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Almanac has no bonuses, arts inside the lint, 3 of 7 slots. Nothing prices a ward record |
| Validity | PASS | Almanac's harmony is checked. Vinegar Cloth's `hit_cost_share` 0.04 is inside 0 to 0.10 |
| Stack | PASS | Increased, More, Conditional, Per |
| Scaling | NOT ASSESSED | `m_static` 3.86 reads hits with no conditionals, so it says little about ticks |
| The fight | PASS | 5 of 5 at Deity, 4 of 5 at Nascent. `dot_pool_cap` and `dot_pulse_cap` hit at the end of the typical and Mixed fights, not on the Wall |
| Reuse | PASS | 1 new technique. Kindling finally runs, and Complication and Stoked come from other sheets |
| NPC use | PASS | Plain rows |
| Counterplay | PASS | Many small hits |
| Originality | PASS | Swidden is a farming method, not a work |

**Matrix:** `sheets/swidden.fight.json --matrix`: typical gaps 0 to 2 win at 6 to 7 s, top-end loses at 1 s. **Unmodelled:** Stoked is one row in the file, as each art reads only its own tag. Kindling on the fire arts' hits is +12 in each art's `x`. Vinegar Cloth's pass is Held Door's first guess.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Ash Almanac (Hôi Lịch) | Needs key | A secret technique holding Smoulder and Bed of Coals, with their Burning as a qi tick |

## Questions

1. A status's rows are read once, at birth. If they were read on each refresh, Thorn and the fires could feed each other with no extra art. Is that the rule you want? It would be the first rule this build asks for.
2. Are Catching Thorn and Catching Flame meant to stack? This build takes both, and they are due to be folded together.

## Also Considered

- **Stone Ward instead of the Cloth:** wins four on 4 to 24 % and loses the Wall on 34 % (`alt-stone-*`). A tick build wants the best pass, not the steadiest bill.
- **A Wood-only hedge, three Thorn arts:** it is The Bramble, already shown above.
