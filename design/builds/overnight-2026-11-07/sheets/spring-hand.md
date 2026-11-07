# The Spring Hand (Xuân Thủ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: 40, "Twenty talismans: a gambler's sleeve." Critic order 4: 5 or more talismans, capability #13 if it fits, joy or pride, a real craft, nobody frightened, plain modifiers for talismans.
> **Direction**: The gamble is not the dice, it is the bill. Paper already paid for leaves the pool alone, a guarded paper costs nothing until it fires, and more than one in three comes back and fires again. So every fight has its own price in seasons at the desk.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: strong · **Use**: player build, or the loudest guest at any sect's New Year
> **Fit**: 1 Fits today · 14 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: no talisman lint exists, so the five records sit inside the art lint only by the rule this build asks for)

## The Spine

- **The channel:** art hits and one tick, all with the `talisman` tag, on L1 to L5.
- **The enabler:** Paid in Advance, on the Spring Couplet Method. A talisman pays no linh lực when it fires. Closes every other art: only paper goes in your slots.
- **The loop:** five kinds on five timers, each behind a guard. The fight decides which paper burns.
- **The engine:** capability #13 and Let It Ride. A paper that comes back fires again, so one chance is both fuel and tempo. Remove them and the Wall burns all twenty, not ten.
- **The sacrifice:** no arts, no crit, no escape. When the sleeve is out you have your fists. It loses to anything that kills you in the first second.
- **The arc:** a hawker with twelve sheets at Foundation, the best hand on the street at Core, a sleeve that barely burns at Nascent.

## The Legend

Every town on the coast road buys its luck from Red Paper Street (Hồng Chỉ Phố) in the last month of the year: door gods, couplets, strings of paper crackers. On New Year's Eve each town burns the old charms in the square and bets on which will not catch. A sheet that comes out of the fire goes back over the door and is called a good year. The painters say that is craft and the gamblers say it is luck, and both have been shouting about it, happily, for three hundred years.

Tô Hỉ is the best hand on the street and will tell you so before you sit down. They took up cultivation at thirty because a cultivator's paper sells higher, found it also hits harder, and have been delighted ever since. They stake a winter's work at any table, sign every sheet, and have never kept a talisman past New Year. Elders who lose to them must then hear what each sheet cost. Elders who beat them hear it too.

## How It Fights

Crackers go every half second, and the pool does not move. The Closing-Day Notice taxes their arts at 0.92 s, the Slow Match lands at 1.83 s, and at 2.75 s the Red Envelope and the Torn Couplet open together. Most fights end on that instant, or just before it. Against the Pulse enemy the target dies with 69 % of their linh lực, and you stand on 85 % of yours (`variants/spring-hand-pulse.fight.json`): nobody's pool is the story here.

**The signature moment:** the Wall, twice (`variants/spring-hand-wall.fight.json`). With the paper that comes back: 5.5 s, 72 % health, 10.4 sheets, 5.3 seasons of drawing. With `--without unburnt`: 10 s, 22 % health, all twenty, 11.7 seasons. It is the same hand. Tô Hỉ will say the difference is craft.

## Enabler

**Paid in Advance (Tiên Phó)**, Rule swap, the Spring Couplet Method's founding rule. The linh lực went into the paper at the desk. A talisman keeps its authored cost for the art lint and pays none of it when fired, so its stock is its price. It closes every art but paper. `--without paid_in_advance` on the Wall loses at 7 s with the enemy on 64 %.

## The Stack

A 55-node walk at Core, 46 acupoints and 9 notables, 127 W, about a quarter of the tree. Sizes are first guesses. `Without` is the Wall, from `variants/spring-hand-wall.fight.json --without "[id]"` or the named file: time, own health, sheets burnt. Full fight: 5.5 s, 72 %, 10.4.

