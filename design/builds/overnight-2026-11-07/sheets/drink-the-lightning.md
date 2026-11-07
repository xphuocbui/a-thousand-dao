# Drink the Lightning (Ẩm Lôi Quyết)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content, and every boss below, are first guesses.
> **Seed**: Critic order 1: a build for Heavenly Tribulation only, Kept Hearth crossed with Level Ground, waves chained on starting shares, nearly useless anywhere else.
> **Direction**: Kept Hearth needs a read, a keystone and the worst root in the game to know what will feed it. A Ground Law can simply decide what element the sky is. One rod, one fixed ward, no read.
> **Realm span**: Nascent Soul, for one fight. A lower row of the step table tested · **Power level**: ordinary, and below it in any duel · **Use**: player build, or the reason an order exists
> **Fit**: 5 Fits today · 10 Needs key · 5 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** none worth the name. Four cheap long-cooldown arts and a fist, M 2.16 against a typical 7.37. The win is that every wave ends in a knockout before the health runs out.
- **The enabler:** Lightning Rod (Thu Lôi), a Ground Law on the place of the attempt. It opens one element for every art the sky throws. It closes everything else: the law stands only on ground tagged `tribulation`.
- **The loop:** the sky strikes. Each strike is Fed, so the ward pays nothing. The pool stays full, so regeneration has nowhere to go but the body.
- **The engine:** Thien-kiep rule 7 forbids healing between waves and says nothing about healing inside one. A ward that is never charged keeps the pool at the top, and Still Water turns every pulse of regeneration the top clips into health.
- **The sacrifice:** damage, and every fight that is not this one. On open ground a typical cultivator kills it in 5 s with 91 % of their health left.
- **The arc:** decades of being useless, three waves of being insufferable, and then a Deity who has to learn to fight.

## The Legend

The Copper Refectory (Đồng Trai Đường) stands on a bare peak that the storms of three provinces use as a nail. Its founder, an abbot of expensive tastes and no gift for violence, held that Heavenly Tribulation is not a punishment but a dinner to which one has at last been invited, and that a cultivator who dies at table has simply eaten badly. The order is now on the eleventh edition of *The Sky's Bill of Fare*, which rates each known wave for body, finish and what to fast on beforehand. Iron Thunder is called robust and a little obvious. Thousand Needles is recommended as a second course. No edition rates Closed Mouth, because no one has come back to file the notes.

Its abbots cross at a rate that makes great sects weep, and they are unbearable about it. They say grace aloud on the roof. They send condolences, with a menu, to every house that loses an elder at the gate. The great sects reply politely and retain people for the road home, since anywhere but under that sky a Refectory abbot can be killed in five seconds by a bad-tempered disciple, and the abbots know this, and go out anyway, because the dinner they are most looking forward to is the one where someone asks them to explain it.

## How It Fights

Nothing much happens, which is the point. A strike lands and the ward takes almost all of it for free. The pool sits near full. The monk's fist and four small arts plod through the boss. Health that fell to the sky's ticks or its basic blows climbs back between them, and each point climbed makes the next plod harder. The worst thing a boss can do is refuse to strike.

**The signature moment:** an abbot walks into the tribulation on 40 % health, at the floor of Combat rule 3, because they fasted. Iron Thunder lands on them for nine seconds and they finish the wave on 92 %. They end the run on 97 % (`variants/drink-the-lightning-draw-fasted-w1.fight.json` to `-w3`, each with `--gap 1`). A typical build survives half of the same draws and comes out on 28 %.

## Enabler

**Lightning Rod (Thu Lôi).** A Ground Law, Level Ground's concept, carried by a laid formation. *Cột thu lôi* is the plain word for a lightning rod.

- **Opens:** on ground tagged `tribulation`, every art hit by the other side carries Thunder (Lôi) and no other element, counted as Fire for the cycle. So the ward can stand in one phase and be Fed by a pool it has never met, with no read. Bosses need no element in their records for this to work, which is the first time a tag build here has not had to assume one.
- **Closes:** the law stands only under that tag, which rule 5 adds and nothing else does. Basic attacks carry no element (rule 13), ticks and soul arts never reach a ward, and a boss that holds its strikes gives it nothing.
- **Found:** the Array Đạo's Field branch, or a seat at the Refectory, which is not cheap.

