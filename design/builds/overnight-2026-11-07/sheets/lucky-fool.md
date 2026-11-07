# The Lucky Fool (Si Phúc Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The lucky fool: fortune (khí vận) and chance as the engine, kept readable under rule 15, mischief as the mood. Check Combat Formulas I. Set it somewhere that is not a river, a paddy or a ferry."
> **Direction**: The literal reading stacks crit and evade, and Formulas I gives a lead of 100 only +0.10 on those. The stronger reading: the fool never attacks. Fortune decides how often the enemy's own art lands on the enemy, and a visible count puts a floor under it, so chance sets how soon and not whether.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: strong against anyone with arts and a fine sword, helpless against fists, ticks and soul · **Use**: player build, or a recurring NPC nobody can explain
> **Fit**: 3 Fits today · 7 Needs key · 6 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** the enemy's own art hit, at their M and through their own ward, redirected by a chance roll. The fool's five layers are empty, `m_static` 1.00.
- **The enabler:** Slip of the Hand (Thất Thủ), the keystone of a new Way. It opens a roll on every art that hits, for both sides, shifted by fortune. It closes every hitting art of your own, which roll too, and the ward, which the armour it comes with will not hold.
- **The loop:** stand there. They swing. The count climbs, and sooner or later a swing goes wrong. When they cannot afford the next swing, you pay for it.
- **The engine:** three pieces nobody meant to join. Slow Wound sets the fool's life at about 20 pulses against any hit of any size. Patronage keeps the enemy swinging for all 20. The Pot makes sure a known number of swings go wrong.
- **The sacrifice:** all damage, all wards, comprehension itself. No answer to an enemy who does not swing an art.
- **The arc:** an embarrassment, then a mascot, then a rumour, and at no point a plan.

## The Legend

The fortress city of Iron Pass (Thiết Quan) has been besieged eleven times, and each time the defenders have carried one person at the head of the column: the General's nephew, who cannot read a map, has failed the garrison drill nineteen times and once saluted a horse. They were given a suit of parade armour three sizes too large, to keep them out of the way. In the first siege an enemy champion's sword came out of its scabbard and through his own knee. In the fourth a formation master sneezed. Combat rates a force's fortune by its leader's, so the staff, who are not fools, have quietly put the nephew's name at the top of every order of battle for thirty years. The common soldiers bet on it. There is a saying older than the fort: *ngu si hưởng thái bình*, the dull enjoy the peace.

Nobody has ever proved the nephew knows. Elders who take offence at them are found a few days later at the bottom of a stair, very old, and owing. The nephew sends flowers, to the wrong address. Two schools of thought divide the officers' mess: the ones who say the nephew is an idiot have all been promoted, and the ones who say otherwise keep having accidents.

## How It Fights

The fool does nothing and apologises for it. The enemy's arts land, and the blows go into a ledger the fool will not feel for a while. Every art that does not go wrong adds to a count anyone can read. When the count fills, the next art turns in the hand and lands on its owner: their M, their crit, through their own ward, at most 30 % of their health. Four of those and they are down. If they run short of linh lực, the fool politely covers the cost. If it is going badly, the fool takes a wrong turn and is simply not there any more.

**The signature moment:** a Core Formation top-end, M about 210, who kills this fool in 1 s if the ledger is taken away, opens with everything. Eighteen seconds later they have hit themselves four times and lie on the floor with the fool's bill for 2,945 years in their hands (`variants/lucky-fool-mixed.fight.json --enemy top_end`). Over 300 seeds the fool wins all 300. The median is 13 s.

## Enabler

**Slip of the Hand (Thất Thủ).** Keystone of the Way of Chance.

- **Opens:** every art that would hit, on either side, first rolls `0.05 + (other's fortune − caster's fortune) × 0.001`. On a slip it resolves on its caster: same size, same M, their own ward and guard, no suppression, at most 30 % of their maximum health. Basic attacks, ticks and arts with no hit do not roll.
- **Closes:** your own hitting arts roll too, and an unlucky carrier eats them. So the keystone is taken by people with no hitting arts, or by no one.
- **Found:** the Way needs fortune 70 or a Void root. It is the only Way in the game whose requirement a fool can meet by accident.