| Rung | Modifier | Take | Effect | Form | Layer | Status | Home | Second home | Without |
|---|---|---|---|---|---|---|---|---|---|
| Multiplier | **Talisman damage (Phù Thương)** | 18 + 2 | +2 / +12 to hits with the talisman tag, +60 | Increased | L1 | ○ new, catalogue tag row | Acupoint, notable | any talisman user | 9.0 s, 39 %, 15.2 |
| Multiplier | **Talisman power** | 8 + 2 | +2 / +12, +40, read as preparation, so a blind fight loses it | Increased | L4 | ○ catalogue | Acupoint, notable | Brush Fee's Blank Slip | 7.0 s, 50 %, 12.8 |
| Rate | **Talisman art speed (Phù Tốc)** | 3 + 1 | +1 / +6 %, +9 % | Increased | none | ○ new, catalogue tag row | Acupoint, notable | any talisman user | 6.0 s, 55 %, 11.0 |
| Fuel | **Good Paper (Thượng Chỉ)** | 3 + 1 | +1 / +6 % to the chance a used talisman is not consumed, +9, to 60 % at most | Increased | none | ○ new | Acupoint, notable | any #13 holder | `bare-30-wall`: 5.8 s, 61 %, 13.3 |
| Multiplier | **Warm Hand (Thủ Nhiệt)** | 4 + 1 | +0.25 / +1 per talisman fired this fight, +2 a firing, to +40 | Per | L2 | ○ new | Acupoint, notable | any burst of cheap arts | 5.8 s, 61 %, 12.8 |
| Multiplier | Steady Thread, retagged | 6 + 1 | +2 / +12 to talismans while linh lực is 50 % or above, +24. On a pool nothing spends it is rarely false | Conditional | L5 | ○ reused | Acupoint, notable | Daily Lesson | 5.8 s, 61 %, 12.8 |
| Fuel | **Steady Brush (Ổn Bút)** | 4 + 1 | +1 / +6 % draw success, +10. Outside the fight | Increased | none | ○ new | Acupoint, notable | any talisman crafter | not in the fight |
| Multiplier | **Signed Paper (Lạc Khoản)** | 1 | +3 to talismans you drew yourself per talisman skill level, +21 at 7. Bought paper gets none | Per | L2 | ○ new | Cluster notable | any crafter who fights with their own work | 5.8 s, 61 %, 12.2 |
| Fuel, Identity | Endless Talismans, capability #13 | 1 | 30 % a used talisman is not consumed | Trigger | none | ● reused | Cluster notable | | with Let It Ride, below |
| Identity | **Let It Ride (Thừa Hứng)** | 1 | A talisman that was not consumed fires once more in the same instant. That firing cannot come back | Trigger | none | ○ new | Cluster notable | any stock art | `no-ride-wall`: 9.0 s, 27 %, 14.0 |
| Multiplier | Sized Paper (Phàn Chỉ) | | +30 to talismans, prepared | More | L4 | ○ reused | Preparation | Brush Fee | 5.8 s, 61 %, 12.8 |
| Multiplier | Full Sea (Mãn Hải) | | +30 while linh lực is above 80 %. Reused, not planned: the pool had nothing else to do | Conditional | L5 | ○ reused | Tree | Fortieth Breath | 5.8 s, 61 %, 12.8 |

**Identity piece:** Endless Talismans with Let It Ride. `--without unburnt`, above. Removing the pair from the home fight moves the win from 1.8 s to 2.8 s and sheets from 3.0 to 7.0.
**The plain rows work as a road.** `no-plain-wall`, with Talisman damage, power and speed, Warm Hand and Steady Thread gone, loses at 12 s with the Wall on 44 %. `no-plain-mixed` wins at 3 s on 51 %, against 2.8 s on 81 %.
**Empty rungs:** crit and pierce, as sacrifices. No crit row here earned a place.

| Layer | Points at Core | Multiplier | Sources |
|---|---|---|---|
| L1 | 60 | ×1.60 | Talisman damage |
| L2 | 21, to 61 | ×1.21 to ×1.61 | Signed Paper, Warm Hand |
| L3 | 40 | ×1.40 | One plain weapon |
| L4 | 70 | ×1.70 | Talisman power, Sized Paper |
| L5 | 54 | ×1.54 | Steady Thread, Full Sea |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire at any purity | Red ink. Nothing reads it |
| Key talents | Soul strength (thần hồn) 70, talisman skill 7 | The draw formula and Signed Paper |
| Ward | Stone Ward (Thạch Hộ), reused, upkeep at the legal 0.10 | Nothing else spends the pool. On Common the Fast fight ends at 2 s on 21 % health and an empty pool (`spring-hand-common-fast`), not 2.8 s on 52 % |
| Pool | **Sold.** `n_qi` 1.0 | Costs and upkeep are shares of maximum and nothing here spends a point of it, so maximum linh lực buys nothing. The same 46 W in health moves the Wall from 65 % to 72 % at the same time (`spring-hand-unsold-wall`) |

