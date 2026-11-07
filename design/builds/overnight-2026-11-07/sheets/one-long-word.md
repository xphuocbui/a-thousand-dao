# The One Long Word (Nhất Ngôn Chú)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 1, the Plain Stack for Curses: "the game, much like poe, is stacking modifiers on a concept."
> **Direction**: One heavy curse kept on the target, against three light ones. 20 ordinary nodes, no enabler, no keystone, no plug-in.
> **Realm span**: Foundation Establishment – Core Formation, defined at Foundation Establishment · **Power level**: ordinary · **Use**: player build, or any NPC curser
> **Fit**: 0 Fits today · 27 Needs key · 0 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, and curses have no lint)

## The Spine

- **The channel:** art hits, through the ward, plus the basic attack. The curse deals nothing by itself (Combat rule 8).
- **The enabler:** none.
- **The loop:** speak one curse, keep it standing, and hit while the enemy's linh lực runs out.
- **The engine:** the curse nearly empties the enemy's pool by t = 5, and the reward rows switch on as it falls. Rows that are off at the start are all on for the last volleys.
- **The sacrifice:** attack. Nearly all of the tree outside the path goes to ward and pools, so a blind fight is lost.
- **The arc:** at Foundation Establishment it scrapes a win. At Core Formation the same path has a bigger body under it and wins with room to spare.

## The Legend

In the hill schools of the north, a student of the Plain Speech Method takes one vow before any other: say a hard thing only if you will still mean it tomorrow. Most of what they learn is silence. They sit with the person they have wronged, or who wronged them, and they practise until a sentence can be held in the chest without turning sour.

A teacher of that school once stood in a burned village and said four words to the officer who had ordered it. Nobody remembers the words. People remember that the officer's strength went out of them slowly, over a long afternoon, and that the teacher stayed and kept saying it, quietly, without anger, because they had promised the dead they would not stop. Students still walk to that place in their first year, and most come home wanting to be kinder.

## How It Fights

For three seconds it looks like losing. Then the Word lands: every art the enemy owns costs 42 % more, its ward burns 42 % faster, and its linh lực stops coming back. By t = 5 it has 5 % left.

**The signature moment:** at t = 6 both cultivators are nearly spent. The enemy reaches for one more jab and cannot pay for it. Its health falls from 61 % to 13 % in that one volley (`variants/one-long-word-mixed.fight.json`, `--timeline`).

## The Stack

This is the node list: 30 nodes, 24 small and 6 notable, on one road. All are tree nodes, status ○, tag-scoped to `curse` or to the target's state, so any curse build can walk them. Sizes follow the catalogue's Status, tag and Conditional rows. "Each" is one node, and "Total" is what the build takes.

### The shared road (any curse build, 22 nodes)

| # | Node | Size | Taken | Each | Total | Form | Layer | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 | Lingering Word (Dư Ngôn) | acupoint | 3 | +2.5 % curse duration | +7.5 % | Increased | none | Stand-In |
| 2 | Slow to Lift (Nan Giải) | notable | 1 | +15 % curse duration | +15 % | Increased | none | Incense Vigil |
| 3 | Sharpened Word (Lợi Ngôn) | acupoint | 3 | +2 % curse strength, inside Combat's bounds | +6 % | Increased | none | Thousand Scales |
| 4 | Full Weight (Toàn Trọng) | notable | 1 | +12 % curse strength, inside Combat's bounds | +12 % | Increased | none | Herd-Child |
| 5 | Quick Tongue (Tấn Thiệt) | acupoint | 3 | +1 % curse art speed | +3 % | Increased | none | Not-Yet-Full |
| 6 | Between Breaths (Tức Gian) | notable | 1 | +6 % curse art speed | +6 % | Increased | none | Lucky Fool |
| 7 | Thrifty Word (Tiết Ngôn) | acupoint | 3 | −1 % curse art cost | −3 % | Increased | none | Incense Vigil |
| 8 | Marked Target (Tiêu Ký) | acupoint | 3 | +1 art damage per curse on the target | +3 per curse | Per | L1 | Stand-In |
| 9 | Bare Vessel (Lộ Đỉnh), reused | acupoint | 2 | +2.5 hit damage while the enemy has under 5 % linh lực | +5 | Conditional | L5 | any ward-breaker |
| 10 | Thinning Ward (Bạc Hộ) | acupoint | 2 | +2 art damage while the enemy has under 50 % linh lực | +4 | Conditional | L1 | Deepest Well |

