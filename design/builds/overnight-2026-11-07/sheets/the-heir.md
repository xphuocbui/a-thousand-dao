# The Heir (Thừa Tự Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 5: cross Best Plan, Given Years and Not-Yet-Full. At death the Creditors' Book, the tally and the masks pass to a named disciple, so the build is a family line that starts each generation owing and feared, proved by a three-generation chain.
> **Direction**: The build is the line, not the person. Each head spends their last years paying one debt, because that payment is fatal, and leaves the rest to someone they raised. The seed's fight unit is not the engine. What needs more than one life is the Book.
> **Realm span**: Foundation – Nascent Soul, over four lives, defined at the first heir's Foundation · **Power level**: ordinary at the first handover, strong by the fourth · **Use**: player build across lives; also a feared NPC house
> **Fit**: 6 Fits today · 6 Needs key · 15 Needs rule (5 new, 10 already asked by the three parents)
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: masks, paper and the estate have no lint. The fight: power between handovers is a saved input, not a simulated life. NPC use: no NPC family rule exists)

## The Spine

- **The channel:** art hits on L1 to L3 for a young heir, and all five layers for a head in their last years. A fled enemy counts as a survived fight, and for a child that is the usual good result.
- **The enabler:** The Named Heir. On your Set Day you may name a disciple, and at your death you continue as them, in the same world, with the Book, the tally and one mask for each head who has died. It closes your own edge, your tree and half of what you ate.
- **The loop:** raise someone, eat what you must, set the Day, pay one debt, hand over the rest.
- **The engine:** Slow Wound under Paid in Seasons. A blow of any size pays 5 % of health a pulse, so a quarter of a season, and the wick burns a season a pulse. That gives an old head one long fight against anything alive, with Short Wick climbing as it burns. It is also fatal: the ledger left on a win falls due in years, thousands of them. **One head, one debt.**
- **The sacrifice:** you. Your realm, your tree and your edge stop at your death. Your heir starts small, hunted, and short of linh lực for every name you did not reach.
- **The arc:** three entries, three deaths, and a child at the end who owes nothing.

## The Legend

Tảo was a lime-burner's child who took one pill from a Deity's courtyard when their sister was sick, and the blow meant for them went into a book. Everything after that was the book. By the time their hair turned there were three names in it, and a disciple called Liêm who had been dug out of a landslide at six and had never been told. Tảo told them on the last evening, by the kiln, and showed them the page. Then Tảo walked to the first name's door with three years left, and Liêm kept the kiln going because nobody had said to stop.

Liêm paid the second name. Sương, whom Liêm named, climbed to the third, and was not brave about it. The faces stayed in a cedar box and came out for the young, who were frightened in them and were feared anyway. The last time the box was opened it was for a sixteen-year-old called Nhi, who owed no one and could not understand why grown people crossed the road. Sương's letter was four lines long. The last line said: you do not have to do anything with this.

## How It Fights

A young heir walks in wearing a dead person's face. The first blow lands on the face and does nothing, and the elder who threw it has heard what that means. Their exit opens. Two seconds is a long time for a child with a thin ward, and most of the build is what buys those two seconds: the mask, the plain nodes, and whichever names the last head reached.

An old head fights the other way. They burn paper at half a second, and from then on nothing can hurt them faster than they are already dying.

**The signature moment:** a Nascent Soul with six years left walks up to a Deity, the name at the back of the Book for three generations, and both fall at 20 s, on the Day (`variants/the-heir-g3-settling.fight.json --enemy top_end --gap 1`). The same Deity stood on 96 % against the founder and 70 % against the first heir.

## Enabler

**The Named Heir (Lập Tự).** A rider on The Set Day, which is reused from The Given Years, so it needs that keystone and its Core Formation gate.

