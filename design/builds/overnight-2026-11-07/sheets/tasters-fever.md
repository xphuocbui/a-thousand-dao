# The Taster's Fever (Thí Độc Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A poisoner who keeps their own pill toxicity high on purpose and fights with it."
> **Direction**: The seed is kept, the poison is moved. The enemy is not what gets poisoned: the cultivator is, and the fever is the weapon. Toxicity is a magazine, not a damage stat. The first plan was a tick clock; the calculator killed it (see The Fight Below the Plan).
> **Realm span**: Foundation Establishment – Nascent Soul · **Power level**: strong · **Use**: player build to aim for
> **Fit**: 5 Fits today · 10 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức and the Đạo's node values were not totalled)
> **Repair**: Bitter Tithe's shared magazine and Overheat now run as plug-ins. The matrix did not move. What changed: without Fever, one realm up takes 5 s, not 4 s, because Overheat goes with it; a per-hit ward no longer slows the build; Foundation now beats one realm up, on nearly a whole magazine. The tick-clock numbers are gone, because that file was not kept.

## The Spine

- **The channel:** art hits at the cooldown floor. They use L1 to L5 and crit, meet evade, ward and guard, and are limited by the magazine, not by linh lực.
- **The enabler:** Bitter Tithe pays poison-tag arts in pill toxicity (đan độc) instead of linh lực, and closes every other way of getting rid of it.
- **The loop:** in a fight, fire every 0.5 s until the toxicity is gone. In a life, binge on cheap pills, spend it all in one fight, take the real pills in the clean window after, binge again.
- **The engine:** Combat Open Question 21 says art speed "raises hit rate and spending together". Tithe cuts that link. Fever is ordinary speed, but paid from a pool the ward does not need.
- **The sacrifice:** no second act. The magazine lasts about 7 s, and after it there is a basic attack. Cultivation runs 40 % slower at đan độc 80, and pills work at 20 %.
- **The arc:** at Foundation a sick cultivator with a fast hand. At Core Formation the terror of a duel's first three seconds. At Nascent Soul, more slots make the sprint shorter and worse.

## The Legend

The tasters of the Reed Throne ate what the throne would eat, a little of everything, every day of their
lives. It was a post for the disposable, until a family of them noticed that the ones who lasted ran hot. They
slept little, moved early, and flinched before the blow. When the throne fell they had no one left to eat for,
and a body that could not be let go cold.

Their canon is a book of doses, not of strikes. Those who keep it now eat what alchemists throw away, and
they look ill, and they are. They cannot clean themselves with any pill. They can only pour it out into someone,
so they go looking for a person large enough to hold it, usually before a breakthrough they could not otherwise
survive.

## How It Fights

Nothing fires at t = 0, and arts wait a full cooldown, so everyone else's first move comes at one second. The
Taster's comes at half a second, with three arts, and again at one second. By the time a typical enemy has
acted once it has taken six hits, and the Taster's linh lực is untouched, because none of those hits cost any.
**The signature moment:** a Nascent Soul elder, one realm up, dead at two and a half seconds, and the Taster
walks off 30 points cleaner than they arrived, and for once a pill will do something.

## Enabler

**Bitter Tithe (Khổ Thuế).** Layer 1 of the Taster's Canon. A player finds the Canon in the ruin of a court
kitchen, or takes it from a Taster.

- **Opens:** arts with the poison tag cost đan độc, not linh lực (2 a firing here, set by the art). With too
  little đan độc the art waits. Đan độc spent stays gone after the fight.
- **Closes:** cleansing pills no longer work on you, and Fever and Bitter Measure read 0 while
  `dan_doc_no_penalty` is held. Nothing takes the poison out but firing it, and natural decay.

## The Stack

