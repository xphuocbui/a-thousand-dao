# cooldown-floor: The Winnowing Gale (Dương Khang Phong), geared: cheap quick Wind arts held at the 0.5 s cooldown floor, paid by per-hit linh lực, with a Wind item set. Realm: Nguyên Anh (nguyen_anh).

Fight file: `design/builds/engine-v3/builds/cooldown-floor.fight.json` (a copy of the engine-v2 file; every number is the old file's, none tuned). Old guide: `design/builds/engine-v2/cooldown-floor.md`.

## Loadout

Realm nguyên anh: grade at most 4, unique items allowed. No `divine_sense` in the file (1.0).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon (base) | Nine-Gale Heron Fan (Cửu Phong Lộ Phiến) `wind-heron-fan` | 4 unique | Its art Heron Takes Wing counts as a Gale Courier Scripture art (the build's main suite) and replaces Reckless Gale; Phantom Dodge feeds the Feather and Breath counters from landed basic attacks; Wind art speed and attack. |
| Armour (base) | Cloud-Walker's Mantle (Đằng Vân Bào) `wind-cloud-walker-mantle` | 4 unique | Art speed +12 and evade +8 with no scope, +8 % thần thức (which widens the extra budget). Its ward and escape Effects are not used. |
| Ring | Ring of Hollow Echoes (Không Hưởng Giới) `wind-hollow-echo-ring` | 3 | Echo (25 % free strike), crit +5, Wind art speed and attack. |
| Ring | Gale-Step Ring (Phong Bộ Giới) `wind-gale-step-ring` | 1 | Evade +3 and linh lực regeneration, which feed Held Breath and Echo of the Dodge. The only other Wind ring. |
| Necklace | Swallow-Tail Pendant (Yến Vĩ Bội) `wind-swallow-tail-pendant` | 2 | Evade, linh lực regeneration, healing, +3 % thần thức. Its reserve art is not run. |
| Extra | Four-Winds Banner (Tứ Phương Phong Kỳ) `wind-four-winds-banner` | 3 | TT 20. Wind at Your Back (an evade gives a Wind stack), Wind art speed and attack, linh lực. |
| Extra | Windbreak Shield (Cách Phong Thuẫn) `wind-windbreak-shield` | 3 | TT 15. Art speed +14 with no scope, evade +6, +3 % thần thức. |
| Extra | Slow-Hour Needle (Trì Thời Châm) `wind-slow-hour-needle` | 2 | TT 10. Its art Stitch the Hour is a Slow Hour Scripture art and replaces Gale Sprite; attack and art speed. |
| Extra | (empty) | - | - |
| Extra | (empty) | - | - |

Thần thức: 20 + 15 + 10 = **45** against a limit of 45 × 1.0 × (1 + 14 / 100) = **51.3** (than_thuc_pct: mantle 8, pendant 3, shield 3). The two empty slots stay empty: the next cheapest piece (a ring, TT 8) would reach 53. Arts: Heron Takes Wing replaces Reckless Gale and Stitch the Hour replaces Gale Sprite, so the file still holds 7 arts in 6 + 1 slots.

Written as engine Effects: **Echo**, **Wind at Your Back** and **Phantom Dodge** (with its stated cost, evade −10 pp, as a separate always-on record).

## Before and after

The "old" column is the engine-v2 file run again on today's engine, so it differs from the old guide's table (3.0 s, 5.9 s).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 4.3 | 2.7 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 10.8 | 6.6 | 18-2-0 | 20-0-0 |
| top_end nguyen_anh+0 | 2.0 | 3.0 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 1.1 | 1.3 | 0-20-0 | 0-20-0 |

`--without` (geared file, mean s and W-L; "before" is the geared row above):

| Test | typical nguyen_anh+0 | typical hoa_than+1 | top_end nguyen_anh+0 | top_end hoa_than+1 |
|---|---|---|---|---|
| `--without item:wind-heron-fan` | 2.9 s, 20-0 | 6.8 s, 20-0 | 2.7 s, 0-20 | 1.2 s, 0-20 |
| `--without eff:Phantom Dodge` | 2.8 s, 20-0 | 6.7 s, 20-0 | 3.0 s, 0-20 | 1.3 s, 0-20 |
| `--without eff:Echo` | 2.9 s, 20-0 | 6.6 s, 20-0 | 2.7 s, 0-20 | 1.5 s, 0-20 |

The Heron Fan is the item I took as mattering most (its art and its Effect); removing it moves the typical fights by about 0.2 s.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Phantom Dodge | Landed basic attacks fill Feathers and Breath | Nine-Gale Heron Fan, held by a Wind sect elder at Core Formation or above | In the catalogue (new Effect, unique) | High |
| Weapon art | Heron Takes Wing (courier group) | A 3.5-times finisher in the main suite | Same fan | In the catalogue | High |
| Armour | art_speed_pct (unscoped) +12, evade +8 | Speed toward the floor | Cloud-Walker's Mantle, a travelling Nascent Soul cultivator | In the catalogue | High |
| Ring | Echo | 25 % free strike on art hits | Ring of Hollow Echoes | In the catalogue | Medium |
| Extra | art_speed_pct (unscoped) +14 | Speed without a Wind scope | Windbreak Shield | In the catalogue | Medium |
| Extra | Wind at Your Back | Evades give Wind stacks | Four-Winds Banner | In the catalogue | Low (the build evades 3 to 25 %) |
| Ring | Evade and a stack-effect modifier on a grade 3+ ring | A better second ring than a grade 1 band | Wind ring | Missing | Medium |
| Extra | Plain art_speed_pct on a cheap (TT 6 or less) piece | Fills the last 6 thần thức | Wind utility piece | Missing | Low |

## Missing pieces

- A Wind ring above grade 1 with art speed and cost reduction (wind family): the build has one real ring and one filler.
- A Wind treasure that lowers art cost or feeds linh lực per hit (wind family, or general): the build pays per hit and nothing in the catalogue answers that.
- An item that makes an art's cooldown floor a rule (the lost Slipstream), a Wind unique (wind family).
- A cheap utility extra (TT 6 or less) so the last 6 thần thức can be spent (general).

## UNMODELLED

- Phantom Dodge's evade event: written as Feather and Breath counter steps from landed basic attacks (twice a pulse), because the engine has no action that raises an evade event. The Breath bank (held free hit and Wind stack) and Echo of the Dodge's evade count do not see these.
- Windbreak Shield's cast ward (shield σ 0.1125) and Cloud-Walker's Veil (reserved block 72, evade +14.4 pp): the build keeps the typical Common Ward; neither beats a modelled drain ward I could name.
- Reserve arts of the pendant (Swallow's Poise, 10 %) and the banner (Standing Wind, 8 %): reserved linh lực is not deducted and the grants are not run.
- Cold Feet and Beneath Notice on the mantle: escape is not modelled, and the build does not rely on them.
- Item modifiers with no engine stat: stack_effect_pct [phong, buff] (fan, banner, both Wind rings/pendant), than_thuc_pct, khi_huyet_pct, linh_luc_pct, defense_pct, status_duration_pct [curse].
- Scoped art_speed_pct ([phong], [quick]) on items: the engine applies it to every art, which slightly over-credits the set.
- The old file's lost pieces (Slipstream, Light Chaff, Breath Between Blows, Eruption, Trigger limit, Overheat) stay lost.

## Observations

Gear changed the typical fights, not the top-end ones: the typical Nguyên Anh fight went from 4.3 s to 2.7 s and the one-realm-up fight from 10.8 s (18-2) to 6.6 s (20-0); against top_end the build still dies (3.0 s and 1.3 s, 0-20 both times) and lived slightly longer only because it has more evade and art speed. Every geared fight is far below the 30-60 s band, so the build stays a burst build rather than a sustain fight, and it was already below it before gear. No item made it degenerate in these runs, but the shortness is the open point: the old guide's identity (Slipstream) is still missing and the two unique items add speed to an already clipped build (echo-crit is clipped 6 to 23 times a fight). The Heron Fan, the item I expected to matter most, moves the typical fights by only about 0.2 s, and Phantom Dodge and Echo by 0.1 to 0.3 s each, so most of the gain comes from the plain art speed and attack lines (mantle, shield, banner, rings) and the two swapped-in arts. Fired nothing: Three-Step Chase against typical same-realm foes (0.0 a fight) and Hundred-Feather Flurry and Three-Step Chase against top_end hoa_than+1 (0.0), because those fights end in about a second; Wind at Your Back barely fires (clipped 0.1 a fight), since the build evades little.
