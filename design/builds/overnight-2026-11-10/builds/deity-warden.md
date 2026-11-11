# The Nine-Gate Warden (Cửu Quan Thủ Hộ Giả)

A Hóa Thần (Deity Transformation) boss that shuts one door on you every 12 seconds, and rewards the player who has a second way in.

> This guide is for the player who meets the Warden. "The build" below is the Warden itself; the shopping list in "Upgrades to look for" is what you bring to beat it. Numbers on new pieces are first guesses. Matchups with other builds are predictions from their names and staged pieces, not simulations.

## Why it works

The Warden runs a clock. Four phases of 12 s in a fixed order, each with a different ward and each closing exactly one of your channels:

| Seconds | Phase | Its defence | Shut channel |
|---|---|---|---|
| 0–12 | Iron Gate (Thiết Môn) | per-hit ward and flat block | many small hits: basic attacks, fast arts, a companion |
| 12–24 | Lustration (Tẩy Lễ) | cleanses 0.5 of every stack each pulse | ticks, element stacks, curses |
| 24–36 | Deaf Gate (Tuyệt Thính) | a soul ward, and a Deaf Verdict soul hit back | soul arts |
| 36–48 | Open Hand (Khai Chưởng) | no ward, but a body shield and 40 % more damage | ward-breaking, starving, and sitting still |

A Purge Bell (Tẩy Chung) tolls every 10 s in every phase: 1.5 s after it swings, every stack and curse on the Warden is gone. Before each swap there is a 2 s Toll in which it has no ward at all.

Key numbers from the simulator, using the Warden's one-ward average: it beats a typical Hóa Thần foe 20 of 20 in under 2 s, and a top-end Hóa Thần player 16 of 20 in about 22 s. Its layers sit on every cap (offence 400 / 300 / 250 / 150 / 100); its sustain is +7 points of regeneration and art cost down 30 %. It is hard because a build that has only one channel spends a quarter of every cycle shut out and runs dry. It is fair because the order never changes and every swap rings a bell first.

## What to look for

In the order you find them.

| Piece | The Warden has | Status |
|---|---|---|
| Spiritual root (linh căn) | Metal and Earth (Kim Thổ), purity 80 / 70 | in the game |
| Talents | Physique, Comprehension, Willpower | in the game |
| Đạo and nodes | Tứ Thời Đạo (Luân Niên, the Turning Year), Kim Đạo (Thối Thể) | not in the game yet (staged: luan-nien-gate); the Ways are a roster draft |
| Công pháp | Nine Thresholds Scripture (Cửu Quan Kinh), main, tier 5 | not in the game yet (staged: cuu-quan-kinh) |
| Arts | Gate Hammer, Closing Palm, Lustral Bell, Deaf Verdict, Open Hand Reckoning | not in the game yet (staged: gate-hammer, closing-palm, lustral-bell, deaf-verdict, open-hand-reckoning) |
| Items | Toll Array (a formation), Turning Key (your reward) | not in the game yet (staged: toll-array, turning-key) |
| Enabler | Nine-Gate Seal (Cửu Quan Ấn) | not in the game yet (staged: nine-gate-seal) |

Where you meet it: the vault of a founding sect, or the last test before a Hóa Thần master takes a disciple.

## The enabling Effects

- **Gate Turning (Chuyển Quan).** Every 12 s the Warden's ward changes model and the old capacity is thrown away. A swap leaves a 2 s Toll with no ward. The build needs it because it is the whole boss: without it the Warden is one top-end ward.
- **Lustral Toll (Tẩy Chung).** Every 10 s a bell swings, then 1.5 s later all stacks and curses on the Warden are removed. The build needs it so a poison pile cannot just run for 48 s. Reuses the cleanse telegraph idea.
- **Unyielding Breath (Bất Khuất).** Once, a killing blow leaves it at 1 health. It needs it so one saved volley cannot end the fight in the Toll. Already in the tree catalogue.
- **Bare Gate (Lộ Quan).** 40 % more damage while its ward is down. It needs it so the Open Hand is dangerous, and a pure turtle cannot just wait.

## Modifiers to stack

The Warden's own priority list, which is also what to expect in a top-end player's counter-kit.

1. **Layers on the caps (L2 to L5).** One source for each: scripture arts (L2), the Seal and armour (L3), the Toll Array (L4), Bare Gate (L5). Stop at the caps; the cap hits are named `soft_knee` on L1, where 400 counts as 300.
2. **Sustain: regeneration, cost, health regen.** The fuel layer: it must outlast a 48 s cycle. Stop when the pool never dries in the sim (it dries at 19 s against a top-end foe, so it is the margin).
3. **Fast-Art Ward** (more ward vs arts under 2 s and basic attacks, Iron Gate only). W2 layer. Falls off in the other phases by design.
4. **Lustral Share** (cleanse 0.25 to 0.5). Falling returns past 0.5; the pulse removes a share, never everything.
5. **Status and soul resistance.** Small, stack up to a notable each, then stop.

## Upgrades to look for

