# The Fierce Fire Road (Mãnh Hỏa Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 1, the Plain Stack, for Fire: 16 or more ordinary tag-scoped modifiers, 0 rule asks, no enabler, one build of 10 or more around a real choice between two lines. Remove any one and the fight barely moves; remove five and it is lost.
> **Direction**: The two heats every kiln-keeper knows. A 30-node Fire road that forks at node 12 into Fierce Fire (big hits together) and Slow Fire (sustained burning). The build walks Fierce Fire. Slow Fire is built and tested as its rival.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Nascent Soul · **Power level**: ordinary · **Use**: player build, or any sect's Fire disciple
> **Fit**: 3 Fits today · 32 Needs key · 0 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** art hit, on all five layers, with no weapon, no preparation and no plug-in.
- **The enabler:** none.
- **The loop:** a cheap art ticks while three big arts wait. All three fire in one instant at 2.73 s, empty the enemy's linh lực, and the cheap art and the basic attack finish a body with no ward.
- **The engine:** 14 ordinary rows, none worth much, on different layers and rungs. It is the one thing a plain +120 Fire damage cannot do at this realm, because L1 is already at its soft cap.
- **The sacrifice:** the volley spends the pool, and the pool is the ward. An enemy who outlasts it wins.
- **The arc:** damage first while L1 is empty, then the fork, then everything except damage.

## The Legend

Every Fire child in the hill schools learns the two heats before they learn to read. A potter's heat is low and lasts all night. A smith's heat is high and is over before the iron cools. Neither is a secret and no sect owns them. The Two Heats Manual is copied by hand and given away, and most copies have a scorch on the cover from the student before you.

Hòa tended a grandmother's lime kiln until a root was found, and reached Nascent Soul slowly, with no luck worth mentioning and no sword. They chose the high heat because they were frightened of long fights, and they are still frightened. After the third stroke they have almost nothing left, and they know exactly how little, and they stand there and hope. When students ask which heat is better, Hòa asks them what they are trying to make, and then goes to light the kiln, because it needs lighting.

## How It Fights

For two seconds it looks like losing: the enemy stands on 87 %, you are on 65 %. Then three arts land in one instant. They do little to the body, but they take the enemy from 70 % linh lực to 0, and the cheap art lands in the same instant on a body with no ward. Their arts stop. Your breath is gone too. What is left is a basic attack and a last cinder, paid for by a single pulse of regeneration.

**The signature moment:** the three big arts deal 21 % of the damage. Last Cinder, the cheapest art on the sheet, deals 50 % and the free basic attack 29 %. The big hits are the door, not the blow (`variants/fierce-fire-mixed.fight.json --timeline`).

## The Stack

Sizes on new rows are first guesses, taken from the catalogue where it has a row. **Nodes** are in walking order: 30 nodes, 24 acupoints and 6 notables, 76.8 W at the Meridian Map's prices. Status ○ for a catalogue row means the row is in the catalogue and its key is not yet in Character Stats. Sector rows scale with purity, so these sizes assume purity 50: 0.5 + purity / 100 (Meridian Map rule 4). Fierce-road removal results are in **The New Test**.

### Trunk, nodes 1 to 12 (both roads)

| Nodes | Type | Row | Each | Total | Rung | Form | Layer | Status | Second home |
|---|---|---|---|---|---|---|---|---|---|
| 1–3, 9–11 | acupoint ×6 | Fire damage | +2 % | +12 | Multiplier | Increased | L1 | ○ catalogue | any Fire build |
| 4 | notable | **Red Heart (Xích Tâm)** | +12 % Fire damage | +12 | Multiplier | Increased | L1 | ○ catalogue | any Fire build |
| 5–7 | acupoint ×3 | Fire art cost | −1 % | −3 | Fuel | Increased | none | ○ catalogue | any Fire build |
| 8 | notable | **Dry Wood (Can Sài)** | −6 % Fire art cost | −6 | Fuel | Increased | none | ○ catalogue | any Fire build |
| 12 | acupoint | Fire art speed | +1 % | +1 | Rate | Increased | none | ○ catalogue | any Fire build |

