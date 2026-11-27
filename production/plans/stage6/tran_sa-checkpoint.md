# Trấn Sa Đường (`tran_sa`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/tran_sa/` against `design/world/depth/sects/tran_sa.*`, `tran_sa.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `tools/design/combat_sim/engine.py`, and `src/gameplay/combat/fight/`.

---

## 1. Ranked Findings

1. **MUST-FIX — `design/stage6-staging/tran_sa/arts/part-sect-tran_sa.json` :: `hold-the-sand.guards` (`vien_co_yen`, `ninh_ha_vien` re-casting)**
   - **What was wrong:** `hold-the-sand` guarded only on `own.field_up < 1`. On `vien_co_yen` and `ninh_ha_vien` (who also slot `iron-hide-stance`), whenever `iron-hide-stance` fired and set `state = "iron-hide"` (which has no `"field"` tag), `own.field_up` dropped to `0` until the next `pulse` merged it into `hold-the-sand-iron`. Whenever `hold-the-sand` came off cooldown during that window, it saw `own.field_up < 1` and re-fired (`4.6` fires/fight on `vien_co_yen`, `5.6` fires/fight on `ninh_ha_vien`), wasting `17.36` linh lực per extra cast even though `sand_ring_up` was already `1` and its rule says `"stays up for the fight"`.
   - **Fix applied:** Added `{"read": "own.counter.sand_ring_up", "op": "<", "value": 1}` alongside `{"read": "own.field_up", "op": "<", "value": 1}` in `hold-the-sand.guards`. Now `hold-the-sand` fires `1.0` time per fight on all `10` holders.

2. **MUST-FIX — `design/stage6-staging/tran_sa/arts/part-sect-tran_sa.json` :: `hold-the-sand` + `iron-hide-stance` stance masking & toggle (`vien_co_yen`, `ninh_ha_vien`)**
   - **What was wrong:** `hold-the-sand` only re-merged `iron-hide` into `hold-the-sand-iron` on `pulse`. Because `iron-hide-toggle` (`design/arts/family-metal.json`) fires on `art_fired` (`{"state": {"set": "iron-hide", "toggle": true}}`) after `hold-the-sand`'s listeners:
     1. Every `6 s` when `iron-hide-stance` fired, `s.state` sat in `"iron-hide"` (`own.field_up == 0`) for `0.3–1.0 s` until the next `pulse`, masking `Smoke on the Road` (`if: own.field_up >= 1` on `was_hit`: `vien_co_yen` only ran `Smoke on the Road` `21` times across `5` gap-0 seeds before the fix).
     2. On the 2nd cast of `iron-hide-stance` while in `hold-the-sand-iron`, `iron-hide-toggle` saw `s.state != "iron-hide"` and never toggled Iron Hide OFF.
   - **Fix applied:** Added `hold-the-sand-leave-iron` (`on: "art_fired"`, `filter: {"art_id": "iron-hide-stance"}`, `if: own.state.hold-the-sand-iron >= 1` -> `set: "iron-hide"` so `iron-hide-toggle` toggles it to `null`), immediate sync listeners `hold-the-sand-sync-iron-hit`/`miss` and `hold-the-sand-sync-plain-hit`/`miss` (`on: "hit_landed"` and `"was_evaded"`, `filter: {"art_id": "iron-hide-stance"}`, which resolve at the exact same millisecond as `art_fired`), and `hold-the-sand-restore` (`on: "pulse"`, `if: sand_ring_up >= 1, own.state.any < 1` -> `set: "hold-the-sand"` as decoy fallback). Verified in `plog` traces for `vien_co_yen` and `ninh_ha_vien`: `field_up` never drops to `0`, `iron-hide` toggles ON (`hold-the-sand-iron`) and OFF (`hold-the-sand`) cleanly every `6 s`, `Smoke on the Road` gap-0 runs rose from `21` to `62`, and `iron-hide-temper` never fires alongside `hold-the-sand-iron-temper` (`0` double-triggers).

3. **NIT (informational, no edit) — `spring-quench` :: `spring-quench-pierce` unscoped `pierce: 35`**
   - `spring-quench-pierce` (`on: "always"`, `if: own.counter.spring_quench_pierce >= 1`) applies `pierce: 35` without `"art_id": "spring-quench"` because both engines read `"pierce"` with `ctx = None` (`engine.py:1327`, `fight.gd:1275`), and `spring_quench_pierce` is cleared immediately on `hit_landed` / `was_evaded` (`art_id: "spring-quench"`). (Only if `spring-quench` struck a decoy—which emits neither `hit_landed` nor `was_evaded`—would the counter wait until the next `spring-quench` hit.) Behaviour is clean and faithful.

