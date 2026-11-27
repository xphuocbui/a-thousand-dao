# Trấn Sa Đường: Stage 6 review (2026-11-27, headless auto-accepted)

## Summary

- **Built (staged under `design/stage6-staging/tran_sa/`):**
  - **3 techniques:** `sand-wall-primer` (Yellow main, `tho`, 6 layers, passives `7.8 W of 8`), `sand-holding-sabre-canon` (Profound main, `tho` + `kim`, 9 layers, bonus `defense_pct 10`, passives `14.8 W of 16`), and `sword-washing-temper` (Profound secret, `kim` + `tho`, 9 layers, bonus `attack_pct 10`, passives `14.7 W of 16`) in `techniques/catalogue-sect-tran_sa.json`.
  - **4 new arts:** `hold-the-line`, `hold-the-sand`, `answering-cut`, and `spring-quench` in `arts/part-sect-tran_sa.json`; art IDs inserted into `design/world/depth/sects/tran_sa.techniques.json`.
  - **3 signature items and 1 set:** all 3 items in `items/catalogue-sect-tran_sa.json` (`sources: ["npc"]`, `unique: true`, R6 `exception` on all 3: `ts-lone-smoke-sabre`, `ts-quench-hammer`, `ts-caravan-shield`) and `ts-fathers-road` in `items/sets-tran_sa.json`.
  - **2 Effects:** `Smoke on the Road` (`ts-lone-smoke-sabre`) and `The Rider Comes In` (`ts-fathers-road`) in `effects/tran_sa.effects.json`.
- **Stand-ins & beasts:** `0` stand-ins, `0` beasts. Cross-owner ref: `loose-north`'s `ho_dien_liet` uses `sand-wall-primer` (verified with `sect_fight` probe; closes when `sand-wall-primer` merges).
- **Deviations:** `2` logged across records (details in §D–§E).
- **Decisions taken (auto-accepted):** `7` (listed in §A with reasons).
- **Pending words:** `0` (all mechanics expressed with existing engine words).
- **Never ran:** `0` — all 4 new arts and both Effects ran on their real holders in `sect_fight.py` (`--gap 0`, `--gap 1`, and targeted evade probe).
- **Early promotions:** `0`.
- **Open items:**
  - Serial merge & export (`stage6_merge.py`, `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py`) to close `techniques`, `arts_new`, `items`, `sets`, `effects`, and the 2 structured `events` (`N-tran_sa-01`, `N-tran_sa-02`).

---

## A. Auto-accepted decisions (with reasons)

1. **Technique bonuses, passives, and unlock layers:**
   - `sand-wall-primer` (tier 0): `bonuses: []`, passives `defense_pct 3`, `block_rating 6`, `khi_huyet_pct 4` (`7.8 W` of `8.0 W`), `hold-the-line` at layer `1`.
   - `sand-holding-sabre-canon` (tier 1): `bonuses: [defense_pct 10]`, passives `block_rating 10`, `attack_pct 6 [physical]`, `stack_duration_pct 15 [tho, debuff]`, `status_duration_pct 10 [curse]` (`14.8 W` of `16.0 W`), `answering-cut` at layer `1`, `hold-the-sand` at layer `2`.
   - `sword-washing-temper` (tier 1): `bonuses: [attack_pct 10]`, passives `stack_effect_pct 14 [kim, buff]`, `stack_duration_pct 15 [kim, buff]`, `pierce_pct 5`, `resist_pct 100 [physical]` (`14.7 W` of `16.0 W`), `spring-quench` at layer `1`.
   - *Reason:* Depth text names no bonuses or passives. Sizing matches same-tier Earth/Metal techniques (`mountain-heart-canon`, `star-quench-canon`, `furrow-iron-breath`) and ensures every cast holder (`vi_sa_yen` L2, `khuc_dang_ha` L1, `la_doan_cuong` L3) accesses their technique's arts.
2. **`hold-the-line` authored without a stance:** `c_art: 0.0`, `buff: [1, 8.0]`, raises `8 %` body shield on cast, and grants `dampen_taken: 12` on `always` while `own.composed >= 1`.
   - *Reason:* Keeping `c_art: 0.0` (a `ward` art, which does not reset `t_act`) lets outer guards stay Composed continuously, and omitting a stance avoids any conflict with `ho_dien_liet`'s `red-sand-sabre-primer` or other aux stances.
