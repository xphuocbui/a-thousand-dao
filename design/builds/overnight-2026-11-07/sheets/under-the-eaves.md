# Under the Eaves (Thiềm Hạ Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Kit hunter: beat Pine Rain at equal W and realm with plain rows, 0 rule asks, a kit other than the cheap one.
> **Direction**: Pine Rain spends half its pool a second and is dry at 2.5 s. So stand under the ward with the best pass, fire nothing, and let seven cheap 4 s arts land together on a body with no ward. No new piece.
> **Realm span**: Foundation Establishment – Deity Transformation, defined at Deity Transformation · **Power level**: strong · **Use**: player build, or any stubborn elder
> **Fit**: 5 Fits today · 3 Needs key · 0 Needs rule
> **Checks**: 7 PASS · 1 FAIL (Stack: three forms) · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** art hits, seven in one instant, every 4 s.
- **The enabler:** none. Standing Verdict does the work.
- **The loop:** wait four seconds, fire once.
- **The engine:** the rain stops on its own. At 3 s the kit stands on 94 % with no pool at all, and at 4 s seven lamps take it to 0 in one instant.
- **The sacrifice:** nothing lands for four seconds, and a top-end ends it at 1 s.
- **The arc:** 4 s is too long at Qi Refining. From Foundation up the pool outlasts the wait.

## The Legend

Master Hà holds, against all weather records, that no rain has ever lasted past the fourth breath. They have written three treatises on this. They have been soaked at every public occasion of their long life, have put it down each time to faulty breathing or the rain's bad manners, and have never once carried an umbrella.

It happens that this is exactly true of the pine school, whose disciples open every duel with a downpour and have nothing behind it. Hà stepped under a gatehouse roof, began to count aloud and lit seven lamps on the word four. The disciples were carried home. Hà has added a fourth treatise, is more certain than ever, and it is raining on them as they write it.

## How It Fights

Pine Rain pours. By 2 s the kit's pool is on 6 %, and Hà is on 76 %. Nothing answers but the fist. At 3 s the pool is 0 and the bar 94 %. At 4 s all seven lamps fire, and the bar goes to 0 in one instant, with Hà on 71 %.

**The signature moment:** a kit on 94 % at 3 s, dead at 4 s. **The line of play, Count to Four:** spend nothing early, put every lamp on the same beat.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Survival | **Standing Verdict** | Per-hit ward, pass 0.30 and 0.20, fee 0.05 | Rule swap | any | none | ○ | Ward | From Fortieth Breath |
| Survival | Ward strength | +24: 20 acupoints | Increased | any | none | ● | Tree | every build |
| Survival | Ward efficiency | +8: 1 notable | Increased | any | none | ● | Tree | every per-hit ward |
| Survival | Maximum health | +95.5 on the walk, +45 off it | Increased | any | none | ● | Tree | every build |
| Fuel | Regeneration | +4.6: 4 acupoints, 4 notables | Increased | any | none | ● | Tree | every build |
| Multiplier | Damage (`attack_pct`) | +122 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Gear | L3 40, kept from Evergreen | Gear | any | L3 | ● | Artifacts | every build |

**Identity piece:** the ward. `--without ward` on `variants/under-the-eaves-vs-pine-rain.fight.json` loses at 1 s with the kit on 98 %.
**Empty rungs:** crit past the base, L2 past the method, L4, L5. All sacrifices.

**W:** 61 acupoints and 14 notables, 185.2 W, plus 176 W outside the walk: attack 122, health 54 at 1.2 W a point. Total 361.2, as Pine Rain's.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire | Low Flame Method names it, and it teaches the lamps |
| Main method | Low Flame Method, read here at L2 20 | Its +40 is more than Evergreen's method gives, so the file keeps 20 and understates the lamps |
| Ward | Standing Verdict, `ws` 108.1, `we` 92.1 | |

## Arts

First Lamp to Seventh Lamp, unchanged from The Seven Lamps: qi, `c_art` 2.23, cost 0.04, 4 s. Seven of seven slots. The kit's cost, at eight times its cooldown.

## Matchups

Files are `variants/under-the-eaves-[name].fight.json`, run with no flag.

| Enemy | Result | File |
|---|---|---|
| **Pine Rain** | **Wins at 4 s on 71 %** | `vs-pine-rain` |
| Pine Rain opens | Wins at 4 s on 71 % | `swap` |
| Same rows, common ward | Loses at 1.5 s, kit on 98 % | `common` |
| The line on Cloth, on Verdict | Wins at 4 s on 71 % | `line-on-cloth`, `line-on-verdict` |
| The line on Stone | Wins at 17 s on 59 % | `line-on-stone` |
| The cheap art on these rows and this ward | Wins at 12 s on 64 % | `kit-on-my-rows` |
| Best kit a search found, W re-spent, on Stone | **Stalemate at 40 s, both on 8 %** | `kit-answer` |
| Re-cut: Short Reply | Wins at 4 s on 45 % | `vs-short-reply` |
| Re-cut: Thin Shavings | Loses at 4 s on overkill, both at 0 % | `vs-thin-shavings` |
| Mixed, Pulse, Evader, Fast | Wins at 8 s on 85 %, 12 s on 72 %, 8 s on 79 %, 4 s on 75 % | `mixed`, `pulse`, `evader`, `fast` |
| Wall | Wins at 24 s on 58 % | `wall` |

**Counter:** a top-end, which kills it at 1 s, and anything that kills by 4 s.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 7 of 7 slots, 361.2 W. Thần thức not totalled |
| Validity | PASS | Fee 0.05 inside Combat's 0 to 0.10. Regeneration 6.6 %, under the 8 % cap |
| Stack | FAIL | Three forms, under the four the skill asks. A plain hunter by brief. `--without ward` changes the fight |
| Scaling | PASS | `m_static` 3.11 against 8.96. Below the anchor on purpose |
| The fight | PASS | No plug-in. The swap matches |
| Reuse | PASS | No new piece |
| NPC use | PASS | Any elder with seven lamps |
| Counterplay | PASS | Top-end, an early kill |
| Originality | PASS | No name borrowed |

## Fight Results

Input: `sheets/under-the-eaves.fight.json`, through `_tools/fight_x.py`. A paper model. Deity has no realm above it, so the gap rows stay at that realm, with suppression.

| Enemy | Gap | Result | Time | Enemy left |
|---|---|---|---|---|
| typical | 0 | Win on 86 % | 6 s | 0 |
| typical | 1 | Win on 84 % | 8 s | 0 |
| top_end | 0 | Loss | 1 s | 100 % |
| top_end | 1 | Loss | 1 s | 100 % |

**For the user:** this is the strongest slow line of the three: 5 of 5 on the panel, and no kit a search tried could beat it. The kit fails here because seven slots spend the pool in 2.5 s. See `kit-hunt.md`.

## Also Considered

- **The Bare Roof:** the same lamps on Stone Ward. It also won its rematches in scratch, with thinner margins.
- **The Long Rope:** seven Drawn Ropes at 3 s. Faster, with thinner margins in scratch.
