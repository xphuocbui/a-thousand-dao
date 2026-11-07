# The Great Tonic (Đại Bổ Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Overfeeding: forcing linh lực into the enemy until it harms them."
> **Direction**: The enemy overfeeds itself. A ward hands every blocked blow back into the attacker's meridians. The seed's own reading, your hits feeding their ward, was dropped in the first draft (see What the numbers changed).
> **Realm span**: Foundation Establishment – Nascent Soul · **Power level**: strong · **Use**: player build, or a physician sect's doctrine
> **Fit**: 5 Fits today · 7 Needs key · 7 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức for artifacts not totalled. Scaling: the anchors measure M and the engine does not use M)

## The Spine

- **The channel:** a new one, Rupture: a share of the target's maximum health, past ward, guard and evade, set by how overfull they are. Then plain needles into an enemy with no ward.
- **The enabler:** Feeding-Back Ward. Opens the attacker's own force as your damage. Closes offence: no layer stack is worth buying, and an enemy who never lands a blockable hit is never fed.
- **The loop:** take the blow, return it, Lance once, then needle an empty vessel.
- **The engine:** a ruptured enemy has no ward and no arts, and the empty cannot take tonic, so it stays that way.
- **The sacrifice:** the multiplier. `m_static` 3.20 is below a typical cultivator's at this realm. It also cannot touch a soul striker.
- **The arc:** a physician who treats the sick becomes one who treats the strong.

## The Legend

A court physician kept a dying sect head alive for forty years on tonics. The patient grew vast with borrowed qi, and when a rival finally struck them, the blow did little and the meridians went like wet silk. The physician knelt at the body and understood that the blow had not killed them. They wrote the Canon that winter, and its first line is older than any sect: the empty cannot take tonic.

Physicians of that line now take the duels nobody else wants, against the strong, for a fee. They do not train to strike. They train to stand still and be hit by someone who has never been refused anything. The founder died in bed of a slow poison, with every needle in the house laid out and useless, which is why the Canon has no chapter on poison and none on the soul. Great sects hire them, and then watch their own elders closely at dinner.

## How It Fights

The physician barely moves. The enemy's greatest art lands, the ward takes nearly all of it, and the force goes back up the arm that threw it. Their sea fills, then overfills. A needle opens the swelling. They lose a fifth of their health, and all their linh lực at once: no ward, no arts, and too empty to take back what they gave. The rest is small needles, and it is not fast. **The signature moment:** a Nascent Soul elder, at their full strength, with no ward left two seconds into a duel with someone who has not yet hurt them.

## Enabler

**Feeding-Back Ward (Phản Bộ Hộ).** A ward record, a new `cost_model`, carried by the Hundred Vessels Canon at layer 4. Named for the young crow that feeds its parent.

- **Opens:** a per-hit ward (pass 0.30 body, 0.25 qi, `hit_cost_share` 0.04) that also returns blocked damage to the attacker's linh lực, 1.0 per point. What passes their maximum becomes Surfeit (see New Concepts).
- **Closes:** it only fires on hits it blocks. Ticks, soul arts and curses return nothing, and every point that lands in a pool below maximum is fuel you handed them.

## The Stack

Sizes on new modifiers are first guesses. The ladder is climbed for Rupture, not for hits.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Feeding-Back Ward** | Blocked damage returns to the attacker | Enabler | rupture | none | ○ | Ward record | signature |
| Base | Strong Decoction (Nùng Thang) | +0.3 to the share a ward returns | More | rupture | none | ○ | Sealed cluster | any Surfeit build |
| Rate | Art speed (`art_speed_pct`) | +30, so Lancing is ready before the first blow | Flat | art | none | ◐ | Tree | every art build |
| Multiplier | Damage (`attack_pct`) | +100 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Fine Needling (Tinh Châm) | +20 points to arts with the needle form | More | art | L2 | ○ | Technique | any `cham` artifact build |
| Multiplier | Artifact attack | +60 from cheap `cham` needles | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Bare Vessel (Lộ Đỉnh) | +80 points to hits while the enemy has under 5 % linh lực. Greater grade, +80. The same modifier has a lesser grade, +30, in Brush Fee, Fortieth Breath, Receiving Hand and Turned-Away; one size would change fights | Conditional | art, basic | L5 | ○ reused | Sealed cluster | Burial Shroud, Ninth Bell |
| Reach | Ward strength (`defense_pct`) | ws 180: pass falls to 0.11 body, 0.09 qi, so block share is reach | Increased | rupture | none | ● | Tree, gear | any ward build |
| Reach | Pill-Fed (Đan Dưỡng) | +1 % return per point of the attacker's pill toxicity, up to +30 %. Channels clogged by pills tear first | Per | rupture | none | ○ | Đạo | a poisoner who works on toxicity |
| Past the cap | Deep Abscess (Thâm Ung) | Surfeit the cap clips adds to the next Lancing, up to +15 % of health | Overflow | rupture | none | ○ | Đạo | any Surfeit build |
| Fuel | Ward efficiency (`ward_efficiency_pct`), art cost | we 100, cost −20 %, regeneration +3 | Flat | any | none | ● | Tree | sustain builds |
| Survival | Body guard, a body technique | `a_b` 3, `t_b` 2, +40 %, so a leak stays small | Flat | any | none | ● | Tree, armour | thể tu builds |
| Survival | Self-Cure (Tự Y) | When a target ruptures, regain 10 % of maximum health | Trigger | rupture | none | ○ | Technique | a healer build (seed 70) |