- **Opens:** a disciple may be named, not only kin. When the Day comes, or if you die after it is set, the next life continues in this world as them. Book, tally and masks pass, and the Tasting Book with them.
- **Closes:** your tree, your realm and your player edge. Grave Goods takes half of what you ate. If the person named dies first, you have no line, and the next life is an ordinary new world.

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a +X per generation became Lien and Grave Goods, which make a line weaker for what it failed to finish.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Eaten Power, reused | Your power term is your realm's base plus what you hold | Borrow | any | none | ○ | Tasting Book | Reused from The Not-Yet-Full |
| Base | **Grave Goods (Tùy Táng)** | At a handover, half of Eaten Power goes into the ground with the head | Trade | any | none | ○ | Succession | any inherited power, any sect treasure that weakens on passing |
| Multiplier | Attack (`attack_pct`) | Plain tree points | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Family Seal, reused | Gear | Gear | any | L3 | ● | Artifact | Reused from The Given Years |
| Multiplier | Short Wick, Given Years, Nothing to Lose, reused | The last years only: L2, L4 at a 20 % gift, L5 | Per | art, basic | L2, L4, L5 | ○ | Evening Table | Reused from The Given Years |
| Reach | Held at Table, reused | Old heads only. A child lets the enemy leave | Trigger | any | none | ○ | Technique | Reused from The Not-Yet-Full |
| Fuel | **Lien (Thế Chấp)** | Each living entry in your Book reserves 5 % of maximum linh lực, to 30 % | Trade | any | none | ○ | Creditors' Book | any debtor, any oath that holds power in escrow |
| Fuel | Thrift, reused unplanned | A quarter of ward efficiency also lowers art cost | Redirect | art | none | ○ | Tree | Reused from The Long Carry, for a pool under Lien |
| Survival | Maximum health (Khí Huyết) | Plain acupoints and notables, to `n_body` 1.4 | Increased | any | none | ● | Tree | any build |
| Survival | Maximum linh lực (Linh Hải) | Plain, to `n_qi` 1.3 | Increased | any | none | ● | Tree | any build |
| Survival | Ward strength (Hộ Lực), Ward efficiency (Hộ Hiệu) | Plain, with gear, to 80 and 80 | Increased | any | none | ● | Tree, gear | any build |
| Survival | Body guard (Hộ Thể) | Plain, to +40 | Increased | any | none | ● | Tree | any build |
| Survival | Slow Wound, Paid in Seasons, Lit Wick, reused | The engine, on paper and the Day | Rule swap | incoming | none | ○ | Paper, Set Day | Reused from three sheets |
| Survival | **Ancestor's Face (Tổ Diện)** | One mask per dead head. Each fight, each stops one hit sized 8 % of your health or more, whole, with nothing drained | Trigger | incoming | none | ○ | Succession | any house relic; a mask stays cheap to the wearer because a death paid for it |
| Identity | **The Name Arrives First (Danh Tiên Chí)** | An enemy your tally frightens carries an exit that stays shut until a blow of theirs falls on a mask. Then it opens at once. Tally 5, 20, 50, 200, 1,000 reach Qi Refining to Deity | Conditional | enemy | none | ○ | The Reckoning | any infamous NPC, any sect with a bad name |
| Identity | Dies Later, Skipped Bill, reused | The Book's two ways of ending without a fight | Per, Overflow | none | none | ○ | Thirty-Six Exits | Reused from The Best Plan |

**Identity piece:** the estate. `--without estate` on `variants/the-heir-mixed.fight.json --gap 1`: the child is dead at 3 s with the enemy on 97 %. With it they are alive on 21 %, and the enemy has left.

**Removed one at a time,** same file and gap: no masks, dead at 3 s. No dread, dead at 4 s. Thrift gone, alive on 15 %. No Lien, alive on 32 %. `variants/the-heir-no-plain.fight.json --gap 1` strips the plain nodes back to typical and the child is dead at 3 s, so the ordinary stack is what keeps the child alive for the exit to open.

**Honey Glaze is a real choice:** at `--gap 0` it empties the stranger's fare and you eat them at 3.076 s. Remove it and they leave at 3.001 s on 62 %. One up it costs you, 21 % against 36 %. First Cut never fires in the main same-realm fight, which ends a millisecond before it.

**The crutch, with its removal run:** `variants/the-heir-g1-settling.fight.json --enemy top_end --without slow_wound`: the founder dies at 1 s with the creditor on 92 %. `--without promissory_paper` gives the same fight. A season pays for a blow only because the blow cannot arrive whole.

**Empty rungs:** L4 is a sacrifice, because Spoiled Palate passes with the Book and closes pills. Crit and rate are plain.

| Layer | Points, first heir | Multiplier | Sources |
|---|---|---|---|
| L1 | 60 | ×1.60 | `attack_pct` |
| L2 | 30 | ×1.30 | Tag modifiers |
| L3 | 30 | ×1.30 | Family Seal |
| L4, L5 | 0 | ×1.00 | Closed, and a child has no condition to hold |

## The Chain