## The Stack

Sizes on new modifiers are first guesses. The forced push tried three stranger stacks: a health guard on every art so the monk eats before it kills, The Whole Bucket refilled by the sky, and Rich Seam with Longer Breath. The guards changed nothing and the second made things worse. The last made the identity pieces decorative, so it was cut. **The numbers changed the design once:** the plan was to throw the sky's food back through The Whole Bucket, and it dropped survival to 0.583, because every drop spent is regeneration that no longer spills into the body.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Long-cooldown discount | Four arts at the art lint's limit for cost 0.02 | Flat | art | none | ● | Technique | **Already-Waited's reading of the lint** |
| Multiplier | Damage (`attack_pct`) | +20. Everything else went to the pool | Increased | any | L1 | ● | Tree | every build |
| Multiplier | **Gorged (Bão Lôi)** | +1 point to arts and basic attacks per 1 % of maximum health restored this fight, to +100 | Per | art, basic | L2 | ○ | Technique | any healer that fights, any Still Water build |
| Multiplier | Artifact attack | +20 | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Known Ground (Thục Địa) | +25 per ground tag where you have lived a full cycle. Rule 5 hands it the `tribulation` tag for free: `home`, `tribulation`, +50 | Per | any | L4 | ○ | Sealed cluster | **Reused from The Level Ground** |
| Past the cap | Still Water (Tĩnh Thủy) | Regeneration or a refund clipped by a full pool restores health, at half its amount | Overflow | any | none | ○ | Technique | **Reused from The Fortieth Breath** |
| Fuel | Child Steals the Mother (Tử Đạo Mẫu Khí) | A hit whose element generates your ward's phase is Fed: `pass_tag` −0.25, the ward pays nothing, and you gain half of what it blocked | Trigger | any | none | ○ | Ward | **Reused from The Kept Hearth, see below** |
| Fuel | Regeneration (`linh_luc_regen_pct`) | +6, to `regen_cap` 0.08. This also fills 64 % of the pool in the rest | Increased | any | none | ● | Tree | any sustain build |
| Fuel | Linh lực (`linh_luc_pct`) | `n_qi` 2.4. Still Water pays by the size of the pool, so the sea is the health regeneration | Increased | any | none | ● | Tree, Technique | every build |
| Survival | Mother-and-Child Ward (Mẫu Tử Hộ) | Common drain ward, phase Earth, `ws` 100, `we` 60 | Flat | any | none | ○ | Ward | **Reused from The Kept Hearth** |
| Identity | **Lightning Rod (Thu Lôi)** | The law above | Rule swap | any | none | ○ | Formation | any boss arena, any gate that names the element of its ground |

**Identity piece:** Lightning Rod. Without it, survival falls from 1.000 to 0.075.

**Another sheet's modifier, used unplanned:** Child Steals the Mother. Its author built a meal that needs a read, a keystone and a five-element root, and said so: "Their size is your food." Here it runs on a fixed phase with no read, and the meal turns out to matter less than the bill. Remove the refund and keep the free ward, and survival is still 0.850. Remove the Fed rule whole and it is 0.025. It is a waiver, not a dinner, which the order will never admit.

**Empty rungs:** Rate, Crit and Reach are sacrifices. Art speed would only spend the pool faster, and the sky's gap is one realm.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 20 | ×1.20 | `attack_pct`, a ninth of a typical's |
| L2 | 0 to 100 | ×1.00 to ×2.00 | Gorged, earned in the wave |
| L3 | 20 | ×1.20 | Ward and body pieces only |
| L4 | 50 | ×1.50 | Known Ground; 0 on open ground |
| L5 | 0 | ×1.00 | Sacrifice. An L5 source made Gorged decorative |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any, Earth preferred | The law names the element, so the root is free. The first ring build that does not need the worst root in the game |
| Key talents | Soul strength if you can | White Silence is the wave that hurts most per point |
| The Way (Đạo) | Array, Field branch, to Ground Law | Only the law. No new Đạo: the order is not interesting enough to deserve one |

## Công Pháp

### Refectory Rule (Trai Đường Quy) — main, Địa giai

Twelve layers of table manners. It stops at Nascent Soul because its authors saw no reason to plan past dinner.

