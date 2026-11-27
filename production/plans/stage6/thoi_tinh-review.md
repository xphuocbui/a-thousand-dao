# Thối Tinh Môn: Stage 6 review (2026-11-27)

## Summary

- **Built (staged under `design/stage6-staging/thoi_tinh/`):**
  - **2 techniques** (`techniques/catalogue-sect-thoi_tinh.json`): `star-quench-canon` (Profound main, Metal, 14.7 W of 16) and `fallen-star-forging-rite` (Earth secret, Metal + Fire, 23.0 W of 24).
  - **4 active arts** (`arts/part-sect-thoi_tinh.json`): `quench-strike`, `ninth-blow`, `white-heat`, `the-makers-fold`. IDs written back to `design/world/depth/sects/thoi_tinh.techniques.json`.
  - **5 items and 1 set** (`items/catalogue-sect-thoi_tinh.json`, `items/sets-thoi_tinh.json`): `tht-three-years-tax`, `tht-river-tongs`, `tht-coal-black-apron`, `tht-star-brand`, `tht-quench-robe`, and set `tht-fallen-star-forge`.
  - **4 Effects** (`effects/thoi_tinh.effects.json`): `Brittle from Its Own Blow` (passive art, d30), `Sky Iron Sings` (item), `Drawn from the River` (item), and `Heat the Edge` (set, d43).
