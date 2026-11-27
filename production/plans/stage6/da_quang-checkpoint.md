# Stage 6 Checkpoint Review — Dạ Quang Môn (`da_quang`)

**Date**: 2026-11-27
**Owner**: `da_quang` (Batch `b05`)
**Scope audited**:
- `design/stage6-staging/da_quang/techniques/catalogue-sect-da_quang.json` (`2` techniques)
- `design/stage6-staging/da_quang/arts/part-sect-da_quang.json` (`3` active arts)
- `design/stage6-staging/da_quang/items/catalogue-sect-da_quang.json` (`6` items) & `sets-da_quang.json` (`2` sets)
- `design/stage6-staging/da_quang/effects/da_quang.effects.json` (`4` Effects)
- `design/world/depth/sects/da_quang.{md,techniques.json,items.json,cast.json,5.cast.json}` (`16` living, `2` dead cast records)

---

## 1. Ranked Findings

### MUST-FIX
- None (`0`).

### SHOULD
1. **`arts/part-sect-da_quang.json` — `crescent-of-red-sand` (`crescent-bleed-bonus`) — FIXED**
   - **What was wrong**: `crescent-bleed-bonus` (`on: "always"`) granted `{"mod": {"dmg_more": 0.25}}` with no hit-kind scope, while `crescent-bleed-spend` excluded `"trigger"` (e.g. `free_hit` triggers such as `debt-blade-interest` or `shear-crit`) and the rule states *"your next cut (direct art or basic hit) deals 25 % more damage"*. If an art with a `hit_landed` `free_hit` trigger is slotted before `crescent-of-red-sand` (so the trigger runs before `crescent-bleed-spend` clears `red_sand_mark`), or if a companion/trigger fires while `red_sand_mark >= 1`, the trigger or companion hit would also receive `+25 %` `dmg_more`.
   - **Fix applied**: Scoped `crescent-bleed-bonus` in `design/stage6-staging/da_quang/arts/part-sect-da_quang.json` to `{"mod": {"dmg_more": 0.25, "kind": "art"}}` and `{"mod": {"dmg_more": 0.25, "kind": "basic"}}` (safe on `on: "always"` records; mutually exclusive per hit).

2. **`effects/da_quang.effects.json` — `Wine in the Night-Glow Cup` (`eff:Wine in the Night-Glow Cup:drink_reset_broken`) — FIXED**
   - **What was wrong**: When `broken` filled the cup at once (`night_glow_cup = 5`) and triggered `drink_heal_broken` + `drink_reset_broken`, `drink_reset_broken` reset `night_glow_cup` and `cup_paid_pct` to `0` while leaving any pre-drink fractional `cup_pct` (up to `4.99 %`) intact, allowing pre-drink health payments or bleed progress to count toward the next post-drink notch while `cup_paid_pct` was `0`.
   - **Fix applied**: Added `{"counter": {"id": "cup_pct", "set": 0}}` to `eff:Wine in the Night-Glow Cup:drink_reset_broken` in `design/stage6-staging/da_quang/effects/da_quang.effects.json`.

### NIT / Verified Observations
- **`First and Often` (`eff:First and Often:free_hp`)**: Uses `{"hp_cost_red": 1, "element": "fire", "kind": "art"}` without a `"sabre"` tag filter, which waives `pay-in-blood`'s `4 %` up-front `hp_cost` if cast before the 3rd Fire cut lands (seen on `do_xich_linh` at `7.03 s`). Keeping `element: "fire", kind: "art"` is intentional so `Red Band` works for non-`da_quang` Fire attack arts (no other Fire arts in `design/arts/` carry `"sabre"`), while `first3` and `mark_after` gate on `hit_landed` (`per_firing: 1`) so `pay-in-blood` never consumes a Fire-cut charge.
- **`Wine in the Night-Glow Cup:bleed` approximation**: Bleed tick fill is fixed at `+2.0 %` health per damaging `bleed` tick (`approx`) rather than raw `event.amount / hp_max`. Verified in `ket_dan` / `truc_co` traces (`0.25–0.33 %` `own_hp` warded at 2 stacks, `1.5–4.2 %` `own_hp` unwarded at 2–5 stacks).
- **`art_cost_hp: 900` on `pay-in-blood` and `Drink After the Raid`**: Shifts `90 %` of linh lực cost to health (`pay_keep_health`-safe, avoiding lethal `blood_cast` self-kills), matching the documented deviation.
- **`lint-bleed-scope` (deferred to `s6-serial-b05`)**: `night-glow-blood-sabre-canon` stages temporary `over_time`/`hoa` proxies on its two `b11` `bleed` passives; `tools/design/arts/lint_techniques.py` was left untouched as instructed.

---

## 2. Pending Words Decision

- **Pending engine words (`pending.json`)**: None (`0`). All required mechanics (`hp_paid_share`, `tick_dealt` + `status: "bleed"`, `broken`, `next_art_cost`, `art_cost_hp`, `hp_cost_red`, `dmg_more`, `heal_taken`, `ignore_taken`, `convert`, `statuses: ["bleed"]`, `technique-effects`, `not_art_id`) already exist in both engines.

