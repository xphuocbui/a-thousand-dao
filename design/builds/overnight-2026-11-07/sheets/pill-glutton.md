# The Pill Glutton (Thực Đan)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Pill glutton: overlapping pills and overdose as a timing tool." Order 4: 5 or more new pills, set in a mine, curiosity as the mood.
> **Direction**: Pills stay preparation only (rule 12). A wax coat decides when each one wakes, so the whole fight is swallowed before it starts.
> **Realm span**: Qi Refining – Core Formation, defined at Foundation Establishment · **Power level**: strong in a foreseen fight, nothing in a blind one · **Use**: player build, or a mine's stubborn old assayer
> **Fit**: 9 Fits today · 15 Needs key · 1 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, and the new pills have no recipe price yet)

## The Spine

- **The channel:** art hits and the basic attack, on all five layers. L4 exists only inside a dose's window, and L5 only over the line.
- **The enabler:** Cut Fuse. A pill swallowed in preparation acts in a window of the fight. It closes every blind fight, and most second fights for a decade.
- **The loop:** hold for four seconds on the props, then let everything come on at once.
- **The engine:** there are two orders. The order you swallow sets each pill's strength, because Formulas D reads toxicity before each one. The fuse sets when it acts. They are independent, so the pill that must be strongest goes down first and comes on last.
- **The sacrifice:** no blind fights, no long fights, no fighting upward, and about 53 toxicity carried out of every fight.
- **The arc:** at Qi Refining, two pills and a held breath. At Foundation, seven and a plan. At Core, the same plan with one more art, and a body that has begun to pay for the last one.

## The Legend

At the Ô Sơn tin workings a new face is shot by hand. The deepest hole is packed first and given the longest fuse, the shallow ones after, so the rock comes down in order. Thạch Vấn was born there and asked why, and never quite stopped asking. They tasted seam water to learn what was in it. They wrote down how long each ache took to come on. When a travelling alchemist left a box of pills against a debt, they ate one a day and noted the hour, not out of courage, only because they wanted to know.

The wax came from the mine's lamps. A pill rolled in it woke late, and two that woke together did something neither did alone, and Thạch Vấn sat down on the spoil heap, delighted, and was sick for a week. That was thirty years ago. Their hair went early and their hands shake until noon. When a Core Formation cultivator came to claim the workings, Thạch Vấn asked for one day to prepare, partly for the miners and partly because they had always wondered what seven at once would do. They wrote that down too, afterwards, in a hand nobody else can read.

## How It Fights

For three seconds almost nothing happens. Pick Stroke lands at 2 s, the ward takes the blows on Pit-Prop, and the pool falls to 31 %. Fire-Setting wakes at 3 s. At 4 s four more doses wake in one pulse, the load jumps from 14.4 to 44.8, and three arts and the basic attack land together. The enemy goes from 87 % to 56 %. At 5 s Hồi Xuân Đan wakes, the health it restores feeds Gorged, and Seam Charge fires on all of it.

| t | Waking | Acting | Load | Own health, pool | Enemy health, pool |
|---|---|---|---|---|---|
| 0 | Pit-Prop, Deep-Air | 2 | 8.0 | 100, 100 | 100, 100 |
| 3 | Fire-Setting | 3 | 14.4 | 60, 31 | 87, 71 |
| 4 | Great Charge, Second-Wind, Dregs | 6 | 44.8 | 46, 34 | 56, 18 |
| 5 | Hồi Xuân Đan | 5 | 39.2 | 76, 13 | 0, 0 |

Rows 3 to 5 are from `variants/pill-glutton-mixed.fight.json --timeline`.

**Signature moment:** four seconds of doing nothing, on 60 % health and falling, while the fuses burn. Then the whole seam comes down in one instant.

## Enabler

**Cut Fuse (Tiệt Dẫn).** Found as a craft note, or learned from anyone who has shot rock for a living. A pill rolled in lamp wax has a fuse: an onset and a length in whole pulses.

- **Opens:** a pill acting inside a fight, in a window you chose in advance. Any pill can be waxed, for +2 toxicity. Windows open and close at a pulse.
- **Closes:** the doses are swallowed before the fight and cannot be changed. A blind fight has none. A dose acts once, on the clock, whether or not the fight has gone as planned.
- **Over the Line (Quá Tuyến):** load is the sum of the toxicity of the doses acting now, after `dan_doc_resist_pct`. At load 30 or more you are over: +28 L5 points on hits, and 4 % of maximum health lost at each pulse, past ward and guard.

