# The Proctor (Giám Thí Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 3, as re-aimed: a hunter that kills Already-Waited or Forum Build at its own realm, whichever is hardest to stop, plain rows and existing wards, someone proud.
> **Direction**: `panel.md` says Forum Build: it beats the Wall at 2 s, where Already-Waited needs 9 s. So the target is Forum Build on its own ground, under its own law. The same file kills Already-Waited as well. No new piece.
> **Realm span**: Core Formation – Nascent Soul, defined at Nascent Soul · **Power level**: ordinary · **Use**: player build, or the Examiners' last ruling
> **Fit**: 7 Fits today · 10 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, and curses have no lint)

## The Spine

- **The channel:** art hits and the fist, mostly qi, through a ward that will run dry.
- **The enabler:** none.
- **The loop:** take the volley on one fee a hit, speak one curse, and keep answering until they cannot.
- **The engine:** a per-hit ward charges the same for 15 as for 1. Forum Build has bought a volley of size, and nothing else. Standing Word then blocks regeneration and raises ward drain on the pool that pays for everything.
- **The sacrifice:** speed. Anything that kills by 1 s, or a top-end, ends it.
- **The arc:** a beginner's method carried past its tier to hold one hall.

## The Legend

Proctor Ôn has kept the third hall of the capital's examination quarter for ninety years, and in that time no candidate has passed a note, a whisper or a bribe under their eye. They wear the plain grey. They set their stool at the same mark on the floor every session. They hold that the honest sitting of an examination is the greatest thing a civilised person can witness, and will explain why, standing, for some time.

When the post went up on the teahouse walls, Ôn read it twice and asked for the array's deed to be brought to them. They do not dispute it. They walk onto the terraces, put down the stool, and charge one fee for every answer, whatever its length. Reply #9 asks what to do about that. Ôn has written the correct answer on the wall underneath, in very small, very even characters: *sit the paper.*

## How It Fights

At t = 1 six arts arrive, and Ôn pays six fees and stands on 73 %. Heart demon buys two more rounds. By 5 s the pool that paid for them is gone, and with Withheld Hand there is no fist to fall back on. From there the bar does not move again, and Ôn finishes marking.

**The signature moment:** Forum Build's `lint_total`: 69.7 fired, 22.4 sold, 119 seconds skipped, and it loses (`variants/the-proctor-swap.fight.json`). **The line of play, Sit the Paper:** Standing Verdict up, Standing Word first, no art held back, and do not try to race the volley.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Survival | **Standing Verdict** | Per-hit ward, pass 0.30 and 0.20, fee 0.05 | Rule swap | any | none | ○ | Ward | From Fortieth Breath |
| Survival | Ward strength, efficiency | `ws` 220, `we` 80 | Increased | any | none | ● | Tree | every build |
| Survival | Health, body guard, armour | `n_body` 2.0, +40 %, `a_b` 2.8, `t_b` 2 | Increased | any | none | ● | Tree, gear, Packed Clay | every build |
| Fuel | Regeneration | +2 % | Increased | any | none | ● | Tree | every build |
| Multiplier | Damage (`attack_pct`) | +150 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Marked Target | +3 per curse | Per | art | L1 | ○ | Tree | From One Long Word |
| Multiplier | Plain Speech Method | +10 to its arts | More | art | L2 | ○ | Technique | From One Long Word |
| Multiplier | Single Grudge, Set Jaw | +18 with one curse on | More | art | L2 | ○ | Tree | From One Long Word |
| Multiplier | Gear and pill | L3 40, L4 20 | Gear | any | L3, L4 | ● | Items | every build |

**Identity piece:** the ward. `--without ward` on `variants/the-proctor-vs-forum-build.fight.json` loses at 1 s with Forum Build on 100 %.
**Empty rungs:** crit, reach, L5. The law would clip L5 to 10 and L2 and L3 to 40 here anyway, so this build pays for nothing it would lose.

| Layer | Points at Nascent Soul | Multiplier | Sources |
|---|---|---|---|
| L1 | 150 to 153 | ×2.50 | `attack_pct`, Marked Target |
| L2 | 10 to 28 | ×1.10 to ×1.28 | Method, the grudge rows with the curse on |
| L3 | 40 | ×1.40 | Typical weapon, at the law's cap |
| L4 | 20 | ×1.20 | Pill, at Taken Ground's limit |
| L5 | 0 | ×1.00 | Empty |

