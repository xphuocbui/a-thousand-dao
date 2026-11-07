# The Not-Yet-Full (Vị Bão)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A tally of cultivators defeated that grows forever, and what the world does about it."
> **Direction**: The tally is not a bonus. It feeds the fight unit, the one number in Combat with no cap, so a Core cultivator with a long enough dinner record eats a god. The world's answer is that its food learns to run.
> **Realm span**: Qi Refining – Core Formation, for ever, defined at Core Formation · **Power level**: strong at first, legend by the end · **Use**: player build, or the reason a world has a Reckoning
> **Fit**: 2 Fits today · 10 Needs key · 11 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: art guards and the Reckoning have no lint. NPC use: the Reckoning asks for world behaviour that does not exist)

## The Spine

- **The channel:** art hits, on L1, L2, L3 and L5, with an outer multiplier nothing else has. `fight_unit` raises power to 0.4, and health, linh lực and every hit all scale by it. Layers have caps. That does not.
- **The enabler:** The Tasting Book. Each knockout of a cultivator adds to Eaten Power, which counts as cultivation in a fight. It closes pills and seclusion for life.
- **The loop:** glaze, cut, eat, and write a review.
- **The engine:** the power of what you ate goes to your fight unit, so a kill is worth a share of the victim's realm. A Nascent Soul is worth a hundred Foundation elders. Eating down stops paying, and pride becomes good strategy.
- **The sacrifice:** the gate. Capability #9 adds +2 heart demon a kill, no pill can touch it now, and Nascent Soul asks for 20 or less. You will never break through, so you stay at Core and get bigger.
- **The arc:** you stop being a person of a realm. Suppression and slots stay at Core while the rest of you passes every elder alive, until the only thing left to eat is what is left.

## The Legend

The Palace of Nine Kitchens has fed one dynasty for six hundred years, and its youngest heir was refused only one thing in their life, by a Foundation elder who said they lacked the stomach for cultivation. The heir invited the elder to dinner. The Tasting Book's first entry reads: "Stringy. Overconfident. Three stars for the sauce."

It runs to eleven volumes now. "Ninth Peak, Core Formation: over-reduced. Too much seclusion." "Sect leader, nine hundred years in the cask: worth the wait. Would eat again, but there is only the one." The heir is delighted with all of this. The sects have called them a monster, a plague and a judgment of Heaven, and the only review that ever stung was the one that called them a glutton, which they had framed, and whose author they are saving for a special occasion.

## How It Fights

You smile, and you make their ward stronger. Honey Glaze settles on them and their shield thickens and every blow costs them more linh lực to stop, so the pool that would have paid for the door is gone. Your first cut lands 72 milliseconds before the fastest exit in the game can roll. They try to leave anyway, and each big blow tears the channel shut. There is a pause while you find your pen.

**The signature moment:** a Core Formation cultivator with 3,000 reviews sits down opposite a Deity, a being the world has three of, and has eaten them at 1.429 s, on 75 % health, for 86,876 power (`variants/not-yet-full-tally-3000.fight.json --gap 2`).

## Enabler

**The Tasting Book (Phẩm Thực Lục).** A blank register, bound in something the palace will not discuss, found in the ninth kitchen after the last head cook left without their hands. It takes a soul-bond and cannot be put down.

