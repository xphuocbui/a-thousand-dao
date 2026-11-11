# The Nine-Gate Warden (Cửu Quan Thủ Hộ Giả)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A Hóa Thần boss that punishes the common shapes of player build: it changes ward model mid-fight, cleanses on a timer, and has phases that each counter one channel. Hard, readable, beatable by a prepared build. List which player builds it beats and which beat it.
> **Direction**: B. The Turning Gate (Chuyển Quan): four fixed phases, each a different ward model that shuts exactly one channel, with a visible toll before every swap (chosen; see Directions considered).
> **Realm span**: Hóa Thần (Deity Transformation); a Nguyên Anh lesser form is noted · **Power level**: legend · **Use**: boss
> **Fit**: 0 Fits today · 12 Needs key · 6 Needs rule (new pieces staged in `deity-warden.staging.md`)
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: technique bonuses outside `bonus_pool`; Validity: tier ids not checked against `max_realm`; The fight: the engine, the phase script, is unmodelled)

## Directions considered

Chosen: **B, The Turning Gate**. It is the only reading where the boss is a puzzle with a visible clock: the player learns the order in the first cycle, and a prepared build plans around it.

- **A. The Mirror Examiner (Kính Giám Quan), rejected.** The boss reads the player's top channel at compile time and adapts its ward to it. Hard to read, punishes by surprise rather than by preparation, and breaks Pillar 3's "fair and readable".
- **C. The Hollow Idol (Hư Tượng), rejected.** One huge ward with a huge cleanse, beaten only by starving it (Spirit Severing, Bare Vessel). Fights end in fatigue and it is a counter to one build, not a test of all of them.

## The Spine

- **The channel:** the boss wins by out-sustaining a build that has only one channel. Its own offence is slow and heavy (Gate Hammer, Closing Palm) at top-end layers (L1 to L5 on the caps), so a player who wastes 12 s of a 48 s cycle shut out of their channel runs dry first.
- **The enabler:** Nine-Gate Seal (Cửu Quan Ấn). Opens: a 12 s phase clock that replaces the ward model, and a 10 s purge bell. Closes: at every swap the old ward's capacity is discarded and for the 2 s Toll before the swap the Warden has no ward at all, so there is always a readable opening.
- **The loop:** four phases, 12 s each, then again. Iron Gate (Thiết Môn, per-hit ward and flat block: shuts many small hits), Lustration (Tẩy Lễ, cleanse 0.5 a pulse: shuts ticks, stacks and curses), Deaf Gate (Tuyệt Thính, soul ward: shuts soul), Open Hand (Khai Chưởng, no ward, body shield, offence up: shuts ward-breaking and starving, and punishes pure turtles).
- **The engine:** Gate Turning. Each phase is the window for the other three channels. A build with two channels switches; a one-channel build must hold its linh lực and wait.
- **The sacrifice:** the Warden has no answer to a heavy hit in any phase except its one Unyielding Breath, and the Toll gap hands a free volley every 12 s. It also never changes the order, so a player who learns it wins.
- **The arc:** at Nguyên Anh a Gate-Guard has two phases (Iron Gate, Lustration); at Hóa Thần the full four.

## The Legend

Nine thresholds guard the old sect's vault. A founder who could not afford a thousand guards bound one warden to the gates and taught it the four ways a thief arrives: many light steps, slow poison, a whisper to the soul, and a hand on the lock. For each it grew a shut door, and at each turn of the year the doors change hands. The Warden has never been bribed, because it never listens, and so every treasure-seeker who came with one trick left without it.

Sects that raise Hóa Thần masters send their best disciples to it as a final exam. They want it kept: it teaches a student which of their arts is real and which is a habit. The Heavenly Tribulation courts want it ended, since a boss that teaches builds to be rounded is a boss that teaches them to survive.

## How It Fights

For 12 s the Warden stands behind an iron gate: small hits bounce off flat block and a per-hit ward. A bell swings; 1.5 s later it tolls and every poison, brand and curse on it vanishes. At 12 s the Toll sounds and for 2 s it has no ward at all, then a heavier door closes: the Lustration phase scrubs 0.5 of every stack each pulse. At 24 s the Deaf Gate shuts to soul and the Warden answers with a Deaf Verdict; at 36 s the gate opens, the ward falls and it hits hardest. Signature moment: the Toll. The whole fight goes quiet, the ward is gone, and a prepared player lands their saved volley into the gap while the unprepared one watches a bar refill.

## Enabler

