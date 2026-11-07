# The Ninth Bell (Cửu Hưởng Đạo)

> **Status**: Pilot design sheet, 2026-11-07. Not in game data. Numbers on new content are first guesses. The direction was chosen by the skill's author to test it, so nothing here is a user decision.
> **Seed**: "art speed should be something you tune, not something you just stack"
> **Direction**: A rhythm build with no enabler: arts that land on the pulse
> **Realm span**: Foundation Establishment – Deity Transformation · **Power level**: ordinary, with a high ceiling · **Use**: player build to aim for
> **Fit**: 3 Fits today · 4 Needs key · 1 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets for artifacts: no thần thức total at this realm; NPC use: the generator would need a way to tune art speed)

## The Spine

- **The channel:** art hits, using all five layers and crit, through the ward.
- **The enabler:** none. It is a stack, and the condition is the whole build.
- **The loop:** three arts on cooldowns that land exactly on the pulse, each hit riding the beat.
- **The engine:** art speed tuned to the exact value that makes every cooldown a whole number of pulses.
- **The sacrifice:** no defence worth the name, and any art speed past the right value makes it weaker.
- **The arc:** at first the player chases speed. Later they refuse it, which is the moment they understand.

## The Legend

The monks of a burned bell tower kept their hours after the tower was gone, striking the air where the
bell had been. Their method was never written as a fighting art. It is a timetable, and a very exact one.

The people who walk this path tend to be exact about everything. They arrive when they say they will. Those
who fought one say the worst of it was realising, a beat early, when the next blow would come.

## How It Fights

Three arts strike on the first, second and third beat, in a pattern that only lines up because the
cultivator refused to be any faster. The rhythm costs them speed, and it makes every hit far heavier.
**The signature moment:** a boss meant to last half a minute falls on the third beat, when the great
bell rings for the first time and deals half the fight's damage in one stroke.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Three bell arts | `c_art` 2.4, 3.3, 4.5, authored at 2, 4 and 6 s | Base | art | none | ○ | Technique | signature |
| Rate | Art speed (`art_speed_pct`) | Exactly +100, so 1, 2 and 3 s | Timing | art | none | ◐ | Tree, Technique | every art build, as a plain stat |
| Multiplier | Damage (`attack_pct`) | +134 at Core Formation | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Metal damage | +20 to Metal arts | Increased | art | L1 | ○ | Tree | any Metal build |
| Multiplier | Tolled Seal (Chung Ấn) | +30 points to arts with the seal form | More | art | L2 | ○ | Technique | any seal build |
| Multiplier | Sustained Note (Dư Âm) | +15 points per second of the fight, to arts, up to +90 | Per | art | L2 | ○ | Đạo | Late Bloom builds |
| Multiplier | Artifact attack | +110 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Ringing Ground (Hưởng Địa) | +20 points to arts, from a formation | More | art | L4 | ○ | Formation | any seal build |
| Multiplier | **On the Beat (Hợp Tiết)** | +70 points to an art that fires in the same millisecond as a pulse | Conditional | art | L5 | ○ | Sealed cluster | any fast-art build, Five Phases Cycle |
| Finish | Bare Vessel (Lộ Đỉnh) | +30 points to hits while the enemy has under 5 % linh lực | Conditional | art, basic | L5 | ○ | Sealed cluster | **Reused from the Burial Shroud** |
| Fuel | Art cost (`art_cost_pct`) | −25 % | Flat | art | none | ● | Tree | sustain builds |
| Fuel | Regeneration (`linh_luc_regen_pct`) | +4 % of maximum per second | Flat | any | none | ● | Tree | sustain builds |

**Identity piece:** On the Beat. Rule 10 resolves the pulse first, so an on-beat art is also paid for by that
pulse's regeneration. One realm up, the same build leaves the enemy on 59 % health on the beat, 75 % at +120 art
speed and 91 % at +60.
**Empty rungs:** Crit is a sacrifice, because it would pull the build towards chance. Survival is a sacrifice, and the matchups show the bill.

| Layer | Points at Core Formation (arts) | Multiplier | Sources |
|---|---|---|---|
| L1 | 154 | ×2.54 | `attack_pct`, Metal damage |
| L2 | 30 to 120 | ×1.3 to ×2.2 | Tolled Seal, Sustained Note |
| L3 | 110 | ×2.10 | Gear |
| L4 | 20 | ×1.20 | Ringing Ground; a blind fight loses it |
| L5 | 70 to 100 | ×1.7 to ×2.0 | On the Beat, Bare Vessel |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal | Purity feeds the method and the bell |
| Key talents | Comprehension | Technique strength, and the art speed comes from precision |
| The Way (Đạo) | Time, a Rhythm branch | Holds Sustained Note |

## Công Pháp

### Nine-Toll Timetable (Cửu Hưởng Thời Khắc Biểu) — main, Thiên giai

Not a fighting manual. Every page is a schedule.

