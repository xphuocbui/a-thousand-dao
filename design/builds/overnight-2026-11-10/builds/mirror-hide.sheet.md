# The Mirror Hide (Kính Bì)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: Retaliation: damage taken becomes damage dealt. Block and guard high, every hit that lands on you returns. A thorns build that wants the enemy to hit it, and has to handle enemies that refuse to (ticks, soul, waiting).
> **Direction**: A. The Mirror Hide (Kính Bì): a new Return channel carried by a body armour (see Directions considered).
> **Realm span**: Foundation (Trúc Cơ) to Nascent Soul (Nguyên Anh) · **Power level**: top-end · **Use**: player · **Spiritual root**: Earth-Metal (Thổ-Kim)
> **Fit**: 6 Fits today · 14 Needs key · 11 Needs rule (pieces on this sheet; reused pieces count where they are used)
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: technique bonus keys are combat keys outside `bonus_pool`, so the budget cannot be computed; The fight: the engine, the Return channel, is a new rule the simulator cannot express, so only a stand-in art was run)

## Directions considered

Chosen: **A. The Mirror Hide (Kính Bì)**. Body armour opens a Return channel: a share of every hit's damage, blocked or taken, comes back as a Physical free hit. It is the only direction where "damage taken becomes damage dealt" is literally true, it fills the layers the build already stacks (block, body layers, health regen), and it needs one new channel plus answers instead of a pile of new rules.

- **B. The Karmic Ledger (Nhân Quả Sổ Nợ).** Every point you take is written as a debt in a pool and called due by one huge art. Rejected: it is a burst-all-in build, which sustain-is-king makes rare, and the pool is just the held-payload idea with no reason to be hit often.
- **C. The Spite Bell (Oán Chung).** A curse makes the enemy deal damage to itself whenever it casts, so being hit does not matter. Rejected: it wants the enemy to cast, not to hit you, which drops the seed's core (guard high, be hit) and is a curse build.

## The Spine

- **The channel:** Return hits (new free-hit channel, Physical, tag `return`). Each hit or tick that reaches your defence path returns a share of its pre-defence damage as a free hit on the attacker. It meets the enemy's evade, resistance, block and shields like any hit, uses L1 to L4 (L5 empty), cannot crit, and is capped per hit.
- **The enabler:** Mirror-Scale Hide (Kính Lân Giáp), a named body armour. Opens the Return channel at 30 % of the incoming damage, counting what block and shields stop. Closes: you can never use a ward and you cannot evade (evade chance is 0), so you have no way to refuse a hit.
- **The loop:** Stand behind block and body layers, apply Earth and Metal stacks so the enemy's hits weigh more, absorb each hit, return it. Heal between.
- **The engine:** Block and body layers make hits survivable while Return counts the prevented part too: the more you stop, the more you send back. Defence is the offence. Metal stacks on the enemy raise Physical taken, which makes their hits bigger on the way in and your return bigger on the way out.
- **The sacrifice:** No ward (so linh lực is only for arts), no evade, no burst and no L5. It never wins against an enemy that will not hit it, so it needs answers (below) rather than a fix.
- **The arc:** Trúc Cơ: a body technique returns a small share of what you block. Kết Đan: the armour turns on the full channel. Nguyên Anh: Held Reflection banks what the cap clips and Open the Mirror releases it, so the build bursts without leaving its defence.

## The Legend

The Hundred-Wall Garrison (Bách Bích Quân) guarded a pass that no army broke and no one in it could leave: its soldiers were hammered into plate until they could be struck from any side. Its last quartermaster, Tư Mã Khuê, kept the plate going by sewing scraps of a shattered bronze mirror into the lining of her armour, because the mirror was what the barbarian chief refused to look into. Her armour did not stop blows. It sent them back.

The path is walked by gate wardens, bodyguards and sect enforcers who want the argument ended by the other side. It makes them patient and strangely gentle: they stop dodging, because a dodged blow returns nothing. Enemies who cannot reach them, poisoners, soul cultivators and duellists who wait, hate it, and the sects that learned to fight it burned the garrison's registers for fear of its reputation.

## How It Fights