Sizes on new modifiers are first guesses. "Per đan độc" reads the value at compile, so it is fixed for the fight.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Three 1 s arts | `c_art` 1.0, inside the lint at zero cost | Flat base | art | none | ○ | Technique | any fast-art build |
| Rate | **Fever (Độc Nhiệt)** | +1.5 `art_speed_pct` per đan độc | Per | art | none | ○ | Đạo keystone | Pill Glutton, any toxicity build |
| Multiplier | Damage (`attack_pct`) | +134 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Bitter Measure (Khổ Lượng) | +1.5 points per đan độc on the poison tag | Per | art, tick | L2 | ○ | Đạo | any toxicity build |
| Multiplier | Artifact attack | +90 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Corpse-Wax Coating (Thi Lạp) | Pilot's +100, at pill potency 0.2: +20 on Bile | More | tick | L4 | ○ | Pill | Burial Shroud |
| Crit | Crit (`crit_chance_pct`, `crit_damage_pct`) | 15 %, ×1.7 | Flat | art | none | ● | Tree | every hit build |
| Reach | Realm pierce (`pierce_pct`) | +30, because the build is always behind | Flat | any | none | ● | Tree | vượt cấp builds |
| Past the cap | Overheat (Quá Nhiệt) | Art speed that `cooldown_min` clips becomes L5 points, 1 for 1, up to +30 | Overflow | art, flight | L5 | ○ | Đạo | any art-speed build: **used by The Remnant Host** |
| Past the cap | Bare Vessel (Lộ Đỉnh) | +80 to hits while the enemy has under 5 % linh lực. Greater grade, +80. The same modifier has a lesser grade, +30, in Brush Fee, Fortieth Breath, Receiving Hand and Turned-Away; one size would change fights | Conditional | art, basic | L5 | ○ | Sealed cluster | Burial Shroud, Ninth Bell |
| Fuel | Bitter Pearl (Khổ Châu) | Each 10 toxicity the clamp at 100 clips adds a grain, kept for life, to 20. A grain counts as 1 đan độc for Fever and Bitter Measure | Overflow | any | none | ○ | Đạo | any life-stat build |
| Survival | Body guard (`body_guard_pct`) | +40 | Flat | any | none | ● | Tree, armour | thể tu builds |
| Survival | Inured Flesh (Quán Độc) | +0.3 `status_resist_pct` per đan độc | Per | any | none | ○ | Đạo | any toxicity build |

**Identity piece:** Fever. It is the reason toxicity is worth keeping, and the half of the engine that Tithe sets free.
**Empty rungs:** L4 on hits is a sacrifice: pills barely work on this body. Sustained damage is a sacrifice: the magazine ends.

| Layer | Points at Core Formation (arts) | Multiplier | Sources |
|---|---|---|---|
| L1 | 134 | ×2.34 | `attack_pct` |
| L2 | 120 | ×2.20 | Bitter Measure at đan độc 80 |
| L3 | 90 | ×1.90 | Gear |
| L4 | 0 | ×1.00 | Sacrifice; Bile alone gets +20 |
| L5 | 20, or 100 with Bare Vessel | ×1.20 to ×2.00 | Overheat, Bare Vessel |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire and Water, with the new Cinnabar variant | Fire brews, and Cinnabar makes the clean window count for more |
| Key talents | Physique | Health and guard carry the first second; the ward needs less help |
| The Way (Đạo) | Poison, proposed below | Holds Fever, Bitter Measure and Overheat |

**New root: Cinnabar (Chu Sa).** Origin: Convergence. Requirement: owns Fire and Water. The two existing pair
convergences, Thunder and Darkness, are both overcoming pairs, and Water over Fire is an unused one.

| Key | Per purity | At 50 | At 100 | W at 50 | W at 100 |
|---|---|---|---|---|---|
| `pill_effect_pct` | +0.60 | +30 | +60 | +30 (weight 1.0 is a guess: this key has no Map weight) | +60 |
| `dan_doc_resist_pct` | −0.20 | −10 | −20 | −16 | −32 |
| **Total** | | | | **14 W** | **28 W** |

It sits in the 10 to 30 W common band (Spiritual Roots Formulas E). **Its cost** is the second line: every pill
poisons you more. For most cultivators that is a real price. For a Taster it is a discount, and the first line
is what makes the clean window worth reaching. Like any variant it needs its own Meridian Map sector (rule 12),
and rule 9's catalogue grows to nine.

