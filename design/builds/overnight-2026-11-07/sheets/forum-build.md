# The Forum Build (Vũ Tệ Quyết)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 4: the exploit a player would post, crossing Already-Waited, Level Ground and Fortieth Breath with at most one new piece. Break the lint on purpose and report what the game should do about it.
> **Direction**: The order named Old Bund, Withheld Hand and heart demon as the break. The runs say the break is the wait being deleted, and that those flat bonuses are not the problem. So this sheet's product is **The Finding**, below.
> **Realm span**: Core Formation – Deity Transformation, defined at Nascent Soul · **Power level**: top-end at home, on purpose · **Use**: a player exploit, and a test case for a rule
> **Fit**: 3 Fits today · 8 Needs key · 13 Needs rule. One new piece: Title Deed.
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: every art passes the lint as written, which is the point, and thần thức is not totalled)

## The Finding

**The art lint is a check on a record, and it reads `within` for all six arts of a volley that fires 3.6 times what the lint would sell for what was paid.** `variants/forum-build-mixed.fight.json --enemy typical --gap 1`, with `rules/lint_watch.py` reading the sum at each firing: 43.1 coefficient fired at t = 1, 11.9 sold for that linh lực and one second of waiting, 90 seconds of wait skipped, 0 seasons paid. A Nascent Soul kills a Deity on the first pulse, on 94 % health.

**The break is time, not flat bonuses.** Formulas C charges `0.25 × (cooldown − 1)` of coefficient to the wait. Two ledger pieces delete the wait and keep the coefficient.

| Removed from `variants/forum-build-mixed.fight.json` | Deity, typical | Same-realm top-end |
|---|---|---|
| Nothing | Win, 1 s on 94 % | Win, 1 s on 97 % |
| Both flat bonuses (`--without old_bund --without deep_bund`) | Win, 3 s on 89 % | Win, 3 s on 94 % |
| Standing Water only | Win, 3 s on 78 %, 71 seasons | Win, 3 s on 91 %, 71 seasons |
| Heart demon only (`--without waited`) | Win, 1 s on 94 % | Win, 1 s on 97 % |
| **Both timer pieces** (`--without standing_water --without waited`) | **Loss, 6 s, enemy on 100 %** | **Loss, 10 s, enemy on 96 %** |

The two timer pieces share one job, and either alone carries the build. That is why a fix to one piece closes nothing.

**Four repairs, tried on this build and on the three builds it was crossed from.** Each is a mode of `rules/lint_watch.py`, for the side that asks. Forum Build files are `variants/forum-build-fix-[name].fight.json`, against the mixed enemy. The parents are `variants/forum-build-on-[build]-[name].fight.json`, where `none` is the control.

| Repair | Forum Build, Deity typical | Forum Build, same-realm top-end | Already-Waited, same realm; enemy left one up | Level Ground, top-end | Fortieth Breath, one up |
|---|---|---|---|---|---|
| None | Win, 1 s on 94 %, 0 seasons | Win, 1 s on 97 %, 0 seasons | 2 s on 74 %; 53 % | Win, 4 s on 87 % | Win, 40 s on 40 % |
| `flat`: a Flat base counts inside the lint | Win, 3 s on 89 %, 30 seasons | Win, 3 s on 94 % | Unchanged | **Loss, 20 s, enemy on 41 %** | **Stalemate, enemy on 42 %** |
| `gated`: the cooldown term needs linh lực, scaled by cost ÷ 0.15 | Win, 3 s on 89 %, 30 seasons | Win, 2 s on 95 % | 2 s on 74 %; 69 % | Unchanged | Unchanged |
| `stored`: Standing Water is a pool, 1 s per 10 years stood | Win, 3 s on 89 %, **63 seasons** | Win, 2 s on 95 %, **55 seasons** | Unchanged | Unchanged | Unchanged |
| `served`: the cooldown term is earned by real waiting | **Loss, 8 s, enemy on 17 %** | Win, 4 s on 92 % | 3 s on 66 %; 73 % | Unchanged | Unchanged |

**What the game should do.** This is a recommendation for the user. Nothing here is a reason to shave any build.

