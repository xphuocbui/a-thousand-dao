# The Kept Hearth (Thủ Táo Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A cultivator who adapts to the enemy's element through the overcoming and generating cycles, using Conversion, the element tags and pass_tag in wards. Defined at Nascent Soul or later."
> **Direction**: The literal reading is a hit of the right colour. The stronger one is a fact about the ring: what an element feeds and what overcomes it are exactly two generating steps apart, and Combat allows exactly two conversions per hit. Love is the mood, because the same knowledge keeps a person alive.
> **Realm span**: Core Formation – Deity Transformation, defined at Nascent Soul · **Power level**: strong, with no bad element · **Use**: player build, or a wandering widow NPC
> **Fit**: 5 Fits today · 16 Needs key · 4 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: thần thức not totalled. Validity: the reference enemies carry no element, so one is assumed in the file. NPC use: nothing says how an NPC holds a five-element root and this Đạo)

## The Spine

- **The channel:** art hits, walked two steps along the generating cycle by Conversion, paid in linh lực through a common drain ward.
- **The enabler:** none. This is a stack, with a Đạo keystone as its identity. It asks for the worst root in the game and a long road to that keystone.
- **The loop:** read the element that just hit you. Your ward turns to what that element feeds, so its hits now pay you. Your arts start there, take two steps, and arrive at what puts it out.
- **The engine:** for any element E, the ward stands one step on from E, and the overcomer of E stands three. The gap is two, the conversion limit is two, and the hit keeps every tag it passed through. One rule fits all five elements.
- **The sacrifice:** the first hit always lands unread, a hand with nothing in it can never be read, and a five-element root is slow for its whole life.
- **The arc:** a useless root spent on someone else, and then the only root in the world that has no bad day.

## The Legend

In the reed country a cultivator with a five-element root, thin in everything, married a Fire prodigy whose root began to fail at a hundred and forty. Nobody treats a failing root. For sixty years this spouse turned their own qi, season by season, into whatever the other needed that week: Wood to feed the fire, Earth to carry it off when it raged, Water at the end, a little, for the fever. It was the only use anyone ever found for a root like that. They kept the hearth lit for sixty years, and then it went out.

They went to the sect that had refused the medicine. They stood in its doorway a long time, and they say it was there that they saw it: what you feed and what you put out are the same knowledge, read two steps further round the ring. The sect is not there now. Those who walk the path set two bowls at every meal, and most of them are polite. The great Fire houses keep a standing watch for anyone thin-rooted who asks what they like to eat.

## How It Fights

The first exchange tells you what they are. From the second, every art they throw at you is food: your ward blocks more of it, pays nothing for it, and half of what it blocked joins your pool. Your own hits now carry three elements, the last of which is the one that ends them. You pay for your arts in the ordinary way, with what they gave you.

**The signature moment:** a Nascent Soul specialist with every point in one element's arts opens at full strength, on a table you set the night before. Their arts are the biggest thing in the fight and they are feeding you. You finish on 67 % health and 74 % of your pool, with 970 health restored by what your pool had no room for. A cultivator with the same stack and no read ends that fight on 0 % (`variants/kept-hearth-set-table.fight.json`, then `--without turning_phase`).

## The Stack

