# Stage 6 Checkpoint Review — `phuong_minh` (Phượng Minh Cung)

Reviewed unanchored from staged engine records, depth files, authored Stage 4/5 records, rulings (`DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`), and live combat engine traces.

---

## 1. What Was Read

- **Briefs, rules, & rulings**: `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `_brief-serial.md`, `FIGHT-INPUT.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, peer checkpoints (`thien_xu-checkpoint.md`, `lac_ha-checkpoint.md`, `thien_xu/pending.json`, `lac_ha/pending.json`).
- **Staged files (`design/stage6-staging/phuong_minh/`)**:
  - `pending.json`
  - `effects/phuong_minh.effects.json` (17 Effects, including `Sit Beside` out-of-fight `not_run`)
  - `techniques/catalogue-sect-phuong_minh.json` (6 techniques)
  - `arts/part-sect-phuong_minh.json` (14 arts after moving `dawn-call` onto `pm-dawn-call-pipe`)
  - `items/catalogue-sect-phuong_minh.json` (28 items) & `items/sets-phuong_minh.json` (10 sets)
  - `foreign/market-folk/techniques/catalogue-sect-market-folk.json` (`censer-smoke-manual`) & `foreign/market-folk/arts/part-sect-market-folk.json` (`pill-smoke`)
- **Depth & authored sources**: `design/world/depth/sects/phuong_minh.{techniques,items,beasts,md}.json`, `phuong_minh.cast.json` + `.2`/`.3`/`.4.cast.json` (120 people, 113 living), `design/world/depth/builds/authored/{auth-tech,auth-eff-1,auth-eff-2,auth-mod}.json`.
- **Engine & linters**: `tools/design/combat_sim/{engine,fight,sect_fight,export_combat_library}.py`, `tools/design/arts/{lint_arts,lint_techniques}.py`, `tools/design/items/{lint_items,export_named}.py`, `tools/design/world/{depth_check,depth_gap,stage6_merge}.py`, `src/gameplay/cultivation/cong_phap.gd`, `src/gameplay/combat/fight/{fighter_compiler,build_file_compiler,effect_runner}.gd`, `assets/data/combat_{engine,effects}.json`.

---

## 2. Ranked Findings

### MUST-FIX

1. **[FIXED] `pending.json` lacked explicit `decision` / `decision_reason` and bundled compiler meter seeding inside `technique-effects`**
   - *Found*: `design/stage6-staging/phuong_minh/pending.json` listed only `technique-effects` without `"decision"` or `"decision_reason"`. Furthermore, checking `fighter_compiler.gd`, `build_file_compiler.gd`, and `effect_runner.gd` confirmed that while `meter` execution and `build.meters` already work in both engines (`engine.py:1870`, `effect_runner.gd:709`, `build_file_compiler.gd:651`), `FighterCompiler` and `fight.py` neither read `techniques[].effects` nor seed `build.meters["playing_past_the_break"] = {"start": saved, "p": (than_hon + khi_van) / 400}` between fights.
   - *Fix*: Marked `technique-effects` `"decision": "build"` (matching `thien_xu` and `lac_ha`) and split out `"carried-meter"` as an explicit `"decision": "build"` entry for `Playing Past the Break` (`FighterCompiler` + `fight.py` seeding/persistence; no new combat engine action word needed). Added `_checkpoint` note.

2. **[FIXED] `Playing Past the Break` fired on the 7th firing instead of right after the 7th, omitted `−10 % linh lực` backlash, and stalled `remnant_movement` at `7` after `break_tried == 1`**
   - *Found in `effects/phuong_minh.effects.json` (`Playing Past the Break`)*:
     - Because art effects run before technique/tree effects in `expand_library`, on the 7th firing `remnant-m7` set `remnant_movement = 7`, and `Playing Past the Break` immediately saw `remnant_movement >= 7` on that same 7th firing (`t=19810 ms` in probe) instead of `"the firing of the Remnant Score's Next Movement right after its seventh"` (8th firing).
     - Failure applied only `self_hit` `c: 1.2` (~5.2–5.6 % HP unwarded / ~2 % warded on Kết Đan builds) and omitted `−10 %` linh lực loss.
     - Once `break_tried == 1`, subsequent cycles reaching `remnant_movement == 7` never reset to `0`, leaving `remnant-next-movement` inert from cast #15 onward.
   - *Fix*: Added `remnant_ready_8` (`cap: 1`) arm/disarm records plus a `break_tried >= 1` reset record so `Playing Past the Break` arms after M7, fires on the 8th firing (and cleanly steps aside when `Never the Eighth` resets `remnant_movement = 0` on M7), resets to `0` on subsequent cycles after `break_tried == 1`, raises backlash `self_hit` `c` to `2.2` (~10 % HP on Kết Đan), and deducts `−10 %` linh lực via `break_backlash` + `gain_qi: {"share": -0.1}` guarded by `own.qi_share >= 0.1` (preventing negative `s.qi` in `engine.py:1841` / `effect_runner.gd:415`).

