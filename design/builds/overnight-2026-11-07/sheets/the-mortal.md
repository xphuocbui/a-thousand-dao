# The Mortal (Phàm Thân Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 5 and seed 63: no ward and no arts, one merged self-hit that borrows a top-end's own M, sincere and frightened, defined below Qi Refining. A person who should not be in this fight.
> **Direction**: The Given Years says its enemies "find out who was named". This is the person named. They have done nothing, and someone is coming for them because of who loves them. The seed's self-hit is kept, but it does not carry the build. What keeps them standing is the years they were given, and every blow takes those years back.
> **Realm span**: Below Qi Refining, for one fight · **Power level**: none: they survive, at best · **Use**: a rare life or a chapter of one; an NPC a hunter is sent to; a warning to the player
> **Fit**: 2 Fits today · 2 Needs key · 7 Needs rule (3 new, 1 the merge, 3 already asked by The Given Years)
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: nothing without a hit is priced. Validity and Scaling: no realm below Qi Refining exists in the data or the anchors)

## The Spine

- **The channel:** none of their own. The first firing of each art aimed at them lands on its owner, at the owner's own M, at most 25 % of the owner's health. Their paddle does about 1 damage a second.
- **The enabler:** The Received Years. You are the mortal someone set their Day for. Closes: any cultivation, for good.
- **The loop:** there is no loop. They stand there, and they get older.
- **The engine:** Plain Blow under Paid in Seasons. A cultivator's force finds no linh lực to bite and passes through, and what stays is what a hand does to a person. That small, fixed hurt is paid in seasons of the gift, so a god's fist costs them about a year, the same as anyone's.
- **The sacrifice:** everything. They cannot win. The best result in the file is that it stops, and they are forty years older.
- **The arc:** seventy, then sixteen, then whatever they are when it stops.

## The Legend

Hạnh threw pots for fifty-four years and had a bad knee and a great many grandchildren. Their parent was a Nascent Soul who still looked forty, and who had buried three of Hạnh's children and did not mean to bury Hạnh. One morning Hạnh woke up sixteen, in the same bed, and the first thing they did was look at their hands, and they cried, because the calluses were gone. Their parent had a date on the wall now, and would not talk about it.

The hunter came in the second autumn, sent to kill Hạnh because a person named can be used against a Day-holder. Hạnh had never seen an art. They stood in the door of the workshop holding the paddle they beat clay with, and they said please. The first blow went back into the one who threw it, and neither of them knew why. Then the hunter used their hands. When it stopped, Hạnh was fifty-eight. They knew how to be fifty-eight. The knee hurt again. They sat down at the wheel, because it was there, and it was a long time before they could make their hands stop shaking enough to centre the clay.

## How It Fights

It does not. An elder fires an art at someone who is plainly nobody. It comes back and takes a quarter of their health and most of their sea, and for a moment they are the more frightened of the two. After that they take the person's measure and use their fists, and the person stays on their feet, because the blows take years in place of ribs. The hair goes first. Then the back. They hit the elder with a wooden paddle about once a second, because they do not know what else to do.

**The signature moment:** sixteen when the door opened. A top-end Core elder beats them for forty seconds, and they are 58 when the time runs out, with the elder on 73 % and 2 % linh lực (`sheets/the-mortal.fight.json --enemy top_end --gap 2`). A Deity does no better: 42.4 years, the Deity on 75 % (`variants/the-mortal-nascent-hunter.fight.json --enemy top_end --gap 2`).

## Enabler

**The Received Years (Thụ Niên).** Not found or earned. It is done to you, as the other end of The Set Day.

- **Opens:** while the giver lives, at most ten years: the years you were given become a wick. Blows take seasons, and every second of a fight takes one more, because nobody can be this frightened for free. An art's first firing at you turns.
- **Closes:** you can never cultivate. One point of linh lực ends it. The years cannot be given back, and what a fight burns is added to your age for good. At 0 you are Down.

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a plain pile of body guard became a wick you watch burn, and an unlimited self-hit became one that each art suffers once.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Turned Hand (Phản Thủ), merged** | One rule, below. Here it fires on the first firing of each art | Rule swap | enemy's art | none | ○ | Received Years | Lucky Fool, Stand-In, Way of Chance |
| Multiplier | None | L1 to L5 are empty. It is their M, not yours | | | | | | |
| Fuel | Paid in Seasons, reused unplanned | Health lost burns seasons of the gift, 1 per 5 % of health, not the giver's 20 % | Rule swap | incoming | none | ○ | Received Years | Reused from The Given Years, built for the one who gives |
| Fuel | Lit Wick, reused unplanned | A season a pulse, read here as terror | Trade | any | none | ○ | Received Years | Reused from The Given Years |
| Survival | **Plain Blow (Phàm Kích)** | A single hit on a side with no linh lực at all removes at most 8 health before body guard. Ticks and soul are not limited | Rule swap | incoming | none | ○ | Mortal Body | any levy row, The Ant General's ranks, a mortal-bodied puppet |
| Survival | Maximum health (Khí Huyết), notable | +6.5 %, on a stamped jack | Increased | any | none | ● | Item | any build |
| Survival | Body guard (Hộ Thể), notable | +8 %, on the same jack | Increased | any | none | ● | Item | any build |
| Survival | **Callus Returns (Kiển Hoàn)** | After 80 seasons have gone, +1 body guard base for the fight. The body remembers being old | Conditional | incoming | none | ○ | Received Years | any build whose age is moved back |
| Trade | **Measure Taken (Lượng Thủ)** | A turned art never turns twice. Its owner has corrected their aim | Trade | enemy's art | none | ○ | The door's rule | any once-only reflection |

