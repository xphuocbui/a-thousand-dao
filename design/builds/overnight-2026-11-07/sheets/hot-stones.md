# The Five Hot Stones (Ngũ Nhiệt Thạch)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Fire and Earth, heavy arts: Full Bellows and Settled Weight, from plain rows, 0 rule asks, 0 or 1 new pieces, the panel, and proof against both parents.
> **Direction**: The plan was bellows and stones in one kit. The runs said the stones were the wrong arts. Five cheap heavy lamps, each turned to Earth by one Ring Step, read both roads and fall in one instant.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: strong · **Use**: player path
> **Fit**: 2 Fits today · 12 Needs key · 0 Needs rule · 1 new piece
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a ward record)

## The Spine

- **The channel:** art hits on all five layers: five qi arts in one instant, every 4 s.
- **The enabler:** Ring Step (Hoàn Bộ), reused from The Kept Hearth. A converted hit keeps both tag families (Combat rule 6), so a Fire lamp reads Earth's rows too.
- **The loop:** wait 3.44 s. Drop five. Wait 4 s.
- **The engine:** a heavy art needs a long cooldown, not a high cost. The lamps cost 0.04 at 4 s, so five of them are 5 % of the pool a second, and Fire's L1 and L2 stack with Earth's L1, L2 and the L5 that Fire does not have.
- **The sacrifice:** the first 3.44 s, and every slot. Nothing happens before the volley, and there is no second plan.
- **The arc:** at Foundation the Wall is out of reach. At Core it falls in 12 s. At Nascent it falls in 7.44 s.

## The Legend

Lữ Ôn keeps the bathhouse at Three Bridges and has one idea, which is that there is nothing wrong with anyone that a hot stone will not fix. They have prescribed hot stones for grief, debt, a failed breakthrough and a neighbour's goat. Physicians have explained the errors, in writing, for forty years. Lữ Ôn frames the letters and hangs them over the steam, where they curl.

They were never taught to fight. They were challenged in their own yard by a sect envoy, reached for the nearest cure, and dropped five stones on the envoy from the rack in a single happy armful. Lữ Ôn wrote it up as a case of stiffness, resolved. The treatment, they tell anyone in the water, has never failed, and the patient has never come back to complain.

## How It Fights

For 3.44 s there is only the fist. Then five lamps land in one instant. On the Mixed enemy the first two do 155 each, because the ward still stands, and they empty it. The other three do 568, 635 and 635 through nothing (`variants/hot-stones-mixed.fight.json`). Mixed, Evader and Fast all die in that one instant.

**The signature moment:** the Wall. Volley one takes its pool from 99 % to 47 %, and volley two to 2 %, for 23 % of its health. It stands on 76 % at t = 11. It is dead at t = 12, and you are on 27 % (`variants/hot-stones-wall.fight.json --timeline`).

## The Stack

55 nodes, The Long Firing's length, across the Fire and Earth border, on a root with both at purity 50. No new rows.

| # | Row | Take | Total | Form | Layer | Status | Reads |
|---|---|---|---|---|---|---|---|
| 1 | Fire damage (Hỏa Thương), Red Heart | 9 + 1 | +30 | Increased | L1 | ○ reused | Fire tag |
| 2 | Earth damage (Thổ Thương) | 9 + 2 | +42 | Increased | L1 | ○ reused | Earth tag, by Ring Step |
| 3 | **Full Bellows (Mãn Bễ)**, at the wheel's heavy line size | 6 + 0 | +12 | More | L2 | ○ reused | Fire, 2.5 s or more |
| 4 | **Settled Weight (Trầm Trọng)** | 2 + 1 | +16 | More | L2 | ○ reused | Earth, 3 s or more, by Ring Step |
| 5 | **Unbroken Glaze (Toàn Dứu)** | 10 + 2 | +44 | Conditional | L5 | ○ reused | Earth, health 25 % or above, by Ring Step |
| 6 | First firing comes sooner (Tiên Phát) | 1 + 1 | −14 % | Timing | none | ○ reused | At last in a fight, by `first_firing` |
| 7 | Maximum health (Khí Huyết) | 5 + 1 | +11.5 % | Increased | none | ● | |
| 8 | Regeneration (Hồi Khí) | 4 + 1 | +1.6 | Increased | none | ● | |

**Identity piece:** Ring Step. `--without ring_step` on `hot-stones-wall` loses at 13 s, Wall on 82 %.
**Empty rungs:** crit stays at the typical 15 %, a sacrifice. No ward rows: the typical's points carry it.

| Layer | Points at Core | Multiplier | Sources |
|---|---|---|---|
| L1 | 72 | ×1.72 | Rows 1, 2 |
| L2 | 68 | ×1.68 | Low Flame Method 40, rows 3, 4 |
| L3, L4 | 40, 20 | ×1.40, ×1.20 | The typical weapon and a pill. L4 is 0 in a blind fight |
| L5 | 44 | ×1.44 | Row 5, the one layer Fire has no row for here |
| M | | ×6.99 | Typical at Core is ×5.48 |

## Foundation and Arts

Fire and Earth, purity 50 each: a one-element root gets Earth's rows at ×0.25. Five of 5 slots. Pools and ward points are the typical's, `t_b` 2 from Packed Clay Method, as on The Long Firing.

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|---|
| First to Fifth Lamp (Sơ Đăng to Ngũ Đăng) | Low Flame Method, main | qi, Fire, hit, Earth by Ring Step | 2.23 | 0.04 | 4 s | Reused |

**Bath-Keeper's Note (Dục Đường Ký), new:** one page on what happens to a stone left in a fire. Harmony is ×1.15, and moves nothing, as there are no bonuses.

