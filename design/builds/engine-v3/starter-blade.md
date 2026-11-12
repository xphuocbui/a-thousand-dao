# The Whetted Edge (Mài Phong Kiếm), geared

A Metal sword build: crits feed a Temper that sharpens the next crits, a banked keen strike rides every art, and a flying sword keeps cutting. Realm: Foundation Establishment (Trúc Cơ, truc_co), grade 3 at most.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | `metal-hundred-edge-flying-sword` Hundred-Edge Flying Sword (Bách Nhận Phi Kiếm) | 3 | Its art Hundred-Edge Flight counts as a Hundred-Blades Canon art, one of the build's three techniques, and reads the Temper counter the build already grows; plus sword attack, crit +5, crit damage +20 |
| Armour | `metal-tortoise-scale-armour` Tortoise-Scale Armour (Quy Lân Giáp) | 3 | The only Metal body piece at grade 3; health, regeneration and a Physical cast ward (not run, see UNMODELLED) |
| Ring 1 | `metal-ring-of-returning-edge` Ring of the Returning Edge (Phong Hồi Giới) | 3 | Edge Returns the Breath: each Physical crit restores 0.8 % linh lực. Crit +8, crit damage +40, attack +14 |
| Ring 2 | `blade-whetted-ring` Whetted Edge Ring (Ma Phong Giới) | 1 | Sword crit +4, attack +6, a little linh lực on crit |
| Necklace | `metal-whetstone-jade-pendant` Whetstone Jade Pendant (Thạch Mài Ngọc Bội) | 2 | Linh lực, regeneration and health; reserve art Keen Edge Aura (Metal arts 10 % faster) |
| Extra 1 (TT 20) | `blade-twin-edge-sword` Twin-Edge Flying Sword (Song Nhận Phi Kiếm) | 2 | Sword crit +6, attack +14, crit damage +15, Opening Cut; its art is not slotted (art slots full) |
| Extra 2 (TT 8) | `metal-iron-temper-ring` Iron Temper Ring (Thiết Thối Giới) | 1 | Physical crit +4, health, stronger Metal buff |
| Extra 3 | empty | - | the flag and the needles were left out (see observations) |

Thần thức: 20 + 8 = 28 against a limit of 45 × 1.0 × (1 + 0/100) = 45 (no item here gives than_thuc_pct, and the build has no divine_sense).

Art swap: `flying-sword` out, `metal-hundred-edge-flight` in. The other three arts are unchanged.

## Before and after

Old file: `engine-v2/builds/starter-blade.fight.json`, re-run today. Geared: `engine-v3/builds/starter-blade.fight.json`. 20 fights each.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical truc_co+0 | 17.3 | 7.7 | 20-0-0 | 20-0-0 |
| typical ket_dan+1 | 8.0 | 10.2 | 0-20-0 | 0-20-0 |
| typical nguyen_anh+2 | 4.0 | 4.0 | 0-20-0 | 0-20-0 |
| top_end truc_co+0 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end ket_dan+1 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |
| top_end nguyen_anh+2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

The old file's typical truc_co+0 reads 17.3 s here; the v2 guide recorded 15.0 s, so the library has moved since. Health left at typical truc_co+0: 70 % old, 94 % geared.

`--without` (typical truc_co+0):

| Test | Mean s | W-L-other | Health left |
|---|---|---|---|
| geared, nothing removed | 7.7 | 20-0-0 | 94 % |
| `--without item:metal-hundred-edge-flying-sword` | 9.3 | 20-0-0 | 92 % |
| `--without eff:Edge Returns the Breath` | 7.7 | 20-0-0 | 94 % |

`--without item:` removes only the item's plain modifiers (one Effect `item:<id>`); its art stays in the slot. So the 1.6 s is what the sword's modifiers are worth, not the art. The art Hundred-Edge Flight was not tested separately.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | grade 4 Metal sword | A stronger flying sword; the grade-3 one is the cap here | crafting or a sect | missing at grade 4 (only the Heaven-Minted Coin, a coin) | medium |
| Armour | ward the engine can run | A Metal armour whose ward the build can model | craft, quest | in catalogue (Tortoise-Scale), ward not run | low |
| Ring | Opening Cut / crit-triggered Effects | Another crit payoff | `blade-twin-edge-sword` | in catalogue, Effect not written | medium |
| Extra | `than_thuc_pct` | More extra-slot room (limit is 45, 28 used) | Sword-Nest Flag gives +6 % | in catalogue | low |
| Necklace | `linh_luc_on_crit_pct` | More breath from crits (modifier not in the engine) | Whetted ring, Twin-Edge sword | in catalogue, not run | low |
| Any | Called Blow (crit reliability) | The ring's build_use names it | tree or Effect | not checked | low |

## Missing pieces

- A cheap Metal ring with Temper or crit-stack scaling: the metal family should own it.
- A Metal body piece whose ward reads as a drain ward and not a cast ward: metal.
- A sword item that adds to the Temper counter directly: blade.

## UNMODELLED

- Flowing Water timer cut on crit: Kiếm Ý notable not in the game.
- Basic attack coefficient add: no engine field set for it in the old file.
- Hot Edge recent-crit condition: L5 held at a flat 10 points.
- Crit chance 0.15 still carries the old averaged Whet stacks, and item crit modifiers now add on top.
- Tortoise-Scale Shell ward (Physical 105.3, cast): the engine takes only drain wards; not swapped, the build keeps the typical ward.
- Iron Skin Renewed (armour) and Opening Cut (Twin-Edge sword): not written, the build does not rely on them.
- Keen Edge Aura reserve art: reserve not deducted, grants not run.
- Item modifiers with no engine stat: khi_huyet_pct, defense_pct, health_regen_inc_pct, linh_luc_pct, linh_luc_on_crit_pct, stack_effect_pct, stack_duration_pct.
- Item art speed with a sword or kim scope applies to every art in the engine.

## Observations

Gear mattered at the same realm: the typical truc_co+0 fight fell from 17.3 s to 7.7 s and health left rose from 70 % to 94 %, all wins both ways; against a higher realm the build still loses 0-20 everywhere, only 10.2 s against typical ket_dan+1 against 8.0 s before. So the build is now further below the 30-60 s band (7.7 s, and it was already below at 17.3 s), and no gear tuning was done to fix that. Nothing looks degenerate against the upward matchups, but at same realm the build is close to a flat win: the foe dries at 6.9 s and you never do. Edge Returns the Breath fired but changed nothing, because the build never ran dry. The Hundred-Edge sword's modifiers were worth 1.6 s. Hundred-edge-notch clipped about 28 times a fight at typical truc_co+0, so most Metal stacks it lays are lost to the stack cap. Fired nothing: needle-rain fires 0.3 times at typical truc_co+0 and not at all at nguyen_anh+2 or top end; the third art fired in every same-realm fight. The Twin-Edge sword's art and Sword-Nest Flag stayed out: the flag's Sword Chorus gives 6 % per other sword artifact and makes non-sword arts deal 15 % less.

GEAR-DONE starter-blade
