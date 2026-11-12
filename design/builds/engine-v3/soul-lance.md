# Soul Lance (Hồn Thương) — carry a Hollow Bell Canon toll-engine and push a needle of thought through the foe's soul, now with a zither, a lamp and a mourning robe

Realm: Nguyên Anh (nguyen_anh). Root: Water (purity 70). Fight file: `design/builds/engine-v3/builds/soul-lance.fight.json`.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Thousand-String Zither (Thiên Huyền Cầm) `soul-song-seal-thousand-string-zither` | 4 unique | Its art Thousand-String Dirge belongs to the hollow-bell-canon suite, the build's own technique. +14 x_soul, +12 % soul art speed. Effect Plucked Time. |
| Armour | Mourning Robe (Tang Y) `soul-song-seal-mourning-robe` | 3 | Ward Mourning Veil (Force 275, drain 0.33), +30 soul resistance, Effect Final Clause. |
| Ring 1 | Echoing Ring (Hồi Âm Giới) `soul-song-seal-echoing-ring` | 3 | +12 x_soul, +12 % soul art speed, Effect Echo (a quarter of hits strike again). |
| Ring 2 | Quiet Mind Ring (Tĩnh Tâm Giới) `soul-song-seal-quiet-mind-ring` | 1 | +3 % thần thức, +3 x_soul, +6 % linh lực regeneration. |
| Necklace | Waking-Soul Jade (Tỉnh Hồn Bội) `soul-song-seal-waking-soul-jade` | 2 | +6 x_soul, +8 % soul art speed, +10 % healing, +20 % health regeneration: the build has no heal art. |
| Extra 1 | Ninth Vigil Heart-Lamp (Cửu Canh Tâm Đăng) `soul-song-seal-ninth-vigil-heart-lamp` | 4 unique | TT 15. +10 x_soul, +30 soul resistance, +6 % thần thức; Effect Lamp-Lit Reading answers high-soul-resistance foes. |
| Extra 2 | Muffled Temple Bell (Ám Chung) `soul-song-seal-muffled-temple-bell` | 2 | TT 25. Ward against slow heavy hitters, +20 soul resistance. |
| Extra 3 | Sandalwood Censer (Đàn Hương Lô) `soul-song-seal-sandalwood-censer` | 2 | TT 10. +8 x_soul, +12 % status duration, +5 % linh lực, +4 % thần thức. |
| Extra 4, 5 | empty | | Nothing else in the catalogue serves a soul build within the limit. |

Thần thức: 15 + 25 + 10 = **50** against a limit of 45 × 1.0 (no `divine_sense` set) × (1 + 28 / 100) = **57.6**. The 28 % is the items' own than_thuc_pct (6 + 4 + 3 + 4 + 6 + 1 + 4; the build carries none of its own). Within the limit.

Art slot change: Thousand-String Dirge replaces mountain-splitting-thought (it never fired in the old file). Items did not change the build's ward: the Mourning Veil and the Muffled Bell Ward are listed as unmodelled, because the build's drain ward (ws 180) was left as it was.

## Before and after

Old = `engine-v2` file, geared = `engine-v3` file, both rerun with the current engine. The old run's numbers differ from the old guide (21.7 / 30.7 / 15.9 / 6.9 s): the engine has moved since that guide was written.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 26.7 | 22.0 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 30.7 | 62.0 | 20-0-0 | 0-20-0 |
| top_end nguyen_anh+0 | 25.4 | 25.7 | 0-20-0 | 0-20-0 |
| top_end hoa_than+1 | 11.5 | 11.8 | 0-20-0 | 0-20-0 |

`--without` (geared file, typical nguyen_anh+0, 20 fights):

| Run | Mean s | W-L-other | Foe dry | Health left |
|---|---|---|---|---|
| geared, full | 22.0 | 20-0-0 | 12.1 | 50 % |
| `--without item:soul-song-seal-thousand-string-zither` (the item that matters most) | 21.0 | 20-0-0 | 14.0 | 50 % |
| `--without eff:Plucked Time` | 22.0 | 20-0-0 | 12.1 | 50 % (NO_CHANGE) |
| `--without eff:Echo` | 22.8 | 20-0-0 | 12.0 | 45 % |

