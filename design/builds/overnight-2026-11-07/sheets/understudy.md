# The Understudy (Thế Thân Hí)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Illusion: the enemy's hits land on something that is not there." Evade has never been an engine. A villain enjoying themselves, in a palace or a theatre, not an elegy.
> **Direction**: Rule 15 forbids a build that rests on a roll, so evade stops being a roll. It becomes a schedule you can count, and the hits it does not cover you buy, one mask at a time.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: top-end at its own realm, strong one up only against a spender · **Use**: player build, or a court villain
> **Fit**: 4 Fits today · 8 Needs key · 5 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: the masks have no hit, so no lint prices them, and thần thức is not totalled)

## The Spine

- **The channel:** the basic attack, then two arts that fire only after a miss. L1 to L5 all count. Nothing here is aimed: every point of offence is a reply.
- **The enabler:** The Understudy. Opens evade as a counted Curtain, with no chance at all. Closes the body: thần thức holds the double, so one light artifact, no gear ward, and every serious hit that lands is the end.
- **The loop:** a hit lands on the double. The Curtain pays, the fist grows by half the blow, Encore rises, and the cued art fires in the follow-up instant.
- **The engine:** a miss ignores M, so the enemy's whole multiplier is worth nothing here. Only their hit count matters. Every miss pays three times: no damage, no drain, and a bigger slap.
- **The sacrifice:** anything that is not a hit. Ticks and soul arts go straight past the double, and many small hits outrun the masks.
- **The arc:** a stage trick at Foundation, a court post at Core, and at Nascent a role that no longer needs its actor.

## The Legend

The Bureau of Rites has held eleven state funerals for the Master of Revels. The Master attended all of them, sat near the back and sent notes on the eulogies. Each corpse was a singer from the palace troupe with a fine voice and a family to consider, told they were being given the part of a lifetime. They were. The Master picks them by ear, rehearses them for years, and has never troubled to learn a name, which they describe as a matter of craft.

Disputes at the Jade Hall are settled by invitation, on gilt paper, and the guests are seated first. When a minister's champion finally lands the blow the whole court came to see, the silk falls and there is no one in it, and someone in the third row is laughing. Then comes a slap, in the champion's own strength, in front of everyone. Three auditors have been sent to end the post. Each reported that they had dealt with the Master personally, and each was right about that, which is why the Bureau is ordering more silk.

## How It Fights

The curtain rises with two hits already paid for. Each second a new mask goes on, the enemy's arts land on silk, and a free slap comes back half as heavy as what they threw. Nothing is rolled, so a player can sit down before the fight and count: their hits a second against your Curtain a second. If the sum holds, they will never touch you. If it fails by one hit, you are dead.

**The signature moment:** a same-realm top-end, 15 blows in 7 seconds, every one above your whole health before ward (`variants/understudy-mark-1.fight.json`). All 15 land on the double. Their ward holds until their pool goes, they fall from 75 % to 0 in the last two seconds, and you finish on 100 % health with nothing left in your own pool (`variants/understudy-mixed.fight.json --enemy top_end`).

## What evade_cap and accuracy allow

From Combat Formulas I, and the reason this build is shaped as it is.

- **`evade_cap` limits a roll, not a miss.** 0.40 caps the chance of one hit. Nothing in the game limits misses from another source, so Costume Change is legal in spirit and needs a rule. Hits fill 0.40 each, and the masks buy the rest: 15 of 15 hits, 100 % against the cap's 40 %.
- **The cap is cheap and nobody buys it.** Notable evade is +2.5 for 8 W, so 3.2 W a point and 128 W for the cap. The anchors carry none, and no reference enemy has any accuracy.
- **Plain evade is not an engine.** The same body with 40 % as an expected value and the same arts unguarded wins a typical at 6 s with almost nothing left, and dies to a top-end at 1 s with the enemy on 98 % (`variants/understudy-plain-evade.fight.json`).
- **Evade past the cap does one thing: it eats accuracy.** `evade − accuracy` is clamped after subtracting, so 55 at accuracy 0 reads as 40, and 15 points of margin are free against the first 15 accuracy. This build buys 55 for that. Accuracy is 2.67 W a point (+3 for 8 W), so a 40-accuracy enemy costs 107 W and turns the same-realm top-end win into a death at 5 s, enemy on 77 % (`variants/understudy-accuracy-40.fight.json`), because the fill falls to 0.15 a hit.
- **Accuracy at or above evade sees through.** This is a proposed line, not Formulas I, which would only stop the roll. With it, bought masks fail too, and the double takes 0 of 9 hits (`variants/understudy-accuracy-60.fight.json`). The same happens at evade 40 against accuracy 40 (`variants/understudy-evade-40.fight.json`), which is why 15 past the cap is the cheapest insurance in the build.
- **A cap on hits by count says nothing about size.** The first design let the player set a threshold, so the double would save itself for big blows. It did nothing, because at this body every landed hit is lethal, and at a Mark of 100 % it loses to a typical at 4 s with 0 of 9 on the double (`variants/understudy-mark-1.fight.json`). It was cut.
- **Fortieth Breath's Measured Stroke needs a ruling.** Its text says "cannot be evaded", and its file models accuracy 40. Against 55 evade those two differ.

