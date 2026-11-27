# Hàm Nguyệt Trang (`ham_nguyet`): Stage 6 Checkpoint Review

Unanchored checkpoint review of `design/stage6-staging/ham_nguyet/` against `design/world/depth/sects/ham_nguyet.*`, `ham_nguyet.md`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked Findings

1. **MUST-FIX — `design/stage6-staging/ham_nguyet/arts/part-sect-ham_nguyet.json` :: `empty-lungs` (`empty-lungs-immune`)**
   - **What was wrong:** `empty-lungs-immune` used `on: "art_fired"` with `{"mod": {"status_immune": 1, "tags": ["heavy_breath", "silence", "sealed_meridian"], "for": 5}}`. In both engines (`tools/design/combat_sim/engine.py` line 1638 and `src/gameplay/combat/fight/fight.gd` line 1488), `apply_status` queries `mod(target, "status_immune", {"status": sid})` with no `"tags"` key in the context, and `temp_mods` in both engines drops `"status"` (keeping only `dtype`, `element`, `tags`, `kind`). As a result, `empty-lungs-immune` matched zero statuses and never blocked `heavy_breath`, `silence`, or `sealed_meridian`.
   - **Fix applied:** Added `"counters": [{"id": "empty_lungs_t", "cap": 1, "each_for": 5}]` to `empty-lungs`, added `{"counter": {"id": "empty_lungs_t", "add": 1}}` to `empty-lungs-hold`, and replaced `empty-lungs-immune` with three `on: "always"` records gated on `own.counter.empty_lungs_t >= 1` (`empty-lungs-immune-breath`, `empty-lungs-immune-silence`, `empty-lungs-immune-sealed`, one `"mod"` per record with `"status": "heavy_breath"`, `"silence"`, `"sealed_meridian"`). Also clarified `"against poison and curses"` to `"against statuses and curses"` in `empty-lungs.rule`. Verified via targeted engine test (`verify_fixes.py`): all three curses are blocked for 5 s and land after expiry.

2. **SHOULD — `design/stage6-staging/ham_nguyet/arts/part-sect-ham_nguyet.json` :: `the-moon-in-the-water` (`moon-water-cast`) + `False Moon`**
   - **What was wrong:** `moon-water-cast` wrote `{"counter": {"id": "refl_t", "set": 4}}` on `art_fired`, while `eff:False Moon extend` (`ham_nguyet.effects.json`) writes `{"counter": {"id": "refl_t", "add": 4}}` on `art_fired`. If `eff:False Moon extend` ever executes before `moon-water-cast` (e.g. under a different listener/compilation order), `set: 4` would overwrite the `+4` extension and silently reduce `False Moon`'s doubled 8 s duration back to 4 s.
   - **Fix applied:** Changed `{"counter": {"id": "refl_t", "set": 4}}` to `{"counter": {"id": "refl_t", "add": 4}}` in `moon-water-cast` (safe because `the-moon-in-the-water` is guarded by `own.counter.refl_up < 1` and both `moon-water-struck` and `moon-water-expire` reset `refl_t` to `0`). Verified in `verify_fixes.py` that `refl_t` reaches `8.0` even when `effects` order is reversed.

3. **NIT — `design/stage6-staging/ham_nguyet/arts/part-sect-ham_nguyet.json` :: `cast-the-pearl.hooks`**
   - **What was wrong:** `cast-the-pearl` (`element: "water"`) listed `"cold damage"` in `hooks` instead of `"water damage"`.
   - **Fix applied:** Updated `"cold damage"` to `"water damage"` in `cast-the-pearl.hooks`.

---

## 2. Specific Audits & Parity Verification

- **`wrap_stance` coexistence with `deep-lake-stance`:**
  - Confirmed `deep-lake-stance` lives in committed `design/arts/family-water.json`, toggles state `"deep-lake"`, and reads `own.state.deep-lake` directly in `lake-deepens` and `empower`. Putting `wrap-the-grain` on the fighter's single `state` slot would cause `deep-lake-stance` (toggling ~every 3 s) to overwrite `wrap-the-grain`, and changing `own.state` to a combined stance would break `deep-lake-stance`'s `own.state.deep-lake` checks. Using self-counter `wrap_stance` matches the established pattern (`ink-sediment` in `design/arts/part-sect-nhan_van.json`) and lets both `kieu_nguyet_chau` and `muc_tiem_uyen` hold both cleanly (`wrap-grain-enter`: 1.0/fight, `lake-toggle`: 12.8/fight on `kieu_nguyet_chau`).