3. **`hold-the-sand` combined stance with `iron-hide-stance`:** Defines `hold-the-sand` (`tags: ["field"]`), `iron-hide` (matching `family-metal.json`), and `hold-the-sand-iron` (`tags: ["field"]`, `mods: {"resist": 120, "block": 35, "art_speed": 0}`, `suppress: ["shatter-edge-cleave"]`), tracks `sand_ring_up` to re-merge `iron-hide` into `hold-the-sand-iron` on `pulse`, and duplicates `iron-hide-temper` (`was_hit`, `per_pulse: 2`, `+1 Metal buff 8 s`) when `own.state.hold-the-sand-iron == 1`.
   - *Reason:* `vien_co_yen` and `ninh_ha_vien` both slot `sand-holding-sabre-canon` and `iron-hide-manual`. Without the combined stance and duplicated `was_hit` trigger, `iron-hide-stance` (`aux`) and `hold-the-sand` (`main`) would overwrite each other's single stance slot and mask `iron-hide-temper`.
4. **`hold-the-sand` non-spatial "charges stopped":** Each pulse while `own.field_up >= 1` lays `1` Earth debuff (`6 s`) and `1` `slowed_time` (`2 s`, uncapped), and when `foe.pressing >= 1` or `own.foe_pressed >= 1`, delays the foe's next ready art by `0.4 s` (`timer {side: "foe", which: "next", by: 0.4}`).
   - *Reason:* Non-spatial combat models "charges" via `foe.pressing` / `own.foe_pressed` (Combat rule 25) and `Slowed Time` + `timer` delay without adding a new engine word.
5. **`answering-cut` via `empower` on `blocked` (`event.amount > 0`):** Arms `answering_guard = 1` on `blocked` (`event.amount > 0`), and `empower` consumes `answering_guard` for `c_mult: 1.5` (`2.4 c`) and `off_guard` (`dur: 2`).
   - *Reason:* Expresses "deals extra Physical damage and breaks the attacker's guard" cleanly in both engines with `off_guard` and native `empower` `pay`.
6. **`spring-quench` unique ID and temper-stack model:** Renamed ID from `quench` (`part-a.json` already owns `quench`) to `spring-quench`. Placed `sword-washing-temper`'s hit-taken skin hardening (`was_hit`, `event.amount > 0`, `per_pulse: 2`, `+1 Earth buff 8 s`) and hit-landed weapon tempering (`hit_landed`, `not_art_id: "spring-quench"`, `per_pulse: 3`, `+1 Metal buff 10 s`) directly in `spring-quench`'s `effects`; firing `spring-quench` consumes all own Metal buff stacks (`+15 %` `dmg_more` per stack on `spring-quench`) and arms `pen 150` (`art_id: "spring-quench"`), `pierce 35`, and `bypass: 0.25`.
   - *Reason:* `ts-quench-hammer` already scopes `stack_effect_pct 14` to `["kim", "buff"]` ("temper stacks"), so weapon temper stacks are Metal buffs; keeping `effects` on `spring-quench` preserves `depth_gap.py`'s `effects: 2` count and lets every `sword-washing-temper` holder run it cleanly.
7. **`Smoke on the Road` `approx` and `The Rider Comes In` scope:** `Smoke on the Road` grants `acc: 100` on `always` while `smoke_road >= 1` (`was_hit` with `own.field_up >= 1` and `event.amount > 0`, cleared on `hit_landed` `art_id: "answering-cut"`). `The Rider Comes In` checks `foe.debuff.earth >= 1` or `foe.status.slowed_time >= 1` for "a slowed foe" and scopes `+0.25 dmg_more` to `art_id: "answering-cut"`. All 3 signature items carry `unique: true`, `sources: ["npc"]`, and the R6 `exception` mark (`phi_kiem`, `an`, `thuan`).
   - *Reason:* Both engines read `acc` without art context (`engine.py:1285`), so `acc +100` holds until `Answering Cut` lands rather than filtering `acc`; marked `approx`.

---

## B. Pending words

None (`0` pending words; no `pending.json`).

---

## C. Techniques (`design/stage6-staging/tran_sa/techniques/catalogue-sect-tran_sa.json`)

| Technique | Tier, kind | Bonuses (new) | Passives (new, unpriced) | Arts (unlock layer) |
|---|---|---|---|---|
| `sand-wall-primer` | Yellow (0) main, `tho` | none | `defense_pct` 3, `block_rating` 6, `khi_huyet_pct` 4 (`7.8 W` of `8`) | `hold-the-line` (1) |
| `sand-holding-sabre-canon` | Profound (1) main, `tho` + `kim` | `defense_pct` 10 | `block_rating` 10, `attack_pct` 6 `[physical]`, `stack_duration_pct` 15 `[tho, debuff]`, `status_duration_pct` 10 `[curse]` (`14.8 W` of `16`) | `answering-cut` (1), `hold-the-sand` (2) |
| `sword-washing-temper` | Profound (1) secret, `kim` + `tho` | `attack_pct` 10 | `stack_effect_pct` 14 `[kim, buff]`, `stack_duration_pct` 15 `[kim, buff]`, `pierce_pct` 5, `resist_pct` 100 `[physical]` (`14.7 W` of `16`) | `spring-quench` (1) |