## Công Pháp

### Taster's Canon (Thí Độc Điển) — main, Địa giai

A book of what was eaten, by whom, and how long they lasted.

```json
{"id": "thi_doc_dien", "name": "Thí Độc Điển", "tier": 2, "tech_kind": "main",
 "names": ["hoa", "thuy"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 15},
             {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "bitter_tithe", "unlock_layer": 1},
               {"ability_id": "first_taste", "unlock_layer": 2},
               {"ability_id": "spat_bile", "unlock_layer": 5},
               {"ability_id": "second_cup", "unlock_layer": 9}],
 "seal_clusters": ["sick_meridians"], "origin": "authored"}
```

**Fit:** Needs key (abilities; `seal_clusters` is unread today) · **Budget:** 15/15 + 15/15 + 10/15 = 2.67 of 3.0

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| First Taste (Sơ Thí) | Canon, 2 | qi, poison, hit | 1.0 | 2 đan độc | 1 s | none | Needs key |
| Spat Bile (Thổ Đảm) | Canon, 5 | body, poison, hit | 1.0 | 2 đan độc | 1 s | none | Needs key |
| Second Cup (Đệ Nhị Bôi) | Canon, 9 | body, poison, hit | 1.0 | 2 đan độc | 1 s | none | Needs key |

- **First Taste.** **Effect:** a qi hit that applies Bile (Đảm Độc), `c_tick` 0.3, 4 pulses, so the wound outlives the magazine. **Description:** A small sip, to see.
- **Spat Bile.** **Effect:** a plain body hit. **Description:** What the body will not keep.
- **Second Cup.** **Effect:** a plain body hit. Slot order puts it last so its hit is the one that lands on a stripped ward. **Description:** Nobody offers a second cup out of kindness.

Each art sits inside the lint as if it cost nothing, which is the strictest reading.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation | 4 | First Taste, Spat Bile, Second Cup | Common | Fever at đan độc 50, +75 art speed |
| Core Formation | 5 | As above | Common | Two slots are left empty on purpose: each art added shortens the magazine |
| Nascent Soul | 6 | Adds a fourth art | Common | 80 đan độc over 4 arts lasts 5 s |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Dregs (Đan Tra) | Pill | new; toxicity 20, no effect, a few stones | What a failed brew leaves today as nothing. It is the reload, and it gives alchemists a reason to sell their mistakes | Needs key |
| Corpse-Wax Coating | Pill, preparation | pilot's | L4 for Bile, at a fifth strength | Needs key |
| Any weapon pieces | Artifact, weapon | Generated | L3 | Fits today |

Ordinary pills reload too. A Tụ Khí Đan adds 6 for 12 stones, before Cinnabar's −10 to resistance.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Sick Meridians (Bệnh Mạch), sealed cluster from Burial Shroud | Holds Bare Vessel | The Canon lists it in `seal_clusters` | Needs key |
| 2 | Pierce and body guard notables | +3, +8 | The build is usually a realm behind | Fits today |

## Đạo

**Poison (Độc), proposed.** A seed in Dao rule 2 with no tree yet. **Requirement:** Fire and Water at purity 30, or
Cinnabar. **`theme_stats`:** `art_speed_pct`, `status_resist_pct`, `dan_doc_resist_pct`, `pierce_pct`. Twenty nodes.

- **The Tongue (Thiệt), 7 nodes:** reading a dose. Ends in **Bitter Measure** (T2) and **Inured Flesh** (T1). Stat lines are `status_resist_pct` and `dan_doc_resist_pct`.
- **The Fever (Nhiệt), 6 nodes:** the heat of a sick body. Stat lines are `art_speed_pct`. Ends in **Overheat** (T2).
- **The Dregs (Tra), 6 nodes:** what is left in the cup. `pierce_pct` lines, a passive that gives a failed brew Dregs (T1), and **Bitter Pearl** (T2).
- **Keystone: Fever** (T3). The signature: toxicity becomes speed.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation | Đan độc 50, a quick poisoner who beats the next realm too, on nearly a whole magazine | Tithe, Fever, Bitter Measure | The first time a pill does nothing |
| Core Formation | Đan độc 80, the three-second duel | Overheat, Bare Vessel | A breakthrough that needs a killing first |
| Nascent Soul | Shorter, harder sprints | A fourth art | Never quite warm, never quite well |