3. **[FIXED] `A Copy in Small` incremented `plumage` without setting a missing `pl_c1..pl_c5` colour flag**
   - *Found in `effects/phuong_minh.effects.json` (`A Copy in Small`)*: `eff:A Copy in Small extra` did `{"counter": {"id": "plumage", "add": 1}}` without setting any lacking `pl_c*` flag, allowing `plumage` to reach `5` before `pl_c*` caught up or exceed `5` when a missing colour fired next.
   - *Fix*: Replaced the bare increment with `c5`..`c1` ordered records checking `pl_c* == 0` alongside `ward_share > 0`, `sm_fast >= 4`, `plumage < 5`, keeping `plumage` and `pl_c1..pl_c5` in lockstep.

4. **[FIXED] `dawn-call` was orphaned in `arts/part-sect-phuong_minh.json` while `pm-dawn-call-pipe` had `arts: []`, breaking item compilation and starving `Light on the Pipe`**
   - *Found*: `design/world/depth/sects/phuong_minh.items.json` and `auth-tech.json (e10)` define `dawn-call` on `pm-dawn-call-pipe`. Every signature weapon in `design/items/catalogue-*.json` embeds its attack art in `it["arts"]`, which `export_combat_library.py:123` and `fighter_compiler.gd:155` compile for the item's wielder (`chuc_hieu_nghi`). Staged `pm-dawn-call-pipe` instead had `"arts": []` and a stale R6 `"exception"`, putting `dawn-call` into `part-sect-phuong_minh.json` where no technique references it.
   - *Fix*: Moved `dawn-call` inline into `pm-dawn-call-pipe["arts"]` in `items/catalogue-sect-phuong_minh.json`, removed it from `arts/part-sect-phuong_minh.json`, and removed the stale R6 exception (`lint_items.py` passes with 0 findings, 19.9 W of 25.6).

---

### SHOULD

5. **[FIXED] Three signature instruments (`pm-remnant-score-zither`, `pm-rites-drum`, `pm-dawn-call-pipe`) used dead `scope: ["artifact"]` instead of reaching song-soul arts**
   - *Found*: Depth `phuong_minh.items.json` (from `auth-mod.json b2`) had `art_speed_pct` scoped to `["song"]`, which `lint_items.py` currently rejects because `"song"` is absent from `lint_techniques.py`'s `TIER` vocabulary pending GDD amendment. Staged items replaced `["song"]` with `["artifact"]`, which matches 0 arts on `lien_thieu_nghi` (`remnant-*` has `["song", "soul", "wood", "movement"]`) or `chuc_hieu_nghi` (`dawn-call` has `["light", "song", "soul", "pipe"]`).
   - *Fix*: Switched `scope` from `["artifact"]` to `["soul"]` (valid in `TIER` and reaches all 4 song-soul arts of both holders) while logging restoration to `["song"]` in Open Items once `"song"` joins the Modifier vocabulary. (Same constraint holds `shao-remnant-score` passives at `["soul"]` / unscoped.)

6. **[FIXED] `nine-shao-eighth-movement` (`nineshao-m8-stacks`) wiped `foe.counter.shao` to `0`**
   - *Found in `arts/part-sect-phuong_minh.json` (`nineshao-m8-stacks`)*: When `nine-shao-eighth-movement` fired out of turn with `foe.counter.shao >= 8`, it executed `{"counter": {"id": "shao", "side": "foe", "set": 0}}`. Neither `phuong_minh.techniques.json`, `auth-tech.json`, nor `nineshao-m8-in-turn` says the eighth movement clears Shao stacks, and zeroing `shao` turns off `nine-shao-fifth-movement` (`>= 3`) and `Eight of Nine` (`>= 8`).
   - *Fix*: Removed the `shao -> 0` reset from `nineshao-m8-stacks`.

