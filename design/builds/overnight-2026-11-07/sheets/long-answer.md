# The Long Answer (Trường Đáp Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Kit hunter: beat Short Reply at equal W and realm with plain rows, 0 rule asks, a kit other than the cheap one.
> **Direction**: Short Reply is One Long Word with its arts cut down. So give the school its slow arts back, charge the ward by the second, and move the kit's damage W onto the ward and the body. No new piece.
> **Realm span**: Foundation Establishment – Deity Transformation, defined at Foundation Establishment · **Power level**: ordinary · **Use**: player build, or a school's answer to its own impatient pupils
> **Fit**: 4 Fits today · 6 Needs key · 0 Needs rule
> **Checks**: 7 PASS · 1 FAIL (Stack: three forms) · 1 NOT ASSESSED (Budgets: thần thức not totalled, curses have no lint)

## The Spine

- **The channel:** art hits on 3 to 4 s cooldowns, the fist, one curse.
- **The enabler:** none. Stone Ward does the work.
- **The loop:** pay one upkeep a second, stand through the volleys, answer at 3 s and at 4 s.
- **The engine:** a per-pulse ward costs the same for 7 hits a second as for none. The kit's pool is gone by 3.8 s, and the slow arts arrive at a body with no ward.
- **The sacrifice:** damage. L1 is 6. It takes 8 s to finish anything, and it has no answer to a kit that spends the same W on damage alone.
- **The arc:** the same arts and ward carry to Deity. At Qi Refining 3 s is too late.

## The Legend

Registrar Khúc of the Plain Speech school has never in their life replied in fewer than four clauses, and has corrected the school's founder on the use of the semicolon, posthumously. When the younger students took to answering in single words, fast, and calling it the modern style, Khúc wrote to the council at length. The council replied with one word.

So Khúc stood up in the yard, set down a stone, and let them speak. They heard out each student entirely. They then gave the reply in full, with its preamble, its proper order and its closing sentence, and sat down again, untouched by doubt. They are sure this proved the semicolon. It proved nothing of the kind, and no one left standing is in a position to say so.

## How It Fights

At 2 s Khúc is on 69 %, and Short Reply stands on 95 % with its pool at 59 %. Level Gaze and Plain Reproach land at 3 s, Standing Word at 3.8 s, and at 4 s the kit's pool is 0 and its bar 57 %. The second round finishes it at 8 s, with Khúc on 30 %.

**The signature moment:** One Long Word's own first-line arts, which lost four of five on the panel, beat the line that replaced them. **The line of play, In Full:** stone down, no art held back, do not race.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Survival | **Stone Ward** | Per-pulse ward, common pass, upkeep 0.10 | Rule swap | any | none | ○ | Ward | From Long Firing |
| Survival | Ward strength | +40.4 on the road, +55 off it | Increased | any | none | ● | Tree | every build |
| Survival | Maximum health | +29 on the road, +91.7 off it | Increased | any | none | ● | Tree | every build |
| Fuel | Regeneration | +0.15: 1 acupoint | Increased | any | none | ● | Tree | every build |
| Multiplier | Damage (`attack_pct`) | +6 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Plain Speech Method, gear, pill | L2 10, L3 30, L4 20, kept from One Long Word | Gear | any | L2 to L4 | ○ | Technique, items | From One Long Word |

**Identity piece:** the ward. `--without ward` on `variants/long-answer-vs-short-reply.fight.json` loses at 1.5 s with the kit on 97 %.
**Empty rungs:** crit, reach, L5, the curse road. All sacrifices.

**W:** road 24 acupoints and 6 notables, 76.8 W, plus 171 W outside it: attack 6, ward strength 55, health 110 at 1.2 W a point. Total 247.8, as Short Reply's.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any | Plain Speech names none |
| Ward | Stone Ward at the legal 0.10, `ws` 135.4, `we` 40 | |

## Arts

Level Gaze, Plain Reproach, Closing Sentence and Standing Word, in that slot order, unchanged from One Long Word, with Standing Word at Short Reply's unrowed values. Four of four slots.

## Matchups

Files are `variants/long-answer-[name].fight.json`, run with no flag.

| Enemy | Result | File |
|---|---|---|
| **Short Reply** | **Wins at 8 s on 30 %** | `vs-short-reply` |
| Short Reply opens | Wins at 8 s on 30 % | `swap` |
| Same rows, common ward | Loses at 2 s, kit on 95 % | `common` |
| The line on Cloth, on Verdict | Wins at 8 s on 28 % | `line-on-cloth`, `line-on-verdict` |
| The line on Stone | Wins at 8 s on 36 % | `line-on-stone` |
| The cheap art on these rows and this ward | Wins at 9 s on 73 % | `kit-on-my-rows` |
| Best kit a search found, W re-spent, on Cloth | **Loses at 3 s, kit on 68 %** | `kit-answer` |
| A 1 s art on Verdict against that kit | Wins at 4 s on 37 % | `second-answer` |
| No Standing Word | Still wins, at 9 s on 12 % | `no-word` |
| Standing Word at 2 s, a probe | Wins at 6 s on 47 % | `early-word` |
| Re-cut: Pine Rain | Wins at 6 s on 71 % | `vs-pine-rain` |
| Re-cut: Thin Shavings | Loses at 2 s, kit on 89 % | `vs-thin-shavings` |
| Mixed, Pulse, Evader, Fast | Wins at 8 s on 58 %, 10 s on 42 %, 13 s on 8 %, 6 s on 47 % | `mixed`, `pulse`, `evader`, `fast` |
| Wall | Loses at 14 s, enemy on 89 % | `wall` |

**Counter:** a kit that spends everything on damage, and a wall.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 4 of 4 slots, 247.8 W. Thần thức not totalled, and curses have no lint |
| Validity | PASS | Upkeep 0.10 inside Combat's 0 to 0.10 |
| Stack | FAIL | Three forms, under the four the skill asks. A plain hunter by brief. `--without ward` changes the fight |
| Scaling | PASS | `m_static` 1.82 against 4.19. Below the anchor on purpose |
| The fight | PASS | No plug-in. The swap matches |
| Reuse | PASS | No new piece |
| NPC use | PASS | Any school elder |
| Counterplay | PASS | Wall, top-end, the damage kit |
| Originality | PASS | No name borrowed |

## Fight Results

Input: `sheets/long-answer.fight.json`, through `_tools/fight_x.py`. A paper model.

| Enemy | Gap | Result | Time | Enemy left |
|---|---|---|---|---|
| typical | 0 | Win on 65 % | 7 s | 0 |
| typical | 1 | Loss | 5 s | 91 % |
| top_end | 0 | Loss | 1 s | 99 % |
| top_end | 1 | Loss | 1 s | 100 % |

**For the user:** this file moves almost every damage point to defence, and that is what beats the kit. It wins because it knows what it is fighting. See `kit-hunt.md`.

## Also Considered

- **The Whole Purse:** four 0.25-cost arts at 1 s, spending the pool in one volley. In scratch it lost, or won narrowly and then lost every rematch.
- **The Early Word:** a curse at 2 s as the identity. It helps here (`early-word`), but on a common ward it changes nothing (`p-early-word`).
