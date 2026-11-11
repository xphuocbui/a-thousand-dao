# Fire (Hỏa) technique catalogue

Family: fire. Three techniques in `catalogue-fire.json` carry all 8 signature arts of `family-fire.json`: one per suite
(Red Sun Scripture, Ashen Phoenix Canon) and one carrier for the lone ungrouped art (Scorch Fist). Burn is the family's
currency, so the passives are plain numbers that feed it: stack effect and duration, Fire damage, art speed and cost,
and (for the phoenix) over-time damage, healing and leech. No new rules; passives are priced in W by the lint.

## Red Sun Scripture (Xích Nhật Kinh)

Main method (tâm pháp), Profound (Huyền, tier 1), 9 layers, names `hoa`. Suite `red-sun-scripture`.

| Layer | Art unlocked |
|---|---|
| 1 | Brazier Form (Lô Hỏa Thế) |
| 2 | Flint Volley (Đả Thạch Liên Hỏa) |
| 4 | Furnace Heart (Lô Tâm Tích Nhiệt) |
| 6 | Twin Flame Echo (Song Diễm Hưởng) |

Passives (15.8 W of 16): art speed +10 % [fire]; Fire damage more +3 % [fire]; stack effect +8 %; art cost -8 % [fire];
stack duration +4 %.
Bonuses: max linh lực +12 %.

Build use: the tempo engine. Art speed and cheaper Fire arts shorten the 3 s window in which two or three Red Sun arts must
fire, which opens the Vent, Flashfire and Bloom steps; stack effect and duration make the Burn that Furnace Heart cashes
heavier and longer lived. Stack Fire art speed and quick Fire arts around it, and offset Brazier Form's 15 % slowdown.

## Ashen Phoenix Canon (Hôi Phượng Điển)

Secret art (bí thuật), Earth (Địa, tier 2), 12 layers, names `hoa`. Suite `ashen-phoenix-canon`.

| Layer | Art unlocked |
|---|---|
| 1 | Blood-Fed Pyre (Huyết Dưỡng Hỏa) |
| 3 | Heat Haze (Nhiệt Phù Chướng) |
| 6 | Ash Rebirth (Tro Tàn Tái Sinh) |

Passives (23.2 W of 24): Fire over-time damage more +4 % [over_time, hoa]; damage +8 % [over_time, hoa]; healing +10 %;
health leech +10 %; stack effect +10 %; status duration +10 % [curse].
Bonuses: max health (khí huyết) +10 %, tâm ma resistance +8 %.

Build use: the grinding sustain engine. Burn ticks gather Ash and feed Slowed Time, so over-time damage and curse duration
keep the foe ticking while leech and healing refill what Blood-Fed Pyre pays in health. Stack Burn lay-down and low-health
safety (health, healing) around it; pair with a Red Sun main only if the harmony works out, since both name `hoa`.

## Scorch Fist Primer (Chước Quyền Sơ Giải)

Secret art (bí thuật), Yellow (Hoàng, tier 0), 6 layers, names `hoa`. No suite (carrier).

| Layer | Art unlocked |
|---|---|
| 1 | Scorch Fist (Chước Hỏa Quyền) |

Passives (7.6 W of 8): stack effect +8 %; Fire damage +3 % [fire]; Fire resistance penetration +24 points [fire].
Bonuses: none (Yellow has bonus_count 0).

Build use: an early Burn opener. Scorch Fist's conversion becomes fully Fire once the foe has 8+ Burn, so Fire
penetration and stack effect reward getting there fast. Stack Burn-laying arts and physical-damage modifiers
around it until the full conversion kicks in.

checked 3 techniques, 0 findings