- **Opens:** Eaten Power and Clean Kill.
- **Closes:** Spoiled Palate, below, for life.

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a plain +X per kill became a read of the fight unit, and Fresh Bite, which read the victim's pool, became Clean Kill.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Eaten Power (Thực Lực)** | In a fight, your power term is your realm's power base plus what you have eaten. Realm, suppression and slots do not change | Borrow | any | none | ○ | The Tasting Book | any build that consumes a cultivator: a blood altar, a demonic inheritance |
| Base | Clean Kill (Nhất Khẩu) | A knockout of a cultivator adds 0.10 × their realm's power base × (0.25 + 0.75 × the health share they had when the last instant began). Chip damage spoils the meal | Per | any | none | ○ | The Tasting Book | any trophy hunter |
| Rate | Rush Order (Cản Đơn) | An art's first firing comes at half its effective cooldown, at +50 % price | Timing | art | none | ○ | Technique | **Reused from The Full Price** |
| Multiplier | Damage (`attack_pct`) | +240 | Increased | any | L1 | ● | Tree, technique | every build |
| Multiplier | Varied Diet (Tạp Thực) | +3 points to hits per different main technique eaten, to +60 | Per | art, basic | L2 | ○ | Hidden cluster | any collector of arts |
| Multiplier | Still Warm (Dư Ôn) | For 4 seasons after a knockout, you hold the victim's largest tag-keyed L2 modifier. +40 here | Borrow | art, basic | L2 | ○ | The Tasting Book | any mimic, any rival who fights the same person twice |
| Multiplier | Artifact attack | +110 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | First Taste (Sơ Vị) | +50 points to art hits while the target's linh lực is above 60 % | Conditional | art | L5 | ○ | Technique | any alpha strike |
| Reach | **Sweet Ward (Cam Hộ)** | A curse may strengthen a ward: `pass_raise` −0.4, so it blocks more and pays for it | Trade | ward drain | none | ○ | Art | **Reused from The Deepest Well**, where it was a drain tool for a support |
| Reach | Held at Table (Lưu Khách) | A single hit of yours for 20 % of the target's maximum health or more breaks an open escape channel. Cost, cooldown and stock stay spent | Trigger | any | none | ○ | Technique | any hunter, sect guard or bounty NPC |
| Fuel | Between Courses (Gián Thiện) | After a knockout of a cultivator, restore 25 % of missing health and 50 % of missing linh lực | Trigger | any | none | ○ | Hidden cluster | any gauntlet build |
| Trade | Spoiled Palate (Yếm Thực) | Pills do nothing for you, and seclusion adds no cultivation base. Only defeats fill the bar, through capability #9 | Trade | any | none | ○ | The Tasting Book | any demonic path |
| Life | Years at Table (Thọ Yến) | A knockout adds 5 % of the victim's years left to your lifespan, up to 3 × the realm's | Per | none | none | ○ | Hidden cluster | any life-thief |

**Identity piece:** Eaten Power. Against a mixed Nascent Soul, `--without eaten` still wins, but on 22 % health, not 82 % (`variants/not-yet-full-mixed.fight.json --gap 1`). The real measure is the Tally Ladder below.

**The borrowed piece:** Sweet Ward was built to feed a drain. Here it is cruelty. Your first Nascent Soul, on tally 0, armed with fast paper and rolling as if lucky (`variants/not-yet-full-tally-0-paper.fight.json --gap 1`): you win at 2.0 s on 22 %. `--without honey_glaze`, you lose at 2.0 s with them on 8 %. Making their ward stronger is what kills them.

**Pieces that share a job,** same file: `--without held_at_table`, they leave at 1.5 s on 37 %. Remove both, they leave at 1.5 s on 29 %. `--without rush_order`, they leave at 1.5 s on 80 %. Varied Diet and Still Warm removed together, they leave at 1.5 s on 83 %. `--without first_taste`, you lose at 3 s with them on 1 %. Each piece holds the door.

**Empty rungs:** L4 is a sacrifice, because Spoiled Palate closes pills. Past-the-cap is empty because there is no cap.

| Layer | Points at Core | Multiplier | Sources |
|---|---|---|---|
| L1 | 240 | ×3.20 | `attack_pct`, past the soft start |
| L2 | 80 + 100 | ×2.80 | Tag modifiers, Varied Diet 60, Still Warm 40 |
| L3 | 110 | ×2.10 | Gear |
| L4 | 0 | ×1.00 | Closed by Spoiled Palate |
| L5 | 50, on the opening | ×1.50 | First Taste |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth, which takes everything in | Harmony with the Bottomless Sutra |
| Key talents | Physique, Fortune | A body that survives wave two, and a say in the roll |
| The Way (Đạo) | Any Way, taken for its art nodes | The build's rule-bending lives in the Book |

## Công Pháp

### Bottomless Sutra (Vô Để Kinh) — main, Địa giai