1. **Do not make a Flat base count against the lint.** It is the obvious answer to Level Ground's Question 2, and it is the worst one. It kills Level Ground and Fortieth Breath and still lets this build beat a Deity.
2. **Adopt one sentence: a wait is paid, never deleted.** Every second skipped comes from a named, bounded pool, and the result reports the seconds skipped. Heart demon already works this way. Standing Water is the one piece with no per-fight price, so it becomes the pool in `stored`, one second per 10 years stood. Level Ground skips 10 s and keeps all of it. This build's t = 1 kill goes, and the same fight now costs 63 seasons instead of none. No parent changes.
3. **Decide whether one realm up should stay on the table.** `stored` prices that win and does not end it. Only `served` ends it, and it costs Already-Waited a second and takes the enemy from 53 % to 73 % one up. Combat keeps one-up wins for top-end, so this is the user's call, not a bug fix.
4. **Move the lint to where it can see.** `fight_calc.py` prints `art_lint ... within` from the record. It could print `lint_watch`'s two numbers from the firing, and range-check as it goes: Level Ground's 0.03 is under Formulas E's 0.04 floor and Last Word's 40 s is over A2's 30 s, and neither is flagged today.
5. **Treat any tag grant as a lint event.** Title Deed needs only one line, and any long art with a `formation` tag does the same job: `variants/forum-build-lint-maxed.fight.json` is six lint-legal 30 s arts at cost 0.04, firing 61.4 against 8.9 sold. Only the art catalogue stands between the game and that file.

**Other routes through the same lint, by ledger text, not run here.** Time: Rush Order, Final Clause. Cost: Priced Above the Sea, Bitter Tithe, Thrift, One Rope, Head of Water. Coefficient after the check: Old Bund, Deep Bund, Withheld Hand, Returned Force, Long Way Round.

**Old Bund reads the formation's age, not the owner's.** A 200-year field can be bought by someone who has not lived 200 years. That is outside the fight and unmodelled, and it is what makes the build reachable at Core.

## The Spine

- **The channel:** art hits on L1, L3 and L4, under your own law. Linh lực pays the costs, and the common drain ward stays on.
- **The enabler:** Title Deed. Opens every laid-formation piece to arts that were never laid. Closes nothing in the fight, which is the problem: its price is the purchase.
- **The loop:** one volley at the first pulse. If anything stands, heart demon pays the short timers again at t = 2.
- **The engine:** the lint sells long cheap arts because they are slow. Standing Water removes the slowness and the discount stays.
- **The sacrifice:** the ground. Away from it this is a thinner Already-Waited. A per-hit fortress wastes the big hits, and a same-realm top-end met blind kills it at t = 1.
- **The arc:** none. It is a recipe, and it is smug.

## The Legend

The capital's examination quarter sells reading rights by the page. In the third recension an heir to a lamp-oil fortune bought three pages from three shelves, laid them on a lacquer table and noticed that none of them said "but". The deed to a bankrupt sect's terraced array cost less than the table. They walked in as a Nascent Soul of no distinction, and that autumn they killed the Examiner of Arrays in the time it takes to sit down.

They now post the method on teahouse walls under a name that means fraud in the examinations, with a list of the dead and each one's time, to the second. The Examiners have ruled on it four times, and each ruling was answered within the week by a footnote. Its followers open every duel by stating how long it will take. They are insufferable, they are usually right, and the whole quarter is hoping to live to see one of them meet someone who says nothing and does not appear to be there.

## The Post

> **[GUIDE] Nascent one-shots Deity at first pulse. 0 seasons. Every art passes the lint. Patch incoming, get in now**
>
> 1. Do NOT lay your own field. Old Bund reads how long the formation has stood, not you. Buy the deed to a 200-year one. +1.0 on every art, day one.
> 2. Seal order: run the Ferry-Rope Sutra, the Forty-Breath Sentence and Thủ Điền Kinh in the main slot for 48 cultivating seasons each. Seal counts never reset and slots swap free. Take #6 and fight on Sutra + Sentence.
> 3. Title Deed. Now every art of 6 s or more counts as laid, so Standing Water fires your 40 s art at the first pulse. Yes, really.
> 4. Level Ground as the law, or a top-end kills you in the same instant.
> 5. Heart demon is backup. It pays 0 in a normal fight. Keep it for whatever survives.
>
> **Reply #2:** drop Withheld Hand, it does nothing in a 1 s fight and it lost me a ×8 boss
> **Reply #3:** works on an ambush too if the array is already standing
> **Reply #9:** got killed by a per-hit ward, what do I do
> **Reply #10:** do not let the illusionist send the invitation

