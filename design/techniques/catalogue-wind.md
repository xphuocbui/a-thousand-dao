# Wind (Phong) technique catalogue

Family: wind. Two techniques, one per suite, carrying all 8 signature arts of `design/arts/family-wind.json`
(no ungrouped arts, so no carriers). Wind is evade, basic-attack tempo and borrowed time: the Courier scripture is the
fast, many-light-hits half, the Slow Hour scripture the curse, health and companion half. Passives are plain numbers that
feed each suite's engine; the bonuses are non-combat lines from `bonus_pool`. Note: both suites have 4 arts, above
cong-phap rule 17's "1-3" (the lint notes it; open GDD point).

## Gale Courier Scripture (Phong Sứ Kinh)

Main method (main), Profound (Huyền) tier 1, 9 layers. Names: `phong`.

| Layer | Art unlocked |
|---|---|
| 1 | Swallow Stance (Yến Hành Thế) |
| 2 | Hundred-Feather Flurry (Bách Vũ Loạn Phong) |
| 4 | Three-Step Chase (Tam Bộ Truy Phong) |
| 6 | Held Breath (Bế Tức Phong) |

Passives (14.6 W of 16):

| Key | Value | Scope |
|---|---|---|
| `evade_pct` | +5 | - |
| `basic_speed_pct` | +10 | - |
| `stack_effect_pct` | +8 | phong |
| `art_speed_pct` | +6 | quick |

Bonuses: `linh_luc_pct` +10.

Use: evades and basic attacks fill Feathers and Breath, so stack evade and basic speed; Swallow Stance is the key that
opens Flurry step 2 and the Held Breath and Echo empowers. Chase's charges fire three courier arts in one pulse for the
step 3 gates; Wind stack effect makes the stacks Flurry burns hit harder. Pair with other evade and Wind stack sources.

## Slow Hour Scripture (Trì Thời Kinh)

Secret art (secret), Earth (Địa) tier 2, 12 layers. Names: `phong`.

| Layer | Art unlocked |
|---|---|
| 1 | Trailing Gale (Lưu Phong Chướng) |
| 2 | Gale Sprite (Phong Linh Đồng) |
| 4 | Echo of the Dodge (Hồi Phong Ảnh) |
| 6 | Reckless Gale (Mệnh Phong Bộ) |

Passives (23.1 W of 24):

| Key | Value | Scope |
|---|---|---|
| `evade_pct` | +4 | - |
| `status_duration_pct` | +10 | curse |
| `art_speed_pct` | +10 | - |
| `leech_health_pct` | +10 | - |
| `healing_pct` | +12 | - |

Bonuses: `khi_huyet_pct` +8, `tam_ma_resist_pct` +8.

Use: Trailing Gale's Slowed Time is the key for Echo's empower and its own step 3, so curse duration keeps it up;
evade feeds Echo and the delay trigger. Reckless Gale spends health: leech, healing and art speed carry the debt, and
the maximum health bonus gives it room. Stack art speed and health sustain around it, and a Wind stack source for the Sprite.

checked 2 techniques, 0 findings
