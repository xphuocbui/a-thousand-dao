# The Banked Well (Đê Tỉnh)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 2: Water's Soaking Line on Earth's Stone Ward, the two elements the wheel says fight, joined by a ward record and not by the tree. Upkeep at the legal 0.10.
> **Direction**: The seed said one key changes everything. It does not: that key alone still loses Pulse and Wall. The ward's real gift is that it lets you buy two more arts, so the Cold Line's arts join the Soaking Line's.
> **Realm span**: Core Formation – Deity Transformation, defined at Deity · **Power level**: strong · **Use**: player path
> **Fit**: 3 Fits today · 13 Needs key · 0 Needs rule · 0 new pieces
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a ward record)

## The Spine

- **The channel:** art hits on all five layers: two qi ladles, two body needles, every 1.5 s.
- **The enabler:** the Stone Ward (Thạch Hộ), a plain record of Combat rule 22's per-pulse model, at `upkeep_share` 0.10 and not the ledger's 0.125.
- **The loop:** the ward takes a fixed 4.7 % a pulse, whatever lands. Income is 8 %. Everything left over is arts.
- **The engine:** a drain ward spends the pool when you are hit, so a walker must keep some back. A Stone Ward never asks for more, so the whole pool can go on arts. Four arts spend 11.7 % a second against 3.3 % spare, about twelve seconds of full fire. Then they wait, and the ward stays up.
- **The sacrifice:** the sea. Maximum linh lực does nothing here, so its 12 nodes are sold. A closed gate on your income is then fatal.
- **The arc:** at Core the rows are short and the Wall wins. By Deity income reaches the cap and nothing on the panel outlasts it.

## The Legend

Lạc Tuyền is the proudest person ever to walk a Water road, and will tell you so before you have sat down. At their ward examination an Earth elder recited that Earth overcomes Water, and Lạc Tuyền laughed out loud in the hall. Every well in the world, they said, is Earth overcoming Water, and nobody has ever complained.

They lined their sea with stone that year. Sects send envoys to argue with them, and Lạc Tuyền loves this, feeds them well, and beats them while explaining what a bank is for.

## How It Fights

For a second and a half, nothing but the fist. Then four arts land in one instant, and again every 1.5 s. Against the Wall the pool runs down to 1 % by t = 12 and the arts begin to wait, but the upkeep is paid every pulse, and the Wall has no pool left either (`variants/banked-well-wall.fight.json --timeline`).

**The signature moment:** a Pulse enemy with its ward intact and 44 % of its pool dies at t = 5, with the Well on 34 % health and 56 % unspent (`banked-well-pulse`).

## The Stack

One Ladle's 110-node walk (Water sector, purity 50). Every row is reused. Three things change, and each is tested below.

| # | Row | Take | Total | Form | Layer | Status | Change from The One Ladle |
|---|---|---|---|---|---|---|---|
| 1 | Water damage (Thủy Thương) | 14 + 2 | +52 | Increased | L1 | ○ reused | Now on four arts |
| 2 | Qi damage (Khí Thương) | 10 + 1 | +25 | Increased | L1 | ○ reused | Ladles only |
| 3 | Thin Stream (Tế Lưu) | 8 + 2 | +40 | More | L2 | ○ reused | Ladles only: a needle costs 0.06 |
| 4 | Held Water (Tàng Thủy) | 6 + 2 | up to +36 | Per | L2 | ○ reused | |
| 5 | Spring Head (Tuyền Đầu) | 2 + 1 | +32 at 8 % | Per | L2 | ○ reused | Up from +20.8, because of row 8 |
| 6 | Wasting (Hao Tổn) | 0 + 1 | up to +20 | Per | L2 | ○ reused | |
| 7 | Unbroken Surface (Toàn Diện) | 6 + 2 | +36 | Conditional | L5 | ○ reused | On this ward it is off only in the last seconds of the Wall |
| 8 | Regeneration (Hồi Khí) | 14 + 4 | +6.1, clipped to +6 by the cap | Increased | none | ● | **+6 + 2 nodes** |
| 9 | Ward strength (Hộ Lực) | 13 + 3 | +39.6 | Increased | none | ● | **+3 + 1 nodes.** The Earth road's stat |
| 10 | Ward efficiency (Hộ Hiệu) | 10 + 2 | +28 | Increased | none | ● | |
| 11 | Water art cost (Tiết Thủy) | 6 + 1 | −12 % | Increased | none | ○ reused | |
| | Maximum linh lực (Linh Hải) | 0 + 0 | | | | ● | **Sold: all 12 nodes moved to rows 8 and 9** |

**Identity piece:** the Stone Ward. `--without ward` on `banked-well-pulse` loses at 3 s, enemy on 36 %; on `banked-well-wall`, at 6 s, enemy on 83 %.
**Empty rungs:** crit stays at the typical 15 %, a sacrifice. Regeneration sits on `regen_cap`, so more income buys nothing.

| Layer | Points at Deity | Multiplier | Sources |
|---|---|---|---|
| L1 | Ladles 77, needles 52 | ×1.77, ×1.52 | Rows 1, 2 |
| L2 | Ladles about 148, needles about 108 | ×2.5, ×2.1 | The Rule 40, rows 3 to 6, Held Water falling as Wasting rises |
| L3, L4 | 40, 20 | ×1.40, ×1.20 | The typical weapon and a pill. L4 is 0 in a blind fight |
| L5 | 36 | ×1.36 | Row 7 |
| M | | ladles about ×10 | Typical at Deity is ×8.96 |

## Foundation and Arts