**Identity piece:** Feeding-Back Ward. With no return (`--without feeding_back_ward`), a top-end equal ends on 94 % instead of 10 %, and a typical two realms up on 93 % instead of 59 %.
**Empty rungs:** Crit is a sacrifice: Rupture cannot crit and the needles do not matter enough. L4 is a sacrifice: nothing here prepares. Certainty comes from the rule: Rupture cannot miss.

| Layer | Points at Core Formation | Multiplier | Sources |
|---|---|---|---|
| L1 | 100 | ×2.00 | `attack_pct` |
| L2 | 20 on needles | ×1.20 | Fine Needling |
| L3 | 60 | ×1.60 | Gear |
| L4 | 0 | ×1.00 | Empty on purpose |
| L5 | 80 while the enemy is dry | ×1.80 | Bare Vessel |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water and Wood | Water generates Wood, the root of medicine in this world's herbs and pill decay |
| Key talents | Physique | Health and guard are the whole of offence, since staying alive is how the enemy is fed |
| The Way (Đạo) | Life, with the Tonic branch below | Holds Deep Abscess and Pill-Fed |

## Công Pháp

### Hundred Vessels Canon (Bách Mạch Tư Dưỡng Kinh) — main, Địa giai

A physician's dosing manual with no upper bound on the dose.

```json
{"id": "bach_mach_tu_duong_kinh", "name": "Bách Mạch Tư Dưỡng Kinh", "tier": 2, "tech_kind": "main",
 "names": ["moc", "thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "khi_huyet_pct", "value": 12},
             {"stat": "defense_pct", "value": 15}],
 "abilities": [{"ability_id": "tonic_needle", "unlock_layer": 2},
               {"ability_id": "feeding_back_ward", "unlock_layer": 4},
               {"ability_id": "long_needle", "unlock_layer": 6},
               {"ability_id": "lancing", "unlock_layer": 8}],
 "seal_clusters": ["swollen_channels"], "origin": "authored"}
```

**Flaw:** it treats only what travels the channels. The founder died of what does not, and a poisoner or a soul striker meets a physician with nothing to return.
**Fit:** Needs key (abilities) · **Budget:** 12/20 + 12/15 + 15/15 = 2.4 of 3.0, each under the single cap

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Tonic Needle (Bổ Châm) | Canon, 2 | qi, needle, Wood | 1.45 | 0.04 | 1 s | none | Needs key |
| Long Needle (Trường Châm) | Canon, 6 | body, needle, Water | 2.2 | 0.08 | 2 s | none | Needs key |
| Lancing (Khai Ung) | Canon, 8 | qi, needle, rupture | none | 0.12 | 1 s | target's Surfeit above 60 % | Needs rule |

- **Tonic Needle.** **Effect:** a hit. **Description:** A courtesy, before the treatment.
- **Long Needle.** **Effect:** a hit. **Description:** Placed by someone who knows where the channels run.
- **Lancing.** **Effect:** the target loses 25 % of maximum health per 100 % of Surfeit, at most 25 %, plus any Deep Abscess. Taken past ward, guard and evade, with no suppression, and divided by `boss_pool_mult`. Its pool and Surfeit go to 0. With a 1 s cooldown it waits ready and fires in the follow-up instant after the blow that crosses 60 %. **Description:** Every swelling wants to be opened.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Lancing, Tonic Needle, Long Needle | Feeding-Back | Needs the Canon at layer 8. Before that, only a weak healer. Run at L1 70, L3 40, ws 140 |
| Core Formation | 5 | Lancing, Tonic Needle, Long Needle | Feeding-Back | Two slots free for a cleanse and an escape, the answers it lacks |
| Nascent Soul | 6 | As above | Feeding-Back | The extra slot is for a soul answer |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Any `cham` needles | Artifact, weapon | Generated | L3 at 10 thần thức a piece, the cheapest attack in the game, so the budget goes to armour | Fits today |
| Any `giap` armour | Artifact, body | Generated | Body guard | Fits today |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Ward strength, ward efficiency notables | +8 each | Block share is this build's reach | Fits today |
| 2 | Body guard notables | +8 each | A leak of a top-end hit is still large | Fits today |
| 3 | Swollen Channels | Sealed cluster | Strong Decoction, Bare Vessel | Needs key |

