# The Deepest Well (Thâm Tỉnh Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Ward drain as the win condition, with the common drain ward on and arts paid in linh lực: every choice is about what the pool is for. Greed as the mood. No clerk, ledger, court or register."
> **Direction**: A deeper well lowers every well around it. What their ward pays runs into your pool, and the pool is ward and weapon at once. The creditor of the backlog became a thirst.
> **Realm span**: Foundation Establishment – Nascent Soul · **Power level**: strong, and beats one realm up only against an enemy who saves · **Use**: player build, or a rogue family of well-borers
> **Fit**: 5 Fits today · 12 Needs key · 5 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: The Whole Bucket's cost sits outside Formulas E's range and thần thức is not totalled. Scaling: M moves with the fight, so `m_static` undersells it. NPC use: the generator has no way yet to choose a guard line)

## The Spine

- **The channel:** ward drain. Hits exist to make the enemy's ward pay. Qi hits burn most, all five layers count, and the kill arrives when the pool is gone.
- **The enabler:** Water Table. Opens a share of everything the enemy's ward pays, into your pool. Closes your own spring: your linh lực does not regenerate in a fight.
- **The loop:** salt their ward so it blocks more and pays more, draw, then tip the whole bucket into them the moment your pool crosses your line.
- **The engine:** one point of linh lực is ward, ammunition and income at once. Pouring empties your ward and makes room to draw, and the pour's own drain refills you in the same instant.
- **The sacrifice:** no regeneration, no crit, and nothing to drink from an enemy who has no drain ward.
- **The arc:** at first the well is a way to survive a stronger neighbour. By the end the player is setting a line on a pool that is mostly other people's.

## The Legend

In the brine country wells are bored by hand, with a bamboo rod and a falling weight, a hand's width a day for three generations. A deeper well lowers every well near it. Everybody there knows this, which is why the neighbours of the deepest family stopped speaking to them in the ninth year of the drought and had stopped living there by the twelfth. The family went on boring. Some time after the valley emptied, one of them noticed that linh lực behaves as brine does: it runs to the lowest place, and a body can be made lowest.

The sects write the name with the other character, *tham* for greed in place of *thâm* for deep, and the walkers do not correct them. Any sect with a spirit vein has a standing order to fill in a shaft on sight, because one bore beside a vein lowers it for a century. Those who walk the path are always a little thirsty. They will tell you it passes.

## How It Fights

At one second the salt goes in and two buckets fall. The enemy's ward, stronger than it has ever been, blocks nearly everything and pays for all of it, and that linh lực arrives in your pool. At two seconds, if your pool stands above your line, the whole of it goes back at them in one blow. Their ward tries to block that too, cannot pay, and the part it could not pay comes out of the body.

**The signature moment:** a Foundation cultivator faces a Core Formation elder who has fought carefully and saved their linh lực. At 1 s the elder holds 64 % and the well 59 %. At 2 s the elder's ward has burned 1,387 linh lực and the elder is dead. The well has drawn 638, more than the 618 it started with, and stands on 22 % health with 42 % of its pool (`variants/deepest-well-mixed.fight.json`, `--gap 1 --timeline`).

## Enabler

**Water Table (Thủy Mạch)**, the first divine ability of the Deep Bore Sutra. Loop opener.

- **Opens:** of the linh lực a target's ward pays for your hit, you gain 0.36 of it, up to your maximum. Salt and a bored shaft raise the share.
- **Closes:** your linh lực does not regenerate in a fight, so `regen_bonus_pct` is −2 in the file. An enemy who pays nothing leaves you with what you brought.
- **Found:** a sutra recovered from a shaft nobody has reached the bottom of. Its last pages are the depth records of one family, in a hand that gets worse.

## The Stack

