# The Wedding Furnace (Hỉ Lô Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "An alchemist whose furnace is a weapon, with joy in the craft rather than gloom. Preparation and L4 should be the real game, not a renamed coating. Reuse existing coatings rather than making a fifth."
> **Direction**: A five-course feast. The four coatings already in the ledger map onto four of the five elements, and the furnace's own fire is the fifth, so no new coating is needed.
> **Realm span**: Foundation Establishment – Nascent Soul · **Power level**: strong when foreseen, weak when blind · **Use**: player build, or a wandering cook NPC
> **Fit**: 3 Fits today · 12 Needs key · 2 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED. The cost of a meal in goods is not priced: Combat leaves that to crafts, and no coating has a recipe yet.

## The Spine

- **The channel:** art hits from one furnace art, then a scald tick from what overflows L4.
- **The enabler:** the Open-Door Furnace. It opens Five Courses. It closes the coatings for anything else: what goes in the furnace is on no blade.
- **The loop:** before the fight, choose the courses and their order. In the fight, serve them one by one, each carrying everything the last one had.
- **The engine:** L4 is no longer a flat bonus. It climbs through the fight, and the order you loaded decides how fast.
- **The sacrifice:** L5, and every fight nobody announced. Blind, the furnace has only its own fire, and when the table is cleared it stops.
- **The arc:** from a three-course supper to a full feast, from a cook who fights to a fighter everyone hopes will cook.

## The Legend

The first of these furnaces was a copper stove on a cook's back, carried between river towns for weddings. A wedding feast there runs five courses in the order the elements feed each other, and a good cook starts three days ahead. One night men came to take the bride's dowry. The cook was on the fourth course, and in no mood to waste it. They opened the door. The story is told at weddings now, and it always gets a laugh, because the cook then finished service.

Those who walk this path are the happiest people in any sect that will have them. They grow their own herbs, argue about ash, and sing while they stir, and their households are full of apprentices who eat well. The great alchemy halls call it a waste of good coatings. Every cook knows how the old stories end: not with a stronger enemy, but with someone at the kitchen door who did not send word.

## How It Fights

The door opens in the first second, and the first course is only a good one. Each plate after it keeps everything the last plate had, so by the third the hit carries as much preparation as a top-end cultivator's. Past that the cap clips, the pot boils over, and the enemy starts to scald. Meanwhile a small flame ticks along under it all. **The signature moment:** the opening Breakdown reads like a menu, and the fourth line says `L4 150, 98 boiled over`.

## Enabler

**Open-Door Furnace (Khai Môn Lô).** A new artifact base, `dan_lo`: attack 46, defence 20, thần thức 30. Any alchemist can own one. It is a pot, not a relic. Its active effect is Open the Door, which takes an art slot.

- **Opens:** Five Courses (below).
- **Closes:** a coating loaded into the furnace serves nothing else. Blind, nothing can be loaded. When the courses run out, the art is finished for the fight.

## The Courses

Five Courses is the build's rule. Each firing of Open the Door serves the next course you loaded. **A course keeps every earlier course's coating**, in the way a converted hit keeps its old tags (Combat rule 6). The next course must be one the last generates, which is the catalogue's Five Phases Cycle. If it is not, the chain breaks and the running total falls to 0.

| Course | Coating, reused | Points | At quality 3 | Kind | Tag it adds |
|---|---|---|---|---|---|
| Wood | Sized Paper (Phàn Chỉ) | 30 | 48 | qi | talisman |
| Fire | none: the furnace's own fire | 0 | 0 | qi | none |
| Earth | Whetstone Ash (Ma Thạch Hôi) | 60 | 96 | body | artifact |
| Metal | Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | 25 | 40 | body | body |
| Water | Whetstone Water (Ma Thạch Thủy) | 40 | 64 | qi | sword |

You may start anywhere on the cycle. Started at Earth, the running L4 is 96, 136, 200, 248, 248 against a cap of 150. Started at Wood it is 48, 48, 144, 184, 248, so the same goods arrive a course late.

## Preparation Is the Game

**What the numbers changed.** The natural order, Wood first, is wrong. The biggest coating goes first and the furnace's own fire goes last, because a course keeps what came before it. Against a typical enemy any meal will do. The feast exists for the guests a supper cannot finish.

Each row is one saved file, `variants/wedding-furnace-[name].fight.json`, at Nascent Soul.