- **Deviations:** 5 design/engine adaptations logged below (art ID `quench-strike` to avoid collision with `part-a.json`'s `quench`; `Ninth Blow` as +120% `dmg_more` on the 9th direct hit rather than a `free_hit` to avoid `trig_budget` clipping; `White Heat` using a 4 s timed counter instead of a stance and a `0.35 c` Fire `free_hit`; `Drawn from the River` using `ward_pct +60` for 5 s; `Heat the Edge` using unscoped `pierce` and following `d43` without the 3 s step fade).
- **Auto-accepted decisions:** 7 decisions logged in §A with rationale against the studio design rules.
- **Pending words:** none (`pending.json` not needed; all mechanics map cleanly to existing engine words).
- **Never ran in typical `sect_fight.py`:** `Sky Iron Sings` (`runs 0` in `--gap 0/1` because typical foes lack Thunder arts and fights end in 10.2–14.6 s before `Heat the Edge` reaches 5 Fire casts at ~20 s); `Drawn from the River` (`runs 0` in `--gap 0` because Bàng Lãnh Tôi wins at 85% HP, runs `5` in `--gap 1`). Both verified in targeted probes.
- **Early promotions:** none (0 stand-ins, 0 cross-owner dependencies).
- **Open items for the serial step:** merge staged files into `design/`, merge `effects/thoi_tinh.effects.json` into `assets/data/combat_effects.json`, and run compile/GDScript parity + world export.

---

## A. Auto-accepted decisions

1. **Art ID `quench-strike` instead of `quench`:** `design/arts/part-a.json` already uses `"id": "quench"` (`Quench (Tôi Thiết)`). Assigned `"quench-strike"` to `Quench (Thối)` to prevent a duplicate-ID lint failure.
2. **Quench mark = Metal debuff stack (`el: "metal"`, `kind: "debuff"`):** Confirmed by `auth-mod.json` `b3` (`Quench Mark (Thối Ấn)` scoping `stack_effect_pct` and `stack_duration_pct` to `["kim", "debuff"]`) and `tht-river-tongs`. Gives Metal builds clean synergy across `star-quench-canon`, `nine-temper-scripture`, and `tht-river-tongs`.
3. **Method bonuses and new passives sized to tier:** `star-quench-canon` had only 2 authored passives (`6.2 W` of `16 W`) and no bonus; added Tier-1 `attack_pct 10` bonus and `attack_pct 8 [kim]`, `block_rating 8` passives (`14.7 W` of `16`). `fallen-star-forging-rite` had no bonuses or passives; added Tier-2 `attack_pct 12`, `khi_huyet_pct 12` bonuses and `attack_pct 10 [kim]`, `attack_pct 10 [hoa]`, `stack_effect_pct 14 [hoa, debuff]`, `art_cost_pct -8 [kim]`, `khi_huyet_pct 5` (`23.0 W` of `24`).
4. **White Heat uses a timed charge counter (`white_heat`, `each_for: 4, cap: 1`) instead of a stance:** Cát Lưu Quang (and Cát Đoán Nhạc / Nghê Bách Đoán / Phàn Lô Kiên) also run `iron-hide-manual` (`iron-hide-stance`, a stance). Keeping `white-heat` as a timed counter lets both run together without clobbering the single stance slot.
5. **Ninth Blow uses +120% `dmg_more` on the 9th direct hit instead of a `free_hit`:** `engine.py` caps trigger `free_hit` damage per pulse at `0.5 * direct_dmg` (`trig_budget`). Boosting the 9th direct hit (`art` or `basic`) itself by `dmg_more: 1.2` avoids `trig_budget` clipping and faithfully matches "the ninth deals heavy Metal damage and resets the count".
6. **Heat the Edge follows `d43` (no 3 s fade) and unscoped `pierce`:** `auth-eff-2.json` `d43` explicitly superseded the 3 s step fade in `thoi_tinh.items.json` so a single-Fire-art holder (`white-heat`, 4 s cooldown) can build past 5 steps with no cap; `pierce` is unscoped in `always` because `engine.py` line 1327 calls `self.mod(att, "pierce")` without hit context (`Heat` only builds on Fire arts and clears on the first sword crit at 5+ steps).
7. **Signature items unique + rule 21 `exception`:** Marked all 5 items `unique: true`, `sources: ["npc"]`, with `rarity: 4` on treasure `tht-river-tongs`, and added the R6 `exception` to `tht-three-years-tax`, `tht-coal-black-apron`, and `tht-quench-robe`.

---

## B. Techniques (`catalogue-sect-thoi_tinh.json`)

| Technique | Tier, kind | Bonuses | Passives | Arts / Effects (unlock layer) |
|---|---|---|---|---|
| `star-quench-canon` | Profound (`1`), main, Metal | **attack 10 % (new)** | stack effect 12 % [kim, debuff], stack duration 16 % [kim, debuff], **attack 8 % [kim] (new)**, **block rating 8 (new)** (`14.7 W` of `16`) | `quench-strike` (1), `ninth-blow` (2); passive art Effect `Brittle from Its Own Blow` (4, d30) |
| `fallen-star-forging-rite` | Earth (`2`), secret, Metal + Fire | **attack 12 % (new)**, **khí huyết 12 % (new)** | **attack 10 % [kim] (new)**, **attack 10 % [hoa] (new)**, **stack effect 14 % [hoa, debuff] (new)**, **art cost -8 % [kim] (new)**, **khí huyết 5 % (new)** (`23.0 W` of `24`) | `white-heat` (1), `the-makers-fold` (4) |

---

## C. Arts (`part-sect-thoi_tinh.json`)

| Art | Depth concept | Engine form | Deviation |
|---|---|---|---|
| `quench-strike` | Cutting strike applying a Quench mark; 3 marks -> extra Metal damage from next hit and lower defence for a few seconds | Metal Physical `c_art 1.5`, `cost 0.03`, `cd 3.0`, `debuff [1, 8]` (Quench mark), tags `[metal, sword, quench]`. On `hit_landed` when `foe.debuff.metal >= 3`: applies `sundered` (1 stack, `-150` res, 4 s) and arms `quench_brittle` (+35% Metal `dmg_more` on the next Metal art hit). | ID `quench-strike` (vs existing `quench`). |
| `ninth-blow` | Counts holder's hits; the ninth deals heavy Metal damage and resets the count | Metal Physical `c_art 1.8`, `cost 0.04`, `cd 4.0`, tags `[metal, sword, heavy]`. Every direct hit (`not_tags: ["trigger"]`) adds 1 `fold_hits`; at 8 prior hits the 9th direct hit deals `+120%` `dmg_more` and resets `fold_hits` to 0. | Direct-hit `dmg_more` instead of `free_hit` so `trig_budget` never clips it. |
| `white-heat` | For a few seconds Metal arts also deal Fire damage and each hit applies a burn; burning foe gains Quench marks twice as fast | Fire `elem` utility `c_art 0.0`, `cost 0.03`, `cd 4.0`, tags `[fire, forge]`. Sets `white_heat` (`each_for: 4, cap: 1`): Metal art hits fire a `0.35 c` Fire `free_hit`, direct hits lay 1 Burn (6 s), and while `foe.debuff.fire >= 1`, `stack_grant +1` on `[metal, debuff]`. | Timed charge counter instead of stance (preserves `iron-hide-stance`); Fire damage via `0.35 c` `free_hit`. |
| `the-makers-fold` | Spends health to empower flying sword: next strikes cannot be parried and leave a lasting mark | Metal Physical `c_art 1.5`, `cost 0.04`, `cd 6.0`, `hp_cost 0.05`, tags `[metal, sword, heavy]`. Sets `maker_fold = 3`: while held, `ignore_block: 1`, and your next 3 `sword`-tagged art hits (including this strike) lay 1 Metal debuff stack for 15 s and spend 1 charge. | Scoped to `sword` art hits (matches "flying sword"). |

---

## D. Effects (`effects/thoi_tinh.effects.json`)

| Effect (host) | Depth / wish rule | Engine form | Deviation / approx |
|---|---|---|---|
| `Brittle from Its Own Blow` (`star-quench-canon` L4, d30) | Each foe hit you block gives 1 Quench mark (once/s); when your hit lays a Quench mark on a burning foe, spend all Burn and add 1 Quench mark per 3 spent | `on: blocked` (`cooldown 1.0`) flags `quench_from_block`, lays 1 Metal debuff (8 s), clears flag. `on: status_applied` (`element: metal`, `quench_from_block == 0`, `foe.debuff.fire >= 1`) computes `floor(fire/3)` into `burn_to_quench`, consumes all `fire`, then lays `burn_to_quench` Metal debuff stacks (8 s). | Uses `quench_from_block` guard so a block-applied mark does not prematurely spend Burn, and `burn_to_quench` so Burn is consumed before laying bonus marks (no recursion). |
| `Sky Iron Sings` (`tht-three-years-tax`) | Thunder art hitting you or your blade makes it ring: next 3 Metal hits deal extra Thunder damage | `on: was_hit` (`dtype: lightning`) sets `sky_iron_rings = 3`. `on: hit_landed` (`element: metal`, `sky_iron_rings >= 1`) fires `0.45 c` Lightning `free_hit` and decrements `sky_iron_rings`. | Extra Thunder damage modelled as `0.45 c` Lightning `free_hit`. |
| `Drawn from the River` (`tht-river-tongs`) | Once a fight, below 1/3 HP: lose all Burns and gain a ward equal to block rating x 10 for a few seconds | `on: was_hit` / `tick_taken` (`own.hp_share <= 0.333`, `river_used == 0`): sets `river_used = 1`, `cleanse {n: 99, el: "fire"}`, `mod {ward_pct: 60, for: 5.0}`. | `ward_pct +60` for 5 s (~300 ward pts on typical Trúc Cơ holder, matching ~30 block x 10). |
| `Heat the Edge` (`tht-fallen-star-forge` 3-piece, d43) | Each Fire art adds 1 Heat step (+4% pierce each); at 5+, next sword art quenches as a certain crit, wakes Sky Iron Sings, and clears Heat | `on: art_fired` (`element: fire`) adds 1 `heat`. `always` scales `pierce: 4` by `heat`; at `heat >= 5` grants `sure_crit: 1` (`tags: ["sword"]`). `on: crit` (`tags: ["sword"]`, `heat >= 5`) clears `heat = 0` and sets `sky_iron_rings = 3`. | Follows `d43` (no 3 s fade); `pierce` unscoped in `always` since `engine.py` reads `pierce` without hit context. |

---

## E. Items and sets (`catalogue-sect-thoi_tinh.json`, `sets-thoi_tinh.json`)

- **5 items** (`tht-three-years-tax`, `tht-river-tongs` with `rarity: 4`, `tht-coal-black-apron`, `tht-star-brand`, `tht-quench-robe`), all `sources: ["npc"]`, `unique: true`, modifiers matching `thoi_tinh.items.json`, weapons/armour carrying the R6 `exception`.
- **1 set** (`tht-fallen-star-forge`, 3 pieces): 2-piece `pierce_pct 5`, `attack_pct 8 [sword]`; 3-piece `Heat the Edge (Tôi Phong)`.

---

## F. Stand-ins and beasts

- **0 stand-ins:** all 10 living cast members already run `star-quench-canon` or `nine-temper-scripture`.
- **0 beasts:** `thoi_tinh` has no named beasts.

---

## G. Holder check (`sect_fight.py thoi_tinh --seeds 5` and `--gap 1`)

Linters (`DEPTH_STAGE=design/stage6-staging/thoi_tinh`):
- `lint_arts.py`: 4 arts, **0 findings**.
- `lint_techniques.py`: 2 techniques, **0 findings**.
- `lint_items.py`: 5 items, **0 findings**.

Holder runs (`--gap 0` / `--gap 1`, 5 seeds each):

| Holder | Realm | Arts | `--gap 0` (mean_s / wins / HP) | `--gap 1` (mean_s / wins / HP) | Effect runs (`--gap 0` / `--gap 1`) |
|---|---|---|---|---|---|
| `cat_luu_quang` | Kết Đan | `quench-strike, ninth-blow, white-heat, the-makers-fold, iron-hide-stance` | 10.2 s / 5 / 90% | 14.6 s / 0 / 0% | `Brittle` 108/133 (10.2s vs 10.9s), `Heat the Edge` 10/9, `Sky Iron Sings` 0/0* |
| `cat_doan_nhac` | Trúc Cơ | `quench-strike, ninth-blow, iron-hide-stance` | 12.0 s / 5 / 94% | 13.8 s / 0 / 0% | `Brittle` 60/69 (12.0s 94% vs 16.0s 91%) |
| `bang_lanh_toi` | Trúc Cơ | `quench-strike, ninth-blow` | 12.0 s / 5 / 85% | 8.0 s / 0 / 0% | `Brittle` 60/40 (12.0s 85% vs 16.0s 81%), `Drawn from the River` 0/5* |
| `phan_lo_kien` | Trúc Cơ | `quench-strike, ninth-blow, iron-hide-stance` | 12.0 s / 5 / 92% | 11.4 s / 0 / 0% | `Brittle` 60/57 (12.0s 92% vs 16.0s 88%) |
| `nghe_bach_doan` | Trúc Cơ | `quench-strike, ninth-blow, iron-hide-stance` | 12.0 s / 5 / 92% | 11.4 s / 0 / 0% | `Brittle` 60/57 (12.0s 92% vs 16.0s 88%) |
| `hau_thiet_anh` | Trúc Cơ | `quench-strike, ninth-blow` | 12.0 s / 5 / 79% | 8.0 s / 0 / 0% | `Brittle` 60/40 (12.0s 79% vs 16.4s 71%) |
| `dinh_hoa_lan` | Trúc Cơ | `quench-strike, ninth-blow` | 12.0 s / 5 / 79% | 8.0 s / 0 / 0% | `Brittle` 60/40 (12.0s 79% vs 16.4s 71%) |
| `tat_kim_thanh` | Luyện Khí | `quench-strike, ninth-blow` | 12.6 s / 5 / 75% | 8.0 s / 0 / 0% | `Brittle` 63/40 (12.6s 75% vs 19.6s 61%) |
| `cat_thanh_diem` | Luyện Khí | `quench-strike, ninth-blow` | 19.6 s / 5 / 61% | 8.0 s / 0 / 0% | (L2 < L4, no Brittle yet) |
| `cat_tinh_chuy` | Luyện Khí | `quench-strike, ninth-blow` | 19.6 s / 5 / 61% | 8.0 s / 0 / 0% | (L3 < L4, no Brittle yet) |
| `man_hac_chau` | Luyện Khí | `quench-strike` | 23.2 s / 5 / 52% | 8.0 s / 0 / 0% | (L1 < L4, no Brittle yet) |

*Targeted probes confirming conditional Effects:*
- `cat_luu_quang` vs Thunder foe (`th-bolt`, Kết Đan typical): `eff:Sky Iron Sings thunder: 5`, `eff:Sky Iron Sings strike: 7` (won in 10.0 s).
- `cat_luu_quang` vs 50x-HP Kết Đan foe (`n_body: 50.0`): fought 30.0 s; `eff:Heat the Edge step: 7`, `eff:Heat the Edge quench: 1`, `eff:Sky Iron Sings strike: 3`, `makers-fold-mark: 15`, `ninth-blow-reset: 6`, `quench-brittle-arm: 11`, `eff:Brittle from Its Own Blow marks: 5`.
- `bang_lanh_toi` vs Burning Nguyên Anh foe (`fire-burn`): `eff:Drawn from the River hit: 1`.
