# The Three Shirts (Tam Giáp Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Earth and Metal, gear: Weapon attack, Ore Vein, Load-Bearing, from plain rows, 0 rule asks, 0 or 1 new pieces, with L3 as the real game.
> **Direction**: Six pieces, not five. The cheapest artifact in the game is a mail shirt, Ore Vein counts artifacts, and nothing stops you wearing three. The grade of what you carry then decides everything.
> **Realm span**: Qi Refining – Core Formation, defined at Foundation Establishment · **Power level**: ordinary at Hạ phẩm, strong at Cực phẩm · **Use**: player path
> **Fit**: 7 Fits today · 9 Needs key · 0 Needs rule · 1 new piece
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a ward record)

## The Spine

- **The channel:** art hits and the basic attack, on all five layers. L3 reaches every channel.
- **The enabler:** none. The kit is six artifacts, the most `equip.max_slots` allows.
- **The loop:** cut every second, and let the gear do the arithmetic.
- **The engine:** a Weapon attack row is a share of what you carry, so its worth is set by grade. Ore Vein is a count, so a 5-point shirt pays it as well as a seal. Three needles and three shirts fill 135 of 135 thần thức and all six slots.
- **The sacrifice:** the ward kit. `ws` 12.4, and the Wall is out of reach until the gear is very good.
- **The arc:** every grade up, the same 30 nodes are worth more. The road never changes. The pack does.

## The Legend

Tôn Y is the best-dressed cultivator in the Salt Counties, and if you do not agree they will wait while you look again. They wear three mail shirts, one over another, of slightly different greys, and regard anyone in fewer as having given up. Three needles ride in the collar. Asked why three, they turn slowly so you can see the stitching.

Duels are a chance to be seen. They have walked out of two sects for the cut of the robes, and they travel with a looking-glass and a boy to hold it. Every season they sell everything they own to buy one grade up, and every season they are right. A sect elder once called them a coat rack. Tôn Y had that elder's sleeve in their collection by the end of the month.

## How It Fights

Plain Cut every second and Seam Thrust every two, with the fist behind them, all at L3 ×2.1. Long Draw comes at 3 s and the enemy is usually gone: 74 %, 19 %, 0 on the Mixed enemy (`variants/three-shirts-mixed.fight.json --timeline`).

**The signature moment:** the same 30 nodes on the Wall, at four grades. At Hạ it keeps 67 %. At Cực phẩm it falls at t = 13 with you on 8 % (`variants/three-shirts-cuc-wall.fight.json --timeline`).

## The Stack

30 nodes on the Earth and Metal border, a root with both at purity 50.

| # | Row | Take | Total | Form | Layer | Status | Side |
|---|---|---|---|---|---|---|---|
| 1 | Weapon attack (Khí Phong, Good Steel) | 6 + 2 | +29 % | Increased | L3 | ● | Both trunks |
| 2 | **Ore Vein (Khoáng Mạch)**, at the wheel's +1 / +5 | 4 + 1 | +9 an artifact, +54 at six | Per | L2 | ○ reused | Metal arts |
| 3 | **Load-Bearing (Phụ Trọng)** | 0 + 1 | +5 an artifact, +30 at six | Per | L2 | ○ reused | Earth art, Lintel only |
| 4 | Armour defence (Giáp Hậu) | 3 + 0 | +4.5 % | Increased | none | ● | Earth |
| 5 | Metal damage (Kim Thương), Bright Steel | 4 + 1 | +20 | Increased | L1 | ○ reused | Metal |
| 6 | Body damage (Thể Thương) | 3 + 1 | +14.5 | Increased | L1 | ○ reused | Earth |
| 7 | Steady Thread (Ổn Tuyến), Metal tag | 0 + 1 | +12 while your linh lực is 50 % or above | Conditional | L5 | ○ reused | Metal arts |
| 8 | Honed Edge (Ma Lợi) | 1 + 0 | +2 | More | L2 | ○ reused | Metal arts |
| 9 | Ward efficiency, Regeneration | 1 + 0 each | +1.2, +0.15 | Increased | none | ● | |

**Identity piece:** Ore Vein, the row that reads the count. `--without "Ore Vein"` moves `three-shirts-wall` from L 67 % to L 75 %. It does not move `three-shirts-mixed`: that fight ends at 3 s either way.
**Empty rungs:** crit, a sacrifice. Artifact power is left off: +0.9 a node to Weapon attack's +1.5, on a pack that is mostly weapon.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 34.5 on Plain Cut | ×1.35 | Rows 5, 6 |
| L2 | 96 | ×1.96 | Method 40, Ore Vein 54, Honed Edge 2 |
| L3 | 110.7 | ×2.11 | Three needles 85.8, row 1 |
| L4 | 20 | ×1.20 | A pill. 0 in a blind fight |
| L5 | 12 | ×1.12 | Row 7, while the pool holds |

