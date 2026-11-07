# The Clever Harm (Thông Họa Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The Scholar (seed 71): comprehension is the damage stat. Build on `daos/examination.md`, a build a player of that Way would really play, and prove a keystone in the fight."
> **Direction**: First on the List, proved against a same-W control at four realms. The numbers turned the plan over: the keystone is not a damage piece and the tree's story of being overtaken is half wrong. It is about 200 W handed back, and the player spends it on a body.
> **Realm span**: Foundation Establishment – Deity Transformation, defined at Foundation · **Power level**: strong · **Use**: player build, or the prodigy every sect sends to the capital
> **Fit**: 6 Fits today · 12 Needs key · 2 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled)

## The Spine

- **The channel:** art hits, all qi, at all five layers, with a fist behind them.
- **The enabler:** First on the List (Bảng Thủ), reused from the Way. Opens L1 as 2 × comprehension. Closes `attack_pct`, every Increased damage line, and 40 fortune.
- **The loop:** read, answer, keep answering. Cheap arts at 1 s and 2.5 s, one curse at 2 s, the Long Essay at 3 s if the fight lasts that long.
- **The engine:** L1's soft start is 200, and comprehension 100 reaches it for 0 W. So the best half of the attack stack is free at every realm, and all that W becomes health and ward.
- **The sacrifice:** fortune, for life. Fighting upward: one realm up it dies at 3 s. And a blind fight against a wall.
- **The arc:** at Foundation nobody near them can do the sum. At Deity they are 2 s slower than the people they looked down on, and in far better health than those people expected.

## The Legend

Liễu Thông sat the county paper at eleven and handed it in before the proctor had trimmed the lamp. They have been first on every list since, and they will tell you so. In the ninety years after, two ferries sank under them, three masters died in the week before adopting them, and a bridge fell on a chicken they had just paid for. Liễu Thông has published a proof that all of this is coincidence. The proof is very good. Proctor Ôn has read it, and returned it with two words in very small, very even characters: *see me.*

Every sect in the capital keeps a copy of their examination scripts and no sect will lend them a boat. They hold that talent is the only honest thing in the world and that luck is what stupid people call their excuses. They have never once changed their mind, about this or anything, and so far nothing has made them.

## How It Fights

Break the Topic lands at 1 s with Model Answer on it, and the first thing the enemy learns is that a Foundation disciple with no attack stat at all has taken a third of their bar. By 2.5 s it is over. Against a wall, the same kit becomes a siege: Set Question holds the curse up, Single Grudge reads it, and the Long Essay does 37 % of the work.

**The signature moment:** `first_on_list` removed from the wall fight, nothing else changed: dead at 13 s with the enemy on 87 %. Put it back: wins at 11 s (`variants/clever-harm-wall.fight.json`, with and without `--without first_on_list`).

**The surprise:** Already Read, the row meant as the strange one, moved little. The fights end before anyone repeats themselves. The largest thing on the sheet is an old row from a curse build.

## Enabler

**First on the List (Bảng Thủ)**, exactly as `daos/examination.md` states it, through `rules/first_on_list.py`. Comprehension 101.8 gives x1 203.6, ×3.02. Earned at a Foundation glimpse with 15 nodes, 45 points, about 93 W of acupoints not bought.

## The Stack

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Long Essay (Trường Sách) | c_art 2.7, cost 0.10, 3 s: on the lint | Art | art | none | ◐ | Way | Reused from the tree |
| Multiplier | **First on the List (Bảng Thủ)** | L1 is 2 × comprehension and nothing else | Rule swap | any | L1 | ◐ | Way keystone | Reused from the tree |
| Multiplier | Clear Reading (Minh Duyệt) | +1.2 per point of comprehension above 50: +62 | Per | art | L2 | ◐ | Way | Reused from the tree |
| Multiplier | Well-Thumbed (Thục Độc) | +2 to main technique arts per layer: +18 at 9 | Per | art | L2 | ◐ | Way | Reused from the tree |
| Multiplier | Single Grudge (Độc Oán) | +12 while the target bears exactly one curse | More | art | L2 | ○ | Tree | **Reused from The One Long Word, unplanned** |
| Multiplier | Gear, pill | L3 40, L4 20 | Gear | any | L3, L4 | ● | Items | every build |
| Multiplier | Past Papers (Cựu Đề) | In a foreseen fight, +1 per 2 points of comprehension lead, to +30 | Per | any | L4 | ○ | Cluster | any build that studies a target |
| Multiplier | Commentary (Chú Giải) | +8 per different enemy art seen, to +40 | Per | art | L5 | ◐ | Way | Reused from the tree |
| Multiplier | Model Answer (Phạm Văn) | First art fired: +1 per point of lead, to +60: +56.8 | Conditional | art | L5 | ◐ | Way | Reused from the tree |
| Reach | Set Question (Xuất Đề) | Curse, 3 pulses: target loses L2 equal to half your lead, to −30 | Curse | art | none | ◐ | Way | Reused from the tree |
| Survival | Already Read (Dĩ Duyệt) | A hit from an art that has fired before this fight is cut by half your lead, as a percentage, to 30 % | Conditional | incoming | none | ○ | Cluster | any build reading a talent against the enemy |
| Survival | Health, pool, ward rows | `n_body` 1.42, `n_qi` 1.25, `ws` 55, `we` 20, guard +15 %, +1 % regeneration | Increased | any | none | ● | Tree | every build |
| Price | Clever Harm (Thông Họa) | −1 fortune per point above 50, to −40 | Trade | any | none | ◐ | Way keystone | Reused from the tree |

