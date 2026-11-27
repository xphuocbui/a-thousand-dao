# Stage 6 serial step: wave `b02`

**Owners (10):** `truc_thuc`, `xuyen_lam`, `minh_loan`, `muc_van`, `nhan_van`, `phan_vu`, `vong_trieu`, `nam_pho`, `thu_phan`, `bach_vu`
**Date:** 2026-11-27

## Words built (both engines with parity)

1. **`lint-element-free-techniques`** (`vong_trieu`, `thu_phan`, `xuyen_lam`)
   - **`tools/design/arts/lint_techniques.py`:** Allows `"names": []` on `origin == "authored"` `main` and `secret` techniques when every carried ability across all layers has `element == ""`. Still rejects `"names": []` if any carried ability has a non-empty `element` (`ELEMENT`), and continues rejecting non-empty `names` on `tech_kind == "body"`.
   - **`src/gameplay/cultivation/cong_phap.gd`:** Updated `avg_purity(c, def)` so `names.is_empty()` returns `0.0` only for `tech_kind == "body"` and returns `c.linh_can.purity(c.linh_can.strongest_element())` (matching `crude()`) for element-free `main`/`secret` methods; updated `usable()` docstring accordingly. Audited `tools/design/items/export_techniques.py`, `tools/design/combat_sim/fight.py`, `tools/design/combat_sim/sect_fight.py`, `src/gameplay/combat/fight/fighter_compiler.gd`, and `src/gameplay/combat/fight/build_file_compiler.gd` (no `names == []` bugs on non-body techniques).
   - **`src/gameplay/items/item_factory.gd`:** Updated manual item summary labels in `describe()` so empty-`names` non-body manuals label `"element-free"` rather than `"body"`.

## GDD and docs updated

- **`design/gdd/cong-phap.md`:** Documented element-free authored `main` and `secret` methods (`names: []` permitted when `origin == "authored"` and every carried art has `element == ""`; usable regardless of root; cultivation speed, purity factor, and bonus scaling use `strongest_element()` purity; neutral `1.0` harmony) across rules 1, 2, 8, Formulas A & D, and Content validation.
- **`tools/design/combat_sim/FIGHT-INPUT.md`:** Added Stage 6 batch `b02` note documenting element-free `main`/`secret` methods and `strongest_element()` purity semantics.

## Tests and parity fixture

- **Python (`tools/design/combat_sim/test_engine.py`):** Added `t_lint_element_free_techniques` (authored element-free `main` and `secret` pass `lint_techniques`, `names: []` carrying an elemental ability fails, `body` with non-empty `names` fails).
- **GdUnit (`tests/unit/cultivation/cong_phap_test.gd`):**
  - Updated `test_every_authored_template_fits_its_tier` to accept `origin == "authored"` `names.is_empty()` templates whose abilities are all element-free.
  - Added `test_element_free_main_and_secret_are_usable_and_scale_with_strongest_root` covering `usable()`, `avg_purity()`, `tech_one()`, `speed_factor()`, `harmony()`, `bonus_lines()`, and `body` returning `0.0` purity.
- **Chance-free parity fixture (`tests/parity/fixtures/t28_b02_exact.json` + `tests/parity/expected/t28_b02_exact.json`, registered in `tests/parity/combat_parity_test.gd`):**
  - Side A runs *Võng Triều* (`set-the-lamp`, `line-of-lamps`, `Lamp-Ward`, `The Lamp Flares`) + *Thu Phân* (`ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`) against Side B *Xuyên Lâm* (`walk-slowly`, `who-is-afraid`, `The Long Road`, `Do Not Listen`).
  - Kept strictly RNG-free (`one-straw-cape` and `neither-wind-nor-rain` were excluded because their global `status_resist` would roll RNG against `line-of-lamps`'s guaranteed `slowed_time` / `leaking_ward` statuses and diverge between Python and GDScript PRNGs). Exact event-for-event parity: A wins at `63.000 s`, `969` rows.

## Staged records updated & `pending.json` cleanup

- **Restored `"names": []` on all 9 element-free authored `main`/`secret` techniques:**
  - `design/stage6-staging/vong_trieu/techniques/catalogue-sect-vong_trieu.json`: `lamp-ward-seal-canon`, `tide-reading-gaze`, `last-lamp-vigil`.
  - `design/stage6-staging/thu_phan/techniques/catalogue-sect-thu_phan.json`: `grave-sweeping-chant`, `autumn-grave-canon`, `jade-of-resentment-ward`.
  - `design/stage6-staging/xuyen_lam/techniques/catalogue-sect-xuyen_lam.json`: `straw-sandal-step-primer`, `calm-wind-staff-canon`, `unheeding-rain-heart-method`.
- **Deleted all `pending.json` files across `b02`:** removed `vong_trieu`, `thu_phan`, `muc_van`, `nhan_van`, and `nam_pho` `pending.json` files (verified `0` remaining across all 10 `b02` owners; the other 5 `b02` owners already had none).

## Auto-accepted decisions

1. Kept `body` techniques strict (`names == []`, `avg_purity() == 0.0` using physique factor instead of root purity) while restricting empty `names` on `main`/`secret` strictly to `origin == "authored"` techniques whose carried arts all have `element == ""`.
2. Reused `c.linh_can.strongest_element()` in `CongPhap.avg_purity()` for element-free `main`/`secret` methods so they match `crude()` and keep root purity meaningful without introducing a dummy element proxy.
3. Excluded `one-straw-cape` and `neither-wind-nor-rain` from `t28_b02_exact` Side B so the fixture stays strictly deterministic (`chance_free: true`, no `status_resist` RNG rolls on `slowed_time`/`leaking_ward`).

## Verification

- **Linters (`DEPTH_STAGE` set for `vong_trieu`, `thu_phan`, `xuyen_lam`):**
  - `lint_techniques.py`: `0 findings` on all 3 (`3` techniques each).
  - `lint_arts.py`: `0 findings` on all 3 (`6` arts in `vong_trieu`, `6` in `thu_phan`, `2` in `xuyen_lam`).
  - `lint_items.py`: `0 findings` on all 3 (`6` items each).
- **`sect_fight.py` (`DEPTH_STAGE` set, `--seeds 5 --gap 0` and `--gap 1` for `vong_trieu`, `thu_phan`, `xuyen_lam`):** `0 REFUSED` (`10/10` living `vong_trieu` holders, `18/18` `thu_phan` holders, `18/18` `xuyen_lam` holders ran).
- **`pending.json` check across all 10 `b02` owners:** `0` remaining.
- **`parity_export.py --check --quick`:** all `40` exact fixtures + `sim_defaults.json` match (`same`).
- **`test_engine.py`:** `0 failed`.
- **Godot `--headless --import --quit` + GdUnit `res://tests/parity`:** `12/12` PASSED (`2/2` suites, `0 errors`, `0 failures`, `0 orphans`).
- **GdUnit `res://tests/unit/cultivation` + `res://tests/unit/combat`:** `202/202` PASSED (`9/9` suites, `0 errors`, `0 failures`, `0 orphans`).

SERIAL DONE