## Foundation and Arts

Earth and Metal, purity 50 each. Thần hồn 45, the typical. Pools are the typical's. `t_b` 2 from Packed Clay Method, reused. Four of 4 slots.

**Baggage Sutra (Hành Trang Kinh), new:** main, Huyền giai, an inventory read aloud. It lists four arts that already exist.

```json
{"id": "hanh_trang_kinh", "name": "Hành Trang Kinh", "tier": 1, "tech_kind": "main", "names": ["tho", "kim"], "layers": 9,
 "bonuses": [], "abilities": [{"ability_id": "plain_cut", "unlock_layer": 1}, {"ability_id": "seam_thrust", "unlock_layer": 3},
 {"ability_id": "long_draw", "unlock_layer": 3}, {"ability_id": "lac_mi", "unlock_layer": 6}], "seal_clusters": [], "origin": "authored"}
```

Also +40 L2 on Earth and Metal arts, the typical anchor.

| Art | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|
| Plain Cut (Bình Trảm) | body, Metal | 1.4 | 0.05 | 1 s | Reused |
| Seam Thrust (Tầm Phùng Thích) | body, Metal, pass_raise 0.40 for 2 pulses | 1.8 | 0.06 | 2 s | Reused |
| Long Draw (Trường Tha) | qi, Metal | 2.2 | 0.08 | 3 s | Reused |
| Falling Lintel (Lạc Mi) | body, Earth | 2.71 | 0.08 | 4 s | Reused |

| Pack | Each | Thần thức at Foundation | Gives |
|---|---|---|---|
| Three `cham`, Hạ phẩm, tier 1 | Attack 286 | 30 each | L3 85.8 before rows |
| Three `giap`, Hạ phẩm, tier 1 | Defence 390, body-tagged | 15 each | `a_b` 1.22 with row 4 |

135 of 135, 6 of 6. **Stone Ward (Thạch Hộ):** reused, common pass, `upkeep_share` 0.10, `ws` 12.4, `we` 13.6, no ward gear: 8.8 % a pulse.

## Matchups

Each cell: result, time, own health. L gives the health the enemy kept. Files are `variants/three-shirts-[name].fight.json`.

| | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|
| **Three Shirts, Foundation, Hạ phẩm** (`mixed` … `fast`) | W 3 s, 57 % | W 3 s, 57 % | L 67 % | W 4 s, 46 % | W 3 s, 33 % | **4** |
| The Grindstone at Foundation (`grindstone-*`) | L 24 % | L 25 % | L 86 % | L 51 % | L 68 % | 0 |
| The Grindstone on the Stone Ward (`grindstone-stone-*`) | W 5 s, 0 % | L 6 % | L 86 % | L 39 % | L 66 % | 1 |
| **The Grindstone on Stone and Packed Clay** (`grindstone-stone-clay-*`) | W 5 s, 40 % | W 6 s, 13 % | L 84 % | W 6 s, 13 % | W 3 s, 7 % | **4** |
| The Grindstone, Stone and Clay, at Cực phẩm (`grindstone-cuc-*`) | W 3 s, 57 % | W 4 s, 45 % | L 76 % | W 5 s, 40 % | W 3 s, 20 % | 4 |
| The Ore Line at Foundation (`ore-*`) | W 5 s, 8 % | L 0 % | L 85 % | L 32 % | L 88 % | 1 |
| Three Shirts at Core, 55 nodes (`core-*`) | W 3 s, 60 % | W 3 s, 60 % | L 67 % | W 4 s, 50 % | W 3 s, 38 % | 4 |
| The Ore Line at home (`ore-home-*`) | W 5 s, 17 % | L 4 % | L 81 % | L 38 % | L 85 % | 1 |
| **Three Shirts, Cực phẩm** (`cuc-*`) | W 2 s, 81 % | W 2 s, 81 % | **W 13 s, 8 %** | W 3 s, 64 % | W 2 s, 46 % | **5** |