| Preparation | Against the mixed enemy | Against high ward strength and efficiency |
|---|---|---|
| Foreseen, five courses, Earth first (`mixed`, `warded-earth`) | Wins at 2.86 s, 64 % health | Wins at 3.57 s, 57 % health |
| Supper, three courses (`supper`, `supper-warded`) | Wins at 3 s, 57 % health | **Loses at 4 s, enemy on 49 %** |
| Same goods, wrong order (`wrong-order`, `wrong-order-warded`) | Wins at 3.57 s, 57 % health | **Loses at 3 s, enemy on 65 %** |
| Ambush, two courses from ready doses (`ambush`) | **Loses at 4 s, enemy on 38 %** | |
| Blind, the fire alone (`blind`) | **Loses at 4 s, enemy on 68 %** | |

Where you start the cycle, with the same goods, at Nascent Soul:

| First course | Thể tu wall (`wall-*`) | Warded (`warded-*`) | Qi-resistant ward (`qiward-*`) | Fast attacker (`fast-*`) |
|---|---|---|---|---|
| Wood | Loses, enemy on 7 % | Loses, 51 % | Loses, 34 % | Loses, 68 % |
| Fire | Loses, 5 % | Loses, 52 % | Loses, 39 % | Loses, 62 % |
| Earth | Wins, 2.86 s | Wins, 3.57 s | **Wins, 3.57 s** | Loses, 48 % |
| Metal | Wins, 2.86 s | Wins, 3.57 s | Loses, 52 % | Loses, 57 % |
| Water | Wins, 2.86 s | Wins, 3.57 s | Loses, 35 % | Loses at 5 s, 26 % |

Earth first is close to dominant, mostly because Whetstone Ash is the largest coating, and those sizes came from other builds. Water first lasts two seconds longer against a fast attacker, because its three qi courses open by burning that enemy's pool, and it still loses.

## The Stack

Sizes on new modifiers are first guesses. Forms: Increased, More, Per, Conversion, Overflow, Rule swap.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Open the Door (Khai Lô) | c_art 2.2, cost 0.10, 1 s, five firings | none | art | none | ○ | Furnace | any alchemist |
| Rate | Art speed (`art_speed_pct`) | +40, so a course every 0.71 s | Increased | art | none | ◐ | Tree | every art build |
| Multiplier | Damage (`attack_pct`) | +90, half of a typical cultivator's | Increased | any | L1 | ● | Tree | every build |
| Multiplier | **Cook's Hand (Trù Thủ)** | +4 points per alchemy level, on hits with the furnace form | Per | art | L2 | ○ | Sealed cluster | any alchemist with a hồ lô or furnace art |
| Multiplier | Artifact attack | +60, the furnace itself | Gear | any | L3 | ● | Artifact | every build |
| Multiplier | Four coatings | The table above | More | art | L4 | ○ reused | Preparation | Fortieth Breath, Remnant Host, Receiving Hand, Brush Fee |
| Multiplier | **Five Courses (Ngũ Vị Tịch)** | A course keeps every earlier coating, and a break in the cycle resets them | Rule swap | art | L4 | ○ | Furnace | any Five Phases Cycle or slot-order build |
| Multiplier | **Fine Work (Tinh Công)** | Coatings you brewed gain 20 % per point of quality, 0 to 3 | Per | art | L4 | ○ | Sealed cluster | any talisman or formation crafter who fights with their own work |
| Crit | Crit chance | 10 %, ordinary | Increased | any | none | ● | Tree | every build |
| Past the cap | **Boiled Over (Phí Dật)** | Each L4 point the cap clips on a course adds 0.01 `c_tick` to a body tick, Scald, for 3 pulses | Overflow | tick | none | ○ | Technique | any formation or coating stack past L4's cap |
| Fuel | Art cost | None: a whole meal is 50 % of the pool, with the ward left on | none | art | none | ● | | |
| Survival | Common ward | ws and we 62, as a typical cultivator | none | any | none | ● | Tree, artifacts | every build |

**Identity piece:** Five Courses. Without it the same art loses at 3 s with the enemy on 58 %, where the meal wins at 2.86 s.
**Empty rungs:** L5 is a sacrifice: nothing here holds a condition, because a feast is served regardless. Reach is a gap: no pierce, so one realm up is lost.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 90 | ×1.90 | `attack_pct` |
| L2 | 36 on courses | ×1.36 | Cook's Hand at alchemy level 9 |
| L3 | 60 | ×1.60 | Furnace |
| L4 | 96 rising to 150 on courses | ×1.96 to ×2.50 | Five Courses, Fine Work |
| L5 | 0 | ×1.00 | Sacrifice |

