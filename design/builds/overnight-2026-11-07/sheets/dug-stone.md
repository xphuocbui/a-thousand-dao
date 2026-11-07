# The Dug Stone (Quật Thạch Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 3: a hunter that kills Full Price at its own realm, plain rows and existing wards, at most one new piece, someone joyful.
> **Direction**: The plan was to outlast the purse. The runs say no legal wall does. A per-hit ward charges one fee for a hit of any size, so it takes the stamp and leaves the pool free for one honest answer at t = 1. One new piece.
> **Realm span**: Core Formation – Nascent Soul, defined at Core Formation · **Power level**: ordinary, with one shot · **Use**: player build, or a miner nobody should have stamped
> **Fit**: 7 Fits today · 9 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** art hits on L1 to L4, one heavy Earth art at the lint's ceiling.
- **The enabler:** none. The new piece is one art.
- **The loop:** take the blow, then spend 85 % of the pool on one swing.
- **The engine:** on a drain ward the pool is the ward, so nobody spends 85 %. A per-hit ward needs only its fee. Standing Verdict separates the two, and the lint sells 11.2 for that share with no stones at all.
- **The sacrifice:** the second swing. If the first does not kill, there is 2 % left and nothing to say.
- **The arc:** a digger who found out what the stones cost.

## The Legend

Lạc has dug spirit stones in Seam Nine for sixty years and has never once stopped finding them funny. They sing badly down the shaft, feed the pit ponies out of their own bowl, and keep a jar of the ugliest stones on the shelf for visitors. When a Seal holder arrived to buy the seam and named a price, Lạc asked to see the money, turned a stone to the lamp, knew the gallery by the grain, and laughed until someone had to fetch a stool.

They have since let four merchants stamp them. They ask for the receipt. They frame the receipts. Then they pick up the pick, swing the whole working day at once, and go looking for whoever is selling lunch. Half the valley comes to watch, and Lạc sells them the seats.

## How It Fights

At 0.5 s the stamp comes down: 45,000 stones, and Lạc goes to 28 %, paying the same small fee the ward charges for a slap. At 1 s Whole Seam and the fist land together, and the merchant is dead before the second contract at 1.5 s.

**The signature moment:** the merchant's bill is 45,619 stones, unrefunded (`variants/dug-stone-swap.fight.json`). Lạc's bill is a day's digging. **The line of play, Take the Stamp:** survive 0.5 s on the fee, answer at 1 s, and never let 1.5 s arrive.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Multiplier | Damage (`attack_pct`) | +72 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Earth damage | +30 | Increased | art | L1 | ○ | Tree | From Long Firing |
| Multiplier | Body damage | +17.5 | Increased | art, basic | L1 | ○ | Tree | From Long Firing |
| Multiplier | Long Firing Method | +40 to Earth arts | More | art | L2 | ○ | Technique | From Long Firing |
| Multiplier | Load-Bearing | 4 acupoints and the notable: +9 per artifact, +36 at four | Per | art | L2 | ○ | Tree | From Long Firing, the notable taken at last |
| Multiplier | Weapon attack | Inside L3 146, the Ore Line's two seals | Gear | any | L3 | ● | Artifacts | From Long Firing |
| Multiplier | Attack pill | +20 | More | any | L4 | ● | Pill | every build |
| Survival | Standing Verdict | Per-hit ward, pass 0.30 and 0.20, fee 0.05 | Rule swap | any | none | ○ | Ward | From Fortieth Breath |
| Survival | Ward strength, health, body guard, Armour defence | `ws` 150, `n_body` 2.0, +32 %, `a_b` 2.8 | Increased | any | none | ● | Tree, gear | every build |
| Identity | **Whole Seam (Toàn Mạch)**, new | Below | | art | none | ○ | Long Firing Method | any per-hit ward build, any one-blow finisher |

**Identity piece:** Whole Seam. `--without whole_seam` on `variants/dug-stone-vs-full-price.fight.json` loses at 1.5 s with the merchant on 95 %.
**Empty rungs:** L5, crit, reach and fuel. A sacrifice: no W is left.

| Layer | Points at Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 119.5 | ×2.20 | On Earth arts |
| L2 | 76 | ×1.76 | Method, Load-Bearing |
| L3 | 146 | ×2.46 | Two seals |
| L4 | 20 | ×1.20 | Pill |
| L5 | 0 | ×1.00 | Empty |

**W:** `attack_pct` 72, Earth damage 18.8, Body damage 14, Weapon attack 17.6, Armour defence 12.8, Load-Bearing 12.8, health 120, linh lực 20, ward strength 125 (over gear 25), body guard 32: 445 of 447.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth | The method names it |
| Key talents | None | Fortune would be wasted on Lạc, who has never needed any |
| Techniques | Long Firing Method (main, Huyền giai), Packed Clay Method (body, `t_b` 2) | Both reused, both reach Core |
| Ward | Standing Verdict, `ws` 150, `we` 0 | |

