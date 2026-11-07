# The Burial Shroud (Liệm Y Đạo)

> **Status**: Pilot design sheet, 2026-11-07. Not in game data. Numbers on new content are first guesses. The direction was chosen by the skill's author to test it, so nothing here is a user decision.
> **Seed**: "a Death's Oath style aura, then stack around it"
> **Direction**: An always-on tick that exists to strip the ward, not to kill
> **Realm span**: Core Formation – Nascent Soul · **Power level**: strong · **Use**: player build to aim for
> **Fit**: 4 Fits today · 4 Needs key · 3 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets for artifacts: no thần thức total at this realm; Reuse is judged by the second pilot)

## The Spine

- **The channel:** a permanent tick. It uses L1 to L4, skips the ward, and clips at `dot_pool_cap` and `dot_pulse_cap`.
- **The enabler:** the Grave-Silk Shroud opens a tick with no slot, and closes a quarter of the linh lực pool.
- **The loop:** the Rot ticks every pulse; whatever the cap clips burns the enemy's linh lực; hits land once the ward is gone.
- **The engine:** clipped tick damage turns into ward burn, so damage past the cap keeps paying.
- **The sacrifice:** no burst, no pace of its own, and a smaller ward. It cannot race a fast killer.
- **The arc:** at first the Rot is a nuisance. By Core Formation it strips wards in seconds, and the cultivator learns to wait.

## The Legend

Grave-silk is spun by moths that feed in the burial mounds of cultivators, and it keeps a little of what it
was wrapped around. The first shrouds were made to hold a dying master's qi inside the body long enough to
be buried with honour. They held it. They also leaked.

The undertakers of the Salt Road learned that a shroud worn by the living goes on doing its work on
whoever stands near. They stopped burying people in them. Sects burn these robes when they find them, and
the undertakers who still wear one are not invited to funerals, which is to say they are invited to all of
them, by people who have no choice.

## How It Fights

The wearer does almost nothing, and that is the terror of it. From the first pulse the enemy starts to
rot, and the part of the rot their body cannot take eats their linh lực instead. Their ward thins. Then it
is gone, and every plain strike lands in full. **The signature moment:** a sect elder a full realm higher,
ward gone at the fourth second, killed by the wearer's bare hand.

## Enabler

**Grave-Silk Shroud (Liệm Thi Y).** A named body artifact on the `giap` base. A player finds it on a body, in
a burial mound or a looted funeral house.

- **Opens:** Grave Rot, a permanent tick applied at t = 0. No slot, no cooldown, no cost per pulse.
- **Closes:** reserves 25 % of maximum linh lực for as long as it is worn. Reserved linh lực cannot be held,
  spent or used to block.
- **After the fight:** a fight lasting over 10 s costs extra vitality. The caller applies it (rule 14).

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Grave Rot (Thi Độc) | Tick, `c_tick` 0.35, body kind, no duration | Enabler | tick | none | ○ | Artifact | signature |
| Multiplier | Damage (`attack_pct`) | +134 at Core Formation | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Damage over time | +60 to ticks | Increased | tick | L1 | ○ | Tree | any poison build |
| Multiplier | Rot Deepens (Thi Độc Thâm) | +180 points to ticks with the poison tag | More | tick | L2 | ○ | Technique, Đạo | any poison build |
| Multiplier | Artifact attack | +90 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Corpse-Wax Coating (Thi Lạp) | +100 points to ticks, prepared before the fight | More | tick | L4 | ○ | Pill | any poison build |
| Reach | Realm pierce (`pierce_pct`) | +30 | Flat | any | none | ● | Tree | vượt cấp builds |
| Past the cap | **Spillover (Dật Độc)** | Tick damage a cap clips burns the target's linh lực, within the qi burn cap | Overflow | tick | none | ○ | Đạo keystone | any poison build |
| Fuel | Regeneration (`linh_luc_regen_pct`) | +3 % of maximum per second | Flat | any | none | ● | Tree | sustain builds |
| Survival | Body guard (`body_guard_pct`) | +40 | Flat | any | none | ● | Tree, armour | thể tu builds |
| Finish | **Bare Vessel (Lộ Đỉnh)** | +80 points to hits while the enemy has under 5 % linh lực | Conditional | art, basic | L5 | ○ | Sealed cluster | Ninth Bell, any ward-breaker |