- **`the-moon-in-the-water` / `False Moon` `refl_t` / `refl_up` decoy timers:**
  - Verified `moon-water-struck` does not filter `decoy_struck` by `kind: "art"`, which is necessary because `engine.py` / `fight.gd` spend `decoys` on any non-triggered direct hit (`art`, `basic`, `companion`); filtering `decoy_struck` by `kind: "art"` would orphan `refl_up = 1` on a basic hit.
  - Verified pulse countdown: `refl_t = 4` (or `8` with `False Moon`) decrements via `moon-water-tick` (`refl_t >= 2 -> add -1`) and expires cleanly via `moon-water-expire` (`refl_t <= 1 -> decoy -1, refl_up = 0, refl_t = 0`), yielding up to 4 s / 8 s without off-by-one decay.
- **`The Pearl Remembers` & `What Hurts You, Wrap` fight deltas:**
  - At `--gap 0` (`--seeds 5`), `kieu_nguyet_chau` beats the typical Kết Đan enemy at `100 %` HP (`34.0 s`), never falling to `<= 0.3334` HP, so both Effects show `34.0 s 100 %` with vs without (`15` `store` runs, `70` `absorb` runs).
  - At `--gap 1` (`--seeds 20` default), both Effects fire their below-1/3-HP spend/freeze clauses and extend survival (`16.8 s` vs `15.9 s`, `81` and `189` runs); removing either drops survival to `15.9 s` because `The Pearl Remembers` supplies `fist_spent = 1` (needed by `What Hurts You, Wrap` to freeze the ward) while `What Hurts You, Wrap` supplies `absorb` Nacre stacks and the 2 s `ward_fixed` freeze.
  - In a targeted mid-hard Kết Đan probe (`[180, 120, 60, 30, 0]`, 5 seeds), both Effects produce large win/HP deltas: `40.60 s, 5/5 wins, 55.9 % HP` with both (`spend hit`: 4, `freeze hit`: 4, `pearl`: 4), vs `38.00 s, 2/5 wins, 16.4 % HP` without `The Pearl Remembers`, and `40.80 s, 4/5 wins, 26.3 % HP` without `What Hurts You, Wrap`.
