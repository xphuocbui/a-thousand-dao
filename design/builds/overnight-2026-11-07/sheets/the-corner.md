# The Corner (Lũng Đoạn Quyết)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Critic order 3, Famine: qi burn as the main channel at last, crossing Thousand Scales, Deepest Well and Long Carry. Set it in a city, with ambition or spite."
> **Direction**: A landlord who corners a walled city's food, and fights the same way: a burn counts as a bill the enemy's pool must pay, and what it cannot pay comes out of the body. The forced push replaced a "more damage to the empty" rung with Requisition, and cut Water Table, which changed no result.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Foundation · **Power level**: strong at home, ordinary abroad · **Use**: player build, or a city boss nobody can afford to kill
> **Fit**: 3 Fits today · 13 Needs key · 5 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: tree spend and thần thức are not totalled)

## The Spine

- **The channel:** qi burn, on L1 to L4, at last. It meets no ward and no guard, and it is capped as a share of the target's pool. In the home fight, half of all health removed arrives as burn the pool could not pay.
- **The enabler:** none. Requisition is one Redirect on a cluster.
- **The loop:** burn the pool, shut the gate on regeneration, keep your own breath, then let every burn and every hit present a bill to an empty pool.
- **The engine:** Requisition makes burn count as ward drain, so Scraping the Well, written for hits, now reads the burn. A pool at 0 no longer stops a burn. It sends it to the body, past guard.
- **The sacrifice:** no burst and no real weapon, so anything that kills inside 5 seconds wins. Its best trick works only on people who have lived in your city.
- **The arc:** the more of the walls you own, the higher you can reach, and the less you can leave. Three realms of owning more of one place.

## The Legend

Three Gates (Tam Môn Thành) has forty thousand mouths, and the House of Mạch has sold it flour for nine generations. When the old head died, the third child was left the worst stall, a joke at the funeral meal, and a breathing manual nobody could read. The third child read it. *Mạch* is wheat in the family's copy and meridian in everyone else's, and the author had plainly stopped caring which. They bought one walled plot, then another. The week they held twelve, a Core Formation elder who had laughed at the funeral found the bread a third lighter, the pills a season late, and a challenge accepted on their behalf.

The third Mạch keeps a table laid in an upstairs window over the East Gate market and eats there at noon with the shutters open. Two sects have asked them to stop. Both sects buy flour. Their stated ambition is a seat among the city's elders, and then to be begged, in public, to open the granaries, so that they can say no.

## How It Fights

Two small levies land in the first second, and then almost nothing seems to happen. The enemy's bar barely moves while their pool drains, their arts thin out and your own breath stays long. Then the pool reaches 0 and the bar falls off a cliff.

**The signature moment:** away from home, one Foundation against another, the enemy stands on 65 % at 4 s, 46 % at 5 s, and is on the ground at 6 s (`variants/the-corner-mixed.fight.json --timeline`). At home it is a Core Formation elder, who arrives on a quarter of a pool and is dead at 7 s (`variants/the-corner-home-mixed.fight.json --gap 1`).

Each acre counts: at home, one realm up, 12 plots win, 9 plots lose with the elder on 34 %, and 6 plots lose with the elder on 82 % (`-home-mixed`, `-home-plots-9-mixed`, `-home-plots-6-mixed`, each `--gap 1`).

## The Stack