```json
{"id": "trai_duong_quy", "name": "Trai Đường Quy", "tier": 2, "tech_kind": "main",
 "names": ["tho"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "defense_pct", "value": 15},
             {"stat": "khi_huyet_pct", "value": 7}],
 "abilities": [{"ability_id": "first_course", "unlock_layer": 3}, {"ability_id": "second_course", "unlock_layer": 6},
               {"ability_id": "third_course", "unlock_layer": 9}, {"ability_id": "last_course", "unlock_layer": 11}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 20/20 + 15/15 + 7/15 = 2.47 of 3.0, each within 1.5. Carries Gorged and Still Water as passives.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| First Course (Sơ Thiện) | Rule, 3 | body | 1.99 | 0.02 | 4 s | none | Needs key |
| Second Course (Thứ Thiện) | Rule, 6 | qi | 2.99 | 0.02 | 8 s | none | Needs key |
| Third Course (Tam Thiện) | Rule, 9 | body | 3.99 | 0.02 | 12 s | none | Needs key |
| Last Course (Mạt Thiện) | Rule, 11 | qi | 5.99 | 0.02 | 20 s | none | Needs key |
| Rinse the Mouth (Thấu Khẩu) | Way art | qi, cleanse | 0 | 0.02 | 2 s | none | Needs key |

**Effect:** each course is one plain hit at the lint's limit. Rinse the Mouth removes two statuses and every curse on you. **Description:** eaten slowly, with the proper cutlery.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Nascent Soul | 6 | First, Second, Third, Last Course | Mother-and-Child, Earth | Two slots stay empty until you have read the pool. No escape art: rule 8 makes it a wasted slot |
| Nascent Soul, Closed Mouth in the pool | 6 | The same, and Rinse the Mouth | Mother-and-Child, Earth | Worth 0.043 of survival. See Matchups |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Lightning Rod Array (Thu Lôi Trận) | Formation | Level 1 to 5, below | Carries the law. Upkeep paid for decades against one afternoon | Needs key |
| Any `thuan`, `giap` | Artifacts, ward and body | Best available | `ws` 100, `we` 60 and L3 20. No weapon: nothing here wants one | Fits today |

```json
{"id": "thu_loi", "name": "Thu Lôi Trận", "stat": "ground_law", "law": "thu_loi", "applies": "laid", "max_level": 5,
 "cost_lt": 600, "cost_growth": 2.5, "materials_per_level": 2, "material_rarity": 3, "upkeep_lt_per_level": 40,
 "needs_ground_tag": "tribulation",
 "desc": "A copper spine driven into the peak. It teaches the sky one word."}
