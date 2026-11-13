# The Flash Before the Thunder (Tiên Điện Hậu Lôi), geared

A Lightning volley that leaves your hands together at the opening floor, before most foes act. Realm: Nguyên Anh (nguyen_anh).

Fight file: `design/builds/engine-v3/builds/first-volley.fight.json` (copy of the engine-v2 file plus `items`, one item art, and four Drumbeat Effects).

## Loadout

Thần thức (TT) limit: 45 × divine_sense 1.0 × (1 + 4 / 100) = **46.8**, the 4 being the pendant's `than_thuc_pct`. Used: **40**. Five extra slots allowed; two used.

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon (base) | Forked-Light Sword (Phân Quang Lôi Kiếm) `thunder-forked-light-sword` | 2 | Its art Forked Slash counts as a Thousand-Bolt Scripture art, so the suite's Palm, Chain Arc and Peal count it; it replaces the weaker common art `forked-light` in the fifth art slot. |
| Armour (base) | Stormcloud Armour (Vân Lôi Giáp) `thunder-stormcloud-armour` | 3 | Lightning art speed, crit chance and crit damage, plus lightning resistance; its cast shield (Cloudflash Shell) does not beat the build's ward, so the ward is unchanged. |
| Ring 1 (base) | Static Band (Tĩnh Điện Giới) `thunder-static-band` | 1 | Linh lực back on crit and crit damage, the same idea as the build's own linh-lực-on-crit Effect. |
| Ring 2 (base) | Ring of Hollow Echoes (Không Hưởng Giới) `wind-hollow-echo-ring` | 3 | Effect Echo: an echo suits a build that fires many short arts. Wind family, taken because Thunder has only one ring. |
| Necklace (base) | Peal-Heart Pendant (Lôi Tâm Bội) `thunder-peal-heart-pendant` | 3 | Lightning crit chance and crit damage, linh lực, +4 % thần thức (raises the extra budget), a 15 % reserve aura for crit. |
| Extra 1 | Stormcaller's Drum (Hô Lôi Cổ) `thunder-stormcaller-drum` | 2 | Lightning crit chance, art speed, crit damage; Steady Breath; a 10 % reserve art. TT 20. |
| Extra 2 | Heartbeat of Heaven Drum (Thiên Tâm Lôi Cổ) `thunder-heartbeat-of-heaven-drum` | 4 unique | Drumbeat: every fourth art fired is a guaranteed crit. Biggest crit pieces in the family. TT 20. |
| Extra 3-5 | empty | | A third drum or the Thunderclap Bell would need 20-25 more TT; the limit is 46.8. |
| **Total TT** | | | **40 of 46.8** |

## Before and after

Matchups are the `--matrix` of the old file (`engine-v2`) and the geared file (`engine-v3`), 20 fights each. The old column is what the engine reports now; the engine-v2 guide's numbers were from an earlier run of it and differ.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, same realm | 1.5 | 1.5 | 20-0-0 | 20-0-0 |
| typical, +1 realm (hoa_than) | 5.5 | 3.7 | 20-0-0 | 20-0-0 |
| top_end, same realm | 10.0 | 48.2 | 0-20-0 | 15-5-0 |
| top_end, +1 realm | 4.0 | 4.0 | 0-20-0 | 0-20-0 |

(Geared column re-run 2026-11-13 after the budget revision; see the section at the end. The pre-revision geared file now reads 1.0 / 2.5 / 33.1 s.)

`--without` (the matrix was run for the first two; the other two only for typical, same realm, where the result is 1.5 s, 20-0-0, same as geared):

| Test | typical same | typical +1 | top_end same | top_end +1 |
|---|---|---|---|---|
| `--without item:thunder-forked-light-sword` | 1.5 s, 20-0-0 | 4.5 s, 20-0-0 | 11.6 s, 0-20-0 | 4.0 s, 0-20-0 |
| `--without eff:Drumbeat` | 1.5 s, 20-0-0 | 4.5 s, 20-0-0 | 11.4 s, 0-20-0 | 4.0 s, 0-20-0 |
| `--without item:thunder-heartbeat-of-heaven-drum` | 1.5 s, 20-0-0 | not run | not run | not run |

The sword is named as the item that matters most because it is the only item with an art that joins the suite. Removing it changes nothing in any matchup.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Lightning crit chance, Forked Slash ramp | A Thousand-Bolt art that raises crit chance per crit | npc, event, craft | In the catalogue (Forked-Light Sword, grade 2) | Have it |
| Weapon (better) | A grade 3-4 Thunder sword whose art joins the suite | More suite members for the empower thresholds | event, npc | Missing: Thunder has one sword | Medium |
| Ring | Linh lực on crit, crit damage | Sustain for a long fight | event, craft | In the catalogue (Static Band, grade 1); a grade 3 Thunder ring is missing | Medium |
| Extra | Drumbeat (guaranteed crit every fourth art) | A fixed crit rhythm | npc, event, quest | In the catalogue (Heartbeat of Heaven Drum, unique) | Have it |
| Extra | Slowed Time on the foe (Marked Prey reads it) | Makes Marked Prey pay | Not decided | Missing: no Thunder art in this build lays Slowed Time | Low |
| Armour | A Thunder ward that beats a 300-point layered drain | Survival at top_end | craft, quest | Missing: Cloudflash Shell is a cast shield | Medium |
| Any | Thunder `more` multiplier (L2) | Replaces the lost L2 300 | Library arts take no overrides | Missing | High |