A digestive exercise, written by a palace physician for a prince with a stomach complaint, and misread on purpose.

```json
{"id": "vo_de_kinh", "name": "Vô Để Kinh", "tier": 2, "tech_kind": "main", "names": ["tho"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "honey_glaze", "unlock_layer": 2}, {"ability_id": "first_cut", "unlock_layer": 4},
               {"ability_id": "carve", "unlock_layer": 6}, {"ability_id": "tucked_napkin", "unlock_layer": 8},
               {"ability_id": "second_helping", "unlock_layer": 10}],
 "seal_clusters": ["thuong_tich"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/15 + 20/20 + 15/15 = 3.0 of 3.0.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Honey Glaze (Mật Trấp) | Sutra, 2 | qi, curse | 1.0 | 0.05 | 0.85 s | none | Needs rule |
| First Cut (Sơ Đao) | Sutra, 4 | body, blade | 2.95 | 0.15 | 4 s, Rush Order | none | Needs key |
| Carve (Phiến Nhục) | Sutra, 6 | qi, blade | 2.2 | 0.08 | 2 s | none | Needs key |
| Tucked Napkin (Thiện Cân) | Sutra, 8 | body, lock | 1.0 | 0.03 | 2 s | none | Needs key |
| Second Helping (Thiêm Thiện) | Sutra, 10 | body, blade | 2.2 | 0.08 | 2 s | enemy health below 50 % | Needs key |

**Honey Glaze. Effect:** hit, then curse for 3 pulses: Sweet Ward. **Description:** basted, so the meat does not dry out.

**First Cut. Effect:** hit. At 40 % art speed Rush Order lands it at 1.428 s. **Description:** before the guest has found their chair.

**Tucked Napkin. Effect:** hit, curse for 3 pulses, `cost_raise` +50 %. Its lock tag takes 0.15 off every escape roll. **Description:** no one leaves before the fruit.

**What the numbers changed:** Fresh Bite read the victim's linh lực, which a ward always empties before health falls, so every meal scored its floor, and it became Clean Kill, which reads the health left at the last instant.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation | 4 | Glaze, First Cut, Carve, Napkin | Drain | `variants/not-yet-full-foundation.fight.json`, tally 40, power 1,500 |
| Core Formation | 5 | Glaze, First Cut, Carve, Napkin, Second Helping | Drain | The last slots you will ever get |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | High Table cluster | Below | Capability #9 is the bar's only food | Needs key |
| 2 | Damage, Art speed | To +240, +40 | The opening has to beat 1.5 s | Fits today |

### Hidden cluster idea: High Table (Thượng Tịch)

Theme: defeat, which any duellist or headhunter can want. Earth affinity. Sealed by the Bottomless Sutra's `seal_clusters`. Size 8: small acupoints of Damage and Health, notables Varied Diet, Between Courses and Years at Table, and capability #9 Great Essence-Draining Art on the outermost notable.

## The Tally Ladder

Mixed enemy. Power figures are saved in each file. Tally 3,000 at 300,000 power is about what all 27 Nascent Souls come to. Tally 5,001 is the whole census in Realms (3,936, 844, 191, 27, 3), each a perfect meal, at 884,760: at this first-guess share, **the entire world, eaten clean, is worth a little under one Deity's power.**

| Tally | Fight unit | Same realm | One up | Two up (a Deity) | Top-end, same realm | File |
|---|---|---|---|---|---|---|
| 0 | 39.8 | Wins 1.214 s | Wins 2.0 s on 22 % | Down at 1 s | Down at 1 s, they keep 90 % | `variants/not-yet-full-tally-0.fight.json` |
| 300 | 70.7 | Wins 1.0 s | Wins 1.429 s on 82 % | Down at 2 s, they keep 94 % | Down at 1 s, they keep 82 % | `variants/not-yet-full-mixed.fight.json` |
| 3,000 | 157 | Wins 0.607 s | Wins 1.214 s on 92 % | **Wins 1.429 s on 75 %** | Both fall at 1 s, and they win on overkill | `variants/not-yet-full-tally-3000.fight.json` |
| 5,001 | 240 | Wins 0.607 s | Wins 1.0 s on 98 % | Wins 1.429 s on 83 % | **Wins 0.607 s** | `variants/not-yet-full-tally-5001.fight.json` |

## What the World Does

A concept, The Reckoning, below. Each row is a change in NPC behaviour once your tally is known.

| Tally | The world's move | What it does in a fight |
|---|---|---|
| 10 | **Rumour.** Those who know carry an exit priced in linh lực, for use at half health | Nothing. The ward has emptied the pool by then, and the art never fires (`variants/not-yet-full-priced-exit.fight.json --gap 1`: no roll made) |
| 50 | **Closed gates.** Markets refuse you, and sects ring a bell | No fight, but a Core life with no shops |
| 200 | **The paper trade.** Your prey buy The Thirty-Six Exits, whose copies have never sold so well. Fast paper, first roll at 1.5 s, no linh lực | Nascent Souls leave unless you have every piece (`variants/not-yet-full-tally-0-paper.fight.json --gap 1`, above). At tally 300 you hold them (`variants/not-yet-full-paper-exit.fight.json --gap 1`, 2 channels broken) |
| 1,000 | **The Reckoning.** Three hunters, one after the other, no rest but 3 pulses | Below |
| any | **A nobody with a perfect build.** One top-end of your own realm | They do not need to be great. Their M is 210 against your 12 |
| 27 eaten | **The top goes dark.** Nascent Souls take centuries to replace, and intake only refills Qi Refining, about 42 a year | Sect libraries close, tiers stop selling, and the food left is worth 10 power each |

**The Reckoning,** at tally 300, three mixed Nascent Souls in a row, with health and linh lực carried and 3 pulses of rest. Between Courses and each bite are worked into the starts, rounded from the printed end state:

| Wave | File (`--gap 1`) | Start | Result | Bite |
|---|---|---|---|---|
| 1 | `variants/not-yet-full-mixed.fight.json` | 100 %, 100 % | Wins 1.429 s, ends on 82 %, 24 % | 3,288 |
| 2 | `variants/not-yet-full-reckoning-2.fight.json` | 86.5 %, 68 % | Wins 1.429 s, ends on 69 %, 1 % | 2,643 |
| 3 | `variants/not-yet-full-reckoning-3.fight.json` | 76.8 %, 56.5 % | Wins 1.428 s, ends on 59 %, 1 % | 7,982 |
| 2, no Between Courses | `variants/not-yet-full-reckoning-2-bare.fight.json` | 82 %, 30 % | **Down at 2 s, with them on 71 %** | none |

So the first elder is dinner, and the second is what kills you, unless the meal itself refills the pool. The world's committee sends three. It should send one, well built.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | A spoiled child with a blade, feeding on bandits for 10 power each | The Tasting Book | The first review |
| Foundation | Wins one realm up by reading the menu | Still Warm | The sects stop sending letters |
| Core Formation | Hunts sect leaders. Every bite is worth more than a lifetime of the small stuff | High Table | Heart demon passes 20, and the gate shuts. You send a note of thanks |
| Still Core, 300 years on | A god with Core suppression and five slots | Years at Table | Nobody is left who remembers refusing you, so you have to invent new reasons |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Any mixed cultivator to one realm up | Eaten | Tally Ladder |
| Priced exits | Eaten | The ward has spent the fare |
| Fast paper at tally 0 | Eaten only with every piece | Above |
| The Best Plan | Eaten at 20 s, the only fight in their book to end that way | `variants/best-plan-vs-not-yet-full.fight.json --gap 2`: each blow breaks the channel |
| Top-end, same realm | Loses until the world is nearly gone | M against fight unit: `sheets/not-yet-full.fight.json --enemy top_end` |
| A second elder with no Between Courses | Loses | The pool carries |

**Counter:** a well-built nobody of your own realm, with every layer filled. Second, a chain of fights with no knockouts to feed Between Courses.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Sutra 3.0 of 3.0, slots 5 of 5, all arts within the lint. The Book and the Reckoning have no budget to meet |
| Validity | PASS | Earth, `dia`, `attack_pct`, `linh_luc_pct`, `khi_huyet_pct` are real. Core is inside `dia`'s reach. #9 exists |
| Stack | PASS | Seven forms: Borrow, Per, Timing, Increased, Conditional, Trigger, Trade. Identity and pair removals run |
| Scaling | PASS | `m_static` 12.10 against typical 5.48 and top-end 210. L1 is above the top-end share of W: INFO |
| The fight | PASS | The loop runs at every tally. No art blocked. Own dry never at same realm |
| Reuse | PASS | Sweet Ward, Rush Order, Great Essence-Draining Art. Each new piece has a second home |
| NPC use | NOT ASSESSED | NPCs can run the stack. The Reckoning's guard changes need an NPC behaviour rule that does not exist yet |
| Counterplay | PASS | Top-end of your own realm, chained hunters |
| Originality | PASS | No names from existing works. The palace and its heir are new |

## Fight Results

Input: `sheets/not-yet-full.fight.json`, tally 300, power 32,000. Observations from `fight_x.py`, a paper model with expected values for chance. Prey in the exit variants roll at `{"threshold": 0}`, so every roll they make succeeds, which is the hard case.

| Enemy | Gap | Result | Time | Own health | Bite | Cap hits |
|---|---|---|---|---|---|---|
| typical | 0 | Win | 1.0 s | 98 % | 447 | none |
| typical | 1 | Win | 1.428 s | 77 % | 8,086 | none |
| typical | 2 | Loss | 1.0 s | 0 %, they keep 95 % | none | none |
| top_end | 0 | Loss | 1.0 s | 0 %, they keep 82 % | none | none |
| top_end | 1 | Loss | 1.0 s | 0 %, they keep 96 % | none | none |
| top_end | 2 | Loss | 1.0 s | 0 %, they keep 99 % | none | none |

**Second realm:** `variants/not-yet-full-foundation.fight.json --matrix`, mixed enemy: wins at 1.214 s, wins a Core at 2.428 s on 76 %, loses to a Nascent Soul at 2 s and to every top-end at 1 s.

**Unmodelled:** Spoiled Palate, Years at Table, Between Courses (worked by hand into `start_health`), the Reckoning's thresholds, and Rush Order's price, paid here on every firing.

## New Concepts

**The Reckoning (Thanh Toán).** The world reads the tally.

- **Rule:** new in Event Engine and NPC generation. Cultivators defeated is a public number with a rumour delay. At each threshold, NPC loadouts gain the row's change, and at 1,000 the Event Engine requests a run of fights, using Tribulation's carry-over rules (rule 7) with hunters as profiles.
- **Bounds:** thresholds are data. The run ends when a side falls.
- **Breakdown line:** "Tally 300: the world brings paper."
- **Other builds:** any infamous NPC, The Best Plan's manual as a market good, a sect war ladder.
- **NPCs:** an NPC with a high tally draws the same response, and the player can be sent as a hunter.
- **The question:** should the tally be public at once, or spread by witnesses?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| The Tasting Book, Eaten Power | Needs rule | Combat Formulas A: `fight_unit` reads a term beyond realm. The largest ask here: it has no cap by design |
| Clean Kill, Between Courses, Years at Table | Needs rule | Combat rule 14 reports the health at the last instant; Character Stats stores the total |
| Spoiled Palate | Needs rule | Realms and Alchemy: a flag that closes pills and seclusion |
| Still Warm | Needs rule | A carried modifier with a season timer |
| Held at Table | Needs rule | Combat rule 10: a hit may end an escape channel |
| Sweet Ward, Rush Order | Needs rule | Reused rule asks |
| The Reckoning | Needs rule | Event Engine, NPC generation |
| Varied Diet, First Taste, High Table, Sutra, arts | Needs key | New keys, tags and records |

## Also Considered

- The Unpaid Dead (Oan Trái): every kill stays with you as a ghost that adds to your hits and is owed a reckoning at Tribulation, which leaned on heart demon, a read the critic has rationed.
- The Headsman's Tally (Trảm Số): the world's own executioner, licensed, whose tally is a salary, with a neat rank ladder and no appetite at all.
