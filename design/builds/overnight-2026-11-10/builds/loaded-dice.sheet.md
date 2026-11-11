# The Loaded Dice (Quán Cốt)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A gambler's build: chance-based arts and khí vận (fortune) as a stat, but counted chance (rule 15 wants chance to stay a flavour), so the dice are loaded in the player's favour by preparation. Fun to watch, swingy but not random.
> **Direction**: The Counted House (Định Mệnh Đạo): every chance is a visible meter, fortune fills the meters.
> **Realm span**: Trúc Cơ to Nguyên Anh · **Power level**: ordinary to top-end · **Use**: player
> **Fit**: 8 Fits today · 7 Needs key · 11 Needs rule (26 staged rows; six of the rules are Đạo nodes of one idea)
> **Checks**: 7 PASS · 0 FAIL · 3 NOT ASSESSED (technique budget; identity test; the fight, because the engine is unmodelled)

## Directions considered

Chosen: **The Counted House (Định Mệnh)**, a counting build on Called Blow (Effects System rule 12) plus a keystone that feeds fortune into the meters. It is the one direction where "dice" and "deterministic" are the same idea, and it needs only one rule exception.

- **The Reroll Rider (Thiên Quyến Đạo)**, rejected: Heaven's Favour rerolls a failed roll. Effects Open Question 7 says a reroll needs a new action and may not exist next to counted chance, and rerolls bring back real randomness (rule 15).
- **The Ill Star (Hung Tinh Đạo)**, rejected as the main build: curse the enemy's fortune so every shifted roll tilts. Fortune only shifts 0.001 per point, so it is weak damage; it survives as this build's counter and as a rival.
- **The Banker (Chủ Sổ)**, rejected: spend lifespan or khí vận as payment for jackpots. A strong dark-path idea but it pays outside the fight and does not use the dice at all.

## The Spine

- **The channel:** art hits with crit. Layers L1 to L4 are filled (L5 empty); crit is the build's second axis (chance 0.30 at Core Formation, 0.40 at Nascent Soul, caps 0.5 and 3.0).
- **The enabler:** The Loaded Table (Mệnh Đạo capstone keystone). Opens: counted evade, and khí vận adds up to +0.15 to every counted chance. Closes: no escape art, and fortune no longer shifts any rolled chance.
- **The loop:** throw cheap thunder arts (Cast the Bones) so the meters fill; every third hit crits on a visible meter; every third crit is a Jackpot; payouts feed linh lực back (Winnings) and damage forward (Stacked Meter).
- **The engine:** fortune is prepared before the fight (dice, array, pill) and becomes meter fill. The player loads the dice at home; the fight only reads the count.
- **The sacrifice:** it cannot flee, cannot use rolled chance, its L1 is modest, and its crit chance is capped at 0.35 before fortune. It is weak against soul and tick damage (evade and crit do not touch them).
- **The arc:** Trúc Cơ: Called Blow only, a steady third-hit crit. Kết Đan: the Table opens, evade is counted, Jackpot arrives. Nguyên Anh: Spilled Luck and House Takes All let the player choose when to cash the meter.

## The Legend

A grain-tax clerk in a border sect (tông môn) kept the sect's ledgers for forty years and noticed that fortune was never luck: the sect that arrived early, with the right pill and the right array, always "got lucky". He carved the knucklebones of his dead master into a pair of dice and wrote a sutra in column form: a chance is a debt, and a debt can be counted.

His heirs call it the Counted House. Gamblers in the lower cities pay to watch them fight, because the crowd can count along. The Tử Vận sect (a Mệnh Đạo school that curses luck) hunts them: an Ill Star on a Counted House disciple turns the ledger red.

## How It Fights

A pair of meters sit above the cultivator: one for crits, one for dodges. Both start half full, because the dice were loaded that morning. Every hit adds the crit chance to the meter; at one, the hit crits. Every third crit is a Jackpot and hits for a full extra multiplier step. Winnings pays linh lực back, so the pool never runs dry in a fight of 15 to 25 seconds.

**Signature moment:** the crit meter reads 0.9, the player's House Takes All is ready, the third-crit counter shows 2 of 3. The art fires: crit, and Jackpot, and the meter flashes. The crowd counted it before it happened.

## Enabler