**W:** `attack_pct` 150, health 120, linh lực 50, ward strength 195 (over gear 25), efficiency 80, body guard 40, regeneration 16, the grudge rows 13: 664 of 739.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any | Plain Speech names none |
| Techniques | Plain Speech Method (main, Huyền giai), Packed Clay Method (body) | Past its tier the method keeps power, and only cultivation falls to ×0.25 (rule 10). Ôn's cultivation stopped mattering decades ago |
| Ward | Standing Verdict, `ws` 220, `we` 80 | |

## Arts

Standing Word, Level Gaze, Closing Sentence and Plain Reproach, in that slot order, unchanged from The One Long Word at its full road. Four of six slots.

## Matchups

Files are `variants/the-proctor-[name].fight.json`, run with no flag. Forum Build runs whole on the enemy side: the law, Standing Water, Title Deed, heart demon, Withheld Hand. No plug-in is left out.

| Enemy | Result | File |
|---|---|---|
| **Forum Build, on its ground, foreseen** | **Wins at 12 s on 46 %, pool 49 %** | `vs-forum-build` |
| Forum Build opens (its file, this build as the enemy) | Wins at 12 s on 46 % | `swap` |
| Forum Build, Core Formation, this build at Core (436 W) | Wins at 10.458 s on 43 % | `core-vs-forum-build` |
| **Already-Waited** | **Wins at 9 s on 52 %** | `vs-already-waited` |
| Mixed, same realm | Wins at 6 s on 90 % | `mixed` |
| Panel Fast | Wins at 5 s on 83 % | `fast` |
| Cut Line | Loses at 0.8 s, enemy on 100 % | `vs-cut-line` |
| Full Price, Core profile | Loses at 1 s, enemy on 97 % | `vs-full-price` |

**One record decides it.** Only the ward changes in the first two rows.

| Change | Result | File |
|---|---|---|
| Common drain ward, same `ws` | Loses at 1 s, Forum Build on 100 % | `drain-ward` |
| Stone Ward at 0.10, same `ws` | Loses at 4 s, Forum Build on 96 % | `stone-ward` |
| `ws` 100, down from 220 | Still wins at 12 s, on 7 % | `ws-100` |
| No Standing Word | Still wins, at 20 s on 36 % | `no-word` |

**Counter:** Cut Line and Full Price, each of which ends this before the first art. A same-realm top-end kills it at 1 s.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 4 of 6 slots, 664 of 739 W. Thần thức not totalled |
| Validity | PASS | Method past its tier is legal by rule 10. `a_b` and `t_b` as The Dug Stone |
| Stack | PASS | Five forms. `--without ward` changes every fight |
| Scaling | PASS | `m_static` 4.20 against 7.37 and 256 |
| The fight | PASS | No plug-in of its own. Six of Forum Build's run on the enemy side. The swap matches |
| Reuse | PASS | No new piece. Standing Verdict moved from Fortieth Breath, the Word from One Long Word |
| NPC use | PASS | Any strict elder |
| Counterplay | PASS | Cut Line, Full Price, a top-end |
| Originality | PASS | No name borrowed |

## Fight Results

Input: `sheets/the-proctor.fight.json`, through `_tools/fight_x.py`. A paper model. The fixture enemies bankrupt themselves, so read the gap rows with that in mind.

| Enemy | Gap | Result | Time | Enemy left |
|---|---|---|---|---|
| typical | 0 | Win on 92 % | 6 s | 0 |
| typical | 1 | Win on 55 % | 13 s | 0 |
| top_end | 0 | Loss | 1 s | 99 % |
| top_end | 1 | Loss | 1 s | 100 % |

**Unmodelled:** see the fight file.

**For the user:** the ward model decides this fight more than any row. Forum Build's whole break, 69.7 of coefficient for 22.4 of price, comes to nothing against one existing ward record. This is the critic's first rule discovery again: nothing prices the ward model.

## Also Considered

- **The Understudy route:** Forum Build's sheet already shows a double beats it. Not plain.
- **The Illusionist's Invitation:** make it fight blind, as reply #10 fears. The law and the deed fall, but that is a plan outside the fight.