What a player shops for to beat it. Core first.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Heavy Hand (Trọng Thủ) | More damage on arts with cooldown 5 s or more | Gets through the Iron Gate block; ignores the bell | Keystone, tree | staged (catalogue) | core |
| Sheathed Blade (Ẩn Phong) | A waiting art hits harder per second waited | Hold fire in your dead phase, release at the Toll | Keystone, tree | staged (catalogue) | core |
| Toll Array (Đối Quan Trận) | 25 % more damage 4 s after an enemy ward swap | Doubles the window | Formation, Alchemy and Formation craft | staged (toll-array) | core |
| Turning Key (Chuyển Quan Thược) | Swap your own ward model once | Counters the Open Hand's heavy hits | Boss reward | staged (turning-key) | strong |
| Quiet Mirror Talisman (Tĩnh Kính Phù) | Soul ward back | Lets you stand the Deaf Verdict | Talisman | staged | core |
| Soul resistance (`soul_res_pct`) | +6 % notable | Shrinks the Verdict | tree notable | in the game | strong |
| Rolling Refresh (Lan Bệnh) | Reapplies stacks on a trigger | Rebuilds after the bell | Effect, Plague facet | staged | strong |
| Tally Ten (Thập Kết) | Spends ten stacks for a hit | Converts stacks before the bell | Effect | staged | strong |
| Spirit Severing (Đoạn Linh) | Hits burn the enemy's linh lực | Starves the Warden, but fails in the Open Hand | Keystone | staged (catalogue) | nice |
| Unyielding Breath answer | Burst past its last breath | Needs a second volley after the first | Sustain stack | in the game (regen, cost) | core |
| Twin Wards (Song Hộ) | Second ward at half strength | A stand-by ward while the Open Hand hits | Keystone | staged (catalogue) | strong |
| Seeing Eye (Động Sát) | Reveals the enemy's profile | Shows the phase list before the fight | Keystone | staged (catalogue) | nice |
| Status resistance (`status_resist_pct`) | +6 % notable | Shrinks Closing Palm's stacks on you | tree notable | in the game | nice |
| Against the Heavens (Nghịch Thiên) | More damage per realm above | For a player a realm below | Keystone | staged (catalogue) | nice |
| Fast-Art Ward and Lustral Share | Both new modifiers | What a Warden-class defender has; the top-end step for a player's own Gate | Turning Year cluster (Luân Niên) | staged (luan-nien-gate) | nice |

## Realm by realm

- **Nguyên Anh (Gate-Guard).** Two phases only (Iron Gate, Lustration). The sim with the same layers shows a top-end player winning 20 of 20 in about 23 s. This is the lesson: learn the bell.
- **Hóa Thần (the Warden).** All four phases, the soul voice, the Open Hand and Unyielding Breath. At one realm below the Warden a player loses in about 8 s; the "gap" is a real wall.
- **Above Hóa Thần.** Not in the game yet. A Warden of the Heavenly Tribulation would add phases, not stats.

## How it plays

Art order for the Warden: Gate Hammer, Closing Palm, then the Bell on its clock. Loadout five to six slots. The signature moment is the Toll: a quiet 2 s with the ward gone.

For the player: open with whatever the Iron Gate does not stop (a heavy art, or soul); at 10 s step back from stacks, they will be wiped; in the Toll at 12 s spend your saved volley; in Lustration use hits and soul; in the Deaf Gate use hits and ticks (the bell strips them again every 10 s, so apply after 30 s); in the Open Hand put up your best ward and burst. Learn the order once; it never changes.

## What beats it

Predicted, not simulated.

| Beats the Warden | Why |
|---|---|
| Heavy-art builds (slow-thunder, giant-killer, one-art) | Block and cleanse do not touch a big hit, and the Toll gives them a free volley. They need a second volley after Unyielding Breath |
| Soul builds (soul-lance) | Soul ignores ward models, so three of four phases are open; hold fire in the Deaf Gate |
| Top-end body (thể tu) builds with sustain | Win on the Open Hand: body layers meet its offence |

| The Warden beats | Why |
|---|---|
| Stack and curse builds (status-collector, curse-engine, starter-venom, two-clocks) | The bell and Lustration strip them on a clock |
| Fast-hit builds (bare-fist, starter-blade, cooldown-floor, beast-carry) | Iron Gate block and per-hit ward |
| Starvers (dry-well, starter-tide) | The Open Hand has no ward and no linh lực use to drain |
| Pure first-volley builds (first-volley) | Unyielding Breath and the ward reset at a swap; they have no second volley |

Even: walls and returners (starter-wall, home-fortress, unkillable, mirror-hide, evade-dancer). They survive its slow hits but have one channel of damage; the fight ends in fatigue. Real enemy types it echoes: a warden boss, a cleanser (Combat rule 18) and a soul caster.

Adapting: carry two channels and one saved volley; never spend your whole pool in the phase that shuts you.

## Not in the game yet

Every staged piece: phase script, Gate Turning, Lustral Toll, Nine-Gate Seal, Turning Key, Toll Array, Nine Thresholds Scripture, Gate Hammer, Closing Palm, Lustral Bell, Deaf Verdict, Open Hand Reckoning, Fast-Art Ward, Lustral Share, Bare Gate, the Turning Year cluster (Luân Niên), the ward-swap gap concept. All in `deity-warden.staging.md`.

## Changes the game would need

- **Boss phase script.** Combat rule 10 (time) and Combat Defence rule 1 (one ward): allow an NPC to carry a list of phases, each with a duration, a ward model and stat swaps. See `deity-warden.suggestions.md`.
- **Ward swap gap.** Combat Defence rule 1: when a ward model changes, the old capacity is discarded and a short ward-less window opens. Same suggestions file.