---

## D. Arts (`design/stage6-staging/tran_sa/arts/part-sect-tran_sa.json`)

| Art | Depth concept | Engine form | Deviation |
|---|---|---|---|
| `hold-the-line` | A guard: the holder takes less damage while the holder stays Composed | Earth `ward` (`c_art 0.0`, `cost_share 0.03`, `cooldown 5.0`, `buff [1, 8.0]`), `8 %` body shield on cast, `always` (`own.composed >= 1`) `dampen_taken 12` | None |
| `hold-the-sand` | Lays a ring of heavy sand (a Field): while up, foe is slowed and its charges stopped | Earth `control` (`c_art 0.0`, `cost_share 0.04`, `cooldown 5.0`, `guards: [own.field_up < 1]`), Field stance (`hold-the-sand` / combined `hold-the-sand-iron`), pulse +1 Earth debuff (`6 s`), +1 `slowed_time` (`2 s`), +0.4 s `timer` `next` delay if `foe.pressing` or `own.foe_pressed` | None (combined stance + non-spatial Pressing reading per Combat rule 25) |
| `answering-cut` | Counter: after blocking a hit, next sabre cut deals extra Physical damage and breaks attacker's guard | Metal `damage` `phys` (`c_art 1.6`, `cost_share 0.04`, `cooldown 4.0`, `tags: ["metal", "sword", "sabre", "counter"]`); `blocked` (`event.amount > 0`) arms `answering_guard`; `empower` adds `c_mult 1.5` (`2.4`) and `off_guard` (`2 s`) | None |
| `spring-quench` | Consumes temper stacks for one heavy Metal cut that pierces armour (plus hit-taken skin hardening / hit-landed temper stacks) | Metal `damage` `phys` (`c_art 1.8`, `cost_share 0.05`, `cooldown 5.0`, `bypass 0.25`); `was_hit` -> +1 Earth buff (`8 s`); `hit_landed` (`not_art_id: "spring-quench"`) -> +1 Metal buff (`10 s`); `art_fired` consumes all Metal buffs (`+15 %` `dmg_more` per stack) + `pen 150` + `pierce 35` | ID `spring-quench` (`quench` exists in `part-a.json`); technique's tempering triggers placed on the art itself |

---

## E. Effects (`design/stage6-staging/tran_sa/effects/tran_sa.effects.json`)

| Effect (source) | Depth rule | Engine form | Deviation |
|---|---|---|---|
| `Smoke on the Road` (`ts-lone-smoke-sabre`) | While your Hold the Sand ring (a Field) is up, when you are struck, your next Answering Cut against that attacker cannot miss | `was_hit` (`own.field_up >= 1`, `event.amount > 0`): `smoke_road = 1`; `always` (`smoke_road >= 1`): `acc +100`; `hit_landed` (`art_id: "answering-cut"`): `smoke_road = 0` | `approx`: `acc` has no art filter in either engine, so `+100 acc` holds from `was_hit` until `Answering Cut` lands |
| `The Rider Comes In` (`ts-fathers-road`) | After you block, the attacker gains an Earth slow stack, and your next counter-cut deals 25 % more to a slowed foe | `blocked` (`event.amount > 0`): +1 Earth debuff (`8 s`) on foe + `rider_counter_cut = 1`; `always` (`rider_counter_cut >= 1` and (`foe.debuff.earth >= 1` or `foe.status.slowed_time >= 1`)): `dmg_more 0.25` (`art_id: "answering-cut"`); cleared on `hit_landed`/`was_evaded` (`art_id: "answering-cut"`) | None |

---

## F. Items & sets (`design/stage6-staging/tran_sa/items/`)

- **3 items** (`catalogue-sect-tran_sa.json`), modifiers unchanged, `sources: ["npc"]`, `unique: true`, `arts: []`, `Smoke on the Road` named in plain English:
  - R6 `exception` on all 3: `ts-lone-smoke-sabre` (`phi_kiem`), `ts-quench-hammer` (`an`), `ts-caravan-shield` (`thuan`).
- **1 set** (`sets-tran_sa.json`): `ts-fathers-road` (2 pieces, `vien_co_yen`), full-set Effect `The Rider Comes In (Kỵ Tự Lai)`.

---

## G. Holder check (`sect_fight.py tran_sa`, 5 seeds)

### Linters (`DEPTH_STAGE=design/stage6-staging/tran_sa`)
- `lint_arts.py`: `4` arts, `0` findings.
- `lint_techniques.py`: `3` techniques (`7.8 / 8`, `14.8 / 16`, `14.7 / 16`), `0` findings.
- `lint_items.py`: `3` items (`3 of 3` unique), `0` findings.
- Standalone `engine.validate()` on `tran_sa.effects.json`: `2/2` passed.

