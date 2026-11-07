# The Ant General (Nghĩ Tướng Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The general: built for the mass-battle rating, not duels. Ambition as the mood. A person who is mediocre alone and terrifying with an army."
> **Direction**: The seed asked for a commander of cultivators. Reading Formulas K found a stranger one: a force's numbers are weighted sums with no ceiling, so the reserve weight of 0.25 never stops counting. Every cultivator in this genre treats mortals as ants. This is the build that does the sum.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: strong at war, poor alone · **Use**: player build, or the reason the mountains go to war
> **Fit**: 4 Fits today · 8 Needs key · 7 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** the rating clash of Combat rule 17, a new home for a build. The duel is not the build. R and P come from `rules/mass_rating.py`, which prints every input under `mass_` lines.
- **The enabler:** the Census Seal. It opens a levy row: mortals as members of a force. It closes the sects, and the next realm.
- **The loop:** raise the levy, arm it, pay for its ward, choose the field, make them come to it. Then count who is left and start again.
- **The engine:** a mortal has empty layers, so every point given to the force multiplies ten thousand people. The enemy has full layers, so a law that caps them takes away everything they trained for. The two meet on prepared ground.
- **The sacrifice:** personal power, by design. It loses to a typical cultivator of its own realm, and a top-end assassin ends it at t = 1. Its levy takes a generation to replace.
- **The arc:** a failed duellist with a seal, then a marshal with a city, then a throne. The cost arrives as a gate that will not open.

## The Legend

There is an old agreement between the mountains and the thrones: cultivators do not lead mortal armies, and mortal armies do not climb mountains. It has held for nine hundred years, because nobody ever wanted to break it. The third child of a border marshal's house found a root at thirty, reached Core Formation on bought pills, and lost every duel they ever fought, twice to people a realm beneath them. Their sect sent them home with a polite letter. They read it, rode to the capital, and asked to see the household registers.

The mountains call them the Ant General and believe this is an insult. It is on the banners now. They want the throne first and the mountains after, and they have priced both. Every clash eats a province's sons and a chest of stones, and every thousand dead is a mark on a heart that will never pass the gate to Nascent Soul. They have read that clause too. They say a gate is only a door somebody else is guarding.

## How It Fights

Alone, it fights like what it is: a cane, a shouted order, and dead at 3 s. It does not fight alone. Ten thousand spears stand on a field it chose, under a law it laid, each one insured with a ward no mortal should be able to hold.

**The signature moment:** a great sect marches on the capital: a top-end Nascent master, eleven war elders, two hundred disciples. They reach the field and find their arts are ordinary. The general, who would lose to any of the eleven, stays in a tent. R 2.37, P 0.97 (`variants/ant-general-elite.fight.json`). Take the law away and it is R 0.11, P 0.02.

## Enabler

**Census Seal (Hộ Bạ Ấn).** A named `an` artifact, stamped by a mortal throne, given once to a cultivator who asks for the registers and gets them. **Opens:** a levy row in Formulas K: mortal members in a force, as many as the registers hold. **Closes:** no sect will hold you or trade with you, and each 1,000 levy lost adds +1 heart demon, which `nascent_tam_ma_max` (20) reads at the gate to Nascent Soul. The army or the next realm. A levy regrows 3 % a year.

## The Stack

