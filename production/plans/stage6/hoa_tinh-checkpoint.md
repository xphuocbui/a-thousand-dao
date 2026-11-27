# Họa Tinh Đường (`hoa_tinh`): Stage 6 Hydrogen Checkpoint Review

Unanchored review of `hoa_tinh` (`b05`) against `design/world/depth/sects/hoa_tinh.*`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `tools/design/combat_sim/engine.py`, `src/gameplay/combat/fight/effect_compiler.gd`, and `src/gameplay/combat/fight/effect_runner.gd`.

## Ranked Findings

1. **MUST-FIX (FIXED) — `design/stage6-staging/hoa_tinh/arts/part-sect-hoa_tinh.json` (`wet-ink` / `wet-ink-mark`):**
   - **What was wrong:** `ink_marked` is declared as `{"id": "ink_marked", "cap": 1, "each_for": 6}`, and `wet-ink-mark` wrote `{"counter": {"id": "ink_marked", "set": 1}}`. In both `engine.py` (`k = int(arg["set"]) - len(times)`) and `effect_runner.gd` (`kk = int(arg.set) - times.size()`), `set: 1` sees `len(times) == 1` whenever an active mark already exists (`k = 0`) and **does nothing**, failing to refresh the 6 s expiry on subsequent primed hits (`t = 4000`, `5000`) and even on recasts of `wet-ink` while `ink_marked` was still live (`t = 7692`).
   - **Fix applied:** Changed `{"counter": {"id": "ink_marked", "set": 1}}` to `{"counter": {"id": "ink_marked", "add": 1}}`. With `cap: 1`, `add: 1` appends a fresh `t + 6.0` expiry and keeps `times[-1:]` (newest), verified on `ho_mac_nhi` (`times=[9846]` -> `[10000]` -> `[11000]` -> `[13692]` -> `[14000]`).

2. **NIT — `production/plans/stage6/hoa_tinh-review.md` (§Summary):**
   - **What was noted:** The record review claimed `ky_ngan_chuc` fires `the-rain-does-not-take-it` at `t = 0.0 s` under `--gap 1`; in reality `the-rain-does-not-take-it` (`cd 10.0`) opens at `~7.0 s`, firing once before `ky_ngan_chuc` falls at `12.4 s`, whereas non-ring Trúc Cơ / Luyện Khí holders fall at `8.0–8.3 s` before their `~8.5 s` opening cooldown. (Review doc left untouched per allowed-paths rule.)

3. **NIT — `design/stage6-staging/hoa_tinh/arts/part-sect-hoa_tinh.json` (`handle-points` / `handle-points-echo`) & `Autumn Light on the Screen`:**
   - **What was checked:** Verified `handle-points` has no `art_id` on `temp_mods` and no multi-`mod` clobber (`handle-points-bind` applies `bound` + `slowed_time` + `handle_double = 1`; `handle-points-echo` uses `fire_art {which: "last", share: 1.0}`). Tested 50 seeds on `ky_ngan_chuc` (`wasted = 0`): `Autumn Light on the Screen` (`fire_art {which: "longest", share: 0.5}`) always arms on the opening `seven-star-talisman` hit before `handle-points` (`cd 5.0`) fires. In a theoretical edge case where a fighter's opening damaging talisman is evaded until after `handle-points` fires, `Autumn Light`'s pulse echo could consume `handle_double` while `s.last_art` points to `handle-points` (`c_art 0.0`), because `fire_art` carries `kind: "art"` without updating `s.last_art`. No change needed (`which: "last"` is the required multi-talisman engine idiom; `which: "longest"` on `handle-points` would break builds carrying `wet-ink`).

## Audit Checklist Verification