`m_static` 3.04 against a typical 7.37. A full course reaches ×10.3. Every other hit stays at 3.04.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire, with Wood if it comes | Fire is alchemy's root; the courses read coatings, not your root |
| Key talents | Fortune, Comprehension | Comprehension for brew success, fortune for alchemy crits |
| The Way (Đạo) | None required | The craft is the Way here |

## Công Pháp

### Wedding Hearth Sutra (Hỉ Táo Kinh) — main, Địa giai

A cookbook that became a method because the cook would not stop adding to it.

```json
{"id": "hi_tao_kinh", "name": "Hỉ Táo Kinh", "tier": 2, "tech_kind": "main",
 "names": ["hoa"], "layers": 12,
 "bonuses": [{"stat": "alchemy_success", "value": 8}, {"stat": "herb_growth_pct", "value": 15},
             {"stat": "linh_luc_pct", "value": 12}, {"stat": "lifespan_years", "value": 8}],
 "abilities": [{"ability_id": "low_flame", "unlock_layer": 2}],
 "seal_clusters": ["long_table"], "origin": "authored"}
```

Layer 4 allows three courses, layer 7 allows five, and layer 9 teaches Boiled Over. **Flaw:** it has no chapter on eating in a hurry.
**Fit:** Needs key (abilities) · **Budget:** 8/8 + 15/25 + 12/20 + 8/15 = 2.73 of 3.0, each under the single cap. `alchemy_success` still meets its character-wide ceiling of 3.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Open the Door (Khai Lô) | Furnace, active effect | set by the course; furnace, artifact | 2.2 | 0.10 | 1 s | none | Needs key |
| Low Flame (Văn Hỏa) | Sutra, 2 | qi, Fire | 1.48 | 0.04 | 1 s | none | Needs key |

- **Open the Door.** **Effect:** serves the next course as a hit, with Five Courses. No courses left: it does not fire. **Description:** Mind the steam.
- **Low Flame.** **Effect:** a hit. It keeps no coating, so it gains nothing from the meal. **Description:** A pot must never go off the boil while guests are waiting.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Open the Door, Low Flame | Common | Three courses. Not run |
| Core Formation | 5 | As above, with a cleanse | Common | Five courses at quality 2, `variants/wedding-furnace-core.fight.json` |
| Nascent Soul | 6 | As above, with an escape | Common | The last two slots go to the guest: whatever the matchup wants. They are empty in every run here |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Open-Door Furnace | Artifact, weapon | `dan_lo`, Hạ phẩm, Thông thiên linh bảo | L3 60, 900 thần thức | Needs key |
| A good shield | Artifact, ward | Thuẫn, Thượng phẩm, Thông thiên linh bảo | With the furnace's defence, `a_w` 1.03. 450 thần thức | Fits today |
| Common ward | Warding spell | Pass 0.54 body, 0.36 qi | Left on | Fits today |
| Sized Paper, Whetstone Ash, Iron-Sand Hand Bath, Whetstone Water | Coatings | Reused, each gaining a cycle element | The menu | Needs key |
| Kitchen-Door Pill (Trù Môn Đan) | Pill | Any coating pressed into a pill, +8 toxicity | A ready dose counts in an Ambush (Combat rule 12), so a cook may keep two in the sleeve | Needs key |

Thần thức: 1,350 of 1,500 at soul strength 50.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Long Table | Below | The whole craft in one cluster | Needs key |
| 2 | Art speed | +40 | Brings the fourth course inside the fight | Fits today |
| 3 | Damage | +90 | Modest on purpose | Fits today |

### Hidden cluster idea: Long Table (Trường Tịch Mạch)

Theme: the Way of Alchemy, Fire, sealed by a technique (Wedding Hearth Sutra), size 8. Small acupoints are alchemy success and Fire damage. Notables are Cook's Hand, then Fine Work at the far end. No capability. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A cook with a supper | Furnace, three courses | Cooks at a village wedding, and is asked back |
| Core Formation | The first full feast | Five courses | Takes on two apprentices who eat too much |
| Nascent Soul | A feast tuned to the guest | Fine Work at quality 3, Boiled Over | Is invited to duels the way others are invited to dinner |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm | Wins at 2.86 s | Foreseen, Earth first |
| Mixed, one realm up | Loses at 2 s, enemy on 88 % | No pierce, and it dies before the third course |
| Top-end, same realm | Loses at 1 s | As it should |
| High ward, thể tu wall | Wins, with the right start | See Preparation Is the Game |
| Huge health, `variants/wedding-furnace-ox.fight.json` | Wins at 5 s, 24 % health | Boiled Over's scald, 14 % of its damage, is the difference |
| Per-hit ward, `variants/wedding-furnace-perhit.fight.json` | Loses at 3 s, enemy on 40 % | Big late hits are what that ward is for |
| Boss at 3× pools, `variants/wedding-furnace-boss-earth.fight.json` | Loses at 3 s, enemy on 66 % | A meal is five plates. It is not a siege |

