# The Nine-Gate Warden (Cửu Quan Thủ Hộ Giả): a Hóa Thần (Hoa_than) Earth/Metal wall that shuts doors on the foe, now in named Earth and body gear.

Realm: Hóa Thần (`hoa_than`). Fight file: `builds/deity-warden.fight.json`. Everything but `items`, one swapped art and two item Effects is unchanged from `design/builds/engine-v2/builds/deity-warden.fight.json`; no number was tuned.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Mountain-Mooring Anchor (Hệ Sơn Mao) `earth-mountain-mooring-anchor` | 3 | Its art Mooring Drop belongs to the Mountain Heart Canon suite and feeds Strata; replaces Mountain Root Stance (the stance that slows the build's own arts). |
| Armour | Boulder-Ring Mail (Cự Thạch Hoàn Giáp) `earth-boulder-ring-mail` | 3 | Physical resistance, health regeneration, Iron Skin Renewed, a Physical-covering Boulder Shell. |
| Ring 1 | Ring of Renewed Iron Skin (Thiết Bì Phục Giới) `body-iron-skin-ring` | 3 | Body shield +24 %, block, healing; a second source of Iron Skin Renewed. |
| Ring 2 | Clay Seal Ring (Nê Ấn Giới) `earth-clay-seal-ring` | 1 | Stronger Earth buff stacks, +100 Physical resistance, health. |
| Necklace | Pendant of the Remembering Stone (Thạch Ký Bội) `earth-remembering-stone-pendant` | 2 | Earth buff stacks +20 %, defence, linh lực regeneration; reserve art Still Stone Aura. |
| Extra 1 | Unmoving Gate Shield (Bất Động Môn Thuẫn) `earth-unmoving-gate-shield` | 4 (unique) | Body shield +40 %, Shattering Ward (every shield break bursts), Unmoved Stance (stances lose their slowness). TT 15. |
| Extra 2 | Mountain-Gate Shield (Sơn Môn Thuẫn) `body-mountain-gate-shield` | 2 | Block, defence, body shield +10 %, a cast shield ward. TT 15. |

Thần thức: 15 + 15 = **30** against a limit of 45 × 1.0 × (1 + 4/100) = **46.8** (the Anchor and the Mail each give +2 % thần thức; the build has no `divine_sense` field). Five of six extra slots stay empty; the next extra would have to cost 16.8 or less.

## Before and after

Foes: typical and top-end Hóa Thần, 20 fights each. The old column is a fresh run of the engine-v2 file today (the engine-v2 guide quoted 1.9 s against the typical foe; today's engine gives 3.6 s for the same file).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical hoa_than | 3.6 | 3.6 | 20-0-0 | 20-0-0 |
| top_end hoa_than | 4.7 | 5.5 | 20-0-0 | 20-0-0 |

`--without` tests on the geared file (typical, then top-end):

| Test | Typical | Top-end |
|---|---|---|
| `--without item:earth-mountain-mooring-anchor` (the item that matters most: it brings the one new art) | 3.6 s, 20-0, NO_CHANGE | 5.5 s, 20-0, NO_CHANGE |
| `--without eff:Iron Skin Renewed` | 3.6 s, 20-0, NO_CHANGE | 5.5 s, 20-0, NO_CHANGE (its clip, 1.0 per fight, remains) |
| `--without eff:Shattering Ward` | 3.6 s, 20-0, NO_CHANGE | 5.5 s, 20-0, NO_CHANGE |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Earth `attack_pct`, Earth debuff stack effect and duration | Stronger Strata and Sinking Weight stacks | Mountain-Mooring Anchor (event, craft, npc) | Catalogue (taken) | High |
| Armour | Iron Skin Renewed, Physical resistance | Shield refills on every Physical art | Boulder-Ring Mail (event, craft, quest, npc) | Catalogue (taken) | High |
| Ring | Iron Skin Renewed + body shield | Same Effect, a second host | Ring of Renewed Iron Skin | Catalogue (taken) | Medium |
| Extra | Shattering Ward, Unmoved Stance | Shield breaks burst; stances without slowness | Unmoving Gate Shield (a Core Formation gate elder, or a flooded quarry) | Catalogue (taken) | High |
| Extra | Body shield + shield-break rule, `than_thuc_pct` | Room in the thần thức budget | A thần thức ring or necklace for the earth family | Missing | Medium |
| Any | `stack_effect_pct` / `stack_duration_pct` [tho] on the Warden's own buff | Mountain Heart Canon and Iron Hide passives did not run either | Meridian Map or a technique | Missing as engine stats | Low |
| Any | Metal debuff stacks (Closing Palm role) | The Metal half of the root has no art | Metal family, a Metal weapon or ring | Missing | Medium |

## Missing pieces

- A cleanse-on-a-clock treasure (the old Lustral Bell): the metal or body family should own it.
- A soul-art item for a Warden with no soul arts (the Deaf Verdict): soul-song-seal has only Water-rooted ones.
- A Metal Earth-stack engine piece (Closing Palm and its 3 Metal debuff stacks): the metal family.
- A ward item that pays Physical and drains (the Iron Gate's per-hit ward): the body family.
- An Earth thần thức piece so more than 30 TT of extras can be carried: the earth family.

## UNMODELLED

- Unmoved Stance (Bất Động Thế): the engine does not model stances or their speed penalties.
- Boulder Shell, Gate Screen, Mountain-Gate Ward: cast, reserved and shield wards; none beats the build's drain ward (payload 342.5), so none replaces it.
- Still Stone Aura (the pendant's reserve art): reserve and its grants are not run.
- Item passives with no engine stat (not run): `khi_huyet_pct`, `defense_pct`, `body_shield_pct`, `health_regen_inc_pct`, `than_thuc_pct`, `stack_effect_pct` and `stack_duration_pct` on Earth stacks, plus the scoped art speed (it applies to every art).
- The engine-v2 lines stand: the phase script and 12 s clock, ward change at each phase, Deaf Verdict and the soul ward, the Iron Gate's per-hit payload, the purge bell, and the Open Hand phase.

## Observations

Gear did not matter in this engine: all three `--without` tests are NO_CHANGE at both foes, and the only movement is that the geared build is slower against the top-end foe (5.5 s against 4.7 s, still 20-0 with full health left), a cost of the Anchor's art joining the arts that fire plus L1 and L2 now clipped at 2.0 per fight. Both fights are far inside the 30-60 s band's lower edge (3.6 s and 5.5 s), as before; the build does not reach a fight long enough for the wall to matter. No item made the build degenerate, because none changed the result. Against the typical foe only Mountain Stance and Bone-Turning Palm fire (0.9 each), so Mooring Drop and the other five arts never fire; against the top-end foe Mooring Drop fires 1.0 per fight, Bastion Reprisal and Strata Hammer still never fire. Iron Skin Renewed shows a clip (1.0 per fight) in the top-end fight, which means it triggers there; Shattering Ward reports nothing, so no shield broke in these fights (a reading, not a checked cause), and removing either changes nothing. The ward items could not be modelled because the build's drain ward is stronger, and most of the Earth items' modifiers (stack strength, body shield, health) have no engine stat, so the gear is mostly unmeasured here.