## Arts

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| **Whole Seam (Toàn Mạch)** | Long Firing Method, a new ability | body, Earth | 11.2 | 0.85 | 1 s | none | Needs key |
| Falling Lintel | Same | body, Earth | 2.71 | 0.08 | 4 s | none | Needs key |
| Settling Wall | Same | body, Earth | 2.96 | 0.08 | 5 s | none | Needs key |

**Whole Seam. Effect:** a hit, on the lint's line exactly. It waits for 85 % of the pool, so it fires once. **Description:** a whole day's work, delivered at once.

## Items

Two seals, `an` at Hạ and Trung phẩm, as the Ore Line. A `giap` at Thượng phẩm and a `thuan` at Hạ phẩm give `a_b` 2.8 under Armour defence, scaled from the Ore Line's 0.85, a first guess. Four artifacts, which is what Load-Bearing counts.

## Matchups

Files are `variants/dug-stone-[name].fight.json`, run with no flag. Full Price runs whole on the enemy side: all five plug-ins, an 80,000-stone purse, the contract loadout.

| Enemy | Result | File |
|---|---|---|
| **Full Price, Core Formation** | **Wins at 1 s on 17 %, pool 2 %** | `vs-full-price` |
| Full Price opens (its file, this build as the enemy) | Wins at 1 s on 17 % | `swap` |
| Full Price, Nascent Soul, this build at Nascent Soul | Wins at 1 s on 31 % | `nascent-vs-full-price` |
| Full Price with 34,850 stones, its third contract | Wins at 1 s on 92 % | `third-contract` |
| Mixed, same realm | Wins at 1 s on 98 % | `mixed` |
| Panel Fast | Wins at 1 s on 77 % | `fast` |
| Cut Line, Nascent Soul profile | Loses at 0.8 s, enemy on 100 % | `vs-cut-line` |
| Forum Build, Nascent Soul profile | Loses at 1 s, enemy on 91 % | `vs-forum-build` |

**How thin it is.** Each row changes one thing against Full Price.

| Change | Result | File |
|---|---|---|
| `attack_pct` 50, down from 72 | Still wins at 1 s on 17 % | `attack-50` |
| `attack_pct` 45 | Loses at 1 s, merchant on 2 % | `attack-45` |
| `ws` 110, down from 150 | Still wins, on 2 % | `ws-110` |
| Common drain ward, same `ws` | Loses at 0.5 s, merchant on 100 % | `drain-ward` |
| A wall alone: no Whole Seam, the W moved to `n_body` 2.6, efficiency 45, regeneration, a tick | Loses at 1.5 s, merchant on 97 % | `wall-only` |

**The row nobody has used.** First firing comes sooner, a catalogue row, at −50 % for 31.6 W (`rules/first_firing.py`). Paid for with `ws` 130 and body guard +20, it wins at 0.5 s on 18 % (`first-firing`). The same file with the row taken off wins at 1 s on 6 % (`no-first-firing`). At Nascent Soul the same swing kills Cut Line at 0.5 s on 70 % (`first-firing-vs-cut-line`). **The row states no floor.** The plug-in stops it at `cooldown_min`, which is this sheet's reading and not a rule.

**Counter:** anyone who kills by 1 s, a same-realm top-end (below), or anyone who survives the swing, since 2 % of a pool answers nothing.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 3 of 5 slots, 445 of 447 W. Thần thức not totalled |
| Validity | PASS | Both techniques reach Core. Whole Seam 11.2 sits inside Formulas C's range of 1.2 to 12 |
| Stack | PASS | Five forms. Removals above |
| Scaling | PASS | `m_static` 5.08 against 5.48 and 210; ×11.4 on Whole Seam |
| The fight | PASS | No plug-in in the main file. Swap matches. All arts `within` |
| Reuse | PASS | One new piece. Load-Bearing's notable and the Ore Line were on Long Firing's sheet, unwalked or unproved there |
| NPC use | PASS | Any miner |
| Counterplay | PASS | Cut Line, Forum Build, a top-end |
| Originality | PASS | No name borrowed |

## Fight Results

Input: `sheets/dug-stone.fight.json`, through `_tools/fight_x.py`. A paper model.

| Enemy | Gap | Result | Time | Enemy left |
|---|---|---|---|---|
| typical | 0 | Win on 98 % | 1 s | 0 |
| typical | 1 | Loss | 5 s | 50 % |
| top_end | 0 | Loss | 1 s | 63 % |
| top_end | 1 | Loss | 1 s | 92 % |

**Unmodelled:** the armour's `a_b`, as above.

**For the user:**
1. Evade stays an expected value, so a 40 % evader is not tested here. The sheet does not lean on it.
2. Any art at cost 0.85 is legal today. Only the pool made that foolish, and a per-hit ward removes the pool from the question.
3. Should First firing have a floor? Forum Build's sentence, "a wait is paid, never deleted", would say so past 1 s arts. On a 1 s art the lint prices no wait, so nothing is deleted there.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Whole Seam | Needs key | An ability record on Long Firing Method |

## Also Considered

- **Outlast the Purse:** a pure wall that waits for the stones to run out. It dies at 1.5 s inside the budget (`wall-only`).
- **The Fourth Fight:** three cheap hired fights first, then this. It works (`third-contract`), and the bait is outside the fight.