```json
{"id": "cuu_huong_bieu", "name": "Cửu Hưởng Thời Khắc Biểu", "tier": 3, "tech_kind": "main",
 "names": ["kim"], "layers": 15,
 "bonuses": [{"stat": "linh_luc_pct", "value": 18}, {"stat": "than_thuc_pct", "value": 12},
             {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "first_toll", "unlock_layer": 3},
               {"ability_id": "second_toll", "unlock_layer": 7},
               {"ability_id": "great_toll", "unlock_layer": 11}],
 "seal_clusters": ["measured_breath"], "origin": "authored"}
```

**Fit:** Needs key (abilities; `seal_clusters` is unread today) · **Budget:** 18/20 + 12/15 + 10/15 = 2.37 of 4.0, each under the single cap

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| First Toll (Nhất Hưởng) | Timetable, 3 | qi, seal, Metal | 2.4 | 0.10 | 2 s | none | Needs key |
| Second Toll (Nhị Hưởng) | Timetable, 7 | body, seal, Metal | 3.3 | 0.14 | 4 s | none | Needs key |
| Great Toll (Đại Hưởng) | Timetable, 11 | qi, seal, Metal | 4.5 | 0.20 | 6 s | none | Needs key |

Each **Effect** is a hit. **Description:** the small bell, the middle bell, and the bell that is no longer there.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Core Formation | 5 | First, Second, Great | Common | Two free slots hold the build's only defence |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Any bell | Artifact, ward and weapon | `chuong`, generated | Its defence feeds the ward, and a bell suits the path | Fits today |
| Ringing Ground | Formation, preparation | new | Fills L4 for arts | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Measured Breath | Sealed cluster | On the Beat | Needs rule |
| 2 | Art speed | To exactly +100 | Past that, the build loses power | Needs key |
| 3 | Art cost, regeneration | Notables | Fuel | Fits today |

### Hidden cluster idea: Measured Breath (Điều Tức)

Theme: Heart State, the discipline of a steady mind. Metal affinity, outer, sealed. Seal condition: a technique
that lists it. Size 7, so it can hold a capability. The small acupoints give art speed and regeneration. The notable is On the
Beat. Bare Vessel can also sit here for a character who has not found Sick Meridians.

## Đạo

**Time, Rhythm branch (proposal).** A branch of the Time Đạo. Its nodes come from Time's `theme_stats`. It holds Sustained Note,
and an art node for a beat-keeping guard.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A slow art user | First Toll | Reading a timetable and thinking it worthless |
| Core Formation | The rhythm appears | On the Beat | Refusing a speed bonus for the first time |
| Deity Transformation | Seven arts in one meter | More slots, longer cycles | Everything is on time now, including the end |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical, same realm | Wins, 2 s | Two beats of heavy hits |
| ×4 boss | Wins, 3 s | The Great Toll fires at 3 s and deals half the damage |
| Typical, one realm up | Loses, 2 s, enemy on 59 % | No defence, so it dies on the second beat |
| Any top-end build | Loses, 1 s | Both sides fire at t = 1, and only one is strong enough |

**Counter:** anything that hits hard early. It has no way to survive the opening. A drainer also hurts it, since a missed beat from lack of linh lực loses the bonus.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.37 of 4.0 and all three arts inside the lint after the first draft failed it; slots 3 of 5. Thần thức not totalled |
| Validity | PASS | Metal, `thien` tier and `chuong` base are real |
| Stack | PASS | Five forms; identity test: without On the Beat, the build ends on 69 % health instead of 79 %, and one realm up the enemy keeps far more |
| Scaling | PASS | Art M about 15 to 28 with conditions, between the anchors |
| The fight | PASS | Constants 60 of 60; selftest clean; the Great Toll fires against a boss and never in an ordinary fight, which the sheet accepts |
| Reuse | PASS | Bare Vessel reused from the Burial Shroud, unchanged |
| NPC use | NOT ASSESSED | The generator picks stats and does not tune to an exact value; it would need a rule for this, or NPCs simply miss the beat |
| Counterplay | PASS | Early burst wins |
| Originality | PASS | Original structure and names |

## Fight Results

Input: `design/builds/ninth-bell.fight.json`. Observations from `fight_calc.py`, a paper model with expected
values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 79 % health left | 2 s | never | none |
| typical | 1 | Loss, enemy on 59 % | 2 s | 2 s | none |
| typical | 2 | Loss, enemy on 98 % | 1 s | 1 s | none |
| top_end | 0 to 2 | Loss, enemy on 91 % or more | 1 s | 1 s | none |

**A real choice.** Against a weak enemy, plain speed beats the rhythm: at +120 art speed the fight ends at 1.82 s against 2.00 s. Against a strong one, the rhythm wins by a long way. So art speed is a decision, not a stat to max.

**Unmodelled:** Sustained Note's cap, and a reset on a missed beat. Fights end before either matters.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| On the Beat | Needs rule | Combat rule 13: a condition on firing in the same millisecond as a pulse, and whether it needs a new guard word |
| Sustained Note, Tolled Seal, Metal damage | Needs key | Tagged and per-second modifier keys |
| Ringing Ground | Needs key | A formation entry that fills L4 |
| Three arts, Nine-Toll Timetable | Needs key | The art record format and ability catalogue |
