# The Stand-In (Thế Thân Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Contagion: your afflictions move to the enemy, including curses, and your own bad state is the ammunition. Curses as an engine, which nobody has done yet. Read Combat rule 8 and Formulas F. Shame or disgust as the mood. Defined at Core Formation."
> **Direction**: You are only well while someone else is sick. Curses you carry for life leave your body in one retch and come home when they lapse. The forced push replaced a shred curse with Fever, which is a blessing to you and a sickness to them.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Core Formation · **Power level**: strong · **Use**: player build, or a palace horror NPC
> **Fit**: 3 Fits today · 9 Needs key · 5 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: curses have no lint, tree spend not totalled)

## The Spine

- **The channel:** art hits, paid in linh lực, with curses as the engine. Purge carries them across and hits on the way, already inside what it brought. Against an equal it does 65 % of the damage.
- **The enabler:** Moved Sickness, on the Sickness-Moving Sutra.
- **The loop:** wait until all your sickness is home, retch it into the enemy, fight clean for three pulses, and let it come home.
- **The engine:** a curse only costs you while it is on you. Purge takes all of them off at the moment it fires, and reads them for its strength, so your sickest instant is your hardest hit, and it is also the instant you stop being sick.
- **The sacrifice:** the pool. If you cannot pay for Purge when the sickness comes home, you hold every curse you own and the enemy holds none.
- **The arc:** more ruin, more ammunition. Each realm adds something wrong with you.

## The Legend

The heirs of the Inner Palace do not fall ill. Each keeps a Stand-In, a servant of the same height, taken at seventeen, into whom the physicians move the heir's pox, the heir's drunken disgrace and the heir's failed breakthroughs, by a rite called the Sickness-Moving Sutra. The physicians have never read its last page, which notes that the rite has no direction.

The present Stand-In has outlived three heirs and carries the leavings of all of them. They weep at the joints, they smell, their left hand shakes, and they reached Core Formation on other people's mistakes. They bow too low. They take your sleeve and tell you how well you look. Nobody has found a polite way to stop this, and they have never enjoyed anything more. The heir's physician has twice asked to have them killed, and has twice been reminded where everything would go.

## How It Fights

At the start they are at their worst: every curse on them, and every blow they could throw would turn on itself. Before anyone else can act they retch. All of it crosses at once, inside the hit. For three pulses the enemy's arts turn in their hands and land on their owner, and the Stand-In, clean for a moment, spends freely. Then it all comes home, and they do it again.

**The signature moment:** a top-end Core Formation elder fires at 1 s, as everyone does, and strikes themselves for nearly a quarter of their health. In the fixture fight they kill the Stand-In at 2 s, standing on 19 % (`sheets/stand-in.fight.json --enemy top_end`). Against the mixed top-end Turned Hand is 74 % of the damage dealt, and against a mixed equal it is 4 %. It is a mirror for the strong.

Firing the moment anything came home lost one realm up, so Purge now waits for all of it, and the fight is won at 9 s by staying sick a little longer (`variants/stand-in-mixed.fight.json --gap 1`, against `variants/stand-in-no-wait-mixed.fight.json --gap 1`, a loss at 7 s with the enemy on 45 %).

## Enabler

**Moved Sickness (Di Bệnh)**, the first divine ability of the Sickness-Moving Sutra. Rule swap.

- **Opens:** curses that come from your own life, with no duration on you. An art with the cleanse tag sends them to the target for their authored duration. When one ends, is cleansed or is pushed out, it comes home the same instant. Any other curse or status on you also goes across when you Purge, with its own source's values.
- **Closes:** you cannot clear them. No pill or cleanse works on your own afflictions, and they are on you whenever they are not on someone else.
- **Found:** in a physician's estate, among the palace's papers. Taking it needs a bad state to move.

**Afflictions at Core Formation**, each a curse, and each owed to a real state on the sheet:

| Affliction | Curse | Pulses | Comes from | What it costs a life |
|---|---|---|---|---|
| Old Shame (Cựu Nhục) | Turned Hand | 3 | Presence at 30 or less | Every event and price that reads presence |
| Stilled Hand (Định Thủ) | Locks the bearer's largest layer | 2 | A Gate Scar | A failed great breakthrough |
| Fever (Độc Nhiệt) | +90 art speed to the bearer | 3 | Đan độc 60 | Slower cultivation, weaker pills |

## The Stack

Sizes on new modifiers are first guesses. Ladder for the art channel, with curses as the base.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Purge (art) | `c_art` 2.2. Moves every curse and status on you, then hits | Art | art | none | ○ | Technique | any cleanse build |
| Rate | Rush Order (Cản Đơn) | +50 % price: first firing at half the cooldown | Timing | art | none | ○ | Technique | **Reused from The Full Price** |
| Rate | Fever (Độc Nhiệt) | +1.5 `art_speed_pct` per đan độc. **Now an affliction:** at home it brings Purge to 0.53 s, ahead of everyone's first second. Moved, it speeds the enemy's arts, so they turn on themselves sooner | Per | art | none | ○ | Technique | **Reused from The Taster's Fever** |
| Multiplier | Damage (`attack_pct`) | +120 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Virulence (Bệnh Thế) | +40 points to arts per curse on you, or per curse an art held as it fired: +120 on a full Purge | Per | art | L2 | ○ | Sealed cluster | any curse build, seed 45 |
| Multiplier | Forgotten Face (Vô Diện) | +2 per point of presence under 45: +60 at presence 15. Nobody forgets this face, and the sum comes out the same | Per | art | L2 | ○ | Sealed cluster | **Reused from The Struck Name** |
| Multiplier | Artifact attack | +60 | Gear | any | L3 | ● | Artifacts | every build |
| Crit | None | Certainty instead: curses move at 100 % | | | | | | |
| Reach | Turned Hand (Phản Thủ) | A curse, in the place of a tag block on `hit`. A bearer's hit art still pays, and lands on its owner at half strength, through their own ward, at most 25 % of their maximum health. The basic attack always runs and is not touched | Rule swap | art | none | ○ | Technique | any curse build, any mirror for the strong |
| Past the cap | None | Curses are bounded by rule, and the build sits inside every bound | | | | | | |
| Fuel | Relapse (Tái Phát) | Each affliction that comes home refunds 2 % of maximum linh lực | Trigger | any | none | ○ | Artifact | any curse that returns or is recast |
| Survival | Stilled Hand (Định Thủ) | The Incense Vigil's curse, carried for life. It lowers the blows that still land, and it shrinks their mirror too | Curse | any | none | ○ | Technique | **Reused from The Incense Vigil** |
| Identity | **Moved Sickness (Di Bệnh)** | See Enabler | Rule swap | any | none | ○ | Technique | seed 45, any haunted NPC |

**Identity piece:** Moved Sickness. With it off (`--without moved_sickness`), the Stand-In loses to an equal at 6 s with the enemy on 88 %, and every art turns on them.
**The unplanned use:** Fever's author wanted a fast poisoner. Here it is a curse that leaves your body. `--without fever` against the mixed top-end turns death at 2 s with the enemy on 58 % into death at 1 s with the enemy on 95 %. It costs something too: one realm up the win is better without it, 7 s on 46 %, because a fevered enemy lands more in the instant the sickness comes home. That is a real choice.
**Empty rungs:** Crit is a sacrifice. Past the cap is empty on purpose. L4 and L5 are empty: nobody prepares a patient.