**The Loaded Table (Quán Bàn).** Found as the capstone of Mệnh Đạo's Định Mệnh branch, after Called Blow. Opens counted evade and the fortune feed (0.002 per point of khí vận, at most +0.15, added after the chance's cap). Closes: no escape art, and fortune stops shifting rolled chances. Needs rule (Effects System rule 12).

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Arts' c_art | Cast the Bones 2.0, Counting Blade 3.1, Raise the Stakes 4.6 | Flat base | art | none | ● | Sutra | any art build |
| 2 Rate | Flowing Water | A crit shortens the other arts' timers by 0.5 s | Trigger | art | none | ◐ | Mệnh Đạo notable | any crit chain |
| 2 Rate | Art speed | +10 % (Core), +15 % (Nascent) | Increased | art | none | ◐ | Tree | any art build |
| 3 Multiplier | Attack | +70 points L1 (Core) | Increased | art | L1 | ● | Tree, Đạo W | any |
| 3 Multiplier | Art damage | +6 L2 on the thunder and metal arts | More | art | L2 | ○ | Sutra | any art build |
| 3 Multiplier | Stacked Meter (Tích Tiết) | +2 % more per payout in 8 s, cap 10 | Per | art | L2 | ○ | Đạo notable | counted-chance builds |
| 3 Multiplier | Ledger-Bone Dice, Nine-Star Array | L3 gear and L4 formation | Increased | art | L3, L4 | ○ | Items | any art build |
| 4 Crit | Called Blow | Crit counted, cap 0.35 | Rule swap | art | none | ◐ | Đạo keystone | crit, sword |
| 4 Crit | Fortune feed (the Table) | +0.002 per khí vận, at most +0.15 | Borrow | art | none | ○ | Enabler | fortune builds |
| 4 Crit | Jackpot (Đại Phát) | Every third counted crit +1.0 crit multiplier | Per | art | none | ○ | Đạo notable | counted-chance builds |
| 5 Reach | Thunder debuff stacks (Thunder Debt) | crit_taken and critdmg_taken on the target | Per | art | none | ● | Art | any thunder build |
| 6 Past the cap | Spilled Luck (Dật Phúc) | Crit chance above 0.35 becomes crit multiplier | Overflow | art | none | ○ | Đạo notable | crit builds |
| 7 Fuel | Linh lực regained on a crit | +0.6 % of maximum on a counted crit; regeneration, cost reduction | Trigger | any | none | ○ | Sutra, tree | any crit build |
| 8 Survival | Counted evade (the Table) | Every Nth hit is dodged, N = 1 / p_evade | Rule swap | any | none | ○ | Enabler | evade builds |
| 9 Identity | The Loaded Table | Fortune becomes meter fill | Borrow | art | none | ○ | Đạo capstone | fortune builds |
| 9 Timing | Loaded Start (Quán Khởi) | Meters start at 0.5 | Timing | any | none | ○ | Pill, notable | counted-chance builds |

**Identity piece:** The Loaded Table. Without it fortune does nothing for a counted build and the player holds a worse Called Blow (0.35 cap, no evade meter).
**Empty rungs:** L5 is empty (a sacrifice: crit and counted payouts are not "while" conditions). Reach by pierce is a gap, filled only by the thunder debuff stacks.

| Layer | Points at Kết Đan | Multiplier | Sources |
|---|---|---|---|
| L1 | 70 | ×1.70 | Tree attack, Đạo W |
| L2 | 20 (+6 to 10 on the arts) | ×1.2 | Sutra, Art damage, Stacked Meter average |
| L3 | 15 | ×1.15 | Ledger-Bone Dice |
| L4 | 10 | ×1.10 | Nine-Star Array, pill |
| L5 | 0 | ×1.00 | empty |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Thunder (Lôi), a convergence of Fire and Metal, purity 80 or more | Thunder stacks give accuracy and crit, and the debuff stacks raise crit taken; Metal arts share the tags |
| Key talents | Fortune (khí vận) high, Comprehension | Khí vận is the fill; the sutra learns faster |
| The Way (Đạo) | Mệnh Đạo, Định Mệnh and Khí Vận branches: Called Blow, Open Book, Tally Keeper, House Edge, Spilled Luck, Jackpot, then The Loaded Table | Counted chance and fortune are Mệnh Đạo's own themes |

## Công Pháp

### Nine-Bone Ledger Sutra (Cửu Cốt Toán Kinh): main, Địa giai (tier 2)

A column-ruled sutra: each layer adds one line to the ledger.

```json
{"id": "nine-bone-ledger-sutra", "name": "Cửu Cốt Toán Kinh", "tier": 2, "tech_kind": "main",
 "names": ["loi"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_regen_pct", "value": 10}, {"stat": "crit_chance_pct", "value": 6}],
 "abilities": [{"ability_id": "winnings", "unlock_layer": 4}, {"ability_id": "raise-the-stakes", "unlock_layer": 8},
               {"ability_id": "house-takes-all", "unlock_layer": 12}],
 "seal_clusters": ["gamblers-row"], "origin": "authored"}
```

