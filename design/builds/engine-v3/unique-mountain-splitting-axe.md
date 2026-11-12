# The Mountain Root Bulwark (Sơn Căn Kim Thân)

Stand in the Mountain Root stance, take the hits, and let the Mountain-Splitting Axe (Phích Sơn Phủ) turn the Debt and the body shield into one blow while its leech keeps the body full. Realm: Core Formation (Kết Đan, ket_dan), grade 4 at most. Root: Earth (Thổ), purity 80.

## How it works

- The engine is the axe's own art, Splitting the Mountain (Phích Sơn): every hit you take (once a pulse) winds 1 Debt, and the axe deals 5 % more for every 5 % of health held as body shield.
- With 5 Debt and either Mountain Root held or a body shield of 30 % of your health, the axe lands 4.5 times as hard and spends the Debt. It is a slow art (3.4 coefficient, 8 s cooldown), so the rest of the build exists to have the stance and the shield up when it comes round.
- Mountain Root Stance gives the stance (20 % less damage taken, +15 block, arts 20 % slower); Bulwark Knuckle and Bastion Reprisal raise the body shield, and Bastion Reprisal bursts when it breaks.
- The unique item is the axe itself: it gives the art that is the build's finisher, Physical attack +25 %, leech health +40 % and the Effect Blood Drinker (heal 6 % of each hit you land).
- Sustain is a pile of health leech, regeneration and shield on the other pieces, so the body stays full while the Debt grows.

## Loadout

| Slot | Item | Grade | Why |
|---|---|---|---|
| Weapon | `body-mountain-splitting-axe` Mountain-Splitting Axe (Phích Sơn Phủ) | 4 | The unique: the finisher art, attack +25 % Physical, leech +40 %, Blood Drinker |
| Armour | `body-mountain-hide-armour` Mountain-Hide Armour (Sơn Bì Giáp) | 2 | Body shield +10 %, health regeneration +12 %; Physical cast ward (not run) |
| Ring 1 | `body-iron-skin-ring` Ring of Renewed Iron Skin (Thiết Bì Phục Giới) | 3 | Body shield +24 %, block +20, healing +6 % |
| Ring 2 | `body-tempered-marrow-ring` Ring of Tempered Marrow (Luyện Tủy Giới) | 1 | Health regeneration +20 %, block +4 |
| Necklace | `body-stone-marrow-pendant` Stone-Marrow Pendant (Thạch Tủy Bội) | 2 | Leech +40, healing +10 %, regeneration +30 %; reserve art Stone-Marrow Aura (not run) |
| Extra 1 (TT 15) | `body-mountain-gate-shield` Mountain-Gate Shield (Sơn Môn Thuẫn) | 2 | Block +20, body shield +10 %; cast shield (not run) |
| Extra 2 (TT 8) | `earth-clay-seal-ring` Clay Seal Ring | 1 | Earth stack effect +12 % (not run), health |
| Extra 3, 4 | empty | - | nothing else in the catalogue fitted the stance engine |

Thần thức (divine sense): 15 + 8 = 23 against a limit of 45 × (1 + 0 / 100) = 45 (nothing here gives than_thuc_pct).

**Techniques:** Mountain Heart Canon (Sơn Tâm Kinh, main, Earth), Mountain Bone Body Art (Sơn Cốt Thể Thuật, body, always usable), Unbroken Flesh Canon (Bất Hoại Nhục Kinh, body, always usable).

