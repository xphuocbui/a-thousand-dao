# The Thousand Scales (Thiên Lân Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The rage of a thousand small cuts: trigger hits that exist to stack statuses, because the trigger budget counts damage, not statuses, then a tick Overflow past `dot_pulse_cap`. Fury as the mood."
> **Direction**: Spillover alone would have rebuilt the Burial Shroud, so the main Overflow is new: what the pulse cap clips widens the cap. Spillover stays as the second one, on the other cap.
> **Realm span**: Foundation Establishment – Core Formation, with an ending at the Nascent Soul gate · **Power level**: strong · **Use**: player build, or a feared NPC nobody wants to finish quickly
> **Fit**: 3 Fits today · 9 Needs key · 3 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức not totalled, and the status lint has no reading for a triggered status)

## The Spine

- **The channel:** ticks, on L1 to L3. Hits exist to carry triggers. Against the mixed enemy one realm up, 88 % of the health removed is ticks.
- **The enabler:** none. Every wound is an ordinary on-hit trigger from an ordinary piece. The build is the stack.
- **The loop:** every hit, free or paid, reopens up to six wounds. Seven different wounds run on the target. The pulse cap clips them, and what it clips widens it.
- **The engine:** `dot_pulse_cap` is the only thing holding seven wounds at 8 %. Widening Wound feeds the cap with its own clip, so the bleed accelerates toward 35 % of maximum health a second (seven wounds at `dot_pool_cap`), at any realm. One realm up the enemy's bar falls 11, 12, 19, 25 and 30 points in successive seconds.
- **The sacrifice:** no attack worth the name, no preparation (L4 is empty on purpose), no escape, and no Nascent Soul while the hatred is kept.
- **The arc:** hatred climbs for a whole life and stops the climb at the Nascent Soul gate, which asks for heart demon at 20 or less. The cultivator must forgive to go on. The numbers say what that costs, and it is less than they think.

## The Legend

On the salt quays below the river mouth the gutters could take the scales off a carp in four hundred strokes and never once cut deep, because a deep cut spoils the fish. One spring a sect opened its dam to save its herb terraces, and the quay town went under with everyone in it except the boats. A gutter from one of those boats climbed the mountain with no root worth naming and the only skill they had, and used it on the first elder who would not say who gave the order. It took the elder a long time to die of it. The method has carried that name since.

The sects have learned not to kill these people quickly, because killing them quickly does not help. The method ends at Core Formation, since Nascent Soul asks for a quiet heart. A few have swallowed the calming pill at the gate and gone through. They are said to be gentle afterwards, and to sleep badly.

## How It Fights

From the first second the enemy is being nicked by a knife that never seems to matter. The fist opens four wounds on its own, for nothing. Three small strokes open three more. Nothing lands hard, and the health bar starts to fall faster each second without anything visibly changing.

**The signature moment:** a top-end cultivator of the same realm kills them in the first second. The fight is over. The wounds go on working, and the winner stands there and falls from 97 % to 32 % (`variants/thousand-scales-mixed.fight.json --enemy top_end`, with and without `parting_cut`).

**Three things the numbers turned around:**

1. **The arts barely matter.** The plan was fast arts feeding triggers. `trig_cap` allows 6 firings a pulse, and the free fist already fires 4. With no arts at all it still wins the same-realm fight in 6 s on 86 % health (`variants/thousand-scales-fist.fight.json`). So the slots stopped being hit rate and became more wounds: each art adds one more 5 % to the ceiling.
2. **Hatred buys about one second.** Without Kept Grudge the one-realm-up fight ends at 8 s, not 7 (`variants/thousand-scales-mixed.fight.json --without "Kept Grudge" --gap 1`). Forgiven at Nascent Soul on heart demon 20, the build still takes an ordinary Deity with it at 8 s, against 7 s on heart demon 85 (`variants/thousand-scales-forgiven.fight.json`, `-unforgiven.fight.json`). What hatred buys is reach two realms up (enemy left on 57 %, not 75 %) and the aftermath. Most of what they refuse to give up was never doing much.
3. **Offence was wasted.** One stack reaches `dot_pool_cap` at the same realm, so attack points do nothing. The tree goes into body and ward, which is why it lives long enough.