- **Standalone Effect compilation:** All 3 Effects in `design/stage6-staging/hoa_tinh/effects/hoa_tinh.effects.json` (`Rainfast Ink`, `Autumn Light on the Screen`, `Seven Stars in One Stroke`) and all 4 arts in `part-sect-hoa_tinh.json` declare every counter they read/write on themselves (`STANDALONE_EFFECTS_OK 3`, `STANDALONE_ARTS_OK 4`), set no undefined stances, and pass `engine.validate`.
- **`seven-star-talisman` pulse ordering:** `dipper_star_ttl` does not use `decay_per_pulse: 1`; `dipper-tick` precedes `dipper-expire` on `on: "pulse"`, clearing `dipper_star` and `dipper_locked` cleanly on the 12th pulse (`ttl: 1 -> 0 -> expire`). Cleanser probe (`cleanse: 3`, `cd 3.0`, 5 seeds): `ky_ngan_chuc` `wiped = 0, detonate = 15`; `lang_mac_khanh` `wiped = 49, detonate = 0`.
- **`the-rain-does-not-take-it`:** Single `mod` (`talisman_fast: 1, curse_fast: 1, for: 8.0`) + `rain_hold = 8`; no multi-`mod` clobber; `rain-hold-punish` uses `on: "cleansed"` (`scale: event.amount`, `0.25` Cold) as documented in D5.
- **Uniqueness & spatial text:** `spatial_words_check.py --sect hoa_tinh` has 0 non-soft hits (`1` soft prose hit `"behind it"` in `ky_ngan_chuc.build.tree.intent`). All IDs, Effect names, and record IDs are unique against `assets/data/combat_effects.json`, committed `design/`, and other `design/stage6-staging/` folders.
- **Explicit-path linters (`DEPTH_STAGE=design/stage6-staging/hoa_tinh`):**
  - `lint_techniques.py`: `checked 3 techniques, 0 findings` (`7.6 W of 8`, `15.6 W of 16`, `16.0 W of 16`).
  - `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
  - `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings` (`unique 3 of 3`).

## Pending Words Decisions

None (`design/stage6-staging/hoa_tinh/pending.json` has `0` entries).

## Holder Table After Fixes (`sect_fight.py hoa_tinh --seeds 5`)

`0 REFUSED`, `0 NEVER_FIRED` at `--gap 0`, all 3 `hoa_tinh` Effects execute on their real holders.

| Holder (realm) | `--gap 0` (`mean_s, wins, hp_left`) | `--gap 1` (`mean_s, wins, hp_left`) | Arts fired (`--gap 0` / `--gap 1`) | Effects (`with / without`, runs) |
|---|---|---|---|---|
| `ky_ngan_chuc` (`ket_dan`) | `27.6 s, 5/5, 54%` | `12.4 s, 0/5, 0%` | `seven-star-talisman` 15.8/6.6, `handle-points` 7.2/3.0, `the-rain-does-not-take-it` 3.4/1.0 | `Rainfast Ink`: 27.6/27.6 s (5 runs; cleanser probe 0 wipes / 15 detonates); `Autumn Light on the Screen`: 27.6/29.0 s (10 runs); `Seven Stars in One Stroke`: 27.6/28.9 s (271 runs); `Paid in Advance`: `always`-only (gap 1: 12.4/9.5 s) |
| `lac_to_binh` (`truc_co`) | `31.9 s, 5/5, 33%` | `8.3 s, 0/5, 0%` | `seven-star-talisman` 14.6/3.2, `handle-points` 6.8/1.0, `the-rain-does-not-take-it` 3.2/0.0 | `Rainfast Ink`: 31.9/31.9 s (5 runs) |
| `diep_tung_yen`, `nhiep_to_han`, `han_thuy_mac` (`truc_co`) | `35.8 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 13.8/3.0, `handle-points` 5.6/1.0, `the-rain-does-not-take-it` 3.2/0.0 | `Rainfast Ink`: 35.8/35.8 s (5 runs) |
| `lang_mac_khanh`, `luc_thanh_chi` (`truc_co`) | `38.5 s, 2/5, 4%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 15.2/3.0, `handle-points` 6.2/1.0 | n/a |
| `te_thu_anh` (`luyen_khi`) | `33.6 s, 1/5, 3%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 13.4/3.0, `handle-points` 5.2/1.0, `the-rain-does-not-take-it` 3.2/0.0 | `Rainfast Ink`: 33.6/33.6 s (5 runs) |
| `tan_cuc_hoa` (`luyen_khi`) | `36.3 s, 1/5, 2%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 14.4/3.0, `handle-points` 5.2/1.0 | n/a |
| `ma_tinh_but` (`luyen_khi`) | `35.2 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 12.6/3.0 | n/a |
| `ho_bach_yen`, `thai_huyen_nhung`, `nham_thanh_luu`, `liem_an_loc`, `ho_mac_nhi`, `phu_vu_sinh`, `quan_loc_nhi` (`luyen_khi`) | `56.6 s, 0/5, 0%` | `8.4 s, 0/5, 0%` | `wet-ink` 14.0/2.0 | n/a |

CHECKPOINT DONE