### Fierce Fire (Mãnh Hỏa), nodes 13 to 30: the build

| Nodes | Type | Row | Each | Total | Rung | Form | Layer | Status | Second home |
|---|---|---|---|---|---|---|---|---|---|
| 13–15 | acupoint ×3 | Fire art speed | +1 % | +4 with node 12 | Rate | Increased | none | ○ catalogue | any Fire build |
| 16 | notable | **Quick Draught (Cấp Phong)** | +6 % Fire art speed | +6 | Rate | Increased | none | ○ catalogue | any Fire build |
| 17–20 | acupoint ×4 | Crit chance with Fire | +0.8 % | +3.2 | Crit | Increased | none | ○ tag swap of the Sword row | any Fire hit build |
| 21 | notable | **White Point (Bạch Điểm)** | +5 % crit chance with Fire | +5 | Crit | Increased | none | ○ tag swap of the Sword row | any Fire hit build |
| 22–23 | acupoint ×2 | Crit damage | +1.5 % | +3 | Crit | Increased | none | ● catalogue | every crit build |
| 24–25 | acupoint ×2 | **Thin Ward (Bạc Hộ)** | +0.05 points per 1 % of the enemy's linh lực missing, Fire arts | up to +10 | Reach | Per | L2 | ○ new | any ward-breaker |
| 26 | notable | **Full Bellows (Mãn Bễ)** | +12 points to Fire arts with a cooldown of 2.5 s or more | +12 | Multiplier | More | L2 | ○ new | any slow Fire art |
| 27–29 | acupoint ×3 | Maximum linh lực | +1.2 % | +3.6 | Fuel, Survival | Increased | none | ● catalogue | every build |
| 30 | notable | **Open Door (Khai Môn)** | +15 % damage to an enemy under 5 % linh lực | +15 | Reach | Conditional | L1 | ○ catalogue, read at 5 % | any ward-breaker |
| Technique | not a node | **Bare Vessel (Lộ Đỉnh)**, lesser grade | +30 points to hits while the enemy is under 5 % linh lực | +30 | Reach | Conditional | L5 | ○ **reused** | see below |

### Slow Fire (Ôn Hỏa), nodes 13 to 30: the rival

| Nodes | Type | Row | Each | Total | Rung | Form | Layer | Status | Second home |
|---|---|---|---|---|---|---|---|---|---|
| 13–15 | acupoint ×3 | Status chance | +1 % | +3 | Base | Increased | none | ○ catalogue | any status build |
| 16 | notable | **Catching Flame (Dẫn Hỏa)** | +6 % status chance | +6 | Base | Increased | none | ○ catalogue | any status build |
| 17–19 | acupoint ×3 | Status duration | +2 % | +6 | Base | Increased | none | ○ catalogue | any status build |
| 20 | notable | **Long Burn (Trường Nhiên)** | +12 % status duration | +12 | Base | Increased | none | ○ catalogue | any status build |
| 21–24 | acupoint ×4 | Maximum linh lực | +1.2 % | +4.8 | Fuel, Survival | Increased | none | ● catalogue | every build |
| 25–27 | acupoint ×3 | Ward efficiency | +1.2 % | +3.6 | Survival | Increased | none | ● catalogue | any long fight |
| 28 | acupoint | **Heat Held (Dư Nhiệt)** | +2.5 points to Fire arts while the enemy is Burning | +2.5 | Multiplier | Conditional | L5 | ○ new | any burn build |
| 29 | notable | **Keeping Heat (Trì Nhiệt)** | +15 points to Fire arts while the enemy is Burning | +15 | Multiplier | Conditional | L5 | ○ new | any burn build |
| 30 | notable | **Stoked (Thiêm Sài)** | +3 points to Fire arts per stack on the enemy | up to +30 | Multiplier | Per | L2 | ○ new | any status build |

### Spurs: on the map, on neither road