## The Stack

Sizes on new modifiers are first guesses. Stack ladder for the tick channel. The forced push replaced a plain "more poison" rung set with the art-wounds and Parting Cut.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Thin Bleed (Tế Huyết) | On hit, apply a wound named for the piece that carries it: `c_tick` 0.2, 4 pulses, stacks to 5. Wounds from different pieces are different statuses. Held four times here: Bleed, Brine, Gall and Sinew | Trigger | tick | none | ○ | Weapon affix, technique, sealed cluster, Đạo | any blade, Water, poison or thể tu build |
| Rate | None | `trig_cap` is the limit, not hit speed | | | | | | |
| Multiplier | Damage (`attack_pct`) | +60 from the tree, kept low | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Heart Demon Turned to Strength | Capability #25: above 50, `attack_pct` = heart demon ÷ 2 (+40) and qi deviation chance doubled | Per | any | L1 | ● | Tree | **Existing capability** |
| Multiplier | Damage over time | +24 | Increased | tick | L1 | ○ | Tree | **Catalogue row** |
| Multiplier | Kept Grudge (Tàng Hận) | +1 point on over-time tags per point of heart demon (+80) | Per | tick | L2 | ○ | Sealed cluster | any heart-demon build |
| Multiplier | Artifact attack | +40 | Gear | any | L3 | ● | Artifacts | every build |
| Crit | None | Ticks cannot crit. Every wound is a 100 % chance instead | | | | | | |
| Reach | Rub Salt (art) | Shred 0.3 for 3 pulses: body guard is the only thing that meets a tick | Curse | tick | none | ○ | Technique | any tick build |
| Past the cap | **Widening Wound (Khoát Thương)** | Half of what `dot_pulse_cap` clips at a pulse adds to that cap on this target for the rest of the fight. It cannot pass distinct statuses × `dot_pool_cap` | Overflow | tick | none | ○ | Sealed cluster, capability | any poison build |
| Past the cap | Spillover (Dật Độc) | Tick damage a cap clips burns the target's linh lực, within the qi burn cap | Overflow | tick | none | ○ | Đạo | **Reused from the Burial Shroud** |
| Fuel | Unspent Rage (Dư Nộ) | After a fight in which `dot_pulse_cap` clipped, +1 heart demon | Overflow | tick | none | ○ | Đạo | anything else a cap clips and a life could pay for |
| Survival | Body and ward first | Tree into health and ward: `n_body` 2.2, `n_qi` 2.0, common drain ward at top-end strength | Flat | any | none | ● | Tree, Artifacts | any tick build |
| Identity | Parting Cut (Biệt Đao) | When you go Down, your statuses run out before the result is final. You do nothing; the winner may cleanse | Trigger | tick | none | ○ | Đạo keystone | any poison NPC, any assassin hired to die |

**Identity piece:** Widening Wound. Without it the mixed enemy one realm up survives on 13 % and the same-realm top-end leaves on 65 %, not 32 %. It is the difference between a clock and an accelerating clock.
**Empty rungs:** Rate is a real limit, not a gap. L4 is a sacrifice: rage does not prepare, and this build is the same in a blind fight as a foreseen one. L5 does nothing for ticks.

| Layer | Points at Foundation | Multiplier on ticks | Sources |
|---|---|---|---|
| L1 | 124 | ×2.24 | Tree 60, capability #25 40, Damage over time 24 |
| L2 | 80 | ×1.80 | Kept Grudge at heart demon 80. Hits get none |
| L3 | 40 | ×1.40 | One knife and armour |
| L4 | 0 | ×1.00 | Sacrifice |
| L5 | 0 | none | Ticks do not use it |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal and Water at any purity | Metal generates Water, and any poor root will do: the legend needs it |
| Key talents | Physique over Comprehension | The build needs to stand up, not to learn |
| The Way (Đạo) | Destruction, Wrath branch (below) | Destruction already carries `tam_ma_resist_pct` −10, so heart demon gains run ×1.10 |