Sizes on new modifiers are first guesses. The forced push replaced a plain qi stack with Sweet Ward and Scraping the Well, and it cut a stored-overflow piece: a draft kept the draw a full pool could not hold and added it to the next pour, and the pool stopped mattering, which walked straight out of rule 11. It is gone, so a full pool now simply wastes the draw. You have to spend before you can receive.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Head of Water (Thủy Đầu) | An art may pay everything above a keep line it names. Its coefficient is the art lint's value for what it paid | Rule swap | art | none | ○ | Technique | any one-blow burst build |
| Rate | Rush Order (Cản Đơn) | +50 % price: the art's first firing comes at half its cooldown | Timing | art | none | ○ | Technique | **Reused from The Full Price** |
| Multiplier | Damage (`attack_pct`) | +80 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Long Rope (Trường Sách) | +40 points to arts with the rope form | More | art | L2 | ○ | Technique | any chain or whip build |
| Multiplier | Rich Seam (Phú Mạch) | +0.5 points to arts per 1 % the target's maximum linh lực exceeds yours, up to +60 | Per | art | L2 | ○ | Sealed cluster | any realm-crosser, any boss hunter |
| Multiplier | Bulk Order (Phê Lượng) | +25 points to an art per full share of its cost | Per | art | L2 | ○ | Sealed cluster | **Reused from The Full Price** |
| Multiplier | Artifact attack | +60 from the gourd | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Bored Shaft (Toản Tỉnh) | Foreseen fights: +25 points to all hits and +0.10 to Water Table, from a shaft sunk at the place of the fight | More | any | L4 | ○ | Formation | any fighter who picks the ground |
| Multiplier | Longer Breath (Trường Tức) | +50 points to hits while your linh lực share is above the target's. A lead of 0 is this sheet's grade: The Long Carry holds the same modifier at a lead of 10, and one lead would change fights | Conditional | art, basic | L5 | ○ | Sealed cluster | **Reused from The Long Carry** |
| Reach | Sweet Ward (Cam Hộ) | A curse may strengthen a ward: `pass_raise` −0.4, so it blocks more and pays for it | Trade | ward drain | none | ○ | Art | a support who wards an ally |
| Past the cap | Scraping the Well (Quát Tỉnh) | When a drain ward's pool cannot pay what a hit asks, the unpaid linh lực lands on health, past body guard | Overflow | ward drain | none | ○ | Technique | any ward-breaker |
| Fuel | Thrift (Tiết Dụng) | A quarter of your ward efficiency also counts as `art_cost_pct`, inside its 50 % limit | Redirect | art | none | ○ | Sealed cluster | **Reused from The Long Carry** |
| Survival | Common ward, body guard | Pass 0.54, 0.36, drain 1.0, 1.5, `ws` and `we` 40, `t_b` 0.5, `body_guard_pct` 30 | Flat | any | none | ● | Ward, Tree | every build |
| Identity | **Water Table (Thủy Mạch)** | A share of what a target's ward pays for your hit joins your pool, up to your maximum | Trigger | ward drain | none | ○ | Technique | any leech or linh lực thief |

**Identity piece:** Water Table. Against the conserving enemy one realm up, removing it turns a win at 2 s on 22 % health into a loss at 3 s with the enemy on 85 %. Against a same-realm miser it turns a win at 2 s into a loss at 6 s.

**Empty rungs:** Crit is a sacrifice: a chance has no place in a line you set before the fight. Rate is thin on purpose, because art speed would move the pour off the second it was chosen for.

**Bare Vessel and Full Sea are not used.** L5 is Longer Breath, a condition that compares two pools.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 80 | ×1.80 | `attack_pct` |
| L2 | 40 to 125 | ×1.40 to ×2.25 | Long Rope 40, Rich Seam up to 60, Bulk Order 25 on The Whole Bucket |
| L3 | 60 | ×1.60 | Well-Mouth Gourd |
| L4 | 25 | ×1.25 | Bored Shaft. 0 in a blind fight |
| L5 | 0 or 50 | ×1.00 or ×1.50 | Longer Breath, which flips as the pools cross |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth at purity 75 or more, with Salt | Salt gives the draw and the efficiency, and Earth is its requirement |
| Key talents | Physique, for a body that outlasts the first second | The ward spends itself: health is what is left |
| The Way (Đạo) | None needed | The build lives on technique, cluster and root |

