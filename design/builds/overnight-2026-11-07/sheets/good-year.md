# The Good Year (Phong Niên Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The Spirit Farmer (seed 66): their fields fight for them. Read the herb effects and Spirit Herbs and Fields. Someone wicked and enjoying it, no gentle farmer."
> **Direction**: The field grows in the enemy. Each plot is a tick with no slot, sized by the live game's herb potency, and potency reads age against mature years, so the best weapon in the game is the cheapest weed left in the ground.
> **Realm span**: Nascent Soul – Deity Transformation, defined at Deity · **Power level**: strong · **Use**: player build, or the landlord at the end of a valley road
> **Fit**: 7 Fits today · 10 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** ticks, on L1 to L4, up to the pulse cap, with one art at the end. In the Mixed fight the field does 87 % of the damage.
- **The enabler:** Sown Field (Hoạt Lũng). Opens each planted plot as a tick on the enemy at t = 0, with no slot and no cooldown. Closes the fist, 1 % of your linh lực per plot, and the plot.
- **The loop:** none. Stand there with your hands in the soil while it comes up.
- **The engine:** ticks stop at a cap, and caps are shares of maximum. So against anyone ordinary three plots kill as fast as twelve, and what the cap clips comes home as linh lực, which pays for a ward that cannot fall. **Against a wall, nothing clips, and every plot and every year counts.**
- **The sacrifice:** the fist, and a plot for every fight. A weeder ends it: a cheap cleanse turns the harvest into a stalemate.
- **The arc:** three plots at the hut, twelve at the end. Each body ploughed in brings the next crop forward.

## The Legend

Every plot on Fat Acre (Phì Điền) has a wooden tag in a lovely hand: a name, a sect, a realm, and how many years they had left. Elder Hậu reads the tags aloud at the harvest supper and laughs until they have to sit down. There are twelve plots and there is a waiting list, because each one ploughed in brings a brother, a master or a sworn friend up the valley road with a sword, and the Elder has the table laid before they arrive.

They grow weeds. Qi-gathering grass, two stones a seed, the stuff children chew. They will tell you why at length, with diagrams: every herb's strength is its age against its own maturity, so a grass mature in one year is at full strength at two hundred and fifty-six, and a Spirit-Changing Fruit needs twenty-five thousand. Three sects have sent elders to reason with them. The food is excellent, everyone agrees. Hậu has never been so happy, sleeps very well, and has already chosen the plot for you.

## How It Fights

Nothing happens for you to see. Elder Hậu does not raise a hand, and from the first pulse the enemy loses ten points of health a second. Against the Wall the bar reads 90, 80, 71, 61, 51, 40, 30, 20, 10, 0.

**The signature moment:** the panel row. Every enemy, from the Evader to the Wall with twice the pool and a ward of 200, is dead at the tenth second, and the Fast at the eighth. Most builds on that panel have a good enemy and a bad one. To this one they are all soil. `--without sown_field`: a stalemate, enemy on 100 %.

## Enabler

**Sown Field (Hoạt Lũng).** A technique's divine ability, learned from a manuscript found folded in a dead farmer's boot, which is why nobody can say who wrote it. With capability #14, Portable Cave Abode, which the game already has, the field goes where you go.

