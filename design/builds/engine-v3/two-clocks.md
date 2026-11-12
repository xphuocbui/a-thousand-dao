# Two Clocks (Song Thời), geared

Never strike: bury the enemy in Burn (fast clock) and Poison (slow clock) until their linh lực runs dry and the rot finishes them. Realm: Nguyên Anh (nguyen_anh).

File: `design/builds/engine-v3/builds/two-clocks.fight.json` (a copy of the engine-v2 file plus `items`, two swapped arts and one Effect). Nothing was tuned.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Ashen Phoenix Fan (Tro Phượng Phiến) `fire-ashen-phoenix-fan` | 4 unique | +22 % attack on over-time, +15 % Fire; its art Ash-Feather Gale lays 3 Burn and counts for Ashen Phoenix Canon. Replaces heat-haze in the art slots |
| Armour | Grave-Silk Robe (Mộ Ti Bào) `wood-grave-silk-robe` | 4 unique | The Slow Garden's keystone: +24 % over-time attack, longer and stronger Poison, a Fire-resist veil |
| Ring | Ring of the Slow Garden (Hoãn Viên Giới) `wood-slow-garden-ring` | 3 | +14 % over-time attack, longer and stronger Poison, Spillover (the guide's own missing piece) |
| Ring | Cinder Ring (Hỏa Tẫn Giới) `fire-cinder-ring` | 1 | +7 % over-time attack, a stronger Fire buff |
| Necklace | Hearth-Keeper Pendant `fire-hearth-keeper-pendant` | 2 | Reserve art, a little thần thức and health; the only cheap necklace for Fire |

| Extra slot | Item | Grade | TT |
|---|---|---|---|
| Extra 1 | Undying Ember Lantern (Bất Diệt Tàn Đăng) `fire-undying-ember-lantern` | 4 unique | 15 |
| Extra 2 | Furnace-Mouth Gourd (Lô Khẩu Hồ Lô) `fire-furnace-mouth-gourd` | 2 | 25 |
| Extras 3-5 | empty | | 0 |

Why the extras: the Lantern adds +20 % over-time attack and +30 % Burn stack effect, and its Embers Never Die makes the Burn clock uncleansable. The Gourd's art swallows 5 Burn stacks into a 2.2× hit, and its Kindled Wound (Fire parts deal more to a burning foe) fits the Fire clock. The Gourd's art replaces thornling-grove.

Thần thức total: 15 + 25 = 40, against a limit of 45 × 1.0 × (1 + 20 / 100) = 54 (than_thuc_pct: robe 6, pendant 4, Lantern 10 = 20). Twelve to spare; nothing else at ≤ 14 TT served the build.

## Before and after

"Old" is the engine-v2 file run on today's engine (the v2 guide quoted 20.5 s and 54.7 s; the engine has changed since). 20 seeds each.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 34.6 | 29.8 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 66.0 | 65.0 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 13.9 | 12.8 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 5.8 | 5.7 | 0-20-0 | 0-20-0 |

Foe dry at typical nguyen_anh+0: 25.6 s old, 23.6 s geared. At typical hoa_than+1: 51.5 s old, 43.9 s geared, and health left rises from 29 % to 69 %.

`--without` (geared file, typical nguyen_anh+0, 29.8 s, 20-0-0):

| Removed | Mean s | W-L-other |
|---|---|---|
| `item:fire-furnace-mouth-gourd` (its modifiers only; the art stays) | 30.7 | 20-0-0 |
| `eff:Kindled Wound` | 33.0 | 20-0-0 |
| `item:fire-ashen-phoenix-fan` (its modifiers only; the art stays) | 29.8 | 20-0-0 |
| `item:wood-grave-silk-robe` | 29.8 | 20-0-0 |
| `item:fire-undying-ember-lantern` | 29.8 | 20-0-0 |

The item that matters most is the Furnace-Mouth Gourd, through Kindled Wound (+3.2 s when removed) and a little through its own modifiers (+0.9 s). `--without item:` removes an item's plain modifiers, not its arts, so the Fan's art Ash-Feather Gale (3.2 casts a fight) is not tested by it.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Fan, Robe, Ring, Lantern | stack_duration / stack_effect on Burn and Poison | Longer, stronger clocks; the engine has no stat for them, so none of it ran | Items already worn | In the catalogue (not run) | High: the engine needs the stat to show it |
| Ring | Spillover | Each clipped tick burns the foe's linh lực, the guide's missing identity piece | Wood ring | In the catalogue (not run) | High |
| Armour | Grave-Silk Shroud | A permanent Poison tick from t = 0 with no slot | Robe | In the catalogue (not run) | Medium |
| Weapon | Fan the Pyre | Each Fire hit refreshes Burn batch timers | Fan | In the catalogue (not run) | Medium |
| Extra | Embers Feed the Hearth (25 % of Burn tick damage back as linh lực) | Sustain for the Burn clock | Fire item | Missing | Medium |
| Extra | Ash Ledger (tick resistance burns linh lực) | The build's identity piece | Fire or force-chaos item | Missing | High |
| Extra | Twin-Wick Incense Clock | L5 payloads also on ticks | Fire item | Missing | Low |
| Necklace | A damage necklace for Fire or Wood with modifiers | The Pendant gives only a reserve and 4 % TT | Fire or wood family | Missing | Low |

## Missing pieces

- An Ash Ledger piece (tick damage resistance stops burns linh lực): fire family, or force-chaos for the drain.
- Embers Feed the Hearth as an item Effect: fire family.
- A Twin-Wick Incense Clock enabler item (extra slot): fire family, or soul-song-seal for its incense base.
- A Wood necklace with modifiers (Poison duration and effect): wood family.
- A second cheap extra for Burn or Poison: fire or wood, at ≤ 12 TT, since 12 TT are left over.

## UNMODELLED

- Fan the Pyre: no action restarts a Burn batch's timer; its 15 % less direct Fire hit is also not run.
- Spillover: no action drains the foe's linh lực (`gain_qi` has no side).
- Grave-Silk Shroud: no action creates a standing tick; its 25 % reserve is not deducted.
- Embers Never Die and the Lantern's reserve art: cleanse immunity; no matchup has a cleanser.
- Item wards (Grave-Silk Veil, Fire 450): not modelled. Its payload and drain 0.33 are the starter veil at 1.5 times, but the old pass ward stays (this guide did not swap it).
- Item modifiers with no engine stat (stack_duration, stack_effect, than_thuc, khi_huyet, linh_luc, reserve arts) are listed by fight.py and not run.
- All pieces already unmodelled in the engine-v2 file remain (Incense Clock, Ash Ledger, Cinder Debt, Embers Feed the Hearth, drain-ward billing of ticks).

## Observations

Gear mattered a little, and only for the typical foe: typical nguyen_anh+0 drops from 34.6 s to 29.8 s, which is still under the 30-60 s band's lower edge at 29.8 s (just), and typical hoa_than+1 stays at 65.0 s, just over the band. The top-end foe still wins all 40 fights, 12.8 s and 5.7 s, so nothing made the build degenerate and nothing rescued the bad matchup. Most of the gear's value sits in modifiers the engine has no stat for (stack_duration, stack_effect), in Effects it cannot express (Spillover, Fan the Pyre, Grave-Silk Shroud, Embers Never Die), and in the Fan's and Robe's over-time attack, which `--without` shows adding nothing at all (29.8 s with or without them), so the clocks are held back by caps: canker-spread, canker-wither and gale-cinder are clipped hundreds of times a fight at typical nguyen_anh+0. What fired: the Gourd's Kindled Wound (+3.2 s) and the Gourd's art (3.0 casts at top end), Ash-Feather Gale (3.2). What fired nothing: the Lantern, the Robe's modifiers and the Fan's modifiers in the typical fight, the Cinder Ring and Hearth-Keeper Pendant (all stats unread), and flint-volley is still NEVER_FIRED at top_end hoa_than+1.
