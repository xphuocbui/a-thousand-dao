# The Hundred-Ailment Ledger (Bách Bệnh Lục), rebuilt on library arts: many different curses on one foe, paid by the count

Guide: `design/builds/overnight-2026-11-10/builds/status-collector.md`. Files: `builds/status-collector.fight.json` (Hóa Thần) and `builds/status-collector.ket-dan.fight.json` (Kết Đan).

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Rime Brand (Ice stacks) | `rime-lock-seal` (Heavy Breath curse from Ice stacks) | winter-toll-canon (1) |
| Cold Iron Brand (Metal armour-break) | `black-ice-glaze` (Exposed, 8 Ice stacks on the next art) | winter-toll-canon (4) |
| Ledger Reckoning (the cash-in) | `shatter-palm` (breaks 10 Ice stacks, free cold hits); a second cash-in is `gathered-ruin-verdict` | winter-toll-canon (6); ruin-ledger-scripture (6) |
| Ember / Cracked Earth Brands (cheap debuff arts) | `fraying-thread` (Sundered, Fray count) | ruin-ledger-scripture (1) |
| Marked Prey / Crowded Ledger (+ per different status) | `ripening-curse` (Stagnation, 3 % more per different status on the foe) | ruin-ledger-scripture (3) |
| Bitter Sap Brand (Wood poison) | `blight-canker` (Poison and Stagnation) | rotting-canopy-canon (2) |
| Thread Lightning Brand | none | none, see Lost |
| Tally Gourd echo, Tally Ten, Rolling Refresh | none | none, see Lost |

Unchanged from the old file: realm, layers, crit, ward, body, art speed and cost, regeneration. The old file had no `purity` and no keystones or curses, so none are written.

## Techniques chosen and why

- **Winter Toll Canon (Đông Toán Kinh), main, Băng:** a main method whose arts are curse and stack layers on the foe: Heavy Breath, Exposed, Ice stacks and a shatter payoff.
- **Ruin Ledger Scripture (Phế Trướng Kinh), auxiliary, Thổ:** the whole suite is the guide's idea, a hit that grows with the number of different statuses, so it is the closest library engine. Its Sundered, Stagnation and Exposed add kinds to the count.
- **Rotting Canopy Canon (Hủ Quan Điển), auxiliary, Mộc:** one art, `blight-canker`, brings Poison and Stagnation, two more kinds for the count.

Hóa Thần has 7 slots: 3 + 3 + 1 arts, all at unlock layer ≤ 6 (limit 12). Kết Đan has 5 slots: `rime-lock-seal`, `black-ice-glaze`, `fraying-thread`, `ripening-curse`, `blight-canker`, all at layer ≤ 4 (limit 9). `shatter-palm` and `gathered-ruin-verdict` (layer 6) unlock at Kết Đan but there are no slots for them.

## Lost in the move

- The six one-element Brands (fire, earth, metal, wood, thunder, ice), cheap and identical, are gone. Fire, earth, thunder and metal debuffs have no library equivalent, so the build now collects Ice, Poison, Sundered, Stagnation, Heavy Breath and Exposed instead.
- The Reckoning's "86 % of the top-end multiplier" count payoff has no direct equivalent. `ripening-curse` pays 3 % per kind with no stated cap, a much smaller reader.
- Tally Gourd, Tally Ten, Rolling Refresh and Crowded Ledger are Effects that belonged to the invented arts' count, so they are not in the file. Twelve kinds are not reachable here.
- The old file put the full 12-status bonus on the Reckoning's `x` from t = 0. That is gone, so this fight is more honest and weaker.
- Not tuned and not edited: art numbers are the library's.

## Fights

Foe: same realm. The matrix lists the typical and top-end foes (the thể tu foe is not in this matrix output).

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| Hóa Thần vs typical | 1.6 | 20-0-0 | never | 1.6 | none |
| Hóa Thần vs top_end | 4.0 | 20-0-0 | never | 3.9 | L1 5.5, trig_budget 3.3 per fight |
| Kết Đan vs typical | 4.0 | 20-0-0 | never | 3.2 | trig_budget 2.7 |

## --without tests (Hóa Thần, same-realm typical, before to after)

- `--without tech:winter-toll-canon`: typical 1.6 s, 20-0, to 1.6 s, 20-0 (NO_CHANGE). On top_end 4.0 s to 4.1 s, 20-0 both.
- `--without ripening-curse` (the identity piece: the count reader): typical 1.6 s, 20-0, to 1.6 s, 20-0 (NO_CHANGE). On top_end 4.0 s to 6.6 s, 20-0 both.

## UNMODELLED (as printed)

- Marked Prey, Tally Ten, Crowded Ledger and the Tally Gourd echo are not in the file: they belonged to the invented arts and have no library form. The count reader is Ripening Curse.
- No `purity` written: the old file had none.
- winter-toll-canon `stack_duration_pct +12` and `stack_effect_pct +6`: no engine stat, so not run.
- winter-toll-canon `art_cost_pct` and `art_speed_pct` scoped `seal`: the engine reads them without hit context and applies them to every art.
- ruin-ledger-scripture `art_speed_pct` and `art_cost_pct` scoped `curse`: the same, applied to every art.
- ruin-ledger-scripture `status_duration_pct +20 [curse]`: no engine stat.
- rotting-canopy-canon `stack_effect_pct +10`, `stack_duration_pct +16`, `status_duration_pct +12 [curse]` and `art_cost_health_pct +8`: no engine stat.
- rotting-canopy-canon `art_speed_pct` scoped `moc`: applied to every art.

## Observations

At Hóa Thần a typical foe dies in 1.6 s with every art NEVER_FIRED, so only the basic attack and layers fought; the build is far from the 30-60 s band (the top-end foe is 4.0 s, also far below). This repeats the old simulator warning that a typical foe dies before any brand lands. At Kết Đan the fight is 4.0 s, still far shorter than 30-60 s. The guide's claim that the count matters against top-end foes holds in one respect: `ripening-curse` is the only art whose removal changes anything (4.0 s to 6.6 s on top_end), and it fires once per fight. The claims about twelve kinds, +48 L5 and a 86 % cash-in cannot be tested here. Removing the main technique changes almost nothing, because it fires about as little. NEVER_FIRED: at Hóa Thần typical all seven arts; at top_end `black-ice-glaze`; at Kết Đan typical `black-ice-glaze` and `blight-canker`. The unmodelled passives (status duration and effect) are exactly the ones a count build would want, so its engine is under-measured. Observations only, no tuning was done.
