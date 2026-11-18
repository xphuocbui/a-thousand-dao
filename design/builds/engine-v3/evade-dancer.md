# Drifting Wind Dancer (Phiêu Phong Vũ Giả), geared

A Wind cultivator at the evade cap whose dodged hits feed two Wind techniques that count, hold and replay them, now dressed in the Wind family's gear. Realm: Nguyên Anh (nguyen_anh). File: `builds/evade-dancer.fight.json`. Old guide: `../engine-v2/evade-dancer.md`.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Nine-Gale Heron Fan (Cửu Phong Lộ Phiến), `wind-heron-fan` | 4 (unique) | Its art Heron Takes Wing counts as a courier art and replaces Gale Sprite in the sixth art slot; its Effect Phantom Dodge (basic attacks count as evades) is the keystone for a build that lives on evades |
| Armour | Cloud-Walker's Mantle (Đằng Vân Bào), `wind-cloud-walker-mantle` | 4 (unique) | Evade, art speed, linh lực regen and +8 % thần thức (raises the extra-slot limit); Cold Feet and Beneath Notice for the world |
| Ring | Ring of Hollow Echoes (Không Hưởng Giới), `wind-hollow-echo-ring` | 3 | Crit, evade, Wind art speed and attack; Effect Echo |
| Ring | Gale-Step Ring (Phong Bộ Giới), `wind-gale-step-ring` | 1 | Evade, Wind buff stacks, linh lực regen |
| Necklace | Swallow-Tail Pendant (Yến Vĩ Bội), `wind-swallow-tail-pendant` | 2 | Evade, regen, healing, thần thức; reserve art Swallow's Poise (basic attacks 10 % faster, evade +3 %) |
| Extra | Four-Winds Banner (Tứ Phương Phong Kỳ), `wind-four-winds-banner` (TT 20) | 3 | Every evade lays a Wind buff stack (Wind at Your Back); Wind art speed, attack, evade, regen; reserve art Standing Wind |
| Extra | Windbreak Shield (Cách Phong Thuẫn), `wind-windbreak-shield` (TT 15) | 3 | 14 % art speed, evade 6, a cast shield |
| Extra | Stitchwind Needles (Phùng Phong Châm), `general-stitchwind-needles` (TT 10) | 2 | Quick-art speed, crit, accuracy; Effect Echo (the only non-Wind piece) |