- **Opens:** at t = 0, each plot you choose to sow is a permanent tick on the enemy. `c_tick` = 0.04 × potency, and potency is the game's own: 1 + 0.5 × log2(age ÷ mature years), at most 5. Each plot is its own status, with its own pool cap, and all share the pulse cap.
- **Closes:** your basic attack never fires: your hands are in the soil. Each plot sown holds 1 % of your linh lực for the fight. A sown plot is gone: the herb dies in them.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Sown Field (Hoạt Lũng)** | Plots become ticks, as above | New channel | tick | none | ○ | Technique | any herb build |
| Base | Field plots (Điền Số) | +1 `field_plots` a node | Increased | none | none | ○ | Cluster | any farmer. Today the tree gives none |
| Base | Herb growth (Dược Trưởng) | `herb_growth_pct` to its ceiling of 10 | Increased | none | none | ● | Technique | any farmer |
| Multiplier | Damage (`attack_pct`) | +120 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Damage over time | +24 | Increased | tick | L1 | ○ | Tree | Catalogue row |
| Multiplier | Held Acres (Tích Điền) | +7 on over-time statuses per plot: +84 at 12 | Per | tick | L2 | ○ | Cluster | **Reused from The Corner** |
| Multiplier | Artifact attack | +60 | Gear | any | L3 | ● | Items | every build |
| Multiplier | New Rice Wine (Tân Mễ Tửu) | +30, foreseen only, brewed from your own field | Pill | any | L4 | ○ | Pill | **Reused from The Level Ground** |
| Multiplier | Longer Breath (Trường Tức) | +50 to arts while your linh lực share leads by 10 points | Conditional | art | L5 | ○ | Technique | **Reused from The Long Carry, unplanned** |
| Past the cap | **Surplus (Dư Thu)** | Tick damage the caps clip comes home as linh lực at half its amount, at most 5 % of maximum a pulse | Overflow | tick | none | ○ | Cluster | any tick build past the cap |
| Past the cap | Rich Soil (Phì Thổ) | +2 points to both tick caps while the target's linh lực is 50 % or more | Cap shift | tick | none | ○ | Cluster | any tick build. The first row tonight that wants their pool full |
| Fuel | Stone Ward (Thạch Hộ) | Per-pulse ward at the legal 0.10, `we` 120: upkeep 4.5 % against 5 % regeneration and Surplus | Rule swap | any | none | ○ | Ward | **Reused from The Long Firing** |
| Survival | Health, pool, ward rows | `n_body` 3.6, `n_qi` 2.5, `ws` 200, guard +40 %, +3 % | Increased | any | none | ● | Tree | every build |
| Arc | What They Had Left (Dư Niên) | A cultivator you kill and plough in adds the years they had left to one plot | Trigger | none | none | ○ | Technique | any build that eats people, such as The Not-Yet-Full |

**Identity piece:** Sown Field. `--without sown_field`: stalemate on Mixed and Wall, enemy on 100 %.
**Empty rungs:** crit, ticks cannot. Reach, none needed: nothing meets a tick but guard.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | 120, crops 144 | ×2.20, ×2.44 | `attack_pct`, Damage over time on crops |
| L2 | crops 84 | ×1.84 | Held Acres |
| L3 | 60 | ×1.60 | Weapon, feeding ticks |
| L4 | 30 | ×1.30 | New Rice Wine. 0 blind |
| L5 | Scythe only, 0 or 50 | ×1.50 | Ticks do not read it |