**Counter:** a fast attacker with two 1 s arts. It drains the pool, so Open the Door fires twice and then waits unpaid. Also anyone who does not send word.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Sutra 2.73 of 3.0. Both arts at the lint. 1,350 of 1,500 thần thức. 2 of 6 slots run |
| Validity | PASS | Elements, tier and realm real. `dan_lo` is a proposed base |
| Stack | PASS | Six forms. L5 and Reach named. `--without five_courses` turns a win into a loss |
| Scaling | PASS | `m_static` 3.04 against typical 7.37, and ×10.3 on a full course. INFO: L4 reaches the top-end anchor of ×2.5 |
| The fight | PASS | The plug-in runs the engine. Courses fire at 0.71 s on. `layer_4_over_cap` is the Overflow's input, and `dot_pool_cap_clipped` shows Scald at its cap in the ox fight |
| Reuse | PASS | Four coatings and Five Phases Cycle reused. No fifth coating. Each new modifier has a second home |
| NPC use | PASS | A generator can pick a start and load a menu. Each course is one Breakdown line |
| Counterplay | PASS | Fast attacker, per-hit ward, ambush |
| Originality | PASS | No names from existing works |

## Fight Results

Input: `sheets/wedding-furnace.fight.json`, Earth first. Observations from `fight_x.py`, a paper model, not the game. Plug-in: `five_courses`.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 55 % health | 2.14 s | never | `layer_4_over_cap` |
| typical | 1 | Loss, enemy on 88 % | 2 s | | none |
| typical | 2 | Loss, enemy on 90 % | 2 s | | none |
| top_end | 0, 1, 2 | Loss | 1 s | | none |

| Run | Result |
|---|---|
| `sheets/wedding-furnace.fight.json --without five_courses` | Loss at 6 s, enemy on 21 % |
| `variants/wedding-furnace-mixed.fight.json --without five_courses` | Loss at 3 s, enemy on 58 % |
| `variants/wedding-furnace-warded-earth.fight.json --without fine_work` | Loss at 6 s, enemy on 50 % |
| `variants/wedding-furnace-warded-earth.fight.json --without cooks_hand` | Loss at 3 s, enemy on 57 % |
| `variants/wedding-furnace-ox.fight.json --without boiled_over` | Loss at 7 s, enemy on 8 % |
| `variants/wedding-furnace-core.fight.json` | Core Formation: win at 3.08 s, 55 % health |
| Same file, `--gap 1` | Loss at 2 s, enemy on 88 % |
| Same file, `--without five_courses` | Loss at 4 s, enemy on 63 % |

**Unmodelled:** course tags, because the plug-in adds a coating's points directly. Ringing Ground and pills, so L4 is the coatings alone. Cleanse and escape. The goods and seasons a meal costs.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Five Courses | Needs rule | Combat rule 13: an art whose kind and tags change per firing. Rule 6: more than 2 conversions in a chain. Rule 12: L4 that changes during a fight. Trade-off: a prepared build gets a curve, not a flat bonus |
| Boiled Over | Needs rule | Combat Formulas B: an L4 clip that feeds a status. Scald stays inside `dot_pool_cap` |
| `dan_lo`, Open the Door, Low Flame, Wedding Hearth Sutra, Long Table, Kitchen-Door Pill | Needs key | A base, abilities, a cluster idea, a pill record |
| Cook's Hand, Fine Work | Needs key | Reads of craft level and item quality at compile. Neither stat has been read by a build before |
| Four coatings | Needs key | A cycle element on each coating record |

## Questions for the User

- No coating has a recipe or a price. Should a meal cost a season's work, or only goods? That decides how often a cook gets to be strong.
- Whetstone Ash at 60 makes Earth first nearly dominant. Should the four coatings be resized, now that one build uses all of them?

## Also Considered

- **Alloy:** a furnace hit counts every coating's tag at once for a flat L4 150. Simple, and it is one big coating under a new name.
- **The Bad Batch:** failed brews and Dregs as ammunition, a furnace that bursts. It drifted toward gloom and toward Taster's Fever.