**Identity piece:** Spillover. The tick reaches its cap early, so without it the rest of the stack is wasted.
Removing it turns a win one realm up into a loss with the enemy on 55 % health.
**Empty rungs:** Rate is a sacrifice: a tick runs on the pulse and nothing speeds it. Crit is a sacrifice: ticks cannot crit.

| Layer | Points at Core Formation (ticks) | Multiplier | Sources |
|---|---|---|---|
| L1 | 194 | ×2.94 | `attack_pct`, damage over time |
| L2 | 180 | ×2.80 | Rot Deepens |
| L3 | 90 | ×1.90 | Gear |
| L4 | 100 | ×2.00 | Corpse-Wax Coating; a blind fight loses it |
| L5 | 0 | ×1.00 | Ticks cannot use L5; only the hits gain Bare Vessel |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Earth and Water | Harmony with the method, and the Darkness variant suits the path |
| Key talents | Physique | Body guard and health carry a ward that is a quarter smaller |
| The Way (Đạo) | Death, with the Burial branch below | Holds Spillover |

## Công Pháp

### Withered Mound Sutra (Khô Trủng Kinh) — main, Địa giai

A manual on keeping the dead from spoiling, annotated by someone who stopped caring about the dead.

```json
{"id": "kho_trung_kinh", "name": "Khô Trủng Kinh", "tier": 2, "tech_kind": "main",
 "names": ["tho", "thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 12},
             {"stat": "defense_pct", "value": 10}],
 "abilities": [{"ability_id": "grave_wind", "unlock_layer": 4},
               {"ability_id": "bier_hush", "unlock_layer": 7},
               {"ability_id": "closing_the_lid", "unlock_layer": 10}],
 "seal_clusters": ["sick_meridians"], "origin": "authored"}
```

**Fit:** Needs key (abilities; `seal_clusters` is unread today) · **Budget:** 15/20 + 12/15 + 10/15 = 2.22 of 3.0, each under the single cap

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Grave Wind (Mộ Phong) | Sutra, 4 | qi, poison, over time | 1.2 | 0.05 | 2 s | none | Needs key |
| Bier Hush (Tịch Liệm) | Sutra, 7 | qi, curse | 1.5 | 0.06 | 3 s | none | Needs key |
| Closing the Lid (Hợp Quan) | Sutra, 10 | body, hit | 3.2 | health 0.05 | 5 s | enemy linh lực below 5 % | Needs key |

- **Grave Wind.** **Effect:** a qi hit that applies Wither, `c_tick` 0.3, 4 pulses, a second tick so the pulse cap is reached. **Description:** The air over an opened grave.
- **Bier Hush.** **Effect:** a curse that blocks regeneration for 3 pulses, so burned linh lực stays gone. **Description:** Nobody speaks while the bier passes.
- **Closing the Lid.** **Effect:** a finishing hit paid in health, because by then the build has no linh lực left to pay with. **Description:** The last courtesy.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | Closing the Lid, Bier Hush, Grave Wind | Common | Two slots free for an escape talisman and an answer |
| Nascent Soul | 6 | As above | Common | A soul answer takes the extra slot |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Grave-Silk Shroud | Artifact, body | `giap`, named | The enabler | Needs rule |
| Corpse-Wax Coating | Pill, preparation | new | Fills L4 for ticks | Needs key |
| Any weapon pieces | Artifact, weapon | Generated | L3, which also feeds the plain hits | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Sick Meridians | Sealed cluster | Bare Vessel, and the tick stack | Needs key |
| 2 | Body guard notables | +8 each | The ward is smaller | Fits today |
| 3 | Regeneration | +1 % notable | The reservation lowers the ceiling, not the rate | Fits today |

### Hidden cluster idea: Sick Meridians (Bệnh Mạch)