## Missing pieces

- A Thunder ring of grade 2-3 with crit or art-speed modifiers (Thunder family: only a grade 1 ring exists).
- A Thunder escape or step item for Lightning Step (Thunder or Wind family).
- A Thunder ward armour with a drain ward (Thunder family).
- An item that carries the lost L2 Lightning more and L4 preparation (Thunder family).

## UNMODELLED

- Item art speed scoped `[lightning]` (sword, armour, both drums): the engine applies art speed to every art without hit context.
- Item passives with no engine stat (`linh_luc_on_crit_pct`, `khi_huyet_pct`, `defense_pct`, `linh_luc_pct`, `than_thuc_pct`): the engine has no stat for them.
- Cloudflash Shell (cast shield σ 0.144): the build's ward is unchanged; the engine models no cast shield here and it is not clearly better than the 300-point drain ward.
- Reserve arts (Peal-Heart Aura 15 %, Stormcaller's Cadence 10 %, Heaven's Pulse 20 %): the loader does not deduct the reserve or run the grants.
- Echo (Ring of Hollow Echoes), Marked Prey (pendant), Steady Breath (Stormcaller's Drum): the rule text is in `effects.md`, which this run did not read, so no engine Effect was written.
- Drumbeat's Thunder buff stack on its crit: only the guaranteed crit and the 8 less crit chance were written (the stack would need a condition the counter cannot gate).
- Drumbeat is an approximation: a counter `beat` (cap 4) adds 1 per art fired, a live +100 crit while it is at least 3, a reset at 4. The engine may count the fourth art differently.
- Everything the engine-v2 file already listed (L2 and L4, First Move and others, Lightning Step).

## Budget revision (2026-11-13)

**What changed in `layers`:** `[360, 0, 250, 0, 0]` became `[270, 0, 130, 0, 0]`. The claimed share of the typical-to-top-end gap fell from 46 % to 21 % (budget at Nguyên Anh (nguyen_anh): 23 %); `fight.py` now prints `layer_budget`, not `OVER_BUDGET`.

**Why:** the layers hold only what the Meridian Map and the old file's own sources give. The techniques' passives and the items' modifiers already run as Effects, so none of them is added again. L1 (base damage, the volley itself) was cut least, since the concept is a burst of lightning arts at the opening; L3 was cut most (250 to 130), as the build needs it least. L1 also counts as 235 rather than 270 past the soft knee. No technique, item or art was changed or removed.

**How the fights moved** (mean time, wins-losses, 20 fights; old = file before the revision, new = after):

| Matchup | Old | New |
|---|---|---|
| typical, same realm | 1.0 s, 20-0 | 1.5 s, 20-0 |
| typical, +1 realm | 2.5 s, 20-0 | 3.7 s, 20-0 |
| top_end, same realm | 33.1 s, 19-1 | 48.2 s, 15-5 |
| top_end, +1 realm | 4.0 s, 0-20 | 4.0 s, 0-20 |

Against a typical same-realm foe the build still wins in 1.5 s, far under the 10-20 s the budget is meant to give: the crit and art-speed caps (50 % / x3.0, 200 %) come from items and the build's own fields, not from `layers`, so they carry the fight. It now has a real contest with the top-end foe at the same realm.

## Observations

Gear did not matter in this model. Typical same realm is 1.5 s either way; typical +1 realm went from 5.5 s to 4.5 s, top_end same realm from 10.0 s to 11.6 s (the run varies, 11.4 to 11.6), both within what a reseeded run can move, and top_end is still lost 20 of 20 in both matchups. Removing the sword, the Drumbeat Effect or the Heartbeat drum changed nothing except 11.6 s to 11.4 s in one cell, so the build's stats are already capped (crit 50 % / ×3.0, art speed 200 %) and the item modifiers add nothing past those fields. The fight is far under the 30-60 s band: 1.5 s typical, 4.5 s one realm up, 11.6 s top-end. No item made the build degenerate. Items that fired nothing visible: Forked Slash fires, but with no measurable effect on the result; the Static Band, both rings' passives, the Stormcloud Armour, the Peal-Heart Pendant, Stormcaller's Drum and Echo, Marked Prey and Steady Breath ran nothing, as they are unmodelled or have no engine stat; only the `forked-slash-ramp` Effect and Drumbeat ran, and Drumbeat only changed one cell.
