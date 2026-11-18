# curse-engine: The Straw Effigy (Thảo Nhân Chú), geared

Every small blow writes another curse on the foe; when the board is full, the big seal comes down. Realm: Nascent Soul (Nguyên Anh, `nguyen_anh`).

Files: `builds/curse-engine.fight.json` (geared copy of `engine-v2/builds/curse-engine.fight.json`: `"items"` added, `ambush-talisman` swapped for the Ledger Stamp; no number tuned).

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Thousand-Cut Returning Sword (Thiên Trảm Hồi Kiếm) `blade-thousand-cut-sword` | 4 unique | Kim debuff stack effect and duration, sword art speed; carries Marked Prey. Its own art is not slotted (the build has no Metal debuff stacks to spend). |
| Armour | Hollow Robe (Không Y) `force-chaos-hollow-robe` | 2 | Light, Force ward and status resistance; a Force 264-point drain ward does not beat the build's ward, so `ward` is unchanged. |
| Ring | Hollow Ring (Không Giới) `force-chaos-hollow-ring` | 1 | Debuff stack effect +10 %, status duration +5 %: made for curse stackers. |
| Ring | Ring of the Open Vein (Khai Mạch Giới) `force-chaos-open-vein-ring` | 3 | Leech, healing and regen to carry the fight; Blood Drinker is already in the build. |
| Necklace | Ledger-Murmur Pendant (Phế Thanh Bội) `force-chaos-ledger-murmur-pendant` | 2 | Debuff stack effect +12 %; reserve art Murmuring Debts lengthens every status you land. |
| Extra | Ledger Seal (Lục Ấn) `soul-song-seal-ledger-seal` | 3 | TT 30. Its Ledger Stamp counts as a Nine Seal Ledger art; slotted in place of `ambush-talisman`. |
| Extra | Ledger Branding Iron (Phế Trướng Lạc Thiết) `force-chaos-ledger-branding-iron` | 2 | TT 15. Curse attack +14 %, curse status duration +15 %; carries Marked Prey. |