## The Stack

Sizes on new rows are first guesses. Walk it as a path: most of this is the ordinary tree.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Pill effect in a fight (`pill_effect_pct`) | 3 small + 2 notable, +15 | Increased | any | L4 | ● | Tree | any pill user |
| Base | Empty Stomach (Không Phúc) | +20 % potency on the first pill of a preparation | Conditional | any | L4 | ○ | Notable | any breakthrough pill |
| Multiplier | Damage (`attack_pct`) | 2 notable + 3 small, about +20 | Increased | any | L1 | ● | Tree | everyone |
| Multiplier | Gorged (Bão Lôi) | +1 point per 1 % of health restored this fight | Per | art, basic | L2 | ◐ reused | Technique | Drink the Lightning |
| Multiplier | Bright Blood (Xích Huyết) | +2 small, +12 notable, on hits while over the line | Conditional | art, basic | L5 | ○ | Acupoint, notable | any overdose or drug build |
| Certainty | Crit chance | 10 %, ×1.5 | Increased | art, basic | none | ● | Tree | everyone |
| Fuel | Ward efficiency, Maximum linh lực | Plain rows, +25 and +30 | Increased | any | none | ● | Tree | everyone |
| Survival | Ward strength, Body guard, Maximum health | Plain rows, +25, +15, +25 | Increased | any | none | ● | Tree | everyone |
| Survival | Toxicity Tolerance (Nại Độc) | +2 small, +12 notable on `dan_doc_resist_pct`, total +20. Lowers load and toxicity kept | Increased | any | none | ○ row, ● key | Acupoint, notable | anyone who eats pills |
| Identity | Over the Line (Quá Tuyến) | Above | Trade | art, basic | L5 | ○ | Cut Fuse | signature |

**Identity piece:** Cut Fuse. Without it (`--without dose_timeline`, which is also a blind fight) the mixed fight is lost at 5 s with the enemy on 71 %. With every pill taken but no fuse (`no-fuse`, all onsets 0) it is lost at 6 s with the enemy on 51 %. The pills are not the build. Their timing is.
**The plain test:** remove Empty Stomach or Bright Blood alone and the fight does not move. Remove both (`no-empty-stomach --without "Bright Blood"`) and it takes 6 s, on 65 %.
**Empty rungs:** Rate is the fuses. Reach and Past the cap are sacrifices: no pierce, and L4 peaks at 56 of 150.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 20 | ×1.20 | Damage |
| L2 | 0, then up to 50 | up to ×1.50 | Gorged, from 5 s |
| L3 | 30 | ×1.30 | Gear |
| L4 | 0, 18 from 3 s, 56 from 4 s | up to ×1.56 | Fire-Setting, Great Charge |
| L5 | 0, 40 over the line | ×1.40 | Over the Line, Bright Blood |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth with some Water | Water purity adds to toxicity decay at 0.05 a point, the only free cure |
| Key talents | Comprehension, for recipes | A quality 1 pill is worth 25 % more before toxicity is read |
| The Way (Đạo) | None | The path is alchemy and the tree |

## Công Pháp

### Seam-Water Method (Mạch Thủy Quyết) — main, Huyền giai

A miner's breathing exercise, for bad air, that also happens to hold a dose steady.