**W:** 965 of 1,172: attack 120, Damage over time 24, health 312, linh lực 150, ward strength 175 over gear 25, efficiency 120, guard 40, regeneration 24.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root | Earth 75, Wood 60 | Earth gives +3 plots. Wood 60 with the ceiling gives growth ×1.628 (Character Stats' worked example). The pair is Wood overcoming Earth, across the wheel, and no border carries it |
| Key talents | Physique | A long life, and a body to wait in |
| The Way | None needed | Nothing asks for one |

**Plots:** 3 base, +3 Earth, +6 from Furrow Line: 12, the cap. **Years in the ground:** 256 ÷ 1.628 = 157 for a full weed. 16 years is 10.

## Công Pháp

### Furrow Scripture (Lũng Điền Kinh) — main, Thiên giai

The hand is a farmer's, the ink is mostly soil, and the last page is a planting calendar for people.

```json
{"id": "lung_dien_kinh", "name": "Lũng Điền Kinh", "tier": 3, "tech_kind": "main", "names": ["moc", "tho"], "layers": 15,
 "bonuses": [{"stat": "herb_growth_pct", "value": 10}, {"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20}],
 "abilities": [{"ability_id": "hoat_lung", "unlock_layer": 1}, {"ability_id": "khai_liem", "unlock_layer": 8}],
 "seal_clusters": ["lung_mach"], "origin": "authored"}
```

**Fit:** Needs key, and it carries Sown Field's rule · **Budget:** 10/25 + 15/15 + 20/20 = 2.4 of 4.0

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Scythe Day (Khai Liêm) | Scripture, 8 | qi, Wood | 2.9 | 0.12 | 3 s | enemy health below 50 % | Needs key |

**Description:** the first stroke of harvest, and the only time the Elder stands up. 1 of 7 slots. The rest are free.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Any weapon of attack 60 | Artifact | Generated | L3 reaches ticks. A plain sickle is the joke, and it is never swung | Fits today |
| New Rice Wine | Pill | Reused | Foreseen L4, and a reason for the supper | Needs key |

## Tree and Clusters

### Hidden cluster idea: Furrow Line (Lũng Mạch)

Theme spirit fields, Earth, outer, sealed by the Furrow Scripture. Size 10. Small acupoints: `field_plots` +1 at six nodes. Notables: Held Acres, Surplus, Rich Soil. Capability #14, Portable Cave Abode, on the far notable. A hermit who never fights would still walk it for the plots.

## What the Numbers Showed

Each is at Deity. Prefix `variants/good-year-`. All plots Qi-Gathering Grass unless named.

| Plots, age 256 | Mixed | Wall | Files |
|---|---|---|---|
| 1 | 26 s, on 26 % | Stalemate, enemy on 81 % | `plots-1-*` |
| 2 | 14 s, on 53 % | Stalemate, 59 % | `plots-2-*` |
| 3 | 10 s, on 62 % | Stalemate, 31 % | `plots-3-*` |
| 6 | 10 s, on 66 % | 26 s, on 58 % | `plots-6-*` |
| 12 | 10 s, on 66 % | 10 s, on 84 % | `-mixed`, `-wall` |

| 12 plots of | Potency | Seeds | Wall |
|---|---|---|---|
| Spirit-Changing Fruit, 100 years | 1 | 14,400 stones | Stalemate, enemy on 16 % (`fruit-wall`) |
| Grass, 4 years | 2 | 24 stones | 25 s (`young-wall`) |
| Grass, 16 years | 3 | 24 | 17 s (`age-16-wall`) |
| Grass, 64 years | 4 | 24 | 13 s (`age-64-wall`) |
| Grass, 256 years | 5 | 24 | 10 s (`-wall`) |

- **Three plots do all an ordinary fight asks.** Past that a plot buys linh lực, not time: Surplus brings in 47 % of the pool on Mixed, and 0 % on the Wall, where nothing clips.
- **The old weed beats the great fruit by the rule as built.** Nobody planned that. Potency measures age against each herb's own maturity. On the Fast, age hardly matters: 8 s at 16, 64 or 256 years.
- **So a fight costs what you choose.** Three young plots for a stranger. Twelve old ones for a wall, and 157 years to grow them back, or twelve kills.

**What They Had Left.** A Nascent Soul at half of a 1,000-year span puts 500 years on a plot, past full strength at once. A Qi Refining at half of 120 puts 60. That is the wicked sum: the strong are worth planting.

## Matchups

Panel, at Deity, each file `variants/good-year-[enemy].fight.json`.

| Enemy | Result | Why |
|---|---|---|
| Mixed | Wins 10 s on 66 % | Field 87 % of the damage |
| Pulse | Wins 10 s on 70 % | Ticks are inside any ward |
| Wall | Wins 10 s on 84 %, enemy pool 91 % | Rich Soil holds all ten seconds. Without it 13 s |
| Evader | Wins 10 s on 66 % | Nothing to evade |
| Fast | Wins 8 s on 62 % | Their flurry bankrupts them, and Rich Soil cuts out |
| Cheap single art (`-cheap`) | Wins 9 s on 79 % | |
| Blind, away from home (`-blind-mixed`) | Wins 10 s on 64 % | Foreseen L4 gone, and it does not matter. #14 carries the field |
| Foreseen, away, without #14 | Stalemate | The same as `--without sown_field`: the field stayed home |
| A weeder: cleanse 3 a second at 0.05 (`-cleanse`) | **Stalemate**, enemy on 60 %, own 13 % | The real counter |
| A good weeder: cleanse 6 every 0.5 s at 0.02 (`-cleanse-cheap`) | **Stalemate**, enemy on 90 % | No field, no fist |
| Top-end | **Loses** at t = 1, enemy on 90 % | Normal |

**Counter:** a cleanse art. It costs one slot, and it ends the build. Or kill them in the first second.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Scythe Day inside the lint, 1 of 7 slots, Scripture 2.4 of 4.0, `herb_growth_pct` at its ceiling. Thần thức not totalled |
| Validity | PASS | Thiên giai reaches Deity. Herb ids, potency, 12 plots and capability #14 read from live data. Stone Ward at 0.10 |
| Stack | PASS | Seven forms. Identity run: stalemate. Pair removed together: Surplus with Rich Soil, Wall 13 s, pool 50 % not 61 % |
| Scaling | PASS | Tick M about 9.3 against a typical 8.96. Printed `m_static` 4.58 is the art's. INFO |
| The fight | PASS | 60 of 60 constants. `dot_pulse_cap_clipped` is the point of the build. Plug-ins `sown_field`, `surplus`, `rich_soil`, `breath_lead` |
| Reuse | PASS | Held Acres, Stone Ward, New Rice Wine, Longer Breath. Longer Breath, unplanned: without it the Fast takes 9 s on 59 %, not 8 s on 62 % |
| NPC use | PASS | A generator can hold plots as one line. An NPC needs no field in fact, only a number |
| Counterplay | PASS | Cleanse, a slot's worth |
| Originality | PASS | Potency is the game's own. Nothing borrowed |

## Fight Results

Input: `sheets/good-year.fight.json`. `fight_x.py`, a paper model.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Wins, 77 % | 9 s | never | `dot_pulse_cap` |
| top_end | 0 | Loses, enemy on 90 % | 1 s | | |

Deity is the last realm, so gaps 1 and 2 in the matrix repeat these. **Second realm:** Nascent Soul, 6 plots at 64 years: `-nascent-mixed` 9 s on 64 %, `-nascent-fast` 7 s on 57 %, `-nascent-wall` 28 s on 46 %. **Removal:** `-mixed --without surplus`, 10 s, pool 62 % not 87 %. `-wall --without rich_soil`, 13 s. `--without scythe_day`, Mixed 11 s, Wall 11 s. **Unmodelled:** plots spent, What They Had Left, and the years to grow them back.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Sown Field | Needs rule | Combat rule 7: a status with no duration, from a preparation. A permanent status for the field only. `rules/sown_field.py` |
| Surplus | Needs rule | Pulse order: clipped ticks credit their owner. `rules/surplus.py` |
| Rich Soil | Needs rule | A conditional cap shift, bounded at +2 points. `rules/rich_soil.py` |
| Scythe Day, Scripture, cluster, What They Had Left | Needs key | Records. A kill's `lifespan_left` on the event |

## Questions

1. **Is the potency curve meant to do this?** A 2-stone seed reaches full strength in 256 years, and a 1,200-stone fruit needs 25,600. Alchemy reads the same curve, so the same weed may be the best ingredient in the game too. Nothing here changes that. It may be a bug or a lovely secret.
2. Should a cleanse clear a field? Here it does, and it decides the build.

## Also Considered

- **Well-Watered:** overfeed the enemy's pool to grow the crop. Rich Soil is the plain version, and it needs no art.
- **The Tenant Host:** plots as bound disciples who fight beside you. A swarm is a rule the Ant General already asks for.
