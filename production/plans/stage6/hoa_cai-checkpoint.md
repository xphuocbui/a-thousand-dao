# Stage 6 checkpoint review: Hoa Cái Đường (`hoa_cai`, Batch b03)

Unanchored checkpoint review of `design/stage6-staging/hoa_cai/` and `design/world/depth/sects/hoa_cai.*` against `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

---

## 1. Ranked findings

1. **[SHOULD — FIXED] `design/stage6-staging/hoa_cai/effects/hoa_cai.effects.json` — `Nine Stars over the Fire` (`eff:Nine Stars over the Fire ward`, `eff:Nine Stars over the Fire sustain`)**
   - *What was wrong:* The depth rule (`hoa_cai.items.json`) states *"while a foe carries your debuffs"* without element restriction, and `canopy-furnace-canon` carries `pill-smoke` (layer 4), which can lay `ice`, `thunder`, or `wind` debuffs depending on the prepared pill. The staged `if` conditions checked only `earth`, `metal`, `wood`, and `fire` debuffs.
   - *Fix applied:* Added `foe.debuff.ice`, `foe.debuff.thunder`, and `foe.debuff.wind` (`>= 1`) to the `any` blocks of both `eff:Nine Stars over the Fire ward` and `eff:Nine Stars over the Fire sustain`, and updated the `approx` string to list all seven debuff elements.

2. **[SHOULD — FIXED] `design/stage6-staging/hoa_cai/arts/part-sect-hoa_cai.json` — `hold-the-fume`**
   - *What was wrong:* `hold-the-fume` carried `"cleanse"` in `"tags"` (`["body", "heal", "cleanse"]`), even though it deliberately performs no `cleanse` action (it uses `tick_to_heal: 1` + `status_immune` so it will not strip `The Unfinished Pill`'s uncleansable Wood poison). Because `"cleanse"` is a Modifier scope tag (`lint_techniques.py`), `[cleanse]`-scoped modifiers would mis-target `hold-the-fume`.
   - *Fix applied:* Removed `"cleanse"` from `hold-the-fume`'s `"tags"` (now `["body", "heal"]`).

3. **[SHOULD — FIXED] `design/stage6-staging/hoa_cai/effects/hoa_cai.effects.json` — `Under the Lid` (`eff:Under the Lid fan tag`)**
   - *What was wrong:* `eff:Under the Lid fan tag` (`filter: {"tags": ["fan"]}`) and `eff:Under the Lid fan gust` (`filter: {"art_id": "fan-gust"}`) currently do not overlap only because `common-arts.json` tags `fan-gust` as `["artifact"]`. If `fan-gust` is later tagged `"fan"`, firing `fan-gust` would trigger both records and lay 2 Mercury stacks instead of 1.
   - *Fix applied:* Added `"not_art_id": "fan-gust"` to `eff:Under the Lid fan tag`'s `"filter"`.

4. **[NIT — UNEDITED] `design/stage6-staging/hoa_cai/arts/part-sect-hoa_cai.json` — `quicksilver-nine-stacks`**
   - *Note:* `quicksilver-nine-stacks` places both `status: withering` (`cap: 1`) and `free_hit` under `scale: {"read": "foe.debuff.metal", "per": 1}`, so `apply_status` receives `stacks = 9+` and clamps to `cap: 1`. Combat behaviour is identical to splitting `withering` into an unscaled record; left untouched.

5. **[NIT — UNEDITED] `design/world/depth/sects/hoa_cai.md` — `A Room Full of Fume` prose phrasing**
   - *Note:* `hoa_cai.md` §10 says *"is shared with the foe when you drink"*, while `hoa_cai.items.json`, `sets-hoa_cai.json`, and `hoa_cai.effects.json` say *"goes to the foe when you drink"* (the poison moves off the wearer onto the foe). `hoa_cai.items.json` is the authoritative item/set text and matches the staged Effect; left `hoa_cai.md` untouched.

---

## 2. Verification & audit notes

- **No MUST-FIX bugs found:**
  - All 4 Effects in `hoa_cai.effects.json` declare every counter they read/write (`gourd_drunk`, `sealed_room_set`) in their own `"counters"` arrays, pass standalone `engine.validate()` (`4/4`), use no stances (`0` stance collisions), have no multi-`mod` records without `"stack": true`, have no `decay_per_pulse: 1`, and have no `always` record with a record-level `filter`.
  - Uniqueness verified against committed `design/`, `assets/data/combat_effects.json`, and all other `design/stage6-staging/` directories (`0` ID or Effect-name collisions).
  - Item and set modifiers in `items/catalogue-sect-hoa_cai.json` and `items/sets-hoa_cai.json` match `design/world/depth/sects/hoa_cai.items.json` verbatim; `hc-nine-cycle-gourd` (`kind: "treasure"`, `grade: 4`, `rarity: 5`, `unique: true`, R6 `exception`) is clearly logged for post-batch `export_named.py` `treasure` support.
  - All 17 living people in `hoa_cai.cast.json` and `hoa_cai.5.cast.json` use lineage methods directly (`0` stand-ins, `0` beasts) with fitting roots. No environment conditions or spatial-fight vocabulary (`spatial_words_check.py`: `0` hits for `hoa_cai`).
- **Targeted Effect & ablation verification (`la_tu_vi`, `uy_dan_duong`, `hold-the-fume`):**
  - Why `sect_fight.py` prints `la_tu_vi` `Under the Lid` (`21.0 s 92%` vs `21.0 s 92%` at `--gap 0`; `9.8 s 0%` vs `9.8 s 0%` at `--gap 1`) and `Nine Stars over the Fire` (`9.8 s 0%` vs `9.8 s 0%` at `--gap 1`):
    - Neither is a no-op. On `la_tu_vi` seed 1 (`--gap 0`), ablating `Under the Lid` lowers `sward_peak` from `437.56` to `405.56` and leaves foe end HP at `-712.83` vs `-784.40` (`71.57` less `lift-the-lid` release damage), while `la_tu_vi` finishes at the same `t = 21.0 s` and `A_hp = 1541.31` (`92%`); ablating `Nine Stars over the Fire` drops `sward_peak` to `393.46`, `A_hp` to `1517.63`, and `B_hp` to `-691.25`. At `--gap 1` (seed 1), ablating `Under the Lid` shifts foe HP from `4580.22` to `4582.72` (ward breaks before refilling, `sward_peak = 252.27`), and ablating `Nine Stars over the Fire` shifts death from `9.0 s` to `10.0 s` (`B_hp = 4585.00`, because `+20 % ward_pct` drains slightly more linh lực on hit).
    - With `hc-sulphur-fan`'s common art `fan-gust` slotted alongside `la_tu_vi`'s 5 technique arts (`fight.py`, `--gap 0`, 5 seeds), `Under the Lid` reduces mean fight time from `17.19 s` (`90.1%` HP) to `16.00 s` (`90.8%` HP), and `Nine Stars over the Fire` improves mean time/HP from `16.40 s` (`88.6%` HP) to `16.00 s` (`90.8%` HP).
  - `uy_dan_duong` solo Gourd probe (without `hc-fume-censer`/`hc-cinnabar-robe`): `eff:The Unfinished Pill self poison` fires (`4` permanent `wood` debuffs remain on `uy_dan_duong` at fight end).
  - `hold-the-fume` probe vs Wood Poison + `corpse_rot` foe and Fire Burn foe: `90` zero-damage ticks on `A` while `fume_hold` is up (`tick_to_heal: 1`), `corpse_rot` blocked while active (`1` application only outside the 4 s window).
- **Post-edit linters & checks (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hoa_cai`):**
  - `lint_techniques.py`: `checked 4 techniques, 0 findings` (`7.6 / 8 W`, `15.9 / 16 W`, `15.8 / 16 W`, `7.8 / 8 W`)
  - `lint_arts.py`: `checked 5 arts in 1 files, 0 findings` (`lift-the-lid empower 1: x1.05 of the lint, gated`)
  - `lint_items.py`: `checked 5 items, 22 bases, 9 common arts, 0 findings`
  - `depth_check.py --sect hoa_cai`: `findings: none`
  - `depth_gap.py --sect hoa_cai`: `unknown_ids: 0`, `engine_words: 0`, `cross_owner: 0`, `stand_ins: 0`, `lines: 26/26 runs`
  - Standalone `engine.validate()`: `4/4 passed`