**Arts (5 slots at Core Formation):** `body-splitting-the-mountain` (the axe's art), `mountain-root-stance` (Mountain Bone Body Art L2), `bulwark-knuckle` (Unbroken Flesh Canon L3), `bastion-reprisal` (Mountain Heart Canon L4), `sinking-weight` (Mountain Heart Canon L2).

## Fights

20 fights each, `--matrix`.

| Matchup | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| typical ket_dan+0 | 16.2 | 20-0-0 | never | 11.7 |
| typical nguyen_anh+1 | 18.0 | 0-20-0 | 9.4 | never |
| typical hoa_than+2 | 5.0 | 0-20-0 | 4.0 | never |
| top_end ket_dan+0 | 2.0 | 0-20-0 | 2.0 | never |
| top_end nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never |
| top_end hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never |

Health left at typical ket_dan+0: 100 %.

`--without` (typical ket_dan+0, then typical nguyen_anh+1):

| Test | Mean s (ket_dan+0) | W-L-other | Mean s (nguyen_anh+1) | W-L-other | Foe dry (ket_dan+0) |
|---|---|---|---|---|---|
| nothing removed | 16.2 | 20-0-0 | 18.0 | 0-20-0 | 11.7 |
| `--without item:body-mountain-splitting-axe` | 16.5 | 20-0-0 | 18.0 | 0-20-0 | 12.4 |
| `--without eff:Blood Drinker` | 16.2 | 20-0-0 | 18.0 | 0-20-0 | 11.7 |
| `--without tech:mountain-heart-canon` | 16.2 | 20-0-0 | 17.9 | 0-20-0 | 11.7 |

`--without item:` removes only the item's plain modifiers (one Effect `item:<id>`); its art stays slotted. So the 0.3 s is what the axe's attack bonus and leech are worth, not the art. The art was not tested separately.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour | `body-vajra-hide-armour` Vajra Shell + Shield Pays the Blood | Bigger Physical ward; shield pays health costs | unique, Marrow Tithe builds | in catalogue, but it is a second unique and the build already holds one | low |
| Ring | Iron Skin Renewed written as an Effect | Ring currently only gives its modifiers | `body-iron-skin-ring` | in catalogue, Effect not written | medium |
| Extra | `than_thuc_pct` | Room for more extra pieces (23 of 45 used) | any item giving it | missing in the body family | low |
| Any | Body shield modifiers the engine reads | `body_shield_pct` sums to +44 % across the pieces and +18 % on techniques, none of it runs | engine | missing engine stat | high |
| Any | A way to write Debt faster | The axe winds Debt only from hits taken | Marrow Tithe Strike, not slotted (slots full) | in library | medium |
| Weapon | Second grade-4 axe or a heavier Phủ | nothing above the axe in its base | craft, quest | missing | low |

## Missing pieces

- Engine stats for `body_shield_pct`, `khi_huyet_pct`, `health_regen_inc_pct`, `defense_pct`, `pierce_pct`: the combat engine should own them; most of this build's gear is ignored without them.
- A body shield that the fight can hold at 30 % at the start of a fight, so the axe's gate is open without the stance: the body family should own a piece for it.
- A cast ward or shield the engine can run (Mountain-Hide Shell, Mountain-Gate Ward): the combat engine.
- A Debt source that does not need hits: the body family (Marrow Tithe Strike is the only one, and it costs a slot).

## UNMODELLED

- Iron Skin Renewed (`body-iron-skin-ring`): not written, the build does not rely on it.
- Mountain-Hide Shell cast ward and Mountain-Gate Ward cast shield: the engine takes only drain wards, so the build keeps the typical ward.
- Stone-Marrow Aura reserve art (body shields +10 %, block +10): the reserve is not deducted and its grants are not run.
- Blood Drinker is written as 6 % of each hit you land, healed (the catalogue gives only the name).
- Passives with no engine stat: body_shield_pct (techniques and items), khi_huyet_pct, health_regen_inc_pct, defense_pct, pierce_pct, stack_effect_pct and stack_duration_pct [tho].

## Observations

The unique does not make the build as the engine runs it: removing the axe's modifiers costs 0.3 s at typical ket_dan+0 (16.5 s against 16.2 s) and nothing at nguyen_anh+1, and removing Blood Drinker changes nothing, because the build ends the same-realm fight at 100 % health and never runs dry; the heal has nothing to mend. Removing the Mountain Heart Canon passives is likewise worth 0 to 0.1 s (they are mostly stats the engine does not read). The fight is a flat win at the same realm (the foe dries at 11.7 s, health is untouched) and a flat loss against anyone above, so the build is a wall against its own realm and no more; mean 16.2 s sits under the 30-60 s band and no tuning was done to fix that. Against nguyen_anh+1 the build is dry at 9.4 s and loses by 18 s, against typical hoa_than+2 it lasts 5 s. The axe's art fired 1.9 times per fight at typical ket_dan+0 and 1.0 at nguyen_anh+1, and never at typical hoa_than+2 or top end (the fights end first), so its 4.5-times blow is seen about once. The Debt counter mountain-hit-debt was clipped 10 times a fight at typical ket_dan+0 (the once-a-pulse limit), so Debt is plentiful and the axe's cooldown, not the Debt, is what holds it back. Never fired: every art at hoa_than+2 and top end except a stray Mountain Root, and the trigger budget clipped bulwark-ram and root-return, so the shield bursts are rationed. Nothing looks degenerate except the 100 % health left; but most of the gear's shield and regeneration is not run, so that figure is not the build's real defence.

UNIQUE-DONE unique-mountain-splitting-axe