**Identity piece:** First on the List. `--without first_on_list` on `-wall` loses on 87 %, on `-mixed` wins at 5 s, not 2.5 s, on 63 % health, not 86 %.
**Empty rungs:** crit, a sacrifice: no row on any road tonight has earned it. Past the cap: L1 past 200 pays half, so comprehension past 100 buys L2 instead, a slow rung and not a gap.

| Layer | Points at Foundation | Multiplier | Sources |
|---|---|---|---|
| L1 | 203.6 | ×3.02 | First on the List. The file's `m_static` 1.68 is printed before the plug-in runs; with L1 and Clear Reading it is about 8.2 against a typical 4.19 |
| L2 | 62 to 92 | ×1.62 to ×1.92 | Clear Reading, Well-Thumbed on method arts, Single Grudge with the curse up |
| L3 | 40 | ×1.40 | Typical weapon |
| L4 | 20 | ×1.20 | Pill. 48 with Past Papers. 0 blind |
| L5 | 0 to 81 | up to ×1.81 | Model Answer once, Commentary as they show their arts |

**W:** Foundation has 248. The Way costs about 93. Of 155 left: health 50, linh lực 25, ward strength 30 over gear 25, efficiency 20, guard 15, regeneration 8. 7 over. None on attack.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root | Any. The Way asks for no element | The fight reads no root |
| Key talents | Comprehension 95 at birth, +6.8 on the Way: 101.8 | Self-made birth, or a rare Fated roll |
| The Way | Examination: The Classics whole, The Paper whole, Posted List 1, First on the List | 15 nodes. Listed Name is 5 nodes further, and at Foundation those 31 W are worth more as a body |

## Công Pháp

### Eight-Legged Method (Bát Cổ Công) — main, Huyền giai

The form every candidate memorises and no candidate has ever enjoyed.