Theme: Way of Alchemy, the study of what poisons the body. Earth affinity, outer, sealed. Seal condition: a
technique that lists it. Size 8, so one notable. The small acupoints give damage over time and status duration.
The notable is Bare Vessel. It serves any build that strips linh lực, not only this one.

## Đạo

**Death, Burial branch (proposal).** A branch of the Death Đạo, requirement unchanged. Its nodes are tick and
reservation lines from Death's `theme_stats`. Its keystone is Spillover. An art node can hold Bier Hush for a
character without the Sutra.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A weak poisoner | Grave Wind | Finding the robe, and not knowing what it is |
| Core Formation | The ward-stripper | Spillover, Bier Hush | The first funeral they are not invited to |
| Nascent Soul | Hunts upward | Closing the Lid | A body that no longer quite warms |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical, same realm | Wins, 4 s | Enemy spends its own ward and Spillover finishes it |
| Typical, one realm up | Wins, 6 s, at 6 % health | The defining fight, and a close one |
| ×4 boss | Wins, 11 s | Ticks are shares of health, so a big pool barely slows them |
| Typical, two realms up | Loses, 2 s | Hits arrive faster than the clock |
| Any top-end burst | Loses, 1 s | It is dead before the second pulse |

**Counter:** burst. Anyone who kills by the first volley never meets the clock. A cleanse also removes Wither, though not the Rot itself.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.22 of 3.0 and all three arts inside the lint; slots 3 of 5. Thần thức for the artifact set was not totalled at this realm |
| Validity | PASS | Elements, `dia` tier and `giap` base are real; `dia` reaches Nascent Soul |
| Stack | PASS | Seven forms; every rung filled or named; identity test changes the result from a win to a loss |
| Scaling | PASS | Tick M about 31 at Core Formation, between the anchors, as a strong build should be. INFO: beats one realm up, which the GDD reserves for top-end |
| The fight | PASS | Constants 60 of 60; selftest clean; the loop runs; own linh lực dry at 3 s one realm up, which is the price paid |
| Reuse | NOT ASSESSED | First build, so nothing to reuse. Second homes are named |
| NPC use | PASS | All pieces are passive or guarded; Spillover is one Breakdown line |
| Counterplay | PASS | Top-end burst wins in 1 s |
| Originality | PASS | The structure comes from a PoE item; no name or effect text is taken from any work |

## Fight Results

Input: `design/builds/burial-shroud.fight.json`. Observations from `fight_calc.py`, a paper model with expected
values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 92 % health left | 4 s | never | tick caps |
| typical | 1 | Win, 6 % health left | 6 s | 3 s | tick caps |
| typical | 2 | Loss, enemy on 93 % | 2 s | 1 s | none |
| top_end | 0 to 2 | Loss, enemy on 94 % or more | 1 s | 1 s | tick cap |

Identity test, typical one realm up: without Spillover, a loss with the enemy on 55 %. Without Bare Vessel, a loss with the enemy on 4 %.

**Unmodelled:** when a reservation can be released; enemy cleanses, since the reference enemies have none; the vitality cost after a long fight.

## New Concepts

**Reservation.** A share of maximum linh lực held out of the pool for a lasting effect.

- **Rule needed:** Combat rule 11 says nothing reserves linh lực, so this is an exception to it. Art costs stay
  a share of maximum, so a reservation weakens the ward without making arts cheaper.
- **Bounds:** the total reserved has a cap, and a Breakdown line shows it.
- **Other builds:** any standing effect, such as a held formation or a kept ward; a build that pays to keep a talisman ready.
- **Question for the user:** should reservation be a general system, or stay on a few named pieces?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Grave Rot, permanent status | Needs rule | Combat rule 7: a status with no duration, and how a cleanse treats it |
| Reservation | Needs rule | Combat rule 11, see New Concepts |
| Spillover | Needs rule | Combat Formulas F: where clipped tick damage goes |
| Damage over time, Rot Deepens, Corpse-Wax Coating | Needs key | Tagged modifier keys (catalogue, To settle) |
| Bare Vessel | Needs key | An L5 modifier with a linh lực condition |
| The three arts, Withered Mound Sutra | Needs key | The art record format and an ability catalogue (Combat Open Question 13) |