### `sect_fight.py tran_sa --seeds 5 --gap 0` and `--gap 1`

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effect runs (gap 0 / gap 1) |
|---|---|---|---|---|---|
| `vien_co_yen` | `truc_co` | `answering-cut`, `hold-the-sand`, `iron-hide-stance` | `31.2 s`, `5/5`, `98%` | `21.3 s`, `0/5`, `0%` | `Smoke on the Road`: `21 / 107`; `The Rider Comes In`: `208 / 153` |
| `tong_thoi_kim` | `ket_dan` | `spring-quench`, `answering-cut`, `hold-the-sand` | `36.2 s`, `5/5`, `74%` | `14.0 s`, `0/5`, `0%` | n/a (art counts: `consume 70`, `skin 221`, `temper 225`) |
| `bang_tran_nhac` | `truc_co` | `answering-cut`, `hold-the-sand` | `57.4 s`, `5/5`, `28%` | `8.9 s`, `0/5`, `0%` | n/a |
| `nhiep_co_dang` | `truc_co` | `answering-cut`, `hold-the-sand` | `57.4 s`, `5/5`, `28%` | `8.9 s`, `0/5`, `0%` | n/a |
| `ninh_ha_vien` | `truc_co` | `answering-cut`, `hold-the-sand`, `iron-hide-stance` | `37.6 s`, `5/5`, `86%` | `14.2 s`, `0/5`, `0%` | n/a (`hold-the-sand-iron-temper 181`) |
| `la_doan_cuong` | `truc_co` | `answering-cut`, `hold-the-sand`, `spring-quench` | `34.8 s`, `5/5`, `70%` | `12.9 s`, `0/5`, `0%` | n/a |
| `vo_kinh_son` | `truc_co` | `answering-cut`, `hold-the-sand` | `57.4 s`, `5/5`, `28%` | `8.9 s`, `0/5`, `0%` | n/a |
| `vi_sa_yen` | `luyen_khi` | `answering-cut`, `hold-the-sand` | `51.4 s`, `5/5`, `31%` | `8.6 s`, `0/5`, `0%` | n/a |
| `vien_tieu_yen` | `luyen_khi` | `answering-cut`, `hold-the-sand` | `51.4 s`, `5/5`, `31%` | `8.6 s`, `0/5`, `0%` | n/a |
| `nghiem_sa_lo` | `luyen_khi` | `answering-cut`, `hold-the-sand` | `51.4 s`, `5/5`, `31%` | `8.6 s`, `0/5`, `0%` | n/a |
| `o_sa_ho` | `luyen_khi` | `hold-the-line` | `64.6 s`, `2/5`, `3%` | `10.4 s`, `0/5`, `0%` | n/a |
| `me_tieu_chuy` | `luyen_khi` | `hold-the-line` | `64.6 s`, `1/5`, `3%` | `10.2 s`, `0/5`, `0%` | n/a (`hold-the-line-shield 58`) |
| `la_tinh_nhi` | `luyen_khi` | `hold-the-line` | `64.6 s`, `1/5`, `3%` | `10.2 s`, `0/5`, `0%` | n/a |
| `khuc_dang_ha` | `luyen_khi` | `hold-the-line` | `64.6 s`, `1/5`, `3%` | `10.2 s`, `0/5`, `0%` | n/a |
| `cam_diem_nhi` | `luyen_khi` | `hold-the-line` | `64.6 s`, `1/5`, `3%` | `10.2 s`, `0/5`, `0%` | n/a |
| `cam_thiet_binh` | `luyen_khi` | `hold-the-line` | `64.6 s`, `1/5`, `3%` | `10.2 s`, `0/5`, `0%` | n/a |
| `dam_tri_ma` | `luyen_khi` | `hold-the-line` | `64.6 s`, `1/5`, `3%` | `10.4 s`, `0/5`, `0%` | n/a |

### Targeted probes
- **`vien_co_yen` vs evading foe (`evade_pct: 30`, 5 seeds):** `37.6 s` (`5/5`, `96.7%`) with `Smoke on the Road` vs `44.2 s` (`5/5`, `96.1%`) without (`acc +100` prevents `Answering Cut` misses).
- **`me_tieu_chuy` `hold-the-line-composed` without-probe (5 seeds):** `64.6 s` (`1/5`, `3 draws`, `2.7%`) with vs `50.4 s` (`0/5`, `5 losses`, `0%`) without.
- **`tong_thoi_kim` `spring-quench-dmg` without-probe (5 seeds):** `36.2 s` (`5/5`, `73.6%`) with vs `42.0 s` (`5/5`, `67.8%`) without.
- **`ho_dien_liet` (`loose-north`, cross-owner `sand-wall-primer`, 5 seeds):** `['cut-the-horse', 'hold-the-line']`, `62.6 s`, `3/5` wins, `1` loss, `1` draw, `10.2%` health left.