### Spring Couplet Method (Xuân Liên Quyết), main, Địa

Painters' breathing, written down by someone who wanted it to hit harder. Holds the enabler and seals the cluster.

```json
{"id": "xuan_lien", "name": "Xuân Liên Quyết", "tier": 2, "tech_kind": "main", "names": ["hoa"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 10}], "abilities": [], "seal_clusters": ["hong_chi_pho"], "origin": "authored"}
```

**Fit:** Needs rule (slots hold paper only) · **Budget:** 10 / 15 = 0.67 of one bonus, no arts of its own

## The Sleeve

Five new talismans. All are `talisman`-tagged arts, stock used up, cost paid at the desk. Draw % is the shipped formula at skill 7, soul strength 70.

| Talisman | Kind | c_art | Ink share | Cooldown | Stock | Guard | Effect | Difficulty, yield | Draw % | Seasons a sheet |
|---|---|---|---|---|---|---|---|---|---|---|
| **New Year Cracker (Bạo Trúc Phù)** | Body | 1.4 | 0.05 | 0.5 s | 8 | Enemy health above 30 % | Hit | 45, 4 | 95 | 0.26 |
| **Red Envelope (Hồng Bao Phù)** | Body | 4.5 | 0.25 | 3 s | 3 | Enemy health below 80 % | Hit | 80, 1 | 66 | 1.52 |
| **Closing-Day Notice (Bế Thị Phù)** | Qi | 1.0 | 0.05 | 1 s | 2 | Enemy linh lực above 50 % | Hit, curse: +50 % art cost, 3 pulses | 55, 2 | 91 | 0.55 |
| **Torn Couplet (Phá Liên Phù)** | Qi | 1.6 | 0.05 | 3 s | 3 | Enemy health above 30 % | Hit, curse: pass ×1.5, 3 pulses | 60, 2 | 86 | 0.58 |
| **Slow Match (Hoãn Hỏa Phù)** | Qi | 1.3 | 0.05 | 2 s | 4 | Enemy health above 20 % | Hit, then a tick, `c_tick` 0.5, 4 pulses | 55, 2 | 91 | 0.55 |

Without, on the Wall (time, health, sheets): Cracker 9.5 s, 27 %, 8.5. Envelope 7.0 s, 50 %, 11.6. Notice, Couplet or Match 5.8 s, 61 %, 11.0. Without the Envelope, Fast drags to 9 s on 13 % (`spring-hand-fast.fight.json`).

### Hidden cluster idea: Red Paper Street (Hồng Chỉ Phố)

Theme: Way of Talismans (Phù Đạo), on the map already. Fire affinity. Outer, sealed by a technique, size 9, so it opens at Core at the earliest. Six small acupoints of Talisman damage and power. Notables: Signed Paper, Let It Ride, and Endless Talismans as its capability.

## Loadout by Realm

| Realm | Slots, stock | Keep | Result, Mixed | Result, Wall |
|---|---|---|---|---|
| Foundation | 4, 12 sheets, no Notice | None: #13 waits behind Core | 5 s on 13 %, 9.0 sheets (`foundation-mixed`) | Loss at 9 s, Wall on 75 % (`foundation-wall`) |
| Core | 5, 20 sheets | 0.39, with ride | 2.8 s on 81 %, 3.7 sheets | 5.5 s on 72 %, 10.4 sheets |
| Nascent Soul | 6, 27 sheets, adds Hearth Ash Talisman, reused | 0.45, with ride | 2.6 s on 85 %, 2.8 sheets (`nascent-mixed`) | 5 s on 79 %, 6.6 sheets (`nascent-wall`) |

Hearth Ash never burns in these fights. That is the point of a guard: insurance that is not called costs nothing.

## Matchups

The panel at Core, one file each, `variants/spring-hand-[name].fight.json`. Seasons is `paper_burnt` times the table above.