---

## 2. Specific Audits & Parity Verification

- **Techniques (`catalogue-sect-tran_sa.json`):**
  - `sand-wall-primer` (`tier: 0`, `main`, `tho`, `layers: 6`, `bonuses: []`, passives `7.8 W of 8`, `hold-the-line` @ L1), `sand-holding-sabre-canon` (`tier: 1`, `main`, `tho`/`kim`, `layers: 9`, `bonuses: [defense_pct 10]`, passives `14.8 W of 16`, `answering-cut` @ L1, `hold-the-sand` @ L2), and `sword-washing-temper` (`tier: 1`, `secret`, `kim`/`tho`, `layers: 9`, `bonuses: [attack_pct 10]`, passives `14.7 W of 16`, `spring-quench` @ L1) match `tran_sa.techniques.json`, tier bonus/W sizing, and every holder's learnt layer.
  - Cross-owner ref `ho_dien_liet` (`loose-north`, `red-sand-sabre-primer` + `sand-wall-primer` L6): verified `['cut-the-horse', 'hold-the-line']`, `62.6 s`, `3/5` wins, `10.2%` HP left (`fires: [13.0, 11.0]`); `hold-the-line` has no stance and `cut-the-horse` has no stance (`0` conflicts).
- **Arts (`part-sect-tran_sa.json`):**
  - `hold-the-line`: `c_art: 0.0` `ward` (`buff: [1, 8.0]`, `8%` body shield, `always` `own.composed >= 1` -> `dampen_taken: 12`); `me_tieu_chuy` without-probe `64.6 s` (`1/5`, `2.7%`) with vs `50.4 s` (`0/5`, `0.0%`) without.
  - `hold-the-sand`: combined stance `hold-the-sand-iron` + duplicated `hold-the-sand-iron-temper` (`was_hit`, `per_pulse: 2`, `own.state.hold-the-sand-iron == 1`) verified on `vien_co_yen` and `ninh_ha_vien` with `0` stance masking and `0` double-triggering; `slowed_time` has no `cap: 1` override; `timer {side: "foe", which: "next", by: 0.4}` matches the rule text ("its next ready art is delayed by 0.4 s").
  - `answering-cut`: `blocked` (`event.amount > 0`) arms `answering_guard = 1`; `empower` consumes it for `c_mult: 1.5` (`c: 2.4`) and `off_guard` (`dur: 2`).
  - `spring-quench`: unique ID `spring-quench` (`quench` owned by `part-a.json`); `was_hit` (`event.amount > 0`, `per_pulse: 2`) -> +1 Earth buff `8 s`; `hit_landed` (`not_art_id: "spring-quench"`, `per_pulse: 3`) -> +1 Metal buff `10 s`; `art_fired` consumes all Metal buffs (`+15% dmg_more` per stack on `spring-quench`) + arms `pen 150` (`art_id: "spring-quench"`) & `pierce 35` + `bypass: 0.25`; cleared on `hit_landed`/`was_evaded`; `tong_thoi_kim` without-probe `36.2 s` (`5/5`, `73.6%`) with vs `42.0 s` (`5/5`, `67.8%`) without.
- **Effects (`tran_sa.effects.json`), items (`catalogue-sect-tran_sa.json`), set (`sets-tran_sa.json`):**
  - `Smoke on the Road` (`ts-lone-smoke-sabre`): standalone `E.validate()` passes (`counters: ["smoke_road"]`); `was_hit` (`own.field_up >= 1`, `event.amount > 0`) -> `smoke_road = 1`; `always` `acc +100`; cleared on `hit_landed` (`art_id: "answering-cut"`). `approx` accurately logs that `acc` is read without art context in `engine.py:1285` and `fight.gd:1643`. Probe (`vien_co_yen` vs `evade_pct: 30`, 5 seeds): `35.2 s` (`5/5`, `95.2%`) with vs `42.6 s` (`5/5`, `92.9%`) without.
  - `The Rider Comes In` (`ts-fathers-road`): standalone `E.validate()` passes (`counters: ["rider_counter_cut"]`); `blocked` (`event.amount > 0`) -> +1 Earth debuff `8 s` on foe + `rider_counter_cut = 1`; `always` (`rider_counter_cut >= 1` and (`foe.debuff.earth >= 1` or `foe.status.slowed_time >= 1`)) -> `dmg_more: 0.25` (`art_id: "answering-cut"`); cleared on `hit_landed`/`was_evaded`.
  - All `3` items match `tran_sa.items.json` modifiers verbatim, carry `sources: ["npc"]`, `unique: true`, `arts: []`, and the R6 `exception`. `sets-tran_sa.json` matches `sets-bang_tam.json` schema.