Fires, geared, typical nguyen_anh+0: tolling-bell-requiem 12.9 (old 26.0), lamp-oil-lance 8.0 (old 0), seep-through-palm 21.0, marrow-to-dew 10.0, drag-of-the-deep 12.0, Thousand-String Dirge 0 (NEVER_FIRED). The zither "matters most" only in the sense that it holds the weapon slot and the Dirge; removing it changes the fight by one second.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | art that feeds Toll or soul hits and actually fires | The Dirge is slotted but never fires; a soul-hit weapon that does | event, craft | Missing (see below) | High |
| Armour | ward that beats ws 180 plus Force/soul cover | The build's ward carries the fight; the robe's veil could not be modelled | craft, quest | In the catalogue (Mourning Robe, already worn); a better one missing | Medium |
| Ring | Effect: `than_thuc_pct` or `divine_sense` for lamp-oil-lance | lamp-oil-lance is paid in thần thức | craft | In the catalogue (modifiers on all worn items) | Medium |
| Necklace | Heal source (+ healing_pct) | Replaces the lost Lamp-Light heal | event, npc | In the catalogue (Waking-Soul Jade, worn) | Low |
| Extra | Soul-resistance-lowering Effect that the engine can run | Lamp-Lit Reading is worn but not run | event | In the catalogue; engine side missing | Medium |
| Extra | Final Clause (Mourning Robe) | Last Death Knell as you go Down | craft | In the catalogue; engine side missing | Low |

## Missing pieces

- A soul weapon whose art fires on the build's own Toll rhythm without a chord counter (soul-song-seal family).
- A ward item for soul-heavy foes with a shape the engine can run as a drain ward (soul-song-seal family).
- A thần thức ring that raises the divine sense the build's soul arts are paid in (soul-song-seal family).
- An item that returns linh lực on a soul hit, the lost Lamp-Oil Siphon (soul-song-seal family).
- A cleanse or escape treasure (the lost Bell of Waking and Lantern Out; general family).

## UNMODELLED

- Final Clause (Mourning Robe): the engine has no action to pick the longest-cooldown art.
- Lamp-Lit Reading (Heart-Lamp): lowers the foe's soul resistance; the engine's `soul_res` mod is our own. Its closer (own soul resistance −15) is not run either.
- Plucked Time's closer (non-soul, non-song arts deal 15 % less): no scope-limited damage mod. The delay half is written as `eff:Plucked Time`.
- Marked Prey (Sandalwood Censer): not written; the file does not model the statuses it counts.
- Mourning Veil and Muffled Bell Ward: ward items; no drain-ward change was made.
- Reserve arts of the Heart-Lamp (15 %) and the Censer (10 %): not deducted and their grants not run.
- Item modifiers with no engine stat: than_thuc_pct, linh_luc_pct, status_duration_pct, khi_huyet_pct, defense_pct, healing_taken_pct, health_regen_inc_pct. Soul-scoped art speed applies to every art, as for techniques.
- Everything the old file already listed (v1 soul numbers, soul shields, Soul Wound, fortress and so on).

## Observations

Gear mattered little at nguyen_anh and for the worse at hoa_than+1. Against a typical nguyen_anh foe the fight is 22.0 s (old 26.7 s), below the 30-60 s band both before and after; against a typical hoa_than+1 foe it went from 30.7 s and a win to 62.0 s and a loss in all 20 fights, and both top_end rows are still lost 0-20 (25.7 s and 11.8 s). I do not know why tolling-bell-requiem fires half as often (12.9 against 26.0 per fight) with the items on; I did not investigate. Thousand-String Dirge never fired at nguyen_anh or against top_end foes (9 per fight at hoa_than+1 only), so Plucked Time, which reads song soul hits, changed nothing (NO_CHANGE) and the Dirge's chord condition is probably not being met there; no cause confirmed. lamp-oil-lance, which never fired before, now fires 8 times a fight, but the engine reads no thần thức stat from the items, so that is not shown to come from them. Removing the zither moves the fight by one second; Echo is the only item Effect with a visible effect (22.0 to 22.8 s without it). No item made the build degenerate. Nothing was tuned.

GEAR-DONE soul-lance