```json
{"id": "mach_thuy_quyet", "name": "Mạch Thủy Quyết", "tier": 1, "tech_kind": "main",
 "names": ["tho"], "layers": 9,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}],
 "abilities": [{"ability_id": "seam_charge", "unlock_layer": 6}],
 "seal_clusters": ["hoan_lap"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 20 / 20 = 1.0 of 2.0, one bonus, reaches Core Formation.

## Arts

| Art | Source | Kind | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Pick Stroke (Hạo Kích) | Technique | Body | 1.2 | 0.04 | 2 s | | Needs key |
| Wedge (Tiết Thạch) | Technique | Qi | 2.2 | 0.08 | 2 s | Fight time 4 s | Needs key |
| Shot Hole (Bạo Khổng) | Technique | Qi | 1.9 | 0.06 | 2 s | Fight time 4 s | Needs key |
| Seam Charge (Mạch Bạo) | Layer 6 | Body | 3.4 | 0.12 | 5 s | | Needs key |
| Backfill (Hồi Điền) | Layer 9, Core only | Body | 2.4 | 0.08 | 3 s | Fight time 4 s | Needs key |

All are inside the art lint. The time guards are rule 13's own vocabulary. They keep the pool for the peak, and a fight with a different peak needs them moved. Only Bright Blood's guard (`over_line`) is new.

## Items: The Pills

**In the order swallowed.** Potency is Formulas D at that moment, from `variants/pill-glutton-mixed.fight.json`, at quality 1 unless stated, with +15 pill effect, 20 % resistance and starting toxicity 5.

| # | Pill | Toxicity | Fuse | Potency | Effect at potency 1 | Fit |
|---|---|---|---|---|---|---|
| 1 | Great Charge Pill (Hỏa Dược Đan) | 10 | 4 to 7 s | 1.60 | +24 L4 | Needs key |
| 2 | Hồi Xuân Đan, in game data, waxed | 3 + 2 | 5 to 6 s | 1.00 | Restores 50 % of health | Needs key (the fuse) |
| 3 | Fire-Setting Pill (Thiêu Thạch Đan) | 8 | 3 to 7 s | 1.19 | +15 L4 | Needs key |
| 4 | Second-Wind Pill (Hậu Khí Đan) | 6 | At 4 s | 1.10 | Refills 30 % of linh lực | Needs key |
| 5 | Pit-Prop Pill (Chi Trụ Đan) | 6 | 0 to 5 s | 1.03 | +70 ward strength | Needs key |
| 6 | Deep-Air Pill (Thâm Khí Đan) | 4 | 0 to 8 s | 0.96 | +3 regeneration, inside `regen_cap` | Needs key |
| 7 | Dregs (Đan Tra), waxed | 20 + 2 | 4 to 8 s | 0.73 | Nothing. Load 17.6 | Reused |

Great Charge goes down first and wakes fifth, for the reason the charges in a shaft are packed that way. Dregs, a failed brew worth a few stones, goes down last because its strength does not matter. It is the switch: without it the peak load is 27, under the line.

## Tree and Clusters

### Hidden cluster idea: Slow Wax (Hoãn Lạp)

Theme: pills and what a body can hold, wider than this build. Earth affinity. Outer, sealed by a technique, and the Seam-Water Method lists it. Size 8: small acupoints of Pill effect and Toxicity Tolerance, a notable for Bright Blood, the payoff Empty Stomach. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | Two doses and a basic attack | Cut Fuse | Sick for a week, and pleased |
| Foundation | Seven doses, one peak | Over the Line | The first fight with a plan |
| Core Formation | The same plan, one more art (`core`) | Backfill, a body art guarded at 4 s | Hands that shake until noon |

## What the Timeline Costs

Every number here is a saved run against the mixed enemy. The home result is 5 s on 76 %.

| Change | File | Result |
|---|---|---|
| Swallow in reverse, same fuses | `reversed` | 6 s on 46 % |
| Without Dregs, so never over the line | `no-dregs` | 6 s on 51 % |
| Without Hồi Xuân Đan | `no-hoi-xuan` | 6 s on 8 % |
| Without Second-Wind | `no-second-wind` | 7 s on 6 % |
| Without Pit-Prop | `no-pit-prop` | 5 s on 51 % |
| Without Deep-Air | `no-deep-air` | 5 s on 76 %, pool 1 % |
| Without Gorged | `mixed --without Gorged` | 6 s on 65 % |
| Fuses cut 1 s short | `short-fuse` | 5 s on 51 %, pool 0 |
| Fuses cut 2 s long | `late-fuse` | Both fall at 6 s, and the enemy wins on overkill |
| The next fight, toxicity 52 | `second-fight` | Lost at 7 s, enemy on 21 %, toxicity 100 |

**The bill for a fight** is outside it. Toxicity leaves at 53.8, so cultivation runs at × 0.73. At 1 a season, with no Water and no cure, it takes 49 seasons, about twelve years, to return to 5. A Thanh Độc Đan taken after the fight is at potency 0.53, so it removes 13.3.

**Gorged is the piece borrowed unplanned,** from Drink the Lightning. There it reads Still Water. Here a waxed pill feeds it, and L2, otherwise empty, fills for exactly one art.

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Mixed, same realm | Wins, 5 s on 76 % | The peak lands before the pool runs out |
| One jab and nothing else (`jab`) | Wins, 5 s on 80 % | The plan does not care how little they do |
| Abroad, foreseen (`abroad`) | Wins, 5 s on 76 % | No ground piece, so nothing is lost. The pills travel |
| Mixed, one up | Loses at 3 s, enemy on 97 % | Dead before the fuse. Short fuses do not save it: 3 s, enemy on 91 % (`short-fuse --gap 1`) |
| Ordinary boss, pool × 2.5 (`long-seam`) | Loses at 6 s, enemy on 52 % | The seam outlasts the charge. A later peak is worse (`long-seam-recut`: 6 s, enemy on 66 %) |
| Blind | Loses at 5 s, enemy on 71 % | Nothing was swallowed |

**Counter:** anything with a deep pool, or anything that strikes before the peak. A second fight in the same decade is the worst enemy it has.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Art lint within on all four. Slots 4 of 4. Technique 1.0 of 2.0. Thần thức not totalled, and pills are unpriced |
| Validity | PASS | Tier 1 reaches Core Formation. `tho`, `pill_effect_pct` and `dan_doc_resist_pct` are real |
| Stack | PASS | Five forms: Increased, Conditional, Per, Trade, and Timing in the enabler. Three rungs named as fuses or sacrifice |
| Scaling | PASS | m_static 1.56 against typical 4.19, peak about 6.4 in the window |
| The fight | PASS | The loop happens. No cap hit. No piece is unmodelled in the engine |
| Reuse | PASS | Gorged and Dregs reused, 8 plain rows, one signature piece |
| NPC use | PASS | A dose list is fixed before the fight, so a generator can author one |
| Counterplay | PASS | A deep pool beats it (`long-seam`), and so does a blind start |
| Originality | PASS | Nothing taken from another work |

## Fight Results

Input: `sheets/pill-glutton.fight.json`, plug-ins `dose_timeline` and `gorged`. A paper model, with expected values for chance.

| Enemy | Gap | Result | Time | Own health, pool | Enemy health |
|---|---|---|---|---|---|
| typical | 0 | Win | 5 s | 81 %, 30 % | 0 |
| typical | 1 | Loss | 2 s | 0, 0 | 98 % |
| typical | 2 | Loss | 1 s | 0, 0 | 100 % |
| top_end | 0 | Loss | 1 s | 0, 0 | 99 % |
| top_end | 1, 2 | Loss | 1 s | 0, 0 | 100 % |

Second realm, `variants/pill-glutton-core.fight.json`: wins at 4 s on 45 %. `pill-glutton-core-mixed`: wins at 5 s on 80 %.

**Unmodelled:** what toxicity does after the fight (worked above from Formulas D), and a fuse cut for the wrong day.

## New Concepts

**Timed dose (Định Tễ).** A pill with an onset and a length, in whole pulses. Rule 12 and Character Stats rule 12's "timed pill effects", which Item Database Open Question 7 leaves open. Bounds: onset and length in whole pulses, and L4 inside its cap. Breakdown line: "Great Charge Pill, +38 L4, 4 to 7 s". Other users: any Foreseen build with a coating, and a healer who times a dose for an ally. NPCs can use it.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Cut Fuse with Over the Line | Needs rule | Combat rule 12 and Item Database Open Question 7: a prepared pill may act in a window |
| Five pills, Bright Blood, Empty Stomach, five arts, technique | Needs key | Recipe `effect` type for a dose, and the arts catalogue |
| `over_line` guard | Needs key | One word in rule 13's guard vocabulary |

## Questions

- Should any pill take a fuse? Hồi Xuân Đan restores 50 % mid-fight for 5 toxicity, and that alone is worth a full second. It may need a price of its own.
- Is a load line better read from the sum of toxicity, or from the count of doses? Toxicity lets `dan_doc_resist_pct` raise the line for free.

## Also Considered

- **Toxicity as a poison aura:** the blood itself as a tick. Too near The Taster's Fever.
- **One long dose:** the whole fight at a low steady load, no peak. Safe, and a stat bundle.