Each row's start is the last row's printed `estate_out` line, except where a life adds what it ate, which is a stated input. Files are in `variants/`.

| Head | Starts with | Book, Lien | Masks | First test | Last fight | Hands on |
|---|---|---|---|---|---|---|
| Tảo, Core | Tally 60, power 4,000 (input) | 3, 15 % | 0 | | Core elder, top-end, 14 seasons: wins at 5 s for 11.3 seasons, then dead on the road, 3,542.8 years owed (`the-heir-g1-settling --enemy top_end`) | Tally 61, power 2,286, 2 entries, 1 mask |
| Liêm, Foundation | As handed on | 2, 10 % | 1 | Mixed Core: enemy flees at 3.001 s, Liêm on 21 % (`the-heir-mixed --gap 1`) | Input: tally 121, power 56,000 at Nascent Soul. Nascent elder, top-end: wins at 5 s for 11.2 seasons, dead on the road (`the-heir-g2-settling --enemy top_end`) | Tally 122, power 30,692, 1 entry, 2 masks |
| Sương, Foundation | As handed on | 1, 5 % | 2 | Mixed Core: enemy flees at 3.001 s on 80 %, Sương on 89 % (`the-heir-g3 --gap 1`) | Input: tally 190, power 80,692. The Deity, top-end, one up, 24 seasons: both fall at 20 s, on the Day, and Sương wins it on overkill (`the-heir-g3-settling --enemy top_end --gap 1`) | Tally 191, power 55,132, 0 entries, 3 masks |
| Nhi, Foundation | As handed on | 0, none | 3 | Mixed Core: wins at 3.076 s on 96 % (`the-heir-g4 --gap 1`). Own top-end: wins at 2.616 s on 100 % (`the-heir-g4-top --enemy top_end`) | None needed | |

**What each head could reach.** The Deity, on the Day: 96 % left against Tảo (`the-heir-g1-deity --enemy top_end --gap 2`), 70 % against Liêm (`the-heir-g2-deity --enemy top_end --gap 1`), 0 against Sương. Tảo also leaves the Nascent elder on 52 % (`the-heir-g1-nascent --enemy top_end --gap 1`).

**The best day to reach a god,** Sương at power 80,692, each `--enemy top_end --gap 1`: 14 seasons, Deity on 10 % (`the-heir-g3-s14`). 18, on 4 % (`the-heir-g3-s18`). 24, a win. A longer wick is worth more here than a shorter one, since the fight has to last.

**Does it need three lives? Not for that fight.** A lone Nascent Soul who has eaten 50,000 and set 24 seasons also kills this Deity at 20 s (`the-heir-one-life --enemy top_end --gap 1`), though at 14 seasons they leave it on 73 % (`the-heir-one-life-s14 --enemy top_end --gap 1`). What needs three lives is the Book, since a settling is fatal, and what comes out at the end: Nhi at Foundation beats a top-end untouched, and `--without masks` the same child is dead at 1 s with the enemy on 92 %. A top-end opens with two hits in one instant, so it takes two masks to be alive for the next, and masks cost a death each.

**The masks do nothing for the old.** Sương with one mask or none still wins, at 18 s (`the-heir-g3-one-mask --enemy top_end --gap 1`, or `--without masks` on the settling file). They exist for children.

**What the line's order costs.** Had Tảo reached no one, Liêm's Lien is 15 % and they leave that fight on 16 % (`the-heir-unsettled --gap 1`). Two names cleared leaves them on 27 % (`the-heir-one-entry --gap 1`).

## Planning Across Lives

This is what a player decides. All of it reads systems the index already lists.