Sizes on new modifiers are first guesses. The forced push replaced a flat stack of "more against your weak element" with the ward side of the ring. A tempo piece that shaved a timer on every turn was cut: it changed no fight. No Bare Vessel, no Full Sea, no empty slots.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Ring Step (Hoàn Bộ) | Up to 100 % of an art hit converts to the next element on the generating cycle, twice. Each part keeps every earlier tag | Conversion | art | rule 6 | ○ | Đạo, Technique | any two-element fusion build |
| Base | Long Way Round (Viễn Lộ) | +0.2 to a part's coefficient per conversion it went through | Flat base | art | none | ○ | Đạo | any Conversion build |
| Multiplier | Damage (`attack_pct`) | +160, One Ring included | Increased | any | L1 | ● | Tree | every build |
| Multiplier | One Ring (Nhất Hoàn) | A bonus to any one element's damage also applies to the other four | Redirect | art | L1 | ○ | Đạo | any multi-element build |
| Multiplier | Banked Heat (Uẩn Nhiệt) | +30 points to hits carrying two or more element tags | More | art | L2 | ○ | Technique | any fusion build |
| Multiplier | Ring's Weakest (Hoàn Nhược) | +1.5 points to arts per point of your lowest owned element's purity | Per | art | L2 | ○ | Technique | any five-element or Chaos build |
| Multiplier | Carried Tags (Kiêm Tính) | +15 points to a hit per element tag on it | Per | art | L2 | ○ | Đạo | any Conversion build |
| Multiplier | Artifact attack | +80 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Set Table (Thiết Tịch) | Foreseen fights: you read their element at t = 0, and +30 points to arts | More | art | L4 | ○ | Formation | any build that studies a target |
| Multiplier | Overcoming Stroke (Khắc Kích) | +60 points to a hit carrying the element that overcomes the target's | Conditional | art | L5 | ○ | Đạo | any single-element hunter |
| Past the cap | Still Water (Tĩnh Thủy) | A gain clipped by a full pool restores health, at half its amount. Here it reads the Fed refund | Overflow | any | none | ○ | Technique | **Reused from The Fortieth Breath** |
| Fuel | Child Steals the Mother (Tử Đạo Mẫu Khí) | A hit whose element generates your ward's phase is Fed: `pass_tag` −0.25, the ward pays nothing, and you gain half of what it blocked | Trigger | any | none | ○ | Ward, Đạo | any phased ward: a Fire ward that feeds on Wood |
| Survival | Common ward, guard | Pass 0.54, 0.36, drain 1.0, 1.5, `ws` and `we` 70, `body_guard_pct` 30 | Flat | any | none | ● | Ward, Tree | every build |
| Identity | **Turning Phase (Chuyển Hành)** | Keystone. When an element reaches you, your ward's phase becomes what it generates, and your Ring Steps start there | Rule swap | any | none | ○ | Đạo keystone | any phased ward or element-tag build |

**Identity piece:** Turning Phase. Across the five enemy elements, same stack, it lifts the worst matchup from 51 % health and 12 % pool to 71 % and 43 %, and the build stops caring what it meets. On a specialist it is the difference between 12 % and a double knockout.

**Empty rungs:** Crit is a sacrifice. Rate is a sacrifice: no art speed, because the fight is decided by what the second hit carries. Reach is the chain itself, since `pass_tag` sums every tag on the hit.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 160 | ×2.60 | `attack_pct`, element lines through One Ring |
| L2 | 120 | ×2.20 | Banked Heat 30, Ring's Weakest 45, Carried Tags 45 on a three-tag hit |
| L3 | 80 | ×1.80 | Kitchen Blade, Second Bowl |
| L4 | 0, or 30 | ×1.00, or ×1.30 | Set Table, foreseen fights only |
| L5 | 60 | ×1.60 | Overcoming Stroke, false before the first read and against an untagged enemy |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Five-element root, lowest purity raised to 30 | The Đạo needs all five, and Ring's Weakest reads the lowest. Tẩy Tủy Đan already raises the weakest element, at most three in a life, so the game has this path built in |
| Key talents | Comprehension, for a slow root and a long technique | Everything here arrives late |
| The Way (Đạo) | Way of Generation and Overcoming, to the keystone | The build's name |

## Công Pháp

### Two-Bowl Canon (Song Bát Kinh) — main, Thiên giai

Household notes in two hands, the second added in the margins after the first stops.