### The Long line (8 nodes): one curse, kept

| # | Node | Size | Taken | Each | Total | Form | Layer | Second home |
|---|---|---|---|---|---|---|---|---|
| 11 | Single Grudge (Độc Oán) | notable | 1 | +12 art damage while the target bears exactly one curse | +12 | More | L2 | any one-curse build |
| 12 | Set Jaw (Giảo Nha) | acupoint | 3 | +2 art damage while the target bears exactly one curse | +6 | More | L2 | any one-curse build |
| 13 | One Thought (Nhất Niệm) | acupoint | 2 | +2.5 % strength of a curse on an art with a cooldown of 3 s or more | +5 % | Increased | none | any slow curse art |
| 14 | Long Memory (Trường Ký) | notable | 1 | +15 % curse duration | +15 % | Increased | none | Incense Vigil |
| 15 | Unbroken Sentence (Bất Đoạn) | notable | 1 | +10 art damage while the enemy has under 50 % linh lực | +10 | Conditional | L5 | any starver |

### The Light line (8 nodes): three small curses, the rival

| # | Node | Size | Taken | Each | Total | Form | Layer | Second home |
|---|---|---|---|---|---|---|---|---|
| 16 | Many Small Ills (Bách Tiểu Tật) | notable | 1 | +5 art damage per curse on the target | +15 at three | Per | L2 | Stand-In |
| 17 | Nibbling Word (Thực Ngôn) | acupoint | 2 | +1 art damage per curse on the target | +6 at three | Per | L2 | any three-curse build |
| 18 | Crowded Sky (Mãn Thiên) | notable | 1 | +3 art damage per curse on the target | +9 at three | Per | L5 | any hit-and-curse build |
| 19 | Small Word (Tiểu Ngôn) | acupoint | 3 | +2.5 % strength of a curse on an art costing 5 % or less | +7.5 % | Increased | none | any cheap curse art |
| 20 | Hurrying Word (Cấp Ngôn) | notable | 1 | +6 % curse art speed | +6 % | Increased | none | any curse build |

**Why a player cannot have both.** A second curse switches off Single Grudge and Set Jaw. Three curses take three of Foundation's four slots. Nodes 16 to 18 pay three times over for what a lone curse is paid once.

**What the road adds up to on Standing Word:** duration 3 to 4 pulses (+37.5 %, rounded), strength 0.34 to 0.418 (+23 %), cooldown 3.8 to 3.486 s, cost 0.08 to 0.0776.

**Identity piece:** Standing Word, the art the road serves. Removing it (`--without standing_word` on `-mixed`) loses at 6 s with the enemy on 53 %. Removing only its curse loses at 6 s on 39 % (`-no-word`). No single node is an identity, on purpose.

**Empty rungs:** crit and past-the-cap are sacrifices. Strength stops at 0.418, under the 0.5 bound, so nothing is clipped.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 5, up to 12 | ×1.05 to ×1.12 | `attack_pct` 5, Marked Target, Thinning Ward |
| L2 | 10, up to 28 | ×1.10 to ×1.28 | Plain Speech "more", Single Grudge, Set Jaw |
| L3 | 30 | ×1.30 | Weapon. Below a typical 40, since the gear budget favours the ward |
| L4 | 20 | ×1.20 | A pill, foreseen fights only |
| L5 | 0, up to 15 | ×1.00 to ×1.15 | Unbroken Sentence, Bare Vessel |

Static M is 1.80. With every row on it is 2.57, so the road multiplies damage by 1.43, and only after the curse has done its work.