---

## 3. Pending words

None (`0` pending words; no `pending.json` present).

---

## 4. Holder table after fixes (`sect_fight.py hoa_cai --seeds 5` and `--gap 1`)

All 17 living holders ran with `0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN` at both `--gap 0` and `--gap 1`:

| Holder(s) | Realm | Arts | `--gap 0` (`mean_s`, `wins/5`, `hp_left`) | `--gap 1` (`mean_s`, `wins/5`, `hp_left`) | Effect ablations (`--gap 0` / `--gap 1`, `runs`) |
|---|---|---|---|---|---|
| `uy_dan_duong` | `ket_dan` | `spread-the-canopy, lift-the-lid, pill-smoke, quicksilver, hold-the-fume` | `16.8 s`, `5/5`, `98%` | `10.9 s`, `0/5`, `0%` | `The Unfinished Pill`: `16.8 s 98%` vs `18.0 s 91%` (`10`) / `10.9 s 0%` vs `10.4 s 0%` (`40`). `A Room Full of Fume`: `16.8 s 98%` vs `20.8 s 95%` (`89`) / `10.9 s 0%` vs `11.2 s 0%` (`238`). |
| `la_tu_vi` | `truc_co` | `spread-the-canopy, lift-the-lid, pill-smoke, quicksilver, hold-the-fume` | `21.0 s`, `5/5`, `92%` | `9.8 s`, `0/5`, `0%` | `Nine Stars over the Fire`: `21.0 s 92%` vs `21.0 s 91%` (`60`) / `9.8 s 0%` vs `9.8 s 0%` (`40`). `Under the Lid`: `21.0 s 92%` vs `21.0 s 92%` (`60`) / `9.8 s 0%` vs `9.8 s 0%` (`40`); shifts `sward_peak` & `B_hp`, and with `fan-gust` drops time `17.19 s -> 16.00 s`. |
| `thieu_ngan_hong` | `truc_co` | `spread-the-canopy, lift-the-lid, pill-smoke, quicksilver` | `21.2 s`, `5/5`, `82%` | `8.4 s`, `0/5`, `0%` | — |
| `bien_lam_chau` | `luyen_khi` | `spread-the-canopy, lift-the-lid, hold-the-fume, quicksilver` | `21.0 s`, `5/5`, `90%` | `8.3 s`, `0/5`, `0%` | — |
| `trac_dao_sa`, `ky_chu_sa`, `muc_hong_sa` | `truc_co` | `spread-the-canopy, lift-the-lid, pill-smoke, hold-the-fume` | `41.2 s`, `5/5`, `75%` | `8.6 s`, `0/5`, `0%` | — |
| `van_thuy_dan` | `truc_co` | `spread-the-canopy, lift-the-lid` | `40.6 s`, `5/5`, `69%` | `8.6 s`, `0/5`, `0%` | — |
| `du_hoang_nhi`, `chau_di_an` | `luyen_khi` | `spread-the-canopy, lift-the-lid` | `36.6 s`, `5/5`, `70%` | `8.3 s`, `0/5`, `0%` | — |
| `ngai_hoang_thach`, `me_hoa_thu`, `chung_minh_hien`, `co_tich_dang` | `luyen_khi` | `pan-the-grains, hold-the-fume` | `51.3 s`, `0/5`, `0%` | `8.5 s`, `0/5`, `0%` | — |
| `me_thanh_mach`, `phi_tieu_lam`, `la_khoi_minh` | `luyen_khi` | `pan-the-grains` | `45.5 s`, `0/5`, `0%` | `8.5 s`, `0/5`, `0%` | — |

---

## 5. Open items for post-batch Stage 6 / Stage 7

1. **Serial merge & export:** merge `design/stage6-staging/hoa_cai/` via `stage6_merge.py`, `put_effects.py`, and run combat/item/technique exports.
2. **`export_named.py` `kind == "treasure"`:** `export_named.py` currently filters `if it.get("kind") != "artifact": continue`, so `hc-nine-cycle-gourd` (`kind: "treasure"`, `grade: 4`, `rarity: 5`) will not export to `assets/data/items_named.json` until `treasure` support is added.
3. **Out-of-fight / unbuilt hooks:** `Nine Stars over the Fire`'s failed-batch pill preservation awaits crafting Effect hooks in `src/`; `pill-smoke`'s half-strength self pill effect awaits full pill combat support.

CHECKPOINT DONE