```json
{"id": "bat_co_cong", "name": "Bát Cổ Công", "tier": 1, "tech_kind": "main", "names": ["kim"], "layers": 9,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "pha_de", "unlock_layer": 1}, {"ability_id": "thua_de", "unlock_layer": 4}],
 "seal_clusters": ["hao_xa_mach"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 12/20 + 10/15 = 1.27 of 2.0. `max_realm` Core, so a later life needs a higher method.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Break the Topic (Phá Đề) | Method, 1 | qi, art | 1.45 | 0.04 | 1 s | none | Needs key |
| Set Question (Xuất Đề) | Way | no hit, curse | 0 | 0.04 | 2 s | none | Needs key |
| Receive the Topic (Thừa Đề) | Method, 4 | qi, art | 1.95 | 0.05 | 2.5 s | none | Needs key |
| Long Essay (Trường Sách) | Way | qi, art | 2.7 | 0.10 | 3 s | none | Needs key |

Slot order as above, 4 of 4. **Break the Topic, description:** the opening line, which says that the question is simpler than the questioner thinks.

## Tree and Clusters

### Hidden cluster idea: Examination Cells (Hào Xá Mạch)

Theme comprehension and study, no element, inner, sealed by a technique that lists it. Size 6. Small acupoints: comprehension, heart demon resistance. Notables: Past Papers, Already Read. No capability. Any scholar's route to a lead, and a thể tu will never want it.

## Matchups

Panel enemies, at Foundation, each file `variants/clever-harm-[enemy].fight.json`.

| Enemy | Result | Why |
|---|---|---|
| Mixed | Wins 2.5 s on 86 % | Model Answer, then Receive the Topic |
| Pulse | Wins 3 s on 75 %, enemy pool 54 % | Full-size hits through a ward it cannot empty |
| Wall | Wins 11 s on 41 %, pool 0 | The only long fight, and close |
| Evader | Wins 3 s on 83 % | Clever Harm gives the enemy 4 points of evade and costs 1 point of health (`--without fortune`) |
| Fast | Wins 2 s on 70 %, pool 9 % | Kills first. Already Read is worth 11 points of health here |
| Cheap single art (`-cheap`) | Wins 2.5 s on 87 % | Commentary pays once |
| Rival scholar, comprehension 101.8 (`-rival`, `-rival-wall`) | Mixed wins 2.5 s on 83 %. Wall **loses**, enemy on 36 % | A lead of 0 turns off Model Answer, Set Question and Already Read |
| Foreseen wall, away from home (`-foreseen-wall`) | Wins 6 s on 75 % | Past Papers at +28. Study halves the fight |
| Blind wall (`-blind-wall`) | **Loses**, enemy on 42 % | No L4, no siege. Blind Mixed still wins at 2.5 s |
| One realm up (`-mixed --gap 1`) | **Loses** at 3 s, enemy on 82 % | The prodigy's limit |
| Top-end | **Loses** at t = 1 | Normal |

**Counter:** an equal mind behind a heavy ward, met without warning. Or anyone a realm up.

## The Proof

Same realm, same comprehension, same kit, same gear, same W. The control has no keystone, and puts 25 % or 45 % of its W on attack, the typical and top-end shares. Cells are the time, or the loss with the enemy's health, and own health at the end. Prefix `variants/clever-harm-`. Foundation is `pulse`, `wall`, `control25-*`, `control45-*`. Others are `[realm]-*`, `[realm]-control-*`, `[realm]-control45-*`.

| Realm | Keystone, Pulse | 25 %, Pulse | 45 %, Pulse | Keystone, Wall | 25 %, Wall | 45 %, Wall |
|---|---|---|---|---|---|---|
| Foundation | 3 s, 75 % | L on 6 % | 3 s, 52 % | 11 s, 41 % | L on 81 % | L on 77 % |
| Core | 3 s, 83 % | L on 2 % | 3 s, 56 % | 10 s, 61 % | L on 78 % | L on 74 % |
| Nascent Soul | 5 s, 84 % | 6 s, 26 % | 4 s, 43 % | 11 s, 73 % | 15 s, 2 % | 12 s, 1 % |
| Deity | 6 s, 89 % | 6 s, 64 % | 5 s, 54 % | 12 s, 86 % | 13 s, 73 % | 10 s, 57 % |

**The tree says the keystone peaks early and is overtaken. In this table it is overtaken only in speed, only at the last two realms, by 1 or 2 seconds, and it ends every fight in better health.** No control beats it on health anywhere. Kit and gear are held fixed so that only the keystone moves.

**At the mean:** comprehension 45 (`-median`, `-median-wall`) still wins Mixed at 3 s on 59 %, and loses the wall on 84 %. The keystone needs the talent, as written.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts inside the lint, 4 of 4 slots, method 1.27 of 2.0. Thần thức not totalled |
| Validity | PASS | Huyền giai reaches Core. Keys real. 15 Way nodes meet dao.md rule 8: one whole branch, a node in each other |
| Stack | PASS | Six forms. The identity run changes both fights. Pair removed together: Set Question with Single Grudge, loses on 5 % (`-no-question-pair-wall`) |
| Scaling | PASS | About 8.2 against a typical 4.19. INFO: above typical, and not pulled back |
| The fight | PASS | 60 of 60 constants. No cap hit. Plug-ins `first_on_list`, `the_paper`, `fortune`, `per_cap` |
| Reuse | PASS | 9 pieces reused. Single Grudge, used unplanned, decides the wall: without it, lost on 4 % (`-no-grudge-wall`) |
| NPC use | PASS | Each row is one Breakdown line. Rule 11 gives NPCs a multiplier, not a tree, so an NPC prodigy reads as a high `comp_strength` |
| Counterplay | PASS | Rival mind and a ward, a realm up, or a top-end |
| Originality | PASS | The eight-legged form and its part names are history, not any work |

## Fight Results

Input: `sheets/clever-harm.fight.json`. `fight_x.py`, a paper model with expected values, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Wins, 83 % | 2 s | never | none |
| typical | 1, 2 | Loses, enemy on 82 %, 98 % | 3 s, 1 s | | none |
| top_end | 0, 1, 2 | Loses | 1 s | | none |

**Second realm:** Deity, the table above. **Unmodelled:** Clever Harm's fortune outside the fight: event checks, reward ceilings, alchemy crits. That is its real price.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Already Read | Needs rule | Combat Formulas C: an incoming term that reads an art's firing count. `rules/the_paper.py` |
| First on the List | Needs rule | The tree's ask 2. `rules/first_on_list.py` |
| Past Papers, arts, method, cluster | Needs key | Records. A compiled `ngo_tinh` on each side |

## Questions

1. **Is First on the List priced?** The lint gives it 34 W, as a guess. Against 25 % of W on attack it saves 62 W at Foundation and 293 W at Deity. Because L1 past 200 pays half, it is really "about 200 W back, at any realm", and that is why it never truly falls behind. If that is too much, a lower L1 per point is one number. If the prodigy is meant to be overtaken, Clear Reading's +120 is the second number to look at.
2. Should a Foundation character reach a keystone? Rule 8 allows it at 27 points. This build does it at 45.

## Also Considered

- **The Reader:** all free W on comprehension at 5 W a point. Past 100 the soft start halves L1, so it buys less than a body does. Rejected on arithmetic, not run.
- **Beyond the Syllabus:** pierce per point of lead, to fight upward. +28 pierce moved the Core enemy from 82 % to 81 % (`-up-pierce-mixed --gap 1`). Cut.