**How it fits Formulas I:** this is rule 9's trigger on an art fired, with an explicit `chance` as rule 15 asks, and fortune shifts it as it shifts every roll. Only the effect, a redirect, is new. Lead 80 makes the 0.05 a 0.13, and that is the whole of the ratio: at low base chances the flat shift dominates, so fortune matters more here than on any roll with a large base.

## The Stack

Sizes on new modifiers are first guesses. The forced push replaced a crit-and-evade stack, then tested the obvious prank, Heckling, which speeds the enemy up: it added nothing (291 wins against 293), so it was cut. **The numbers changed the design once:** without a limit, one slip killed any top-end at any realm in 6 s, so a slip now stops at 30 % of its caster's health, which is also what makes "four slips" something a player can count.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Slip of the Hand (Thất Thủ)** | The roll above | Trigger | enemy art | none | ○ | Đạo keystone | any jinx, any cursed ground, any NPC with bad luck about them |
| Rate | Patronage (Bảo Trợ) | When the enemy cannot afford a ready art, you pay its cost, while your pool is above that cost | Trade | art | none | ○ | Đạo | **Reused from The Brush Fee, see below** |
| Certainty | **When the Worst Has Passed (Bĩ Cực)** | Each roll against you that fails adds its chance to a visible count. At 1.0 the next one lands and the count returns to 0 | Rule swap | any | none | ○ | Đạo | any chance build: crit, status or escape |
| Reach | Ill Omen (Hung Triệu) | A curse: the enemy's fortune −15 for 3 pulses, stacking to −45 | Trigger | any | none | ○ | Đạo | any curse build that wants rolls moved |
| Past the cap | Years Owed (Thọ Trái) | At the fight's end each 100 % of maximum health left in the ledger costs 1 % of the realm's base lifespan | Overflow | any | none | ○ | Artifact | **Reused from The Incense Vigil** |
| Past the cap | Someone Else's Problem (Giá Họa) | On a knockout win, the loser pays your Years Owed | Redirect | none | none | ○ | Đạo | any Slow Wound user, any debt |
| Fuel | Dull Fortune (Ngu Phúc) | +1 `khi_van` per point of comprehension under 50, to +40 | Per | any | none | ○ | Technique | any thể tu who skipped the reading |
| Fuel | Fortune (`khi_van`) | Base 90, and Dull Fortune: 130 | Flat | any | none | ● | Birth, Tree | every chance build |
| Survival | Slow Wound (Hoãn Thương) | Hit damage past ward and guard enters a ledger, paid at most `dot_pool_cap` of maximum health a pulse | Rule swap | incoming | none | ○ | Artifact | **Reused from The Incense Vigil** |

**Identity piece:** Slip of the Hand, with the Pot as its floor. Without it, a top-end stands on 95 % when the fool leaves at 19 s.

**Another sheet's modifier, used unplanned:** Patronage. The Brush Fee pays the enemy's art so that it has something to copy. Here it pays for the swing that will hit them, and the fool is mostly paying for a bad day. Remove it and wins fall from 293 to 33 of 300. Slow Wound is a second: The Incense Vigil built it to reach a stalemate, and here it buys time for the other side to have an accident. Without it, dead at 2 s.

**Empty rungs:** Multiplier is a sacrifice, all five layers. Crit is replaced by the Pot. No ward: `model` off, so the pool serves Patronage alone.

| Layer | Points at Core | Multiplier | Sources |
|---|---|---|---|
| L1 to L5 | 0 | ×1.00 | The fool has no damage. The slip uses the enemy's layers, all of them |

## Reading It (Rule 15)

Rule 15 wants chance to be a flavour, not the base. So the build is two things at once, and the log keeps them apart.

- **The floor:** the Pot alone, with no draw at all. It is deterministic. Against the mixed enemy it wins at 19 s on 10 %. The fight file runs this.
- **The flavour:** true rolls usually bring a slip sooner, and can also spend one on a small art. Over 300 seeds the same fight is 293 wins and 7 flights, median 15 s, 10th to 90th percentile 11 to 18 s. Remove the Pot and it is 167 wins and 133 flights.

