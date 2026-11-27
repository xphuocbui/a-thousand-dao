# Phần Vũ Đường (`phan_vu`): Stage 6 checkpoint review (2026-11-27, auto-accepted)

## Summary

Reviewed `design/stage6-staging/phan_vu/` against `design/world/depth/sects/phan_vu.*`, `_brief-record.md`, `_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`, and GDScript compiler parity (`effect_compiler.gd`, `build_file_compiler.gd`, `fighter_profile_loader.gd`, `fight.gd`).

- **Findings:** 0 `MUST-FIX`, 1 `SHOULD` (fixed in `design/world/depth/sects/phan_vu.items.json`).
- **Pending words:** 0 (no `pending.json`).
- **GDScript standalone parity:** PASS — all 3 Effects in `phan_vu.effects.json` declare every counter they read or write in their own `"counters"` array (`missing: []`), none set a stance (Effects merged from `combat_effects.json` do not merge `"states"`), all 8 arts in `part-sect-phan_vu.json` declare all counters and states they reference, `wall-of-red-rock` guards `own.state.any == 0` so it never clobbers `mountain-stance`, and no `on: "always"` record has a record-level `filter`.
- **Effect name uniqueness:** PASS — `Red Cloud Rising`, `Burn and Get Back Up`, and `Let You Burn Out` have 0 collisions against `assets/data/combat_effects.json` (258 entries) and all other staged `.effects.json` files (`minh_loan`, `muc_van`, `nhan_van`, `truc_thuc`, `xuyen_lam`; 23 staged Effects total).
- **`stand-in-the-ash` & `Burn and Get Back Up` verification:** Confirmed genuine (details below); no code or record bug.

---

## Ranked Findings

1. **[SHOULD — FIXED] `design/world/depth/sects/phan_vu.items.json` (`pvd-xich-ha-ky` / `red-cloud-rising`):**
   - *What was wrong:* The depth item record still carried the pre-ruling spatial/allies wording (`"While the banner is planted, allies within its cloud gain..."` in `effects[0].rule`, and `"allies"` in `build_use`), which `spatial_words_check.py --sect phan_vu` flagged as `removed` / `postponed` rule-field hits even though the staged `phan_vu.effects.json` and `items/catalogue-sect-phan_vu.json` had already been rewritten per `DECISIONS-2026-11-26.md` (no spatial fight, one side against one side).
   - *Fix applied:* Rewrote `effects[0].rule` on `pvd-xich-ha-ky` in `design/world/depth/sects/phan_vu.items.json` to `"Every 3 s, you gain 1 Fire stack of fury (15 s, raising attack) and 1 self-Burn stack (6 s, burning you for a little health each second); once each fight, if you would fall, you rise at a fifth of your health."` and updated `build_use` to `"A war banner for the hall's levy: Fire fury on the wearer and one rising."` (matching `items/catalogue-sect-phan_vu.json`).

---

## Investigation: `stand-in-the-ash` (`NEVER_FIRED` at `--gap 0`) and `Burn and Get Back Up`

- **`stand-in-the-ash` on `hung_phan_vu` and `tao_tan_kien`:**
  - *Slot priority:* `stand-in-the-ash` is in slot 1 (right after `feathers-burn` in slot 0) on both `hung_phan_vu` and `tao_tan_kien` (`burning-feather-body-canon` layer 9), so it is not starved by slot priority.
  - *Trigger / guard at `--gap 0`:* Guarded on `own.hp_share <= 0.33` and `own.counter.ash_stood == 0`. Against a `--gap 0` `typical` Kết Đan foe, both Tier A leaders win easily (`hung_phan_vu`: `21.3 s 5/5 100%`, seed 1 ends at `100.0%` HP and `61.5%` body shield; `tao_tan_kien`: `26.4 s 5/5 100%`, seed 1 ends at `100.0%` HP and `35.3%` body shield). Because their HP never drops to `<= 33%`, `stand-in-the-ash` legitimately stays held (`0.0 fires`, `NEVER_FIRED`). Meanwhile, all 7 Trúc Cơ / Luyện Khí holders (`ngac_tri_hoa`, `sai_tinh_lan`, `trang_hoi_y`, `doi_liet_cuong`, `hac_dan_thach`, `bao_viem_nuong`, `thuong_quy_vu`) drop below 33% HP and fire `stand-in-the-ash` `1.0/fight` at `--gap 0`.
  - *`--gap 1` firing:* Against a `typical` Nguyên Anh foe (`--gap 1`), `hung_phan_vu` fires `stand-in-the-ash` `1.0/fight` (5/5 seeds) and `tao_tan_kien` fires it `0.6/fight` (3/5 seeds; in seeds 1 and 4 `nirvana-of-the-red-wall` refuses Down to 50% HP at `12.24 s` and lethal damage takes him from >33% straight to Down before pulse 17 / `act()`). The 7 Trúc Cơ / Luyện Khí holders die in `8.0–8.2 s` at `--gap 1` before firing `stand-in-the-ash`.