**Nine-Gate Seal (Cửu Quan Ấn)**, a named artifact carried by the boss, `giap` role utility. Found on the Warden; the player's reward is the Turning Key (Chuyển Quan Thược), see Items. Opens: Gate Turning and the Purge Bell. Closes: the Toll gap (a 2 s ward-less window) and the Mantle rule (nothing carries across a swap).

## The Stack

New sizes are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Gate Hammer, Closing Palm | c_art 3.4 at cd 6, c_art 2.4 at cd 3, both inside the lint | Flat base | art | none | ● | arts | any heavy-art build |
| 2 Rate | Phase clock | a swap every 12 s, a bell every 10 s | Timing | any | none | ○ | enabler | Thời Đạo builds |
| 3 Multiplier | Boss layers at the caps | L1 400, L2 300, L3 250, L4 150, L5 100 | More / Increased | art | L1–L5 | ● | tree, items | top-end players |
| 3 Multiplier | Bare Gate (Lộ Quan) | 40 % more damage while its own ward is down (Open Hand phase and the Toll) | Conditional | art | L5 | ○ | công pháp | Empty Vessel builds |
| 5 Reach | Closing Palm debuff | 3 stacks Metal phys-taken for 10 s | Per | art | none | ● | art | metal builds |
| 6 Past the cap | Mantle | ward capacity discarded at a swap; the old one's overflow is lost | Overflow (inverted) | any | none | ○ | enabler | any phase NPC |
| 7 Fuel | Sustain | regeneration +7 pp a pulse, art cost −30 %, health regen +7 pp | Increased | any | none | ● | tree, công pháp | any wall |
| 8 Survival | Gate Turning | ward model changes 4 times; Unyielding Breath once | Rule swap | any | none | ○ | enabler | phase-boss NPCs |
| 8 Survival | Fast-Art Ward (Khoái Kích Hộ) | 40 % more ward strength against arts under 2 s cooldown and basic attacks, in the Iron Gate phase | More | art, basic | W2 | ○ | công pháp | anti-evade-dancer defences |
| 8 Survival | Lustral Share (Tẩy Phần) | cleanse share 0.25 to 0.5 | Increased | stacks | none | ○ | công pháp | any cleanser |
| 9 Identity | Gate Turning | see above | Rule swap | any | none | ○ | enabler | signature |

**Identity piece:** Gate Turning (Chuyển Quan). Remove it and the Warden is one top-end ward build; the simulator cannot take it away because it is unmodelled, so this is `NOT ASSESSED` rather than proven. The modelled side-piece Lustral Bell passed the removal run only weakly (see Fight Results).
**Empty rungs:** crit/certainty (rung 4): a sacrifice, the Warden has crit 10 % at ×1.5 and uses its slow arts for reliability. Soul is not an attacking channel of the Warden except the Deaf Verdict.

| Layer | Points at Hóa Thần | Multiplier | Sources |
|---|---|---|---|
| L1 | 400 (counts as 300) | ×4.0 | Physique, tree, Kim Đạo Thối Thể |
| L2 | 300 | ×4.0 | Nine Thresholds Scripture arts |
| L3 | 250 | ×3.5 | Nine-Gate Seal, armour |
| L4 | 150 | ×2.5 | Toll Array, own formation (Kính Môn) |
| L5 | 100 | ×2.0 | Bare Gate |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal and Earth dual (Kim Thổ), purity 80 / 70 | Metal feeds Closing Palm and phys-taken stacks, Earth feeds Gate Hammer and phys dampening; a gatekeeper of a vault |
| Key talents | Physique, Comprehension, Willpower | body shield and block on the Iron Gate; Comprehension for the scripture layers |
| The Way (Đạo) | Tứ Thời Đạo (Luân Niên: the Turning Year) and Kim Đạo (Thối Thể) | the four seasons are the four phases; Tempered Body gives the block |

## Công Pháp

### Nine Thresholds Scripture (Cửu Quan Kinh), main, tier 5

The founder wrote it in nine doors and finished only four; the Warden is the other five.