## The Removal Test

The fight is `variants/one-long-word-mixed.fight.json`: equal realm, mixed enemy. It wins at 7 s on 10 % health, with the enemy on 13 % at t = 6 (`--timeline`). Each row below is the whole row removed, all its nodes, recompiled and saved as `variants/one-long-word-[name].fight.json`.

**Remove any one: 15 of 15 still win.**

| Removed (`no-…`) | Result | Own health | Enemy at t = 6 |
|---|---|---|---|
| `lingering`, `slow-lift`, `long-mem` (each alone) | 7 s | 10 % | 13 % |
| `sharpened`, `one-thought` | 7 s | 10 % | 15 % |
| `full-weight`, `bared` | 7 s | 10 % | 16 % |
| `marked`, `thin` | 7 s | 10 % | 17 % |
| `set-jaw` | 7 s | 10 % | 18 % |
| `grudge`, `unbroken` | 7 s | 10 % | 22 % |
| `thrift` | 7 s | 9 % | 13 % |
| `quick`, `breath` | 8 s | 16 % | 13 % |

The duration rows move nothing alone because rounding gives them slack, and they work as a family (below). Losing a speed row delays the second Word past t = 7, which saves the linh lực the last of the ward needed, so the win is later and healthier.

**Remove five: 10 of 12 saved sets lose.**

| Set (`five-…`) | Rows removed | Result |
|---|---|---|
| `quietest` | The five rows that changed nothing alone: 1, 2, 14, 5, 6 | **Lost** at 10 s, enemy on 4 % |
| `reward` | 8, 9, 10, 11, 12 | **Lost** at 8 s, enemy on 9 % |
| `small` | Five acupoint rows: 7, 1, 5, 9, 8 | **Lost** at 10 s, enemy under 1 % |
| `r1` | 2, 4, 7, 12, 15 | **Lost** at 8 s, enemy on 3 % |
| `r2` | 1, 4, 8, 9, 12 | **Lost** at 8 s, enemy on 1 % |
| `r3` | 2, 7, 9, 11, 13 | **Lost** at 8 s, enemy on 2 % |
| `r4` | 5, 7, 10, 12, 14 | **Lost** at 10 s, enemy under 1 % |
| `r5` | 1, 2, 6, 12, 14 | **Lost** at 8 s, enemy on 7 % |
| `r7` | 3, 9, 12, 14, 15 | **Lost** at 8 s, enemy on 5 % |
| `r8` | 1, 3, 5, 14, 15 | **Lost** at 8 s, enemy on 13 % |
| `strength-speed` | 3, 4, 13, 5, 6 | Won at 7 s on 7 % |
| `r6` | 1, 3, 4, 6, 7 | Won at 9 s on 7 % |

`r1` to `r8` were drawn by a seeded sample, not chosen. Both survivors remove rows 3 and 4, which is explained below.

**By family.**

| Family removed (`family-…`) | Result | Enemy at t = 6 |
|---|---|---|
| `duration` (1, 2, 14) | 7 s on 10 % | 24 % |
| `speed` (5, 6) | 8 s on 16 % | 13 % |
| `strength` (3, 4, 13) | 7 s on 7 % | 8 % |
| `reward` (8 to 12, 15) | **Lost** at 8 s, enemy on 15 % | 28 % |
| The whole road (`no-path`) | **Lost** at 6 s, enemy on 23 % | 23 % |

**One thing a player would not guess.** Curse strength is not always good. At 0.34 the enemy can still afford a jab at t = 6, and that spends linh lực its ward needed. At 0.418 it cannot, so the pool stays in the ward. This is why removing all three strength rows leaves the enemy lower at t = 6, at the price of 3 points of your own health.

**How much the test depends on sizing.** The build is deliberately close: its tree goes to the ward, so a fair fight is won by a little. A build with more attack would pass the single test and fail the five test by winning anyway.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any. Nothing here reads an element | The road is tagged by `curse`, so it fits any root |
| Key talents | None required | An ordinary life can walk it |
| The Way (Đạo) | None | Curses need a tree path, not a Way |
| Tree outside the road | 171 W: linh lực +35 %, health +35 %, ward strength +44, ward efficiency +44, attack +5 | With the road's 76.8 W, this is the 248 W anchor at Foundation |