## Enabler

**The Understudy (Thế Thân)**, keystone of the Illusion Đạo. Rule swap.

- **Opens:** your evade is never rolled. Each body or qi hit aimed at you fills the Curtain by `p_evade`, as Formulas I gives it, times `min(1, your thần thức ÷ theirs)`. When the Curtain holds 1 or more it pays 1, and the hit lands on the double: it deals nothing, drains nothing and fires no on-hit trigger, and they keep the cost. It holds at most 2. This takes no draw, so rule 15 is satisfied outright, and the calculator is exact for this fight rather than an expected value.
- **Closes:** thần thức holds the double, so you carry one artifact of cost up to a quarter of your thần thức, and no ward gear. And The Credit, below.
- **Found:** the keystone of a tree nobody teaches, because the last holder is still using it.

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken: a plain evade stack gave way to the masks, and a fist that grows from what missed replaced a stored-damage mirror.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Returned Force (Hoàn Lực) | Half the coefficient of a hit on the double joins your next basic attack | Borrow | basic | none | ○ | Sealed cluster | **Reused from Receiving Hand**, which only caught arts |
| Rate | Cue (Nhập Tràng) | A guard: true in an instant when a hit landed on the double. The art fires in the follow-up instant | Timing | art | none | ○ | Technique | any riposte build |
| Multiplier | Damage (`attack_pct`) | +100 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Encore (Tái Diễn) | +10 points per hit evaded this fight, to +100 | Per | art, basic | L2 | ○ | Illusion Đạo | any evade build, rolled or not |
| Multiplier | Artifact attack | +20, one light piece | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Full House (Mãn Tọa) | On ground with the `stage` tag: +30 points, and the Curtain holds 4 | More | any | L4 | ○ | Illusion Đạo | any arena or court build |
| Multiplier | Longer Breath (Trường Tức) | +50 while your linh lực share leads by 10 points | Conditional | art, basic | L5 | ○ | Technique | **Reused from Long Carry**, which got its lead by not warding |
| Reach | Thần thức (`than_thuc_pct`) | +50: holds the read on someone stronger | Increased | none | none | ● | Tree, technique | every soul build |
| Past the cap | Evade (`evade_pct`) | 55: 15 past the cap, as margin against accuracy | Flat | incoming | none | ● | Illusion Đạo | any evade build |
| Survival | The Understudy | Above | Rule swap | incoming | none | ○ | Keystone | any evade build |
| Survival | Costume Change, Painted Screen | Arts that add 1 to the Curtain, times the thần thức ratio | Cap shift | incoming | none | ○ | Technique | any build that fears one big art |
| Survival | Dress Rehearsal (Diễn Tập) | In a foreseen fight the Curtain starts at 2 | Timing | incoming | none | ○ | Illusion Đạo | any charge or stock build |
| Survival | Seen Through (Thức Phá) | Accuracy at or above your evade: the double fails for that attacker | Trade | incoming | none | ○ | Keystone | any evade build |
| Price | The Credit (Đầu Bài) | A knockout won with the Curtain up is credited to the role. It feeds no tally of cultivators defeated, and the world records the double | Trade | none | none | ○ | Keystone | any disguise build |

**Identity piece:** The Understudy. Without it the same body loses a typical at 6 s with the enemy on 76 %, and dies to a top-end at 1 s (`variants/understudy-mixed.fight.json --without understudy`).
**The modifier used against its author's plan:** Returned Force was written for a fist saint's empty slots. Here it turns a miss into the main damage. `--without catching_hand` on the mixed file loses the top-end at 15 s with the enemy on 50 %. Longer Breath also earns its place, against spenders only: it never fires against the mixed top-end, and on the main file one up `--without "Longer Breath"` loses at 10 s with the enemy on 29 %, where the build otherwise wins at 7 s.
**Pairs that share a job, removed together.** Returned Force and Encore: same-realm top-end lost at 8 s, enemy on 84 %. Both masks: lost at 2 s, enemy on 95 %. The cued arts, Curtain Call and Aside, are not the engine: without both the fist alone still wins that top-end at 10 s on 100 %, keeping 18 % of its pool.
**Empty rungs:** Crit is a sacrifice, since a schedule has no use for a second chance. Fuel is the real gap: the pool is the clock, and this build refuses to fix it.

