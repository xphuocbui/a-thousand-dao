# The Turned-Away (Cự Quan Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Failed breakthroughs as power: scar tissue on the soul, a build that wants to fail."
> **Direction**: Every failed gate leaves a scar, and each scar lets you fail at dying once. Stronger than the seed's plain reading, a stat per failure, which became one modifier here (see Also Considered).
> **Realm span**: Foundation Establishment – Core Formation, and meant to stop there · **Power level**: strong at 4 scars, a legend at 6 or more · **Use**: player build, and a reason to fear old failures in the world
> **Fit**: 6 Fits today · 10 Needs key · 5 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: thần thức for artifacts not totalled)
> **Repair**: Turned Away now runs as `rules/turned_away.py`, in place of the per-hit ward stand-in and the `rule_model` block. Every rule-model number reproduced from saved files. The stand-in's table and its numbers are gone, and The fight moves from NOT ASSESSED to PASS.

## The Spine

- **The channel:** art hits and the basic attack, thrown from 5 % health. All five layers count. The real resource is instants survived.
- **The enabler:** The Copyist's Error, on the Spent Kiln Sutra. Opens unlimited failed attempts, each leaving a Gate Scar. Closes every great breakthrough while it is the main method.
- **The loop:** die in the first second, stand up at 5 %, hit harder, die again. Each scar buys one more instant.
- **The engine:** the ward is switched off, so linh lực pays only for refusals, and arts are paid in health, which is free when you have none left.
- **The sacrifice:** no ward, no next realm, no escape, a fixed number of instants. Anyone who makes many instants ends it.
- **The arc:** a cultivator the gate refused takes up a manual they know is wrong. They stop climbing and start counting.

## The Legend

The potters of Ash Ferry treated the great gate as a firing: draw the fire up through the body and hold it. One copyist, paid by the line, wrote *draw it down*. Nobody noticed for two generations, because the gate refuses most people anyway. Then a rival sect came to break the kilns and found that the oldest failures of Ash Ferry would not stay down.

The true text burned with the kilns. Only the error survives. The people who read it now are mostly those a gate has already turned away, late in life, with a full bar and no pill. They can see the line is wrong, and they breathe it anyway. Proper sects burn the copies out of mercy. A sect elder who meets one on a road learns what a century of refusal does to a body, and why nobody has ever tested the last chapter.

## How It Fights

The ward is off. The first hit kills them, and it does not take: they stand at 5 % health with a little less linh lực. Every art they own is paid in health, and at 5 % there is nothing left to charge. Each refusal makes the next blow heavier, until the enemy's own casting has emptied its ward. **The signature moment:** a Nascent Soul elder strikes them down four times in four seconds, and on the fourth, a Core Formation cultivator at 5 % health kills them with a plain blow.

## Enabler

**The Copyist's Error (Sao Ngộ).** Carried by the Spent Kiln Sutra as main method. Found in a burnt kiln town, on a sect's forbidden shelf, or on the body of someone very old.

- **Opens:** while it is the main method, a great breakthrough attempt needs no pill and ignores `bare_attempt_cap`. Each failure leaves one Gate Scar (Quan Ngân), up to the layers of the Sutra reached (12 at most).
- **Closes:** every attempt under it fails, with no roll. All of Realms rule 10's penalties still land: 30 % of the bar, +15 heart demon, 40 % of vitality, the deviation roll.
- **The way out:** swap the main method (free at a season start) and attempt normally. A successful great breakthrough closes every scar, to 0. That is the choice a legend is offered: a perfect pill, and the end of everything they are.

The real limit is heart demon. The gain lands before the deviation roll, and death needs 90 or more, so an attempt at 74 or below cannot kill. At 0.25 decay a season that is one safe scar per 15 years: 4 scars is 60 years, 8 is 120. Core Formation's lifespan is 500. Tĩnh Tâm Đan (−25) buys time.

## The Stack