| Enemy | Result | Time | Own health | Sheets | Seasons | Which paper |
|---|---|---|---|---|---|---|
| `mixed` | Win | 2.8 s | 81 % | 3.7 | 2.0 | Crackers, one Envelope |
| `pulse` | Win | 2.8 s | 73 % | 4.3 | 1.8 | Crackers and Notices, no Envelope |
| `wall` | Win | 5.5 s | 72 % | 10.4 | 5.3 | Everything |
| `evader` | Win | 2.8 s | 73 % | 4.3 | 2.2 | More Crackers |
| `fast` | Win | 2.8 s | 52 % | 3.0 | 1.7 | One Envelope carries it |
| `boss`, Mixed ×4 pool | Win | 5 s | 40 % | 7.9 | 3.7 | |
| `cheap`, one art at cost 0.04 | Win | 2.8 s | 82 % | 3.7 | 2.0 | |
| `blind-mixed` | Win | 2.8 s | 73 % | 4.9 | | L4 gone. Paper survives a blind fight, its preparation does not |
| `blind-wall` | Win | 11 s | 27 % | 15.9 | | |

**Counter:** a top-end at its own realm kills you at t = 1 with 89 % health left, and a typical one realm up at 2 s on 69 % (`--matrix`). A curse that blocks the `talisman` tag for 3 pulses (Formulas F) should blank the whole hand, since all five kinds carry it: `unmodelled`, no number.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | All five inside the art lint on their ink share, slots 5 of 5, Slow Match 2.0 within 2.22, curses inside Formulas F. But the lint was built on linh lực paid in the fight, and no talisman lint exists |
| Validity | PASS | Realms, tier, Stone Ward at the legal 0.10, capability #13 from `meridian_capabilities.json`, Way of Talismans on the map |
| Stack | PASS | Six forms: Increased, Conditional, Per, Trigger, More, Rule swap. Identity test changes the fight |
| Scaling | PASS | INFO: `m_static` 1.40 hides the tag rows. Live M is about 7.1 to 9.4 against typical 5.48 |
| The fight | PASS | Loop runs in all nine matchups. No cap hit |
| Reuse | PASS | Stone Ward, Sized Paper, Full Sea, Steady Thread, Hearth Ash, #13, catalogue Talisman power. Steady Thread and Full Sea proved by removal. No signature piece |
| NPC use | PASS | Every row reads a sheet value. #13 has `npc_effect` none, so an NPC sleeve would need one |
| Counterplay | PASS | Above |
| Originality | PASS | Door charms and New Year betting are folk custom. Nothing lifted |

## Fight Results

Input: `sheets/spring-hand.fight.json`, `--matrix`. A paper model. Chance runs as expected value, so sheets are averages, not one night at the table.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 83 % | 1.8 s | never | none |
| typical | 1 | Loss, enemy on 69 % | 2 s | never | none |
| typical | 2 | Loss, enemy on 97 % | 1 s | never | none |
| top_end | 0 to 2 | Loss, enemy on 89 % or more | 1 s | never | none |

**Unmodelled:** drawing time and ink, a `talisman` tag block, and the spread of real dice.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Paid in Advance | Needs rule | Combat rule 13 and the unwritten Talismans GDD: what a talisman costs when fired |
| Spring Couplet Method | Needs rule | A main method that limits slots to paper |
| Let It Ride | Needs rule | Combat rule 9: a trigger on capability #13's roll, inside `trigger_depth` |
| Five talismans, Red Paper Street | Needs key | `talisman` tag on art records, cluster data |
| Eight plain rows | Needs key | Tag keys, a Per on firings and on talisman skill, a chance key under 60 % |

**Questions for the user.** (1) Does a talisman cost linh lực when fired? Combat does not say, and `crafting_talismans.json` still spends them at the start of a fight, not as arts. (2) No rule limits stock in a slot: only seasons do. Is that enough? (3) At ink share 0.25 the lint gives `c_art` 4.5 for no linh lực. Should stock have its own term in a talisman lint?

## Also Considered

- The Marked Deck (Ám Ký): guards reading statuses other paper set, so the sleeve is a small program. Mostly fits today, but the guard vocabulary cannot read evasion, so it could not branch where it mattered.
- The Empty Sleeve (Không Tụ): a spent kind counts as an empty slot, so paper gives way to a fist saint. Good second act, and the Wall ends before it starts.