**Identity piece:** the gift. `--without wick`, Down at 6 s with the elder on 75 %. That is a mortal with nobody who loved them enough. `--without pratfall`, they still stand 40 s, but it costs 46.3 years and the elder is on 98 %.

**The plain rows here are worth years, not damage.** Mortal Body closes the tree, so these two are affixes on a mass-made jack (Stamped Iron's rule: no thần thức). Take it off and the fight costs 44.6 years, not 42.4 (`variants/the-mortal-no-jack.fight.json --enemy top_end --gap 2`). `--without callus`, 49.1 years.

**Empty rungs:** rate, crit, reach and past-the-cap are sacrifices. They have nothing to spend on any of them.

### The merged self-hit: one rule, three doors

The critic found two copies. This sheet uses one, by `rules/pratfall.py`, with no third file.

> **Turned Hand.** A turned art still pays. Its hit resolves on its owner: same size, same M, through their own ward and guard, with no suppression, at most **25 %** of their maximum health. Basic attacks, companions, ticks and arts with no hit never turn.

| Door | When an art turns | From |
|---|---|---|
| Slip of the Hand | When the fortune roll says so | The Lucky Fool, Way of Chance. Its 30 % becomes 25 % |
| The curse | While a bearer carries it. Half strength stays a term of this door | The Stand-In |
| The Received Years | The first firing of each art, with no roll, then Measure Taken | Here |

**Why the clip is a rule:** take it away and one blow kills a Core top-end at 1 s, 15,239 health, with the mortal 1.1 years older (`variants/the-mortal-no-clip.fight.json --enemy top_end --gap 2`).

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | None | Mortal Body. A new origin, below the worst root in the game |
| Size | `power` 10, one step below Qi Refining on the ×10 ladder: fight unit 2.51, health 42.8 | A guess, as the data has no such row |
| Talents, Way, fortune, thần thức | None read | No file here reads fortune or sense. The door has no roll |

## Arts and Items

No arts. One basic attack, a wooden clay paddle, `c` 1.0.

| Item | Type, role | What it does | Fit |
|---|---|---|---|
| Stamped Jack (Ấn Giáp) | Mass-made coat, from Stamped Iron's rule | Carries the two plain rows | Needs key |

## How Old Were They

The gift is capped by their age, since the Set Day stops at 16. So the longer the parent waited, the more there is to spend. All against the top-end Core elder.

| Named at | Gift | Result | File |
|---|---|---|---|
| 30 | 14 years | Down at 12 s, elder on 74 % | `variants/the-mortal-named-at-30.fight.json --enemy top_end --gap 2` |
| 50 | 34 years | Down at 32 s, elder on 73 % | `variants/the-mortal-named-at-50.fight.json --enemy top_end --gap 2` |
| 70 | 54 years | Stands. 42.4 years gone, 11.6 left | main |

Waiting is what a parent of a mortal child cannot afford to do, and it is the only thing that helps.

## Matchups

Top-end and typical are the fixtures. All files are in `variants/` as `the-mortal-[name].fight.json` unless marked main.

| Enemy | Result | Years burned | File |
|---|---|---|---|
| Top-end Core | Stands 40 s, elder on 73 % | 42.4 | main `--enemy top_end --gap 2` |
| Top-end Nascent Soul | Stands 40 s, elder on 74 % | 42.4 | `nascent-hunter --enemy top_end --gap 1` |
| Mixed, Foundation | Stands 40 s, on 0.4 seasons | 53.9 | `mixed --gap 1` |
| Mixed, Core | **Down on the last second, elder on 74 %** | 54 | `mixed --gap 2` |
| Mixed, top-end Core | Stands, elder on 73 % | 48.5 | `mixed --enemy top_end --gap 2` |
| One jab and nothing else, ordinary Core | **Down at 36 s, elder on 86 %** | 54 | `one-jab --gap 2` |
| One jab, top-end Core | Stands, elder on 73 % | 48.5 | `one-jab --enemy top_end --gap 2` |
| Foreseen, a stranger's yard, L4 +40 on the paddle, mixed Core | Stands, on 0.4 seasons, elder on 74 % | 53.9 | `foreseen --gap 2` |
| Bare hands only | Stands, elder on 98 % | 39.1 | `hands --enemy top_end --gap 2` |
| Top-end with a dog | Down at 32 s, elder on 73 % | 54 | `dog --enemy top_end --gap 2` |
| A poisoner, ordinary Core | Stands, elder on 96 % | 48.0 | `poison --gap 2` |
| The same hunter comes back | Down at 10 s | 11.6, all that was left | `second-visit --enemy top_end --gap 2` |

**The ordinary one is the one who kills them.** A top-end's first blow is so large that its own ward empties paying for it, and it cannot afford another art for most of the fight. An ordinary elder's jab comes back small, the pool stays, and they keep throwing it. So the person is safest from those they should never have met.

**A day's warning buys a tenth of a year.** Foreseen is the difference between dying in the last second and not, because a coated paddle costs the elder a little more. Nothing else can be done with a day except spend it.

**Counter:** patience. A hunter who comes twice needs no skill at all. Then a companion, which never turns and doubles the blows. Then any ordinary cultivator with one cheap art.

**What the forty seconds are for.** Their parent arrives. `sheets/given-years.fight.json --enemy top_end`: a Day-holder at 14 seasons dies at 1 s with a fresh top-end on 80 %. `variants/the-mortal-parent-arrives.fight.json --enemy top_end`, against the hunter as Hạnh left them, on 74 % with 3 % linh lực: both fall at 1 s, and the hunter wins it on overkill. The parent does not survive it. Nor does the hunter.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | No arts to lint. The gift, the turn and Plain Blow have no price |
| Validity | NOT ASSESSED | The file says `luyen_khi`, and `mortal_body.py` replaces the size, as no realm below it exists |
| Stack | PASS | Forms: Rule swap, Trade, Increased, Conditional. Identity tested. Layers empty on purpose |
| Scaling | NOT ASSESSED | No anchor exists below Qi Refining, and a build with no damage meets none |
| The fight | PASS | Stalemates and knockouts as shown, in all six matrix fights and every variant. No `cap_hit` beyond the notes of turned arts |
| Reuse | PASS | Turned Hand, Paid in Seasons, Lit Wick, The Set Day, Kin tie, Stamped Iron and two plain rows. Each new piece has a second home |
| NPC use | PASS | All stored numbers and no input. Any mortal named on a Day holds it |
| Counterplay | PASS | A second visit, a dog, an ordinary jab |
| Originality | PASS | All names are new |

## Fight Results

Input: `sheets/the-mortal.fight.json`, with `rules/pratfall.py`, `rules/mortal_body.py`, `rules/lit_wick.py`. 216 seasons, the full 54 years. `--gap` reads from Qi Refining, so 0 is already a realm above them. Observations from `fight_x.py`, a paper model.

| Enemy | Gap | Result | Years burned | Enemy ends on |
|---|---|---|---|---|
| typical | 0 | Stands 40 s | 44.5 | 47 % |
| typical | 1 | Stands 40 s | 45.1 | 71 % |
| typical | 2 | Stands 40 s | 45.1 | 81 % |
| top_end | 0 | Stands 40 s | 41.5 | 48 % |
| top_end | 1 | Stands 40 s | 42.4 | 67 % |
| top_end | 2 | Stands 40 s | 42.4 | 73 % |

The paddle does most of the difference at gap 0. A hunter at Qi Refining loses 40 health to it over the fight.

**Second realm:** `variants/the-mortal-nascent-hunter.fight.json` sets the file at Core, so `--gap 1` is a Nascent Soul and `--gap 2` a Deity. **Unmodelled:** the gift itself, the ten-year window, and what a stalemate means here: the file stops at `time_limit`, and why the hunter leaves is the caller's business. At 0 seasons the file says Down, though their own old age would still be there.

## New Concepts

**Mortal Body (Phàm Thân).** A side with no linh lực at all, no ward, no arts and a power term below Qi Refining.

- **Rule:** Combat rule 23 today says a mortal takes hits nearly in full. This adds Plain Blow. Realms says mortals are not simulated, so this is a side the caller creates for one fight, as Levy does for a mass battle.
- **Bounds:** 8 before guard is about a fifth of their health. They last about 6 s with no gift (`--without wick`).
- **Breakdown line:** "Plain Blow: there was nothing for it to bite. 8."
- **Other builds:** The Ant General's levy rows, mortal-bodied puppets, a hostage event.
- **NPCs:** yes. The person named on any NPC's Day is a target for the Event Engine.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| The Received Years | Needs rule | Realms rule on Set Day: the person named holds a wick while the giver lives |
| Plain Blow, Mortal Body | Needs rule | Combat rule 23, Realms |
| Turned Hand, merged | Needs rule | One rule to replace two, and a ruling on the 25 % |
| Measure Taken | Part of the door | `once_per_art` in `pratfall.py`, off by default |
| Paid in Seasons, Lit Wick, The Set Day | Needs rule | Already asked by The Given Years |
| Callus Returns, Stamped Jack | Needs key | A read of seasons burned; a coat with no thần thức cost |

## Also Considered

- The Door (Đương Môn): any mortal who stands unarmed between a cultivator and someone else turns the blow. Moving, but it arms every mortal alive, and a sect would start pushing people through doors.
- The Line of Villagers (Liệt Dân): four mortals in a row at 25 % each kill an elder. The numbers refuse it: the first blow empties the elder's pool, so the next person only meets a fist.
