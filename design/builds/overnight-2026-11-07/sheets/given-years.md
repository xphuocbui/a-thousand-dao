# The Given Years (Tặng Thọ Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Stronger as lifespan runs out: the last decade of a life, with a known date. Love or family is the reason. Lifespan as fuel must be a real choice over a whole life."
> **Direction**: The plan was a clock: a season burned each pulse, 40 seasons in 40 s. The numbers killed it, because fights end in 2 s and the clock barely moved. So blows themselves now take seasons instead of health, and the wick became the health bar. Arts stay paid in linh lực: this is not a resource swap.
> **Realm span**: Core Formation – Nascent Soul, defined at Nascent Soul · **Power level**: strong · **Use**: player build, or an NPC elder with a reason
> **Fit**: 3 Fits today · 10 Needs key · 4 Needs rule
> **Checks**: 9 PASS · 0 FAIL · 0 NOT ASSESSED

## The Spine

- **The channel:** art hits and the basic attack, on all five layers, through a common drain ward, paid in linh lực.
- **The enabler:** The Set Day. Once in a life, name someone you love and a day at most ten years off. Every year past that day goes to them. Closes: your lifespan can never rise again, so the climb is over.
- **The loop:** every blow that reaches you takes seasons, not health. Every season gone makes you hit harder.
- **The engine:** your remaining life is your health bar and your damage at once. Forty seasons is a deep body and a weak hand. Six seasons is a terrible hand and one more blow.
- **The sacrifice:** Deity Transformation, every year after the Day, and every season each fight costs. Nothing refills the wick.
- **The arc:** an ordinary life with a family in it, then one decision, then forty seasons to spend.

## The Legend

In the reed country a Nascent Soul elder married a rope-maker, a mortal, in a wet year. The sect called it a charming waste of forty years. At seventy the rope-maker's hands began to shake, and the elder had six hundred years left and no way to hand them over, until they noticed what their own house had always done. When the rice ran short at the end of winter, the one who loved more ate less and said they were not hungry. The Keeping-House Sutra is that sentence, refined for three centuries.

The elder woke old, with a date. The rope-maker woke sixteen and furious. Those who walk this path keep a calendar on the wall and are gentle with everyone, and a sect can hire one to kill far above their station, once, because they have nothing left to bargain with. Their enemies have learned not to fight them at all. They find out who was named.

## How It Fights

An ordinary fighter with a good stack, until someone hits them. Health does not move; the hair goes white. Each blow takes a year or two and the next swing lands visibly harder. The ward still matters more than in any other build, because linh lực spent on arts is ward not standing between a blow and a year of your life.

**The signature moment:** five years before the Day, a Nascent Soul kills a Deity Transformation cultivator in 3 seconds, pays 3.6 years for it, and walks home with 5 seasons left to spend at the table (`variants/given-years-s20-mixed.fight.json --gap 1`).

## Enabler

**The Set Day (Định Nhật).** Keystone on the Evening Table cluster. A moment in a life: an event, a bonded person and a preview that states the result, as Realms rule 14 already requires for a change that shortens a life.