Sizes on new modifiers are first guesses. Ladder for the qi burn channel.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Two levies | `c_tick` 0.4, 5 pulses, stacks to 5: Short Measure and Bad Year, each on its own 5 % cap | Art status | qi burn | none | ○ | Technique | any burn build |
| Rate | Rush Order (Cản Đơn) | +50 % price: first firing at half the cooldown | Timing | art | none | ○ | Technique | **Reused from The Full Price** |
| Multiplier | Damage (`attack_pct`) | +60, kept low | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Damage over time | +24 | Increased | tick, burn | L1 | ○ | Tree | **Catalogue row** |
| Multiplier | Held Acres (Tích Điền) | +7 points on over-time statuses per spirit field plot you work (`n_plots`, 1 to 12): +84 at 12 | Per | tick, burn | L2 | ○ | Sealed cluster | any Spirit Farming poisoner |
| Multiplier | Artifact attack | +60 | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Longer Breath (Trường Tức) | +50 points to hits while your linh lực share leads by more than 10 points. Here it costs nothing to hold: it was on for all 7 hits in the home fight | Conditional | art, basic | L5 | ○ | Technique | **Reused from The Long Carry** |
| Crit | None | Burn cannot crit. Every status is 100 % instead | | | | | | |
| Reach | Closed Gate (Bế Môn) | The Incense Vigil's curse, here a siege: no regeneration for 5 pulses, so the pool has nothing to pay with | Curse | burn | none | ○ | Technique | **Reused from The Incense Vigil** |
| Past the cap | Spillover (Dật Độc) | Tick damage a cap clips burns linh lực, within the burn cap | Overflow | tick | none | ○ | Technique | **Reused from The Burial Shroud** |
| Past the cap | **Requisition (Trưng Thu)** | Linh lực burn counts as drain a ward asked for: whatever reads drain also reads your burn | Redirect | qi burn | none | ○ | Sealed cluster, capability | any drain build, such as Water Table's |
| Past the cap | Scraping the Well (Quát Tỉnh) | What a pool cannot pay lands on health, past guard. Through Requisition, that now includes every burn | Overflow | ward drain | none | ○ | Technique | **Reused from The Deepest Well** |
| Fuel | Thrift (Tiết Dụng) | A quarter of ward efficiency counts as `art_cost_pct`, held at its 50 % limit | Redirect | art | none | ○ | Sealed cluster | **Reused from The Long Carry** |
| Survival | Efficiency over strength | Ward efficiency 240, strength 60, body before attack | Flat | any | none | ● | Tree, Artifacts | any long-breath build |
| Identity | Cornered Market (Lũng Đoạn Thị) | Foreseen fights in a city where you hold the market, against someone who wintered there: they start on `1 − n_plots / 16` of their linh lực (0.25 at 12) | Concept | burn | none | ○ | New concept | see below |

**Identity piece:** Requisition. Without it the home fight one realm up is lost at 10 s with the elder on 15 %, not won at 7 s.
**The unplanned use:** Scraping the Well's author wrote it for hits. Here it reads a status. `--without scrape_share` on the same file loses at 10 s with the elder on 29 %. Longer Breath's author earned it by not spending. Here it comes free, because the enemy's share is what falls.
**Empty rungs:** Crit is a sacrifice. L4 is a sacrifice: the preparation goes into the market, not a coating.

| Layer | Points at Foundation | Multiplier on burn | Sources |
|---|---|---|---|
| L1 | 84 | ×1.84 | Tree 60, Damage over time 24 |
| L2 | 84 | ×1.84 | Held Acres at 12 plots. Hits get none |
| L3 | 60 | ×1.60 | Granary Seal and armour |
| L4 | 0 | ×1.00 | Sacrifice |
| L5 | 0 | none | Burn does not use it. Hits get +50 from Longer Breath |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth at high purity, with Metal | Each 25 Earth purity is one more plot (`canh-gioi.md`, `n_plots`) |
| Key talents | Physique over Comprehension | The body must last 7 seconds of a stronger enemy's fists |
| The Way (Đạo) | None needed | The life is spent on land |

## Công Pháp

### Severed Wheat Sutra (Đoạn Mạch Kinh) — main, Địa giai

Read one way, a treatise on cutting wheat. Read the other, on cutting meridians: 斷麥 and 斷脈 sound the same.