Extra thần thức: 30 + 15 = **45 of 45** (limit 45 × divine_sense 1.0 × (1 + 0 %); the items' own than_thuc_pct was not counted). Three of five extra slots are empty.

## Before and after

Both runs use `--matrix`, 20 fights per row. (Engine moved since the v2 guide, so "old" is a fresh run of the v2 file, not the v2 guide's printed numbers.)

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical nguyen_anh+0 | 2.5 | 4.4 | 20-0-0 | 20-0-0 |
| typical hoa_than+1 | 4.7 | 8.8 | 20-0-0 | 20-0-0 |
| top_end nguyen_anh+0 | 6.2 | 12.6 | 20-0-0 | 0-20-0 |
| top_end hoa_than+1 | 6.5 | 7.9 | 0-20-0 | 0-20-0 |

Health left, geared (after the budget revision): 100 / 100 / 0 / 0 %. Geared top_end same realm shows "dry you 9.0" (you run out of linh lực at the end of the fight); the old file never ran dry.

`--without` (top_end nguyen_anh+0, geared 8.7 s, 20-0-0, dry you 8.8):

| Removed | Mean s | W-L-other | Dry you | Health left |
|---|---|---|---|---|
| `item:blade-thousand-cut-sword` (the one that matters most) | 8.8 | 20-0-0 | never | 100 % |
| `item:soul-song-seal-ledger-seal` | 8.6 | 20-0-0 | never | 100 % |
| `item:force-chaos-ledger-branding-iron` | 8.9 | 20-0-0 | 9.0 | 99 % |

No `--without eff:` test: no item Effect was written (see UNMODELLED).

## Budget revision (2026-11-13)

**What changed in `layers`:** `[330, 0, 150, 80, 0]` became `[310, 0, 0, 80, 0]`. The claimed share of the typical-to-top-end gap fell from 38 % to 22 % (Nascent Soul [Nguyên Anh] budget: 23 %).

**Why:** the 150 points of L3 (gear) were the items' own modifiers, which already run as Effects (`item:<id>`) and through `techniques`, so they were counted twice. L3 was cut to 0. L1 (Đạo Đồ) was trimmed 330 to 310 to get under the line. L4 keeps the 80 from the Nine Rods formation, the layer the concept (stacking curses) needs most; L2 and L5 were already 0 (Weight of Names and Marked Prey run as Effects on L5).

**How the fights moved** (old -> new, mean seconds and wins out of 20):

| Matchup | Old | New |
|---|---|---|
| typical nguyen_anh+0 | 2.3 s, 20 wins | 4.4 s, 20 wins |
| typical hoa_than+1 | 6.1 s, 20 wins | 8.8 s, 20 wins |
| top_end nguyen_anh+0 | 9.9 s, 14 wins (5 losses, 1 draw) | 12.6 s, 0 wins (20 losses) |
| top_end hoa_than+1 | 7.9 s, 0 wins | 7.9 s, 0 wins |

The build still beats a typical same-realm enemy, though faster than the 10-20 s a budgeted build is meant to take. It no longer beats the top-end enemy of its own realm.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | `stack_effect`/`stack_duration` scoped to curse (not only kim debuff) | The sword's stack boosts reach Sundered, Exposed and Heavy Breath | A Thousand-Cut-style sword for curses | Missing (the catalogue's is kim-debuff scoped) | High |
| Any | status duration the engine can run | Curse-lengthening gear (Murmur Pendant, Branding Iron, Hollow Ring) fires nothing today | Engine, not the catalogue | Present in catalogue; engine has no `status_duration` stat | High |
| Necklace or extra | Linh lực sustain with no art-speed cost | Offsets the dry-out the sword's art speed causes | Wood or Water family pendant | Reserve pendants exist (e.g. `wood-sap-heart-pendant`, `water-moon-well-pendant`); not tried | Medium |
| Ring | Effect that moves timers on curse application | A second Driven Nail (it clips 31 times a fight) | Metal or soul-song-seal ring | Missing | Low |
| Armour | A ward that beats ws 120 drain | A stronger ward | Any family armour | Not seen; the Hollow Veil does not | Low |

## Missing pieces

- A curse-scoped weapon: kim debuff stack boosts scoped to curses and statuses, not Metal debuff stacks (Metal family).
- Weight of Names as an item: curse stack count readable by the engine and an item that scales on it (force-chaos family).
- A cleanse-answer or Sealed-Meridian piece: an item that lays Sealed Meridian on the foe's L2 (soul-song-seal family).
- A Nascent Soul ward ring or armour that costs no art speed (general family).

## UNMODELLED

- Marked Prey (thousand-cut sword, branding iron): already in `effects` as the Scripture's copy; a second copy was not written, so the items add only their plain modifiers.
- Blood Drinker (open-vein ring): same, already in `effects`.
- Hollow Veil ward (Force 264, drain 0.317): below the build's ward, not modelled.
- Murmuring Debts reserve art: reserves 10 % of linh lực, not deducted; grants not run.
- Item modifiers with no engine stat: `status_duration_pct` (ledger seal, branding iron, hollow ring), `stack_effect_pct`, `stack_duration_pct` (sword, rings, pendant), `than_thuc_pct`, `khi_huyet_pct`, `defense_pct`, `status_resist_pct`, `health_regen_inc_pct`, `linh_luc_pct`: printed by fight.py as no engine stat, not run.
- Item `art_speed_pct` scoped to sword, seal and curse (sword, ledger seal, branding iron): the engine applies it to every art.
- The sword's own art `blade-thousand-cut-return` is not slotted (art slot given to the Ledger Stamp).
- All the v2 UNMODELLED lines (Sealed Meridian's layer, Litany refresh, Weight of Names, Fourth Nail, Backlash, Insect-Waking Incense, linh lực on hit, Paid in Nails) still stand.

## Observations

Gear did not help. The same-realm typical and next-realm matchups moved by 0.0 and 0.2 s, and top_end same-realm slowed from 6.2 to 8.7 s with the run going dry at 8.8 s where the old one never did; the next-realm top_end loss stayed 0-20 (6.5 to 7.8 s). Fights stay far under 30-60 s, so nothing here lengthens them. The slowdown traces to the sword: without it the geared build runs 8.8 s and never goes dry, while removing the Ledger Seal or the Branding Iron changes 0.1–0.2 s, so the sword's sword-scoped art speed (applied to every art) is probably what drains linh lực. Most of the loadout fires nothing: all the status duration, stack effect and stack duration modifiers have no engine stat, the Murmuring Debts reserve is not run, and the Marked Prey and Blood Drinker copies were not written. Nothing became degenerate. The Ledger Stamp fired (5.0 times in top_end same realm), and all six arts fire in every row except `branding-seal` in typical same realm in the old run.