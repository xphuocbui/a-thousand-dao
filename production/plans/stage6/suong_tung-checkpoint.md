# Sương Tùng Các (`suong_tung`): Stage 6 Hydrogen checkpoint review (2026-11-27, batch `b05`)

Unanchored checkpoint review of `design/stage6-staging/suong_tung/` against `design/world/depth/sects/suong_tung.*`, `tools/design/combat_sim/engine.py`, `src/gameplay/combat/fight/effect_runner.gd`, `src/gameplay/combat/fight/effect_compiler.gd`, and `production/plans/stage6/_brief-review.md`.

---

## 1. Ranked findings

1. **[MUST-FIX — FIXED]** `design/stage6-staging/suong_tung/arts/part-sect-suong_tung.json` — `frost-sheet` (`frost-sheet-stick`):
   - **What was wrong:** `frost_sheet` is defined with `"cap": 1, "each_for": 10`, and `frost-sheet-stick` used `{"counter": {"id": "frost_sheet", "set": 1}}`. In both `engine.py` and `effect_runner.gd`, `set` on an `each_for` counter computes `k = set - len(times)`: when `frost_sheet` is already active (`len(times) == 1`), `k = 0`, so subsequent hits fail to refresh the 10 s expiry (observed in trace: `cau_ap_suong` stuck `[13365]` at `t = 6730` and `10095`, dropping off before `t = 13460`).
   - **Fix applied:** Changed `{"counter": {"id": "frost_sheet", "set": 1}}` to `{"counter": {"id": "frost_sheet", "add": 1}}` so each landing appends a fresh `t + 10 s` timestamp and `cap: 1` retains the newest expiry (verified in post-fix trace: `[13365] -> [16730] -> [20095] -> [23460] -> ...`; outer disciples rose from `4/5` wins `29%` HP to `5/5` wins `37%` HP).

2. **[MUST-FIX — FIXED]** `design/stage6-staging/suong_tung/arts/part-sect-suong_tung.json` — `frost-on-the-pine` (`pine-frost-lay`):
   - **What was wrong:** `pine_frost_ward` is defined with `"cap": 1, "each_for": 8`, and `pine-frost-lay` used `{"counter": {"id": "pine_frost_ward", "set": 1}}`. Recasting `frost-on-the-pine` (`cooldown: 5.0`) while the ward was still active computed `k = 0` and failed to refresh its 8 s expiry.
   - **Fix applied:** Changed `{"counter": {"id": "pine_frost_ward", "set": 1}}` to `{"counter": {"id": "pine_frost_ward", "add": 1}}`.