The ladder here is the rating channel: Off, health, pass and N_eff. Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a stack of officers became a stack on the levy, because the numbers said officers do almost nothing.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Census (Hộ Bạ)** | Mortals may be counted in a force as levy rows | Rule swap | rating | none | ○ | Census Seal | any throne's marshal; a sect that arms its villages |
| Base | Spear Drill (Thao Thương) | A levy's basic coefficient is 1.3 | Flat base | rating | none | ○ | Technique | any militia, any sect's outer ranks |
| Multiplier | Drilled Ranks (Thao Binh) | +50 to hits with the artifact source tag. **Reused from The Remnant Host**: the levy's spears carry that tag. Own law caps it at 40 | More | rating | L2 | ○ | Technique | **Reused** |
| Multiplier | Stamped Iron (Ấn Thiết) | +40 for mass-made arms, no thần thức, usable by mortals | More | rating | L3 | ○ | Item | any sect armoury |
| Multiplier | Field Array (Dã Trận) | The leader's formation adds its L4 to every member of the force: +40 | Redirect | rating | L4 | ○ | Cluster | any sect's great array in a war |
| Multiplier | Given to the Ranks (Phó Liệt) | Half your L1 leaves you and counts as L4 for every member: +60, and your own L1 falls from 120 to 60 | Borrow | rating | L4 | ○ | Cluster | any support who leads |
| Reach | Rank Lent | A force's realm for `g` is its leader's: Formulas K as written | none | rating | none | ● | Combat | every force |
| Past the cap | Rotating Ranks (Luân Xạ) | +0.10 to `mass_reserve_weight` for your force | Cap shift | rating | none | ○ | Cluster | any sect that drills its reserve |
| Survival | Indemnity Ward (Bồi Thường Hộ) | **Reused from The Full Price.** A ward paid in stones needs no linh lực, so a mortal can hold one: pass 0.4 and 0.3, 1 stone a soldier a second | Rule swap | rating | none | ○ | War chest | **Reused** |
| Survival | Level Ground (Bình Địa) | **Reused from The Level Ground.** L2, L3 and L5 count at most 40, 40 and 10 for both forces | Cap shift | rating | none | ○ | Formation | **Reused** |
| Survival | Taken Ground (Chiếm Địa) | **Reused from The Level Ground.** The other side's L4 counts at most 20 | Rule swap | rating | L4 | ○ | Formation | **Reused** |

**Identity piece:** Census. With `--without census` the same general and field face the sect master's muster at R 0.001, P 0.02.

**The standing rule, twice.** Indemnity Ward was written so a rich cultivator's linh lực would never be touched. Its unplanned use is that it needs no linh lực at all, so it is the only ward a mortal can hold. Level Ground was written for one farmer at home; on a battlefield it deletes what a great sect spent centuries on. Against the elite force (`variants/ant-general-elite.fight.json`):

| Removed | R | P |
|---|---|---|
| Nothing | 2.37 | 0.97 |
| `standing_ground` (both laws) | 0.11 | 0.02 |
| `indemnity` | 0.83 | 0.32 |
| Both of those together | 0.04 | 0.02 |
| `levy_arms` | 1.07 | 0.56 |
| `rotating_ranks` | 1.27 | 0.72 |
| `given_to_ranks` | 1.72 | 0.90 |
| `field_array` | 1.94 | 0.93 |
| `field_array` and `given_to_ranks`, which share a job | 1.29 | 0.73 |
| `field_array` and `levy_arms` | 0.89 | 0.38 |

Against the ordinary muster the law does nothing useful: R 6.15 with it and 6.56 without, because it also clips your own L2. It is an answer to elites and only that.

**Empty rungs:** Rate, because a mortal has no arts. Crit, a sacrifice. L1 and L5 on the levy, because a mortal has no tree and the law caps L5 anyway. Fuel is the chest.

| Layer | On one levy soldier | Multiplier | Sources |
|---|---|---|---|
| L1 | 0 | ×1.00 | A mortal has no tree |
| L2 | 40 of 50 | ×1.40 | Drilled Ranks, clipped by the law |
| L3 | 40 | ×1.40 | Stamped Iron |
| L4 | 100 | ×2.00 | Field Array, Given to the Ranks |
| L5 | 0 | ×1.00 | Empty |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth, any purity | Array work. Nothing asks more of it |
| Key talents | None worth naming | That is the point |
| The Way (Đạo) | Array, Field branch (from The Level Ground) | Ground Law |

## Công Pháp

### Standard-Bearer's Method (Chấp Kỳ Quyết) — main, Địa giai

A manual for standing where you can be seen by the drums, and nothing else.