- **Checklist, collisions & spatial check:**
  - `0` multi-`mod` clobbers without `"stack": true`; `0` `temp_mods` filtering by `"art_id"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`; `0` `each_for` + `cap: 1` `set: 1` refresh bugs.
  - `0` ID or Effect-name collisions against `assets/data/combat_effects.json`, committed `design/`, or other staged directories.
  - `spatial_words_check.py --sect tran_sa`: `1` `soft` hit (`tran_sa.techniques.json :: sand-wall-primer :: techniques.concept :: beside`), `0` non-soft hits in `tran_sa`.
  - `0` stand-ins, `0` beasts across `17` living `tran_sa` cast members (`10` in `tran_sa.cast.json`, `7` in `tran_sa.5.cast.json`).

---

## 3. Pending Words

None (`pending.json` absent; `0` pending words).

---

## 4. Holder Table (after final edits)

### Linters (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\tran_sa`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`sand-wall-primer`: `7.8 W of 8`, `sand-holding-sabre-canon`: `14.8 W of 16`, `sword-washing-temper`: `14.7 W of 16`).
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings` (`3 of 3` unique, R6 `exception` on all `3`).

### `sect_fight.py tran_sa --seeds 5` (`--gap 0` and `--gap 1`, `0` `REFUSED`)

| Holder | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (gap 0 with vs without, runs; gap 1 runs) |
|---|---|---|---|---|---|
| `vien_co_yen` | `truc_co` | `answering-cut` (8.4), `hold-the-sand` (1.0), `iron-hide-stance` (5.4) | `33.6 s`, `5/5`, `96%` | `19.2 s`, `0/5`, `0%` | `Smoke on the Road`: `33.6 s 96%` vs `33.6 s 96%` (`62` / `105`); `The Rider Comes In`: `33.6 s 96%` vs `37.4 s 94%` (`223` / `143`) |
| `tong_thoi_kim` | `ket_dan` | `spring-quench` (7.0), `answering-cut` (8.8), `hold-the-sand` (1.0) | `36.2 s`, `5/5`, `74%` | `14.0 s`, `0/5`, `0%` | — |
| `la_doan_cuong` | `truc_co` | `answering-cut` (8.4), `hold-the-sand` (1.0), `spring-quench` (6.8) | `34.8 s`, `5/5`, `70%` | `12.9 s`, `0/5`, `0%` | — |
| `ninh_ha_vien` | `truc_co` | `answering-cut` (9.6), `hold-the-sand` (1.0), `iron-hide-stance` (6.2) | `39.4 s`, `5/5`, `75%` | `14.2 s`, `0/5`, `0%` | — |
| `bang_tran_nhac`, `nhiep_co_dang`, `vo_kinh_son` (3 inner) | `truc_co` | `answering-cut` (14.2), `hold-the-sand` (1.0) | `57.4 s`, `5/5`, `28%` | `8.9 s`, `0/5`, `0%` | — |
| `vi_sa_yen`, `vien_tieu_yen`, `nghiem_sa_lo` (3 inner) | `luyen_khi` | `answering-cut` (12.8), `hold-the-sand` (1.0) | `51.4 s`, `5/5`, `31%` | `8.6 s`, `0/5`, `0%` | — |
| `o_sa_ho`, `dam_tri_ma` (2 outer) | `luyen_khi` | `hold-the-line` (11.6) | `64.6 s`, `2/5`, `3%` | `10.4 s`, `0/5`, `0%` | — |
| `me_tieu_chuy`, `la_tinh_nhi`, `khuc_dang_ha`, `cam_diem_nhi`, `cam_thiet_binh` (5 outer) | `luyen_khi` | `hold-the-line` (11.6) | `64.6 s`, `1/5`, `3%` | `10.2 s`, `0/5`, `0%` | — |

CHECKPOINT DONE