## Công Pháp

### Plain Speech Method (Trực Ngôn Công) — main, Huyền giai

Say it once, and mean it.

```json
{"id": "truc_ngon_cong", "name": "Trực Ngôn Công", "tier": 1, "tech_kind": "main", "names": [], "layers": 9,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "standing_word", "unlock_layer": 3}], "seal_clusters": [], "origin": "authored"}
```

Also carries +10 L2 on the method's arts.

**Fit:** Needs key · **Budget:** 20/20 + 15/15 = 2.0 against Huyền's 2.0. `max_realm` is `ket_dan`, which reaches the span.

## Arts

| Art | Source | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Standing Word (Trụ Ngôn) | Method | qi, curse | 2.0 | 0.08 | 3.8 s | none | Needs key |
| Plain Reproach (Trực Trách) | Method | body | 1.9 | 0.04 | 3 s | none | Needs key |
| Level Gaze (Bình Thị) | Method | qi | 1.9 | 0.04 | 3 s | none | Needs key |
| Closing Sentence (Kết Ngữ) | Method | qi | 2.47 | 0.06 | 4 s | none | Needs key |
| Small Complaint (Tiểu Oán), Light line | Method | qi, curse | 1.4 | 0.04 | 2.5 s | none | Needs key |
| Thin Skin (Bạc Bì), Light line | Method | body, curse | 1.4 | 0.04 | 2.5 s | none | Needs key |
| Grudging Hand (Lận Thủ), Light line | Method | qi, curse | 1.4 | 0.04 | 2.5 s | none | Needs key |

**Standing Word. Effect:** a hit, then a curse for 3 pulses: art cost +34 %, ward drain +34 %, regeneration blocked. **Description:** it is not loud, and they hear it anyway.

**Light curses, 2 pulses each.** Small Complaint: ward pass +24 %. Thin Skin: shred 0.24. Grudging Hand: art cost +20 %. **Description:** three small truths, told in turn.

A hit that carries a curse is set at about 80 % of its art lint as a first guess, because nothing prices a curse.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Standing Word, Plain Reproach, Level Gaze, Closing Sentence | Common drain, 84 / 84 | The Word goes first, so its curse is on before any later hit in the same instant |
| Core Formation | 5 | Adds Second Sentence: body, c_art 2.45, 0.06, 4 s | Common drain, 114 / 114 | One more hit, and 175 of the 199 W gained |

## Items

| Item | Type, role | What it does for the build | Fit |
|---|---|---|---|
| Any weapon | Artifact, weapon | L3 30 | Fits today |
| Any ward piece | Artifact, ward | 40 of the ward's strength and efficiency | Fits today |
| Any attack pill | Pill | L4 20. Without it the fight is lost (`-blind`) | Fits today |

## Tree and Clusters

No keystone and no cluster. For the rework, nodes 1 to 10 lie on one road with a fork at its end, the Long line on one side and the Light line on the other, far enough apart that 30 nodes reach only one. Keys needed are `curse_duration_pct`, `curse_effect_pct`, and the catalogue's "any one tag" speed and cost shape.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A narrow win over an equal, and only foreseen | The whole road | The first time they mean it |
| Core Formation | A clear win: 6 s on 35 % (`-core-mixed`) | One more slot, a larger tree under the road | They find they could stop, and do not |

## Matchups

Each file is `variants/one-long-word-[name].fight.json`. The Light line has the same 30-node budget and the same 171 W outside the road, with attack +39 and a thinner ward (70 / 70), three curse arts and Closing Sentence.