Extra thần thức: 20 + 15 + 10 = **45** against a limit of 45 × 1.0 × (1 + 0) = 45 (the items' own +14 % thần thức, Mantle 8, Pendant 3, Shield 3, would lift it to 51.3, but I did not rely on it). Three of five extra slots used. Grade 4 pieces are allowed at nguyen_anh.

## Before and after

20 runs each, `--matrix`. (The matrix labels the higher realm hoa_than+1.) The old numbers are a fresh run of the old file; they differ a little from the old guide's table (typical 2.0 s here against 1.7 s there).

Current numbers (after the 2026-11-13 budget revision, `--matrix`, 20 runs each). The pre-revision numbers in the table at the end of this section are from the over-budget file and are kept only for comparison.

| Matchup | Mean s, now | W-L-other, now |
|---|---|---|
| typical, same realm | 3.0 | 20-0-0 |
| typical, one realm higher | 6.1 | 20-0-0 |
| top end, same realm | 9.0 | 0-20-0 |
| top end, one realm higher | 5.1 | 0-20-0 |

The `--without` item and Effect tests quoted in the first geared version (fan worth 0.1–0.4 s; Wind at Your Back NO_CHANGE) were run on the over-budget `layers` and were not re-run.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Effect Phantom Dodge | Basic attacks count as evades for Feathers, Breath, Echoes | Wind sect elder at Core Formation or above, or a cliff-top ruin | In the catalogue (`wind-heron-fan`); not modelled | High |
| Armour | Cold Feet, Beneath Notice | Fleeing a higher-realm foe | Travelling Nascent Soul cultivator, or a lost waystation | In the catalogue (`wind-cloud-walker-mantle`) | Medium |
| Extra | Effect Wind at Your Back | Wind stack per evade | Event, craft, quest, NPC | In the catalogue (`wind-four-winds-banner`) | Medium |
| Ring | `stack_effect_pct` on Wind buffs | Stronger Wind stacks (no engine stat) | Gale-Step Ring, Heron Fan, Banner, Pendant | In the catalogue | Medium |
| Weapon, any | Evade-cleanse of own stacks | Lost answer to ticks (see old guide) | none | Missing | Medium |
| Extra | Slow Hour Needle `wind-slow-hour-needle` (TT 10) | Slow-hour art feeding the Slowed Time gates | Wind family | In the catalogue; did not fit the 45 TT limit | Low |

## Missing pieces

- An evade-cleanse treasure (cleans own stacks on an evade, 2 batches per 6 s): the Wind family should own it, the lost Scatter Gale.
- A ward that stops damage ticks (Carried Off in the old guide) for an evade build: Wind or general.
- A thần thức pendant or banner that lifts the extra limit so a build can wear both Banner and Mirror of Second Seat: general.

## UNMODELLED

- Effect Phantom Dodge (Heron Fan): the engine has no action that raises an evade event from a basic attack, so basics cannot feed `evaded` Effects.
- Effect Echo (Hollow Echoes ring, Stitchwind Needles): its rule is in `effects.md`, which this run did not read, so I did not guess an engine form.
- Effects Cold Feet, Beneath Notice (Mantle): same reason, and both are out-of-fight.
- Cloud-Walker's Veil ward (block 72, evade +14.4 pp): not a drain ward, and evade is already at 40; the build's drain ward stays.
- Windbreak Screen cast shield: no cast-shield payload in the engine; the build's ward stays.
- Reserve arts Swallow's Poise and Standing Wind: the engine does not deduct the reserve and does not run their grants (not run; the pair would add basic speed 10, evade 6, art speed 5.8).
- `stack_effect_pct` on Wind buffs (Fan 25, Banner 20, Pendant 15, Gale-Step 12), `than_thuc_pct`, `khi_huyet_pct`, `defense_pct`, `linh_luc_pct`: no engine stat.
- Wind art speed scopes (Fan, Banner, Hollow Echoes) and quick scope (Needles): applied to every art by the engine.
- Everything the old file listed (evaded hit pays linh lực, Wind stack from evade, riposte, evade_cap keystone) is kept.

## Observations

Gear mattered little in the first geared version, and the build was over budget (see below). The keystone Phantom Dodge still cannot run, so the fan's art Heron Takes Wing carries it. Fights are well under the 30–60 s band (typical 3.0 s, top end 9.0 s). Against the typical same-realm foe hundred-feather-flurry, three-step-chase, trailing-gale and Heron Takes Wing are NEVER_FIRED (the foe dies first). Gale Sprite was swapped out for Heron Takes Wing, which the old guide rated as the weakest art.

## Budget revision (2026-11-13)

**What changed.** `layers` went from [400, 260, 250, 150, 100] to [210, 120, 80, 40, 30]. The claimed share of the typical-to-top-end gap fell from 103 % to 22 % (nguyen_anh budget 23 %, `layer_budget` printed). Nothing else in the file changed: techniques, items, arts, ward, body and effects are as before.

**Why.** The old values were the whole Map-and-gear total written as a layer claim. The techniques' passives and the items' modifiers already run as Effects, so counting them again in `layers` double-booked them. `layers` now holds only the Đạo Đồ share the concept needs.

**What was cut first.** L5 (100 to 30), L4 (150 to 40) and L3 (250 to 80) were cut hardest: an evade-and-speed build lives on its dodge and art speed, which come from items, not these layers. L1 (400 to 210) and L2 (260 to 120) were kept highest because crit and art output run through them.

**How the fights moved** (old -> new, fresh runs of both files, 20 runs, `--matrix`):

| Matchup | Mean s | Wins-losses |
|---|---|---|
| typical, same realm | 1.2 -> 3.0 | 20-0 -> 20-0 |
| typical, one realm higher | 2.1 -> 6.1 | 20-0 -> 20-0 |
| top end, same realm | 7.1 -> 9.0 | 17-3 -> 0-20 |
| top end, one realm higher | 5.1 -> 5.1 | 0-20 -> 0-20 |

The build no longer beats the top-end same-realm enemy; that is intended for a build at budget. It still beats a typical same-realm enemy, in 3.0 s, faster than the 10–20 s the budget rule expects, so the gear and evade carry it.