The whole loop rests on one fact: at đan độc 80 a breakthrough pill is at 20 %. So before each great breakthrough
the Taster must find something big enough to pour into. A small fight does not clean them: killing a typical peer
in 1 s fires 6 arts and spends only 12.

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical, same realm | Wins, 1 s | Six hits land before it acts twice |
| Typical, one realm up | Wins, 2.5 s, 84 % health | The defining fight |
| Typical, two realms up | Loses, 2 s, enemy on 85 % | Hits outrun the sprint |
| ×8 boss, same realm (`variants/tasters-fever-boss-x8.fight.json`) | Wins, 5 s, spends 60 | The fight a Taster wants before a breakthrough |
| ×8 boss, one realm up (same file) | Loses, 9 s, boss on 62 % | Magazine empty, and then there is nothing |
| Per-hit ward, one realm up (`variants/tasters-fever-per-hit-ward.fight.json`) | Wins, 2.5 s, 84 % health | No slower than a plain ward: at 0.05 of the pool a hit, six hits a second empty it |
| Any top-end | Loses, 1 s | Deals 26 % at the same realm, then dies |

**Counter:** a pool too big for one magazine. A boss outlasts the 40 firings, and the Taster stands there clean,
with a basic attack. Top-end burst also kills it, though it hurts on the way down.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.67 of 3.0, each value in its pool; three arts within the lint; slots 3 of 5. Thần thức for artifacts was not totalled, and the Đạo's node values were not linted |
| Validity | PASS | Fire and Water, `dia` tier and its Nascent Soul `max_realm`, `art_speed_pct`, `dan_doc_resist_pct`, `pill_effect_pct` are real; Cinnabar is in band |
| Stack | PASS | Seven forms; every rung filled or named. Identity test below changes the fight |
| Scaling | PASS | Art M about 11.7 (the five layers above), 19.6 with Bare Vessel, against 5.48 typical and 210 top-end. INFO: beats one realm up, which the GDD keeps for top-end |
| The fight | PASS | Constants 60 of 60, selftest clean. The loop runs, and no art is blocked until the magazine is empty. One `dot_pool_cap` clip, on Bile. Tithe and Overheat run through `rules/bitter_tithe.py` and `rules/speed_overflow.py` |
| Reuse | PASS | Bare Vessel, Corpse-Wax Coating and Sick Meridians reused by name; every new piece has a second home |
| NPC use | PASS | All passive and compile-time. An NPC needs a toxicity value, and one Breakdown line explains each |
| Counterplay | PASS | A boss enemy (rule 18) outlasts the magazine at 9 s |
| Originality | PASS | The structure is old court practice; names are invented for this sheet |

## The Fight Below the Plan

The first version was the literal one: a tick clock whose cap rose with toxicity. Ticks hit a fixed clock, so a stat
that moves the cap moves little. That input was not kept, so its numbers are not quoted here. Trying speed instead
kills a typical enemy one realm up in 2.5 s at 84 % health (`sheets/tasters-fever.fight.json`). The poison in this
build is mostly a story now, and the fever does the work.

## Fight Results

Input: `sheets/tasters-fever.fight.json`, at đan độc 80. Observations from `_tools/fight_x.py`, the calculator plus
the plug-ins the file lists: a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 98 % health | 1 s | never | `dot_pool_cap` once |
| typical | 1 | Win, 84 % health, 55 % linh lực | 2.5 s | never | `dot_pool_cap` once |
| typical | 2 | Loss, enemy on 85 % | 2 s | 2 s | none |
| top_end | 0 | Loss, enemy on 74 % | 1 s | 1 s | `dot_pool_cap` once |
| top_end | 1 | Loss, enemy on 94 % | 1 s | 1 s | none |
| top_end | 2 | Loss, enemy on 99 % | 1 s | 1 s | none |

