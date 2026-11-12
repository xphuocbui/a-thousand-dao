# The Red Hearth Ladder (Xích Lô Môn Giai Thê), geared

A plain Fire-sect disciple who keeps a small fire alive for a long time: Burn that never stops, a pool that never empties. Realm: Foundation Establishment (trúc cơ, `truc_co`). Technique: Red Sun Scripture (Xích Nhật Kinh). File: `builds/sect-ladder.fight.json`; the ungeared file is `../engine-v2/builds/sect-ladder.fight.json`.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Red Sun Seal (Hồng Nhật Ấn) `fire-red-sun-seal` | 3 | Its art Red Sun Descends names Red Sun Scripture as its group, so the suite's engines count it as a fourth suite art; it lays 4 Burn and falls twice as hard in Brazier Form or at 6 Heat. Also Fire attack +18 %, Fire art speed +8 %. |
| Armour | Phoenix Plume Armour (Phượng Vũ Giáp) `fire-phoenix-plume-armour` | 3 | Healing and health regeneration, plus the Effect Phoenix Mend: Brazier Form's mend burns the foe. |
| Ring | Cinder Ring (Hỏa Tẫn Giới) `fire-cinder-ring` | 1 | Over-time attack +7 %, stronger Fire buff, a little health. The only Fire ring that does not pay in health. |
| Ring | (empty) | | Blood Kindling Ring spends health, against this build's concept; no other ring fits. |
| Necklace | Hearth-Keeper Pendant (Thủ Lô Bội) `fire-hearth-keeper-pendant` | 2 | Linh lực regeneration +8 %, Fire attack +6 %, and Hearth Aura (Burn lasts 25 % longer, 10 % stronger). |

| Extra slot | Item | Grade | Thần thức (TT) | Why it is here |
|---|---|---|---|---|
| Extra 1 | Furnace-Mouth Gourd (Lô Khẩu Hồ Lô) `fire-furnace-mouth-gourd` | 2 | 25 | Fire attack +16 %, debuff stacks +16 %, linh lực +6 %, and Kindled Wound (the build already has it from its Way, so the Effect is redundant here; only the modifiers count). Its art has no free art slot. |
| Extra 2, 3 | (empty) | | 0 | Nothing else fits the concept within the limit. |

Thần thức: 25 of 45 (45 × divine_sense 1.0 × (1 + 0/100)).

## Before and after

Art slot change: Flint Volley was replaced by Red Sun Descends (the item art).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical truc_co+0 | 24.1 | 20.4 | 20-0-0 | 20-0-0 |
| typical ket_dan+1 | 8.0 | 8.0 | 0-20-0 | 0-20-0 |
| typical nguyen_anh+2 | 4.0 | 4.0 | 0-20-0 | 0-20-0 |
| top_end truc_co+0 | 1.6 | 1.6 | 0-20-0 | 0-20-0 |
| top_end ket_dan+1 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |
| top_end nguyen_anh+2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

(The old column is the v2 file run on today's engine, so it differs from the v2 guide's 20.5 s.) At the build's realm you run dry at 21.7 s old and never geared; health left 56 % old, 65 % geared; the foe runs dry at 17.7 s old, 16.2 s geared.

| Test (typical truc_co+0) | Mean s | W-L-other | Health left |
|---|---|---|---|
| geared | 20.4 | 20-0-0 | 65 % |
| `--without item:fire-red-sun-seal` | 21.5 | 20-0-0 | 60 % |
| `--without eff:Phoenix Mend` | 20.8 | 20-0-0 | 63 % |
| `--without item:fire-phoenix-plume-armour` | 20.4 | 20-0-0 | 65 % (no change: its modifiers and ward are not run) |

The seal still fires Red Sun Descends when removed (the art stays in its slot), so the 1.1 s is only its modifiers.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Ring | Fire attack, Burn stack strength | Burn hits harder | craft, event | In: Cinder Ring (grade 1); no grade 2-3 Fire ring for a non-health build | High |
| Ring | Linh lực sustain | The build dries near the end against equal foes (it did not geared) | craft | Missing: a Fire ring of linh lực regeneration | Medium |
| Weapon | Embers Never Die (Effect) | Burn that a cleanser cannot end | unique, Core Formation and above (ket_dan) | In: Undying Ember Lantern (grade 4, unique; not allowed at this realm) | Later |
| Weapon | Fan the Pyre (Effect) | Burn growing while hits land | unique, ket_dan | In: Ashen Phoenix Fan (grade 4; not allowed at this realm) | Later |
| Armour | A drain ward that beats the build's ward | A real ward rather than a cast shield | craft | Missing: a Fire armour with a standing ward at grade 3 (Smouldering Robe is grade 2, Fire-only) | Medium |
| Extra | Fire stack duration and strength | Longer Burn | event | In: Hearth-Keeper Pendant (reserve); not run by the engine | Low |

## Missing pieces

- A grade 2-3 Fire ring that does not pay in health (modifiers or an Effect for Burn builds): fire.
- A Fire armour with a standing drain ward at grade 3: fire.
- An extra-slot treasure under 20 thần thức that lets Burn last longer: fire.

## UNMODELLED

- Phoenix Shell (cast shield σ 0.135, 4 s cooldown): a cast shield, not a drain ward, not shown to beat the build's ward.
- Hearth Aura reserve art (12 % of linh lực reserved): the engine has no reserve field, and stack duration and stack effect have no engine stat.
- Stack effect +8 to +20 % on the seal, ring, gourd and technique, linh lực % on seal and gourd, health % on seal, ring, pendant and armour, defence %, health regeneration % and thần thức % on armour and pendant: no engine stat (printed "not run").
- Kindled Wound from the gourd: already in the file as `kindled-wound` from the Way.
- The seal's and gourd's Fire art speed: the engine reads it without hit context, so it applies to every art.
- Everything the v2 file already listed (Embers Feed the Hearth's closing cost, pill and array, Way nodes, Deep Heat).

## Observations

Gear changed little. At the build's own realm the fight shortens from 24.1 s to 20.4 s, further below the 30-60 s band, and health left rises from 56 % to 65 %, while the pool no longer runs dry; every higher-realm and top-end matchup is unchanged, so nothing here changes the tiers. The seal matters most (1.1 s), and the Phoenix Mend Effect, the only modelled Effect, is worth 0.4 s and 2 % health. No item made the build degenerate. Phoenix Plume Armour fired nothing in the engine (its ward and modifiers are not run), and the gourd's Effect and art fired nothing (duplicate Effect, no art slot); at ket_dan+1 and above all arts including Red Sun Descends are NEVER_FIRED or die within seconds, and Brazier Form and Red Sun Descends never fire at nguyen_anh+2. One caveat: Flint Volley was removed for the item art, which also lowers Burn laying; I did not test the other choices of which art to replace.

GEAR-DONE sect-ladder