| Enemy | Long line | Light line | Why |
|---|---|---|---|
| Mixed, equal realm | Wins at 7 s on 10 % (`mixed`) | Wins at 6.5 s on 25 % (`light-mixed`) | Light is on by t = 2.2 and hits more often |
| One cheap art | Wins at 6.97 s on 27 % (`jab`) | Wins at 6.5 s on 25 % (`light-jab`) | Even |
| Per-hit ward, one strike | Loses at 9 s, enemy on 16 % (`perhit`) | Wins at 7 s on 43 % (`light-perhit`) | Drain does nothing to a per-hit ward; pass and shred do |
| Bulwark: three times the pools, one cheap jab | Wins at 24 s on 7 % (`bulwark`) | Loses at 18 s, enemy on 16 % (`light-bulwark`) | Blocked regeneration and low upkeep win a long fight |
| Blind, mixed | Loses at 8 s, enemy on 23 % (`blind`) | Loses at 7 s, enemy on 27 % (`light-blind`) | L4 is gone, and neither line has slack |

**The choice:** Light is better in the ordinary fight, and it answers a per-hit ward. Long is the only one of the two that outlasts a big pool. This build takes Long because a cultivator can leave a fast fight and cannot leave a siege, and a player who disagrees has a fair case.

**Counter:** a per-hit or per-pulse ward, since drain does nothing to it. One realm up it dies at 2 s with the enemy on 98 %, before the Word is spoken.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Method 2.0 of 2.0, arts within lint, 4 of 4 slots, tree 247.8 W of 248. Thần thức is not totalled, and curses have no lint |
| Validity | PASS | Real tier and realm. Curse values inside Formulas F, duration 4 of 5 |
| Stack | PASS | 15 rows in four forms: Increased, More, Conditional, Per. Layers stated. `--without standing_word` changes the fight |
| Scaling | PASS | M 1.80 static, 2.57 peak, against a typical 4.19. Stated power is ordinary |
| The fight | PASS | In `-mixed` the Word fires twice, and every row moves the fight alone or with its family. No `cap_hit` lines |
| Reuse | PASS | Bare Vessel reused. 19 new nodes, each scoped by tag with a second home |
| NPC use | PASS | All are plain stat rows a generator can pick, and each reads as one Breakdown line |
| Counterplay | PASS | Per-hit ward, one realm up, a blind fight |
| Originality | PASS | Names checked against the ledger. Nothing from existing works |

## Fight Results

Input: `sheets/one-long-word.fight.json`. Observations from `fight_x.py`, a paper model with expected values for chance. No plug-in is used.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| Typical fixture | 0 | Win, 29 % | 6 s | never | none |
| Typical fixture | 1 | Lost, enemy on 98 % | 2 s | never | none |
| Typical fixture | 2 | Lost, enemy on 100 % | 1 s | 1 s | none |
| Top-end | 0 to 2 | Lost, enemy on 99 to 100 % | 1 s | 1 s | none |
| Mixed (`-mixed`) | 0 | Win, 10 % | 7 s | 7 s | none |

The fixture bankrupts itself, so it proves little: `--without standing_word` still wins there, at 8 s on 18 %. The mixed fight is the proof.

**Unmodelled:** listed in the fight file. Recasting while a curse stands would count twice in the calculator, and here the second Word comes 0.028 s before the first ends, with no other hit in that gap. Enemy status resistance and cleanse are not run, and curses land at 100 %.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| `curse_duration_pct`, `curse_effect_pct` | Needs key | Duration rounds to the nearest pulse. Strength stops at Combat's bounds |
| Curse art speed, curse art cost | Needs key | The catalogue's tag-keyed shape |
| "Exactly one curse", "per curse", "enemy under X % linh lực" | Needs key | Condition reads on existing state |
| Plain Speech Method, 7 arts | Needs key | Content, including a `curse` tag on arts |

**Question for the user:** does a curse recast on itself refresh or stack? Rule 7 offers both, and duration nodes depend on the answer.

## Also Considered

- Three light curses as the main build. It wins the ordinary fight by more, and is kept here as the rival line.
- A curse carried on a talisman, cast once with a long duration. It leaned on stock, not on the tree.
