# Stage 6 checkpoint review: Yên Quang Các (`yen_quang`)

Unanchored audit of `design/stage6-staging/yen_quang/` against `design/world/depth/sects/yen_quang.*` (`md`, `techniques.json`, `items.json`, `cast.json`, `5.cast.json`), `design/arts/family-wood.json`, `design/techniques/catalogue-wood.json`, `assets/data/combat_engine.json`, `assets/data/combat_effects.json`, Stage 6 rules (`_brief-record.md`, `_brief-review.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `FIGHT-INPUT.md`), and both combat engines (`tools/design/combat_sim/{engine,fight,sect_fight}.py` and `src/gameplay/combat/fight/{effect_compiler,effect_runner,fighter_state,fight}.gd`).

## Ranked findings (1 MUST-FIX applied, 1 SHOULD applied, 1 NIT noted)

| # | Severity | File | Record / ID | What was wrong | Fix applied |
|---|---|---|---|---|---|
| 1 | **MUST-FIX** | `design/stage6-staging/yen_quang/effects/yen_quang.effects.json` | `Unlit` (`eff:Unlit:clear_cost`, `eff:Unlit:tick`, `eff:Unlit:pulse_cost`, `eff:Unlit:pulse_trigger`) | `eff:Unlit:clear_cost` (`on: "pulse"`) was ordered *after* `eff:Unlit:pulse_cost` (`on: "pulse"`), and `eff:Unlit:tick` *after* `eff:Unlit:pulse_trigger`. When the holder fell to `<= 40 %` HP during a `pulse` (tick or fatigue) without `Haze Held All Night` (`dusk_no_lit_cost == 0`), `pulse_cost` set `furnace_hp_cost = 1` and `clear_cost` immediately reset it to `0` in the same `pulse` event before the next pulse's `upkeep` could deduct `10 %` max HP; `tick` also decremented `furnace_burn` `10 -> 9` in the same pulse. | Moved `eff:Unlit:clear_cost` and `eff:Unlit:tick` before `eff:Unlit:pulse_cost` and `eff:Unlit:pulse_trigger`. Verified in a targeted pulse-trigger probe (`diem_tu_to` without `Haze Held All Night`, `2,450` Wood stacks for 2 s): at `t = 3.0 s` HP fell to `10.38 %`, `furnace_hp_cost = 1` persisted, and at `t = 4.0 s` `upkeep` deducted exactly `10.00 %` max HP (`10.38 % -> 0.38 %`) before `clear_cost` cleared it. |
| 2 | **SHOULD** | `design/stage6-staging/yen_quang/effects/yen_quang.effects.json` | `Haze Held All Night` (`approx`) | `store_restored` and `store_overflow` have no `filter`, so they store `event.share` from all incoming heals (including pulse regen), whereas the `rule` says "from your own arts" and `approx` previously said "half of incoming heals" without noting why it is unfiltered (`art.heal` like `second-spring` fires before `s.cur_ev` is set, and `the-haze-gathers` releases on `pulse`, so neither carries `kind: "art"`). | Clarified `approx` to state explicitly that `heal_taken -50` and `heal_restored`/`heal_overflow` cover all incoming heals unfiltered because `art.heal` and pulse-released heals do not carry `kind: "art"`. |
| 3 | **NIT** | `design/world/depth/sects/yen_quang.cast.json` | `diem_tu_to` (`sect_fight.py` 6-art cap) | `diem_tu_to` knows 3 techniques (`verdant-cycle-scripture`, `gathered-haze-canon`, `evening-haze-furnace`, 8 arts total), so `sect_fight.py`'s `MAX_ARTS = 6` slots `seed-of-spring`, `rooted-form`, `second-spring`, `harvest-bloom`, `the-haze-gathers`, `dusk-haze` and leaves `bank-the-furnace` out of the 6-art loadout; `bank-the-furnace` fires `1.0–3.2×` on the other 5 `evening-haze-furnace` holders. | Left untouched (expected `MAX_ARTS = 6` behaviour). |

---

## Checked & verified

### 1. Uniqueness & standalone compilation parity
- **Uniqueness:** 0 collisions for `yen_quang`'s 3 technique ids, 4 art ids, 6 item ids, 2 set ids, and 4 Effect names against `assets/data/combat_effects.json`, committed `design/`, and all 9 other staged `b03` directories (`chan_kim`, `chuc_ha`, `hoa_cai`, `hong_dau`, `le_hoa`, `nhan_tran`, `phat_y`, `thai_chi`, `vu_linh`).
- **Standalone Effect compilation parity (`effect_compiler.gd` / `engine.validate`):**
  - Every Effect in `yen_quang.effects.json` self-declares all counters it reads or writes in its own `"counters"` (`Lit at Dusk`: `[]`; `Unlit`: `furnace_lit`, `furnace_burn`, `furnace_hp_cost`, `dusk_no_lit_cost`; `Banked Till Dusk`: `[]`; `Haze Held All Night`: `furnace_lit`, `dusk_no_lit_cost`, `dusk_heal_store`, `dusk_released`).
  - Zero `always` records have a record-level `filter` (scopes live inside `mod`), zero multi-`mod` records exist without `"stack": true`, zero `decay_per_pulse: 1` off-by-one counters exist, and zero counters are armed and spent on the same hit.
- **Stance safety (`haze_sec` vs `rooted-form`):**
  - All 6 `evening-haze-furnace` holders (`tao_mo_tu`, `diem_tu_to`, `van_duong_quy`, `ly_tang_ky`, `nhac_vien_chi`, `au_hoang_ky`) also slot `verdant-cycle-scripture`'s committed `rooted-form` (`family-wood.json`), which toggles `s.state = "rooted"` and checks `own.state.rooted == 1`. Using self-counter `haze_sec` on `dusk-haze` leaves `rooted-form` intact across all firings (`tao_mo_tu` probe vs tanky Trúc Cơ foe: `rooted-form:8`, `dusk-haze:6`, `bank-the-furnace:6`).

### 2. Specific focus investigations
- **`Lit at Dusk` (`tao_mo_tu`) and `Banked Till Dusk` (`tao_mo_tu`) at `gap 0`, `gap 1`, and targeted >20 s probe:**
  - `sect_fight.py` counts `runs` by hooking `Fight.do()`, which `on: "always"` records never call (`Lit at Dusk` is `on: "always"`). In `sect_fight.py`, `tao_mo_tu` ends `gap 0` in `19.6 s` (`5/5` wins, `100 %` HP; `Banked Till Dusk` runs `3` times via `< 20 s`? No, `Banked Till Dusk:dur` is `always`, and `Banked Till Dusk:cleanse` ran `3` times when seeds crossed `20 s` briefly before finishing at `19.6 s` mean) and loses `gap 1` in `11.3 s` (`0/5` / `0/20` wins before `t = 20 s`).
  - Targeted probe on `tao_mo_tu` vs a tanky same-realm foe (`n_body: 5.0`, `layers: [110, 80, 40, 20, 0]`, `seed = 1`, `67.0 s` win): removing `Lit at Dusk` left `tao_mo_tu` lower across pulses after `t = 20 s` (e.g., `t = 29 s`: `97.6 %` HP with vs `96.1 %` without; `t = 32 s`: `92.2 %` vs `90.9 %`; `t = 34 s`: `100.0 %` vs `99.4 %`), confirming `stack_more: 0.2` on `wood` buffs takes effect live after `t = 20 s`.
- **`Unlit` (`diem_tu_to`) at `gap 0` and `gap 1`:**
  - At `gap 0` (`--seeds 5`), `diem_tu_to` wins in `16.9 s` at `100 %` HP (never drops to `<= 40 %` HP, so `Unlit` has `0` runs).
  - At `gap 1` (`20` seeds, `sect_fight.py yen_quang --gap 1`), `Unlit` runs `143` times and extends survival from `14.6 s` (`without`) to `19.2 s` (`with`, `+4.6 s`); `Haze Held All Night` runs `437` times and extends survival from `17.1 s` to `19.2 s` (`+2.1 s`).
- **`second-spring` `NEVER_FIRED` at `gap 1` on Trúc Cơ holders:**
  - `second-spring` (`family-wood.json`) has `cooldown: 8.0` and `guards: [own.hp_share <= 0.95]`. Under `+1`-realm Kết Đan pressure (`gap 1`), `nhac_vien_chi`, `au_hoang_ky`, `tao_mo_tu`, `van_duong_quy`, and `ly_tang_ky` fall in `11.3–12.1 s`, either before `8 s` drops them to `<= 95 %` HP or after running low on linh lực. At `gap 0` (`--seeds 5`), `second-spring` fires `0.6–1.0×` on all 5 holders.

### 3. Techniques, items, sets, and stand-ins
- **Techniques (`catalogue-sect-yen_quang.json`):** `dusk-gathering-primer` (`7.8 W of 8`), `evening-haze-furnace` (`14.7 W of 16`), `gathered-haze-canon` (`23.7 W of 24`); bonuses match `bonus_pool`; all 4 new art ids are registered in `yen_quang.techniques.json` (`"id"` before `"new"`). `lint_techniques.py`: `0 findings`.
- **Arts (`part-sect-yen_quang.json`):** `one-in-three`, `dusk-haze`, `bank-the-furnace`, `the-haze-gathers` all lint cleanly (`0 findings`) and match depth text / `yen_quang-review.md` decisions.
- **Items & sets (`catalogue-sect-yen_quang.json`, `sets-yen_quang.json`):** 6 items, all 25 depth modifier lines preserved (`depth_gap.py`: `lines: 25/25 runs`), `sources: ["npc"]`, `unique: true`, `rarity: 4` on `yq-evening-glow-furnace`, `rarity: 5` on `yq-cold-furnace`, R6 `exception` on the 3 weapon/body_gear pieces (`yq-last-light-gourd`, `yq-dusk-field-robe`, `yq-purple-haze-gourd`). `lint_items.py`: `0 findings`.
- **Stand-ins & beasts:** `stand_ins: 0`, `beasts: 0`; all 17 living members in `yen_quang.cast.json` and `yen_quang.5.cast.json` already use `dusk-gathering-primer` or `verdant-cycle-scripture` fitting their Wood/Earth roots.

---

## Pending word decisions

None (`0` pending words; no `pending.json` in `design/stage6-staging/yen_quang/`).

---

## Linters & Holder table after fixes

### Linters & structural checks (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\yen_quang`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`7.8 W / 8`, `14.7 W / 16`, `23.7 W / 24`)
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`
- `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings` (`unique 6 of 6`)
- `depth_check.py`: `findings: none`
- `depth_gap.py --sect yen_quang`: `stand_ins: 0, unknown_ids: 0, cross_owner: 0, ties_unmapped: 0, ties_over_cap: 0, engine_words: 0, wishes_open: 0, lines: 25/25 runs`
- `sect_fight.py yen_quang --seeds 5` (`gap 0`) and `sect_fight.py yen_quang --gap 1` (`20` seeds): **0 REFUSED** across all 12 authored-method/item holders (`sam_bach_chi`, `phung_cam_thao`, `khong_ich_mau`, `thai_tri_mau`, `mo_nguu_tat` use `verdant-cycle-scripture` only, excluded by `sect_fight.py`'s authored-owner filter).

### Holder table (post-fix: `gap 0` `--seeds 5`, `gap 1` default `20` seeds)

| Holder | Realm | `gap 0` (`mean_s`, wins, HP) | `gap 1` (`mean_s`, wins, HP) | Arts & Effects (`with` vs `without`, `runs`) |
|---|---|---|---|---|
| `tao_mo_tu` | Trúc Cơ 2 | `19.6 s`, `5/5`, `100 %` | `11.3 s`, `0/20`, `0 %` | `dusk-haze` `2.0`/`1.0`, `bank-the-furnace` `2.0`/`1.0`, `second-spring` `0.6`/`0.0`. **Lit at Dusk**: `19.6 s 100%` vs `19.6 s 100%` (`0` runs, `always` + `<20 s` at `gap 0/1`; verified active post-`20 s` in probe). **Banked Till Dusk**: `19.6 s 100%` vs `19.6 s 100%` (`3` runs at `gap 0` / `0` at `gap 1`, `<20 s`). |
| `diem_tu_to` | Kết Đan 1 | `16.9 s`, `5/5`, `100 %` | `19.2 s`, `0/20`, `0 %` | `the-haze-gathers` `1.0`/`0.6`, `dusk-haze` `1.8`/`1.0`, `second-spring` `0.2`/`0.5`. **Unlit**: `0` runs at `gap 0` (`100 %` HP); `gap 1` `19.2 s 0%` vs `14.6 s 0%` (`143` runs). **Haze Held All Night**: `gap 0` `16.9 s 100%` vs `16.9 s 100%` (`157` runs); `gap 1` `19.2 s 0%` vs `17.1 s 0%` (`437` runs). |
| `van_duong_quy` | Trúc Cơ 2 | `19.6 s`, `5/5`, `100 %` | `12.1 s`, `0/20`, `0 %` | `dusk-haze` `2.0`/`1.0`, `bank-the-furnace` `2.0`/`1.0`, `second-spring` `0.6`/`0.0` |
| `ly_tang_ky` | Trúc Cơ 0 | `31.9 s`, `5/5`, `100 %` | `12.1 s`, `0/20`, `0 %` | `dusk-haze` `3.2`/`1.0`, `bank-the-furnace` `3.2`/`1.0`, `second-spring` `1.0`/`0.0` |
| `nhac_vien_chi`, `au_hoang_ky` | Trúc Cơ 1 / 0 | `31.1 s`, `5/5`, `100 %` | `12.1 s`, `0/20`, `0 %` | `dusk-haze` `3.0`/`1.0`, `bank-the-furnace` `3.0`/`1.0`, `second-spring` `1.0`/`0.0` |
| `ma_thu_diep`, `co_tam_nhi`, `trang_van_lo`, `trang_van_thao`, `tien_tieu_dong`, `mai_tieu_ngai` | Luyện Khí | `24.8 s`, `5/5`, `99 %` | `8.0 s`, `0/20`, `0 %` | `one-in-three` `6.8`/`1.9`, `seed-of-spring` `4.8`/`1.0` |
| `sam_bach_chi`, `phung_cam_thao`, `khong_ich_mau`, `thai_tri_mau`, `mo_nguu_tat` | Trúc Cơ / Luyện Khí | — | — | `verdant-cycle-scripture` only (no staged `yen_quang` art or named item) |

CHECKPOINT DONE