**Identity tests, typical one realm up.** `--without art_speed_pct` removes Fever, the only art speed in the file, and
Overheat with it: a win at 5 s, 71 % health, and top-end falls only to 90 % rather than 74 %. Without Tithe
(`variants/tasters-fever-no-tithe.fight.json`, arts at `cost_share` 0.05 and no magazine): a **loss** at 9 s with the
enemy on 10 %, own pool dry at 2 s. `--without "Bare Vessel"`: a win at 3 s, 81 % health. Neither half of the engine
carries the build alone, and Tithe is the larger half.

**Second realms.** Stats are a first guess, because wave 1 kept no input: L1 and L3 scale from the Core Formation file
by tree W. Nascent Soul, đan độc 85, 4 arts (`variants/tasters-fever-nascent.fight.json`): typical same realm 1 s;
typical Deity Transformation 2 s at 87 % health; top-end same realm a loss, enemy on 64 %. Foundation, đan độc 50,
3 arts (`variants/tasters-fever-foundation.fight.json`): typical same realm 2 s; one realm up a win at 4.6 s on 80 %,
spending 48 of 50.

**Shaped enemies** (Core Formation). `variants/tasters-fever-boss-x8.fight.json`, gap 0: win at 5 s, 30 firings, 60 đan
độc; gap 1: loss at 9 s, boss on 62 %. `variants/tasters-fever-boss-x16.fight.json`, gap 0: win at 7 s, 87 % health,
all 40 firings. `variants/tasters-fever-per-hit-ward.fight.json`, gap 1: win at 2.5 s, 84 % health.

**Unmodelled:** Fever and Bitter Measure as fixed numbers at đan độc 80, since they read it at compile; the clean
window and Bitter Pearl, which are caller effects; Inured Flesh, because reference enemies carry no statuses.

## New Concepts

**Art costs in a life stat.** An art may name a resource other than linh lực or health.

- **Rule needed:** Combat rule 13 and Formulas E add a `cost_resource`; Combat rule 14 reports it as spent;
  Character Stats rule 7 adds a loss of toxicity that is not decay. The art lint needs a price for it.
- **Bounds:** the resource is 0 to 100, and it is read at compile, so a fight stays a pure function.
- **Breakdown line:** "Paid 2 đan độc (Bitter Tithe)".
- **Other builds:** heart demon as a second pool (backlog 12), and any lifespan-paid art (backlog 11).
- **Question for the user:** this undercuts Open Question 21's link between rate and spending on purpose. Is that
  the kind of hole you want open, or should the rule keep art speed from applying to arts paid this way?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Bitter Tithe | Needs rule | Combat rule 13, Formulas E; Character Stats rule 7; the closing line on cleansing pills |
| Overheat | Needs rule | Combat Formulas A2: what `cooldown_min` clips |
| Bitter Pearl | Needs rule | Character Stats rule 7 and Edge Cases: what the clamp at 100 clips, and a stored grain count |
| Fever, Bitter Measure, Inured Flesh | Needs key | Per-toxicity keys; `art_speed_pct` still has to reach Character Stats (Open Question 21) |
| Bare Vessel, Corpse-Wax Coating, Sick Meridians | Needs key | As in Burial Shroud |
| Cinnabar | Needs key | A `variants` row, `variant_effects`, a Meridian sector and a `pill_effect_pct` weight |
| Dregs | Needs key | A recipe record and a failed-brew output |
| Taster's Canon, three arts, Poison Đạo | Needs key | The art record format and ability catalogue (Open Question 13); `dao.json` |

## Also Considered

- **The Shared Cup (Đồng Ẩm):** one poison on both sides, and your tolerance decides who lasts. Dropped: a slower Burial Shroud.
- **Tolerance Clock (Nại Độc):** tick caps rise with your toxicity. Tested first and dropped: a cap moves little on a fixed clock.
