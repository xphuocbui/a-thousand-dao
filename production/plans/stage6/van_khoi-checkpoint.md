# Stage 6 Checkpoint Review — `van_khoi` (Vân Khởi Quán, Batch `b04`)

Unanchored review against `design/world/depth/sects/van_khoi.*`, `van_khoi.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, and Băng Tâm's approved files.

---

## 1. Ranked Findings

### 1. **MUST-FIX** — `design/stage6-staging/van_khoi/effects/van_khoi.effects.json` (`Read Aloud` / `eff:Read Aloud third`)
- **What was wrong:** `eff:Read Aloud third` used `{"timer": {"side": "own", "which": "next", "by": -99}}` on `art_fired`. In `tools/design/combat_sim/engine.py`, `which: "next"` selects `min(ready[i])` across all slotted arts. On `van_nhan_huong` (and any `sitting-cloud-canon` holder), `clouds-rise` in slot 1 fires once at `t = 3.0 s` and is then blocked by its guard (`own.state.clouds-watching < 1`) for the rest of the fight with `ready[1] = 3000`. Consequently `which: "next"` always picked `clouds-rise`, producing **0** cooldown acceleration (`lamp-oil-lance` fired `16.0` times both with and without `Read Aloud`) while creating spurious `act()` wakeups at `t + 500 ms` that shifted `self.order` RNG draws (`60.6 s 1%` with vs `62.2 s 4%` without). Even without `clouds-rise`, `which: "next"` could target `the-water-has-ended` rather than a soul art.
- **Fix applied:** Added `eff:Read Aloud cast-now` (`on: "always"`, `if: [own.counter.bell_ring >= 1, own.counter.read_aloud >= 2]`, `do: [{"mod": {"art_speed": 1000, "tags": ["soul"]}}]`) so the 3rd bell-lit soul art sets its cooldown to `cooldown_min` (`0.5 s`), firing the next soul art immediately at the `1.0 s` `soul_lockout` (`t = 10 s, 17 s, 24 s, 31 s, 38 s` in seed 0), and kept `eff:Read Aloud third` solely to reset `read_aloud` to `0` at `read_aloud >= 3`. Updated `Read Aloud`'s `rule` and `approx` text to match.

### 2. **SHOULD** — `design/stage6-staging/van_khoi/effects/van_khoi.effects.json` (`Read Aloud` / `eff:Read Aloud ring`)
- **What was wrong:** `bell_ring` has `each_for: 6.5` (`cap: 1`), while `eff:Read Aloud ring` (`on: "was_hit"`) had `limit: {"cooldown": 8.0}`, leaving a `1.5 s` dead window (`7.5..9.0 s`) where incoming hits failed to re-ring the bell and `t = 9.0 s` soul casts raced `was_hit`.
- **Fix applied:** Lowered `eff:Read Aloud ring` `limit.cooldown` from `8.0` to `6.0` (matching the 6 s bell window in the depth rule).

### 3. **NIT** (verified, no edit needed)
- **`status_dur` clamp on `lamp-oil-lance`:** `lamp-oil-lance` (`design/arts/family-soul-song-seal.json`) lays `slackened_soul` (`curse`, `dur: 5`), which already sits at `K["curse_duration_max"] = 5`. Both `clouds-rise` (`+15 % status_dur` per Cloud) and `Read Aloud` (`+25 % status_dur`) clamp to `5 s` on `lamp-oil-lance` while remaining valid for any `<5 s` soul status; documented in `Read Aloud`'s `rule` and `approx`.
- **Unreached branches on `typical` foes:** `Sit and Watch` reports `runs 0 NEVER_RAN` in `sect_fight.py` because `sect_fight.py` counts `Fight.do()` calls rather than `on: "always"` mods (verified active via `82%` vs `78%` HP at `--gap 0` and `11.2 s` vs `9.5 s` survival at `--gap 1`) and `typical` enemies cast no statuses (verified `eff:Sit and Watch watch: 1`, `eff:Sit and Watch ended: 1`, `water-ended-turn: 1` in status-foe probe). `Sit as Thôi Sat`'s 5-Cloud counter-hit never reaches 5 Clouds when `lamp-oil-lance` spends Clouds every ~2.7–3 s (verified `runs 106` via `tick`/`bank` feeding `lamp-oil-lance`, and `palm: 3, echo: 3, clear: 3` in a probe without `lamp-oil-lance`).

---

## 2. Verification Summary (All Re-Run After Final Edit)

- **Linters (`DEPTH_STAGE=design/stage6-staging/van_khoi`)**:
  - `lint_techniques.py`: `checked 3 techniques, 0 findings` (`water-ends-primer` `8.0 W of 8`, `sitting-cloud-canon` `23.8 W of 24`, `cloud-mother-seal` `15.0 W of 16`)
  - `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`
  - `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings` (`36.0/51.2`, `34.4/38.4`, `22.0/25.6`, `34.8/51.2`, `36.6/51.2`, `22.0/25.6 W`, `6/6 unique`, R6 `exception` on the 4 `dao_bao`/`chuong`/`an` pieces)
- **Standalone Effect compilation (`engine.validate` + GDScript `EffectCompiler` rules)**: `STANDALONE_OK` on all 3 Effects (`Sit and Watch`, `Sit as Thôi Sat`, `Read Aloud`), all counters declared locally, 0 multi-`mod` conflicts, 0 `temp_mods` `art_id`/`status` filter issues, 0 `always` record-level filters, 0 listener-order races.
- **ID / Effect-name collisions**: `0` collisions against `assets/data/combat_effects.json`, committed `design/`, and other staged directories.
- **`spatial_words_check.py --sect van_khoi`**: `0` staged rule hits (`4` non-rule `people.ties.note` lore hits in depth cast files: `beside` ×3, `Alone` ×1).
- **`depth_gap.py --sect van_khoi`**: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `beasts 0`, `lines 26/27 runs` (`1` open: `cast_ward_duration_pct` on `vk-cloud-mother-mirror`).
- **Stand-ins & Root Fit**: `0` stand-ins needed; all 19 living cast members hold `van_khoi` element-free lineage methods matching their rank and root (`water-ends-primer` for novices/luyen_khi, `sitting-cloud-canon` for inner/elders/abbot, `cloud-mother-seal` for `lanh_xuan_gian`, `hundred-echo-palm-scripture` aux where cast builds list it).
- **Pending Words**: `none` (`pending.json` not present; all records run on existing engine words).

---

## 3. Holder Table After Fixes (`sect_fight.py van_khoi --seeds 5`)

| Holder(s) | Realm | Slotted Arts | Gap 0 (`mean_s`, `wins/5`, `hp%`) | Gap 1 (`mean_s`, `wins/5`, `hp%`) | Effect / Art Notes (`gap 0`) |
|---|---|---|---|---|---|
| `tong_toa_van` | `nguyen_anh` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist`, `rolling-barrage-fist` | `19.0 s`, `5/5`, `82%` | `11.2 s`, `0/5`, `0%` | Arts fire `6.0 / 1.0 / 2.0 / 6.8 / 2.0 / 9.0`. `Sit and Watch`: `19.0 s 82%` vs `19.0 s 78%` (`11.2 s` vs `9.5 s` at `--gap 1`, `runs 0`). `Sit as Thôi Sat`: `19.0 s 82%` vs `19.2 s 82%` (`runs 106`). |
| `van_nhan_huong` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended` | `61.8 s`, `0/5`, `0%` | `8.2 s`, `0/5`, `0%` | Arts fire `16.0 / 1.0 / 6.8`. `Read Aloud`: `61.8 s 0%` vs `62.2 s 4%` (`runs 164` at gap 0, `109` at gap 1); 4th soul casts verified firing at `1 s` lockout (`10s, 17s, 24s, 31s, 38s`). |
| `kha_thuy_cung` | `ket_dan` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist`, `rolling-barrage-fist` | `19.8 s`, `5/5`, `74%` | `8.0 s`, `0/5`, `0%` | Arts fire `6.2 / 1.0 / 2.0 / 7.0 / 2.0 / 8.6`. |
| `lanh_xuan_gian` | `ket_dan` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `frozen-hour-seal`, `cloud-in-the-pane` | `42.4 s`, `5/5`, `92%` | `18.1 s`, `0/5`, `0%` | Arts fire `13.4 / 1.0 / 5.8 / 12.0 / 8.6`. |
| `nong_bach_thach` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist`, `rolling-barrage-fist` | `19.5 s`, `5/5`, `75%` | `8.0 s`, `0/5`, `0%` | Arts fire `6.2 / 1.0 / 2.0 / 7.0 / 2.2 / 8.0`. |
| `han_thanh_dai`, `ha_khong_thuy` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist` | `22.5 s`, `5/5`, `66%` | `8.0 s`, `0/5`, `0%` | Arts fire `7.0 / 1.0 / 2.0 / 7.6 / 2.8`. |
| `trang_thanh_tuyen`, `tho_u_hoang` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended` | `46.2 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | Arts fire `13.8 / 1.0 / 5.2`. |
| `ha_que_hoa` | `luyen_khi` | `lamp-oil-lance`, `clouds-rise` | `41.8 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | Arts fire `13.4 / 1.0`. |
| 9 `water-ends-primer` novices (`an_tho_hoa`, `pho_tieu_diem`, `trinh_van_phien`, `mai_ngu_yen`, `ho_kinh_dieu`, `lao_hong_diep`, `thong_van_thach`, `cu_tung_gian`, `ba_xuan_son`) | `luyen_khi` | `not-counting-the-steps` | `35.4 s`, `0/5`, `0%` | `8.3 s`, `0/5`, `0%` | `not-counting-the-steps` fires `6.6` times at gap 0, `1.1` at gap 1. |

CHECKPOINT DONE