```

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Regeneration (`linh_luc_regen_pct`) | +6, to the cap | The whole of the mending | Fits today |
| 2 | Linh lực (`linh_luc_pct`) | `n_qi` 2.4 | Regeneration is a share of the pool | Fits today |
| 3 | Ward strength, efficiency | `ws` 100, `we` 60 | What a basic attack still costs | Fits today |
| 4 | Damage (`attack_pct`) | +20 | The last thing bought | Fits today |

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Up to Core Formation | A weak cultivator with a large pool | The Rule's first layers | You are laughed at, and you note who laughs |
| Nascent Soul | Still weak, and everyone knows why | The array, four courses | You stop going out |
| The attempt | The best-fed person alive | The law, three waves | You say grace |
| Deity Transformation | A Deity with M 1.44 and a tempered buff | Nothing. The Rule stops here | Someone asks you to explain it |

## Bosses This Build Calls For

The tribulation pool is content the user is waiting on, so this is a first pool, inside Formulas D. All first guesses. `Off` is Combat Formulas K, with ticks counted as rate. ehp 3,856 at multiplier 1, `boss_pool_mult` 1.25, so 1.25, 1.88 and 2.81 across the waves. The baseline kills the last wave in about 7 s, inside `stall_share`. Elements and thần thức appear in no GDD: each element is authored and replaced under the law, and White Silence's `divine_sense` of 1.6 against the player's 1.0 is a guess. Records: the `tribulation` block of `variants/drink-the-lightning-pool.fight.json`.

| Boss | Main kind | Off | r_b | What it asks of any build | To this build |
|---|---|---|---|---|---|
| Iron Thunder (Thiết Lôi) | body | 658 | 0.18 | Two heavy strokes, can your ward take them | "Robust." A feast |
| Thousand Needles (Thiên Châm) | qi | 1,213 | 0.33 | Three thin fast arts, the baseline's worst wave | Also a feast: the deadliest boss is the best food |
| White Silence (Bạch Tịch) | soul | 518 | 0.14 | Soul past the ward | A slow wave, nothing to drink from the soul half |
| Sour Cloud (Toan Vân) | body, ticks | 677 | 0.19 | Ticks inside the ward | The hungriest common wave. Regeneration alone must carry it |
| Dry Wind (Can Phong) | qi | 672 | 0.18 | Burns the pool, blocks regeneration | Hurts most before the rest. Its hits still feed |
| Held Breath (Bế Tức) | body | 742 | 0.20 | Silent until it falls under 60 % health | Waits for you, then feeds you |
| **Closed Mouth (Bế Khẩu)** | body, ticks | 537 | 0.15 | **The test boss.** Seals regeneration every 3 s, ticks, burns, and has no strike worth the name | The only boss the order fears. Almost harmless to anyone else |

**Closed Mouth is the boss to build.** It has the lowest threat in the pool for a normal cultivator, who is hardly touched by it, and it ends this build. Add it to the pool and survival falls from 1.000 to 0.671, while a typical build's rises from 0.500 to 0.567, because it replaces harder draws. That is what Formulas C asks for: "the fix is bosses that counter more builds, not more pool." An answer exists and it is thin: Rinse the Mouth lifts survival only to 0.714.

## Matchups

| Enemy | Result | Why |
|---|---|---|
| The pool, 120 draws | Survives 1.000, 68 % health at the end | Every boss but one is food or can be outlasted |
| Typical reference, same pool | 0.500, 28 % at the end | On Formulas C's target of 0.50 |
| Top-end reference, same pool | 1.000, 98 % at the end | It simply kills them. Above 0.90, as Formulas C warned |
| Pool with Closed Mouth, 210 draws | 0.671 | Nothing to drink, and no regeneration to spill |
| Same, Rinse the Mouth slotted | 0.714 | Reading the pool helps, a little |
| A colder pool (Off about 240 to 570) | 1.000, 89 % | Without Fed, 0.758. A hot sky needs the ward most |
| Typical, on open ground | Dead at 5 s, enemy on 91 % | Nothing here works |
| Typical one realm up, open ground | Dead at 2 s, enemy on 99 % | |
| Top-end, open ground | Dead at 1 s, enemy on 100 % | |

**Counter:** Closed Mouth, under rule 18's "drains linh lực hard" profile with no hits. Outside the sky, any assassin on the road home. Anything that needs only five seconds beats it.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.47 of 3.0. All arts at or within the lint. Slots 4 of 6, or 5 of 6 with Rinse the Mouth. Thần thức not totalled |
| Validity | PASS | Địa giai reaches `nguyen_anh`, the last realm it needs. Keys and bases are real. `tribulation` is rule 5's tag. Boss lint: `boss_pool_mult` within `bm_max`, 2 or 3 arts each, all inside the art lint, r_b 0.14 to 0.33, one boss per main kind. Soul share of offence is not computed, because Formulas D gives no way to compare a soul share to a hit rate |
| Stack | PASS | Five forms: Increased, Per, Overflow, Trigger, Rule swap. Rate, Crit and Reach named as sacrifices. L5 empty and L2 earned. Identity test: 1.000 to 0.075 |
| Scaling | PASS | `m_static` 2.16 against typical 7.37 and top-end 256, as an ordinary build should in its own arena. INFO: far below typical elsewhere, on purpose |
| The fight | PASS | 60 of 60 constants. `fed_hits` shows the loop running in every wave. No cap hit. Plug-ins: `element_tags`, `thu_loi`, `still_water`, `gorged`, `tribulation` |
| Reuse | PASS | Child Steals the Mother, Mother-and-Child Ward, Still Water, Ground Law, Known Ground reused. Gorged's second home is any healer. Hearth Ash not used. New pieces: one law, one modifier, one technique, five arts |
| NPC use | PASS | Every piece is one Breakdown line and the generator can hold it. NPCs never run a tribulation (rule 1), so the law has no NPC use, and says so |
| Counterplay | PASS | Closed Mouth, run. Any open ground, run |
| Originality | PASS | Lightning rods, refectories, grace and bills of fare are common words. No name from any work |

## Fight Results

Observations from `fight_x.py`, a paper model with expected values, not the game. Prefix `variants/drink-the-lightning-`. Pool files replace the fight with a whole run through `rules/tribulation.py`, which is Formulas A and B: `p_t` is the weighted share of all ordered draws survived, with `wave_count` 3, `pool_ramp` 1.5 and `rest_pulses` 8. The main file stands on tribulation ground against a plain enemy so that the law shows in an identity run.

**The chains.** One file a wave, with `start_health` and `start_qi` from Formulas B. Run each with `--gap 1`. A boss's `realm` in the file sets only its fight unit.

| Draw | Wave | Boss | Starts on | Ends on | Time |
|---|---|---|---|---|---|
| Feast, `draw-feast-w1` to `w3` | 1 | Iron Thunder | 100 %, pool 100 % | 97 %, pool 94 % | 12 s |
| | 2 | Sour Cloud | 97 %, pool 100 % | 67 %, pool 96 % | 12 s |
| | 3 | Thousand Needles | 67 %, pool 100 % | 97 %, pool 98 % | 13 s |
| Famine, `draw-famine-w1` to `w3` | 1 | Dry Wind | 100 %, pool 100 % | 63 %, pool 44 % | 12 s |
| | 2 | White Silence | 63 %, pool 100 % | 53 %, pool 84 % | 12 s |
| | 3 | Sour Cloud | 53 %, pool 100 % | 27 %, pool 94 % | 16 s |
| Fasted, `draw-fasted-w1` to `w3` | 1 | Iron Thunder | 40 %, pool 100 % | 92 %, pool 98 % | 9 s |
| | 2 | Sour Cloud | 92 %, pool 100 % | 67 %, pool 96 % | 12 s |
| | 3 | Thousand Needles | 67 %, pool 100 % | 97 %, pool 98 % | 13 s |

**The whole pool.**

| File, flags | p_t | Final health | What failed it |
|---|---|---|---|
| `pool` | 1.000 | 68 % | Nothing |
| `pool`, `--without thu_loi` | 0.075 | 42 % | Every boss but Held Breath, which is the Fire one |
| `pool`, `--without still_water` | 0.117 | 29 % | Sour Cloud, White Silence |
| `pool-no-fed` | 0.025 | 20 % | All of them |
| `pool-no-sw-no-fed`, the two healing pieces together | 0.000 | | All of them |
| `pool-no-refund` | 0.850 | 60 % | Sour Cloud, Dry Wind, White Silence |
| `pool`, `--without Gorged` | 0.917 | 70 % | Sour Cloud mostly |
| `pool`, `--without Gorged --without last_course`, the offence pair | 0.883 | 72 % | Sour Cloud, Dry Wind |
| `pool-no-damage-at-all`, L1 and L3 at 0 | 0.942 | 64 % | A monk with no damage stat at all |
| `pool-whole-bucket`, in First Course's slot | 0.583 | 57 % | Sour Cloud, White Silence, Dry Wind |
| `pool-fasted`, wave 1 at 40 % | 0.967 | 69 % | Dry Wind, Sour Cloud first |
| `pool-level-ground`, the other law | 0.050 | 68 % | The boss's L2 to L5 are empty, so it caps only Gorged |
| `pool-closed-mouth` | 0.671 | 69 % | Closed Mouth 0.262 |
| `pool-closed-mouth-rinse` | 0.714 | 67 % | Closed Mouth 0.214 |
| `pool-ref-typical` | 0.500 | 28 % | Thousand Needles most |
| `pool-ref-typical-closed-mouth` | 0.567 | 27 % | |
| `pool-ref-top-end`, `pool-ref-top-end-closed-mouth` | 1.000 | 98 % | Nothing |
| `pool-cold`, `pool-cold-no-fed`, `pool-cold-ref-typical` | 1.000, 0.758, 0.450 | 89 %, 77 %, 20 % | Off 240 to 570, ehp 6,041, nearer the GDD's example boss |
| `pool-core`, a Core Formation row, same pool scaled by fight unit | 1.000 | 68 % | Second realm |
| `pool-core-ref-typical` | 0.000 | | The pool was fitted at Nascent Soul only, so read nothing into this |

**Duels.**

| Enemy | File, flags | Result | Time | Own health, pool | Enemy health |
|---|---|---|---|---|---|
| typical | `sheets/drink-the-lightning.fight.json` | Win | 9 s | 59 %, 92 % | 0 % |
| typical, no law | same, `--without thu_loi` | Loss | 4 s | 0 %, 51 % | 88 % |
| typical, one up | same, `--gap 1` | Loss | 4 s | 0 %, 82 % | 96 % |
| top_end, all gaps | same, `--enemy top_end` | Loss | 1 s | 0 %, 0 % | 100 % |
| Mixed | `mixed` | Win | 12 s | 42 %, 90 % | 0 % |
| Mixed, no law | same, `--without thu_loi` | Loss | 5 s | 0 %, 37 % | 86 % |
| Mixed, one up | same, `--gap 1` | Loss | 5 s | 0 %, 82 % | 95 % |
| typical, open ground | `open-ground` | Loss | 4 s | 0 %, 51 % | 92 % |
| Mixed, open ground | `open-ground-mixed` | Loss | 5 s | 0 %, 37 % | 91 % |
| Mixed, open ground, one up | same, `--gap 1` | Loss | 2 s | 0 %, 21 % | 99 % |
| Mixed, open ground, top_end | same, `--enemy top_end` | Loss | 1 s | 0 %, 0 % | 100 % |

The two wins are the law against an ordinary enemy, which the tag forbids in play. They exist only to show the law. Everything the law does not reach loses.

**Unmodelled:** the cost and years of the array. The tempered buff and the reward, which come after the fight. Whether a fast costs anything but vitality.

## New Concepts

**A Ground Law may set an element.** Level Ground's concept moves listed keys. This adds one more kind of entry: a tag every art hit on the ground carries, replacing its own.

- **Rule:** Combat rules 6 and 12, and the law list in Formations.
- **Bounds:** one law to a ground, as before. Art hits only. This law needs the `tribulation` tag.
- **Breakdown line:** "Thu Lôi: this hit is Thunder (was Metal)."
- **Other builds it serves:** Kept Hearth at home, any element gate, a sect whose mountain is all one element. Without the tag, on any ground, it wins a duel with a typical cultivator in 12 s (`mixed`), which is why the tag is there.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Lightning Rod | Needs rule | Combat rules 6 and 12: a Ground Law may set a hit's element. Thien-kiep rule 5: a laid law binds a boss |
| Child Steals the Mother, Mother-and-Child Ward | Needs rule | As The Kept Hearth asks, Formulas D |
| Still Water | Needs rule | As The Fortieth Breath asks |
| Ground Law | Needs rule | As The Level Ground asks |
| Gorged | Needs key | A count of health restored this fight |
| Known Ground | Needs key | As The Level Ground asks |
| Refectory Rule, four courses, Rinse the Mouth, Lightning Rod Array, seven bosses | Needs key | Content records. Bosses go in `tribulation_bosses.json` |

**Questions for the user:**

1. Rule 7 and the Degenerate Strategies line both forbid healing between waves. Is healing inside a wave intended? Still Water plus the regeneration cap is 0.117 to 1.000 on its own here, and any sustain build can reach for it.
2. Does a Ground Law bind a tribulation boss? This build lives on yes: 0.075 without. Level Ground's question 3 feared Level Ground itself. In this pool that fear is unfounded, because a boss's L2 to L5 are empty, and the law scored 0.050.
3. A monk with no damage stat at all survives 0.942 of draws, because `time_limit` is the only pressure on offence and 40 s is long. Is that a problem for rule 8, or the pool's job?
4. A boss's shape matters as much as its r_b. Two pools of the same band give Fed a value of 0.975 or 0.242. Should Formulas D lint Off and ehp apart?
5. Does an unpaid Slow Wound ledger carry between waves? Rule 7 does not list it, and if it starts fresh, a wave's bill is burned at the door.

## Also Considered

- **The Burned Ledger:** Slow Wound in a tribulation, paying a wave's damage only if the wave lasts, on the reading above. Sharper as an exploit than as a build, and it needs question 5 answered first.
- **The Whole Bucket Abbot:** throwing the sky's strikes back through Head of Water. Tested at 0.583 (`pool-whole-bucket`), which is why the order eats slowly.