- **Opens:** your age jumps to within ten years of your cap. The person named has their age lowered by half the years you gave, never below 16. What falls below 16 is lost. Both moves work like Burning Life to Break Through (#23): a change to age, not a lifespan bonus, so no ceiling absorbs them. Opens Paid in Seasons and Lit Wick.
- **Closes:** your cap is fixed. No pill, treasure or breakthrough raises it. The Day can only come nearer. If the person named dies, Given Years reads 0.

A Day-holder may still attempt a gate, and Last Radiance (#22) will help, but nothing moves the date. They would be a god with five years left.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Common arts | `c_art` 1.6 to 4.2, inside the lint | | art | | ◐ | Technique | |
| 3 Multiplier | Attack (`attack_pct`) | 195 points of tree | Increased | any | L1 | ● | Tree | everyone |
| 3 Multiplier | **Short Wick (Đoản Đăng)** | +5 points for each season of lifespan under 40 | Per | art, basic | L2 | ○ | Evening Table notable | any old cultivator, any Last Radiance life |
| 3 Multiplier | Given Years (Tặng Niên) | +2 points per 1 % of your realm's lifespan given away, while the person named lives, in any fight. This is the art and basic grade: The Herd-Child holds a companion grade of the same modifier, +1.5 per 1 % on L2, to +45, and one size would change fights | Per | art, basic | L4 | ○ | Set Day | any build with a sworn sacrifice: **used by The Herd-Child** |
| 3 Multiplier | Nothing to Lose (Vô Sở Thất) | +10 points for each doubling of the enemy's years left over your own, to +100 | Per | art, basic | L5 | ○ | Evening Table notable | any elder facing the young |
| 7 Fuel | Hearth Ash Talisman (Lô Hôi Phù), reused | Refunds 15 % of maximum linh lực while under 45 % | | any | none | ◐ | Talisman | |
| 8 Survival | **Paid in Seasons (Quý Thường)** | Health you lose is restored at the defeat check and burns 1 season per 20 % of maximum health. At 0 seasons you are Down, having acted in that instant | Rule swap | incoming | none | ○ | Set Day | a guardian bound to a fixed term |
| 9 Identity | Lit Wick (Tàn Đăng) | Each pulse of a fight burns a season, whether or not you are struck | Trade | any | none | ○ | Set Day | any build priced in time |

**Identity piece:** Paid in Seasons with Short Wick, one plug-in, `rules/lit_wick.py`. Remove it and the same character loses one realm up with the enemy on 85 %.
**The new Per:** Short Wick reads seasons of lifespan left, which no build has read. Nothing to Lose also reads the enemy's.
**Empty rungs:** crit and rate are ordinary, and past the cap is empty because Short Wick tops out at +200, under L2's 300. Rate is a sacrifice: this build's speed is its life's speed.

| Layer | Points at 14 seasons | Multiplier | Sources |
|---|---|---|---|
| L1 | 195 | ×2.95 | Tree |
| L2 | 130, rising to 200 | ×2.30 | Short Wick |
| L3 | 60 | ×1.60 | Gear |
| L4 | 80 | ×1.80 | Given Years at 40 %. A gift, not a coating: it works in a blind fight |
| L5 | about 72 | ×1.72 | Nothing to Lose, against a same-realm enemy with 500 years left |

Worked from those values, M is about 34 at the start of that fight, against 7.37 typical and 256 top-end.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire and Earth, purity about 50 | A hearth: Fire generates Earth. Ordinary, on purpose |
| Key talents | Any | This is a life an unremarkable person can have |
| The Way (Đạo) | None needed | One glimpse is better spent on what the family needs |

## Công Pháp

### Keeping-House Sutra (Trì Gia Kinh) — main, Địa giai

What the one who ate less was doing, written down.

```json
{"id": "tri_gia_kinh", "name": "Trì Gia Kinh", "tier": 2, "tech_kind": "main",
 "names": ["hoa", "tho"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 30}, {"stat": "khi_huyet_pct", "value": 22}],
 "abilities": [], "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 30 ÷ 20 + 22 ÷ 15 = 2.97 of 3; single values 1.5 and 1.47 of 1.5.

## Arts

Source: Keeping-House Sutra. All paid in linh lực.

| Art | Layer | Kind | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Threshing Flail (Đả Cốc) | 1 | body | 1.6 | 0.05 | 1 s | | Needs key |
| Banked Coals (Tàng Thán) | 3 | qi | 2.4 | 0.08 | 3 s | | Needs key |
| Splitting Maul (Phách Sài) | 6 | body | 2.4 | 0.10 | 2 s | | Needs key |
| Last Harvest (Mạt Thu) | 9 | qi | 4.2 | 0.25 | 2 s | Own seasons 14 or fewer | Needs key |

All inside the lint (`sheets/given-years.fight.json` prints it). **Description:** the work of a house, done harder than it needs to be.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | The four arts, Hearth Ash | Common drain | The cluster's first reach |
| Nascent Soul | 6 | The same | Common drain | One slot free |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Family Seal (Gia Ấn) | Artifact, weapon | `an`, Trung phẩm, Nascent Soul | L3, and an ordinary generated piece that came down the family | Fits today |
| Hearth Ash Talisman | Talisman, stock 2 | Reused from The Turned-Away | Buys one more blow of ward. Ash from the house's own stove | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Evening Table | Below | The build | Needs key |
| 2 | Attack, ward strength | The rest of W | Plain, and it works | Fits today |

### Hidden cluster idea: Evening Table (Vãn Thực Mạch)

Theme Longevity, Earth, outer, sealed by event: sit a last season with someone whose lifespan is ending. Size 8, so it gates at Core Formation. Small acupoints: health and `linh_luc_pct`. **Notables:** Short Wick and Nothing to Lose. **Keystone, as the capability on the farthest notable:** The Set Day. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining to Foundation | An ordinary cultivator | Threshing Flail | Marries, or takes in a child, or both |
| Core Formation | Ordinary, with a cluster waiting | Evening Table opens | Sits with someone dying and cannot help |
| Nascent Soul | The Day is possible | The Set Day | The choice below |
| The last ten years | Everything | Every season spent | Spends them on the table or on the road |

**When to set the Day.** The earlier, the more you give and the less you have built. All three are 14 seasons, against the mixed enemy, one realm up:

| Day set | Given | File | Result |
|---|---|---|---|
| Entering the realm, stage 1.00 | 75 % | `given-years-early` | Loses the overkill in a double knockout at 2 s |
| Mid-realm, stage 1.30 | 40 % | `given-years-mixed` | Wins at 2 s with 1.3 left |
| Near natural death, stage 1.45 | 8 % | `given-years-late` | Wins at 2 s with 2.8 left |

So love costs power, narrowly, and waiting costs the person you were waiting for: nobody has six centuries to be patient for a mortal. That is the real choice, and the fight's answer is close enough to leave it open. Against that, the gate itself: a Day-holder gives up Deity Transformation for good.

## Matchups

Variants are in `variants/`, named `given-years-[name].fight.json`.

| Enemy | Result | Why | File |
|---|---|---|---|
| Mixed, same realm | Wins at 1 s for 0.5 years | | `mixed` |
| Mixed, one up | Wins at 2 s for 3.2 years | See below | `mixed --gap 1` |
| Top-end, same realm | Loses at t = 1, enemy on 80 % | One blow takes all 14 seasons | main |
| ×8 boss, same realm | Wins at 3 s for 1.6 years | | `boss` |
| ×8 boss, one up | Loses at 3 s, boss on 82 % | | `boss --gap 1` |
| A wall one up that never strikes | The Day comes at 14 s, enemy on 63 %, no blow taken | Lit Wick is the clock, and the hunter only waits | `wall --gap 1` |
| An old rival with 5 years left, one up | Wins at 2 s | Nothing to Lose reads far lower, and here that is still enough | `old-rival --gap 1` |

**Counter:** one big blow, or patience. A top-end's first hit takes the whole wick. A wall, or any enemy who can run, spends your life for free. And the cruel one is not in the fight: kill the person named and Given Years goes to 0.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | 5 of 6 slots; four arts inside the lint; technique 2.97 of 3 |
| Validity | PASS | Tier 2 reaches `nguyen_anh`; size 8 is above `cap_min_n` 7, so the keystone gates at Core Formation. This is why the build cannot be defined lower: a capability needs that gate |
| Stack | PASS | Forms: Increased, Per, Rule swap, Trade. L1 to L5 all filled. `--without lit_wick` changes every fight |
| Scaling | PASS | About M 34, between the anchors, which suits strong. `m_static` 4.72 leaves out the Pers |
| The fight | PASS | Rules are a plug-in. No cap hit. The gift happens outside the fight and is listed |
| Reuse | PASS | Hearth Ash Talisman reused. Every new modifier has a home outside this build. 0 signature |
| NPC use | PASS | Seasons are a stored number, and no input is needed |
| Counterplay | PASS | Top-end, wall and boss all run above |
| Originality | PASS | Nothing borrowed. A vow to give one's years is a common folk motif, and all names are new |

## Fight Results

Input: `sheets/given-years.fight.json` at 14 seasons, through `_tools/fight_x.py`. The calculator clamps at Deity Transformation, so gap 2 is left out.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | win, 0.6 years burned | 1.000 | never | none |
| typical | 1 | win, and the Day comes in the same instant | 2.000 | 2.000 | none |
| top_end | 0 | loss, enemy 80 % | 1.000 | 1.000 | none |
| top_end | 1 | loss, enemy 96 % | 1.000 | 1.000 | none |

**The best day to kill a god.** The mixed enemy one realm up, by seasons left at the start. Files `given-years-s[n]-mixed`, or `mixed` for 14, each with `--gap 1`:

| Seasons | Result | Time | After |
|---|---|---|---|
| 40 | Loss, enemy on 42 % | 4 s | Dead |
| 32 | Loss on overkill, both at 0 | 4 s | Dead |
| 24 | Loss on overkill, both at 0 | 3 s | Dead |
| **20** | **Win** | 3 s | **5 seasons left** |
| 16 | Win | 2 s | 3 left |
| 14 | Win | 2 s | 1 left |
| 12, 8, 6 | Win, and the Day comes in that instant | 2 s | Dead |
| 4 | Loss, enemy on 63 % | 1 s | Dead |

**Removal runs** on `given-years-mixed`:

| Removed | Same realm | One up |
|---|---|---|
| Nothing | 1 s, 0.5 years | 2 s, 1 season left |
| `lit_wick` | 3 s, own health 43 % | Loss at 2 s, enemy on 85 % |
| `given_years` | 2 s, 1.1 years | 2 s, 1 season left |
| `nothing_to_lose` | 2 s, 1.1 years | Win at 3 s, and the Day comes in that instant |

`given-years-bereaved` (the person named has died) matches the `given_years` row. `given-years-plain-health` keeps Short Wick at a fixed +130 with ordinary health: it wins one up at 2 s by overkill, on 0 health. Paid in Seasons is the difference between dying there and going home.

**Second realm:** Core Formation (`core`) wins at 2 s against the same realm, and one realm up at 2 s with under a season left.

**The surprises:**
1. The clock was the seed and it did almost nothing. In the one-up fight the pulses burned 2 seasons and the blows burned 10.7.
2. The last year is not the strongest day. Below 6 seasons one exchange ends you. The best day to kill above your realm is about five years out, and the window closes on both sides.
3. The curve has a cliff in it. 24 seasons dies at 3 s where 20 walks away, and it comes down to the enemy's purse. The harder hits of 20 seasons drain its pool to 2 % by t = 2, so it cannot pay for the blow it means to land at t = 3. At 24 seasons it still holds 12 %, pays, and that one art takes the rest of the wick. Rule 11 decides who goes home (`--timeline` on both files).
4. The gift is worth seasons, not wins. Grief does not lose the one-up fight, but it doubles what a same-realm fight costs: 0.5 years becomes 1.1.

**For the user:**
- The fixture enemy hides all of this. At 40 seasons the build beats it one up at 5 s, on the last hundredth of a season, because the enemy bankrupts itself (`given-years-s40-fixture --gap 1`). The conserving enemy beats that same life with 42 % health left. The critic's point again.
- A double knockout decided on overkill is the build's natural ending, and "you won and you died" needs a line on the result screen. Combat's rule 14 result types do not have it.

**Unmodelled:** the gift, the fixed cap and the refused gate, all outside the fight. The `early` and `late` variants stand in for when the Day was set. An enemy who runs is not modelled; `wall` is the nearest shape.

## New Concepts

**Kin tie (Thân Duyên).** A named person bound to you by marriage, blood or adoption, beside Quests' master and disciple ties. Rule: Quests rule 16 and NPC Interaction. Bounds: one person named for the Set Day. Breakdown line: "Given Years +80: Rope-Maker lives". Serves any build about family, a beast bond, and the Event Engine's hostile events. Question: do you want a family system at all, and how thin can it be? NPCs can hold it as a stored id.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| The Set Day | Needs rule | Realms rule 14: a fixed cap, and age moved both ways, read like #23. The floor of 16 and the 0.5 gift rate are guesses |
| Paid in Seasons | Needs rule | Combat rules 3, 10: health loss paid at the defeat check |
| Lit Wick | Needs rule | Combat rule 10: a pulse can burn a stored life stat. Seasons burned reach Time & Turn after the fight |
| Kin tie | Needs rule | As above |
| Short Wick, Given Years, Nothing to Lose | Needs key | Compile reads of years left, and the enemy's years left |
| Art guard on seasons | Needs key | Combat rule 13's guard vocabulary |

## Also Considered

- **Burning Hours:** arts paid in years. The obvious reading, and the resource swap the critic has closed.
- **The Long Table:** a Per on living descendants, so a life's family is its strength. Lovely, but it needs the kin system to exist first. A strong next step if the Kin tie is approved.