**Fit:** Fits today (bonuses), new art records · **Budget:** NOT ASSESSED: the Σ value / pool_max check needs both keys in `bonus_pool`; tier 2 `max_realm` is nguyen_anh, so the span is reached.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Cast the Bones (Phóng Cốt) | Sutra 1 | qi, thunder, strike | 2.0 | 0.04 | 2 s | none | Fits today |
| Counting Blade (Toán Đao) | Sutra 2 | qi, metal, strike | 3.1 | 0.06 | 4 s | none | Fits today |
| Thunder Debt (Lôi Trái) | Sutra 3 | qi, thunder, status | 1.4 | 0.03 | 3 s | none | Fits today |
| Winnings (Thắng Lợi) | Sutra 4 | qi, thunder, restore | 0.8 | 0.05 | 6 s | none | Fits today |
| Raise the Stakes (Đại Chú) | Sutra 8 | qi, metal, strike | 4.6 | 0.08 | 8 s | none | Fits today |
| House Takes All (Nhà Cái Thắng) | Sutra 12 | qi, thunder, strike | 3.4 | 0.05 | 6 s | Cash Out | Needs rule |

**Effects:** Cast the Bones: a hit and one thunder buff stack on you. Counting Blade: a hit. Thunder Debt: a hit and 3 thunder debuff stacks. Winnings: a hit and 3 % of maximum linh lực back. Raise the Stakes: a slow, large hit. House Takes All: if the crit meter reads 0.6 or more, the hit crits and 1 comes off the meter; below 0.6 it waits.
**Descriptions:** the bones fall, the blade tallies, the debt is called, the winnings come home, the stakes go up, the house takes it all.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Trúc Cơ | 4 | Bones, Blade, Debt, Winnings | Common Ward | Called Blow only: a crit every third hit, no Table yet |
| Kết Đan | 5 | Bones, Blade, Debt, Winnings, Stakes | Common Ward | The Table opens; counted evade; Jackpot |
| Nguyên Anh | 6 | Bones, Blade, Debt, Winnings, Stakes, House Takes All | Drain ward, ws_base 50 | Cash Out times the payout |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Ledger-Bone Dice (Toán Cốt Tử) | Artifact, utility, named | utility base, high grade, Kết Đan tier | +15 khí vận, +6 % crit damage, Loaded Start. History: a clerk's master's knucklebones | Fits today, one line Needs rule |
| Nine-Star Array (Cửu Tinh Trận) | Formation | prepared | +20 khí vận in the fight; L4 | Needs key |
| Borrowed Luck Talisman (Tá Vận Phù) | Talisman | prepared | +12 khí vận for 30 s, uses an art slot | Needs key |
| Sparrow-Luck Pill (Tước Vận Đan) | Pill | prepared | +15 khí vận for the next fight | Needs key |

Fortune needed for a full feed (+0.15): 75. Base 25 + dice 15 + array 20 + pill 15 = 75.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Crit chance notable | +2.5 % each | The raw sum the meter counts | Fits today |
| 2 | Khí vận small nodes | +fortune | The fill | Needs key |
| 3 | Crit damage notable | +10 % | Payout size | Fits today |
| 4 | Linh lực regeneration | +1 % | Fuel | Fits today |
| 5 | Art damage | +10 % | L2 | Needs key |

### Hidden cluster idea: Gambler's Row (Phố Cược)

Theme: Mệnh Đạo and Heart State. Element affinity: Thunder, Metal. Sealed, 9 acupoints. Seal condition: win three fights against a higher realm. Small points: khí vận, crit chance, crit damage; notable: Stacked Meter. No capability.

## Đạo

Mệnh Đạo (Thiên Cơ), existing. Wanted: Định Mệnh (Called Blow, Open Book, Tally Keeper, Jackpot), Khí Vận (House Edge, Spilled Luck), capstone The Loaded Table. These are staged as nodes to add; the Way's `theme_stats` are untouched.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A steady third-hit crit; four cheap arts | Called Blow, Cast the Bones | The clerk's first ledger |
| Kết Đan | Counted evade, Jackpot every ninth hit | The Loaded Table, the dice, the array | Cannot run: the debt is never fled |
| Nguyên Anh | Choosing the payout moment | Spilled Luck, House Takes All | The Tử Vận sect finds them |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical same realm | wins | 17 s at Core, 12 s at Nascent in the simulator |
| One realm up | loses | 7.4 s (Core) and 5.2 s (Nascent) |
| Top-end | loses | the fight ends in about 1 s, before the meters pay |
| Ill Star curser (Mệnh Đạo) | loses | the curse cuts fortune, so the feed falls |
| Tick or soul specialist | loses | evade and crit never touch them |
| Block-heavy body cultivator (thể tu) | even | flat block eats small hits, so the cheap arts lose value |