| Decision | When | What it reads | The pull |
|---|---|---|---|
| **Whom to raise** | Decades before the Day | Progression Edges (#11), `npc` sources in `character_edges.json` | Below |
| **Which name to pay** | The last years | The Book | You get one. The name your child is likeliest to meet, or the highest one you can reach, or the one whose death frees the most Lien |
| **When to set the Day** | Any time after Core | Set Day, Given Years | Early gives your heir more years and you a longer last fight. Late gives you more of a life |
| **How much to eat** | Each life | Heart demon, Realms rule on the Nascent gate | Heart demon does not pass, so each heir's gate opens again, which is the door The Not-Yet-Full could never use. Each entry still counts +1. Liêm at 2 entries has (20 − 2) ÷ 2 = 9 kills before the gate |
| **Whom to outlive** | Across lives | Dies Later, Living World Tick (#28) | A line is the cheapest lifespan in the game. Generations of Foundation lives can attend a Deity's funeral, and each funeral pays into the estate |
| **Whether to stop** | Any handover | Succession | An heir may refuse, and the next life is an ordinary new world. Nothing stops Nhi from putting the box away |

**Whom to raise.** An heir is an NPC, so they cross gates on their edge score e, by Realms Formulas C2: base + (max − base) × e⁶. These are the real data values at the four gates. The player's own 0.70 / 0.70 / 0.30 / 0.20 does not pass.

| Disciple | e | Qi Refining | Foundation | Core | Nascent |
|---|---|---|---|---|---|
| Purity 90, poor | 0.35 | 0.124 | 0.079 | 0.059 | 0.032 |
| The estate makes them a rich family | 0.65 | 0.167 | 0.125 | 0.077 | 0.045 |
| And a place in the inner sect (nội môn) | 0.75 | 0.226 | 0.189 | 0.102 | 0.062 |
| And elder's rank (trưởng lão), not inner | 0.90 | 0.430 | 0.409 | 0.187 | 0.121 |
| And one variant root | 1.00 | 0.70 | 0.70 | 0.30 | 0.20 |

So a line can buy its child the player's own odds, and the last 0.10 of edge is worth nearly as much as everything before it. Dies Later's claims pay for rich family, the seat pays for rank, and the search for a variant root is the work of a whole life.

**The power term is bounded.** With a life eating E, each handover gives ½ (P + E), which closes on E. A line never holds more than one life's meal at handover, whatever its length. That answers the critic's question about `fight_unit` for this build, at least.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Whatever the disciple has. Purity first | It decides the edge table above |
| Key talents | Any | No build reads one. Fortune stays at the default 50 in every file, and no art reads thần thức |
| The Way (Đạo) | None needed | One glimpse goes to what the house lacks |

## Công Pháp and Arts

All reused, with no new technique. Bottomless Sutra is the main method: First Cut, Carve, Honey Glaze, Second Helping, Tucked Napkin. Thirty-Six Exits is the secret method, for Thần Hành Phù and Skipped Bill. Keeping-House Sutra is not taken, so none of its arts are used. All arts are inside the lint in every file.

## Loadout by Realm

| Realm | Slots | Slot order | Note |
|---|---|---|---|
| Foundation | 4 | Paper, First Cut, Carve, Honey Glaze | Paper waits on its `owing` guard: owing costs a slot in every fight, used or not |
| Core Formation | 5 | Add Second Helping | |
| Nascent Soul | 6 | Add Tucked Napkin | Its lock tag closes the exit, so it comes in when you want them to stay |
| Debt-free | 4 | First Cut, Carve, Honey Glaze, Tucked Napkin | Nhi's slot back |

## Matchups

The first heir, `sheets/the-heir.fight.json` and `variants/`.

| Enemy | Result | File |
|---|---|---|
| Mixed, same realm | Win, 3.076 s on 92 % | `the-heir-mixed` |
| Mixed, one up | Enemy flees at 3.001 s, you on 21 % | `the-heir-mixed --gap 1` |
| Mixed, two up | Dead at 2 s, enemy on 99 %. Tally 61 does not reach a Nascent Soul | `the-heir-mixed --gap 2` |
| One jab and nothing else, one up | Enemy flees at 3.001 s, you on 67 % | `the-heir-one-jab --gap 1` |
| One jab, same realm | Win, 3.076 s on 92 % | `the-heir-one-jab` |
| Foreseen, abroad, L4 +25 on body hits from Iron-Sand Hand Bath, same realm | Win, 3.076 s on 92 % | `the-heir-foreseen` |
| Foreseen, abroad, one up | **Dead at 4 s, enemy on 92 %.** Nobody here has heard of you | `the-heir-foreseen --gap 1` |
| A creditor, Nascent elder, two up, with paper and an exit | Leaves at 3.5 s on 85 %, 98,198 % still owed | `the-heir-creditor --enemy top_end --gap 2` |
| The same, out of paper | Dead at 1 s as the bill lands | same file, `--without promissory_paper` |
| Top-end, same realm | Dead at 1 s. One mask, two hits | main |
| Second heir against the same top-end | Dead at 2 s, enemy on 84 % | `the-heir-g3-top --enemy top_end` |

**Counter:** a stranger. Fear stops at the edge of what people have heard, and so does most of the first heir. Second, a top-end's two-hit opening until the line has two masks. Third, the cruel one: kill the disciple before the Day, and three lives of planning end in an ordinary new world.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Slots 4, 5 and 6 of their realms, every art within the lint. Masks, paper and the estate have no price, the critic's first finding |
| Validity | PASS | Real realm, ward and key ids. `n_body` 1.4 matches the top-end share at Foundation, 1 + 0.00833 × 0.20 × 248 |
| Stack | PASS | Forms: Borrow, Trade, Increased, Redirect, Rule swap, Trigger, Conditional, Per. Identity and single removals run. L4 stated as a sacrifice |
| Scaling | PASS | `m_static` 2.70 against typical 4.19 and top-end 148, under the anchor on purpose. A first heir is ordinary. The fight unit is 25.5 against the realm's 15.8. INFO |
| The fight | NOT ASSESSED | Every fight in the chain runs and no cap is hit, but the power between handovers is a stated input, so the life that earns it is untested |
| Reuse | PASS | Everything but the 5 new pieces is reused. Thrift is the unplanned one, proved in the main fight: `sheets/the-heir.fight.json --gap 1`, on 57 % with it, 50 % without. Each new piece has a second home |
| NPC use | NOT ASSESSED | Each modifier is a stored number, but no rule says how an NPC house passes on |
| Counterplay | PASS | Abroad, top-end, killing the disciple |
| Originality | PASS | All names are new. "Thừa tự" is an ordinary word for inheriting a line |

## Fight Results

Input: `sheets/the-heir.fight.json`, the first heir at handover, with `rules/the_line.py` and the parents' plug-ins. Observations from `fight_x.py`, a paper model.

| Enemy | Gap | Result | Time | Own health |
|---|---|---|---|---|
| typical | 0 | Win | 3.076 s | 95 % |
| typical | 1 | Enemy flees | 3.001 s | 57 % |
| typical | 2 | Dead, enemy on 99 % | 2 s | 0 % |
| top_end | 0 | Dead, enemy on 97 % | 1 s | 0 % |
| top_end | 1 | Dead, enemy on 99 % | 1 s | 0 % |
| top_end | 2 | Dead, enemy on 100 % | 1 s | 0 % |

**Second realm:** the Core and Nascent Soul files in The Chain. **Unmodelled:** Succession, Set Day's age move, the edge table, heart demon, Dies Later, and every kill that fills a head's power between handovers. Fortune and sense are not read.

## New Concepts

**Succession (Kế Tự).** A mode of system #12, Codex & Karmic Carryover, which is Not Started and has no GDD, so this breaks nothing. Game concept says each life is a new world. This adds one exception.

- **Rule:** with a Named Heir alive at your death, the next life continues as them in this world. Passes: Book, tally, half of Eaten Power, one mask per head, stones and Family Seal. Stays behind: tree, techniques not taught, heart demon, and the player's edge.
- **Bounds:** Grave Goods bounds power. Masks cost a death each. An entry ends with its creditor.
- **Breakdown line:** "Ancestor's Face: Tảo. Hit stopped."
- **Other builds:** any sect succession, The Given Years' Long Table, a Herd-Child's beast left to a grandchild.
- **NPCs:** a house is a stored chain of ids. Living World Tick would need one row.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| The Named Heir, Succession, Grave Goods | Needs rule | Codex & Karmic Carryover (#12); Realms rule on Set Day; World Database keeps the world |
| Lien | Needs rule | Combat rule 11: an entry may reserve linh lực. The calculator's `reserve_share` already runs it |
| Ancestor's Face | Needs rule | Combat rule 4: a hit may be stopped whole. Same family as The Curtain, and unpriced, as the critic found |
| The Name Arrives First | Needs rule | One row in The Reckoning: an exit gated on a fallen mask |
| Slow Wound, Promissory Paper, Skipped Bill, Creditors' Book, Eaten Power, Spoiled Palate, Held at Table, The Set Day, Paid in Seasons, Lit Wick | Needs rule | Already asked by the parents |
| Thrift, Short Wick, Given Years, Nothing to Lose, the arts, Thần Hành Phù | Needs key | Reused |

## Also Considered

- The Long Table (Trường Tịch): a Per on living descendants, so a big family is the stat. Warm, but it is one number with a family painted on it, and it leaves the debt out.
- The Borrowed Name (Tá Danh): one mask worn for six centuries, with the world never told the founder died. Strong as a fraud story, but the critic asked for sincerity.