- **`Burn and Get Back Up` (`pvd-standing-fire` 3pc on `hung_phan_vu`):**
  - At `--gap 0` vs `typical` Kết Đan, `hung_phan_vu`'s 56%+ body shield never breaks, so only the two `fight_start` setup records (`eff:Burn and Get Back Up flag`, `eff:Burn and Get Back Up start`) run (`runs 10` over 5 seeds).
  - At `--gap 1` vs `typical` Nguyên Anh (`sect_fight.py phan_vu --seeds 5 --gap 1`), `Burn and Get Back Up` changes the fight outcome cleanly (`with 18.3 s 0%` vs `without 17.0 s 0%`, `runs 20`: 6 shield breaks, 6 `c: 2.0` Fire free hits on `[fist, basic]`, and 5/5 33% rises overriding `Red Cloud Rising`'s 20% rise via `has_standing_fire`).
  - Against a stronger same-realm foe (`typical` Kết Đan with `1.6x` layers, 5 seeds), `Burn and Get Back Up` extends `hung_phan_vu`'s survival from `35.744 s` to `39.344 s` (`+3.6 s`).

---

## Pending Words

None (`0` pending words; all records use existing engine words).

---

## Checks After Final Edit (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\phan_vu`)

- `lint_techniques.py design/stage6-staging/phan_vu/techniques/catalogue-sect-phan_vu.json`: checked 4 techniques, **0 findings** (`7.7 W of 8`, `15.8 W of 16`, `23.7 W of 24`, `7.0 W of 8`).
- `lint_arts.py design/stage6-staging/phan_vu/arts/part-sect-phan_vu.json`: checked 8 arts in 1 files, **0 findings**.
- `lint_items.py design/stage6-staging/phan_vu/items/catalogue-sect-phan_vu.json`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py --quiet`: **findings: none** (1891 people, 435 builds with Đạo Đồ targets).
- `depth_gap.py --sect phan_vu`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 29/29 runs`.
- `sect_fight.py phan_vu --seeds 5 --gap 0` & `--gap 1`: **0 REFUSED** across all 18 living cast members.

---

## Holder Table After Fixes (`sect_fight.py phan_vu --seeds 5`, `--gap 0` / `--gap 1`)

| Holder | Realm | Arts | `--gap 0` (`mean_s`, `wins`, `hp_left`) | `--gap 1` (`mean_s`, `wins`, `hp_left`) | Staged Effects (`gap 0` / `gap 1`) | Notes on art fires |
|---|---|---|---|---|---|---|
| `hung_phan_vu` | `ket_dan` | `feathers-burn,stand-in-the-ash,into-the-vent,mountain-stance,sinking-weight,bastion-reprisal` | `21.3 s`, `5/5`, `100%` | `18.3 s`, `0/5`, `0%` | **Red Cloud Rising**: `21.3 s` vs `27.4 s` (`36` runs) / `18.3 s` vs `16.8 s` (`32` runs); **Burn and Get Back Up**: `21.3 s` vs `21.3 s` (`10` runs) / `18.3 s` vs `17.0 s` (`20` runs) | `stand-in-the-ash` `0.0` (`NEVER_FIRED` at `gap 0`: 100% HP), `1.0` at `gap 1`; `bastion-reprisal` `2.0` at `gap 0`, `0.0` at `gap 1` |
| `tao_tan_kien` | `ket_dan` | `feathers-burn,stand-in-the-ash,into-the-vent,scorch-fist,wall-of-red-rock,nirvana-of-the-red-wall` | `26.4 s`, `5/5`, `100%` | `17.6 s`, `0/5`, `0%` | **Let You Burn Out**: `26.4 s` vs `28.4 s` (`526` runs) / `17.6 s` vs `18.0 s` (`320` runs) | `stand-in-the-ash` `0.0` (`NEVER_FIRED` at `gap 0`: 100% HP), `0.6` at `gap 1`; `wall-of-red-rock` `3.0`/`0.4`; `nirvana-of-the-red-wall` `4.0`/`1.0` |
| `doi_liet_cuong` | `truc_co` | `feathers-burn,stand-in-the-ash,into-the-vent,scorch-fist` | `42.2 s`, `5/5`, `32%` | `8.0 s`, `0/5`, `0%` | n/a | `feathers-burn` `6.8`/`1.0`, `stand-in-the-ash` `1.0`/`0.0`, `into-the-vent` `4.2`/`0.4`, `scorch-fist` `10.4`/`2.0` |
| `trang_hoi_y` | `truc_co` | `feathers-burn,stand-in-the-ash,into-the-vent` | `53.8 s`, `1/5`, `1%` | `8.2 s`, `0/5`, `0%` | n/a | `feathers-burn` `8.4`/`1.0`, `stand-in-the-ash` `1.0`/`0.0`, `into-the-vent` `5.8`/`0.4` |
| `ngac_tri_hoa` | `truc_co` | `feathers-burn,stand-in-the-ash,into-the-vent` | `54.4 s`, `1/5`, `1%` | `8.2 s`, `0/5`, `0%` | n/a | `feathers-burn` `8.6`/`1.0`, `stand-in-the-ash` `1.0`/`0.0`, `into-the-vent` `5.8`/`0.4` |
| `sai_tinh_lan` | `truc_co` | `feathers-burn,stand-in-the-ash,into-the-vent` | `54.4 s`, `1/5`, `1%` | `8.2 s`, `0/5`, `0%` | n/a | `feathers-burn` `8.6`/`1.0`, `stand-in-the-ash` `1.0`/`0.0`, `into-the-vent` `5.8`/`0.4` |
| `hac_dan_thach` | `truc_co` | `feathers-burn,stand-in-the-ash,into-the-vent` | `54.4 s`, `1/5`, `1%` | `8.2 s`, `0/5`, `0%` | n/a | `feathers-burn` `8.6`/`1.0`, `stand-in-the-ash` `1.0`/`0.0`, `into-the-vent` `5.8`/`0.4` |
| `bao_viem_nuong` | `truc_co` | `feathers-burn,stand-in-the-ash` | `48.8 s`, `0/5`, `0%` | `8.2 s`, `0/5`, `0%` | n/a | `feathers-burn` `8.8`/`1.0`, `stand-in-the-ash` `1.0`/`0.0` |
| `thuong_quy_vu` | `luyen_khi` | `feathers-burn,stand-in-the-ash` | `41.8 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | n/a | `feathers-burn` `7.0`/`1.0`, `stand-in-the-ash` `1.0`/`0.0` |
| `long_chuoc_sinh` | `luyen_khi` | `feathers-burn` | `40.8 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | n/a | `feathers-burn` `7.0`/`1.0` |
| `cat_xich_van` | `luyen_khi` | `feathers-burn` | `40.8 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | n/a | `feathers-burn` `7.0`/`1.0` |
| `do_lang_quyen` | `luyen_khi` | `hot-rock,shake-off-the-ash` | `64.0 s`, `2/5`, `4%` | `8.4 s`, `0/5`, `0%` | n/a | `hot-rock` `1.0`/`1.0`, `shake-off-the-ash` `12.0`/`1.2` |
| `khanh_mac_thach` | `luyen_khi` | `hot-rock,shake-off-the-ash` | `64.0 s`, `2/5`, `4%` | `8.4 s`, `0/5`, `0%` | n/a | `hot-rock` `1.0`/`1.0`, `shake-off-the-ash` `12.0`/`1.2` |
| `nguy_hong_tao` | `luyen_khi` | `hot-rock,shake-off-the-ash` | `64.0 s`, `2/5`, `4%` | `8.4 s`, `0/5`, `0%` | n/a | `hot-rock` `1.0`/`1.0`, `shake-off-the-ash` `12.0`/`1.2` |
| `kinh_tieu_hoa` | `luyen_khi` | `hot-rock,shake-off-the-ash` | `64.2 s`, `1/5`, `3%` | `8.4 s`, `0/5`, `0%` | n/a | `hot-rock` `1.0`/`1.0`, `shake-off-the-ash` `12.2`/`1.2` |
| `nhiep_hoi_sinh` | `luyen_khi` | `hot-rock,shake-off-the-ash` | `64.2 s`, `1/5`, `3%` | `8.4 s`, `0/5`, `0%` | n/a | `hot-rock` `1.0`/`1.0`, `shake-off-the-ash` `12.2`/`1.2` |
| `lanh_nham_nuong` | `luyen_khi` | `hot-rock,shake-off-the-ash` | `64.2 s`, `1/5`, `3%` | `8.4 s`, `0/5`, `0%` | n/a | `hot-rock` `1.0`/`1.0`, `shake-off-the-ash` `12.2`/`1.2` |
| `boc_than` | `luyen_khi` | `bank-the-kiln` | `46.8 s`, `1/5`, `1%` | `8.0 s`, `0/5`, `0%` | n/a | `bank-the-kiln` `13.8`/`2.0` |

CHECKPOINT DONE
