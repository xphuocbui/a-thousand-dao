# Mục Vân Trang (`muc_van`): Stage 6 checkpoint review (2026-11-27)

Unanchored review against `design/world/depth/sects/muc_van.*`, `production/plans/stage6/_brief-record.md`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `engine.py`, and GDScript `EffectCompiler` / `EffectRunner` / `FighterProfileLoader`.

## Ranked findings

1. **MUST-FIX — `design/stage6-staging/muc_van/effects/muc_van.effects.json` (`eff:Ninety Thousand Li gust`)**:
   - **What was wrong:** `eff:Ninety Thousand Li gust` placed `{"mod": {"dampen_taken": 25, "for": 2.0}}` before `{"consume": {"el": "wind", ..., "then": [{"mod": {"evade": 2.5, "for": 4.0}}]}}` inside the same Effect record. In both `engine.py` and `effect_runner.gd`, `consume`'s `then` branch runs `do()` with the parent Effect's `id`, and because the inner `mod` lacks `"stack": true`, it purges all existing `temp_mods` matching `e.id` — immediately deleting `dampen_taken: 25` on the same instant (confirmed by tracing `s.temp_mods`: `dampen_taken` never persisted).
   - **Fix applied:** Split `dampen_taken: 25` (`for: 2.0`) into its own listener `eff:Ninety Thousand Li guard` (same `filter` and `if: own.buff.wind >= 8`) placed immediately before `eff:Ninety Thousand Li gust`. Verified in `s.temp_mods` trace that both `dampen_taken: 25.0` (2 s) and `evade: 2.5 * n` (4 s) now persist and refresh independently.

2. **MUST-FIX — `design/stage6-staging/muc_van/arts/part-sect-muc_van.json` (`the-herd-turns` / `herd-turns-call`)**:
   - **What was wrong:** `herd-turns-call` placed two separate `{"mod": ...}` actions in one `do` array (`dmg_more: 0.25, kind: "companion"` followed by `companion_speed: 25`). The second `mod` shares `e.id` (`herd-turns-call`) without `"stack": true`, so it immediately wiped `dmg_more: 0.25` from `temp_mods` (confirmed via trace: `herd-turns-call` only ever added `companion_speed: 25.0`). They cannot be combined into one `mod` dict because `dmg_more` requires `kind: "companion"` while `companion_speed` is read with `ctx=None`.
   - **Fix applied:** Split `companion_speed: 25` (`for: 5.0`) into its own record `herd-turns-speed` on `the-herd-turns`, leaving `dmg_more: 0.25` (`kind: "companion"`, `for: 5.0`), `summon`, and `herd_turns` counter set on `herd-turns-call`.

3. **MUST-FIX — `design/stage6-staging/muc_van/arts/part-sect-muc_van.json` (`whistle-home` / `whistle-home-rally`)**:
   - **What was wrong:** `whistle-home-rally` placed two separate `{"mod": ...}` actions in one `do` array (`companion_speed: 15` followed by `status_resist: 15`). The second `mod` immediately wiped `companion_speed: 15` from `temp_mods` (confirmed via trace: `whistle-home-rally` only ever added `status_resist: 15.0`).
   - **Fix applied:** Merged both unfiltered mods into one `mod` dictionary (`{"companion_speed": 15, "status_resist": 15, "for": 3.0}`), which both `engine.py` and `effect_runner.gd` apply together without purging each other.

4. **MUST-FIX — `design/stage6-staging/muc_van/effects/muc_van.effects.json` (`One Thread of Wind`)**:
   - **What was wrong:** (a) `mark comp`, `mark art`, and `mark basic` unconditionally set `otw_comp_hit = 1` / `otw_own_hit = 1` even when that same hit had just triggered a joint strike (`joint comp` / `joint art` / `joint basic`), letting one hit pair twice in alternating sequences (`278` companion hits produced `480` joint-strike procs in 20 seeds). (b) `joint comp`, `joint art`, and `joint basic` each used separate `per_pulse: 1` limits instead of one shared pulse lock, allowing up to 3 procs in one pulse despite the rule's `(once a pulse)` bound.
   - **Fix applied:** Added `otw_pulse_lock` (`cap: 1`) to `One Thread of Wind`'s `counters`, ordered `mark` before `joint` for each hit kind (`comp`, `art`, `basic`) gated on the opposite window being `0`, gated all three `joint` records on `otw_pulse_lock == 0` and set `otw_pulse_lock = 1`, and added `eff:One Thread of Wind pulse reset` (`on: pulse`, `if: otw_pulse_lock >= 1` -> `set: 0`). In 20 seeds at `gap 0`, joint-strike procs dropped from `480` to `283` across `284` companion hits.