### Hidden cluster idea: Swollen Channels (Ứ Mạch)

Theme: wards and how force moves through them. Water affinity, outer, sealed. Seal condition: a technique that lists it. Size 8, so one notable. The small acupoints give ward strength and ward efficiency. The notable is Strong Decoction, and Bare Vessel sits on the same path as in Sick Meridians, because any build that empties a pool wants it. A cultivator with any return ward can use this.

## Đạo

**Life, Tonic branch (Bổ Chi), proposal.** A branch of the Life Đạo, requirement unchanged. Its nodes are `khi_huyet_pct` and `linh_luc_regen_pct` lines from Life's `theme_stats`, and Pill-Fed as a passive. Its keystone is Deep Abscess. An art node can hold Lancing for a character without the Canon, as long as they carry some return ward.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Beats one realm up in 5.4 s; any top-end kills it at t = 1 | The ward, the needles, Lancing | Treating a master who will not get better |
| Core Formation | Beats one realm up in 4.6 s at 96 % health. Top-end equal ends on 10 % | Deep Abscess, Self-Cure | The first fee taken for a duel, not a cure |
| Nascent Soul | Beats Deity Transformation in 5.4 s. Top-end equal ends on 5 % | Pill-Fed | A sect sends a patient who is not sick |

## Matchups

Each row is read from `--matrix` on the file named, in `variants/` unless it says `main`, which is `sheets/great-tonic.fight.json`.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical, same realm | Wins, 3.1 s, 100 % health | Its hits are small, so Strong Decoction is what gets the first rupture at 3 s. Without it, 6.2 s | main; `great-tonic-no-decoction.fight.json` |
| Typical, one realm up | Wins, 4.6 s, 96 % health | Bigger blows, first rupture at 2 s. Without Bare Vessel it takes 7.7 s | main; `--without "Bare Vessel"` |
| Typical, two realms up | Loses, 10.5 s, enemy on 59 % | Rupture at 2 s, then the leak outpaces the needles | main |
| Top-end, same realm | Loses, 2.0 s, enemy on 10 % | Its first blow ruptures it at t = 1, taking 35 %. The closest top-end fight here | main |
| Top-end, one realm up | Loses, 1 s, enemy untouched | Dead before Lancing can answer | main |
| Soul piercer, one realm up | Loses, 7.5 s, enemy on 74 % | No blocked hit, no return, and it eats the pool the ward pays with | `great-tonic-soul.fight.json` |

**Counter:** a soul piercer (Combat rule 18). Three small fast arts do not beat it: they still fill the sea, and a swarm one realm up lost in 4.6 s (`variants/great-tonic-swarm.fight.json`).

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.4 of 3.0; both hitting arts inside the lint, Lancing has no `c_art`; slots 3 of 5. Thần thức for the artifact set was not totalled |
| Validity | PASS | `moc`, `thuy`, tier `dia`, bases `cham` and `giap` real; `dia` reaches Nascent Soul. Ward pass and `hit_cost_share` inside Combat's ranges |
| Stack | PASS | Seven forms (More, Increased, Conditional, Per, Overflow, Trigger, enabler rule); every rung filled or named. Identity test: `--without feeding_back_ward` moves one up from 4.6 s to 8.5 s, and a top-end equal from 10 % to 94 % |
| Scaling | NOT ASSESSED | `m_static` 3.20 against anchors 5.48 and 210. The anchors measure M, and this engine does not use M, so the comparison says nothing. INFO: below typical on purpose |
| The fight | PASS | Constants 60 of 60, selftest clean. `rules/feeding_back_ward.py` and `rules/rupture.py` run the engine, so the loop is simulated, not approximated. No cap hit |
| Reuse | PASS | Bare Vessel reused; the per-hit ward model and body guard exist. One signature piece, the ward. Every other new modifier has a second home |
| NPC use | PASS | A ward record and guarded art: the generator slots them like any others. One Breakdown line: "Returned [n] to the attacker, Surfeit [n] %" |
| Counterplay | PASS | A soul piercer one realm up wins with 74 % health left on it |
| Originality | PASS | "The empty cannot take tonic" is a traditional medical saying, not a game or novel. Phản Bộ is an ordinary idiom. No name or effect text taken from any work |

## Fight Results

Input: `sheets/great-tonic.fight.json`, rules `feeding_back_ward` and `rupture`. Observations from `_tools/fight_x.py`, a paper model with expected values for chance, not the game. Its rules: a blocked hit adds `ward_return` × blocked to the attacker's pool, at most the pool it finds; the excess past maximum is Surfeit; Lancing as written above.