```json
{"id": "cuu-quan-kinh", "name": "Cửu Quan Kinh", "tier": 5, "tech_kind": "main",
 "names": ["kim", "tho"], "layers": 9,
 "bonuses": [{"stat": "linh_luc_regen_pct", "value": 7}, {"stat": "art_cost_pct", "value": -30}, {"stat": "khi_huyet_pct", "value": 20}],
 "abilities": [{"ability_id": "gate-turning", "unlock_layer": 4}, {"ability_id": "lustral-toll", "unlock_layer": 6}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** NOT ASSESSED (the regen and cost keys are outside `bonus_pool`; abilities do not count).

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Gate Hammer (Quan Chùy) | scripture, layer 1 | body, Earth, slam | 3.4 | 0.05 | 6 s | none | Needs key |
| Closing Palm (Hợp Chưởng) | scripture, layer 2 | qi, Metal, palm | 2.4 | 0.04 | 3 s | none | Needs key |
| Lustral Bell (Tẩy Chung) | Lustral Toll, layer 6 | qi, Metal, bell | 1.0 | 0.03 | 10 s | none | Needs rule |
| Deaf Verdict (Tuyệt Thính Phán) | scripture, layer 4 | soul | soul | 0.04 | 8 s | Deaf Gate phase only | Needs rule |
| Open Hand Reckoning (Khai Chưởng Phán) | scripture, layer 6 | body, Earth | 3.0 | 0.05 | 5 s | Open Hand phase only | Needs rule |

**Effects:** Gate Hammer hits hard and slow; Closing Palm lays 3 Metal stacks (phys taken) for 10 s; Lustral Bell is a 1.5 s telegraph then removes every debuff stack and curse on the Warden; Deaf Verdict is a soul hit whose size is set by thần thức; Open Hand Reckoning is the Open Hand's heavy slam. **Description:** a hammer for the lock, a palm for the thief, a bell for the dirt on the door.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Nguyên Anh (Gate-Guard) | 5 | Gate Hammer, Closing Palm, Lustral Bell | Iron Gate, then Lustration only | two phases of 12 s; lesser form |
| Hóa Thần | 6 | Gate Hammer, Closing Palm, Lustral Bell, Deaf Verdict, Open Hand Reckoning | drain, per-hit, soul, off in turn | four phases |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Nine-Gate Seal (Cửu Quan Ấn) | artifact, utility, enabler | new base, named | the phase clock and the bell | Needs rule |
| Turning Key (Chuyển Quan Thược) | artifact, utility, boss reward | new base, tier 5 | the holder swaps their own ward model once per fight with a 2 s ward gap | Needs rule |
| Toll Array (Đối Quan Trận) | formation, L4 | new, tier 5 | player-side: first 4 s after an enemy ward swap, 25 % more damage | Needs key |

The Warden's Seal was cut from the vault door itself; the Key is the Seal's missing half, which is why a player who holds it can do a smaller version of the same trick.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Unyielding Breath (Bất Khuất) | once a fight, 1 health | the Warden's one reply to burst | Needs rule |
| 2 | Status resistance | +6 % notable | stops a share of curses | Fits today (●) |
| 3 | Soul resistance | +6 % notable | the Deaf Gate's soul ward | Fits today (●) |
| 4 | Ward strength, Body guard | +8 % notables | the sustain stack | Fits today (●) |

### Hidden cluster idea: Turning Year (Luân Niên)

Theme Tứ Thời Đạo, Metal and Earth affinity, sealed by defeating the Warden. Eight acupoints: ward strength, block, ward efficiency, status resistance in small points; notables: Fast-Art Ward, Lustral Share; capability: swap your ward model once. An idea for the tree rework.

## Đạo

Existing Tứ Thời Đạo (roster draft: Luân Niên facet, the Turning Year) and Kim Đạo (Thối Thể). The Warden's nodes would sit on Luân Niên: Fast-Art Ward, Lustral Share, the Turning capstone. The graph is not drawn yet (staged: luan-nien-gate).

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Nguyên Anh | Gate-Guard: two doors | Iron Gate, Lustral Bell | a first lesson in reading a clock |
| Hóa Thần | the Nine-Gate Warden: four doors, a soul voice | Deaf Gate, Open Hand, Unyielding Breath | the vault's real exam |

## Matchups

The simulator ran the Warden against two foes only. Build matchups below are predicted from each build's name and staged pieces, not from their sheets, and are not simulated.

| Enemy | Result | Why |
|---|---|---|
| Typical Hóa Thần (sim) | the Warden wins 20 of 20 in 1.9 s | a typical foe cannot survive its first Gate Hammer |
| Top-end Hóa Thần (sim) | the Warden wins 16 of 20 in about 22 s, health left 80 % | the average of its four wards; a prepared player wins the rest |
| Heavy-hit builds (slow-thunder, giant-killer, one-art) | beat it | block and cleanse mean nothing to a big hit; they use the Toll |
| Soul builds (soul-lance) | beat it | three phases open; hold fire in the Deaf Gate |
| Stack and curse builds (status-collector, curse-engine, starter-venom, two-clocks) | lose | the bell and Lustration strip them on a clock |
| Fast-hit builds (bare-fist, starter-blade, cooldown-floor, beast-carry) | lose | the Iron Gate block and per-hit ward |
| Starvers and drainers (dry-well, starter-tide) | lose | the Open Hand has no ward to drain |
| Walls and returners (starter-wall, home-fortress, unkillable, mirror-hide) | even | live through, but one channel of damage is not enough; fatigue ends the fight |

**Counter:** a build that carries two channels and a saved volley beats it; a single-channel build loses to it. A top-end the-tu (body) build with sustain also wins on the Open Hand phase.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | art lint PASS (no `lint_over`); technique bonuses (regen, cost) sit outside `bonus_pool` |
| Validity | NOT ASSESSED | realm `hoa_than` and `nguyen_anh` loaded; tier 5 `max_realm` not checked; aux arts none |
| Stack | PASS | seven forms (flat base, timing, more, conditional, per, rule swap, increased), identity piece named, layers at caps, rung 4 a stated sacrifice |
| Scaling | PASS | INFO: every layer on the cap, above the top-end anchors by design (legend); not pulled back |
| The fight | NOT ASSESSED | the phase script (the engine) is unmodelled; the one-ward average ran, see Fight Results |
| Reuse | PASS | 15 pieces reused by name; one signature piece (Gate Turning) |
| NPC use | PASS | the generator can give a boss a phase list; each modifier reads as one Breakdown line |
| Counterplay | PASS | heavy-art builds and soul builds beat it, see Matchups; real types: a warden boss, a cleanser, a soul caster |
| Originality | PASS | no name or technique taken from a novel or game; the structure (phases) is generic |

## Fight Results

Input: `design/builds/deity-warden.fight.json`. Observations from `fight.py` on the combat simulator (`tools/design/combat_sim/sim.py`, 20 fixed seeds), not the game. The file is the Warden's one-ward average (drain ward, ws_base 100, we 100, ward and body layers at the caps, regen +7 pp, art cost −30 %).

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical | 0 | 20 / 0 / 0 | 1.9 s | never | all three arts (over before the first firing) | none |
| top_end | 0 | 16 / 4 / 0 | 22.4 s | 19.0 s | none | `soft_knee` L1 400 counts as 300 |
| top_end, Nguyên Anh form | 0 | 20 / 0 / 0 | 22.9 s | never | none | `soft_knee` |
| top_end, Hóa Thần | +1 | 0 / 20 / 0 | 7.7 s | 7.2 s | Lustral Bell | `soft_knee` |

**Identity test** (`--without lustral-bell`): `changed` at top_end+0 (22.4 s to 23.6 s, wins 16 to 17 at Hóa Thần; 22.9 s to 24.1 s at Nguyên Anh) and `NO_CHANGE` against a typical foe and at +1. The bell is the only modelled piece; it changes the fight only by a second or so, and the real identity (Gate Turning) is not testable.

**Unmodelled:** ward model change at each phase; the phase script and the 12 s clock; the soul ward and Deaf Verdict; the Iron Gate's per-hit ward; the purge bell as a timed full strip; the Open Hand phase (no ward, offence up); the Toll gap; Unyielding Breath. `model_note`: enemies exact at Qi Refining and fitted at Hóa Thần; soul, companions, triggers, conversion, guards, conditions, shields beyond the body shield and escape are not modelled.

## New Concepts

- **Phase script (Luân Môn).** An NPC or boss carries a list of phases, each with a duration, a ward model and a few stat swaps; the script runs on the fight clock. Rule: Combat rule 10 (time) and Combat Defence rule 1 (one ward). Bounds: at most four phases, at least 8 s each. Breakdown line: "Phase 2 of 4: Lustration (cleanse 0.5)". Other builds served: any phase boss, a Thiên Kiếp wave boss, and a Time Đạo "stance" player. Question for the user: do player builds get a one-time phase script too (the Turning Key)?
- **Ward-swap gap (Toll).** A swap leaves the holder wardless for a short window and discards the old ward's capacity. Same rules; serves any NPC that swaps wards and the Turning Key.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Phase script, Gate Turning | Needs rule | Combat rule 10 and Combat Defence rule 1: a ward may change model on a timer |
| Lustral Toll | Needs rule | Effects System rule 9a: a timed full cleanse with a telegraph |
| Nine-Gate Seal, Turning Key | Needs rule | an artifact that carries a timed rule |
| Deaf Verdict, Open Hand Reckoning | Needs rule | phase-guarded arts |
| Fast-Art Ward, Lustral Share, Bare Gate | Needs key | three new keys |
| Gate Hammer, Closing Palm | Needs key | art records |
| Nine Thresholds Scripture | Needs key | technique with two abilities |
| Toll Array | Needs key | combat formation payload |