### New variant root: Salt (Diêm)

- **Origin:** Transmutation (Chuyển Hóa). **Requirement:** owns Earth. Earth purified to salt. Rolls and purity follow rule 10: `transmutation_factor` × Earth purity ÷ 100, purity 0.8 × Earth purity.
- **Effects per purity point:** +0.20 `ward_draw_pct` (new key, a Water Table share in points), +0.15 `ward_efficiency_pct`, −0.10 `tam_ma_resist_pct`.
- **At purity 60:** +12 draw, +9 ward efficiency, −6 heart-demon resistance.
- **Price (Formulas E, first guess):** `ward_draw_pct` at 1.5 W a point, `ward_efficiency_pct` at 1 W. At purity 50: 15 + 7.5 − 7.5 = 15 W. At 100: 30 W. Inside the common band of 10 to 30 W.
- **What it costs:** salt draws water out of everything it touches, including the mind. It is the only variant that makes a character worse at something.
- **Without Water Table:** a cheaper drain ward, which any ward cultivator wants, at a heart-demon price. So it is not a one-build root.
- **Sector (rule 12):** a hidden variant sector, its contents left to the tree rework.

## Công Pháp

### Deep Bore Sutra (Thâm Toản Kinh) — main, Địa giai

A boring manual with the words for water and for linh lực used interchangeably, and no sign the writer noticed.