Water, purity 50. Talents, Way and the rest of the tree as The One Ladle, with `n_qi` back at the typical 2.10. Four of 7 slots.

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Fit |
|---|---|---|---|---|---|---|
| First, Second Ladle (Sơ, Tái Chước) | One Ladle Rule | qi, Water, hit | 1.60 | 0.04 | 1.5 s | Reused |
| Cold Needle, Cold Rain (Hàn Châm, Hàn Vũ) | One Ladle Rule, the Cold Line's forms | body, Water, hit | 1.84 | 0.06 | 1.5 s | Reused |

**Stone Ward (Thạch Hộ):** per-pulse, common pass 0.54 and 0.36, `ws` 123.7, `we` 112.1, `upkeep_share` 0.10: 4.7 % a pulse.

## Matchups

The standard panel at the build's own realm. Each cell: result, time, own health. L gives the health the enemy kept. Files are `variants/banked-well-[name].fight.json`.

| | Mixed | Pulse | Wall | Evader | Fast | Won |
|---|---|---|---|---|---|---|
| **The Banked Well, Deity** (`mixed`, `pulse`, `wall`, `evader`, `fast`) | W 3 s, 57 % | W 5 s, 34 % | W 14 s, 22 % | W 4.5 s, 53 % | W 3 s, 48 % | **5** |
| The One Ladle, Deity (`ladle-*`) | W 4.5 s, 50 % | L 39 % | L 73 % | W 7.5 s, 27 % | L 84 % | 2 |
| **The Banked Well, Core**, 55 nodes (`core-*`) | W 3 s, 39 % | W 4.5 s, 23 % | L 76 % | W 4.5 s, 32 % | W 3 s, 26 % | **4** |
| The Long Firing, Core, 55 nodes, at the legal 0.10 (`firing-*`) | W 8 s, 15 % | W 10 s, 2 % | L 84 % | L 7 % | L 49 % | 2 |

The Core rows hold The Long Firing's base pools and ward points, with the Water rows at about half, so that line of parents meets the same enemies on the same body. **Neither parent beats the Fast enemy or the Wall. The hybrid beats Fast at both realms, and the Wall at Deity.**

**Which change did it?** At Deity, on the same rows.

| Change removed | File | Pulse | Wall | Fast |
|---|---|---|---|---|
| Two arts, not four | `two-ladles-*` | L 15 %, pool 83 % | L 19 %, pool 71 % | W 4.5 s, 24 % |
| Common drain ward, not Stone | `common-*` | L 15 %, pool 0 % | L 67 %, pool 0 % | W 4 s, 9 % |
| Keep Maximum linh lực too | `with-pool-wall` | | W 14 s, 22 %, pool 1 %: **no change at all** | |

Two arts on the Stone Ward die with the pool nearly full, which is the waste this build exists to spend. Four on a drain ward die with it empty. Neither half wins alone.

**The rival line, Four Ladles (`four-ladles-*`):** two more copies of the Ladle, kept off the build because they would be near copies. 5 of 5: W 3 s on 65 %, W 6 s on 15 %, W 9 s on 46 %, W 4.5 s on 53 %, W 3 s on 48 %. Better on the Wall, worse on Pulse.

**The honest control.** The One Ladle with only its ward swapped for Vinegar Cloth (Thố Cân Hộ, per-hit, pass 0.34 and 0.24) wins 5 of 5 with two arts (`ladle-vinegar-*`: Pulse 10 s on 16 %, Wall 18 s on 22 %). The same per-hit model at the common pass loses both (`ladle-perhit-common-pulse`, `-wall`: L 35 %, L 47 %). So the pass is what wins, not the model. The Well is faster in every cell, but it is not the only road, and that is Question 1.

**Counter, found by running it:**

- **A Wall with a Closed Gate (Bế Môn):** regeneration blocked, the income stops, the ward starves. Loses at 10 s, enemy on 76 % (`gate-wall`). The Long Drought does this on purpose.
- **Fast on a Stone Ward of their own:** loses at 3.5 s, enemy on 31 % (`stone-fast`). The Evader on one still loses, but the Well ends on 3 %, at 7.5 s (`stone-evader`).
- **Top-end:** dead at t = 1, as everyone is.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Method 2.0 of 4.0, arts at the lint's ceiling, 4 of 7 slots. Nothing prices a ward record |
| Validity | PASS | `upkeep_share` 0.10 is inside Combat's 0 to 0.10. Regeneration at `regen_cap`. The ledger's 0.125 is not used |
| Stack | PASS | Increased, More, Conditional, Per. L1 to L5 filled |
| Scaling | PASS | Ladles about ×10 against typical ×8.96. INFO: above typical |
| The fight | PASS | 5 of 5 at Deity, 4 of 5 at Core. No cap hit. `own_dry_at` never against `typical` |
| Reuse | PASS | 0 new pieces |
| NPC use | PASS | Ordinary rows and a ward record |
| Counterplay | PASS | A curse on regeneration, or a faster Stone Ward |
| Originality | PASS | No borrowed names |

**Matrix:** `sheets/banked-well.fight.json --matrix`: typical gaps 0 to 2 all win at 3 s, top-end loses at 1 s. **Unmodelled:** ward strength against one element, fortune, thought.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Stone Ward | Needs key | Its ledger row, with `upkeep_share` corrected to 0.10 |

## Questions

1. Vinegar Cloth's pass of 0.34 was a first guess, and it turns any ward fight around. Should per-hit wards carry the common pass?
2. Maximum linh lực is exactly worth nothing on a Stone Ward, because every cost is a share. Is a pool row meant to be a trap for a per-pulse ward?

## Also Considered

- **Sustained Note on the Stone Ward:** the critic's endless fight. Nothing on the panel lasts long enough to need it.
- **Crown's two regeneration notables by name:** the same effect as row 8, and they are due to be folded together.
