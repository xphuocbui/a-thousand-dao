# The Unquarrelling Ledger (Bất Tranh Trướng), geared: a tide-and-undertow sustain build that wins by outlasting the foe's linh lực pool.

Realm: Kết Đan (ket_dan). Fight file: `design/builds/engine-v3/builds/pacifist.fight.json` (the old file plus `items`, four `effects`; arts unchanged).

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Still-Pool Gourd (Tĩnh Trì Hồ Lô) `water-still-pool-gourd` | 2 | Regen +12 %, linh lực +8 %, art speed +5 % [thuy], and Steady Breath. Its own art is not slotted: the five arts are the build. |
| Armour | Hundred-Patch Armour (Bách Nạp Giáp) `general-hundred-patch-armour` | 3 | Health regen +20 %, healing taken +12 %, resist +100 %, a stronger Common Ward (411 pts, drain 0.394). No Water armour exists. |
| Ring 1 | Ring of the Returning Tide (Hồi Triều Giới) `water-returning-tide-ring` | 3 | Healing +14 %, regen +14 %, health regen +20 %, and Backflow: every heal refills linh lực. |
| Ring 2 | Dewdrop Ring (Lộ Châu Giới) `water-dewdrop-ring` | 1 | Regen +8 %, linh lực +4 %, Water buff stacks stronger. Cheap filler. |
| Necklace | Moon-Well Pendant (Tỉnh Nguyệt Bội) `water-moon-well-pendant` | 2 | Healing +8 %, regen +10 %, thần thức +5 %; reserve art Still Surface. |
| Extra 1 | Mirror of the Drowned Moon (Nịch Nguyệt Kính) `water-mirror-of-the-drowned-moon` | 4 unique | TT 18. Regen +25 %, linh lực +15 %, healing +10 %, thần thức +4 %; Sea Already Deep (8 Water stacks from the start). |
| Extra 2 | Brimming Shield (Mãn Thuẫn) `water-brimming-shield` | 3 | TT 15. Regen +14 %, defence +12 %, standing shield ward, Steady Breath. |

Thần thức: 33 of 50.4 (45 × 1.0 × (1 + 12 / 100), the 12 % from armour 3, pendant 5, mirror 4). Two extra slots left empty: nothing cheap enough served the build.

## Before and after

Old column = the v2 file re-run on today's engine (it gives 64.0 s at the main matchup, not the 48.8 s in the v2 guide).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical ket_dan+0 | 64.0 | 66.0 | 20-0-0 | 20-0-0 |
| typical nguyen_anh+1 | 54.9 | 62.8 | 13-7-0 | 3-10-7 |
| typical hoa_than+2 | 4.8 | 7.0 | 0-20-0 | 0-20-0 |
| top_end ket_dan+0 | 2.0 | 2.1 | 0-20-0 | 0-20-0 |
| top_end nguyen_anh+1 | 1.0 | 1.3 | 0-20-0 | 0-20-0 |
| top_end hoa_than+2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

At typical ket_dan+0 the geared build ends at 50 % health, dry at 5.6 s, foe dry at 57.0 s (old: 84 % health, never dry, foe dry at 31.9 s).

`--without` (typical ket_dan+0, geared → without):

| Removed | Mean s | W-L | You dry | Foe dry | Health left |
|---|---|---|---|---|---|
| (geared) | 66.0 | 20-0 | 5.6 | 57.0 | 50 % |
| `item:water-mirror-of-the-drowned-moon` (its plain modifiers only; its Effect is a separate record) | 66.0 | 20-0 | 5.2 | 58.5 | 56 % |
| `eff:Sea Already Deep cost` (the 10 % dearer arts) | 62.9 | 20-0 | never | 31.0 | 94 % |
| `eff:Sea Already Deep` (the 8 stacks) | 66.0 | 20-0 | 6.0 | 58.0 | 52 % |
| `eff:Backflow` | 66.0 | 20-0 | 5.6 | 57.5 | 55 % |
| `item:general-hundred-patch-armour` | 66.0 | 20-0 | 5.0 | 58.1 | 52 % |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour | A Water Giáp with a ward and heal modifiers | Same sustain without the Hundred-Patch's heavier drain | craft, quest | Missing (water has no armour) | High |
| Extra | An Effect or modifier that cuts art cost | Pays back the mirror's 10 % surcharge, which decides the fight | event, craft | Missing | High |
| Weapon | An item art that heals or restores linh lực | Fills an art slot without dealing damage | craft | Missing | Medium |
| Mirror of the Drowned Moon | Sea Already Deep | 8 Water stacks from t = 0 (unused by the five arts, so it fired nothing useful) | npc (Nascent Soul Water cultivator) or a lost lake | In catalogue | Low for this build |
| Ring 2 | Healing or health-regen ring of grade 3 | Replaces the Dewdrop Ring | event | Only the Returning Tide ring exists | Low |

## Missing pieces

- A cost-reducing item (Effect or modifier): the water family should own it.
- A Water armour (Giáp) with a standing ward: water family.
- A Water item art that restores linh lûc or heals without damage: water family.

## UNMODELLED

- Final Clause (armour): the build does not rely on it; the engine could run it, I did not write it.
- Hundred-Patch ward (411 pts, drain 0.394): not better than the build's ward (same price check), so the old ward stays.
- Brimming Shield ward (shield σ 0.30): the build's body shield is already 0.3, so no change.
- Reserve arts Still Surface (10 %) and Reflection (15 %): the engine does not deduct the reserve or run the grants.
- Item modifiers with no engine stat: linh_luc_pct, stack_effect_pct, defense_pct, khi_huyet_pct, healing_taken_pct, health_regen_inc_pct, than_thuc_pct (listed by the loader, not run). Art speed scoped [thuy] applies to every art.
- Steady Breath is written as always-on L5 +12 above 50 % linh lực; its scope (host's arts only) is not expressible, so it applies to every art. Backflow's cap (3 % max linh lực a pulse) is approximated as one trigger per pulse.
- Skipped on purpose: Nine-Fathom Abyss Seal. Its Water Table closes "your linh lực never regenerates in fights", which this build cannot take.

## Observations

Gear did not help; at typical ket_dan+0 it made the fight a little longer (64.0 → 66.0 s, just above the 30-60 s band) and much more fragile (the build runs dry at 5.6 s and the foe at 57 s; old: never dry and 31.9 s). The cause is a single piece: the mirror's closing rule (arts cost 10 % more) written as `cost_red -10`. Without it the geared build is 62.9 s, never dry, 94 % health, but still not faster. With it, `gathering-wave`, `brimming-cup` and `drag-of-the-deep` NEVER_FIRED at ket_dan and the build only fires the stance and a palm; the rest of the gear moves the fight by under a second. Against a foe one realm above (nguyen_anh+1) wins fall from 13 to 3 of 20 and 7 fights run out of time. No item made the build degenerate. Backflow clipped 1.6 times per fight against its one-a-pulse limit, and did almost nothing because the arts that heal hardly fired. Most plain modifiers (regen, linh lực, health regen) have no engine stat, so the gear's real value is under-measured. If the cost closing rule were removed or offset, the build would probably move toward the earlier results.