| Type | Row | Each | Rung | Form | Layer | Status | Why a walker leaves it, or takes it |
|---|---|---|---|---|---|---|---|
| acupoint | Damage over time | +2 % | Multiplier | Increased | L1 | ○ catalogue | Clips at equal realm. Four of them instead of linh lực: Slow Fire ends on 16 %, not 21 % (`-slow-wall-dot`). Wants a fight one realm up |
| notable | **Deep Coals (Thâm Than)** | +12 points to Fire over-time statuses | Multiplier | More | L2 | ○ new | As above, not tested alone |
| acupoint | Ward strength against Fire | +2 % | Survival | Increased | none | ○ catalogue | The Fire ward resistance row. Against a Fire enemy, three of them for the linh lực nodes: 6 s on 16 %, so the pool is worth more (`-fire-ward-mixed`) |
| notable | **Burnt Hands (Thục Thủ)** | +12 % ward strength against Fire | Survival | Increased | none | ○ catalogue | For a Fire sect's own duels, not tested alone |
| notable | **Slag (Xỉ Hỏa)** | 40 % of Fire hits become Lava, keeping their Fire tags | Multiplier | Conversion | none | ○ catalogue one-off | Combat's own example, AC-CB-19. A fair swap, no better (`-slag-mixed`) |
| acupoint | Lava damage | +2.5 % | Multiplier | Increased | L1 | ○ catalogue | Only on the converted share. Three of them with Slag, for Open Door and the crit damage nodes: enemy on 12 % at 4 s, not 13 % |

**Identity piece:** none, on purpose. The critic's new test replaces the identity test: no row may be the build. The `pieces` file carries `identity_id: null`.
**The unplanned use:** Bare Vessel's authors drain a pool over seconds and then hit. Here the condition turns true inside one instant: the volley empties the pool, and Last Cinder, resolving after it in slot order, already reads it. Without it the enemy stands on 24 % at 4 s, not 13 %. Without it and Open Door together, the fight runs to 6 s and ends on 11 % (`-mixed-pair-dry`).
**Bare Vessel's grades, stated plainly.** One modifier, four sizes tonight: +2.5 as an acupoint, +25 as a notable, +30 lesser grade and +80 greater grade on techniques and sealed clusters. This row is the lesser grade on a technique, not a tree node, at twice the +10 to +15 of the Conditional notables on the roads. It stays, because a change alters fights. At +15 the main fight ends the same (`-mixed-bv15`), but the split goes from a win at 5 s on 10 % to a loss at 6 s on overkill (`-split-mixed-bv15`), and the cost pair from a win at 6 s on 9 % to a loss at 7 s on overkill (`-mixed-pair-cost-bv15`).
**Empty rungs:** Past the cap is a sacrifice: the soft cap on L1 is the cap, and the answer to it is to stop buying L1. Survival is thin by choice, 3 acupoints.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 209, or 224 on a dry enemy | ×3.05, or ×3.12 | 185 the typical attack share, Fire damage 12, Red Heart 12, Open Door 15. Past 200 each point counts half |
| L2 | big arts 12 to 22, Last Cinder 0 to 10 | up to ×1.22, ×1.10 | Full Bellows, Thin Ward |
| L3 | 0 | ×1.00 | No weapon. A sacrifice, and the first thing to fix: see below |
| L4 | 0 | ×1.00 | No preparation, so a blind fight is this same fight |
| L5 | 30 on a dry enemy | ×1.30 | Bare Vessel |

Crit: 23.2 % at ×1.73, worth ×1.17 on average. The anchors are typical M 7.37 and top-end 256. This build never passes about M 5 on a hit.

## The New Test

Every line is `python design/builds/overnight-2026-11-07/_tools/fight_x.py variants/fierce-fire-[name].fight.json`, against the mixed enemy, equal realm. `--timeline` gives the enemy's health at 4 s, which shows what a row does when the end time does not change.