| Layer | Points at Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 100 | ×2.00 | Tree |
| L2 | 0 to 100 | ×1 to ×2 | Encore, in the fight |
| L3 | 20 | ×1.20 | One light piece |
| L4 | 30 | ×1.30 | Full House, on a stage |
| L5 | 0 or 50 | ×1 or ×1.5 | Longer Breath |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water, purity 30 or more | The Illusion Đạo's requirement below |
| Key talents | Soul strength, then Presence for the court | Own thần thức 117 is soul strength 60 × stage 1.3 × +50 % |
| W, a first guess | Tree 303 of Core's 447: attack 100, health 36, linh lực 60, ward 60, thần thức 47. Way lines: evade 55, at 176 W | Offence is what misses pay for, so W goes to evade and the read |
| The Way (Đạo) | Illusion (Huyễn), below | The keystone and the Curtain's pieces |

## Công Pháp

### Hundred-Mask Libretto (Bách Diện Hí Bản) — main, Địa giai

A prompt book with every line of every role, and a margin of notes about who was bad in them.

```json
{"id": "bach_dien_hi_ban", "name": "Bách Diện Hí Bản", "tier": 2, "tech_kind": "main", "names": ["thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 20}, {"stat": "than_thuc_pct", "value": 15}],
 "abilities": [{"ability_id": "costume_change", "unlock_layer": 2}, {"ability_id": "curtain_call", "unlock_layer": 4},
               {"ability_id": "aside", "unlock_layer": 6}, {"ability_id": "painted_screen", "unlock_layer": 8},
               {"ability_id": "last_act", "unlock_layer": 11}],
 "seal_clusters": ["hau_dai"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 20/20 + 15/15 = 2.0 against Địa's 3, two bonuses as the tier's `bonus_count`. Tier `max_realm` is `nguyen_anh`.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Costume Change (Cải Trang) | Libretto, 2 | illusion | 0 | 0.06 | 1 s | none | Needs rule |
| Painted Screen (Họa Bình) | Libretto, 8 | illusion | 0 | 0.08 | 2 s | none | Needs rule |
| Curtain Call (Tạ Mạc) | Libretto, 4 | qi, Water | 1.6 | 0.05 | 1 s | Cue | Needs rule |
| Aside (Bàng Bạch) | Libretto, 6 | qi, Water | 2.4 | 0.08 | 3 s | Cue | Needs rule |
| Last Act (Chung Mạc) | Libretto, 11 | qi, Water | 5.15 | 0.12 | 12 s | none | Needs key |

**Costume Change. Effect:** adds 1 to the Curtain, times the thần thức ratio. **Description:** the same face, in a better coat.
**Curtain Call. Effect:** a hit, in the follow-up instant. **Description:** you bow. It is not to them.
The two masks have no hit, so the art lint does not price them. They are sized by comparison: a per-hit ward at `hit_cost_share` 0.05 blocks part of a hit, and a mask at 0.06 blocks all of one.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Costume Change, Painted Screen, Curtain Call, Aside | Common drain | `variants/understudy-foundation.fight.json` |
| Core Formation | 5 | As above, one slot open | Common drain | A cleanse belongs in the open slot if you know a poisoner is coming |
| Nascent Soul | 6 | As above, then Last Act | Common drain | `variants/understudy-nascent.fight.json` |

Painted Screen is the one real choice. Against peers it is waste: out of the mixed file, the top-end dies at 6 s and you keep 28 % of your pool. One up it is the difference between dying at 3 s and dying at 6 s.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Any light piece | Artifact | Generated, under the quarter of thần thức | L3 20, and that is all | Fits today |
| The Jade Hall, or any theatre | Ground tag `stage` | A place | Full House. No formation, only a room | Needs key |

Gilt invitations are not an item. They are why you want to be the side that opened: see Matchups.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Thần thức (`than_thuc_pct`) | +35 here, +15 from the Libretto | Keeps the ratio at 1 against peers | Fits today |
| 2 | Green Room | Sealed cluster | Returned Force | Needs key |
| 3 | Damage (`attack_pct`) | +100 | L1 | Fits today |

### Hidden cluster idea: Green Room (Hậu Đài)

Theme: performance and the second self. Water, outer, sealed by a technique that lists it, here the Libretto. Size 10. Small acupoints of linh lực and thần thức. Notables: Returned Force, and a second for Longer Breath's condition. Capability: a Cue guard on any art. An idea for the tree rework, not data.

## Đạo

**Illusion (Huyễn Đạo).** Already in the Way's catalogue of 22, with no tree yet.

- **Requirement:** Water at purity 30.
- **`theme_stats`:** `evade_pct`, `than_thuc_pct`, `linh_luc_regen_pct`, `mi_luc`.
- **The Mask (Diện), 6 nodes:** evade lines, then Costume Change as an art node. A player here reads as a rogue.
- **The Script (Bản), 7 nodes:** Dress Rehearsal, the Cue guard, a passive that adds one cued art slot's worth of order. A player here reads as a duellist who only answers.
- **The House (Tọa), 6 nodes:** Encore, Full House, presence lines. A player here reads as a courtier.
- **Keystone:** The Understudy, with Seen Through and The Credit as its terms. 20 nodes.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Beats its own top-end at 6 s on 100 %, loses one up at 3 s | Costume Change | A stage trick at a provincial fair |
| Core Formation | The defined build | The keystone, Encore | The first singer they do not bother to thank |
| Nascent Soul | Own top-end at 9 s on 100 %. One up, dead at 4 s, enemy on 88 % | Last Act | The double starts getting better reviews |
| Deity Transformation | Not run | | |

## Matchups

Core Formation. Mixed enemy unless stated. "On the double" is hits missed of hits aimed.

| Enemy | Result | On the double | File, in `variants/` |
|---|---|---|---|
| Mixed, same realm | Win, 3 s on 100 %, pool 55 % | 7 of 7 | `understudy-mixed` |
| Mixed top-end, same realm | Win, 7 s on 100 %, pool 0 % | 15 of 15 | same |
| Mixed, one up | Loss, 6 s, enemy on 72 % | 10 of 14 | same |
| Mixed top-end, one up | Loss, 3 s, enemy on 98 % | 5 of 7 | same |
| Blind, typical (no stage, Curtain starts at 0, holds 2) | Win, 5 s on 78 % | 8 of 10 | `understudy-blind` |
| Blind, top-end | Dead at 1 s, enemy on 99 % | 1 of 2 | same |
| **Chaff, 4 cheap arts** | Typical: win, 3 s on 60 %. **Top-end: dead at 2 s, enemy on 93 %** | 9 of 10 | `understudy-chaff` |
| **Poisoner** | Typical: win, 4 s on 90 %. **Top-end: dead at 12 s, enemy on 57 %** | 17 of 18 | `understudy-poisoner` |
| **Soul arts** | Typical: win, 5 s on 99 %. **Top-end: dead at 19 s, enemy on 19 %** | 18 of 19 | `understudy-soul-arts` |
| Accuracy 40 | Typical: win, 3 s on 100 %. Top-end: dead at 5 s, enemy on 77 % | 10 of 11 | `understudy-accuracy-40` |
| Accuracy 60, or evade 40 against accuracy 40 | Typical: dead at 4 s, enemy on 84 % | 0 of 9 | `understudy-accuracy-60`, `understudy-evade-40` |
| ×4 boss | Dead at 20 s, boss on 4 %: the pool ends first | 23 of 29 | `understudy-boss-x4` |
| No masks | Typical: win, 3 s on 61 %. Top-end: dead at 2 s | 4 of 7, 3 of 4 | `understudy-no-masks` |
| The Forum Build, at Nascent Soul, you open | **Win, 32 s on 43 %.** It fires its volley at silk and has no fist | 10 of 11 | `understudy-vs-forum-build` |
| The Forum Build, it opens | **Dead at 2 s** | | `forum-build-vs-understudy` |

**Where the sense numbers come from.** Own 117 is derived above. Enemies use `realm_sense`, `sense_base` 57 and 85, copied from The Cut Line, which the anchors do not state and the critic has called derived from nothing. Same realm the ratio is above 1, so it does nothing. One up it is 0.68 against typical and 0.46 against top-end, through `M_ts`. No enemy here has an element.

**Counter:** many hits, ticks, soul, accuracy or someone patient. Combat rule 18's over-time attacker and any cheap-art flurry both beat it, and a top-end who simply has a poison art wins with 57 % left. Against a build that opens with one enormous volley, it comes down to rule 10: whoever opened lands first, so your mask is up or it is not. So the invitations are on gilt paper.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Curtain Call 1.60 of 1.60, Aside 2.40 of 2.46, Libretto 2.0 of 3. Slots 4 of 5. The masks have no hit, so no lint applies, and thần thức is not totalled |
| Validity | PASS | `thuy`, tier 2, `nguyen_anh`, `evade_pct`, `than_thuc_pct`, `mi_luc` are real. Illusion is in the Way's catalogue. Cost and cooldown inside Formulas A2 and E |
| Stack | PASS | Nine forms. Identity and both pairs tested. L1 to L5 stated |
| Scaling | PASS | `m_static` 3.12 against typical 5.48 and top-end 210, and it beats top-end anyway, because the miss ignores M. INFO: this is a Core build killing its own top-end, for the whole pool |
| The fight | PASS | `rules/understudy.py` and `rules/cue.py` run the rule, and Returned Force is `catching_hand.py`, unmodified. No chance field: the result is exact. `longer_breath_hits_off` is a count, not a cap |
| Reuse | PASS | Returned Force, Longer Breath, Illusion from the catalogue. No Hearth Ash. No new Overflow |
| NPC use | PASS | All data on a loadout. Breakdown: "Curtain 1.4: hit on the double" |
| Counterplay | PASS | Chaff, poison, soul, accuracy, a ×4 boss, a blind top-end |
| Originality | PASS | A stage double is a common idea; no name comes from an existing work |

## Fight Results

Input: `sheets/understudy.fight.json`. Rules `realm_sense`, `catching_hand`, `understudy`, `cue`, `breath_lead`. Observations from `_tools/fight_x.py`, a paper model that is exact here, since nothing is rolled.

| Enemy | Gap | Result | Time | Own dry at | On the double |
|---|---|---|---|---|---|
| typical | 0 | Win, 100 % | 3 s | never | 6 of 6 |
| typical | 1 | Win, 100 % | 7 s | 6 s | 11 of 11 |
| typical | 2 | Loss, enemy 99 % | 2 s | 2 s | 2 of 4 |
| top_end | 0 | Win, 100 % | 5 s | never | 9 of 9 |
| top_end | 1 | Loss, enemy 98 % | 3 s | 3 s | 4 of 6 |
| top_end | 2 | Loss, enemy 100 % | 2 s | 2 s | 2 of 4 |

The one-up win is against the fixture that bankrupts itself. Against the mixed enemy it is a loss, so the claim is "own realm, top-end included".

**Unmodelled:** The Credit; Dao heart, which `game-concept.md` says resists illusions and which has no key in a fight profile; the quarter-of-thần thức limit; escape.

## New Concepts

**The Curtain (Mạc).** A deterministic replacement for the evade roll, and a general answer to rule 15 for any chance a build wants to rest on.

- **Rule:** Combat rule 15 and Formulas I: a keystone may replace one roll with a counter that fills at the roll's chance.
- **Bounds:** rolled evade stays capped by `evade_cap`, the counter stops at 2 or 4, and bought misses cost linh lực.
- **Breakdown line:** "Curtain 1.4: hit on the double".
- **Other builds it serves:** any crit build wanting a fixed rhythm, and The Loud Sword if it wants to be readable.
- **Question for the user:** is a miss that is bought rather than rolled still inside what `evade_cap` means?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| The Understudy, Seen Through | Needs rule | Combat rule 15, Formulas I. An accuracy line |
| Costume Change, Painted Screen | Needs rule | Formulas I: a miss from outside `evade_cap`. No-hit arts need a lint |
| Cue | Needs rule | Combat rule 13: a new guard |
| Returned Force on the double | Needs rule | One line: a hit on the double counts as caught |
| The Credit | Needs rule | Combat rule 14: a result flag for the caller |
| Encore, Dress Rehearsal, Full House, Longer Breath, Libretto, five arts, Green Room, Illusion tree | Needs key | Content, one Per scale, one ground tag |

## Questions

1. A Core build beats its own top-end untouched, for its whole pool. Rule 18 calls one volley at top-end normal. Is "they never touch you, and it ends when your pool does" wanted, or should a mask cost more?
2. Should Dao heart be the key that sees through illusions? `game-concept.md` says so for breakthroughs, and it would give an old key a fight job.
3. Rule 10 gives the opener first hit. Should a side be able to choose to open, given what that decided here?
4. Does Measured Stroke's "cannot be evaded" beat the double? Its text and its file disagree.

## Also Considered

- **The Lying Mirror:** the enemy's guards read a false health and fire their finishers on your illusion. Funny, but only a shaped enemy shows it, so it is one modifier and not a build.
- **The Mirror Stage:** evade past the cap returns the enemy's own hit at their M. Strong, but it is the enemy-ruins-itself story again, and an Overflow.