```json
{"id": "song_bat_kinh", "name": "Song Bát Kinh", "tier": 3, "tech_kind": "main",
 "names": ["moc", "hoa", "tho", "kim", "thuy"], "layers": 15,
 "bonuses": [{"stat": "linh_luc_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 12},
             {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "set_a_place", "unlock_layer": 3},
               {"ability_id": "bank_the_fire", "unlock_layer": 6},
               {"ability_id": "turn_the_pillow", "unlock_layer": 9},
               {"ability_id": "turn_down_the_lamp", "unlock_layer": 13}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/20 + 12/15 + 10/15 = 2.22 of 4, each within 1.5. **Harmony:** naming all five makes every auxiliary art with an element overcome something, so it runs at ×0.60 (cong-phap.md rule 12). Take a body technique as auxiliary, which is always ×1.00.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Set a Place (Thiết Vị) | Canon, 3 | qi, ring | 2.2 | 0.10 | 1 s | none | Needs key |
| Bank the Fire (Phục Hỏa) | Canon, 6 | body, ring | 2.45 | 0.10 | 2 s | none | Needs key |
| Turn the Pillow (Phiên Chẩm) | Canon, 9 | qi, ring | 2.8 | 0.11 | 3 s | none | Needs key |
| Turn Down the Lamp (Hạ Đăng) | Canon, 13 | qi, ring | 5.25 | 0.25 | 6 s | none | Needs key |

For all four: **Effect:** one hit. A ring art has no element of its own: it takes the phase of your ward and Ring Steps twice. Before any read it runs the Canon's opening chain, Wood, Fire, Earth. **Description:** things you do for someone at night, done in another room.

## Wards

**Mother-and-Child Ward (Mẫu Tử Hộ).** A common drain ward, pass 0.54 body and 0.36 qi, drain 1.0 and 1.5, that carries a phase, one element at a time. `pass_tag` −0.25 against the element that generates its phase. It keeps every cost of a drain ward against everything else, which matters: a hit from any other element drains it as usual. The phase is authored without the keystone (Metal in the file).

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | Set a Place, Bank the Fire, Turn the Pillow, Hearth Ash, Cold Road | Mother-and-Child | Conversions at 50 % each, so half of each hit stops short |
| Nascent Soul | 6 | Set a Place, Bank the Fire, Turn the Pillow, Turn Down the Lamp, Hearth Ash, Cold Road | Mother-and-Child | Conversions complete. The ring closes |
| Deity Transformation | 7 | The same, and a seventh for the fight in hand | Mother-and-Child | |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Kitchen Blade (Trù Đao) | Artifact, weapon | `phi_kiem`, trung phẩm, Thông thiên linh bảo | Most of L3. A knife that has only ever cut vegetables, until recently | Fits today |
| The Second Bowl (Đệ Nhị Bát) | Artifact, ward | `chuong`, Thông thiên linh bảo, inverted | Ward strength and efficiency. A chipped bowl from the first house. Turned over, it rings | Needs key |
| Hearth Ash Talisman (Lô Hôi Phù) | Talisman | Stock 1 | **Reused from The Turned-Away.** Refunds 15 % of maximum linh lực under 45 %, for the fight where nothing feeds you | Needs key |
| Cold Road (Hàn Lộ) | Art, escape | Slot 6 | The first thing the path teaches is when to leave | Needs key |
| Tẩy Tủy Đan | Pill | Existing | Raises the weakest element: three doses of Ring's Weakest in one life | Fits today |
| Set Table (Thiết Tịch Trận) | Formation | Foreseen only | Needs something the enemy has eaten from. It gives the read at t = 0 and L4 +30 | Needs rule |

## Đạo

### Way of Generation and Overcoming (Sinh Khắc Đạo)

- **Requirement:** all five base elements at purity 10 (rule 5).
- **`theme_stats`:** `element_affinity_pct`, `conversion_share_pct` (new), `element_ward_pct` (new, ward strength against an element your phase names).
- **Shape:** 20 nodes, branches of 7, 6 and 6, and a keystone. Art nodes follow the 2026-11-07 decision: designed now, added to data when the fight is built.
- **What the nodes say with the name hidden:** one ring and how it turns.

**The Feeding Ring (Tương Sinh).** What the ward does. 7 nodes, 80 W, mean 11.4.

| # | Node | Kind | W |
|---|---|---|---|
| 1 | +10 `element_affinity_pct` | Stat | 8 |
| 2 | Child's Share: Fed hits refund 25 % of what is blocked | Passive T1 | 10 |
| 3 | +8 `element_ward_pct` | Stat | 8 |
| 4 | Child Steals the Mother: the refund is 50 %, and a Fed hit drains nothing | Passive T2 | 18 |
| 5 | +10 `element_affinity_pct` | Stat | 8 |
| 6 | Set a Place, as an art node for anyone without the Canon | Art T1 | 10 |
| 7 | Known Tastes: a read from Set Table holds through a blind fight once a season | Passive T2 | 18 |

**The Checking Ring (Tương Khắc).** What the hit does. 6 nodes, 72 W, mean 12.0.

| # | Node | Kind | W |
|---|---|---|---|
| 1 | +25 `conversion_share_pct` on the first step | Stat | 8 |
| 2 | Bank the Fire, as an art node | Art T1 | 10 |
| 3 | Ring Step: a second step on the generating cycle | Passive T2 | 18 |
| 4 | +25 `conversion_share_pct` on the second step | Stat | 8 |
| 5 | Overcoming Stroke | Passive T2 | 18 |
| 6 | Long Way Round | Passive T1 | 10 |

**The Turned Ring (Tương Vũ).** When the weak element insults its master. 6 nodes, 72 W, mean 12.0.

| # | Node | Kind | W |
|---|---|---|---|
| 1 | +10 `element_affinity_pct` | Stat | 8 |
| 2 | One Ring | Passive T2 | 18 |
| 3 | +8 `element_ward_pct` | Stat | 8 |
| 4 | Carried Tags | Passive T1 | 10 |
| 5 | Insult (Tương Vũ): the middle tag of a chain is the element the target overcomes. A negative `pass_tag` on that tag counts as 0 | Passive T2 | 18 |
| 6 | Turn Down the Lamp, as an art node | Art T1 | 10 |

**Keystone: Turning Phase (Chuyển Hành).** T3 with a 4 W line, 34 W. When an art carrying an element reaches you, your ward's phase becomes the element it generates, from your next hit on. Your Ring Steps start from that phase, so they end at its overcomer. Reads one element at a time, the last one. No cap moves.

**Lint (Formulas D1), first guess:** total 258 W over 20 nodes, mean 12.9, inside 11.2 to 13.7. Branch means 11.4, 12.0, 12.0, inside 9.9 to 14.9. Keystone routes R(A) 130 W over 10 nodes (13.0), R(B) and R(C) 122 W over 9 (13.6), all at least 11.2. `conversion_share_pct` and `element_ward_pct` weights are guesses at 8 W a line.

**NPC effect:** the Đạo's power multiplier under rule 11, as for any other. Its signature only runs in a full duel.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Core Formation | Half-walked hits, a ward that learns | Keystone, conversions at 50 % | You have outlived the person you learned this for, or you are still learning it for them |
| Nascent Soul | The ring closes: three tags on every hit | Conversions at 100 %, Turn Down the Lamp | You catch yourself setting two bowls |
| Deity Transformation | The same, and no element frightens you | Slot 7 | The Fire houses stop writing to you |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Any single element, same realm | Wins at 2 to 3 s, 71 to 80 % health | The ring has no bad side |
| One-element specialist | Wins on 12 %, or 67 % with Set Table | Their size is your food |
| Three-element enemy | Wins, 71 % | The fight ends before the third arrives |
| Ring-walker (all five, in generating order) | Wins a double knockout on overkill, 0 Fed hits | Your ward is always one step behind |
| Hands only (no arts) | Wins on 60 %, keystone does nothing | No element, nothing to read |
| One realm up | Loses, with the pool still half full | See the third surprise |
| One realm up, Set Table, conserving enemy | Wins at 3 s on 24 % | The read is worth a realm here |
| Mirror | Loses a double knockout at 2 s as the requesting side | |
| Top-end, any | Loses at 1 s | Expected |

**Counter:** a body-crusher who never uses an art (Combat rule 18), and a Five Phases Cycle cultivator (catalogue keystone) whose arts fire in generating order. A bare-hit cultivator such as The Struck Name should also beat it, by the same reading: `unmodelled`, no duel run.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Canon 2.22 of 4. All four arts within lint, Long Way Round adds on top by design. Slots 5 of 6 in the file, with the escape listed. Thần thức not totalled |
| Validity | NOT ASSESSED | Ids, tier, base and root are real, tier 3 reaches Deity Transformation. But the reference enemies have no element, so `assumed_enemy_element` supplies one, and the merge's mixed run reads that same assumption |
| Stack | PASS | Ten forms, every rung filled or named, identity test changes the result |
| Scaling | PASS | `m_static` 4.68, a ring art ×16.5 and ×21.4 with Set Table, against typical 7.37 and top-end 256. INFO: above typical, as a strong build should be |
| The fight | PASS | 60 of 60 constants. `fed_hits` and `turned` show the loop running. Plug-ins: `element_tags`, `turning_phase`. Turn Down the Lamp, at 6 s, fires only in the boss run, where it lands the last blow: it is for a fight this build does not usually have |
| Reuse | PASS | Still Water and Hearth Ash Talisman reused. Ring Step and Carried Tags serve seed 50 and seed 54 |
| NPC use | NOT ASSESSED | Each piece is one Breakdown line. How an NPC comes by the root and the Đạo is open |
| Counterplay | PASS | Fists and the ring-walker, both run |
| Originality | PASS | Tương sinh, tương khắc, tương vũ and tử đạo mẫu khí are common five-phase and medical terms, not any work's |

## Fight Results

Observations from `fight_x.py`, a paper model. `main` is `sheets/kept-hearth.fight.json`. It is not prepared, and it assumes a Fire enemy.

| Enemy | File, flags | Result | Time | Own health, pool | Enemy health |
|---|---|---|---|---|---|
| typical | main | Win | 2 s | 72 %, 65 % | 0 % |
| typical, no keystone | main, `--without turning_phase` | Win | 2 s | 66 %, 42 % | 0 % |
| typical, one up | main, `--gap 1` | Loss | 3 s | 0 %, 53 % | 23 % |
| typical, two up | main, `--gap 2` | Loss | 3 s | 0 %, 53 % | 50 % |
| top_end, all gaps | main | Loss | 1 s | 0 % | |
| Mixed | `variants/kept-hearth-mixed.fight.json` | Win | 2 s | 77 %, 65 % | 0 % |
| Mixed, one up | same, `--gap 1` | Loss | 3 s | 0 %, 83 % | 54 % |
| Specialist | `variants/kept-hearth-specialist.fight.json` | Win | 2 s | 12 %, 75 % | 0 % |
| Specialist, no keystone | same, `--without turning_phase` | Win by overkill | 2 s | 0 %, 0 % | 0 % |
| Specialist, Set Table | `variants/kept-hearth-set-table.fight.json` | Win | 2 s | 67 %, 74 % | 0 % |
| Same, no keystone | same, `--without turning_phase` | Win by overkill | 2 s | 0 %, 0 % | 0 % |
| Mixed, Set Table | `variants/kept-hearth-set-table-mixed.fight.json` | Win | 2 s | 85 %, 73 % | 0 % |
| Mixed, Set Table, one up | same, `--gap 1` | Win | 3 s | 24 %, 83 % | 0 % |
| Same, no Overcoming Stroke | `variants/kept-hearth-set-table-no-overcoming.fight.json`, `--gap 1` | Loss | 4 s | 0 %, 75 % | 8 % |
| Same, no Still Water | `variants/kept-hearth-set-table-no-still-water.fight.json`, `--gap 1` | Win | 3 s | 2 %, 83 % | 0 % |
| Fire ward | `variants/kept-hearth-fire-ward.fight.json` | Win | 3 s | 71 %, 43 % | 0 % |
| Fire ward, no keystone | same, `--without turning_phase` | Win | 3 s | 68 %, 42 % | 0 % |
| Three elements | `variants/kept-hearth-many-elements.fight.json` | Win | 3 s | 71 %, 43 % | 0 % |
| Ring-walker | `variants/kept-hearth-ring-walker.fight.json` | Win by overkill | 2 s | 0 %, 0 % | 0 % |
| Ring-walker, no keystone | same, `--without turning_phase` | Win | 3 s | 15 %, 0 % | 0 % |
| Boss ×6, mixed | `variants/kept-hearth-boss-x6.fight.json` | Win | 6 s | 39 %, 12 % | 0 % |
| Fists | `variants/kept-hearth-fists.fight.json` | Win | 3 s | 60 %, 34 % | 0 % |
| Fists, one up | same, `--gap 1` | Loss | 3 s | 0 %, 0 % | 83 % |
| Mirror | `variants/kept-hearth-mirror.fight.json` | Loss on overkill | 2 s | 0 %, 0 % | 0 % |
| Core Formation, conversions at 50 % | `variants/kept-hearth-core.fight.json` | Win | 2 s | 69 %, 64 % | 0 % |
| Deity Transformation | `variants/kept-hearth-deity.fight.json` | Win | 2 s | 76 %, 67 % | 0 % |
| Deity Transformation, mixed | `variants/kept-hearth-deity-mixed.fight.json` | Win | 2 s | 81 %, 67 % | 0 % |

**The five elements.** Stout enemy (larger pools), same stack, `variants/kept-hearth-stout-[element].fight.json`.

| Enemy element | With Turning Phase | Without (`--without turning_phase`) |
|---|---|---|
| Wood (`moc`) | 3 s, 71 %, pool 43 % | 3 s, 51 %, pool 12 % |
| Fire (`hoa`) | 3 s, 71 %, pool 43 % | 3 s, 51 %, pool 12 % |
| Earth (`tho`) | 2 s, 80 %, pool 81 % | 2 s, 80 %, pool 81 % |
| Metal (`kim`) | 2 s, 77 %, pool 65 % | 2 s, 73 %, pool 49 % |
| Water (`thuy`) | 2 s, 77 %, pool 65 % | 2 s, 73 %, pool 49 % |

**The surprises:**

1. **The ring has a built-in length.** This came from the data, not the calculator. In `character_elements.json`'s cycle, the overcomer of E is three steps on and what E feeds is one. So the distance is two, for every element, and Combat's limit of 2 conversions per hit is exactly enough. The middle step is always the element E overcomes, which is why the Turned Ring exists: your hit has to walk through the one thing they beat.
2. **Adapting can lose to someone who adapts faster.** An enemy firing five elements in generating order is always one step ahead: the ward reads hit N, and hit N + 1 is the element the ward has just turned into, so it never feeds. With the keystone there are 0 Fed hits and the fight ends in a double knockout. Without it, a ward that simply stands still is Fed twice and lives on 15 %. Standing still beats adapting, against the one enemy who walks the ring.
3. **It dies rich.** One realm up it loses with 83 % of its pool left. What kills it is the first hit, which is unread, and the basic attack, which has no element under rule 13 and which no ward can turn to. All that food, and nowhere to spend it in time.
4. **Knowing them is worth a realm.** Against the conserving enemy one realm up, Set Table turns a loss with the enemy on 54 % into a win on 24 % health. It is the only piece of preparation in this campaign that is information and not a coating.
5. **Resistance can hurt the resister.** Against a Fire ward that resists Fire, the keystone barely matters (71 % against 68 %). A hit the ward resists is one it blocks more of and pays more for, so a drain ward's own strength runs it dry. The Deepest Well is built on the same fact.

**Unmodelled:** Insult, because no reference ward resists a chain's middle tag. Cold Road, because the calculator has no escape. Harmony, outside the fight. Duels with The Struck Name.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Turning Phase | Needs rule | Combat rules 6 and 22: a ward's phase and a conversion's target may change in a fight, read from the last element that reached the side |
| Child Steals the Mother, Mother-and-Child Ward | Needs rule | Formulas D: a ward record with a phase and a Fed term. A hit may pay in place of draining |
| Still Water | Needs rule | As The Fortieth Breath asks, widened to a refund |
| Set Table | Needs rule | Combat Open Question 4: what a side may know of the enemy before the fight |
| Ring Step, `conversion_share_pct` | Needs key | A conversion on the generating cycle, in rule 6's fixed order |
| Long Way Round, Carried Tags, Banked Heat, Ring's Weakest, Overcoming Stroke, One Ring | Needs key | Keys for tag counts, lowest purity, a target's element and one Redirect |
| Way of Generation and Overcoming, Two-Bowl Canon, the four arts, Hearth Ash Talisman, Cold Road, The Second Bowl | Needs key | New content, and an element on every compiled profile |

**Questions for the user:** Should every enemy's compiled profile carry a main element, so tags matter against a plain enemy? Should a basic attack ever carry an element without Elemental Fist? The fists counter depends on no. Is a five-element root meant to be a real path to power, as this assumes?

## Also Considered

- **The Sick Ring (Mẫu Bệnh Đạo):** curses that travel along the generating cycle, the mother's sickness reaching the child. Good lore, and most of it came across as the Đạo's language.
- **The Five-Hour Clock (Ngũ Thời Đạo):** arts firing in generating order for a stacking bonus. It is the catalogue's Five Phases Cycle, and it became this build's counter.