5. **SHOULD — `design/stage6-staging/muc_van/arts/part-sect-muc_van.json` (`run-with-the-herd` / `run-herd-spend`)**:
   - **What was wrong:** `run-herd-spend` listened on `on: "art_fired"`, executing before `run-with-the-herd`'s own `c_art: 1.6` hit landed (`direct_dmg == 0.0` on 6 of 10 firings in a seed-0 fight). That starved `engine.py`'s `free_hit` trigger budget down to `trig_budget * trig_floor_u * U_att = 0.25 * U_att`, clipping most of the Momentum-scaled Physical damage (`clipped.trig_budget: 5.05` per fight on `khau_muc_van` at `gap 0`).
   - **Fix applied:** Moved `run-herd-spend` to `on: "hit_landed"` (`filter: {"art_id": "run-with-the-herd"}`, `limit: {"per_pulse": 1}`), matching the rule text (`"when the charge lands"`) and other `scale` + `free_hit` arts (`root-in-the-crack`, `five-petals-of-cold`). `clipped.trig_budget` on `khau_muc_van` (`gap 0`, 20 seeds) dropped from `5.05` to `1.25` (and `0` at `gap 1`), and kill time improved from `40.9 s` to `38.7 s` (`37.5 s` on 5 seeds).

6. **SHOULD — `design/stage6-staging/muc_van/effects/muc_van.effects.json` (`Horse and Rider Bear It Together`)**:
   - **What was wrong:** `comp`, `art`, and `basic` marked `hr_comp_hit` / `hr_own_hit` unconditionally even when the hit just completed a joint strike (`rest comp` / `rest art` / `rest basic`), and `rest` did not clear the opposite hit window, allowing one hit to rest two separate bouts of tiredness within 1 s.
   - **Fix applied:** Separated `eff:Horse and Rider Bear It Together mark comp` from `companion_present`, gated `mark comp` / `art` / `basic` so a hit that just rested `horse_tired` does not re-arm the window (`any: [opposite == 0, horse_tired == 0]`), and cleared the consumed window (`hr_own_hit = 0` or `hr_comp_hit = 0`) inside each `rest` record.

7. **NIT / Open (no edit in `muc_van` scope) — `thoi_duong_giac` pre-existing two-stance pairing**:
   - **Observation:** `thoi_duong_giac` inherits committed library arts `swallow-stance` (`gale-courier-scripture`) and `mountain-root-stance` (`mountain-bone-body-art`), which toggle `s.state` back and forth (`swallow-stance` 4.0 fires, `mountain-root-stance` 2.0 fires at `gap 0`). Both arts live in committed `design/arts/family-wind.json` and `design/arts/family-body.json` outside `muc_van`'s write scope; she still clears `gap 0` 5/5 (13.3 s, 99% HP) and `4/20` at `gap 1` (40.2 s with `Ninety Thousand Li` vs `2/20` 30.2 s without). Logged in `.reviewed` `open`.

---

## Verification checklist