Sizes on new modifiers are first guesses. Numbers shown are for 4 scars at Core Formation.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Cracked Perfection (Liệt Viên Mãn) | +0.05 to `stage_mult` on damage per Gate Scar, past great perfection: 1.65 | Per | any | none | ○ | Đạo keystone | any cultivator stuck at a gate |
| Rate | Art speed (`art_speed_pct`) | +20 | Flat | art | none | ◐ | Tree | every art build |
| Multiplier | Damage (`attack_pct`) | +134 at Core Formation | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Heart Demon Turned to Strength (#25) | +35 at heart demon 70, doubles deviation | Increased | any | L1 | ● | Capability | any high heart demon build |
| Multiplier | Refused Force (Cự Lực) | +15 points to hits per health floor held this fight | Per | art, basic | L2 | ○ | Đạo | any build with a floor, such as Unyielding Breath |
| Multiplier | Artifact attack | +90 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Raw Scar (Tân Ngân) | +30 points to hits for 4 seasons after a failed great breakthrough, in any situation, even a blind fight | Trade | any | L4 | ○ | Đạo | anyone who fails on purpose before a duel |
| Multiplier | Reopened (Tái Liệt) | +0.6 points to hits per 1 % of health missing, so +57 at the floor | Per | art, basic | L5 | ○ | Sealed cluster | any low-health build |
| Multiplier | Bare Vessel (Lộ Đỉnh) | +30 points to hits while the enemy has under 5 % linh lực. Lesser grade, +30. The same modifier has a greater grade, +80, in Great Tonic, Remnant Host, Struck Name and Taster's Fever; one size would change fights | Conditional | art, basic | L5 | ○ reused | Tree | Ninth Bell, Burial Shroud |
| Reach | Known Gate (Thức Quan) | +5 pierce per Gate Scar: they have felt what is behind it | Per | any | none | ○ | Đạo | vượt cấp builds |
| Fuel | Arts paid in health | `body_cost_share` cannot take health below 1, and a floor resets it, so the cost is nearly free at 5 % | Rule, existing | art | none | ● | Combat Formulas E | any health-paid art |
| Fuel | Ward off | Rule 22: a side may switch its ward off, so linh lực pays only for refusals | Rule, existing | any | none | ● | Loadout | any pool-spending keystone |
| Survival | **Turned Away (Bế Môn)** | At the defeat check, a side at 0 health with an unopened Gate Scar and 15 % of maximum linh lực pays it, opens one scar and stands at 5 % health. One per instant | Rule swap | any | none | ○ | Sutra ability, layer 3 | any build with stored floors |
| Survival | Numb Soul (Ma Hồn) | +8 `soul_res_pct` per Gate Scar: scar tissue feels nothing | Per | soul | none | ○ | Đạo | any soul-exposed build |

**Identity piece:** Turned Away. Without it the build loses every fight in the matrix at t = 1, because it has no ward by choice.
**Empty rungs:** Crit is a sacrifice: nothing here wants chance. Past the cap is a sacrifice: when the floors run out, the fight is over. In practice the pool caps refusals: at 15 % each, with regeneration, a fight held 8 even with 12 scars (`variants/turned-away-scars-12.fight.json`, top-end two up), so more scars add stats and no more instants.

| Layer | Points at Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 169 | ×2.69 | `attack_pct` 134, capability #25 35 |
| L2 | 0 to 60 | ×1.00 to ×1.60 | Refused Force, per floor held |
| L3 | 90 | ×1.90 | Gear |
| L4 | 30 | ×1.30 | Raw Scar. Gone in a cold fight |
| L5 | up to 87 | up to ×1.87 | Reopened 57 at the floor, Bare Vessel 30 |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Fire and Earth, any purity | The Sutra names them. A weak root is the usual reason to be here, and costs little: nobody on this path needs speed |
| Key talents | Dao heart, Physique | Dao heart slows deviation, Physique sets the health the floor is a share of |
| The Way (Đạo) | Way of the Threshold, below | Holds Cracked Perfection and the per-scar lines |

## Công Pháp

### Spent Kiln Sutra (Phế Diêu Kinh) — main, Địa giai

A firing manual for the body, correct in every line but one.

```json
{"id": "phe_dieu_kinh", "name": "Phế Diêu Kinh", "tier": 2, "tech_kind": "main",
 "names": ["hoa", "tho"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 15},
             {"stat": "lifespan_years", "value": 15}],
 "abilities": [{"ability_id": "hairline", "unlock_layer": 1},
               {"ability_id": "turned_away", "unlock_layer": 3},
               {"ability_id": "second_firing", "unlock_layer": 6},
               {"ability_id": "gate_opens_inward", "unlock_layer": 9}],
 "seal_clusters": ["waster_heap"], "origin": "authored"}
```

**Flaw:** the reversed line is the whole of The Copyist's Error. Nobody has passed a gate under it, so its last chapter, on what lies past the gate, cannot be tested by anyone who reads it.
**Fit:** Needs rule (Realms rules 8, 10 and 11) · **Budget:** 15/15 + 15/20 + 15/15 = 2.75 of 3.0, each under the single cap

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Hairline (Liệt Văn) | Sutra, 1 | qi, Fire | 2.2 | health 0.04 | 2 s | none | Needs key |
| Second Firing (Tái Thiêu) | Sutra, 6 | body, Earth | 2.9 | health 0.06 | 3 s | none | Needs key |
| The Gate Opens Inward (Môn Nội Khai) | Sutra, 9 | qi, Fire, Earth | 4.1 | health 0.08 | 6 s | none | Needs key |

- **Hairline.** **Effect:** a hit. **Description:** The first crack in a glaze makes no sound.
- **Second Firing.** **Effect:** a hit. **Description:** What survives the kiln twice is not the same clay.
- **The Gate Opens Inward.** **Effect:** a hit. At +20 art speed its first firing is at 5 s, which is the last instant four scars buy, and a dying side still acts in it. **Description:** Everyone pushed. Nobody thought to pull.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Gate Opens Inward, Second Firing, Hairline | Off from the first scar | Two scars is about all a young life can hold. Run at L1 100, L3 50, L4 30 |
| Core Formation | 5 | Gate Opens Inward, Second Firing, Hairline | Off | Two slots free. Nothing in the build wants an escape |
| Core Formation, 7+ scars | 5 | As above, then Hearth Ash Talisman | Off | The pool now limits refusals, so fuel takes a slot |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Hearth Ash Talisman (Lô Hôi Phù) | Talisman | new | Refunds 15 % of maximum linh lực while under 45 %. Swept from a kiln gone cold. One more refusal, for those who have outlived their pool | Needs key |
| Tĩnh Tâm Đan | Pill | existing | −25 heart demon, so a scar need not wait 15 years | Fits today |
| Any weapon pieces | Artifact, weapon | Generated | L3 only. Defence that feeds a ward is wasted here | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Way of the Threshold keystone | Cracked Perfection | Damage that scales with the life they chose | Needs rule |
| 2 | Waster Heap | Sealed cluster | Reopened | Needs key |
| 3 | `attack_pct`, regeneration notables | +8, +1 % | Base damage, and a little more fuel | Fits today |

### Hidden cluster idea: Waster Heap (Phế Đôi)

Theme: wounds and vitality, the heap behind every kiln where failed pots are thrown. Earth affinity, outer, sealed. Seal condition: a technique that lists it, or three failed great breakthroughs in one life, so anyone a gate has beaten can open it. Size 8, so one notable. The small acupoints give health and body guard, because the floor is a share of health. The notable is Reopened. It serves any build that lives at low health.

## Đạo

**Way of the Threshold (Hạm Đạo), proposal.** Requirement: Fire and Earth at purity 25. `theme_stats`: `khi_huyet_pct`, `body_guard_pct`, `pierce_pct`, `soul_res_pct`, `tam_ma_resist_pct`. With its name hidden, its nodes read as gates, knocking and refusal. 20 nodes.

- **Knock (Khấu), 7 nodes:** attempts and what they teach. Signature nodes: Known Gate; Raw Scar; a passive that lowers a failed attempt's bar loss from 30 % to 20 %, so a scar takes less time to refill.
- **Crack (Liệt), 6 nodes:** what failure leaves in the body. `khi_huyet_pct` and `body_guard_pct` lines, and Numb Soul.
- **Refusal (Cự), 6 nodes:** what it is to be refused. Refused Force, plus `tam_ma_resist_pct` lines that keep a cultivator under 74.
- **Keystone: Cracked Perfection.** Rule 4 allows it: it moves no Character Stats ceiling and no root factor, and the scar count bounds it.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Beats an equal, loses one realm up (enemy on 62 %, 2 scars; `variants/turned-away-foundation.fight.json`) | Turned Away, the arts | Refused at the gate with years left, and finding the wrong copy |
| Core Formation, 4 scars | Beats one realm up. The defining build | The Way | Sixty years spent failing on purpose. Their juniors have passed them |
| Core Formation, 6 scars | Beats two realms up and a top-end one up | Waster Heap | Nobody alive remembers why they stayed |
| Core Formation, 8 scars | The same brackets, with the pool as the new limit | Hearth Ash Talisman | Someone brings a perfect pill. They look at it for a long time |

## Matchups

From `sheets/turned-away.fight.json`, at 4 scars unless stated.

| Enemy | Result | Why |
|---|---|---|
| Typical, same realm | Wins, 2.0 s, 2 scars | Barely needs the build |
| Typical, one realm up | Wins, 4.0 s, 4 scars, at 5 % | The defining fight. Its ward is nearly empty by the third second |
| Typical, two realms up | Loses, 5.0 s, enemy on 23 % | Six scars win this |
| Top-end, same realm | Wins, 3.3 s, 3 scars | The size of a hit means nothing to a floor |
| Top-end, one realm up | Loses a double knockout at 5.0 s | Gate Opens Inward lands in the last instant, and overkill decides |
| Swarm, one realm up (three small arts off the beat; `variants/turned-away-swarm.fight.json`) | Loses, 1.4 s, enemy on 93 % | Four instants in 1.4 s. The real counter |
| Soul piercer, one realm up (`variants/turned-away-soul.fight.json`) | Wins, 3.3 s | A floor does not care what kind of blow it was |

**Counter:** a fast enemy of many small arts on separate timers, such as a Thousand Cuts swordsman. Damage does not matter to this build. Instants do.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.75 of 3.0; three arts inside the lint; slots 3 of 5. Thần thức for the artifact set was not totalled |
| Validity | PASS | `hoa`, `tho`, tier `dia` real; `dia` reaches Nascent Soul and the build stops at Core Formation. Stage 1.45, +15 heart demon, 0.25 decay, threshold 90, floor 5 %, `bare_attempt_cap` 3 read from the GDDs and data |
| Stack | PASS | Five named forms (Increased, Per, Conditional, Trade, Rule swap); every rung filled or named. `--without turned_away`: a loss in every cell at t = 1 |
| Scaling | PASS | `m_static` 6.64 against anchors 5.48 and 210. INFO: 4 scars beat one realm up and a top-end equal, and 6 beat two up. Noted, not shaved |
| The fight | PASS | Constants 60 of 60, selftest clean. Turned Away runs through `rules/turned_away.py` at the defeat check, and the loop happens |
| Reuse | PASS | Bare Vessel reused; #25, Tĩnh Tâm Đan, rule 22's ward off and Formulas E's health costs reused. Every new modifier has a second home |
| NPC use | PASS | All passive, no input. NPC fate rolls already produce failures, so old failures can read as scars. One Breakdown line: "Turned Away: scar 3 of 4 opened, 15 % linh lực paid" |
| Counterplay | PASS | A swarm wins in 1.4 s, and Thousand Cuts in the catalogue makes such an enemy |
| Originality | PASS | Kiln, copyist and Ash Ferry are original. No name or effect text taken from any work |

## Fight Results

Input: `design/builds/overnight-2026-11-07/sheets/turned-away.fight.json`. Observations from `_tools/fight_x.py`, the calculator plus `rules/turned_away.py`: a paper model with expected values, not the game. Its rule: at the defeat check, a side at 0 health with `scar_floor` left and `scar_cost_share` of its pool pays, opens a scar and stands at `scar_floor_share`, once per instant. Own linh lực never ran dry and no cap was hit in any cell.

| Enemy | Gap | Result | Time | Scars used |
|---|---|---|---|---|
| typical | 0 | Win, 5 % health | 2.00 s | 2 |
| typical | 1 | Win, 5 % health | 4.00 s | 4 |
| typical | 2 | Loss, enemy on 23 % | 5.00 s | 4 |
| top_end | 0 | Win, 1 % health | 3.33 s | 3 |
| top_end | 1 | Loss, double knockout on overkill | 5.00 s | 4 |
| top_end | 2 | Loss, enemy on 95 % | 5.00 s | 4 |

Scar count, same stack: 2 scars lose one up with the enemy on 43 % (`variants/turned-away-scars-2.fight.json`); 6 win two up and top-end one up, each in 5.0 s (`variants/turned-away-scars-6.fight.json`); 8 keep those brackets, and top-end two up is still a loss (`variants/turned-away-scars-8.fight.json`).

**What the numbers changed.**

- **The ward was the enemy.** A common ward (ws 60) turns the win one up into a loss with the enemy on 79 %, because blocking spends the linh lực that pays for refusals (`variants/turned-away-common-ward.fight.json`). The sacrifice became the engine.
- **A planned modifier made it worse.** Second Attempt shortened timers by 0.5 s when a floor held. Two up went from enemy on 23 % to 51 %, and top-end one up from enemy on 0 % to 21 % (`variants/turned-away-second-attempt.fight.json`). Firing sooner is not better here. It was cut.
- **Health-paid arts are the margin.** With the same arts paid in linh lực, the pool ends at 0 in the five-second fights, leaving nothing against a drainer (`variants/turned-away-paid-in-linh-luc.fight.json`).
- **Enemies beat themselves.** The reference enemy spends its own ward dry within seconds, so surviving is itself offence. Bare Vessel pays because of this.

**Unmodelled:** the timing of Raw Scar, which is set by hand (a cold fight still wins one up, in 5.0 s: `variants/turned-away-cold.fight.json`); the after-fight rule below; cleanses, since a floor is not a status.

## New Concepts

**Gate Scar (Quan Ngân).** A saved count of failed great breakthroughs in a life.

- **Rule needed:** Realms rule 10 adds `gate_scars` +1 on any failure, for every character, and rule 9 resets it to 0 on a success. It does nothing without a piece that reads it. Combat rule 14: a scar opened in a fight stays raw and unusable for 8 seasons, reported in the result and applied by the caller.
- **Bounds:** the Sutra caps usable scars at its layers reached, 12 at most. Heart demon and lifespan bound the rest.
- **Breakdown line:** "Gate Scars 4: stage +0.20, pierce +20, soul resistance +32".
- **Other builds:** a tribulation survivor build (seed 62); a never-upgraded cultivator (seed 20); any NPC elder the world has already failed.
- **Question for the user:** the difficulty targets mean most lives stall at a gate. Should a stalled life have a real second path? This build says yes, and that changes how failure feels across the whole game.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Turned Away | Needs rule | Combat rule 10, defeat check: a floor before Down |
| The Copyist's Error, Spent Kiln Sutra | Needs rule | Realms rules 8, 10, 11: an attempt that always fails, with no pill and no cap |
| Gate Scar | Needs rule | See New Concepts |
| Cracked Perfection | Needs rule | Combat Formulas C: `stage_src` may pass 1.45, on damage only |
| Raw Scar | Needs rule | Combat rule 12: an L4 source that survives a blind fight |
| Reopened, Refused Force, Known Gate, Numb Soul | Needs key | Per-keys on health missing, floors held and `gate_scars` |
| The three arts, Hearth Ash Talisman | Needs key | Art record format and ability catalogue (Combat Open Question 13) |
| Waster Heap, Way of the Threshold | Needs key | Cluster and Đạo data, for the tree rework |

## Also Considered

- **The Thirteenth Stage:** each failure adds a stage past perfection and nothing else. A pure stat race; it survives as Cracked Perfection.
- **The Botched Cast:** an art that cannot be paid fires anyway and wounds you, so failure happens inside the fight too. Good, but it is a health cost with more rules.