## How It Fights

The enemy steps onto the terraces and their gear goes flat. On the first pulse six arts that have waited one second fire together, and the forty-second cut lands with them. Wait Here goes first and pushes back whatever they had coming. Last Ferry stays guarded and fires in the follow-up instant if they are under 40 %.

**The signature moment:** `art_lint last_word ... within`, and four lines later a Deity is dead at t = 1.000.

## Enabler

**Title Deed (Địa Khế)**, the one new piece. A Borrow, on any formation you hold title to.

- **Opens:** while the formation stands, your arts with an authored cooldown of 6 s or more count as carrying the `formation` source tag. Old Bund, Deep Bund and Standing Water then read them.
- **Closes:** in the fight, nothing. A deeded art in a blind fight simply loses the tag and fires as authored, so this also repairs Level Ground's worst weakness. A real enabler must close something, and this one failing that test is part of the finding.
- **Found:** a sale, and a price set by the market. `rules/title_deed.py`.

## The Stack

Everything except the deed is reused, and none of it was meant to meet. The standing rule is met three times over: Standing Water was written for 3 s ditches and here takes a 40 s art to t = 1 (`--without standing_water`, above), Old Bund lands on arts that were never laid, and Level Ground's law protects a build whose damage it never caps.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Old Bund (Cựu Bờ) | +1.0 at 200 years | Flat base | art | none | ○ | Array Đạo | From Level Ground |
| Rate | Standing Water (Tích Thủy) | Arts first fire at the first pulse | Timing | art | none | ○ | Array Đạo | From Level Ground |
| Rate | Already Waited (Dĩ Đãi) | Heart demon pays a timer, 1 per second | Rule swap | art | none | ○ | Cold Landing | From Already-Waited |
| Rate | Both Hands (Song Thủ) | Two payments a pulse above 50 | Cap shift | art | none | ○ | Cold Landing | From Already-Waited |
| Multiplier | Damage (`attack_pct`) | +150 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Artifact attack | +40, the most the law counts | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Formation power (`formation_power_pct`) | L4 200 with the array | Increased | art | L4 | ● | Tree | Catalogue row |
| Reach | Level Ground (Bình Địa) | L2, L3, L5 count at most 40, 40, 10, for both sides | Cap shift | any | none | ○ | Formation | From Level Ground |
| Reach | Taken Ground (Chiếm Địa) | The other side's L4 counts at most 20 | Rule swap | any | L4 | ○ | Formation | From Level Ground |
| Reach | Wait Here (art) | Pushes their next art back 3 s | Timing | art | none | ○ | Sutra | From Already-Waited |
| Past the cap | Deep Bund (Thâm Bờ) | L4 past the cap: +0.01 a point, +0.50 here | Overflow | art | none | ○ | Cluster | From Level Ground |
| Survival | Field Walls (Điền Thành) | +120 ward strength and efficiency | Redirect | any | none | ○ | Cluster | From Level Ground |
| Fuel | Every Blow (Mỗi Đòn) | Heart demon rises when hurt | Trigger | incoming | none | ○ | Cold Landing | From Already-Waited |
| Base | Withheld Hand (Thu Thủ) | No fist; +1.0 a second to your longest art | Rule swap | art, basic | none | ○ | Standing Post | From Fortieth Breath |
| Identity | **Title Deed (Địa Khế)** | Above | Borrow | art | none | ○ | Sold with a formation | any sect elder with a home array |

**Identity piece:** Title Deed. `--without title_deed` on the mixed file loses to the Deity at 6 s, enemy on 44 %, and wins the same-realm top-end at 5 s on 88 %.
**Withheld Hand does not earn its place, and it stays because the order asked for it.** An art comes before the fist in hit order, so at t = 1 it holds 0. See The Held Cut.
**Empty rungs:** Crit is unused, and the law would cap L2 and L5 anyway. L2 and L5 are not a sacrifice here: they are free points left on the table.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 150 | ×2.50 | Tree |
| L2 | 0 | ×1.00 | Empty |
| L3 | 40 | ×1.40 | Gear, at the law's cap |
| L4 | 200 | ×2.50, 50 clipped | Array and formation power; Deep Bund spends the clip |
| L5 | 0 | ×1.00 | Empty |

## Foundation