- **GDScript standalone compilation parity:** Every Effect in `design/stage6-staging/muc_van/effects/muc_van.effects.json` (`4/4`) declares all counters it reads or writes (`rider_art_window`, `herd_turn_next`, `companion_present`, `horse_tired`, `hr_own_hit`, `hr_comp_hit`, `otw_own_hit`, `otw_comp_hit`, `otw_pulse_lock`) in its own `"counters"` list, uses only ported `EVENTS`, `MOD_KEYS`, `ACTIONS`, `STATUS`, and filter keys from `assets/data/combat_engine.json`, and sets no undefined states.
- **Effect name uniqueness:** Verified `Turn the Herd`, `Horse and Rider Bear It Together`, `One Thread of Wind`, and `Ninety Thousand Li` have 0 collisions against `assets/data/combat_effects.json` and all other staged `b02` `*.effects.json` files.
- **Beast wiring, `herd-call`, stand-ins:**
  - `muc_van.beasts.json` defines `dap_van` (`khau_muc_van`) and `hong_tong` (`tan_thien_ly`), and `muc_van.cast.json` wires `"beasts": ["dap_van"]` on `khau_muc_van` and `"beasts": ["hong_tong"]` on `tan_thien_ly`.
  - `herd-call` in `catalogue-sect-muc_van.json` has `"tech_kind": "body"` and `"names": []` (matching `cong-phap.md` Rule 2 and Mục Vân's no-lean body doctrine).
  - `hua_tich_cau` uses `river-ice-groom-breath` (`two-bucket-haul`, layer 3, Yellow `main` `["thuy", "moc"]`); `stand_ins: 0`.
- **Linters & depth checks (post-fix, `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\muc_van`):**
  - `lint_techniques.py`: 3 techniques, **0 findings** (`16.0 W of 16`, `15.8 W of 16`, `8.0 W of 8`).
  - `lint_arts.py`: 6 arts, **0 findings**.
  - `lint_items.py`: 6 items, **0 findings** (`unique 6 of 6`, R6 `exception` on the 3 weapon/armour/robe items).
  - `depth_check.py --quiet`: **findings: none**.
  - `depth_gap.py --sect muc_van`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `lines 25/25 runs`.

---

## Pending words (`design/stage6-staging/muc_van/pending.json`)

- **0 pending words** (`{"words": [], "arts": [], "effects": {}}`). Verified empty; no new engine words needed.

---

## Holder table after fixes (`sect_fight.py muc_van --seeds 5`, `gap 0` / `gap 1`, 0 REFUSED)

Every staged art fires and every Effect runs on its real holders at both `gap 0` and `gap 1` (`0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`).

| Holder | Realm | `gap 0` (`mean_s`, `wins`, `hp_left`) | `gap 1` (`mean_s`, `wins`, `hp_left`) | Art fires (`gap 0`) & Effects (`with / without`, runs) |
|---|---|---|---|---|
| `khau_muc_van` | `ket_dan` 1 | `37.5 s`, `5/5`, `100%` | `15.7 s`, `0/5`, `0%` | Arts: `the-long-ride` `1.0`, `run-with-the-herd` `9.2`, `bridle-hand` `6.6`, `whistle-home` `8.4`, `the-herd-turns` `4.8`, `swallow-stance` `9.6`. **Horse and Rider Bear It Together**: `gap 0` `37.5 s` vs `39.3 s` (`561` runs); `gap 1` `15.7 s` vs `13.6 s` (`183` runs). **Turn the Herd**: `gap 0` `37.5 s` vs `38.7 s` (`129` runs); `gap 1` `15.7 s` vs `15.8 s` (`22` runs). **One Thread of Wind**: `gap 0` `37.5 s` vs `38.3 s` (`442` runs); `gap 1` `15.7 s` vs `15.0 s` (`134` runs). |
| `thoi_duong_giac` | `ket_dan` 0 | `13.3 s`, `5/5`, `99%` | `27.8 s`, `0/5`, `0%` *(20-seed `gap 1`: `40.2 s`, `4/20`, `5.3%`)* | Arts: `swallow-stance` `4.0`, `hundred-feather-flurry` `2.4`, `three-step-chase` `3.2`, `held-breath` `5.8`, `mountain-root-stance` `2.0`, `bone-turning-palm` `3.2`. **Ninety Thousand Li**: `gap 0` `13.3 s` vs `12.3 s` (`28` runs); `gap 1` 5-seed `27.8 s` vs `39.6 s` (`66` runs), 20-seed `40.2 s` `4/20` vs `30.2 s` `2/20` (`37` `guard` + `74` `gust` + `385` `wind` calls). |
| `tan_thien_ly` | `truc_co` 2 | `49.4 s`, `5/5`, `68%` | `9.5 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.8`, `bridle-hand` `6.4`, `whistle-home` `9.4`, `the-herd-turns` `5.8` |
| `lu_truy_phong` | `truc_co` 1 | `49.4 s`, `5/5`, `68%` | `9.5 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.8`, `bridle-hand` `6.4`, `whistle-home` `9.4`, `the-herd-turns` `5.8` |
| `du_bon_van` | `truc_co` 0 | `49.4 s`, `5/5`, `68%` | `9.5 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.8`, `bridle-hand` `6.4`, `whistle-home` `9.4`, `the-herd-turns` `5.8` |
| `khau_thanh_thao` | `truc_co` 1 | `57.6 s`, `4/5`, `24%` | `9.4 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `10.4`, `bridle-hand` `6.8` |
| `trinh_luc_phan` | `truc_co` 0 | `55.8 s`, `2/5`, `8%` | `8.4 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.8` |
| `thong_truy_dien` | `luyen_khi` 2 | `51.6 s`, `2/5`, `4%` | `8.0 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.2` |
| `tan_muc_so` | `luyen_khi` 2 | `51.6 s`, `2/5`, `4%` | `8.0 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.2` |
| `khau_tieu_cau` | `luyen_khi` 1 | `51.6 s`, `2/5`, `4%` | `8.0 s`, `0/5`, `0%` | `the-long-ride` `1.0`, `run-with-the-herd` `9.2` |
| `hua_tich_cau` | `luyen_khi` 2 | `59.0 s`, `1/5`, `2%` | `8.0 s`, `0/5`, `0%` | `two-bucket-haul` `13.6` (`1.4` at `gap 1`) |

CHECKPOINT DONE