| Layer | Points at Core Formation | Multiplier on a full Purge | Sources |
|---|---|---|---|
| L1 | 120 | ×2.20 | Tree |
| L2 | 180 | ×2.80 | Virulence 120, Forgotten Face 60 |
| L3 | 60 | ×1.60 | The Gilded Spittoon and others |
| L4 | 0 | ×1.00 | Sacrifice |
| L5 | 0 | ×1.00 | Sacrifice |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Wood and Fire, no Water | Water purity washes đan độc away each season, and this build needs to keep it |
| Key talents | Physique, with presence kept low | They need to last, and Forgotten Face wants 15 |
| The Way (Đạo) | Way of the Unnamed, Unseen branch, if any | Holds Forgotten Face |

## Công Pháp

### Sickness-Moving Sutra (Di Bệnh Kinh) — main, Địa giai

A physician's rite. The last page is in a different hand and says only "it does not care which way".

```json
{"id": "di_benh_kinh", "name": "Di Bệnh Kinh", "tier": 2, "tech_kind": "main",
 "names": ["moc", "hoa"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "lifespan_years", "value": 10}],
 "abilities": [{"ability_id": "moved_sickness", "unlock_layer": 1}, {"ability_id": "purge", "unlock_layer": 1},
               {"ability_id": "bile", "unlock_layer": 3}, {"ability_id": "phlegm", "unlock_layer": 5}],
 "seal_clusters": ["hundred_ills"], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 15/15 + 10/15 = 1.67 against Địa's 3.0

## Arts

All paid in linh lực, on the common drain ward.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Purge (Thổ Uế) | Sutra, 1 | qi, cleanse, hit, Rush Order | 2.2 | 0.12 | 2 s | Holding all your afflictions | Needs rule |
| Bile (Đảm Trấp) | Sutra, 3 | qi, hit | 2.2 | 0.08 | 3 s | No curse on you | Needs key |
| Phlegm (Thổ Đàm) | Sutra, 5 | body, hit | 1.85 | 0.05 | 2 s | No curse on you | Needs key |

- **Purge:** moves first, then hits, so the hit meets what it brought. Lint at the base cost 0.08: 2.20 against 2.21. **Description:** it is worse from close by.
- **Bile, Phlegm:** ordinary hits, guarded because Turned Hand at home would land them on you. **Description:** the palace has stopped asking them not to.

Slots 4 and 5 stay open at Core Formation, for a talisman or an escape art. Neither was run. Pool limits this build, not slots.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Purge, Bile | Common drain | Old Shame and Fever only: no Gate Scar yet |
| Core Formation | 5 | Purge, Bile, Phlegm | Common drain | The defined build |
| Nascent Soul | 6 | Purge, Bile, Phlegm, one more hit | Common drain | `variants/stand-in-nascent-mixed.fight.json` |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| The Gilded Spittoon (Kim Thóa Hồ) | Artifact, utility | `ho_lo`, named | L3 and Relapse. Three heirs used it. It has been polished every day, and that has not helped | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Hundred Ills | Whole cluster | Virulence | Needs key |
| 2 | Ward efficiency, linh lực | As much as the realm allows | Purge must always be payable | Fits today |
| 3 | Damage | +120 | The hits are real | Fits today |

### Hidden cluster idea: Hundred Ills (Bách Bệnh)

Theme: curses and bad states, on either side of a fight. Wood, outer, sealed by the Sutra, size 9. Small acupoints are curse duration and status resistance. Notables Virulence and one more affliction read. An idea for the tree rework, not data.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Two curses, a win at 3 s, and a realm above beaten at 7.6 s on 26 % | Old Shame, Fever | The first heir dies clean |
| Core Formation | The defined build | Stilled Hand | A failed gate, on purpose |
| Nascent Soul | Wins its own realm in 3 s. A Deity survives on 41 %, at 10 s | One more hit | The palace starts sending for them |

Second realms: `variants/stand-in-foundation-mixed.fight.json` and `variants/stand-in-nascent-mixed.fight.json`, each with `--gap 1` for the realm above.

## Matchups

Core Formation, one realm up unless stated, mixed enemy arts. Shapes are hand-set in each file. The soul enemy's sense of 1.6 is set by hand in its file, as `enemy_divine_sense`, and the build's own is 1.0. No art here reads element, and the reference enemies have none.

| Enemy | Result | Why | File (`variants/stand-in-`) |
|---|---|---|---|
| Mixed, same realm | Wins, 3 s on 93 % | Two Purges | `mixed` |
| Mixed | Wins, 9 s on 35 %, linh lực 4 % | Four Purges, and barely paid for | `mixed --gap 1` |
| Cleanser | Wins, 9 s on 42 % | Cleansing sends it home sooner, which reloads Purge. Better for you than no cleanse | `cleanser --gap 1` |
| Poisoner | Wins, 9 s on 35 % | Their venom goes back, with their own values | `poisoner --gap 1` |
| Gap striker, a 3 s art from 4 s on | Wins, 12 s on 15 % | Its art can land in the instant the sickness comes home | `gap-striker --gap 1` |
| Curser | Loses at 10 s, enemy 61 % | A hex on you shuts your clean-guarded arts and raises what Purge costs | `curser --gap 1` |
| Soul striker, sense 1.6 | Loses at 4.5 s, enemy 77 % | Soul arts do not turn | `soul --gap 1` |
| Fist, no arts | Loses at 10 s, enemy 59 % | Nothing to turn | `fist --gap 1` |
| Thể tu, ward off | Loses at 14 s, enemy 56 % | Nothing to turn, and a body that holds | `the-tu --gap 1` |
| Patient, one 12 s art | Loses at 12 s, enemy 49 % | Almost nothing to turn, and an unspent pool behind its ward | `patient --gap 1` |

**Counter:** a soul striker, or anyone who brings no art to turn. A top-end still kills them by 2 s. Also poverty: with `n_qi` 1.0 the one-up win becomes a loss at 8 s with the enemy on 47 % (`variants/stand-in-broke.fight.json --gap 1`).

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Sutra 1.67 of 3.0. Art lint within, Purge at its base cost. Slots 3 of 5. Every curse is inside its bound: tag block 3 pulses, layer lock 2, duration 5. Curses have no lint of their own, and tree spend and thần thức are not totalled |
| Validity | PASS | Elements `moc`, `hoa`; tier 2 reaches `nguyen_anh`; base `ho_lo`; `curse_slots` 3 used in full |
| Stack | PASS | Forms: Rule swap, Per, Timing, Trigger, Increased. Identity test changes the fight. Virulence and Forgotten Face share L2: removed together the one-up fight is lost at 12 s, enemy 25 % |
| Scaling | PASS | `m_static` 3.52, under typical 5.48. A full Purge is ×9.86. INFO: beats one realm up, which Combat keeps for top-end |
| The fight | PASS | The loop runs: 4 Purges at 0.53, 3, 6 and 9 s one realm up. Own pool reaches 5 % only in the last instant of that win. No cap hit |
| Reuse | PASS | 4 reused, 2 of them in a way their authors did not plan |
| NPC use | PASS | Guards sit in rule 13's status family. Afflictions compile from the sheet. An NPC needs no input |
| Counterplay | PASS | Soul striker, a fist, a curser |
| Originality | PASS | Thế thân and di bệnh are common words. All names invented |

## Fight Results

Input: `sheets/stand-in.fight.json`, on the fixture enemies. A paper model with expected values.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win on 93 % | 3 s | never | |
| typical | 1 | Win on 61 % | 6 s | never | |
| typical | 2 | Loss, enemy 77 % | 5 s | never | |
| top_end | 0 | Loss, enemy 19 % | 2 s | 2 s | |
| top_end | 1 | Loss, enemy 82 % | 1 s | 1 s | |
| top_end | 2 | Loss, enemy 90 % | 1 s | 1 s | |

Against the mixed enemy, `variants/stand-in-mixed.fight.json`:

| Removed (`--without`) | Same realm | One up | Top-end, same realm |
|---|---|---|---|
| Nothing | Win, 3 s on 93 % | Win, 9 s on 35 % | Loss at 2 s, enemy 58 % |
| `moved_sickness` | **Loss, 6 s, enemy 88 %** | **Loss, 3 s, enemy 98 %** | Loss at 1 s, enemy 100 % |
| `fever` | Win, 4 s on 90 % | Win, 7 s on 46 % | **Loss at 1 s, enemy 95 %** |
| `Virulence` | Win, 3 s on 93 % | **Loss, 12 s, enemy 0 %, on overkill** | Loss at 2 s, enemy 60 % |
| `Forgotten Face` | Win, 3 s on 91 % | **Loss, 12 s, enemy 7 %** | Loss at 2 s, enemy 61 % |
| `relapse_refund` | Win, 3 s on 93 % | **Loss, 10 s, enemy 4 %** | Loss at 2 s, enemy 58 % |
| `bile` and `phlegm` | Win, 3 s on 91 % | Win, 12 s on 15 % | |

And swapping what you carry:

| Afflictions | One up, mixed | File (`variants/stand-in-`) |
|---|---|---|
| Shame, Stilled Hand, Fever | Win, 9 s on 35 % | `mixed` |
| Shame, Weeping Sores (shred 0.5), Fever | Loss, 6 s, enemy 0 %, on overkill | `sores-for-lock-mixed` |
| Sores, Stilled Hand, Fever: no Shame | Loss, 5 s, enemy 72 % | `sores-for-shame-mixed` |
| Shame, Stilled Hand, Sores: no Fever | Win, 10 s on 26 % | `sores-mixed` |
| Shame alone | Loss, 6 s, enemy 22 % | `shame-only-mixed` |

Turned Hand's main job is defence, not damage: without Old Shame the one-up fight ends at 5 s.

**Unmodelled:** the talisman or escape in slots 4 and 5; the costs of đan độc, presence and a Gate Scar; `status_resist_pct` against a move. The compile reads are fixed values in the file.

## New Concepts

**Chronic affliction (Cố Tật).** A curse owned by a character, compiled from a real state, with no duration on its owner. Rule: Combat rule 8 and Formulas F, Character Stats for the source list. Bounds: `curse_slots`, and every existing curse bound. Breakdown line: "Old Shame, carried from before the fight." It also serves seed 45, cursed on purpose, and a haunted NPC whose haunting is a stat. NPCs can use it.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Moved Sickness, chronic affliction | Needs rule | Combat rule 8: curses with an owner, moves, return home |
| Turned Hand | Needs rule | Combat rule 8, Formulas F: a tag block whose art fires at its owner, with the share and cap as data keys |
| Fever as a curse | Needs rule | Combat rule 8's list gains an art speed curse |
| Rush Order, Purge | Needs rule | Rush Order as its own sheet. Purge is the art that carries the move |
| Virulence, Relapse, Forgotten Face, Stilled Hand | Needs key | A count of curses on self; a refund on return; a presence read; as its own sheet |
| Sutra, Bile, Phlegm, Hundred Ills, Spittoon | Needs key | New content |

**Questions for the user:** (1) Formulas F's tag block names "arts carrying the tag", and rule 6 makes `hit`, `body` and `qi` tags. Is one curse on `hit` meant to silence every hit art for 3 pulses? That is in the rules today, with no build needing to bend anything. (2) Rule 13 says the basic attack always runs, and its tags include `hit`. This sheet reads that as immune. Is it?

## Also Considered

- **The Shameless (Vô Sỉ):** carry every curse and own nothing they touch, no ward, no layers, so the curses cost you nothing and the enemy everything. Dropped because it had no way to deal damage.
- **Festering (Hóa Nùng):** a curse pushed out of a full set of slots turns into a tick. Dropped because Overflow is closed this wave and this would not be the identity piece.