| Remove | Variant | Result | Own health | Enemy at 4 s |
|---|---|---|---|---|
| Nothing | `-mixed` | Wins at 5 s | 29 % | 13 % |
| Fire damage ×6 | `-mixed-no-fire-damage` | Wins at 5 s | 29 % | 17 % |
| Red Heart | `-mixed-no-red-heart` | Wins at 5 s | 29 % | 17 % |
| Full Bellows | `-mixed-no-full-bellows` | Wins at 5 s | 29 % | 26 % |
| Thin Ward ×2 | `-mixed-no-thin-ward` | Wins at 5 s | 29 % | 21 % |
| Fire art speed ×4 | `-mixed-no-speed` | Wins at 5 s | 29 % | 13 % |
| Quick Draught | `-mixed-no-quick-draught` | Wins at 5 s | 29 % | 13 % |
| Crit chance with Fire ×4 | `-mixed-no-crit` | Wins at 5 s | 29 % | 17 % |
| White Point | `-mixed-no-white-point` | Wins at 5 s | 29 % | 20 % |
| Crit damage ×2 | `-mixed-no-crit-damage` | Wins at 5 s | 29 % | 14 % |
| Open Door | `-mixed-no-open-door` | Wins at 5 s | 29 % | 15 % |
| Bare Vessel | `-mixed-no-bare-vessel` | Wins at 5 s | 29 % | 24 % |
| Fire art cost ×3 | `-mixed-no-cost` | Wins at 6 s | 16 % | 13 % |
| Dry Wood | `-mixed-no-dry-wood` | Wins at 6 s | 12 % | 13 % |
| Maximum linh lực ×3 | `-mixed-no-linh-luc` | Wins at 6 s | 16 % | 13 % |

**One out: 14 of 14 win.** Most rows leave the end where it was and move only the enemy's bar, and the two speed rows do not even do that. The three fuel rows cost a second, because the fifth Last Cinder can no longer be paid at 5 s. That is the largest move, and it is not nothing: 17 points of health.

| Remove together | Variant | Result |
|---|---|---|
| Fire damage, Red Heart | `-mixed-pair-damage` | Wins at 5 s on 29 %, enemy on 25 % at 4 s |
| Both crit chance rows | `-mixed-pair-crit` | Wins at 5 s on 29 %, enemy on 25 % at 4 s |
| Open Door, Bare Vessel | `-mixed-pair-dry` | Wins at 6 s on 11 % |
| Both cost rows | `-mixed-pair-cost` | Wins at 6 s on 9 % |
| Both speed rows | `-mixed-pair-speed` | **Loses at 3 s, enemy on 16 %** |
| Five damage rows: Fire damage, Red Heart, Full Bellows, White Point, Bare Vessel | `-mixed-five-damage` | **Loses at 5 s, enemy on 51 %** |
| Five that deal no damage: both speed, both cost, linh lực | `-mixed-five-fuel` | **Loses at 3 s, enemy on 16 %** |
| Five of crit and the dry bonus: both crit chance, crit damage, Open Door, Bare Vessel | `-mixed-five-crit` | **Loses at 7 s, enemy on 6 %** |
| One from each rung: Fire damage, speed, Dry Wood, crit chance, Open Door | `-mixed-five-one-a-rung` | **Loses at 7 s, enemy on 1 %** |
| Fire art speed, both crit chance, crit damage, Open Door | `-mixed-five-kept` | Still wins at 5 s on 29 %, enemy on 28 % at 4 s |
| All 30 nodes | `-mixed-no-path` | Loses at 3 s, enemy on 61 % |

**Not every five is lost,** and `-mixed-five-kept` is the proof. The soft rows are crit and Open Door, which only speed up a fight the basic attack is already finishing. One pair is a real cliff, too: with no speed row at all the volley lands at 3 s, in the same instant as the enemy's blows, and that alone loses. Any one speed row is enough, which is the most useful thing the sheet can tell a player.

**Why spread at all.** The same 30 nodes spent on one stat, same technique and arts:

| Realm, L1 before the road | The road | 76.8 W of plain attack | +120 Fire damage, all 30 nodes |
|---|---|---|---|
| Foundation, L1 0 (`-early-…`) | Loses, enemy on 64 % | Loses, enemy on 53 % | Loses, enemy on 26 % |
| Foundation, L1 62 (`-foundation-…`) | **Wins at 4.5 s on 45 %** | Loses at 3 s, both on 0 %, on overkill | Wins at 3 s, both on 0 %, on overkill |
| Core, L1 112 (`-core-…`) | **Wins at 4.5 s on 48 %** | Loses at 3 s, enemy on 8 % | Loses at 3 s, both on 0 %, on overkill |
| Nascent Soul, L1 185 (`-mixed-…`) | **Wins at 5 s on 29 %** | Loses at 3 s, enemy on 30 % | Loses at 3 s, enemy on 24 % |

With an empty L1 the plain number is the best buy. Once anything is in L1, the road beats both, and by Nascent Soul the plain paths lose outright. Neither plain path buys a speed row, so its volley lands at 3 s, on the cliff above.

## The Choice

Node 12 is the fork. Both roads cost the same 18 nodes and neither reaches the other's notables.

| Road | Arts | vs mixed | vs The Wall |
|---|---|---|---|
| Fierce Fire | Red Bellows, White Coal, Furnace Mouth, Last Cinder | **Wins at 5 s on 29 %** (`-mixed`) | Loses at 9 s, enemy on 47 % (`-wall`) |
| Slow Fire | Smoulder, Bed of Coals, Last Cinder | Loses at 4 s, enemy on 53 % (`-slow-mixed`) | **Wins at 9 s on 21 %** (`-slow-wall`) |
| Split, 9 nodes each way | Red Bellows, White Coal, Smoulder, Last Cinder | Wins at 5 s on 10 % (`-split-mixed`) | Loses at 10 s, enemy on 37 % (`-split-wall`) |

**The Wall** is a typical Nascent Soul who has put everything into the ward and carries one jab: no L2 to L5, ward 150, about twice the pool. Fierce Fire breaks on it and stands empty. Burning goes inside the ward, so Slow Fire never needs to touch it. The split is worse than Fierce Fire where Fierce Fire wins, and it loses where Slow Fire wins, so the fork is a real choice.

Slow Fire passes the same test against The Wall: without both chance rows, Keeping Heat or Stoked it still wins, at 10 s on 5 % (`-slow-wall-no-chance`, `-slow-wall-no-keeping-heat`, `-slow-wall-no-stoked`). Without ward efficiency it wins at 9 s on 19 % (`-slow-wall-no-ward-efficiency`), and without linh lực at 9 s on 16 % (`-slow-wall-no-linh-luc`). Remove five and it loses at 11 s, both on 0 %, on overkill (`-slow-wall-five`). **Status duration does nothing here:** without it the result is unchanged (`-slow-wall-no-duration`), because its arts refresh the burn before it ends. The rows matter only to a burn that must outlive its last cast, and this fight does not ask that.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire, purity 50 | Sets the sector scale. Purity is not a fight input, but the row sizes above assume it |
| Key talents | None | A typical life: n_body 2.04, n_qi 1.73 before nodes |
| The Way (Đạo) | None | Everything is on the tree or the technique |
| Sense and fortune | Not used | Divine sense stays at 1.0, fortune and heart demon are never read |

## Công Pháp

### Two Heats Manual (Nhị Hỏa Thiên) — main, Địa giai

A copybook for children, with a scorch on the cover.

```json
{"id": "nhi_hoa_thien", "name": "Nhị Hỏa Thiên", "tier": 2, "tech_kind": "main",
 "names": ["hoa"], "layers": 12,
 "bonuses": [{"stat": "alchemy_success", "value": 8}, {"stat": "tam_ma_resist_pct", "value": 15}],
 "abilities": [{"ability_id": "last_cinder", "unlock_layer": 1}, {"ability_id": "smoulder", "unlock_layer": 2},
               {"ability_id": "bed_of_coals", "unlock_layer": 3}, {"ability_id": "red_bellows", "unlock_layer": 4},
               {"ability_id": "white_coal", "unlock_layer": 6}, {"ability_id": "furnace_mouth", "unlock_layer": 9}],
 "seal_clusters": [], "origin": "authored"}
```