## Công Pháp

### Scale-Knife Method (Quát Lân Đao Pháp) — main, Huyền giai

A fish-gutter's breathing count, with a knife in it. It stops at Core Formation because nobody who kept it ever went further.

```json
{"id": "quat_lan_dao_phap", "name": "Quát Lân Đao Pháp", "tier": 1, "tech_kind": "main",
 "names": ["kim", "thuy"], "layers": 9,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "scaling_stroke", "unlock_layer": 1}, {"ability_id": "seam_stroke", "unlock_layer": 3},
               {"ability_id": "gill_stroke", "unlock_layer": 5}, {"ability_id": "rub_salt", "unlock_layer": 7}],
 "seal_clusters": ["open_seams"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/15 = 1.0 against Huyền's 2.0, one bonus as the tier's `bonus_count`

## Arts

All paid in linh lực in the normal way, on the common drain ward.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Scaling Stroke (Quát Lân Thức) | Technique, 1, 3, 5 | three forms: body and metal, qi and metal, qi and water; hit | 0.5 | 0.02 | 1 s | none | Needs key |
| Rub Salt (Sát Diêm) | Technique, 7 | curse, water | 0 | 0.03 | 3 s | none | Needs key |

- **Scaling Stroke:** one art in three forms, each slotted on its own, and each also applies its own wound (Scale, Seam, Gill), qi kind, `c_tick` 0.15, 4 pulses. The file's ids `scaling_stroke`, `seam_stroke` and `gill_stroke` are the three forms. Their job is the seventh wound, not the hit. **Description:** three strokes that any apprentice could learn in a morning.
- **Rub Salt:** shred 0.3 for 3 pulses. It does nothing to a soft target and matters against a thể tu. **Description:** the oldest thing anyone has ever done to a wound.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Scaling Stroke in its three forms, Rub Salt | Common drain | The defined build |
| Core Formation | 5 | As above, plus an eighth wound if a piece offers one | Common drain | Tested with the same four: `variants/thousand-scales-core.fight.json` |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Gutter's Knife (Khai Đỗ Đao) | Artifact, weapon | `cham`, any grade, realm tier | Carries the Thin Bleed affix. A generated knife could roll it. It was never a weapon, and that is why it is thin enough | Needs key |
| Any `giap` | Artifact, body | Best available | Ward and body only. Every point of L3 past a little is wasted | Fits today |
| Calming pill (Tĩnh Tâm Đan) | Pill | Existing, −25 heart demon | The valve. The build runs at 80, and takes the pill before any breakthrough, because under 75 a failure cannot reach 90 (see Progression) | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Maximum health, Body guard, Ward strength | as the catalogue | Offence is wasted, so this is where the tree goes | Fits today |
| 2 | Capability #25, Heart Demon Turned to Strength | exists | +40 L1, and it doubles the risk at the next gate | Fits today |
| 3 | Open Seams (below) | size 10 | Kept Grudge, Thin Bleed (Gall) and Widening Wound | Needs key |

### Hidden cluster idea: Open Seams (Khai Phùng Mạch)

Theme: statuses and how they run on a body, wider than this build. Water affinity. Outer, sealed by a technique (Scale-Knife Method lists it, and any poison technique could). Size 10: small acupoints of Damage over time and Status duration, a notable for Thin Bleed (Gall), a notable for Kept Grudge, and Widening Wound as the capability at the far end. An idea for the tree rework, not data.

## Đạo

**Destruction, Wrath branch (Hủy Diệt, Nộ Chi).** A branch for the existing Destruction Đạo, using its `theme_stats`. Signature nodes: Thin Bleed (Sinew, passive), Spillover (passive), Unspent Rage (passive), and Parting Cut as the branch's end. The remaining nodes are stat lines. With the name hidden, a player reads it as someone who stopped caring how a fight ends.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | The defined build: wins its realm in 5 s | Seven wounds on four slots | The first elder |
| Core Formation | The same, one tier up | Heart demon 75 to 85 | Each failed attempt adds 15. At 75 a failure reaches 90, and a deviation at 90 kills, at twice the normal chance with #25 |
| The Nascent Soul gate | Stops | The condition is heart demon at 20 or less | Forgive, with pills and decades, or stay here until the lifespan runs out |
| Nascent Soul (forgiven) | Still kills an ordinary realm-up enemy with them, at 8 s | No #25, Kept Grudge +20 | The numbers: about one second lost |

## Matchups

Against the mixed enemy unless stated. "Takes them along" is a mutual knockout: a loss, the build is Down, and so is the enemy.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical, same realm | Wins, 5 s on 90 % | The bar goes 89, 70, 40, 1 | `variants/thousand-scales-mixed.fight.json` |
| Typical, one realm up | Down at 6 s with the enemy under 1 %, who dies at 7 s | Ward is dry at 4 s. Parting Cut finishes it | same, `--gap 1` |
| Typical, two up | Loses at 3 s, enemy left on 57 % | Stacks cannot reach the cap in time | same, `--gap 2` |
| Top-end, same realm | Dead at 1 s, enemy left on 32 % | Four pulses of aftermath | same, `--enemy top_end` |
| Top-end, one realm up | Dead at 1 s, enemy left on 72 % | | same, `--enemy top_end --gap 1` |
| Big single-art nuker, same realm | Wins, 4 s on 89 %, against 5 s on 87 % without Spillover | Spillover starves the one art that matters | `variants/thousand-scales-nuker.fight.json` |
| Thể tu (guard `a_b` 3, `t_b` 4, +120 %), one realm up | Loses at 6 s, enemy left on 15 %, no mutual kill | Body guard is all a tick meets | `variants/thousand-scales-the-tu.fight.json` |
| Top-end with a 3-status cleanse art, same realm | Dead at 1 s, enemy left on 51 %, not 32 % | The winner cleanses in the aftermath | `variants/thousand-scales-cleanse.fight.json` |

**Counter:** a thể tu with real body guard, then a cleanse. In the fight a cleanse does little, because every hit reopens the wounds. After it, a cleanse is the only thing that saves the winner. A slotted cleanse art is the price the world pays for this build existing.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 1.0 of 2.0. Slots 4 of 4. Arts within the lint (0.5 against 1.24). Thần thức not totalled. Art wounds meet the status lint (0.6 against 0.6). Trigger wounds have no equal-cost art to be read against |
| Validity | PASS | Real elements, tier, bases (`cham`, `giap`), capability #25. Huyền giai `max_realm` is `ket_dan`, which matches the span |
| Stack | PASS | Four forms: Trigger, Increased, Per, Overflow. L5 and L4 stated empty. `--without widening_wound` changes the result one realm up |
| Scaling | PASS | Hit `m_static` 2.80 against typical 4.19, on purpose. Tick multiplier 5.6. Strong at its realm, loses one realm up to a conserving enemy |
| The fight | PASS | Ticks are 88 % of health removed one realm up. Cap hits are the point of the build. Parting Cut is a plug-in, not a stand-in |
| Reuse | PASS | Spillover, capability #25, Damage over time, Tĩnh Tâm Đan. All new modifiers read tags, not the build |
| NPC use | PASS | Passive triggers and plain arts. Parting Cut needs no choice. Each is one Breakdown line |
| Counterplay | PASS | Thể tu, a cleanse art, and burst on a target that has not yet been hit |
| Originality | PASS | No name from an existing work. The death-by-small-cuts idea is historical, and only its shape is borrowed |

## Fight Results

Input: `sheets/thousand-scales.fight.json` and `variants/thousand-scales-mixed.fight.json`. Rules: `widening_wound`, `parting_cut`, `cleanse_art`. Observations from `fight_x.py`, a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical (fixture) | 0 | Win, 92 % | 4 s | never | `dot_pool_cap` 18, `dot_pulse_cap` 12, `trig_cap` 12 |
| typical (fixture) | 1 | Win, 2 % | 6 s | 4 s | `dot_pool_cap` 13, `dot_pulse_cap` 18, `trig_cap` 14 |
| typical (fixture) | 2 | Loss, enemy 70 % | 2 s | 2 s | `trig_cap` 6 |
| top_end (fixture) | 0 | Loss, enemy 32 % | 1 s | 1 s | `dot_pool_cap` 8, `dot_pulse_cap` 11 |
| top_end (fixture) | 1, 2 | Loss, enemy 72 %, 94 % | 1 s | 1 s | `trig_cap` 3 |
| mixed | 0 | Win, 90 % | 5 s | never | `dot_pool_cap` 25, `dot_pulse_cap` 13, `trig_cap` 15 |
| mixed | 1 | Mutual knockout | 7 s | 4 s | `dot_pool_cap` 18, `dot_pulse_cap` 19, `trig_cap` 14 |

**Identity runs** (`variants/thousand-scales-mixed.fight.json`): `--without widening_wound`: gap 1 loses, enemy left on 13 %; top_end left on 65 %. `--without parting_cut`: gap 1 is a plain loss with the enemy under 1 %; top_end left on 97 %. `--without tick_overflow_qi`: same results, enemy linh lực 33 %, not 18 %, at gap 1.

**Second realm:** Core Formation, heart demon 85 (`variants/thousand-scales-core.fight.json`): wins in 5 s on 93 %, mutual knockout one up at 7 s.

**Unmodelled:** Unspent Rage (after the fight). Heart demon is read at compile. Enemy `status_resist_pct` is not tested. `-unforgiven.fight.json` is a comparison only: heart demon 85 cannot pass the gate.

## New Concepts

None. Wounds, triggers, caps and heart demon all exist. Parting Cut is one rule, below.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Widening Wound | Needs rule | Combat Formulas F: `dot_pulse_cap` may rise per target for one fight |
| Parting Cut | Needs rule | Combat rule 14: a result may wait on open statuses. Today a fight ends with a result, never a consequence, so the alternative is to return open wounds in the result and let the caller run them |
| Unspent Rage | Needs rule | Character Stats: heart demon from a fight. Kills add none today, by user decision, so this is a deliberate exception |
| Kept Grudge | Needs key | A `per` on heart demon for over-time tags |
| Thin Bleed | Needs key | Status records and an on-hit trigger format |
| Scale-Knife Method, Scaling Stroke, Rub Salt, Gutter's Knife, Open Seams, Wrath branch | Needs key | Content records. The art catalogue does not exist yet |

**Questions for the user:**

1. The status lint reads `c_tick · duration` against an equal-cost art. A status from a trigger has no such art. Should it have a lint of its own? Today it is limited only by `trig_cap`.
2. Should a Down cultivator's wounds outlive them, or is that one rule too many for rule 14?
3. Unspent Rage breaks "kills add no heart demon" on purpose, for one build. Is that exception acceptable?

## Also Considered

- **Flinch:** clipped tick damage delays the enemy's timers, so the surplus buys survival. A strong idea, but it answers nothing the first time the cap has not clipped, and that is exactly when this build dies.
- **Racing Blood:** art speed also shortens your tick interval. Since the cap is per pulse, it only meant more damage clipped, so it needed the cap rule anyway. Widening Wound is the cleaner statement.
- **Struck Back and Numb With Rage (cut after testing):** a Timing piece that shortened timers when hit, and a guard Conditional on wound count. Neither changed a result, so both left the stack.
