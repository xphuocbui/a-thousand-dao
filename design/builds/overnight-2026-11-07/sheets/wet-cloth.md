# The Wet Cloth (Thấp Cân Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Kit hunter: beat Thin Shavings at equal W and realm with plain rows, 0 rule asks, a kit other than the cheap one.
> **Direction**: The drain ward is what the kit eats. A per-hit fee charges one small sum for each hit, however it was made, so the attacker's speed stops emptying your pool. No new piece.
> **Realm span**: Qi Refining – Deity Transformation, defined at Qi Refining · **Power level**: ordinary · **Use**: player build, or any bathhouse guard
> **Fit**: 4 Fits today · 4 Needs key · 0 Needs rule
> **Checks**: 7 PASS · 1 FAIL (Stack: three forms) · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** art hits and the fist, two body arts and one qi art, every 1 s.
- **The enabler:** none. The ward record does the work.
- **The loop:** pay about 3 % of the pool a hit, answer each second, and let the enemy's own ward run dry.
- **The engine:** on a common ward these rows are dry at 1 s. On Vinegar Cloth they never run dry. The kit's hits buy nothing but fees.
- **The sacrifice:** walls. It loses the Wall with 76 % of the bar left.
- **The arc:** the same cloth and the same 1 s cadence win at all three realms tested.

## The Legend

Thảo has run the steam rooms on Salt Street for thirty years and laughs at nearly everything, which the guests take for simplicity. One wet cloth, wrung once, takes off anything: soot, blood, a drunk magistrate's opinions. They charge one copper a towel, and if a guest brings forty small troubles that is forty coppers, and they are delighted.

The needle-sellers' apprentices came down the street to collect a debt, hitting fast, as they are taught. Thảo took each needle on the cloth, wrung it out, named the price aloud and flicked it back. They were still laughing when the third apprentice sat down. The street says nobody has ever been so glad to see trouble, or billed it so exactly.

## How It Fights

At 1 s the first answer lands, and Thin Shavings falls to 64 % with its pool on 42 %. At 2 s its pool is gone, spent on arts and on its own drain ward, and its bar is on 8 %. The fight ends at 3 s, with Thảo on 27 %.

**The signature moment:** the kit's pool reads 0 at 2 s while the cloth's still reads 35 %. **The line of play, One Copper a Towel:** cloth up, answer every second, spend nothing on speed.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Survival | **Vinegar Cloth** | Per-hit ward, pass 0.34 and 0.24, fee 0.04 | Rule swap | any | none | ○ | Ward | From The Held Door |
| Survival | Ward strength | +18.8: 9 acupoints, 1 notable | Increased | any | none | ● | Tree | every build |
| Survival | Ward efficiency | +17.2: 1 acupoint, 2 notables | Increased | any | none | ● | Tree | every per-hit ward |
| Survival | Maximum health | +28.5: 9 acupoints, 3 notables | Increased | any | none | ● | Tree | every build |
| Fuel | Regeneration | +0.15: 1 acupoint | Increased | any | none | ● | Tree | every build |
| Multiplier | Art damage | +12: 8 acupoints | Increased | art | L1 | ○ | Tree | every art build |
| Multiplier | Needles and mail | L3 114.4, kept from Thin Shavings | Gear | any | L3 | ● | Artifacts | Grindstone |

**Identity piece:** the ward. `--without ward` on `variants/wet-cloth-vs-thin-shavings.fight.json` loses at 1 s with the kit on 64 %.
**Empty rungs:** crit past the base, reach, L4, L5. All sacrifices.

**W:** 28 acupoints and 6 notables, 81.6 W, the counts Thin Shavings walks. L1 12 on arts, L2 20 from the method, L3 114.4.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any that holds the rows' ground | Rows read at full size, as the kit's are |
| Ward | Vinegar Cloth, `ws` 35.8, `we` 34.2 | |

## Arts

Cold Bucket twice (body, `c_art` 1.6, cost 0.05, 1 s) and Dry Click (qi, 1.48, 0.04, 1 s), unchanged from their sheets. Three of three slots, at twice the kit's cooldown.

## Matchups

Files are `variants/wet-cloth-[name].fight.json`, run with no flag.

| Enemy | Result | File |
|---|---|---|
| **Thin Shavings** | **Wins at 3 s on 27 %** | `vs-thin-shavings` |
| Thin Shavings opens | Wins at 3 s on 24 % | `swap` |
| Same rows, common ward | Loses at 1 s, kit on 64 % | `common` |
| The line on Vinegar Cloth | **Loses at 3 s, kit on 3 %** | `line-on-cloth` |
| The line on Verdict, on Stone | Wins at 3 s on overkill, both at 0 % | `line-on-verdict`, `line-on-stone` |
| The cheap art on these rows and this ward | Wins at 6 s on 6 % | `kit-on-my-rows` |
| Best kit a search found, W re-spent, on the Cloth | **Loses at 3.5 s, kit on 42 %** | `kit-answer` |
| A 1 s art on the Cloth against that kit | Wins at 4 s on 5 % | `second-answer` |
| Re-cut: Short Reply, Pine Rain | Wins at 3 s on 67 %, at 2 s on 76 % | `vs-short-reply`, `vs-pine-rain` |
| Mixed, Pulse, Evader, Fast | Wins at 3 s on 67 %, 3 s on 67 %, 4 s on 58 %, 3 s on 50 % | `mixed`, `pulse`, `evader`, `fast` |
| Wall | Loses at 10 s, enemy on 76 % | `wall` |

**Counter:** the kit in the same cloth, or a wall.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 3 of 3 slots, 81.6 W. Thần thức not totalled |
| Validity | PASS | Real realm. Fee 0.04 inside Combat's 0 to 0.10 |
| Stack | FAIL | Three forms, under the four the skill asks. A plain hunter by brief. `--without ward` changes the fight |
| Scaling | PASS | `m_static` 2.14 against 3.27. Below the anchor on purpose: the W is on defence |
| The fight | PASS | No plug-in. The swap agrees on the winner and the time |
| Reuse | PASS | No new piece |
| NPC use | PASS | Any guard with a cloth |
| Counterplay | PASS | Wall, top-end, the kit in the same cloth |
| Originality | PASS | No name borrowed |

## Fight Results

Input: `sheets/wet-cloth.fight.json`, through `_tools/fight_x.py`. A paper model.

| Enemy | Gap | Result | Time | Enemy left |
|---|---|---|---|---|
| typical | 0 | Win on 74 % | 3 s | 0 |
| typical | 1 | Loss | 3 s | 70 % |
| top_end | 0 | Loss | 1 s | 90 % |
| top_end | 1 | Loss | 1 s | 98 % |

**For the user:** this is the kit's best realm. It keeps one exact rematch, and a re-spent kit beats this file. See `kit-hunt.md`.

## Also Considered

- **The Early Coin:** a bigger art at 0.5 s on the common ward. It wins at 0.5 s on 71 % (`wet-cloth-burst`), but it keeps the kit's own cooldown, so it answers a different question.
- **The Quiet Lamp:** 4 s arts at this realm. Re-cut in `under-the-eaves-vs-thin-shavings`, it loses on overkill, both at 0 %.