Stats are Level Ground's own Nascent profile (`variants/level-ground-nascent.fight.json`), with the bund at 200 years and Already-Waited's 85 heart demon, so nothing here is a fresh guess except the deed.

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water with Metal | The two main methods name them |
| Key talents | Dao heart | 85 heart demon is a danger at any gate |
| The Way (Đạo) | Array, Field branch | Old Bund, Standing Water, Ground Law |

## Công Pháp and Arts

Nothing new. **Legal, with one trick:** only two main slots exist (capability #6), and the build touches three methods. Seal counts never reset and slots change free at any season start (Cultivation Techniques rules 6 and 15), so 144 cultivating seasons open all three clusters, and the fight runs on the Sutra and the Sentence alone.

| Art | From | c_art, authored | Cost | Cooldown | c_art fired | Lint for one second's wait |
|---|---|---|---|---|---|---|
| Wait Here | Ferry-Rope Sutra | 2.7 | 0.04 | 6 s | 4.20 | 1.48 |
| Rope Burn | Sutra | 3.7 | 0.04 | 10 s | 5.20 | 1.48 |
| Third Winter | Sutra | 3.3 | 0.05 | 8 s | 4.80 | 1.60 |
| Lantern Left | Sutra | 4.4 | 0.06 | 12 s | 5.90 | 1.72 |
| The Last Ferry | Sutra | 6.3 | 0.05 | 20 s | 7.80 | 1.60 |
| Last Word | Forty-Breath Sentence | 13.75 | 0.25 | 40 s | 15.25 | 4.00 |

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | As above, without The Last Ferry | Common drain | `variants/forum-build-core.fight.json`, 60 heart demon. Stats are a first guess |
| Nascent Soul | 6 | As above | Common drain | The post |
| Nascent Soul, boss | 6 | Last Word out, The Last Ferry guarded at 90 % | Common drain | At 0.25 Last Word dries the pool for a long fight |

## Matchups

| Enemy | Result | File, in `variants/` |
|---|---|---|
| Mixed, same realm | Win, 1 s on 98 %, pool 50 % | `forum-build-mixed` |
| Mixed, one up | Win, 1 s on 94 %, pool 33 % | same |
| Mixed top-end, same realm | Win, 1 s on 97 % | same |
| Mixed top-end, one up | Loss, 5 s, enemy on 87 % | same |
| No law, top-end | Dead at 1 s, enemy on 29 % | same, `--without ground_law` |
| Ambush, standing array | Win, 1 s on 98 %; top-end 1 s on 97 % | `forum-build-ambush` |
| Blind, typical | Win, 3 s on 92 %, 71 seasons. Level Ground alone takes 22 s to reach 21 % | `forum-build-blind` |
| Blind, top-end | Dead at 1 s, enemy on 97 % | same |
| ×4 boss | Win, 3 s on 96 %. Top-end ×4: loss, 9 s, boss on 81 % | `forum-build-boss-x4` |
| ×8 boss, Last Ferry at 40 % | Loss, 28 s, boss on 19 %, and no fist left to finish it | `forum-build-boss-x8` |
| ×8 boss, same, no Hand | Win, 9 s on 90 % | same, `--without withheld_hand` |
| ×8 boss, Last Ferry at 90 % | Win, 8 s on 91 %, 87 seasons. One up: loss, boss on 85 % | `forum-build-boss-x8-early` |
| Soul assassin, thần thức ×2.5 | Win, 1 s on 68 % | `forum-build-soul` |
| **Per-hit fortress, ward strength 400** | **Loss, 12 s, enemy on 3 %.** Top-end: loss, 8 s, enemy on 52 % | `forum-build-fortress` |
| **The Understudy, Nascent Soul, who opens** | **Loses at 32 s, Understudy on 43 %** | `understudy-vs-forum-build` |
| The Understudy, Forum Build opens | Win, 2 s on 86 %, pool 1 % | `forum-build-vs-understudy` |

The soul assassin's sense is `enemy_divine_sense` 2.5, copied from `variants/level-ground-soul.fight.json`, a stated multiple and not derived. No enemy here has an element, because the anchors carry none.

**Counter:** a per-hit ward, which charges one fee for a hit of any size, so the volley's size is wasted. Or anything that lands before the first pulse. Or a double. Rule 10 resolves the opener's hits first, so the Understudy's mask is either up for the volley or it is not, and that one ordering turns a 2 s loss into a 32 s win. With the pool gone, Withheld Hand leaves no fist either.

## The Held Cut

The literal recipe in the order is one art, held by Withheld Hand, with heart demon paying the timer at the pulse a guard names. It exists and it works: `variants/forum-build-held-cut.fight.json`, on Fortieth Breath's per-hit ward with Still Water, Last Word alone, guarded on the enemy's linh lực below 5 %. The demon pays 24 seasons at t = 16, and the cut fires at 30.25 with 15 held, against 7.75 sold. It beats a mixed Deity at 16 s on 11 %, and the same-realm top-end at 16 s on 49 %. `--without waited` loses at 20 s with the enemy on 100 %.

It is still worse than the fist. `--without withheld_hand` wins that Deity at 12 s on 32 %, because the fist keeps draining them. The one fight where the Hand leads is a Deity top-end fixture, a loss either way, enemy on 7 % against 37 % (`variants/forum-build-held-cut-fixture.fight.json`). Its price, the basic attack, is the thing that finishes fights when the pool is gone.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | All six arts `within` as authored. Slots 6 of 6. Thần thức not totalled. Last Word's 40 s is carried from Fortieth Breath, over A2's range |
| Validity | PASS | Two main slots through #6; the third method is needed only to open its seal. Tiers, realm and ids as in the parent sheets |
| Stack | PASS | Nine forms. Identity removed changes the result. Pairs that share a job removed together: both timers, both bunds |
| Scaling | PASS | `m_static` 8.75 against typical 7.37 and top-end 256. INFO: it passes top-end only by lowering top-end |
| The fight | PASS | Six plug-ins, none a stand-in. Constants and selftest clean. `lit_wick`, `stands_over` and `turned_away` are not loaded |
| Reuse | PASS | One new piece, as ordered. Three sheets' arts, laws and timers |
| NPC use | PASS | The generator needs one id. Any sect elder on a home array could carry this, which is the macro risk if the rule stays as it is |
| Counterplay | PASS | Per-hit fortress, a double, top-end one up, a blind top-end |
| Originality | PASS | The examination fraud is a common historical idea; no name comes from an existing work |

## Fight Results

Input: `sheets/forum-build.fight.json`. Rules `lint_watch`, `laid_ground`, `title_deed`, `already_waited`, `demon_scale`, `withheld_hand`. Observations from `_tools/fight_x.py`, a paper model.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 98 % | 1 s | never | `layer_4_over_cap` |
| typical | 1 | Win, 93 % | 1 s | never | same |
| typical | 2 | Win, 90 % | 2 s | never | same |
| top_end | 0 | Win, 96 % | 1 s | never | same |
| top_end | 1 | Loss, enemy 88 % | 5 s | 2 s | same |
| top_end | 2 | Loss, enemy 90 % | 5 s | 2 s | same |

Nascent Soul's gap 2 meets the last realm, so it adds suppression only. `enemy_art_delayed` in the output is Wait Here. **Second realms:** Deity Transformation wins at 1 s on 99 %, and against its own top-end at 2 s on 96 % (`variants/forum-build-deity.fight.json`). Core Formation beats one up at 2 s on 84 % and its own top-end at 1 s on 94 % (`variants/forum-build-core.fight.json`).

**Unmodelled:** the deed's price, upkeep and Untended Field; seasons owed, which `demon spent` stands for; heart demon carried to the next gate.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Title Deed | Needs rule | Combat rule 6: a tag gained from a held formation, not from the record |
| Everything reused | As in the parent sheets | No new ask |
| A wait is paid, never deleted | Needs rule, if taken | Combat rule 13 and Formulas A2. Standing Water's text. `seconds_skipped` in rule 14's result |

## Questions

1. Should a one-realm-up win stay possible at 63 seasons a fight, or should `served` end it?
2. Should Old Bund read the holder's years, not the formation's?
3. Should a Withheld Hand user be allowed to go dry with no way to act at all? It is the only build that can.
4. Can one side of a fight lose by not being the opener? Rule 10 decides this for the Understudy, and it may deserve a rule of its own.

## Also Considered

- **The Lint-Maxed Field:** six new 30 s arts at cost 0.04. Stronger, but that is six new pieces, so it stays a variant and a warning.
- **The Headsman's Field:** Fortieth Breath stands on Level Ground and waits out the full 40 s. It is The Held Cut with less demon, and worse.