7. **[FIXED] `Fire Down the Thread` omitted its written `1 % linh lực` cost under an outdated `approx` claim**
   - *Found in `effects/phuong_minh.effects.json` (`Fire Down the Thread`)*: Claimed `(engine has no self_burn_qi action)`, whereas `assets/data/combat_effects.json` (`The Peak Does Not Move`) already uses `gain_qi` `-0.01` guarded by `own.qi_share >= 0.01`.
   - *Fix*: Added `own.qi_share >= 0.01` condition and `{"gain_qi": {"share": -0.01}}` to `eff:Fire Down the Thread grow` and updated `approx`.

8. **[OPEN] Cast root mismatches vs `CongPhap.usable` (24 living people)**
   - `wutong-dawn-breath` (`names: ["moc", "hoa"]`) is held by 20 living outer disciples lacking `moc` or `hoa`, and `five-virtue-phoenix-canon` (`names: ["hoa", "moc"]`) is held by 4 living elders (`su_hoanh_duc`, `vuu_cam_thu`, `phan_vong_hai`, `hach_chu_lang`) lacking `moc` (`su_hoanh_duc` has `hoa` + `kim`; the other 3 lack `moc`). Left untouched here (technique `names` accurately reflect their Fire + Wood arts); carry to cast/root reconciliation.

9. **[OPEN] `foreign/market-folk/` `censer-smoke-manual`: `names: ["hoa"]` vs `o_thiem_tu` (`thinh_vu`) and single-owner lint gap**
   - `censer-smoke-manual` was authored element-free (`names: []` in `market-folk.techniques.json`) so alchemists/poisoners like `o_thiem_tu` (`moc`/`thuy` in `thinh_vu`) can run it, but `lint_techniques.py:130` requires `1..3` elements on non-`body` techniques, so `names: ["hoa"]` was kept in staging (passing `ke_chu_sa` `hoa`/`moc` and `phung_xich_kim` in `chan_kim`). Meanwhile standalone `lint_techniques.py foreign/market-folk/...` reports `ART_MISSING 'pill-smoke'` only because `lint_techniques.py:96` does not glob `foreign/*/arts/` (will pass once `stage6_merge.py` merges `foreign/market-folk/` into `design/`).

---

### NIT

10. **`five-colour-plumage` `pl-spend-*` self-trigger**: Because `pl-spend-clean`/`pl-spend-repeat` run on `art_fired` before that art's own `hit_landed`, a damaging art completing the 5th colour (`furnace-heart`, `five-colour-plumage`, etc.) boosts and consumes `pl_held` on its own hit rather than waiting for the subsequent art (only a 0-damage ward like `perch-on-the-wutong` defers to the next hit). Documented rather than rewriting `d1` hit-ordering; also `Birds Pay Court to the Phoenix`'s `approx` updated to note `bird_empowered` (`cap: 1`) cannot track multiple companion instances separately.
11. **`tang_ke_ti` array/Field build gap**: `pm-nest-thread-banner` (`Thread of the Nest`) and `pm-nest-array` (`Fire Down the Thread`) condition on `own.field_up >= 1`, and `tang_ke_ti` knows only `five-virtue-phoenix-canon` + `ashen-phoenix-canon` (neither grants a Field art; `perch-on-the-wutong` raises a stance ward, not a Field).

---

## 3. Pending Words (`pending.json`)

| Word | Kind | Decision | Scope / Reason |
| --- | --- | --- | --- |
| `technique-effects` | `field` | **`build`** | Matches `thien_xu` & `lac_ha`: export `techniques[].effects`, load via `fight.py` (`tech_layers`) and GDScript `FighterCompiler` for `Birds Pay Court to the Phoenix` (layer 5) and `Playing Past the Break` (layer 1). |
| `carried-meter` | `field` | **`build`** | Seed `build.meters["playing_past_the_break"] = {"start": saved, "p": (than_hon + khi_van) / 400}` in `FighterCompiler`, save-state persistence, and `fight.py`/`sect_fight.py` cast builders. Combat `meter` action and `build_file_compiler.gd` already exist. |

---

## 4. Verification & Holder Table (Post-Edit)