Also carries Bare Vessel, lesser grade, at layer 9. **Fit:** Needs key · **Budget:** 8/8 + 15/15 = 2.0 of 3.0, chosen off the fight so the road does all the work.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Red Bellows (Xích Bễ) | Manual, 4 | qi, Fire, hit | 3.18 | 0.14 | 3 s | none | Needs key |
| White Coal (Bạch Than) | Manual, 6 | qi, Fire, hit | 3.18 | 0.14 | 3 s | none | Needs key |
| Furnace Mouth (Lô Khẩu) | Manual, 9 | qi, Fire, hit | 3.18 | 0.14 | 3 s | none | Needs key |
| Last Cinder (Dư Tẫn) | Manual, 1 | qi or body, Fire, hit | 1.60 | 0.05 | 1 s | none | Needs key |
| Smoulder (Âm Nhiên) | Manual, 2 | body, Fire, hit, over time | 1.25 | 0.05 | 2 s | none | Needs key |
| Bed of Coals (Than Sàng) | Manual, 3 | body, Fire, hit, over time | 1.25 | 0.05 | 2 s | none | Needs key |

**Effect:** the first four are plain hits at the art lint. On Fierce Fire, all costs are −9 % and cooldowns ÷1.10, so the volley fires every 2.73 s for 0.38 of the pool. Smoulder and Bed of Coals each also apply their own Burning status (Thiêu): `c_tick` 0.15, 3 pulses, chance 0.60, stacking to 5, a Fire health tick and not a qi burn. Within the split lint: 1.25 / 1.85 + 0.45 / 2.22 = 0.88. Last Cinder takes its kind from the road: qi to feed the volley, body to leak past a standing ward.

**Description:** a pump of the bellows, a coal gone white, the furnace door opened. And what is still warm in the morning.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Nascent Soul | 4 of 6 | Red Bellows, White Coal, Furnace Mouth, Last Cinder | Common drain ward, ws and we 62 | One more art than the mixed enemy. Last Cinder must be last |

**Two slots stay open, and the sheet is honest about that.** A slot is not an art: this plain character owns one technique. A fourth big art wins at 4 s on 39 % (`-mixed-more-arts`), so a second technique is a real upgrade.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Common ward piece | Artifact, ward | `thuan`, the typical's artifact defence 0.85 × B_p | The typical's ws and we 62 | Fits today |

**No weapon.** An ordinary weapon at L3 40 wins at 2.73 s on 65 % in one volley (`-mixed-weapon`). That is the road's first upgrade, and it also ends the new test, because the fight no longer has a second exchange. The bare build is the honest floor.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Trunk, nodes 1 to 12 | +24 Fire damage, −9 % cost | Damage first: it is the only row that pays with an empty L1 | Needs key |
| 2 | One speed row | +1 % or more past the trunk | The volley must land before 3 s | Needs key |
| 3 | The rest of Fierce Fire | See The Stack | Each worth a little, on a different rung | Needs key |

### Hidden cluster idea: The Two Heats (Nhị Hỏa Mạch)

Theme Spiritual Power, Fire affinity, sealed by the Two Heats Manual, two clusters of 12 acupoints past a shared road, with the rest of each 18-node road on open acupoints beside them. The payoff notables sit farthest from the entry: Open Door and Stoked. No capability. Tree nodes are not authored here, so this is an idea for the rework.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation | Trunk first, plain damage | The fork in sight | Leaves the kiln, afraid of a long fight |
| Core Formation | One big art and Last Cinder, then two | Fierce nodes begin | Picks the high heat, knowing what it costs |
| Nascent Soul | The whole volley | Furnace Mouth, Open Door | Teaches both heats to children, and still lights the kiln |

## Matchups

| Enemy | Result | Why | Input |
|---|---|---|---|
| Mixed typical, equal | Wins at 5 s on 29 % | The volley dries them at 2.73 s | `-mixed` |
| One cheap art, equal | Wins at 5 s on 29 % | Identical, because their other arts never fired anyway | `-jab` |
| Foreseen, no home ground | The same fight | No ground and no preparation, so nothing to take away | `-mixed` |
| Earlier realm, Core | Wins at 4.5 s on 48 % | Same 30 nodes | `-core-mixed` |
| The Wall | Loses at 9 s, enemy on 47 % | Pool outlasts the volley | `-wall` |
| Mixed typical, one realm up | Loses at 2 s, enemy on 97 % | It is an ordinary build | `-mixed --gap 1` |
| Mixed top-end, equal | Loses at 1 s, enemy on 99 % | Expected | `-mixed --enemy top_end` |

