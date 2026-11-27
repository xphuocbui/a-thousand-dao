# Chân Kim Các (`chan_kim`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/chan_kim/` against `design/world/depth/sects/chan_kim.*`, `chan_kim.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **MUST-FIX — `design/stage6-staging/chan_kim/effects/chan_kim.effects.json` :: `Tried and Stamped` (`eff:Tried and Stamped burn`)**
   - **What was wrong:** The rule states `"a foe your art hits while it carries a buff is stamped for 6 s; the next buff it gains burns off at once, and you gain a ward worth 5 % of your health."` However, `eff:Tried and Stamped burn` did not clear `stamped_ttl`, so against a buff-refreshing foe a single 6 s stamp triggered up to 6 times (burning repeatedly and granting up to 30 % HP stance ward per stamp; the record pass's own log showed 25 burns from 10 marks).
   - **Fix applied:** Added `{"counter": {"id": "stamped_ttl", "set": 0}}` to `eff:Tried and Stamped burn` so each 6 s stamp consumes itself on burn (10 burns from 11 marks in post-fix buff-foe verification). Added an `"approx"` field documenting the pulse poll for `foe.buff_elements >= 1` and the 1-per-burn `touchstone_stripped` count.

2. **SHOULD — `design/stage6-staging/chan_kim/effects/chan_kim.effects.json` & `design/stage6-staging/chan_kim/arts/part-sect-chan_kim.json` :: `True Gold Does Not Fear the Furnace`, `Nothing False Survives`, and `the-furnace-shows`**
   - **What was wrong:** `chan_kim.techniques.json` specifies `"Each buff stack you strip from the foe, and each ward share your Assay strips, restores 1.5 % of your maximum linh lực and adds one Part the Dross stack."` The staged Effect narrowed this in its `rule` to `(via Assay, Touchstone or Tried and Stamped)` and logged `Deviation: None` in `chan_kim-review.md`, silently omitting `Nothing False Survives` (`strip {n: 1}`) and `the-furnace-shows` (`strip {n: 99}`).
   - **Fix applied:**
     - Declared `{"id": "touchstone_stripped"}` on `Nothing False Survives` and added `{"counter": {"id": "touchstone_stripped", "add": 1}}` to `eff:Nothing False Survives buff` (`tech_effects` run before `items`, so `True Gold` consumes it on the next pulse).
     - Declared `{"id": "touchstone_stripped"}` on `the-furnace-shows` and added `furnace-shows-open-count` / `furnace-shows-hold-count` (gated on `foe.buff_elements >= 1` immediately before `strip {n: 99}`; `arts` run before `tech_effects`, so `True Gold` consumes `pulse` counts on the same pulse).
     - Restored `True Gold Does Not Fear the Furnace`'s `rule` text and added `"approx"` explaining that `strip` does not report exact stack count removed, so multi-stack strips (`The Furnace Shows`, `Tried and Stamped`) count 1 trigger per strip event.

3. **SHOULD — `design/stage6-staging/chan_kim/effects/chan_kim.effects.json` :: `Nothing False Survives` (`eff:Nothing False Survives ward`)**
   - **What was wrong:** `chan_kim.items.json` states `"every buff, ward or borrowed stat a foe gains while near you burns off twice as fast."` The staged record used `"ward_bill": 50` (1.5× drain, +50 %), whereas `"ward_bill": 100` gives 2× drain (`bill_up = 2.0`).
   - **Fix applied:** Raised `ward_bill` from `50` to `100` and updated `"approx"` (`tuong_bach_luyen` now clears `typical` in `20.1 s` with `81 %` HP vs `30.7 s` / `69 %` HP without).

4. **NIT — `production/plans/stage6/chan_kim-review.md` :: `--gap 1 --seeds 5` run counts & minor omissions**
   - `chan_kim-review.md` logged no deviation on `True Gold Does Not Fear the Furnace` (fixed in staged files above; `chan_kim-review.md` left untouched per brief write list).

---

## 2. Verification Summary (after final edits)

- **Stand-ins / roots / depth parity:** All 17 living cast members (`10` in `chan_kim.cast.json`, `7` in `chan_kim.5.cast.json`) use `chan_kim`'s element-free (`names: []`) methods (`0` stand-ins; `phung_xich_kim`'s aux `censer-smoke-manual` is already committed in `design/techniques/catalogue-sect-market-folk.json`). All 5 items match `chan_kim.items.json` verbatim (`unique: true`, `sources: ["npc"]`, `rarity: 5` on `ck-hundred-fold-crucible`, R6 `exception` on the 4 weapon/body_gear items).
- **Standalone Effect parity & multi-`mod` check:** Every Effect in `chan_kim.effects.json` declares every counter it reads/writes in its own `"counters"` array; no stances are set; no record has two `"mod"` actions without `"stack": true`; no `decay_per_pulse: 1` off-by-one; no `always` record with a record-level filter.
- **Uniqueness:** `0` technique, art, item, set, or Effect name collisions across committed `design/`, `assets/data/combat_effects.json`, and staged `b03` directories.
- **Linters (`DEPTH_STAGE=design/stage6-staging/chan_kim`):**
  - `lint_techniques.py`: `checked 3 techniques, 0 findings` (`touchstone-primer` 8.0 W of 8, `true-gold-canon` 14.2 W of 16, `hundred-refinings-art` 14.2 W of 16).
  - `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
  - `lint_items.py`: `checked 5 items, 22 bases, 9 common arts, 0 findings`.
- **Supplemental buffing-foe check (`tuong_bach_luyen` vs `ket_dan` `typical` + `feed-the-fire` + `packed-earth-stance`, 5 seeds):** `18.5 s`, `5/5` wins, `94 %` HP left; `eff:Tried and Stamped mark`: 11, `eff:Tried and Stamped burn`: 10, `eff:Nothing False Survives buff`: 15, `eff:Touchstone`: 11, `furnace-shows-open-count`: 5, `furnace-shows-hold-count`: 6, `eff:True Gold Does Not Fear the Furnace assay`: 10, `eff:True Gold Does Not Fear the Furnace strip`: 36.

---

## 3. Pending Words

None (`pending.json` not needed; all mechanics expressible cleanly with existing engine words).

---

## 4. Holder Table (after fixes)

### `sect_fight.py chan_kim --seeds 5` (`0` REFUSED, all `17` living holders)

| Holder | Realm | Arts (fires/fight) | Mean s | Wins | HP left | Effects (with vs without, runs) |
|---|---|---|---|---|---|---|
| `tuong_bach_luyen` | `ket_dan` | `assay` (3.8), `the-furnace-shows` (2.6), `part-the-dross` (5.6) | 20.1 | 5 | 81% | `True Gold Does Not Fear the Furnace`: 20.1s 81% vs 20.1s 81% (11); `Nothing False Survives`: 20.1s 81% vs 30.7s 69% (`always` `ward_bill` live; buff strip 0 vs buffless `typical`, 15 vs buffing foe); `Touchstone`: 0 (`typical` has no buffs; 11 vs buffing foe); `Tried and Stamped`: 0 (`typical` has no buffs; 11 marks / 10 burns vs buffing foe) |
| `tuong_ngoc_can` | `truc_co` | `assay` (7.8), `the-furnace-shows` (5.2) | 39.4 | 5 | 34% | `True Gold Does Not Fear the Furnace`: 39.4s 34% vs 39.6s 33% (29); `A Hair Light`: 39.4s 34% vs 41.2s 27% (23); `A Second Lean`: 39.4s 34% vs 42.8s 23% (15) |
| `phung_xich_kim` | `truc_co` | `assay` (4.8), `the-furnace-shows` (3.8), `part-the-dross` (7.6), `pill-smoke` (3.8) | 27.0 | 5 | 62% | `True Gold Does Not Fear the Furnace`: 27.0s 62% vs 29.2s 57% (20) |
| `on_song_ngoc`, `tuong_tri_chuan`, `duong_noan_ha` | `truc_co` | `assay` (9.0), `the-furnace-shows` (6.4) | 48.0 | 5 | 14% | `True Gold Does Not Fear the Furnace`: 48.0s 14% vs 48.0s 7% (30) |
| `la_minh_nhan` | `truc_co` | `assay` (9.0), `the-furnace-shows` (5.6) | 48.0 | 2 | 7% | — (L3, below L4 passive) |
| `cu_tieu_hanh`, `tien_phan_vi`, `khuong_tieu_kim`, `luong_diem_chi` | `luyen_khi` | `assay` (7.0), `the-furnace-shows` (4.0) | 43.0 | 2 | 2% | — (L2–L3) |
| `nghiem_bac_sinh`, `nghiem_tuyet_ngan`, `on_bich_lien`, `on_tieu_kieu`, `quan_thap_thu` | `luyen_khi` | `streak-on-the-stone` (10.4) | 35.2 | 0 | 0% | — |

### `sect_fight.py chan_kim --gap 1 --seeds 5`

- `0` `REFUSED`; all 17 holders load and fire every slotted art (`1.0–2.0` times).
- `tuong_bach_luyen`: `11.8 s`, `0` wins, `True Gold Does Not Fear the Furnace` (6 runs); `tuong_ngoc_can`: `10.0 s`, `0` wins, `True Gold` (5 runs), `A Hair Light` (23 runs), `A Second Lean` (15 runs); `phung_xich_kim`: `8.8 s`, `0` wins, `True Gold` (5 runs); `on_song_ngoc` / `tuong_tri_chuan` / `duong_noan_ha`: `8.0 s`, `0` wins, `True Gold` (5 runs).

CHECKPOINT DONE