- **`cast-the-pearl` depth fidelity:**
  - Confirmed neither Python nor GDScript has a mechanism to persist the raw damage/coefficient of a prior foe art across hits for replay on a later active cast (`return_damage` only reads the current event's `amount`, and `fire_art` replays own arts). Authoring `cast-the-pearl` as a Pearl-gated (`own.counter.pearl >= 1`) Water strike at `c_art 2.0` (half of a typical ~4.0 heavy art, under the `2.96` ungated lint) faithfully preserves the defensive Pearl-condensing engine and `What Hurts You, Wrap`'s 2-Ice payoff without bespoke engine plumbing for one art.
- **Standalone compilation, multi-`mod`, `temp_mods`, collisions & spatial check:**
  - `3/3` Effects (`The Pearl Remembers`, `False Moon`, `What Hurts You, Wrap`) declare all their own read/written `counters` (`states` unused) and pass `engine.validate()` + 1-seed `E.fight()` standalone.
  - `0` multi-`mod` records without `"stack": true`; `0` `temp_mods` filtering by `"art_id"`; `0` `always` records with record-level `filter`; `0` `decay_per_pulse: 1`; `0` `was_hit` damage-only checks missing `event.amount > 0` (`wrap-the-grain` intentionally triggers on any landing foe art hit, including ward-absorbed hits; `The Pearl Remembers spend hit` reads `own.hp_share <= 0.3334`).
  - `0` ID or Effect-name collisions vs `assets/data/combat_effects.json`, committed `design/`, or other staged `b04` directories.
  - `spatial_words_check.py --sect ham_nguyet`: `3` depth hits, all non-fight prose/node names (`kieu_nguyet_chau` `ties.note`: `"alone"`; `muc_tiem_uyen` `tree.intent`: `"beside"`; `lam_ham_suong` `tree.targets_note`: `"Still"` in node name `"Still Pond"`), and `0` hits in staged files.
  - All `18` living cast members fit their Water roots and sect lineage (`0` stand-ins, `0` beasts). All 4 staged items match `ham_nguyet.items.json` modifiers/grade/base/kind/holder/set identically and carry `unique: true`, `sources: ["npc"]`, and R6 `exception` on the 3 weapon/armour pieces.

---

## 3. Pending Words

None (`pending.json` absent; all 5 arts and 3 Effects run on the existing Python and GDScript engine vocabulary).

---

## 4. Holder Table (after final edits)

### Linters (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ham_nguyet`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`pearl-diver-breath` `7.6 W of 8`, `moon-holding-scripture` `23.0 W of 24`, `nacre-over-grit-canon` `15.7 W of 16`).
- `lint_arts.py`: `checked 5 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 4 items, 22 bases, 9 common arts, 0 findings` (`4 of 4` unique, R6 `exception` on `hn-tuyet-loc-fist-pearl`, `hn-nacre-robe`, `hn-frost-lotus-pin`).
- `depth_gap.py --sect ham_nguyet`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0` (only staged records + `N-ham_nguyet-01..04` open for serial merge/Stage 7).

### `sect_fight.py ham_nguyet` (`--seeds 5` at `--gap 0`, default `--seeds 20` at `--gap 1`; `0` `REFUSED`, `0` `NEVER_FIRED`, `0` `NEVER_RAN`)

| Holder | Realm | Arts (gap 0 fires) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (with vs without, runs) |
|---|---|---|---|---|---|
| `kieu_nguyet_chau` | `ket_dan` | `deep-lake-stance` (12.8), `full-pool` (5.4), `the-moon-in-the-water` (4.4), `wrap-the-grain` (1.0), `cast-the-pearl` (3.0), `seep-through-palm` (12.8) | `34.0 s`, `5/5`, `100%` | `16.8 s`, `0/20`, `0%` | `The Pearl Remembers`: gap 0 `34.0 s 100%` vs `34.0 s 100%` (`15`), gap 1 `16.8 s` vs `15.9 s` (`81`), mid-hard `40.6 s 5/5 55.9%` vs `38.0 s 2/5 16.4%`; `What Hurts You, Wrap`: gap 0 `34.0 s 100%` vs `34.0 s 100%` (`70`), gap 1 `16.8 s` vs `15.9 s` (`189`), mid-hard `40.6 s 5/5 55.9%` vs `40.8 s 4/5 26.3%` |
| `muc_tiem_uyen` | `ket_dan` | `deep-lake-stance` (16.6), `full-pool` (6.4), `the-moon-in-the-water` (6.2), `wrap-the-grain` (1.0), `cast-the-pearl` (6.0) | `49.8 s`, `5/5`, `100%` | `13.7 s`, `0/20`, `0%` | `False Moon`: gap 0 `49.8 s 100%` vs `49.8 s 100%` (`31`), gap 1 `13.7 s` vs `13.5 s` (`18`) |
| `lam_ham_suong` | `truc_co` | `deep-lake-stance` (10.6), `full-pool` (4.4), `the-moon-in-the-water` (3.4), `seep-through-palm` (10.6), `marrow-to-dew` (4.4), `drag-of-the-deep` (6.4) | `28.4 s`, `5/5`, `100%` | `18.6 s`, `0/20`, `0%` | — |
| `quach_bat_tram` | `truc_co` | `deep-lake-stance` (13.6), `full-pool` (5.8), `the-moon-in-the-water` (4.8), `seep-through-palm` (13.6), `marrow-to-dew` (5.8) | `35.8 s`, `5/5`, `100%` | `14.4 s`, `0/20`, `0%` | — |
| `dam_thiem_dang` | `truc_co` | `deep-lake-stance` (13.8), `full-pool` (5.8), `the-moon-in-the-water` (4.8), `seep-through-palm` (13.8) | `36.3 s`, `5/5`, `100%` | `9.4 s`, `0/20`, `0%` | — |
| `kha_toan_chau`, `dao_nguyet_lan`, `phan_tinh_ba` (3 inner/steward) | `truc_co` | `deep-lake-stance` (17.2), `full-pool` (6.6), `the-moon-in-the-water` (6.0) | `51.8 s`, `5/5`, `99%` | `10.6 s`, `0/20`, `0%` | — |
| `nhan_bich_thuy`, `thu_anh_dam`, `vien_tiem_nhi`, `mong_loc_nhi`, `la_tu_chau`, `dinh_luu_ly` (6 inner) | `luyen_khi` | `deep-lake-stance` (16.8), `full-pool` (6.4) | `50.6 s`, `5/5`, `99%` | `8.3 s`, `0/20`, `0%` | — |
| `kieu_vong_thiem`, `mong_bach_giac`, `la_tieu_boi`, `nguy_tieu_ngu` (4 outer) | `luyen_khi` | `gathering-wave` (12.0), `empty-lungs` (7.0) | `63.0 s`, `0/5`, `0%` | `8.0 s`, `0/20`, `0%` | — |

CHECKPOINT DONE