---

## 3. Verification After Final Edits

All checks re-run with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\da_quang`:
- `lint_techniques.py catalogue-sect-da_quang.json`: **0 findings** (`checked 2 techniques, 0 findings`; `3.3 W / 8`, `22.9 W / 24`).
- `lint_arts.py part-sect-da_quang.json`: **0 findings** (`checked 3 arts in 1 files, 0 findings`).
- `lint_items.py catalogue-sect-da_quang.json`: **0 findings** (`checked 6 items, 22 bases, 9 common arts, 0 findings`).
- `spatial_words_check.py --sect da_quang`: **0 rule hits** (`3` soft/postponed notes in `ties.note` / `tree.intent`).
- Standalone `engine.validate` + `Fight.run()` (`test_every_library_effect_compiles`-equivalent): **4 / 4 passed** (`Wine in the Night-Glow Cup`, `Drink After the Raid`, `Cut the Horse First`, `First and Often`).
- Effect name uniqueness: **0 collisions** against `assets/data/combat_effects.json`, `design/stage6-staging/*/effects/*.effects.json`, and `design/world/depth/effects/*.effects.json`.
- `sect_fight.py da_quang --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED**.

---

## 4. Holder Table (Post-Fix, `sect_fight.py da_quang --seeds 5`)

| Holder | Realm | Arts | `--gap 0` (`mean_s`, `wins`, `hp_left`) | `--gap 1` (`mean_s`, `wins`, `hp_left`) | Effect Runs (`--gap 0` / `--gap 1`) & Notes |
|---|---|---|---|---|---|
| `hang_da_boi` | `ket_dan` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade`, `shearing-palm`, `bloodletting-rite` | `16.4 s`, `5/5`, `93%` | `8.6 s`, `0/5`, `0%` | All 5 arts fire (`3.8`, `1.2`, `5.2`, `5.2`, `1.2`). `Wine`: `234` (`93%` vs `90%` w/o) / `80`; `Drink After the Raid`: `105` / `35`; `Cut the Horse First`: `173` (`93%` vs `77%` w/o) / `73`; `Blood Casting`: `0` (`always`-only mod; `8.6 s` vs `8.8 s` at `--gap 1`). |
| `do_xich_linh` | `ket_dan` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade` | `22.9 s`, `5/5`, `54%` | `9.0 s`, `0/5`, `0%` | All 3 arts fire (`7.0`/`2.2`, `3.0`/`1.0`, `7.4`/`2.2`). `Wine`: `278` (`54%` vs `45%` w/o) / `64`; `First and Often`: `37` (`54%` vs `49%` w/o) / `11`. |
| `hang_luu_hoa`, `trac_hong_da` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade` | `26.0 s`, `5/5`, `40%` | `8.0 s`, `0/5`, `0%` | All 3 arts fire at `--gap 0` (`6.2`, `2.6`, `8.6`). `Wine`: `327` (`40%` vs `33%` w/o) / `52`. `pay-in-blood` (`cd 9.0`) is `0.0` at `--gap 1` due to `8.0 s` defeat. |
| `co_xich_nguyet` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood`, `debt-blade` | `25.2 s`, `5/5`, `33%` | `8.0 s`, `0/5`, `0%` | All 3 arts fire at `--gap 0` (`6.0`, `2.2`, `8.2`); L3 (`< L4`, no `Wine`). `pay-in-blood` `0.0` at `--gap 1` (`8.0 s` defeat). |
| `o_liet_phong` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood` | `38.6 s`, `5/5`, `22%` | `8.0 s`, `0/5`, `0%` | Both arts fire at `--gap 0` (`9.6`, `4.0`). `Wine`: `347` (`22%` vs `19%` w/o) / `32`. `pay-in-blood` `0.0` at `--gap 1` (`8.0 s` defeat). |
| `cuu_lac_nhat` | `truc_co` | `crescent-of-red-sand`, `pay-in-blood` | `38.6 s`, `5/5`, `19%` | `8.0 s`, `0/5`, `0%` | Both arts fire at `--gap 0` (`9.6`, `4.0`); L2 (`< L4`, no `Wine`). `pay-in-blood` `0.0` at `--gap 1` (`8.0 s` defeat). |
| `man_xich_cau`, `kieu_liet_ca` | `luyen_khi` | `crescent-of-red-sand` | `38.2 s`, `5/5`, `35%` | `8.0 s`, `0/5`, `0%` | `crescent-of-red-sand` fires `9.4` at `--gap 0`, `1.4` at `--gap 1`. |
| `o_sa_nhi`, `hung_da_linh`, `tat_da_lang`, `liem_hoa_nhi`, `na_lac_linh`, `dan_muc_lang`, `thoi_kim_doi`, `dieu_luu_ly` | `luyen_khi` | `cut-the-horse` | `33.6 s`, `0/5`, `0%` | `8.3 s`, `0/5`, `0%` | `cut-the-horse` fires `8.0` at `--gap 0`, `1.8` at `--gap 1` (committed Yellow primer). |

CHECKPOINT DONE