```json
{"id": "duc_duong_ky", "name": "Dục Đường Ký", "tier": 1, "tech_kind": "secret", "names": ["hoa", "tho"], "layers": 9,
 "bonuses": [], "abilities": [], "seal_clusters": [], "origin": "authored"}
```

Passive: Ring Step, all of a Fire hit to Earth, one step.

**Stone Ward (Thạch Hộ):** reused, per-pulse, common pass 0.54 and 0.36, `upkeep_share` 0.10 (the top of Combat's range, not a guess), `ws` and `we` 47.85: 6.8 % a pulse.

## Matchups

Each cell: result, time, own health. L gives the health the enemy kept. Files are `variants/hot-stones-[name].fight.json`.

| | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|
| **Five Hot Stones, Core** (`mixed` … `fast`) | W 3.4 s, 63 % | W 7.4 s, 16 % | **W 12 s, 27 %** | W 3.4 s, 63 % | W 3.4 s, 20 % | **5** |
| Fierce Fire at Core (`fierce-*`) | W 4.5 s, 48 % | L 50 % | L 91 % | L 67 % | L 86 % | 1 |
| Fierce Fire on the same Stone Ward (`fierce-stone-*`) | W 4.5 s, 48 % | L 39 % | L 89 % | L 42 % | L 86 % | 1 |
| The Long Firing (`firing-*`) | W 8 s, 15 % | W 10 s, 2 % | L 84 % | L 7 % | L 49 % | 2 |
| At Foundation, 30 nodes, four lamps (`foundation-*`) | W 3.4 s, 59 % | W 7.4 s, 8 % | L 79 % | W 7.4 s, 41 % | W 3.4 s, 13 % | 4 |
| At Nascent, 85 nodes, six lamps (`nascent-*`) | W 3.4 s, 65 % | W 3.4 s, 65 % | W 7.4 s, 65 % | W 3.4 s, 65 % | W 3.4 s, 25 % | 5 |

**What neither parent can do:** the Wall, the Fast enemy and the Evader, all three. On the same ward, Fierce Fire still wins one.

**Who did what, measured.**

| Change | File | Won | What moved |
|---|---|---|---|
| Common drain ward | `common-*` | 2 | Loses Pulse on 12 %, Wall on 76 %, Fast on 95 % |
| No Ring Step: the Earth rows read nothing | `no-ring-*` | 3 | Loses Pulse, Wall on 82 % |
| **All 26 Earth nodes sold back to Fire rows** | `fire-road-*` | 4 | **Loses the Wall on 45 %.** Evader takes a second volley |
| Glaze alone removed | `no-glaze-wall` | | Loses the Wall on 67 % |
| First firing removed | `no-first-*` | 4 | Loses the Wall on 9 %, Fast won on 0 % |
| Four lamps | `--without lamp_5` on `wall` | | Loses at 16 s, Wall on 23 % |

**So the honest split.** The Stone Ward carries three cells: Pulse, Wall, Fast. The lamps, a kit from The Seven Lamps and from neither parent, carry the rest: a plain Fire walker with them wins four. **The crossing itself buys the Wall and one volley on the Evader.** It does that through L5. The same nodes in Fire rows pile onto L1 and L2, where they are worth less, which is the plain case for a border: the other side owns a layer you lack.

**Two nodes of timing decide the Wall.** First firing at −14 % moves every volley off the 4 s beat, so each lands before the enemy's instant, and the Wall goes from a loss on 9 % to a win.

**Counter, found by running it:**

- **A Wall with a Closed Gate (Bế Môn):** income stops, and the third volley never comes. Loses at 14 s on 45 % (`gate-wall`).
- **A Stone Ward of their own:** the first two lamps have no pool to empty. Fast loses you the fight at 7 s on 20 % (`stone-fast`), the Wall at 13 s on 65 % (`stone-wall`).
- **Top-end:** dead at t = 1. An Evader at 50 % only costs a volley (`evader-50`: W 7.4 s, 46 %).

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Note has no bonuses, lamps at the lint's ceiling, 5 of 5 slots. Nothing prices a ward record |
| Validity | PASS | `upkeep_share` 0.10 in range. One main, two auxiliaries. Harmony checked |
| Stack | PASS | Increased, More, Conditional, Conversion, Timing. L1 to L5 filled |
| Scaling | PASS | ×6.99 against typical ×5.48. INFO: above typical. `m_static` prints 1.68 because every row is conditional |
| The fight | PASS | 5 of 5 at Core. No cap hit. `own_dry_at` 11.44 s on the Wall, never elsewhere |
| Reuse | PASS | 1 new technique. Ring Step, the lamps and First firing all get a new home |
| NPC use | PASS | Plain rows |
| Counterplay | PASS | Closed Gate, or a per-pulse ward |
| Originality | PASS | A bathhouse |

**Matrix:** `sheets/hot-stones.fight.json --matrix`: typical gap 0 wins at 3.44 s, gap 1 loses at 3 s, top-end loses at 1 s. **Unmodelled:** ward strength against one element, fortune, thought.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Bath-Keeper's Note (Dục Đường Ký) | Needs key | A secret technique carrying one Ring Step |

## Questions

1. Ring Step at 100 % lets any art read two element roads. On this evidence it is what a border is for. Should conversion be the Map's standard bridge, with bridge clusters that sell it?
2. Mixed, Evader and Fast die in one instant at Core. Five lamps reach about 86 units of a 73-unit enemy. Is an all-slots volley meant to one-shot a peer at 4 s?

## Also Considered

- **Two Stones (`two-stones-*`):** Lintel and Settling Wall for two lamps. 4 of 5, Pulse at 6 s on 26 %, and the Wall lost on 71 %. Needs a second main, capability 6.
- **Slag, Fire to Lava:** Earth's rows do not read Lava, so it opens no border.