All linters ran after the last edit with `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\phuong_minh"`:
- `lint_arts.py part-sect-phuong_minh.json`: **14 arts, 0 findings**.
- `lint_techniques.py catalogue-sect-phuong_minh.json`: **6 techniques, 0 findings**.
- `lint_items.py catalogue-sect-phuong_minh.json`: **28 items, 0 findings** (22 bases, 9 common arts).
- `lint_arts.py foreign/market-folk/arts/part-sect-market-folk.json`: **1 art (`pill-smoke`), 0 findings**.
- `lint_techniques.py foreign/market-folk/techniques/catalogue-sect-market-folk.json`: **1 finding (`ART_MISSING 'pill-smoke'`) + `NOT_PRICED` note (`pill_effect_pct`)**, expected pre-merge because `lint_techniques.py` globs `DEPTH_STAGE/arts/` only.
- `depth_check.py --sect phuong_minh`: **findings: none** (`beasts` 3/3 valid & alive/owned; `cong_phap` 6/6).
- `depth_gap.py --sect phuong_minh`: **stand_ins 0, unknown_ids 0, lines 135/135 runs, cross_owner 2**.

### Key `sect_fight.py phuong_minh --seeds 5` & Targeted Probe Results

(`sect_fight.py` ran at `--gap 0` and `--gap 1` across all 55 living authored NPCs; **0 `REFUSED`**, non-signature outer disciples omitted below for brevity — all Luyện Khí outer disciples won 5/5 at `gap=0` except 4 `hearth-ash-breath` `stand-in`-named sweepers [`bao_lac_hai`, `bi_thuan`, `nguu_dai_huu`, `luu_tu_nuong`: `48.6s 0W 0%`], and all lost `0/5` at `gap=1`.)

| Holder | Realm | Gap 0 (`5 seeds`) | Gap 1 (`5 seeds`) | Key Effects (`sect_fight` + Targeted Probes) |
| --- | --- | --- | --- | --- |
| `hoa_trieu_duong` | `nguyen_anh` | `26.0s`, 5W, `80%` | `8.8s`, 0W, `0%` | `The Five Marks Shine`: runs 15 (`+9%` HP left vs without at gap 0); `Embers Never Die`: runs 5. `Eight of Nine` (`pm-tieu-thieu-quan`): verified `open` + `hold` (`shao >= 8`, preserves `shao=23` after `m8` fix) with Nine Shao kit. `Birds Pay Court to the Phoenix`: verified via `tree_effects` + bird companion. `The Phoenix Comes with Stately Grace` (`pm-five-virtue`): split-set (`pm-wutong-seal` on `vu_ngo_dong`); verified 4 fires when all 3 equipped. |
| `nhiep_tan_sa` | `nguyen_anh` | `19.0s`, 5W, `81%` | `12.2s`, 0W, `0%` | `The Censer Remembers`: runs 66 (gap 0) / 45 (gap 1); `heal` on `wounded` verified (`t=12240ms`). `Sit Beside`: `0 NEVER_RAN` (`not_run` out-of-fight breakthrough rule). |
| `su_hoanh_duc` | `nguyen_anh` | `14.9s`, 5W, `99%` | `12.0s`, 0W, `0%` | `Burning Feathers`: runs 50 (gap 0) / 24 (gap 1). `Two Wings Beat` (`pm-twin-wings`): split-set (`pm-right-wing-fan` on `co_da_lan` in `thinh_vu`); verified echo triggers when both equipped. |
| `vu_ngo_dong` | `ket_dan` | `28.2s`, 5W, `92%` | `11.2s`, 0W, `0%` | `Fan the Pyre`: runs 90 (gap 0) / 26 (gap 1). `The Birds Fight First`: `0 NEVER_RAN` in `sect_fight` because `beasts` (`xich_quan`, `tieu_vi`) are not compiled as `companions` yet; verified `21` stack procs with 2 bird companions + `Birds Pay Court` (`6` rewards). |
| `tang_ke_ti` | `ket_dan` | `19.8s`, 5W, `69%` | `11.8s`, 0W, `0%` | `Fire Down the Thread`: `0` at gap 0 (no ward break), `4` at gap 1 (`shield_broken`), and verified `grow` (`-1%` qi) + `break` when Field art is slotted. `Thread of the Nest`: `0 NEVER_RAN` (no Field art on build). |
| `lien_thieu_nghi` | `ket_dan` | `28.3s`, 5W, `100%` | `10.0s`, 0W, `0%` | `Never the Eighth`: `0 NEVER_RAN` in `sect_fight` (`remnant-next-movement` is 7th art past `MAX_ARTS=6`). With `remnant-next-movement` slotted + `Playing Past the Break`: `Never the Eighth` restarts at M7 cleanly (`3` cycles, `23` steps), suppressing `Playing Past the Break`. |
| `lo_van_khanh` | `ket_dan` | `27.6s`, 5W, `100%` | `8.1s`, 0W, `0%` | `Playing Past the Break`: verified post-fix on 8th cast (`t=22640ms` after M7 at `19810ms`), `-10%` qi backlash fires cleanly on `p=0.0`, `p=1.0` grants 5 Slowed Time + 10% qi, and cycle #2 cleanly resets at `t=45280ms`. |
| `trinh_hi_quang` | `ket_dan` | `14.9s`, 5W, `84%` | `9.4s`, 0W, `0%` | `A Copy in Small`: runs 20 (gap 0) / 10 (gap 1); synced `pl_c1..pl_c5` probe verified. |
| `an_thuy_vu` | `truc_co` | `18.8s`, 5W, `68%` | `8.0s`, 0W, `0%` | `The Birds Bring the Fire`: `0 NEVER_RAN` in `sect_fight` (`beasts`: `ngu_cau` not compiled to `companions`); verified `9` stack procs with bird companion. |
| `chuc_hieu_nghi` | `truc_co` | `14.1s`, 5W, `89%` | `8.0s`, 0W, `0%` | `Light on the Pipe`: `0 NEVER_RAN` in `sect_fight` (`sect_fight.py:66` does not slot `items[named].arts`); `pm-dawn-call-pipe` now carries `dawn-call` and probe confirms `dawn-count` + `Light on the Pipe count` both run (`2` procs in 12s). |
| `du_diem_ca` | `truc_co` | `12.4s`, 5W, `94%` | `8.0s`, 0W, `0%` | `Petal Feint`: runs 7 (gap 0) / 4 (gap 1). |
| `ke_chu_sa` | `ket_dan` | `20.8s`, 5W, `67%` | `8.0s`, 0W, `0%` | `censer-smoke-manual` / `pill-smoke`: not compiled in `sect_fight` (`foreign/` not globbed, and 7th art past `MAX_ARTS=6`); `smoke-burn-pill` verified after registering `foreign/market-folk/arts/`. |