**Counter:** a Mệnh Đạo Ill Star curse (cuts khí vận), a soul striker, or a tick build; or a top-end enemy that ends the fight before the meters pay. Adapt by cleansing the curse, a soul ward, or higher base crit chance so the build does not live on the fortune feed.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts inside the art lint (house-takes-all was over at 3.6, fixed to 3.4), slots 5 at Core, 6 at Nascent. The technique budget could not be checked: its keys are not in `bonus_pool` |
| Validity | PASS | Elements thunder and metal exist (Lôi is a Fire and Metal convergence); tier Địa giai reaches nguyen_anh; Mệnh Đạo is catalogue Way 12 |
| Stack | PASS | Forms: Increased, More, Per, Trigger, Overflow, Borrow, Timing, Rule swap; identity piece present; L5 empty by choice |
| Identity test | NOT ASSESSED | The Loaded Table is unmodelled. A stand-in run (`--without winnings`, the refund that stands for the payout loop) changed the Nascent fight at same realm from 18 wins to 14, and Core from dry at never to dry at 14.8 s |
| Scaling | PASS (INFO) | fight.py printed no `m_static` line; judged on the fight: wins in 16.8 s at Core, above the 30 to 60 s typical band, so the build is above typical; not pulled back |
| The fight | NOT ASSESSED | The engine (counted meters, Jackpot, fortune feed) is unmodelled; the simulator ran a mean-crit stand-in. Same-realm wins 20/0 at Core, 18/2 at Nascent; no `NEVER_FIRED` at the same realm |
| Reuse | PASS | 5 pieces reused; signature pieces: only The Loaded Table and Jackpot |
| NPC use | PASS | The generator can roll a Mệnh Đạo NPC with these nodes; a Breakdown line is "Crit meter 0.30, fortune feed +0.13" |
| Counterplay | PASS | Ill Star curse, soul striker, tick build, top-end burst |
| Originality | PASS | Names are new; the dice and the ledger are generic images |

## Fight Results

Input: `design/builds/loaded-dice.fight.json` (Core Formation) and `loaded-dice.nguyen-anh.fight.json`. Observations from `fight.py`, 20 fixed seeds.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Core | 0 | 20 / 0 / 0 | 16.8 s | never | none | none |
| typical, Core | +1 | 0 / 20 / 0 | 7.4 s | 6.2 s | none | none |
| typical, Core | +2 | 0 / 20 / 0 | 3.3 s | 2.8 s | winnings, raise-the-stakes | none |
| top_end, Core | 0 | 0 / 20 / 0 | 1.6 s | 1.1 s | counting-blade, winnings, raise-the-stakes | none |
| typical, Nascent | 0 | 18 / 2 / 0 | 12.2 s | 9.5 s | none | none |
| typical, Nascent | +1 | 0 / 20 / 0 | 5.2 s | 4.4 s | raise-the-stakes | none |
| top_end, Nascent | 0 | 0 / 20 / 0 | 1.1 s | 1.1 s | five arts | none |

No `lint_over` in either file after the fix. **Note:** at Nascent the pool runs dry at 9.5 s in the typical fight; the fights are short enough to win, but the sustain there is thin.

**Identity test** (`--without winnings`, stand-in): Core same realm `changed` (own dry never to 14.8 s); Nascent same realm `changed` (18 to 14 wins); other matchups NO_CHANGE. The real identity piece is not testable.

**Unmodelled:** Loaded Table (counted meters, pre-fill, fortune feed), Jackpot, counted evade (approximated as 10 % and 15 % evade), Stacked Meter (folded into L2 on the arts), Flowing Water (folded into art speed), the Winnings refund on a crit (gain on hit 0.4 %), Spilled Luck (folded into crit multiplier), escape closure. `model_note`: the simulator does not model soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape.

## New Concepts

**Counted payout event (Chi Trả).** Rule needed: Effects System rule 12. A meter reaching 1 emits an event that Per modifiers and Effects read. Bounds: the Per cap, the crit multiplier cap 3.0. Breakdown line: "Crit meter: 3 of 3, Jackpot". Serves: any Called Blow build; a counted-evade build. Question for the user: should payouts count toward `trig_budget`?
**Fortune in the fight (Khí Vận Chiến).** Rule needed: Combat Formulas I. Preparation can raise khí vận for one fight. Serves: any fortune or escape build; a Mệnh Đạo caster. Question: should the in-fight value be capped by realm?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| The Loaded Table | Needs rule | Effects System rule 12: fortune feeds a counted chance; counted evade |
| Jackpot, Cash Out, Spilled Luck, Loaded Start | Needs rule | Effects System rule 12: payout counter, meter spend, cap overflow, meter start |
| Stacked Meter | Needs key | A payout count |
| Nine-Star Array, Borrowed Luck Talisman, Sparrow-Luck Pill | Needs key | A fight-long khí vận bonus from preparation |