**What neither parent can do, plainly.** As written the parents win 0 and 1, and the four wins look like the crossing. They are not. **Most of the fourth row is the ward and Packed Clay:** the Grindstone given both also wins four. What the crossing adds is health, 57 % against 40 and 13, 46 against 13, 33 against 7, and the Wall at Cực phẩm, which the Grindstone at the same grade loses on 76 %. On the common ward it is 3 of 5 (`common-*`: Wall L 69 %, Fast L 68 %, Evader won on 10 %), and Packed Clay is worth 18 to 26 points of health (`no-clay-*`).

**L3 as the real game.** The Wall at each grade, on the same 30 nodes. **Plain road** moves the 17 gear nodes to Metal damage and Honed Edge.

| Grade | 3 needles, 3 shirts: L3, `a_b` | Wall (`[grade]-wall`) | 4 needles, 1 shirt: L3 | Wall (`[grade]-four-one-wall`) | Plain road, 3 and 3 (`damage-[grade]-wall`) |
|---|---|---|---|---|---|
| Hạ | 110.7, 1.22 | L 67 % (`wall`) | 147.6 | L 65 % (`four-one-wall`) | L 68 % |
| Trung | 144.7, 1.60 | L 61 % | 193.0 | L 59 % | L 63 % |
| Thượng | 187.3, 2.07 | L 52 % | **249.7** | **L 21 %** | L 57 % |
| Cực | **255.4**, 2.82 | **W 13 s, 8 %** | 340.6, clipped to 250 | L 20 % | L 27 % |

Four things to take from that table.

- **At Hạ phẩm the gear rows are worth almost nothing.** The plain road is within 1 point in every cell (`damage-ha-*`). This is why L3 has been ignored: a row that multiplies 86 is a poor row.
- **Past Thượng they decide the fight.** The gap to the plain road on the Wall goes 1 point, 2, 5, then a win.
- **L3's cap of 250 sets the pack.** Four needles land on it at Thượng, three at Cực. Past that a needle is wasted, and the fourth needle had better become a shirt. Nobody needs a rule for this: a player reads the sheet and changes clothes.
- **Six is the number, until the Wall.** Three and three pay Ore Vein +54, four and one +45, and `a_b` 1.22 against 0.41: 57 % against 52 % on Mixed, and 33 % against 30 % on Fast (`four-one-*`). Against the Wall, below Cực phẩm, the fourth needle is the better buy.

**Counter, found by running it:**

- **The Wall,** at every grade below Cực phẩm. Even there a Closed Gate stops it: L 28 % (`cuc-gate-wall`).
- **Fast on a Stone Ward of their own:** you still win, on 6 % (`stone-fast`). A shred curse costs 9 points (`shred-mixed`), and a Closed Gate on the Mixed enemy costs nothing (`gate-mixed`).
- **Top-end:** dead at t = 1.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Sutra has no bonuses, arts within the lint, 4 of 4 slots, 135 of 135 thần thức, 6 of 6 pieces. Nothing prices a ward record |
| Validity | PASS | Real bases, grades and tiers. `giap` is body-tagged, so its defence goes to `a_b`, not the ward. The Grindstone's sheet puts it on the ward: that file is left as written |
| Stack | PASS | Increased, Per, Conditional, More. L1 to L5 filled |
| Scaling | PASS | Plain Cut ×7.5 at Hạ, with the pool high, against typical ×4.19 at Foundation. INFO: above typical |
| The fight | PASS | 4 of 5 at Foundation and Core, 5 of 5 at Cực. `layer_3_over_cap` is named above |
| Reuse | PASS | 1 new technique. Load-Bearing's notable and Armour defence finally matter |
| NPC use | PASS | Plain rows and common items |
| Counterplay | PASS | The Wall, and a Closed Gate at the top |
| Originality | PASS | No borrowed names |

**Matrix:** `sheets/three-shirts.fight.json --matrix`: typical gap 0 wins at 3 s, gap 1 loses at 3 s, top-end loses at 1 s. **Unmodelled:** thần thức is costed here, not spent in the fight. Fortune is not read.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Baggage Sutra (Hành Trang Kinh) | Needs key | A dual-element main listing four existing arts |

## Questions

1. Item Database rule 11 says nothing stops three mail shirts. Is that meant? It is the whole of this build's Hạ phẩm edge.
2. Ore Vein and Load-Bearing are due to fold. Folded, this walker saves one node and Lintel reads +54, not +30. Not run. Should the folded row keep both tags?

## Also Considered

- **Full Cleave for Lintel (`meth40-*`):** the same four wins, Wall L 70 %. It costs 0.12 and fires at 6 s, so it spends more for less.
- **Thần thức cost rows for a seventh weight:** six is the slot limit, so they only buy heavier bases. A sequel for a build on `an` seals.