```json
{"id": "chap_ky_quyet", "name": "Chấp Kỳ Quyết", "tier": 2, "tech_kind": "main",
 "names": ["tho"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "khi_huyet_pct", "value": 8}],
 "abilities": [{"ability_id": "quan_truong", "unlock_layer": 2}, {"ability_id": "ho_lenh", "unlock_layer": 5}],
 "seal_clusters": ["co_liet_mach"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 12/20 + 8/15 = 1.13 of 3.0, the largest 0.6 under the 1.5 single cap.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Officer's Cane (Quân Trượng) | Method, 2 | body | 1.48 | 0.04 | 1 s | none | Needs key |
| Shouted Order (Hô Lệnh) | Method, 5 | qi | 2.2 | 0.08 | 2 s | none | Needs key |

**Effect:** a hit each. **Description:** the two things a marshal does to someone standing too close.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Census Seal | Artifact, utility | `an`, named | The enabler | Needs rule |
| War Chest (Quân Khố) | Prepared stock | 50,000 stones for 10,000 soldiers: 5 s of ward. That is 10 × `linh_thach_max` at Core | The fuel: when it empties the ward falls | Needs key |
| Level Ground Array | Formation | Reused | Foreseen only, so the general must be attacked, or lure | Needs rule |

## Tree and Clusters

### Hidden cluster idea: Drum Line (Cổ Liệt Mạch)

Theme formations, Earth, outer, sealed by the Standard-Bearer's Method. Size 9. Small acupoints: formation power, health. Notables: Given to the Ranks, Rotating Ranks. Capability: Field Array. An idea for the tree rework, not data.

## Progression

Against the elite force, the leader's own realm is worth less than anyone would guess.

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | R 1.97, P 0.94 (`variants/ant-general-foundation-leader-elite.fight.json`) | Seal, levy | Asks for the registers |
| Core Formation | R 2.37, P 0.97 | Field Array, the law | First great sect broken |
| Nascent Soul | R 2.75, P 0.98 (`variants/ant-general-nascent-leader-elite.fight.json`) | Needs heart demon under 20, so few dead | The gate, if they ever stop |

## Matchups

All with 10,000 levy and 50,000 stones unless named. P is clamped at 0.98, so read R.

| Force | R | P | File |
|---|---|---|---|
| Sect muster: Nascent master, 11 Core, 40 Foundation, 150 Qi Refining, all typical | 6.15 | 0.98 | `sheets/ant-general.fight.json` |
| Great sect: top-end master and 11 top-end Core, the rest typical | 2.37 | 0.97 | `variants/ant-general-elite.fight.json` |
| Twelve top-end Core Formation | 3.24 | 0.98 | `variants/ant-general-twelve.fight.json` |
| Deity host: a Deity, 3 top-end Nascent, 8 top-end Core, 100 Foundation | 0.88 | 0.37 | `variants/ant-general-host.fight.json` |
| The same host, 15,000 levy | 1.86 | 0.92 | `variants/ant-general-host-15000.fight.json` |
| The same host, 20,000 levy | 3.15 | 0.98 | `variants/ant-general-host-20000.fight.json` |
| Great sect, eleven Long Carry bearers in the front rank | 2.67 | 0.98 | `variants/ant-general-long-carry-front.fight.json` |
| Great sect, a chest of 10,000 stones | 1.17 | 0.65 | `variants/ant-general-thin-chest-elite.fight.json` |
| Soul master: `pi_s` 0.3 on the muster, then on the great sect | 1.74, 1.00 | 0.90, 0.50 | `-soul-master`, `-soul-master-elite` |
| General killed before the clash: muster, then great sect | 1.84, 0.77 | 0.92, 0.26 | `-headless`, `-headless-elite` |

The Long Carry row answers that sheet's open question: eleven bearers show a rating of Off 148.5, health 304, drain 0.714, and add 13 % to R here.

**Counter:** the soul-piercer of Combat rule 18, because `pi_s` is not scaled by numbers. Better still, a top-end assassin: the general dies at t = 1, the array and the rank go, and the levy is a crowd. Or refuse the field: a great sect that will not come to the law is at R 0.11 the moment the general marches to it.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, slots 2 of 5, technique 1.13 of 3.0. Thần thức is not totalled |
| Validity | PASS | `tho`, tier `dia`, base `an`, reused Level Ground and Indemnity Ward records |
| Stack | PASS | 6 forms on the rating channel. Pairs removed together above |
| Scaling | PASS | `m_static` 2.08 against typical 5.48, below on purpose. INFO: R is above every anchor force but the Deity host |
| The fight | PASS | Duel as designed: loses every cell. The rating runs on Formulas K. Its agreement test against full fights was not run, and a levy has no full fight to agree with |
| Reuse | PASS | Four reused pieces, and two of them used against their authors' plan. Signature pieces: none |
| NPC use | PASS | A levy row is data. The Living World can give one to any marshal NPC, if the user wants that |
| Counterplay | PASS | Soul-piercer, assassin, refusing the field, emptying the chest |
| Originality | PASS | Rotating fire is history, not a work of fiction. No names taken |

## Fight Results

Input: `sheets/ant-general.fight.json`, through `rules/mass_rating.py`.

**Alone** (duel, `--matrix`): six losses. Typical same realm at 3 s with the enemy on 77 %, then t = 1 everywhere else. Mixed same realm at 3 s with the enemy on 77 % (`variants/ant-general-mixed.fight.json`). Keeping all 120 of its L1 changes nothing: it still loses at 3 s, enemy on 68 %, and R falls to 4.39 (`variants/ant-general-keeps-it-mixed.fight.json`).

**The clash, with its inputs, against the sect muster:**

| Input | Own force | Enemy force |
|---|---|---|
| N, N_eff | 10,001, 3,508.15 | 202, 59.5 |
| Off | 45,474 | 10,949 |
| Health | 35,929 | 22,052 |
| Linh lực | 1,242 | 32,433 |
| Pass, drain | 0.350, 0.000 | 0.333, 0.924 |
| f, body and qi | 0.983, 0.988 | 0.924, 0.943 |
| Net spend | 74.5 | 2,173.5 |
| Leader's realm | Core Formation | Nascent Soul, so own supp is 0.90 |
| Ward clock | 5.00 s of chest | t_w 1.18 s |
| T0 to beat the other | 1.37 s | 8.44 s |

One soldier: Off 12.8, health 10. The general: Off 592.9, health 701, one of 3,508 weights. R 6.146, P 0.980 at `kappa_mass` 4.

All enemies are the reference fixtures, so they carry no element and divine sense 1.0, and `pi_s` 0.3 is the ceiling `soul_cap` / `soul_lockout`, not a sourced profile.

**Assumptions**, printed by the plug-in, because Formulas K is silent: net spend summed like linh lực; uptime from a mirror fight; a per-pulse ward has no drain term; `pi_s` is not scaled by numbers; a mortal is `B_p` 10, so 0.398 of a Qi Refining fight unit, at `n` 0.25. At half that unit the muster is R 1.89 and the great sect R 0.67 (`variants/ant-general-weak-mortals.fight.json`, `-weak-mortals-elite`).

**Unmodelled:** levy deaths, regrowth, heart demon and stones after a clash, and how a player raises 10,000 people.

## New Concepts

**Levy (Hương Dũng).** A member row in Formulas K for mortals, who are not simulated (Realms: "background only"). Rule: Combat rule 17, Formulas K. Bounds: the registers of a held province. Breakdown line: "levy 10,000 at weight 0.35". Other builds: a sect arming its villages, a mortal rebellion as a world event. NPCs: possible, and a question below.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Census, Levy | Needs rule | Combat rule 17, Formulas K: mortal members |
| Field Array, Given to the Ranks | Needs rule | Rule 12, Formulas K: a leader's L4 reaches a force |
| Rotating Ranks | Needs rule | A modifier that moves `mass_reserve_weight` |
| Indemnity Ward, Level Ground, Taken Ground | Needs rule | As asked by their first sheets, plus K must read them for a force |
| Spear Drill, Drilled Ranks, Stamped Iron, method, two arts, Drum Line, War Chest | Needs key | Levy fields, records, a stock of stones as preparation |

## Questions for the User

- **Formulas K has no ceiling on reserves, even with no new rule.** `variants/ant-general-crowd-2000.fight.json`: one mediocre Core leader and 2,000 Qi Refining beat the muster at R 5.44. `-crowd-3900`, about all the Qi Refining in the world: R 18.58. Should the reserve saturate, or is that what a war is?
- **AC-CB-50's R 1.84 holds only where health runs out before the ward.** With typical members, 40 against 20 is R 2.18 under the same formula (`variants/ant-general-forty-twenty.fight.json`), because `t_w` does not scale with numbers.
- **AC-CB-49's T0 of 7.77 implies D_late 22.8, not the 20.65 of a basic attack.** The plug-in's literal reading gives 7.98, printed as `mass_selftest`. Everything else in that example matches.
- **Formulas K does not say** how a force sums net spend or `pi_s`, or how per-hit and per-pulse wards enter `t_w`. Should a per-pulse ward be free of D?
- May mortals ever be in a force? The whole build rests on this, and "a mortal stands no chance" is in the concept. The answer here is that one does not. Ten thousand do.

## Also Considered

- **The Regent:** a Foundation adjutant holding a drugged Nascent elder as figurehead for the leader's `g`. Wicked, but the numbers show rank is worth about 20 % of R.
- **The Supply Column:** a supply general whose negative net spend means the ward never falls. Sound, and it became the chest.