```json
{"id": "tham_toan_kinh", "name": "Thâm Toản Kinh", "tier": 2, "tech_kind": "main",
 "names": ["tho", "thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 15}, {"stat": "defense_pct", "value": 10}],
 "abilities": [{"ability_id": "water_table", "unlock_layer": 1},
               {"ability_id": "lowered_bucket", "unlock_layer": 2},
               {"ability_id": "salted_well", "unlock_layer": 4},
               {"ability_id": "cold_bucket", "unlock_layer": 5},
               {"ability_id": "whole_bucket", "unlock_layer": 7},
               {"ability_id": "drawn_rope", "unlock_layer": 10}],
 "seal_clusters": ["dry_courses"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/20 + 10/15 = 1.42 of 3, each within 1.5. Water Table grows to 0.42 at layer 12.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Salted Well (Diêm Tỉnh) | Sutra, 4 | curse, Earth | none | 0.09 | 2 s, Rush Order | none | Needs rule |
| Lowered Bucket (Cấp Thủy) | Sutra, 2 | qi, rope, Water | 1.6 | 0.05 | 1 s | none | Needs key |
| Cold Bucket (Hàn Tuyền) | Sutra, 5 | body, rope, Water | 1.6 | 0.05 | 1 s | none | Needs key |
| The Whole Bucket (Khuynh Tỉnh) | Sutra, 7 | qi, rope, Water | lint value of what it paid | all above the keep line | 2 s | own linh lực above your line | Needs rule |
| Drawn Rope (Khiên Sách) | Sutra, 10 | qi, rope, Earth | 2.46 | 0.08 | 3 s | none | Needs key |

**Salted Well.** **Effect:** curse, 3 pulses: drain raise +50 % (exists) and `pass_raise` −0.4 (Sweet Ward). Cost includes Rush Order's +50 %, so it fires at 1 s. **Description:** you do not poison the water. You make it taste better.

**The Whole Bucket.** **Effect:** pays everything above its keep line when it resolves. `c_art` = 1 + 12 × paid + 0.25 × (cooldown − 1). The build's two settings are its guard, your line, and its keep. **Description:** a bucket has no use half way up.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Salted Well, Lowered Bucket, Cold Bucket, The Whole Bucket | Common drain | Line 0.5, keep 0 |
| Core Formation | 5 | Add Drawn Rope | Common drain | |
| Nascent Soul | 6 | Add an escape art | Common drain | The sixth slot is the first thing you have ever kept in reserve |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Well-Mouth Gourd (Tỉnh Khẩu Hồ Lô) | Artifact, weapon | `ho_lo`, trung phẩm, Pháp bảo | L3 60. Cut from the rim of a dry well in a valley with nobody in it | Fits today |
| Plain armour | Artifact, body | `giap`, hạ phẩm, Pháp bảo | Body guard, cheap in thần thức | Fits today |
| Bored Shaft (Toản Tỉnh Trận) | Formation | Foreseen only | L4 +25 and +0.10 draw. Ruins the ground for ten seasons, and if the ground is somebody's, that is a feud | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Dry Courses, to Rich Seam | Notable | The way up against a bigger pool | Needs key |
| 2 | Ward efficiency, ward strength | Small | Thrift turns efficiency into cheaper arts | Fits today |
| 3 | Longer Breath | Notable | Fills L5 | Needs key |

### Hidden cluster idea: Dry Courses (Can Mạch)

Theme: linh lực and wards. Earth affinity. Sealed by a technique (`seal_clusters`), outer, size 9. Small acupoints: ward efficiency, maximum linh lực, qi damage. Notables in order: Thrift, Rich Seam, Longer Breath, the payoff farthest from the entry. No capability. Bulk Order sits on a small branch. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | One pour at 2 s, aimed at whoever is above you | The Whole Bucket | The first time you draw more than you started with, you notice you are not tired |
| Core Formation | The same, and a pour every two seconds in a long fight | Drawn Rope, Dry Courses | A sect fills in your first shaft and tells you why |
| Nascent Soul | The line is set per enemy, and the same art kills two kinds of people | Water Table at 0.42 | Someone asks what the water is for. You have stopped being able to answer |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Conserving enemy, same realm | Wins at 2 s | Spends nothing it needs to |
| Conserving enemy, one up | Wins at 2 s on 22 % | Their saved pool is the fuel |
| Spendthrift fixture, one up | Loses a double knockout at 3 s | They spend their own pool, so 480 is drawn in place of 638 and the pour never fires |
| Miser (big pool, heavy ward), same realm | Wins at 2 s on 76 % | The richest prey there is |
| Per-hit ward | Loses at 4 s | Salted Well strengthens a ward whose price is fixed. Take it out of the loadout and the same fight is a win at 2 s |
| Thể tu, ward off | Loses at 3 s, enemy on 42 % | Nothing to drink, no regeneration, one pool |
| Soul piercer, same realm | Wins on 37 % | Soul skips the ward but cannot outrun 2 s. One up it loses, enemy on 39 % |
| Top-end, any | Loses at 1 s | Expected |

**Counter:** a thể tu with no ward (Combat rule 18's body-crusher), a per-hit ward, or simply a reckless spender one realm up. You cannot draw from a dry neighbour, and this build has no spring of its own.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Sutra 1.42 of 3. The two plain arts are within lint, and slots are 4 of 4. The Whole Bucket pays above Formulas E's 0.04 to 0.25 and its lint line is by construction. Thần thức is not totalled |
| Validity | PASS | `tho`, `thuy`, `ho_lo`, `giap`, tier 2 reaches Nascent Soul, realm ids real |
| Stack | PASS | Ten forms, all ladder rungs filled or named, identity test changes the result |
| Scaling | NOT ASSESSED | `m_static` 3.60 against typical 4.19 and top-end 148, but a hit carries up to ×12 with L2 and L5, and the pour's coefficient moves. INFO: it beats one realm up against a saver |
| The fight | PASS | 60 of 60 constants. Every art fires. `water_table_clipped_by_full_pool` is the only cap hit, and it is the point. The `longer_breath_hits` lines count hits, not caps. Plug-ins: `well_rules`, `breath_lead`, `per_cap` |
| Reuse | PASS | Rush Order, Bulk Order, Thrift and Longer Breath reused. Every new modifier has a second home outside this build |
| NPC use | NOT ASSESSED | Each piece is one Breakdown line, but the generator must choose a line and a keep, and no rule says how |
| Counterplay | PASS | Thể tu and per-hit ward, both run |
| Originality | PASS | Well-boring and the deep and greedy pun are real-world, and no name is taken from a work |

## Fight Results

Observations from `fight_x.py`, a paper model. `main` is `sheets/deepest-well.fight.json`.

| Enemy | File, flags | Result | Time | Own health, pool | Enemy health |
|---|---|---|---|---|---|
| typical | main | Win | 2 s | 72 %, 0 % | 0 % |
| typical, one up | main, `--gap 1` | Loss, double knockout on overkill | 3 s | 0 %, 15 % | 0 % |
| typical, two up | main, `--gap 2` | Loss | 1 s | 0 % | |
| top_end, all gaps | main | Loss | 1 s | 0 % | |
| Mixed | `variants/deepest-well-mixed.fight.json` | Win | 2 s | 57 %, 0 % | 0 % |
| Mixed, one up | same, `--gap 1` | Win | 2 s | 22 %, 42 % | 0 % |
| Mixed, one up, no Water Table | same, `--gap 1 --without water_table` | Loss | 3 s | 0 % | 85 % |
| Mixed, one up, no Scraping | same, `--gap 1 --without scrape_share` | Win | 3 s | 6 %, 11 % | 0 % |
| Mixed, one up, no Longer Breath | same, `--gap 1 --without "Longer Breath"` | Loss | 3 s | 0 % | 85 % |
| Mixed, one up, no Rich Seam | same, `--gap 1 --without "Rich Seam"` | Loss | 3 s | 0 % | 85 % |
| Mixed, one up, no Salted Well | same, `--gap 1 --without salted_well` | Loss | 3 s | 0 % | 64 % |
| Miser | `variants/deepest-well-miser.fight.json` | Win | 2 s | 76 %, 64 % | 0 % |
| Miser, no Water Table | same, `--without water_table` | Loss | 6 s | 0 % | 24 % |
| Boss ×4 | `variants/deepest-well-boss-x4.fight.json` | Win | 2 s | 76 %, 48 % | 0 % |
| Blind, mixed | `variants/deepest-well-blind.fight.json` | Win | 2 s | 57 %, 0 % | 0 % |
| Blind, mixed, one up | same, `--gap 1` | Loss | 3 s | 0 % | 85 % |
| Per-hit ward | `variants/deepest-well-per-hit.fight.json` | Loss | 4 s | 0 % | 31 % |
| Per-hit ward, no Salted Well | `variants/deepest-well-per-hit-no-lick.fight.json` | Win | 2 s | 61 %, 0 % | 0 % |
| Thể tu | `variants/deepest-well-the-tu.fight.json` | Loss | 3 s | 0 % | 42 % |
| Soul piercer | `variants/deepest-well-soul.fight.json` | Win | 2 s | 37 %, 0 % | 0 % |
| Soul piercer, one up | same, `--gap 1` | Loss | 3 s | 0 %, 4 % | 39 % |
| Nascent Soul, fixture | `variants/deepest-well-nascent.fight.json` | Win | 2 s | 76 %, 0 % | 0 % |
| Nascent Soul, fixture, one up | same, `--gap 1` | Win | 3 s | 17 %, 6 % | 0 % |
| Nascent Soul, mixed | `variants/deepest-well-nascent-mixed.fight.json` | Win | 2 s | 78 %, 0 % | 0 % |
| Nascent Soul, mixed, one up | same, `--gap 1` | Win | 2 s | 43 %, 38 % | 0 % |
| Nascent Soul, mixed, one up, no Water Table | same, `--gap 1 --without water_table` | Loss | 3 s | 0 % | 86 % |

**What the pool is for: the line and the keep.** Both are settings on one art, chosen before the fight. Same stack, mixed enemy.

| Setting | File | Same realm (no flag) | One up (`--gap 1`) |
|---|---|---|---|
| Line 0.5, keep 0 | `variants/deepest-well-mixed.fight.json` | Win, 57 %, pool 0 % | Win at 2 s, 22 %, pool 42 % |
| Line 0.5, keep 0.35 | `variants/deepest-well-keep-a-third.fight.json` | Win, 76 %, pool 22 % | Win at 3 s, 6 %, pool 46 % |
| Line 0.5, keep 0.5 | `variants/deepest-well-keep-half.fight.json` | Win, 76 %, pool 37 % | Win at 3 s on overkill, 0 %, pool 30 % |
| Line 0.6, keep 0 | `variants/deepest-well-tight-line.fight.json` | Win, 57 %, pool 0 % | Loss at 3 s, enemy on 13 % |
| Line 0.85, keep 0 | `variants/deepest-well-greedy-line.fight.json` | Win, 76 %, pool 70 % | Loss at 3 s, enemy on 13 % |

**The surprises, from the calculator:**

1. **Greed is correct against an equal and fatal against a better.** Line 0.85 is the best setting in the table at the same realm, because the pour never has to fire. One realm up it dies with the enemy on 13 %, since a pool under fire never reaches it. Line 0.5 is what wins. Nothing in the stack changes. The whole build is one number you must set before you know how frightened to be.
2. **A careful enemy is the easy one.** The critic warned that the fixture flatters a build because it bankrupts itself. Here it is the harder test: one realm up the build wins against the enemy who saves and loses a double knockout to the enemy who spends, because what they spend on themselves is water you did not get.
3. **Scraping the Well is the biggest line in the log and the least necessary piece.** It is 49 % of the health damage one realm up (`variants/deepest-well-mixed.fight.json`, `--gap 1`), and without it the build still wins. Water Table, Longer Breath, Rich Seam and Salted Well each flip that fight, because each is what puts the pool over the line at 2 s.
4. **Salted Well is a slot decision.** It is the best art here against a drain ward and turns a win into a loss against a per-hit ward.

**Unmodelled:** Salt's heart-demon cost and the ruined ground of a Bored Shaft, which act outside the fight. The file's `unmodelled` list states what is folded in.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Water Table | Needs rule | Combat rule 11 and Formulas D: a hit's drain may credit the attacker's pool, up to its maximum |
| Head of Water, The Whole Bucket | Needs rule | Combat rule 13 and Formulas E: an art whose cost is what stands above a line, outside 0.04 to 0.25, with the lint read at firing |
| Sweet Ward, Salted Well | Needs rule | Combat rule 8: a curse may raise a defence. Also a negative `pass_raise`, with a floor |
| Scraping the Well | Needs rule | Formulas D: unpaid drain reaches health. Today the excess only leaks |
| Rush Order | Needs rule | As asked by The Full Price |
| Long Rope, rope form | Needs key | A new form tag in rule 6 |
| Rich Seam, Longer Breath, Thrift, Bulk Order | Needs key | Reads of the enemy's `qi_max`, a two-pool comparison, and a key link from `ward_efficiency_pct` to `art_cost_pct` |
| Salt | Needs key | A ninth variant, `ward_draw_pct`, a sector, and an entry in `character_elements.json` |
| Deep Bore Sutra, arts, Bored Shaft, Dry Courses | Needs key | New content |

**Questions for the user:** Should a guard line be something a player tunes as a number, or a few set choices? Should a curse ever be allowed to make a ward stronger? Does a resisted hit that drains more than an unresisted one sit well with you? The build depends on yes.

## Also Considered

- **The Salt Debt (Diêm Trái):** costs paid as a share of what is left, so the pool never empties. It kept the tension and lost the kill.
- **The Parched Field (Hạn Điền):** a burn tick that starves the ward slowly. A clock, and clocks are this campaign's most used escape.