3. **[SHOULD — FIXED]** `design/stage6-staging/suong_tung/arts/part-sect-suong_tung.json` — `frost-on-the-pine` (`pine-frost-trigger`):
   - **What was wrong:** `pine-frost-trigger` listened on `"was_hit"` without guarding `event.amount > 0`. In `engine.py` / `fight.gd`, `was_hit` fires even when a ward or body shield absorbs the entire hit (`amount == 0.0`). In the pre-fix trace of `van_han_dang` (`seed 1`), a `0.0`-damage hit at `t = 8000 ms` (soaked by `thorn-lullaby`'s body shield) prematurely consumed `pine_frost_ward`.
   - **Fix applied:** Added `{"read": "event.amount", "op": ">", "value": 0}` to `pine-frost-trigger`'s `"if"` conditions and updated `frost-on-the-pine`'s `"rule"` to `"the next damaging hit that lands on you"` (verified in post-fix trace: `t = 8000` and `8360` `0.0`-damage hits no longer spend `pine_frost_ward`, which holds until the `6.35`-damage hit at `t = 8540`).

4. **[NIT — unedited]** `design/world/depth/sects/suong_tung.items.json` (`_doc` line 3):
   - `_doc` still ends with `"No set."` from before the cast-sets pass added `st-lamp-and-brush` (`sets` lines 151–179). Left unedited as harmless commentary.

### Verified clean across the rest of the checklist
- **Standalone Effect compilation & counter/state declarations:** All 3 Effects in `suong_tung.effects.json` (`The Light That Stays`, `Sheets in the Wind`, `Ward Written Inside`) declare every counter they read/write in their own `"counters"` and pass `engine.validate` standalone (`STANDALONE_VALIDATE OK`). No Effect or art uses `stances` (avoiding any collision with `thorn-and-ink-verses` `march` stance) or `temp_mods`.
- **`laid-ward` & `cold-night-lamp`:** `laid-ward` triggers once per second the foe acts (`time > 1`, `any: [own.foe_pressed >= 1, foe.since_act <= 1]`), routes `ward_save` (`The Light That Stays`) -> `ward_twice` (`Ward Written Inside`) -> `ward` cleanly via `ward_spared` without same-event listener races, and `laid-ward-foreseen` (`tag.foreseen >= 1`) grants `3.0` `ward` at `fight_start` when `"foreseen"` is present in `REQUEST_TAGS`. `cold-night-lamp`'s `decay_per_pulse: 1` (`9` normal, `17` doubled) yields `8`/`16` active pulses around `pulse()` pre-event decrement, and `slowed_time` carries no `"cap": 1` override (uses Status Catalogue `cap: 5`).
- **Techniques, items, set & depth fidelity:** All 3 techniques (`7.2/8`, `15.8/16`, `15.4/16 W`), all 3 items (`st-cold-night-lantern`, `st-hundred-wards-flag`, `st-lantern-maker-brush` with R6 `exception` and `unique: true`, `sources: ["npc"]`, all 13 depth modifier lines verbatim), and set `st-lamp-and-brush` (all 2pc modifiers verbatim) match the depth files and pass all explicit-path linters with 0 findings.
- **Spatial & uniqueness checks:** `spatial_words_check.py --sect suong_tung` and `spatial_words_check.scan` over all staged files show 0 real spatial hits (only `"Flag"` / `"flag"` from the proper item name "Flag of a Hundred Wards"). All Effect names, technique IDs, art IDs, item IDs, and set IDs have 0 collisions with `assets/data/combat_effects.json`, committed `design/`, and `design/stage6-staging/`.

---

## 2. Pending words (`pending.json`)

- None (`pending.json` has `"words": []`, `"arts": []`, `"effects": {}`).

---

## 3. Verification after final edit (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\suong_tung`)

- `spatial_words_check.py --sect suong_tung`: exit 0, 0 real spatial hits (3 depth item/cast `"flag"` hits from "Flag of a Hundred Wards").
- `depth_check.py --sect suong_tung --quiet`: `findings: none`.
- `lint_techniques.py design/stage6-staging/suong_tung/techniques/catalogue-sect-suong_tung.json`: 3 techniques, 0 findings (`7.2/8`, `15.8/16`, `15.4/16 W`).
- `lint_arts.py design/stage6-staging/suong_tung/arts/part-sect-suong_tung.json`: 4 arts, 0 findings (`frost-sheet empower 1: x1.04 of the lint, gated`).
- `lint_items.py design/stage6-staging/suong_tung/items/catalogue-sect-suong_tung.json`: 3 items, 0 findings (`unique 3 of 3`).
- Standalone `engine.validate` on all 3 staged Effects: 3/3 OK.
- `sect_fight.py suong_tung --seeds 5` (`--gap 0` and `--gap 1`): exit 0, **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN** across all 16/16 living members.

---

## 4. Holder table after fixes (`sect_fight.py suong_tung --seeds 5`)

| Holder(s) | Realm | Arts | `--gap 0` (`mean_s`, `wins/5`, `hp_left`) | `--gap 1` (`mean_s`, `wins/5`, `hp_left`) | Effects (`with / without`, runs) |
|---|---|---|---|---|---|
| `van_han_dang` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `cold-night-lamp`, `marching-dirge`, `thorn-lullaby` | `31.5 s, 5/5, 96%` (`3.8–11.6` fires) | `10.2 s, 0/5, 0%` (`1.0–3.2` fires) | **The Light That Stays**: `31.5 s 96%` vs `31.4 s 97%` (`35` G0, `15` G1). **Ward Written Inside**: `31.5 s 96%` vs `30.1 s 100%` (`19` G0, `5` G1). |
| `nhac_hoa_bi` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `marching-dirge`, `thorn-lullaby` | `28.2 s, 5/5, 100%` (`4.8–9.8` fires) | `8.7 s, 0/5, 0%` (`1.0–3.0` fires) | **Sheets in the Wind**: `28.2 s 100%` vs `28.7 s 100%` (`61` G0, `15` G1). |
| `thieu_hoa_tam`, `quan_suong_thu` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `marching-dirge`, `thorn-lullaby` | `27.6 s, 5/5, 100%` (`4.0–10.0` fires) | `8.3 s, 0/5, 0%` (`1.0–2.2` fires) | n/a |
| `duong_mac_chieu` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `marching-dirge` | `37.9 s, 5/5, 24%` (`5.0–14.0` fires) | `8.1 s, 0/5, 0%` (`1.0–2.0` fires) | n/a |
| `khong_da_hanh` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `cold-night-lamp` | `61.9 s, 4/5, 14%` (`7.8–16.0` fires) | `8.5 s, 0/5, 0%` (`1.0–2.2` fires) | n/a |
| `chu_anh_tuyet`, `hang_bang_tuong`, `lien_bich_phu` | `luyen_khi` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine` | `34.6 s, 0/5, 0%` (`4.6–11.4` fires) | `8.0 s, 0/5, 0%` (`1.0–2.0` fires) | n/a |
| `o_tieu_mac`, `tat_hanh_chi`, `nghe_tung_yen` | `luyen_khi` | `lamp-oil-lance`, `laid-ward` | `41.8 s, 0/5, 0%` (`5.4–13.6` fires) | `8.0 s, 0/5, 0%` (`1.0–2.0` fires) | n/a |
| `cau_ap_suong`, `banh_tieu_dang`, `bui_to_chi`, `cao_han_chuc` | `luyen_khi` | `ambush-talisman`, `frost-sheet` | `29.0 s, 5/5, 37%` (`8.0–9.2` fires) | `9.0 s, 0/5, 0%` (`2.0` fires) | n/a |

CHECKPOINT DONE