You open by marking the enemy with Metal stacks and hardening with Earth stacks, then stand there. Each hit they land is returned in the same second, doubled by your layers. A heal art and body regeneration keep your health up, and when the cap on a single return clips a big blow, Held Reflection banks the excess. Around the 6-second mark Open the Mirror spends the bank in one hit.

**Signature moment:** a top-end foe throws its best strike; your health bar barely moves and the same strike lands back on them from the armour, a mirror-bright flash that ends the fight.

## Enabler

**Mirror-Scale Hide (Kính Lân Giáp)**: named body armour, `giap` base, grade high, tier of the realm, found on a dead garrison quartermaster (rare event or boss drop, Nguyên Anh grade from a sealed garrison tomb). Opens the Return channel (share 0.30 of pre-defence damage, blocked part included). Closes: no ward of any kind (default ward included) and evade 0. Needs rule (Combat Formulas G2, below). Rarity: the armour is rare; the stack is ordinary.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Return Share (Phản Lượng) | Return share +3 points (small), +12 points (notable); the armour gives 30 | Flat base | return | none | ○ | tree, armour, technique | any thorns or Mirror Ward build |
| 2 Rate | Bait (Mồi Nhử) | Curse: enemy basic attack cooldown 20 % shorter, so hits arrive faster | Timing | return | none | ○ | art, Đạo | any build that wants more hits, a curse build |
| 3 Multiplier | Return Damage (Phản Thương) | +2 % small, +12 % notable damage with the `return` tag | Increased | return | L1 | ○ | tree | thorns builds; Thorns (Kinh Thứ) |
| 3 Multiplier | Hide Hardens (Bì Cứng) | +4 points of return damage more per 5 block rating, up to +60 | Per | return | L2 | ○ | technique | any block build |
| 3 Multiplier | Mirror-Scale Plate (artifact power) | Armour attack-equivalent in the gear layer | Increased | return | L3 | ● | artifact | any armour build |
| 3 Multiplier | Echo-Wall Array (Hưởng Bích) | Prepared return damage from a formation | More | return | L4 | ○ | formation | seal build, Ringing Ground |
| 4 Certainty | Always Lands (Phản Tất Trúng) | Return hits ignore the accuracy roll (they are free hits) | Rule (part of the Return channel) | return | none | ○ | enabler | signature of the channel |
| 5 Reach | Needle Mark (Châm Ấn) | Metal debuff stacks: enemy takes more Physical (0.018 a stack) | stack | return | n/a | ● | art | any Metal build |
| 6 Past the cap | Held Reflection (Tồn Ảnh) | What the per-hit return cap clips is banked, up to 3 U x stage; Open the Mirror spends it | Overflow | return | none | ○ | Effect | any capped trigger build; held-payload |
| 6 Past the cap | Return Cap Shift (Phản Hạn) | +0.25 to the per-hit return cap (base 2.0) | Cap shift | return | none | ○ | rare node | any return build |
| 7 Fuel | Spring Returns (Hồi Xuân) | Health regeneration affix, reused | Increased | health | none | ○ | item | starter-wall |
| 7 Fuel | Self-Wound Counts (Tự Thương Cũng Trả) | Health your own arts cost counts as a hit taken, 1 return per cast | Redirect | return | none | ○ | Effect | any health-pay build |
| 8 Survival | Block and body layers B2 to B5 | Block rating, body resistance, body shield, regen | Increased and more | defence | B2–B5 | ● | technique, armour, formation | thể tu |
| 9 Identity | Mirror-Scale Hide (the Return channel) | The channel itself, with the prevented part counted | Rule swap (channel) | return | none | ○ | enabler | signature |
| Ticks | Boil Returned (Phản Độc) | When a tick stack on you ends or is cleansed, 40 % of its total returns as a hit | Trigger | return | none | ○ | Effect | any cleanse build |
| Ticks | Tick Return Weight | Ticks count 25 % toward return, +12 points a notable | Per | return | none | ○ | tree | any poison-resist build |

