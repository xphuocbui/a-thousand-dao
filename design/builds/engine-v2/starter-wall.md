# The Patient Wall (Nại Bích): an Earth-root cultivator, very hard to kill, who wins slowly on ward, body and regeneration.

## Pieces

Kept as they were: Foundation (Trúc Cơ) defining realm, Earth (Thổ) root purity 50, layers 90/10/0/0/0, no crit, ward (drain, layers 50/47/20), body (block 30, resistance 25, shield 0.3, layers 50/47/20), linh lực regeneration +2.5, health regeneration +1.5, healing +20 %, no keystones, no curses.

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Packed Earth Stance (Hậu Thổ Trụ Thế) | `mountain-stance` | mountain-heart-canon (1) |
| Tremor Palm (Chấn Thổ Chưởng) | `sinking-weight` | mountain-heart-canon (2) |
| (none; new engine arts of the suite) | `bastion-reprisal` | mountain-heart-canon (4) |
| (none) | `strata-hammer` | mountain-heart-canon (6) |
| Mending Breath (Hồi Khí Tức), guarded heal | none (lost) | none |
| Long Tượng Công body passives (+15 % health, +10 % damage) | body passives of two body techniques | unbroken-flesh-canon, mountain-bone-body-art (no art slotted) |
| (Kết Đan only, fifth slot) | `bulwark-knuckle` | unbroken-flesh-canon (3) |

## Techniques chosen and why

- **Main: `mountain-heart-canon`** (Profound main, tho). It is the whole Earth wall suite: a stance that answers hits and adds Strata, a seal that stacks Earth, a body-shield burst and a Strata hammer. At Foundation its four arts exactly fill the four slots (layers 1, 2, 4, 6 are all allowed). Hits taken and body shields broken feed the engine, which is what a wall already produces.
- **Auxiliary: `unbroken-flesh-canon`** (body, always usable). Body shield, health regeneration and max health passives. It is kept for passives at Foundation, then lends `bulwark-knuckle` (layer 3) at Kết Đan: a body shield that breaks into `bastion-reprisal` bursts.
- **Auxiliary: `mountain-bone-body-art`** (body). Block, body shield and Physical resistance passives. No art slotted: `mountain-root-stance` and `bone-turning-palm` would crowd the suite.

## Lost in the move

- **Mending Breath's guarded heal (health at or below 60 %).** No Earth library art heals. The closest is the common `second-wind` (heal at 70 % or less), which would require replacing the main technique with a generated common technique. Not taken. The build now has no heal art; healing comes only from the +1.5 regeneration, healing +20 % and body shield.
- **Tremor Palm as a plain Earth debuffer** became `sinking-weight`, a heavier seal with a Slowed Time payoff.
- **Long Tượng Công** was not a catalogue technique; the two body techniques only give shield, regeneration and health passives, none of which the engine runs (see UNMODELLED).
- Fire-and-forget Stone Does Not Hurry remains unbuilt, as before.

## Results (fight.py v2, 20 fights per row)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical Trúc Cơ (same realm) | 31.7 | 20-0-0 | never | 22.1 | mountain-take 2.4, trig_budget 0.3 |
| typical Kết Đan +1 | 14.0 | 0-20-0 | 8.0 | never | mountain-take 1.3 |
| typical Nguyên Anh +2 | 4.0 | 0-20-0 | 3.6 | never | mountain-take 0.6 |
| top_end Trúc Cơ | 2.0 | 0-20-0 | 1.6 | never | none |
| top_end Kết Đan +1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end Nguyên Anh +2 | 1.0 | 0-20-0 | 1.0 | never | none |
| typical Kết Đan, same realm (`starter-wall.ket-dan`, five arts, no matrix) | 19.5 | 20-0-0 | never | 15.2 | bulwark-ram 4.2, mountain-take 1.5 |

Health left was 100 % in both won rows.

## `--without` tests (typical, Trúc Cơ, same realm)

| Removed | Before | After |
|---|---|---|
| `tech:mountain-heart-canon` | 31.7 s, 20-0, foe dry 22.1 | 31.8 s, 20-0, foe dry 22.6 (no change: all its passives have no engine stat and did not run; the arts stay) |
| `mountain-stance` (identity piece) | 31.7 s, 20-0, foe dry 22.1 | 43.1 s, 20-0, foe dry 28.3 (the fight is 11 s longer; sinking-weight fires 7.0, strata-hammer 6.0 per fight) |

## UNMODELLED

- Iron Skin Renewed: an Effect of the Way, not written in the file (Effects from Đạo stay as in the guide).
- Hộ Sơn Trận and Kim Cương Phù: home ground and prepared defence, no fight-input field.
- Stone Does Not Hurry: needs a new key, still not in the file.
- Block, body resistance and ward are modelled by their nearest numbers: drain ward.
- mountain-heart-canon body_shield_pct +8, stack_effect_pct +10 [tho], stack_duration_pct +15 [tho]: no engine stat.
- unbroken-flesh-canon body_shield_pct +6, health_regen_inc_pct +10, khi_huyet_pct +3: no engine stat.
- mountain-bone-body-art body_shield_pct +4: no engine stat (block_rating, resist_pct and attack_pct passives were not reported as unmodelled).

## Observations

At the same realm the wall wins 20 of 20 in 31.7 s at Trúc Cơ, at the very edge of the 30-60 s band (the old file's guide said about 65 s), and 19.5 s at Kết Đan (the guide said about 66 s), under the band. It ends at 100 % health at both, against about 70 % and 54 % in the guide, so "wins slowly, finishes hurt" no longer holds; "very hard to kill" holds more strongly. The guide's claim that your own linh lực runs dry around 28 s at Kết Đan no longer holds: you are never dry, the foe is (22.1 s and 15.2 s). One realm up the wall loses every fight (14.0 s), as the guide said for a cultivator one realm above. Top-end fights end in 1-2 s. NEVER_FIRED: at Nguyên Anh +2 sinking-weight, bastion-reprisal and strata-hammer; at every top_end row all four arts. At the same realm no art is NEVER_FIRED. Removing `mountain-stance` makes the fight longer (43.1 s) rather than shorter, so the stance, which slows your own arts, costs speed here, though the engine's Strata and Earth-stack payoffs it feeds are not what ends the fight. The main technique's passives do nothing in the engine (none are modelled).

LIB-DONE design/builds/engine-v2/starter-wall.md