**Breakdown lines:** "Pot 0.78 of 1.00 (lead +80, 0.13 a swing)." "Slip! Heavy Strike turned in the hand, clipped at 30 %. Slips 3." A player reads the fight as a bar and a count of four, and fortune as how fast the bar moves.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Void, as much as you have | Its roads carry `khi_van` to the cap |
| Key talents | Fortune as high as birth allows. Comprehension 10, deliberately | Dull Fortune reads what you lack. Each slow decade is paid for here |
| The Way (Đạo) | Way of Chance, to the keystone | Below |

## Công Pháp

### Recruit's Drill Manual (Tân Binh Điển) — main, Huyền giai

Issued to every conscript at Iron Pass. The fool has read the cover.

```json
{"id": "tan_binh_dien", "name": "Tân Binh Điển", "tier": 1, "tech_kind": "main",
 "names": ["kim"], "layers": 9,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 7}],
 "abilities": [], "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 20/20 + 7/15 = 1.47 of 2.0, each within 1.5. Carries Dull Fortune. It stops at Core Formation, so the Nascent Soul run assumes another manual.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| After You (Nhượng Tiên) | Way art | none | 0 | 0 | 1 s | none | Needs key |
| Ill Omen (Hung Triệu) | Way art | qi, curse | 0 | 0.03 | 2 s | none | Needs key |
| Wrong Turn (Mê Lộ) | Way art | escape | 0 | 0.10 | 3 s | own health below 30 % | Needs key |

**Effect:** After You is the slot Patronage runs from. Ill Omen as above. Wrong Turn is an escape art, `e_art` 0.55, which fortune shifts by Formulas I. **Description:** "Oh, I am so sorry." Wrong Turn is the only art here the fool has ever used on purpose, and they say it was not.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | After You, Ill Omen, Wrong Turn | Off | Runs the same |
| Core Formation | 5 | The same | Off | The defined build |
| Nascent Soul | 6 | The same | Off | The clock does not care about realm |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Borrowed Armour (Tá Giáp) | Artifact, body | `giap`, hạ phẩm, named | Carries Slow Wound and Years Owed. It holds no ward: three sizes too large, so blows take a while to find the wearer. Taken off a dead general's dummy | Needs key |

## Đạo

### Way of Chance (Cơ Duyên Đạo)

- **Requirement:** fortune 70, or a Void root at purity 30 (rule 5).
- **`theme_stats`:** `khi_van`, `evade_pct`, `status_resist_pct`.
- **Shape:** 20 nodes, branches of 7, 6 and 6, and a keystone, at about 12.9 W a node, the shape The Kept Hearth's Way passed the lint with. W prices are guesses. With the name hidden, a player reads a tree about things going wrong near you.

**The Slip (Thất Thủ Mạch).** What goes wrong for them. Signature nodes: Ill Omen (art), After You (art), Patronage (passive T2).

**The Pot (Hạn Mạch).** What a run of bad luck is worth. Signature nodes: When the Worst Has Passed (passive T2), a node that lets the Pot also count a failed crit (passive T1).

**The Road Out (Thoát Mạch).** Not being there. Signature nodes: Wrong Turn (art), Someone Else's Problem (passive T2), +`escape_bonus` lines.

**Keystone: Slip of the Hand.** T3 with a 4 W line, 34 W. No cap moves.

**NPC effect:** the Đạo's power multiplier under rule 11. In a rating clash fortune already counts, so its signature costs nothing extra there.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Already itself | The armour, the keystone | You fall off a wall and a siege ends |
| Core Formation | Beats its own top-end, better than even against a typical one realm up | Dull Fortune at full | Your name goes on the orders |
| Nascent Soul | The same, slower to die | Nothing you noticed | Someone tries to assassinate you and it goes badly for them |

## Matchups

Mixed enemy at Core Formation unless stated. Results are the floor, then 300 seeds.

| Enemy | Result | Why |
|---|---|---|
| Typical | Win at 19 s on 10 %; 293 wins, 7 flights | Four slips |
| Typical, one realm up | Loss at 21 s, enemy on 44 %; 180 wins, 120 losses | Slips fit, the clock barely does |
| Typical, two up | Loss, enemy on 58 %; 25 wins, 275 losses | |
| Top-end, same realm | Win at 18 s on 15 %; 300 wins | Every slip is the full 30 % |
| Top-end, one up | Loss, enemy on 39 %; 121 wins, 179 losses | |
| Top-end, two up | Loss, enemy on 40 %; 51 wins, 249 losses | Better odds than a typical two up: the excellent trip harder |
| Bankrupting fixture, typical | Loss at 21 s, enemy on 12 %; 217 wins, 83 losses | Paying 15 % of their pool a second empties yours |
| Bankrupting fixture, top-end | Loss at 22 s, enemy on 34 %; 28 wins, 272 losses | The same, on a bigger pool |
| Per-hit ward enemy | Win at 18 s on 15 %; 300 wins | Slips ignore what ward it is |
| Fists | Flight at 19 s, enemy on 76 %; 300 flights | Nothing to slip. The fool leaves |
| Poisoner | Dead at 11 s, enemy on 63 %; 300 losses | Ticks skip the ledger, and small hits make small slips |
| Soul assassin, thần thức ×2 | Dead at 5 s, enemy on 89 %; 298 losses, 2 flights | Soul skips the ledger |
| Luckier rival, fortune 150 | Flight at 19 s, enemy on 54 %; 35 wins, 265 flights | The lead has turned round |

**Counter:** Combat rule 18's soul-piercer and poisoner, both flat. A body-crusher with no arts cannot be beaten, only left. And anyone luckier, which in practice means a second fool.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 1.47 of 2.0. Slots 3 of 5. No art has a coefficient, so the art lint has nothing to read. Thần thức not totalled |
| Validity | PASS | Huyền giai reaches `ket_dan`, the defined realm. `giap` is a real base, `khi_van` a real key, Void a real root. The enemy's fortune is 50 by assumption: reference enemies carry none, and 50 is the neutral point of Character Stats Formulas H, as `rules/escape.py` also assumes |
| Stack | PASS | Six forms: Trigger, Trade, Rule swap, Overflow, Redirect, Per. All layers stated empty. Identity test changes every fight |
| Scaling | PASS | `m_static` 1.00 against typical 5.48 and top-end 210. Its damage is theirs, so the anchors do not measure it. INFO: beats its own top-end |
| The fight | PASS | 60 of 60 constants. `slips` and the sweep show the loop. Plug-ins: `slow_wound`, `fortune`, `pratfall`, `patronage`, `escape`. No damage cap applies. Every fight is either the expected floor or a stated seed |
| Reuse | PASS | Patronage, Slow Wound, Years Owed reused. Hearth Ash not used. The Pot serves any chance build, Slip any jinx |
| NPC use | PASS | Each piece is one Breakdown line. A fool NPC needs only fortune and the keystone. The generator must not give it hitting arts |
| Counterplay | PASS | Fists, ticks, soul and a luckier enemy, all run |
| Originality | PASS | *Ngu si hưởng thái bình* and *bĩ cực thái lai* are common sayings. The plot of a lucky idiot is a shape, not a name |

## Fight Results

Observations from `fight_x.py`, a paper model. `pratfall` runs the Pot with no draw, which is the floor, then prints the sweep over seeds 1 to 300. Crit stays an expected value. Prefix `variants/lucky-fool-`. Main file: `sheets/lucky-fool.fight.json`, against the bankrupting fixture.

| Enemy | File, flags | Floor | Time | Own health, pool | Enemy health | 300 seeds |
|---|---|---|---|---|---|---|
| typical | main | Loss | 21 s | 0 %, 8 % | 12 % | 217 wins, 83 losses |
| typical, one up | main, `--gap 1` | Flight | 19 s | 10 %, 12 % | 64 % | 296 flights, 4 wins |
| typical, two up | main, `--gap 2` | Loss | 21 s | 0 %, 72 % | 73 % | 300 losses |
| top_end | main, `--enemy top_end` | Loss | 22 s | 0 %, 8 % | 34 % | 28 wins, 272 losses |
| top_end, one up | same, `--gap 1` | Flight | 19 s | 10 %, 26 % | 69 % | 300 flights |
| top_end, two up | same, `--gap 2` | Loss | 22 s | 0 %, 71 % | 70 % | 300 losses |
| Mixed | `mixed` | Win | 19 s | 10 %, 38 % | 0 % | 293 wins, 7 flights |
| Mixed, one up | same, `--gap 1` | Loss | 21 s | 0 %, 5 % | 44 % | 180 wins, 120 losses |
| Mixed, two up | same, `--gap 2` | Loss | 21 s | 0 %, 0 % | 58 % | 25 wins, 275 losses |
| Mixed, top_end | same, `--enemy top_end` | Win | 18 s | 15 %, 5 % | 0 % | 300 wins, median 13 s |
| Mixed, top_end, one up | same, `--gap 1` | Loss | 21 s | 0 %, 7 % | 39 % | 121 wins, 179 losses |
| Mixed, top_end, two up | same, `--gap 2` | Loss | 22 s | 0 %, 11 % | 40 % | 51 wins, 249 losses |
| Foundation Establishment | `foundation-mixed` | Flight | 19 s | 10 %, 45 % | 7 % | 295 wins, 5 flights |
| Nascent Soul | `nascent-mixed` | Win | 19 s | 10 %, 29 % | 0 % | 289 wins, 11 flights |
| Nascent Soul, top_end | same, `--enemy top_end` | Loss | 21 s | 0 %, 6 % | 7 % | 280 wins, 20 losses |
| Fists | `fists` | Flight | 19 s | 10 %, 81 % | 76 % | 300 flights |
| Poisoner | `poisoner` | Loss | 11 s | 0 %, 80 % | 63 % | 300 losses |
| Soul assassin | `soul-assassin` | Loss | 5 s | 0 %, 12 % | 89 % | 298 losses, 2 flights |
| Luckier rival | `luckier-rival` | Flight | 19 s | 10 %, 51 % | 54 % | 35 wins, 265 flights |
| Per-hit ward | `per-hit-ward` | Win | 18 s | 15 %, 33 % | 0 % | 300 wins |

**Removing pieces.** All against `mixed`, floor and then 300 seeds. The soul assassin's thần thức and the rival's fortune are set by hand in their files.

| Removed | File, flags | Floor | 300 seeds |
|---|---|---|---|
| Slip of the Hand | `mixed`, `--without pratfall` | Flight at 19 s, enemy on 75 % | No roll, so no sweep |
| Same, top_end | `mixed`, `--enemy top_end --without pratfall` | Flight at 19 s, enemy on 95 % | |
| The Pot | `mixed-no-pot` | Flight at 19 s, enemy on 75 % | 167 wins, 133 flights |
| The Pot, top_end | same, `--enemy top_end` | Flight at 19 s, enemy on 95 % | 209 wins, 55 flights, 36 losses |
| Patronage | `mixed`, `--without patronage` | Flight at 19 s, enemy on 39 % | 33 wins, 267 flights |
| Patronage, top_end | same, `--enemy top_end` | Flight at 19 s, enemy on 31 % | 28 wins, 272 flights |
| Slow Wound | `mixed`, `--without slow_wound` | Dead at 2 s, enemy on 97 % | 300 losses |
| Slow Wound, top_end | same, `--enemy top_end` | Dead at 1 s, enemy on 100 % | 300 losses |
| All fortune | `mixed`, `--without fortune` | Flight at 19 s, enemy on 51 % | 7 wins, 293 flights |
| Lead at 0, fortune 50 | `mixed-even-luck` | Flight at 19 s, enemy on 30 % | 72 wins, 228 flights |
| Same, one up | same, `--gap 1` | Loss at 21 s, enemy on 82 % | 23 wins, 277 losses |
| Dull Fortune, fortune 90 | `mixed-sharp` | Win at 19 s on 10 % | 244 wins, 56 flights |
| Same, one up | same, `--gap 1` | Loss at 21 s, enemy on 38 % | 104 wins, 196 losses |
| Ill Omen | `mixed`, `--without ill_omen` | Flight at 19 s, enemy on 13 % | 208 wins, 92 flights |
| The Pot and Ill Omen, which share the job | `mixed-no-pot`, `--without ill_omen` | Flight at 19 s, enemy on 75 % | 93 wins, 207 flights |
| Wrong Turn | `mixed`, `--without wrong_turn` | Win at 19 s on 10 % | 300 wins. The escape abandons 7 fights it would have won |
| Wrong Turn, Fists | `fists`, `--without wrong_turn` | Dead at 21 s, enemy on 74 % | 300 losses. With it, 300 flights |
| Heckling added | `mixed-heckling` | Flight at 19 s, enemy on 5 % | 291 wins, 9 flights. Cut |
| The 30 % clip | `mixed-no-clip`, `--enemy top_end` | Win at 6 s on 75 % | 300 wins, median 4 s |
| Same, one up, two up | same, `--gap 1`, `--gap 2` | Win at 6 s on 75 % | 300 wins each |

**Unmodelled:** Someone Else's Problem, which acts after the fight: the billed years in the text are the `years_owed` line, which is what it would pass on. Dull Fortune's price in slow cultivation. Ill Omen filling a curse slot. Fortune in a rating clash.

## New Concepts

**A roll that remembers (The Pot, Hạn).** A chance that fails adds itself to a count, and the count makes the next one certain.

- **Rule:** Combat rule 15 and Formulas I. Rolls stay seeded and in order. The count is a per-fight value, and a certain roll takes no draw, as a chance of 1 does today.
- **Bounds:** one count a side, reset on landing and at the start of each fight.
- **Breakdown line:** "Pot 0.78 of 1.00."
- **Other builds it serves:** any crit or status build that wants to be readable, and the escape art, whose expected roll in `rules/escape.py` already works this way, because that is the only honest way to write an expected roll on paper.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Slip of the Hand | Needs rule | Combat rules 9 and 15: a trigger on an art fired, with a new effect, a redirect to the caster |
| When the Worst Has Passed | Needs rule | Combat rule 15, Formulas I, as above |
| Someone Else's Problem | Needs rule | Combat rule 14 and Character Stats: a fight's lifespan cost may pass to the loser |
| Patronage | Needs rule | As The Brush Fee asks: one side may pay the other's cost |
| Slow Wound, Years Owed | Needs rule | As The Incense Vigil asks |
| Dull Fortune | Needs key | A Per that reads comprehension at compile |
| Way of Chance, Recruit's Drill Manual, Borrowed Armour, three arts | Needs key | Content records |

**Questions for the user:**

1. Rule 15 aims at chance as a flavour. The Pot turns a chance into a meter with a deterministic floor. Does that satisfy it, or is a meter a way round it?
2. Without the clip, a Core Formation fool kills a Deity Transformation top-end in 6 s, every time, because top-end Off is far above top-end ehp: anchors are loaded guns pointed both ways. Should any self-inflicted hit be limited by rule, as the 30 % here is?
3. A force's fortune is its leader's (Formulas K), so a fortune-130 figurehead adds (130 − 50) × 0.001 = 0.08 to every clash, with no realm or skill. Is an army meant to be able to do that? It is how the legend works.
4. Nothing says what a win costs when the bill passes on. Can Years Owed kill the loser after a mercy? This joins the critic's open question on what happens after Down.

## Also Considered

- **The Long Shot:** 1 % effects, because a chance of 0 is never shifted and a chance of 0.01 gets the whole lead. A great rule reading, but evade 1 % and crit 1 % changed nothing here, since the enemy decides this fight. It wants its own build.
- **The Luck Thief:** stealing the enemy's fortune for good, seed 14. Fun, but a lead of 80 is already the ceiling of what a Formulas I shift can do, and the Omen does the fight's share of it.