**Identity piece:** the Return channel carried by Mirror-Scale Hide. Remove it and the build is a block tank with a basic attack. The `--without mirror-return` run (the channel's stand-in) lengthened every fight it won: top-end mirror 41.5 s to 65.4 s.
**Empty rungs:** L5 is empty (sacrifice: return hits are not "while" hits, and a conditional would need a read of the incoming hit, see New Content); crit is empty (return hits never crit, the substitute is certainty: free hits skip the accuracy roll); ward (closed by the armour); evade (closed).

| Layer | Points at Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 400 (counts as 250, soft knee past +200) | ×3.5 | Tree (return damage, body damage), Đạo notables, Earth stack passives |
| L2 | 250 | ×3.5 | Return More from the technique (60), Hide Hardens (60), Heavy-Hand-style arts (30 each), Đạo keystone |
| L3 | 200 | ×3.0 | Mirror-Scale Hide armour, a second body piece, artifact power |
| L4 | 120 | ×2.2 | Echo-Wall Array, Iron-Sand Hand Bath coating, Stone-Marrow Pill |
| L5 | 0 | ×1.0 | Empty on purpose |

M = 3.5 × 3.5 × 3.0 × 2.2 ≈ 81 (typical Core Formation 5.48, top-end anchor 210). The body layers sit at the caps: B2–B5 300 / 250 / 150 / 100.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth-Metal (Thổ-Kim), purity 70 or more each | Earth buff stacks give Physical dampening (0.011 a stack), Metal debuff stacks give Physical taken (0.018 a stack), and Earth generates Metal in the cycle |
| Key talents | Physique (the body layers and block), Comprehension for the technique's layers | Body layers carry both defence and, through the channel, offence |
| The Way (Đạo) | Nhân Quả Đạo (Nhân Quả; Cause and Effect), branch Báo Ứng (Retribution): the proposed keystone Every Blow Comes Home, plus Debts and Cutting karma nodes | It is a listed Way (dao.md Catalogue 29) whose branch is retaliation; its nodes are not authored yet |

## Công Pháp

### Mirror-Skin Hundred Tempering Scripture (Kính Bì Bách Luyện Kinh) — main, Địa giai (tier 3)

A body-first Earth-Metal method written by the Garrison's armourers: the practitioner tempers the skin until it holds an edge.

```json
{"id": "kinh-bi-bach-luyen", "name": "Kính Bì Bách Luyện Kinh", "tier": 3, "tech_kind": "main",
 "names": ["tho", "kim"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 14}, {"stat": "block_rating", "value": 6}],
 "abilities": [{"ability_id": "hide-hardens", "unlock_layer": 3},
               {"ability_id": "return-share-small", "unlock_layer": 5},
               {"ability_id": "open-the-mirror", "unlock_layer": 8}],
 "seal_clusters": ["scarred-hide"], "origin": "authored"}
```

**Fit:** Needs key (abilities, combat passives) · **Budget:** NOT ASSESSED: `block_rating` is outside `bonus_pool`; khi_huyet_pct 14 only is in the pool and within the guessed single cap. The tier's `max_realm` must reach Nascent Soul; not checked against data on this run.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Packed Earth Stance (reused, as `packed-earth-stance`) | Scripture, 1 | elem, Earth, buff: 3 Earth stacks 12 s | 0.2 | 0.03 | 4 s | none | Needs key |
| Needle Mark (Châm Ấn) | Scripture, 2 | elem, Metal, debuff: 3 Metal stacks 10 s | 0.3 | 0.03 | 3 s | none | Needs key |
| Mending Breath (reused as `mending-breath`) | Scripture, 4 | heal, Earth | 0 (c_heal 1.2) | 0.04 | 5 s | none | Needs key |
| Open the Mirror (Khai Kính) | Scripture, 8 | phys, Metal, return, spends the Held Reflection bank | 3.6 | 0.06 | 6 s | bank above 0 | Needs rule |
| Offering Cut (Hiến Huyết Thức) | Đạo node | body, Metal; costs health 5 % | 0.8 | health 0.05 | 4 s | health above 40 % | Needs rule |
| Thorn Chorus (Kinh Hợp Xướng) | Scripture, 10 | phys, Metal, return | 1.2 | 0.04 | 4 s | none | Needs key |

**Effects.** Needle Mark: a Metal debuff, stacks per Effects System Formulas D. Open the Mirror: a hit of c_art 3.6 plus the whole Held Reflection bank, once per 6 s. Offering Cut: its health cost counts as one hit taken, and the Return channel answers it (Self-Wound Counts). Thorn Chorus: a hit whose damage grows by 5 % for each Return since the last cast, capped at 10. All inside the art lint at the shown costs (Open the Mirror 3.6 against a limit of 3.69).

**Descriptions.** Needle Mark: an iron needle pressed into the bruise. Open the Mirror: the lining turns outward. Offering Cut: you cut yourself and the garrison remembers. Thorn Chorus: every wound spoken back at once.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation (Trúc Cơ) | 4 | Packed Earth Stance, Needle Mark, Mending Breath, Offering Cut | none (ward closed from Kết Đan; before that the default ward is optional) | Return share small (10 %) from the technique only |
| Core Formation (Kết Đan) | 5 | Packed Earth Stance, Needle Mark, Mending Breath, Open the Mirror, Offering Cut | no ward (closed) | Armour turns on the channel; the channel takes no slot |
| Nascent Soul (Nguyên Anh) | 6 | the five above + Thorn Chorus | no ward | Held Reflection live, a second return-damage notable |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Mirror-Scale Hide (Kính Lân Giáp) | Artifact, body armour (enabler) | `giap`, high grade, realm tier | The Return channel; closes ward and evade. Mirror shards sewn into the lining by the Garrison's last quartermaster | Needs rule |
| Spring Returns affix (reused `hoi-xuan-affix`) | Affix on a second body piece | affix row | Health regeneration, so the build heals between returns | Fits today |
| Echo-Wall Array (Hưởng Bích Trận) | Formation, L4 | combat formation | Prepared return damage, lasts the fight | Needs key |
| Hot Spring Array (reused) | Formation | `hot-spring-array` | Health regen for the build | Needs key |
| Iron-Sand Hand Bath (reused) | Coating | `iron-sand-hand-bath` | L4 coating, here for return damage | Needs key |
| Stone-Marrow Pill (reused) | Pill | `stone-marrow-pill` | Body layer in preparation | Needs key |
| Bruise-Blossom Pill (Ứ Hoa Đan) | Pill | preparation payload | +5 return share for the fight, raises pill toxicity | Needs key |
| Quiet Mirror Talisman (Tĩnh Kính Phù) | Talisman | guard: a soul hit arrives | Returns 30 % of the soul damage it stops as soul damage (the answer to soul) | Needs rule |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Block (`block_rating`) universal and vs physical | +3 / +20 rating | The block layer and Hide Hardens | Fits today (designed) |
| 2 | Return Share | +3 / +12 points | The base of the channel | Needs key |
| 3 | Return Damage | +2 % / +12 % | L1 | Needs key |
| 4 | Maximum health, health regeneration | +1 / +6.5 %, +0.15 / +1 % | Sustain between returns | Fits today |
| 5 | Thorned Skin (Kinh Bì), existing catalogue keystone | n/a | The seed of this channel; a player without the armour can take the keystone for a weaker return | Needs rule |
| 6 | Iron Marrow (Thiết Tủy), existing catalogue keystone | n/a | Block rises as health falls: makes the back half of the fight sturdier | Needs rule |
| 7 | Tick Return Weight | +12 points | Lets poison and burn feed the channel | Needs key |
| 8 | Return Cap Shift | +0.25 | Rare one-off past the cap | Needs key |

### Hidden cluster idea: Scarred Hide (Sẹo Bì)

Theme: Body Tempering (Thể Luyện), element Earth. Sealed, authored. Seal condition: a technique that lists it in `seal_clusters` (the Scripture) or carrying 40 blows from higher-realm foes in one life. Size: 8 acupoints. Small: block, body regeneration, health, Return Share. Notables: Return Damage, Hide Hardens, Bank Deeper (Held Reflection bank +1 U). Capability on the last notable (outer sealed cluster): the Return cap rises by 0.25.

## Đạo

Nhân Quả Đạo, branch Báo Ứng (Retribution). Existing Đạo; nodes not authored (Fits today for the Way, Needs rule for the nodes). Nodes wanted: Every Blow Comes Home (keystone: Return hits cannot be dodged by the enemy's evade and count the tick weight at 50 %), Debt Paid in Kind (Offering Cut), Cutting Karma (cleanse that triggers Boil Returned), plus Return Share lines. No ceiling raises, no root factors.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation (Trúc Cơ) | A block tank with a small return; wins by outlasting | Hide Hardens, Packed Earth Stance | You learn to stop dodging |
| Core Formation (Kết Đan) | Return on every hit; ends a typical fight in about two seconds | Mirror-Scale Hide, Needle Mark | The armour closes your ward, and the first time you need it you notice |
| Nascent Soul (Nguyên Anh) | Bank and release; a mirror match against another top-end build is about 41 s | Held Reflection, Open the Mirror, Thorn Chorus | The garrison's ledgers were burned for a reason |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical melee or Physical striker, same realm | wins, about 2 s | Return plus Metal stacks end it before it reaches the heal |
| Top-end offence build, same realm | wins on the stand-in, about 41 s | Body layers at the caps; the Return approximated as one Physical hit a second |
| Top-end, one realm above | loses, 10 to 12 s | Suppression and the lack of a ward |
| Poisoner or burner (ticks) | even | Tick weight 25 % feeds a small return; Boil Returned pays out when stacks end; cleanse is the plan |
| Soul cultivator | loses unless prepared | Soul skips layers; Quiet Mirror Talisman returns a share, soul resistance is the answer |
| Wind or evade build, ice cost-up | loses or stalls | Evaded hits return nothing; Bait shortens the enemy cooldown, Needle Mark ends dodging via the Đạo keystone |
| Waiting or guard-blocked enemy | stalls | Offering Cut and Self-Wound Counts turn your own health into returns, and fatigue ends the fight |

**Counter:** an evade or wait build (Wind, Ice) that never lets a hit land, and a soul cultivator. They take longer, but each fight still ends, because fatigue starts at 60 s and Offering Cut makes the build hit itself.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique bonuses are `block_rating` (not in `bonus_pool`) and `khi_huyet_pct` 14; art lint met on every art (Open the Mirror 3.6 of 3.69); no `lint_over` line from `fight.py`; slots 4 / 5 / 6 within `slots_by_realm`; one artifact equipped |
| Validity | PASS | Realms `truc_co`, `ket_dan`, `nguyen_anh` exist in cultivation_realms.json; Earth and Metal are real elements; tier max_realm not checked against data |
| Stack | PASS | Nine rungs filled or named as a sacrifice (L5, crit, ward, evade); forms: flat base, increased, more, per, timing, overflow, cap shift, trigger, redirect, rule swap, so ten; identity piece named. Identity test: `--without mirror-return` changed every matchup on both realm files (identity lines `changed`), measured on the stand-in only |
| Scaling | PASS | M ≈ 81 at Core Formation, between typical (5.48) and top-end (210); the fight outcome matches top-end: ends a typical foe in 1.7 s, a top-end mirror lasts 41.5 s. INFO: layers L2 to L4 sit below their caps |
| The fight | NOT ASSESSED | The engine (the Return channel, Held Reflection, ticks, soul) is unmodelled; only a stand-in art was run. Loop observed on the stand-in; four arts show `NEVER_FIRED` in the 1.7 s typical fight because the fight ended first, but all fire in the top-end mirror |
| Reuse | PASS | 12 reused pieces; signature pieces: 2 (the Return channel, Mirror-Scale Hide); every new modifier names a second home |
| NPC use | PASS | An NPC generator can roll Return Share, Hide Hardens and the armour; a Breakdown line: "Returned 31 of the 94 you sent (Return 30 %)" |
| Counterplay | PASS | Wind and Ice evade or wait builds, soul cultivators, and a higher realm with suppression |
| Originality | PASS | No names or techniques from novels or games; the Garrison and Tư Mã Khuê are original |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/mirror-hide.fight.json` (Core Formation) and `mirror-hide.nguyen-anh.fight.json` (Nascent Soul). Observations from `fight.py` on the combat simulator (20 fixed seeds), not the game. The Return channel is approximated by the art `mirror-return`; the file has no ward (the armour closes it) and body layers at the caps.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Core file | 0 | 20 / 0 / 0 | 1.7 s | never | packed-earth-hide, needle-mark, open-the-mirror, sap-the-bruise | none |
| typical | 1 | 20 / 0 / 0 | 3.4 s | never | open-the-mirror, sap-the-bruise | none |
| typical | 2 | 20 / 0 / 0 | 9.5 s | never | none | none |
| top_end | 0 | 20 / 0 / 0 | 41.5 s | never | none | none |
| top_end | 1 | 0 / 20 / 0 | 11.6 s | never | none | none |
| top_end | 2 | 0 / 20 / 0 | 2.2 s | never | open-the-mirror, sap-the-bruise | none |
| typical, Nascent Soul file | 0 | 20 / 0 / 0 | 1.7 s | never | packed-earth-hide, needle-mark, open-the-mirror, sap-the-bruise, thorn-chorus | none |
| typical | 1 | 20 / 0 / 0 | 4.0 s | never | open-the-mirror, sap-the-bruise | none |
| top_end | 0 | 20 / 0 / 0 | 41.6 s | never | none | none |
| top_end | 1 | 0 / 20 / 0 | 10.0 s | never | none | none |

An earlier run with a drain ward (all four ward layers at the caps) lost to a top-end foe at the same realm in 8.6 s because the ward drained linh lực dry; the no-ward body build is what the armour's closing of the ward produces, and it won.

**Identity test** (`--without mirror-return`): changed in every matchup on both files. Core: typical 1.7 → 3.0 s, +1 3.4 → 5.0 s, +2 9.5 → 16.5 s, top-end 41.5 → 65.4 s; top-end +1 and +2 unchanged in result. Nascent Soul: typical 1.7 → 3.0 s, top-end 41.6 → 61.7 s.

**Unmodelled:** the simulator reports `not modelled: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape`. Beyond that, this sheet's own list: the Return channel as a per-incoming-hit channel (approximated at one hit a second, c_art 1.4); the armour's prevented-part counting; Held Reflection; Boil Returned and tick return; Self-Wound Counts and Offering Cut's health cost (`art_cost_health_pct` 0); soul returns and the Quiet Mirror Talisman; Bait; guards (Open the Mirror waits for a bank in the game, only for cost in the sim).

## New Concepts

**Return channel (Phản).** Rule: Combat Formulas G gets a sibling G2. For each incoming hit part that enters the defence path (ticks at weight 0.25), `return_hit = return_share × pre_defence_damage × L1..L4(return) × supp`, delivered as a free hit that meets the enemy's defence path, clipped to `ret_cap × U × stage` per hit (ret_cap 2.0). Excess goes to the Held Reflection bank when the Effect is held. It is not a trigger (no `trig_budget`, no `trigger_depth` use) and a return never triggers another return. Bounds: the per-hit cap, the 0.25 tick weight, depth 1. Breakdown line: "Returned 31 of the 94 you sent (Return 30 %)". Serves: starter-wall (Thorns), any Wood Thorns build from dual-metal-wood, and any Mirror Ward variant. Question for the user: is a new channel outside the trigger budget acceptable?

**Incoming hit readable.** Effects need to read the size of the hit that reached the defence path (Combat Defence & Healing rule 1). Serves: this build and any reactive ward. Question: allowed as a read, not a new stat?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Return channel | Needs rule | Combat Formulas G2: return hits, cap `ret_cap`, tick weight 0.25 |
| Mirror-Scale Hide | Needs rule | Item enabler: closes wards and evade (Combat Defence & Healing rule 5 pattern) |
| Held Reflection | Needs rule | Effects System: overflow bank, bank cap |
| Self-Wound Counts | Needs rule | Combat Defence & Healing: health paid by arts counts as a hit taken |
| Bait | Needs rule | Combat rule 8: a curse that shortens the enemy's basic cooldown |
| Boil Returned | Needs rule | Effects System: event "a tick stack removed", reuse `cleansed-stacks-event` |
| Return Share, Return Damage, Return More, Hide Hardens, Tick Return Weight, Return Cap Shift | Needs key | `return_share_pct`, `return` tag and its modifier keys |
| Scripture, arts, formation, pills, talisman, cluster | Needs key | Records and art records |