| Enemy | Gap | Result | Time | First rupture | Own dry at | Cap hits |
|---|---|---|---|---|---|---|
| typical | 0 | Win, 100 % health | 3.08 s | 3.00 s, 18 % | never | none |
| typical | 1 | Win, 96 % health | 4.61 s | 2.00 s, 22 % | never | none |
| typical | 2 | Loss, enemy on 59 % | 10.46 s | 2.00 s, 24 % | never | none |
| top_end | 0 | Loss, enemy on 10 % | 2.00 s | 1.00 s, 35 % | never | none |
| top_end | 1 and 2 | Loss, enemy on 100 % | 1.00 s | never | never | none |

**What the repair changed.** These are the rule-model numbers the sheet already quoted, and each one came back the same from the plug-ins. The old approximation, Lancing as a one-shot soul art, is gone, with its table. With the engine in the saved files, The fight moves from NOT ASSESSED to PASS.

**Second realms.** Foundation Establishment (L1 70, L3 40, ws 140, `variants/great-tonic-foundation.fight.json`) beats one realm up in 5.4 s. Any top-end kills it at t = 1. Nascent Soul (L1 130, L3 70, ws 220, `variants/great-tonic-nascent.fight.json`) beats Deity Transformation in 5.4 s, and a top-end equal ends on 5 %.

**What the numbers changed.**

- **The seed's reading failed.** First design: your hits feed the enemy's drain ward. Your hits were too small against their pool, and their hits were not, so the pipe was turned around. That first run was not kept, so no figure is given for it.
- **One rupture is the fight.** Rupture was meant as a clock, four of them to kill. In practice the enemy stays dry after the first and has no ward and no arts. That made the refusal rule the engine: without it (`variants/great-tonic-no-refusal.fight.json`), one up slows from 4.6 s to 6.2 s, and two up dies in 8.0 s instead of 10.5 s.
- **The obvious art is a trap.** Seed Needle refilled an empty enemy so it could be ruptured again. It re-armed them: one up went from 4.6 s at 96 % to 10.0 s at 54 % (`variants/great-tonic-seed-needle.fight.json`). It was cut.
- **Two pieces were cut.** Regeneration spilling into the enemy, and a clip that delayed their timers. The runs behind that were not kept, so it is a design call here, not a result.
- **Being strong is the weakness.** Against typical enemies the first rupture comes sooner one realm up (2 s) than at the same realm (3 s).

**Unmodelled:** Pill-Fed, since no reference enemy has toxicity. Combat has no toxicity on its profile today.

## New Concepts

**Surfeit (Ứ Khí).** Linh lực forced into a full pool. It is a number on the target, in shares of `qi_max`, not a pool: it cannot be spent and does not ward.

- **Rule needed:** Combat rule 11 and Formulas E. A forced gain above maximum becomes Surfeit, up to 100 %. A forced gain from one source is at most the pool the target holds at that moment, so a hit can double a pool and cannot fill an empty one (Hư Bất Thụ Bổ, the empty cannot take tonic). It mirrors Formulas D, where `qi_loss` never exceeds the pool. Rule 22 gains the return `cost_model`. A cleanse with a matching tag clears it. It falls to 0 when the pool is emptied.
- **Bounds:** 100 % of `qi_max`. Lancing at most 25 % of health, +15 % from Deep Abscess, and divided by `boss_pool_mult` like soul loss.
- **Breakdown line:** "Surfeit [n] %, from returned force".
- **Other builds:** a healer who wins by keeping a fight going (seed 70); a pill glutton who overdoses themselves on purpose (seed 43); the creditor who sizes hits around an enemy's ward (seed 5).
- **Question for the user:** is giving an enemy linh lực as a threat, instead of taking it, a direction you want for wards in general, or is this one sect's secret?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Feeding-Back Ward | Needs rule | Combat rule 22: a return `cost_model` |
| Surfeit | Needs rule | See New Concepts |
| Lancing | Needs rule | Combat Formulas: a Rupture effect past ward, guard and evade |
| Strong Decoction, Deep Abscess, Self-Cure | Needs rule | Each reads Surfeit or a rupture event |
| Pill-Fed | Needs rule | `dan_doc` on the combat profile (rule 2) |
| Fine Needling, the needle form tag | Needs key | Rule 6's form list has no needle |
| Tonic Needle, Long Needle, Hundred Vessels Canon | Needs key | Art record format and ability catalogue (Combat Open Question 13) |
| Swollen Channels, Life Tonic branch | Needs key | Cluster and Đạo data, for the tree rework |

## Also Considered

- **Gift Hits:** your own hits feed the enemy's drain ward until it bursts. A first-draft run killed it: see What the numbers changed.
- **The Generous Tempo:** a curse that gives the enemy art speed, so they spend themselves dry and fall out of their own ward. Good, but it needs no new concept and is a smaller idea.