```json
{"id": "doan_mach_kinh", "name": "Đoạn Mạch Kinh", "tier": 2, "tech_kind": "main",
 "names": ["tho", "kim"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 15}, {"stat": "herb_growth_pct", "value": 20}],
 "abilities": [{"ability_id": "short_measure", "unlock_layer": 1}, {"ability_id": "bad_year", "unlock_layer": 2},
               {"ability_id": "closed_gate", "unlock_layer": 3}, {"ability_id": "spoiled_stores", "unlock_layer": 4},
               {"ability_id": "rent_day", "unlock_layer": 7}, {"ability_id": "thin_gruel", "unlock_layer": 10}],
 "seal_clusters": ["hungry_courses"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/20 + 20/25 = 1.55 against Địa's 3.0

## Arts

All paid in linh lực, on the common drain ward. Cost is what the fight file charges.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Short Measure (Đoản Đấu) | Sutra, 1 | burn, over time, Rush Order | 0 | 0.06 | 2 s | none | Needs key |
| Bad Year (Hoang Niên) | Sutra, 2 | burn, over time, Rush Order | 0 | 0.06 | 2 s | none | Needs key |
| Spoiled Stores (Hủ Thương) | Sutra, 4 | body, over time | 0 | 0.05 | 2 s | none | Needs key |
| Closed Gate (Bế Môn) | Sutra, 3 | curse | 0 | 0.04 | 3 s | none | Needs key |
| Rent Day (Thu Tô) | Sutra, 7 | qi, hit | 2.2 | 0.08 | 2 s | enemy linh lực at or below 20 % | Needs key |
| Thin Gruel (Bạc Chúc) | Sutra, 10 | burn, over time | 0 | 0.05 | 2 s | none | Needs key |

- **Short Measure, Bad Year:** burn, `c_tick` 0.4, 5 pulses. Status lint 2.0 against 2.08, read at the base cost 0.04. **Description:** the same sack, a little less in it.
- **Spoiled Stores:** a body tick, `c_tick` 0.44, 5 pulses, there to clip and spill. **Description:** weevils, at a price.
- **Rent Day:** a hit that exists to be scraped. **Description:** they knock once.
- **Thin Gruel:** a third burn, `c_tick` 0.44. **Description:** the invoice calls it soup.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Short Measure, Bad Year, Spoiled Stores, Closed Gate | Common drain | The defined build |
| Core Formation | 5 | As above, plus Rent Day | Common drain | `variants/the-corner-core-mixed.fight.json` |
| Nascent Soul | 6 | Thin Gruel in the third slot, Rent Day last | Common drain | `variants/the-corner-nascent-mixed.fight.json` |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Granary Seal (Thương Ấn) | Artifact, weapon | `an`, generated | L3. The founder's stamp, cut a hair small so every sack it passes reads full | Needs key |
| Plain shield and armour | Artifact, ward and body | `thuan`, `giap` | Ward strength 60 and `a_b` 1.0 | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Hungry Courses | Whole cluster | Requisition, Held Acres, Thrift | Needs key |
| 2 | Ward efficiency, health | As much as the realm allows | Ward strength loses this fight | Fits today |
| 3 | Plot nodes (`field_plots`) | To reach 12 | Each plot is +7 burn and 6 points off a resident's opening pool | Fits today |

### Hidden cluster idea: Hungry Courses (Cơ Mạch)

Theme: linh lực and the starving of it. Earth, outer, sealed by the Severed Wheat Sutra, size 10. Small acupoints are burn duration and regeneration denied. Notables Held Acres and Thrift. Capability, farthest from the entry: Requisition. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A landlord who beats a resident elder one realm up, and only a resident | Twelve plots | The funeral debt is collected |
| Core Formation | Wins its own realm in 3 s at home. The resident above survives on 9 % | Rent Day | Sects start buying elsewhere, and paying for it |
| Nascent Soul | Wins its own realm in 6 s abroad. Home no longer reaches a realm up | Thin Gruel | The city is theirs, and too small |

Reach falls as they climb: one realm up at home is a win at Foundation, a loss on 9 % at Core (`variants/the-corner-core-home-mixed.fight.json --gap 1`) and a loss on 58 % at Nascent Soul (`variants/the-corner-nascent-home-mixed.fight.json --gap 1`). Twelve is `max_plots`, so the land stops growing and the pools do not.

## Matchups

Same realm, abroad, against the mixed enemy's arts, unless stated. Enemy shapes are hand-set in each file. No art here reads element or sense.

| Enemy | Result | Why | File (`variants/the-corner-`) |
|---|---|---|---|
| Mixed | Wins, 6 s on 70 % | The cliff | `mixed` |
| Mixed, one up | Loses at 5 s, enemy 83 % | A full pool outlasts you | `mixed --gap 1` |
| Resident, one up | Wins, 7 s on 17 % | Starts on a quarter of a pool | `home-mixed --gap 1` |
| Regenerator (+6 %) | Wins, 7 s on 64 % | Regeneration pays part of each bill until the Gate shuts | `regen` |
| Cleanser | Wins, 7 s on 64 % | Two burns gone every 3 s is a delay | `cleanser` |
| Deep pool (`n_qi` 3.5) | Wins, 7 s on 57 % | A deep granary lasts longer. The plan said it would fall faster, and it does not | `deep-pool` |
| Thể tu, ward off, small pool | Wins, 17 s on 34 % | No ward to scrape, so the burn alone must do it | `the-tu` |
| Fist, no arts | Wins, 8 s on 67 %; one up loses at 10 s, enemy 53 % | Silencing arts takes nothing from a fist | `fist` |
| Striker, 1 s heavy arts | Wins, 5 s on 47 %; one up loses at 2 s, enemy 97 % | Burst beats a clock | `striker` |

**Counter:** a stranger. A burst striker one realm up who took lodgings elsewhere kills the third Mạch at 2 s with 51 % of their own pool unspent. A top-end kills at 1 s.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Sutra 1.55 of 3.0. Status lint within on every art. Slots 4 of 4. Tree spend is not totalled: efficiency has only a guessed W price, and this spends heavily on it. A leaner body still wins, by overkill, in a double knockout at 8 s (`variants/the-corner-lean-home-mixed.fight.json --gap 1`). Thần thức not totalled |
| Validity | PASS | Elements `tho`, `kim`; tier 2 reaches `nguyen_anh`; base `an`; `n_plots` read from `canh-gioi.md`, maximum 12 |
| Stack | PASS | Forms: Redirect, Per, Overflow, Conditional, Timing, Increased. Identity test changes the fight. Requisition and Scraping share a job: removed together the home fight loses at 10 s, enemy 29 % |
| Scaling | PASS | `m_static` 2.56 on hits, below typical 4.19 by design. Burn runs at ×5.42. INFO: a resident one realm up falls, which Combat keeps for top-end |
| The fight | PASS | `dot_pool_cap` clips. Spillover burned 61.7 linh lực at the same realm and 0 one realm up, because raw damage must pass the cap to spill. Own pool never dry in the two main wins |
| Reuse | PASS | 6 reused, each new piece has a second home |
| NPC use | PASS | All read compiled values. Cornered Market needs the caller to know residence |
| Counterplay | PASS | Burst striker; a stranger |
| Originality | PASS | Lũng đoạn is a common word. All names invented |

## Fight Results

Input: `sheets/the-corner.fight.json`, on the fixture enemies. A paper model with expected values.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win on 73 % | 6 s | never | `dot_pool_cap` 4 |
| typical | 1 | Loss, enemy 76 % | 6 s | never | `dot_pool_cap` 2 |
| typical | 2 | Loss, enemy 99 % | 2 s | 2 s | |
| top_end | 0 to 2 | Loss, enemy 99 to 100 % | 1 s | 1 s | |

The mixed enemy, and the home fight, from the files named above:

| Removed (`--without`) | `the-corner-mixed`, same realm | `the-corner-home-mixed --gap 1` |
|---|---|---|
| Nothing | Win, 6 s on 70 % | Win, 7 s on 17 % |
| `requisition` | Win, 7 s on 67 % | **Loss, 10 s, enemy 15 %** |
| `scrape_share` | Win, 8 s on 65 % | **Loss, 10 s, enemy 29 %** |
| `tick_overflow_qi` (Spillover) | Win, 7 s on 64 % | Win, 7 s on 17 % |
| `Longer Breath` | Win, 7 s on 64 % | Win, 8 s on 10 % |
| `ward_thrift` | Win, 6 s on 66 % | Win, 7 s on 5 % |
| `closed_gate` | Win, 6 s on 66 % | Win, 8 s on 10 % |
| `Longer Breath` and `ward_thrift` | | Win by overkill, double knockout at 8 s |

The fixture agrees: at home one realm up it wins at 7 s on 34 % (`variants/the-corner-home-fixture.fight.json --gap 1`).

Efficiency is the second engine: the same build with ward strength 240 and efficiency 60 loses at 5 s with the elder on 59 % (`variants/the-corner-strong-ward-home-mixed.fight.json --gap 1`).

**The burn cap's reading:** the file takes Formulas F's 5 % per status, as the calculator does. Read as one cap per pulse, the same-realm win takes 8 s on 59 % and the home win takes 8 s on 10 % (`variants/the-corner-shared-cap.fight.json`, `variants/the-corner-shared-cap-home.fight.json --gap 1`).

**Unmodelled:** Cornered Market's price, its seasons and the city's reaction. It shows only as `start_qi`. Held Acres and Damage over time are folded into each status's `x`.

## New Concepts

**Cornered Market (Lũng Đoạn Thị).** Combat rule 3 already lets a fight request carry starting shares, for Tribulation. This lets a caller lower one side's linh lực share before a foreseen fight, at the place you hold, against a resident of at least one winter. Rules: Combat rules 3 and 12, plus an Event Engine check. Bound: never below 0.25. Breakdown line: "Opened on 25 % linh lực: a season of short supply." It also serves a poisoner who owns the well and a sect that feeds its guests before a duel. NPCs can use it where they hold a place.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Requisition | Needs rule | Combat Formulas F: burn counts as drain for anything reading drain |
| Scraping the Well, Spillover, Rush Order | Needs rule | As their own sheets |
| Cornered Market | Needs rule | Combat rules 3 and 12, Event Engine |
| Held Acres | Needs key | A read of `n_plots` at compile |
| Longer Breath, Thrift, Damage over time, Closed Gate | Needs key | As their own sheets |
| Sutra, arts, Hungry Courses, Granary Seal's flavour | Needs key | New content |

**Questions for the user:** (1) Is the 5 % qi burn cap per status or per pulse? Formulas F and AC-CB-38 can be read either way, and it changes every burn build. (2) May anything but Tribulation set a starting share? One lowered share turned a loss on 83 % into a win.

## Also Considered

- **Bank Run (Tễ Đoái):** burn only what the enemy has reserved. Dropped because reservation hardly exists yet.
- **The Long Siege (Vi Thành):** a win when a pool stays empty for 6 pulses, with no health damage at all. Dropped because Scraping and Longer Breath would have had nothing to do.
