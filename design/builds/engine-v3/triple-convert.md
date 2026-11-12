# The Three Smeltings (Tam Luyện): a Physical blow converted to Fire, then to Chaos, so Physical, Fire and Chaos bonuses all feed every hit

Realm: Nascent Soul (Nguyên Anh, `nguyen_anh`). Fight file `design/builds/engine-v3/builds/triple-convert.fight.json` (old: `design/builds/engine-v2/builds/triple-convert.fight.json`). Techniques unchanged: Nine-Temper Scripture, Rotting Canopy Canon, Scorch Fist Primer.

## Loadout

Grade cap at this realm is 4; no unique (grade 4) item is used except the lantern (allowed at Core Formation and above). The build has no `divine_sense` (1.0) and no thần thức bonus of its own, so the extra-slot limit is 45 × 1.0 = 45 (the lantern's own +10 % thần thức and the armour's +4 % would raise it slightly; not needed).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Furnace-Mouth Gourd (Lô Khẩu Hồ Lô) `fire-furnace-mouth-gourd` | 2 | Fire +16 %, Burn stacks 16 % stronger; its art Gourd Swallows the Flame eats the Burn that Scorch Fist lays (replaces Thornling Grove); carries Kindled Wound, the Effect the build already wrote |
| Armour | Phoenix Plume Armour (Phượng Vũ Giáp) `fire-phoenix-plume-armour` | 3 | Fire family armour with healing, health regeneration, Fire resistance 120 and a cast shield |
| Ring 1 | Ring of Blood Kindling (Huyết Dẫn Giới) `fire-blood-kindling-ring` | 3 | Fire +10 %, 20 % health leech, Fire art speed +10 % |
| Ring 2 | Ring of the Open Vein (Khai Mạch Giới) `force-chaos-open-vein-ring` | 3 | Chaos +12 % (the build's end of the chain), 25 % health leech; Blood Drinker is what the old Kiln-Hook Sword was meant to give |
| Necklace | Whetstone Jade Pendant (Thạch Mài Ngọc Bội) `metal-whetstone-jade-pendant` | 2 | Linh lực +6 %, regeneration, healing; reserve art Keen Edge Aura for Metal stacks and speed |
| Extra 1 (15 thần thức) | Undying Ember Lantern (Bất Diệt Tàn Đăng) `fire-undying-ember-lantern` | 4 unique | Burn damage over time +20 %, Burn stacks 30 % stronger, thần thức +10 %; Burn that cannot be cleansed |
| Extra 2-5 | empty | | no further piece served the concept without clashing with it (see Missing pieces) |

Extras total: 15 thần thức against a limit of 45.

## Before and after

Twenty fights each, `--matrix`, rerun today (the engine has moved since the v2 guide: the old file now gives 15.3 s at its own realm, not 8.2 s, so the v2 table is not used).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, nguyen_anh+0 | 15.3 | 13.5 | 20-0-0 | 20-0-0 |
| typical, hoa_than+1 | 8.7 | 9.2 | 0-20-0 | 0-20-0 |
| top_end, nguyen_anh+0 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end, hoa_than+1 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

Health left at typical, nguyen_anh+0: 85 % old, 100 % geared. Foe runs dry at 12.1 s old, 11.1 s geared. The canker-spread and canker-wither clips fell from about 24 and 25 per fight to 1.6 and 3.8.

`--without` (typical, nguyen_anh+0, geared baseline 13.5 s, 20-0-0, 100 % health left):

| Test | Mean s | W-L-other |
|---|---|---|
| `--without item:fire-blood-kindling-ring` (the item that matters most) | 14.8 | 20-0-0 |
| `--without item:fire-furnace-mouth-gourd` | 13.9 | 20-0-0 |
| `--without item:force-chaos-open-vein-ring` | 13.5 | 20-0-0 |
| `--without item:fire-phoenix-plume-armour` | 13.5 | 20-0-0 |
| `--without item:fire-undying-ember-lantern` | 13.5 | 20-0-0 |
| `--without eff:Kindled Wound` | 13.5 | 20-0-0 |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Fan the Pyre (Ashen Phoenix Fan) | Burn timers refresh on every Fire hit (costs 15 % less direct Fire damage) | Fire sect elder at Core Formation or above, or a burned-out secret realm | In the catalogue (`fire-ashen-phoenix-fan`, 25 thần thức as an extra); engine cannot run it | Medium |
| Ring | Blood Casting / Blood Drinker | Health feeding the build's arts and leech | Demonic-path forge; event or NPC | In the catalogue (not modelled here) | Medium |
| Necklace or extra | Chaos penetration, Fire-to-Chaos conversion | The second conversion the build is named for | none | Missing | High |
| Armour | A drain ward or a block piece | Survival against hoa_than+1 | any | In the catalogue as shells (cast shields, not run) | Medium |
| Extra | Marked Prey (Ledger Branding Iron) | More Marked Prey | Event, craft or NPC | In the catalogue (`force-chaos-ledger-branding-iron`); the build already has Marked Prey, so a second copy was not added | Low |

## Missing pieces

- A Physical-to-Fire conversion piece (ring or weapon), owned by the fire family.
- A Fire-to-Chaos conversion piece (+30 to +50 % convert), owned by the force-chaos family.
- Chaos penetration on a necklace or extra piece, owned by the force-chaos family.
- A Sundered-curse piece (strips Chaos resistance), owned by the force-chaos family.
- A Metal or Wood armour with a drain ward, owned by the metal or wood family.

## UNMODELLED

- Two conversions per hit and the damage history: the engine has no conversion inside a hit beyond an art's own `convert`.
- Kindled Wound's Fire-part scope and Festering Wound: mod keys have no part scope.
- Fire-to-Chaos conversion, Chaos penetration and the Sundered curse: no field in the engine.
- Blood Casting and Blood Drinker (the two rings): not written as Effects in this run; only the rings' plain modifiers loaded.
- Embers Never Die and the Long Burn Light reserve: the typical foe cleanses nothing, so nothing to test.
- Phoenix Mend: the build has no healing art, so it would fire nothing; Phoenix Shell is a cast shield, left out, the build keeps the typical ward.
- Keen Edge Aura (pendant reserve art): grants and the 15 % reserve not run.
- Item modifiers with no engine stat (khi huyết, health regeneration, defence, thần thức, linh lực %, Burn stack strength) and the fire art speed scope: the first group is not run, the scoped art speed applies to every art.

## Observations

Gear moved the typical same-realm fight from 15.3 s to 13.5 s and left the build at full health instead of 85 %, so it mattered a little, mostly through the Ring of Blood Kindling (removing it costs 1.3 s) and the gourd's art (0.4 s); against hoa_than+1 the fight is 0.5 s longer and against top-end foes nothing changed, and all of those are still lost. The typical fight is about a quarter of the 30-60 s band, inside neither end, with or without gear. No item made the build degenerate: no fight hit the clip or ran away. Items that fired nothing visible: the Ring of the Open Vein, the Phoenix Plume Armour and the Undying Ember Lantern (removing any one changes the result by 0.0 s), and `eff:Kindled Wound` also changes nothing, which suggests the typical foe has Burn on it rarely or the +15 L5 is too small to move the mean. Gourd Swallows the Flame fires 3.6 times a fight, and at top_end nothing but Whetstone Pass fires, so the build still dies before its arts come off cooldown. The conversion the build is named for remains untested.

GEAR-DONE triple-convert
