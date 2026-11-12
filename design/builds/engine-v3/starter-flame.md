# The Hearth Keeper (Thủ Lô Hỏa Giả), geared

A Fire caster that burns the enemy with a tempo suite of Fire arts and lets the Burn refill its linh lực; here it wears the fire family's items. Realm: Kết Đan (Core Formation, `ket_dan`).

Fight file: `design/builds/engine-v3/builds/starter-flame.fight.json` (copy of the engine-v2 file plus `items`, two item arts and one Effect).

## Loadout

`divine_sense` is absent (1.0). The extra limit is 45 × 1.0 × (1 + than_thuc_pct / 100). The loadout's own thần thức % (Phoenix Plume 4, Hearth-Keeper Pendant 4, Undying Ember Lantern 10 = 18 %) would lift it to 53.1; the loadout is chosen to fit the plain 45 either way.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Ashen Phoenix Fan (Tro Phượng Phiến), `fire-ashen-phoenix-fan` | 4 (unique) | Its art Ash-Feather Gale (Tro Vũ Cuồng Phong) names the Ashen Phoenix Canon as its suite and feeds on Burn ticks; it replaces Heat Haze in the art slots. Fire/over-time attack modifiers; Fan the Pyre (Burn never expires) is the Bonfire's keystone but is UNMODELLED. |
| Armour | Phoenix Plume Armour (Phượng Vũ Giáp), `fire-phoenix-plume-armour` | 3 | Phoenix Mend turns every art heal (Brazier Form's mending) into Burn on the foe. Healing +14 %, Fire resist. |
| Ring 1 | Cinder Ring (Hỏa Tẫn Giới), `fire-cinder-ring` | 1 | Over-time attack +7 %, stronger Fire buff. |
| Ring 2 | Ring of Blood Kindling (Huyết Dẫn Giới), `fire-blood-kindling-ring` | 3 | Fire attack +10 %, Fire art speed +10 %, health leech; its Blood Casting Effect is not needed and not run. |
| Necklace | Hearth-Keeper Pendant (Thủ Lô Bội), `fire-hearth-keeper-pendant` | 2 | Fire attack +6 %, regen, healing; its reserve art would boost Burn but is not run. |
| Extra 1 (TT 30) | Red Sun Seal (Hồng Nhật Ấn), `fire-red-sun-seal` | 3 | Its art Red Sun Descends counts as a Red Sun Scripture art, so Furnace Heart, Flint Volley and Brazier Form engines count it; it replaces Twin Flame Echo. |
| Extra 2 (TT 15) | Undying Ember Lantern (Bất Diệt Tàn Đăng), `fire-undying-ember-lantern` | 4 (unique) | Over-time attack +20 %, Burn stacks +30 %; Embers Never Die guards Burn against cleansers (UNMODELLED, a typical foe never cleanses). |
| Extra 3, 4 | empty | | Gourd (25) and Robe (6) would break the limit. |

Thần thức total: 30 + 15 = **45 of 45** (53.1 with the loadout's thần thức %). Grades are all at most 4; both unique items are allowed at Kết Đan.

Art slots (still 5): Brazier Form, Flint Volley, Furnace Heart, Red Sun Descends (was Twin Flame Echo), Ash-Feather Gale (was Heat Haze). Effect run: `eff:Phoenix Mend` (on `heal_restored`, 1 fire stack on the foe per 1 % of max health restored, at most 6 a pulse, 6 s; Phoenix Mend is a new Effect in the catalogue).

## Before and after

Old = the engine-v2 file run today (the engine has changed since the v2 guide: it printed 17.9 s then, 27.7 s now).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, Kết Đan | 27.7 | 19.1 | 20-0-0 | 20-0-0 |
| typical, Nguyên Anh | 11.2 | 11.6 | 0-20-0 | 0-20-0 |
| typical, Hóa Thần | 4.0 | 4.0 | 0-20-0 | 0-20-0 |
| top_end, Kết Đan | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end, Nguyên Anh | 1.0 | 1.0 | 0-20-0 | 0-20-0 |
| top_end, Hóa Thần | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

Same-realm fight: you never run dry; foe dry at 20.8 s old, 15.7 s geared; health left 97 % old, 100 % geared.

`--without` tests (typical, Kết Đan, geared 19.1 s, 20-0):

| Test | Result |
|---|---|
| `--without item:fire-ashen-phoenix-fan` | 19.0 s, 20-0 (only its plain modifiers are removed; its art stays slotted) |
| `--without item:fire-red-sun-seal` | 19.3 s, 20-0, foe dry 16.1 (same: modifiers only) |
| `--without eff:Phoenix Mend` | 21.3 s, 20-0 (the item Effect that matters most: +2.2 s without it) |

Every other matchup was not run for the `--without` tests.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Fan the Pyre | Burn batches refresh on every Fire hit, so Burn never lapses | Fire sect elder with the fan (Core Formation+) or a burned-out secret realm | In the catalogue (Ashen Phoenix Fan); not run | High |
| Armour | Phoenix Mend | Art heals add Burn to the foe | quest / npc / craft | In the catalogue (Phoenix Plume Armour) | High |
| Extra | Stack effect / duration on Burn | Stronger and longer Burn (Cinder, Lantern, Pendant, Fan carry it) | craft | Catalogue has it; the engine has no stat for it | Medium |
| Necklace | Hearth Aura reserve | Burn batches +25 % longer, +10 % stronger for 12 % linh lực | npc / craft | In the catalogue (Hearth-Keeper Pendant); not run | Medium |
| Ring | Burn tick returns linh lực (Embers Feed the Hearth) | The build's linh lực engine as a real item Effect | — | Missing | Medium |
| Weapon/Ring | Fire hits cheaper or faster per Burn stack on the foe | Ties tempo to the Burn pile | — | Missing | Low |
| Extra | Furnace-Mouth Gourd | Spends 5 Burn for a heavier hit; Kindled Wound | craft / npc | In the catalogue; left out for thần thức | Low |

## Missing pieces

- A ring or necklace carrying Embers Feed the Hearth (a Burn tick returns linh lực): fire family.
- A heat-keeping item for Furnace Heart's Heat counter (slower Heat decay or Heat gain on a Burn tick): fire family.
- A plain cheap Burn weapon art in the Red Sun / Ashen Phoenix suites (the old Spark Palm rhythm): fire family.

## UNMODELLED

- Fan the Pyre (refresh every Burn batch on a Fire hit): the engine has no action that restarts a debuff timer.
- Fan the Pyre's cost (direct Fire hits deal 15 % less): not applied, so direct damage is overstated.
- Embers Never Die and Lantern of the Long Burn: the typical foe has no cleanse, so nothing can be observed; the reserve is not deducted.
- Hearth Aura reserve (12 % linh lực): not deducted, grants not run.
- Blood Casting (Blood Kindling ring): not needed by this build (linh lực never runs dry), not written.
- Phoenix Shell cast ward: not modelled as a drain ward; the build's ward is kept.
- Item modifiers with no engine stat (stack effect, stack duration, khi huyet, linh lực %, health regen inc, defense, thần thức); the Fire-scoped art speed of the Blood Kindling ring and the Red Sun Seal applies to every art.
- Kindled Wound on the Furnace-Mouth Gourd: the gourd is not worn; the build already carries the old always-on L5 15.
- The old file's own lines (Embers approximation and the rest) are kept as they were.

## Observations

Gear moved the same-realm fight from 27.7 s to 19.1 s with 100 % health left (old 97 %), so it matters at Kết Đan, and the fight is now further below the 30-60 s band (the old file was already below it today). One realm up it still loses in about 11.6 s (old 11.2) and Hóa Thần and top-end fights are unchanged, so gear does not change the matchups the build loses. No item made the build degenerate: all 20 same-realm fights are still won, none ends early on a single burst. The Phoenix Mend Effect did the most: removing it gives 21.3 s, while removing either art item's modifiers moved the fight by about 0.1-0.2 s (the arts themselves were not removed by `--without item:`). The unmodelled pieces (Fan the Pyre's refresh, stack effect and duration modifiers, Hearth Aura) are the ones the build should gain most from, so the geared figure is likely a floor. NEVER_FIRED: Brazier Form, Flint Volley, Red Sun Descends at Hóa Thần+2 (Ash-Feather Gale and Furnace Heart fire once), all five arts at every top_end matchup; the Cinder counter on Ash-Feather Gale is clipped 36.6 times a fight, a sign the unlock gate is rarely ready. Fire art slots, the engine's Heat counter and the trigger budget (4.6 clipped) are the build's real bottlenecks.