---

## 5. Open Items (Not Blocked on Staging Edits; Carry to Serial / Cast / GDD Passes)

1. **Serial (`pending.json`)**: Build `technique-effects` (`export_combat_library.py`, `fight.py` `tech_layers`, `FighterCompiler`) and `carried-meter` (`FighterCompiler` + save persistence seeding `build.meters["playing_past_the_break"]`), then move `Birds Pay Court to the Phoenix` & `Playing Past the Break` into `combat_effects.json`.
2. **GDD Modifier vocabulary (`b2`)**: Add `"song"` tag to `combat_engine.json` / `modifiers.md`, then restore `scope: ["song"]` on `pm-remnant-score-zither`, `pm-rites-drum`, `pm-dawn-call-pipe`, and `shao-remnant-score` passives.
3. **Cross-sect `foreign/market-folk/`**: Reconcile `censer-smoke-manual` `names: ["hoa"]` vs element-free `o_thiem_tu` (`thinh_vu`), either via an element-free `secret` exemption in `lint_techniques.py` or adjusting `o_thiem_tu`'s root; confirm `lint_techniques.py` passes cleanly post-merge via `stage6_merge.py`; price `pill_effect_pct` in Formulas A if needed.
4. **Cast & build reconciliation**: Reconcile 24 living `phuong_minh` cast `CongPhap.usable` mismatches (`wutong-dawn-breath`, `five-virtue-phoenix-canon`); consider whether `tang_ke_ti` should gain a `tran_su` Field art so `Thread of the Nest` fires in regular duels; leave `nine-shao-ninth-movement` story-only (`unlock_layer: 15`) and `tieu_vi`/`xich_quan`/`ngu_cau` companion cards to their systems pass.
5. **Sim tool enhancements (non-blocking)**: `sect_fight.py` does not yet compile `items[named].arts` (`pm-dawn-call-pipe`), `beasts` into `companions` (`vu_ngo_dong`, `an_thuy_vu`), `tree_effects` / `technique.effects`, or `foreign/` arts, and caps slotted arts at `6` (dropping `remnant-next-movement`, `nine-shao-next-movement`, `pill-smoke` for multi-technique elders).

CHECKPOINT DONE