**Counter:** any warder whose pool outlasts one volley. The Combat rule 18 enemy that resists a kind does this by trade, and so does anyone with Slow Fire.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Technique 2.0 of 3.0. All arts within lint. 4 of 6 slots. 30 of 357 points, 76.8 W, taken from the non-combat half of a typical life, and More and Conditional rows are unpriced (Combat Open Question 5) |
| Validity | PASS | Real element, tier, base and realm. Lava is a Way tag (dao.md rule 2), not one of the eight variants, and it is used only on a spur |
| Stack | PASS | Forms: Increased, More, Conditional, Per. Rungs filled except Past the cap, stated. L3 and L4 empty, stated |
| Scaling | PASS | Static M 2.85, under typical 7.37, and still beats a typical. Stated power is ordinary |
| The fight | PASS | Volley fires at 2.73 s, Last Cinder 5 times, no cap hit, no `UNMODELLED` that decides anything |
| Reuse | PASS | Bare Vessel, Crit damage, Maximum linh lực, Ward efficiency. Every row has a second home |
| NPC use | PASS | Every row is a one-line number. Any generator can roll a Fire road |
| Counterplay | PASS | The Wall |
| Originality | PASS | The two heats are a common alchemist's idea, here named Mãnh Hỏa and Ôn Hỏa |

## Fight Results

Input: `sheets/fierce-fire.fight.json`, 0 plug-ins. Observations from `fight_x.py`, a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Wins on 29 % | 4 s | 3 s | none |
| typical | 1 | Loses, enemy on 97 % | 2 s | 2 s | none |
| typical | 2 | Loses, enemy on 97 % | 2 s | 2 s | none |
| top_end | 0 | Loses, enemy on 99 % | 1 s | 1 s | none |
| top_end | 1 | Loses, enemy on 100 % | 1 s | 1 s | none |
| top_end | 2 | Loses, enemy on 100 % | 1 s | 1 s | none |

Gaps 1 and 2 both meet a Deity Transformation enemy, the top of the realm list.

**Unmodelled:** crit rows also lift the basic attack, because the calculator holds one crit for a side, which flatters the fight slightly. In `-fire-ward-mixed`, Ward strength against Fire is read as +6 ws on every hit, which is slightly generous. Status chance ignores `status_resist_pct`, since the calculator has no resist.

## Questions for the User

1. **Is an all-Fire-damage road allowed to exist?** With an empty L1 it is the best buy, and 2 % per node is worth far more than any other small row. This sheet assumes a Fire road on the map mixes its rows. The rework should say so.
2. Status duration is a share of a whole number of pulses. The calculator rounds a part pulse up. Should the key?
3. The catalogue says "no linh lực". A dry enemy regains 2 % each pulse, so this sheet reads it at Bare Vessel's 5 %. Are those one threshold?
4. Is Last Cinder's kind a choice of the road, or do you want two arts?

## Also Considered

- **Slow Fire as the build:** it is a real road, but it loses the mixed enemy on 53 %, so it stands as the rival.
- **A Lava road built on Slag:** at catalogue sizes a 40 % conversion is a fair swap and no more, so it stays a spur.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Fire damage, Fire art cost, Fire art speed, crit chance with Fire, Status chance, Status duration, Damage over time, Ward strength against Fire, Lava damage | Needs key | One key shape that names a tag, as the catalogue already asks |
| Full Bellows, Thin Ward, Open Door, Heat Held, Keeping Heat, Stoked, Deep Coals, Slag and the named notables | Needs key | Keys for a cooldown threshold, an enemy pool share, an enemy status and a stack count |
| Two Heats Manual, 6 arts, Burning | Needs key | Art records and a status record |
