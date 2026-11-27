# Stage 6 Checkpoint Review — `phuong_minh` (Phượng Minh Cung)

Fresh, unanchored Neon audit of `design/stage6-staging/phuong_minh/` (including `foreign/market-folk/`) against `design/world/depth/sects/phuong_minh.*`, Stage 4/5 authored records, rulings (`DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`), `FIGHT-INPUT.md`, and live Python + GDScript combat parity.

*(Earlier Hydrogen fixes already on disk — `pending.json` `technique-effects`/`carried-meter` split, moving `dawn-call` inline onto `pm-dawn-call-pipe`, `A Copy in Small` syncing `pl_c1..pl_c5`, and removing `foe.counter.shao -> 0` from `nineshao-m8-stacks` — were independently verified and preserved.)*

---

## 1. What Was Read

- **Rules, memory, & rulings**: `CLAUDE.md`, `.claude/docs/{directory-structure,coordination-rules,coding-standards}.md`, `.claude/rules/{data-files,design-docs}.md`, standing memory (`modifier-vs-effect`, `effects-hand-designed-unpriced`, `scale-without-caps`, `no-environment-conditions`, `no-spatial-fight`), `production/plans/stage6/{_brief-review,_brief-record,bang_tam-review,phuong_minh-review}.md`, `design/world/depth/DECISIONS-2026-11-{25,26}.md`, peer `pending.json` (`thien_xu`, `lac_ha`), `design/world/depth/effects/bang_tam.effects.json`.
- **Staged files (`design/stage6-staging/phuong_minh/`)**:
  - `pending.json` (`technique-effects`, `carried-meter`)
  - `effects/phuong_minh.effects.json` (17 Effects, including `Sit Beside` out-of-fight `not_run`)
  - `techniques/catalogue-sect-phuong_minh.json` (6 techniques)
  - `arts/part-sect-phuong_minh.json` (14 arts)
  - `items/catalogue-sect-phuong_minh.json` (28 items, with inline `dawn-call` on `pm-dawn-call-pipe`) & `items/sets-phuong_minh.json` (10 sets)
  - `foreign/market-folk/techniques/catalogue-sect-market-folk.json` (`censer-smoke-manual`) & `foreign/market-folk/arts/part-sect-market-folk.json` (`pill-smoke`)
- **Depth & authored sources**: `design/world/depth/sects/phuong_minh.{techniques,items,beasts}.json`, `phuong_minh.md`, `phuong_minh{,.2,.3,.4}.cast.json` (120 people, 113 living), `design/world/depth/people/market-folk.techniques.json`, `design/world/depth/sects/thinh_vu.techniques.json`, `design/world/depth/builds/authored/{auth-tech,auth-eff-1,auth-eff-2,auth-mod}.json`, `design/arts/family-fire.json` (`ash-rebirth`), `design/items/catalogue-soul-song-seal.json`.
- **Engine, linters, & GDScript parity**: `tools/design/combat_sim/{FIGHT-INPUT.md,engine.py,fight.py,sect_fight.py,export_combat_library.py}`, `assets/data/combat_engine.json`, `tools/design/arts/{lint_arts,lint_techniques}.py`, `tools/design/items/lint_items.py`, `tools/design/world/{depth_check,depth_gap}.py`, `src/gameplay/combat/fight/{effect_compiler,effect_runner,build_file_compiler,fighter_profile_loader,fighter_compiler,fight}.gd`, `src/gameplay/cultivation/cong_phap.gd`.

---

## 2. Ranked Findings (Fresh Neon Audit)

### MUST-FIX (12 found, 12 fixed)

1. **[FIXED] `Petal Feint` (`effects/phuong_minh.effects.json`): `+30 % art_speed` deleted itself in the same `do` block & stripped `art_id` (0.00 s delta)**
   - *Found*: In both `engine.py:1830-1838` and `effect_runner.gd:388-411`, a non-`always` `mod` action without `stack: true` deletes all prior `temp_mods` sharing `e["id"]`, AND `temp_mods` keeps only `("dtype", "element", "tags", "kind")` (silently dropping `"art_id"`). Having three `mod` actions inside one `eff:Petal Feint` record caused `art_speed 30` to be deleted immediately by the subsequent `stack_dur 33` mod; `stack_dur` also lacked `kind: "debuff"` and ran for 3 s instead of the next fan art, and `ash-feather-gale`/`fan-gust` were omitted.
   - *Fix*: Rewrote with `petal_feint` (`cap: 1`): `evaded` sets `petal_feint = 1`; `on: "always"` (`petal_feint >= 1`) grants `art_speed: 30` across `tags: ["fan"]` and `art_id` `flint-volley` / `ash-feather-gale` / `fan-gust` (`always` mods support `art_id`); damaging fan `art_fired` (`not_tags: ["ward"]`, plus `flint-volley`/`ash-feather-gale`/`fan-gust`) grants a single `mod: {"stack_dur": 33, "element": "fire", "kind": "debuff"}` (no `for` -> expires `t + 1` ms after that art's sub-hits) and resets `petal_feint = 0`. Verified real delta on `du_diem_ca` (`12.06 s` vs `12.18 s` over 20 seeds).

2. **[FIXED] `The Censer Remembers` (`effects/phuong_minh.effects.json`): `wounded` always drained `ash_bank` BEFORE rebirth (`refused`), blocking the rebirth ward**
   - *Found*: `on: "wounded"` (`<= 25 %` HP) gated on `ash_refused == 0` ALWAYS fired before `down`/`refused` (0 % HP), wiping `ash_bank` even when `nhiep_tan_sa` had `ash-rebirth` armed (`ash >= 3`). After rising, `wounded` (`s.crossed`) could never fire a second time; `scale {per: 1}` floored `0.5` bank increments to `0`; and `leak` checked `foe.debuff.fire == 0` instead of "each second you deal no Fire".
   - *Fix*: Tracked `ash_bank` in 0.5 % HP units (`share: 0.005`, `floor: false`), added `censer_fire` (`cap: 1`, set on Fire `hit_landed`/`tick_dealt`, cleared on `pulse`) for exact 2 % no-Fire leak, converted `ash_bank` to ward on `refused` (`ash_refused = 1`), and moved the once-per-fight <=25 % heal to `was_hit`/`tick_taken` with `ash_healed == 0` and `any: [ash_refused >= 1, own.counter.ash < 3]`. Probe verified on `nhiep_tan_sa` with `ash-rebirth`: `ash_bank = 7.92` survives 25 % HP -> converts to ward on `refused` at `12000 ms` -> heals once at `22.3 %` HP at `14000 ms` after rebirth; and heals once at <=25 % HP when no rebirth is slotted.

3. **[FIXED] `five-colour-plumage` (`arts/part-sect-phuong_minh.json`): self-buffed Art #5, dropped after sub-hit #1, double-counted multi-tag arts, and skipped Fire fan/song repeats**
   - *Found*: (a) `pl-spend-*` ran on `art_fired` before Art #5's own hits, buffing Art #5 instead of "your next art", and `pl-release-*` cleared `pl_held = 0` on sub-hit #1 of multi-hit arts (`hundred-plumes`, `flint-volley`); (b) multi-tag arts (`perch-on-the-wutong` Wood+Ward, `wing-screen` Fan+Ward, song+Wood arts) added TWO colours in a single cast; (c) `pl-fire-repeat-*` excluded Fire fan/song arts even when they added no colour; (d) `pl_clean_flag` was unused.
   - *Fix*: Split `pl_held` into `pl_armed` + `pl_active` with `pl-expire-active` (`held: {"until": "art_fired"}`, which `spend_banked` runs right after all sub-hits finish in both `engine.py:1131` and `fight.gd:1048`), skipping 0-damage `ward`/`stance`/`dawn-clouds` on activation and scoping `L5` to `kind: "art"`; added `pl_added` (`cap: 1`) + `plumage < 5` to every colour check (Ward -> Fan -> Song -> Wood/Heal -> Fire canon) so each cast adds at most 1 colour; opened `pl-fire-repeat-*` to any `element: "fire"` art with `pl_added == 0`; removed unused `pl_clean_flag`. Probe confirmed `46` sub-hit heals across `21` activations on `hundred-plumes` (`clean_spends: 7`, `repeat_spends: 15`).

4. **[FIXED] `nine-shao-first/next/fifth/eighth-movement` (`arts/part-sect-phuong_minh.json`): no `guards` caused out-of-turn auto-cast resets, and `nineshao-m8-stacks` broke M6–M7**
   - *Found*: Without `guards`, auto-cast fired M1/M5/M8 off cooldown whenever ready, triggering `*-miss` and wiping `shao_movement = 0` before movements 3–8 could play. Additionally, once `Eight of Nine` reached `foe.counter.shao >= 8` around M4, `nineshao-m8-stacks` wiped `shao_movement = 0` on every 7 s cast, blocking M6, M7, and M8-in-turn.
   - *Fix*: Added exact in-turn `guards` to all four arts (`shao_movement == 0`; `any [1, 2, 3, 5, 6]`; `== 4`; `any [shao_movement == 7, foe.counter.shao >= 8]`) and removed `shao_movement -> 0` from `nineshao-m8-stacks` (leaving completion reset on `nineshao-m8-in-turn` and miss reset on `nineshao-m8-miss`). Probe verified all 8 movements playing cleanly in sequence (`m1: 25, m2: 25, m3: 25, m4: 21, m5: 21, m6: 20, m7: 20, m8-in-turn: 20`, 0 misses).

5. **[FIXED] `"movement"` tag collision with Combat rule 25 `Pressing` (`arts/part-sect-phuong_minh.json`)**
   - *Found*: All five song-movement arts (`remnant-next-movement`, `nine-shao-first/next/fifth/eighth-movement`) carried `"movement"` in `tags`, which both `engine.py:1110` and `fight.gd:1022` treat as a physical dash/movement art setting `s.t_move = t` (putting musicians in Pressing state for 1 s after every note). No rule filtered on `"movement"`.
   - *Fix*: Replaced `"movement"` with `"shao"` across all five arts; probes confirmed `t_move == None`.

6. **[FIXED] `remnant-next-movement` permanent stall at 7 (`arts/part-sect-phuong_minh.json`, `effects/phuong_minh.effects.json`)**
   - *Found*: Without `Never the Eighth` or `Playing Past the Break`, `remnant-next-movement` stopped matching any branch once `remnant_movement == 7` (depth rule: "After the seventh, the next firing is the attempt at the eighth (Playing Past the Break), or the first again"). On cycle 2 after `break_tried == 1`, `Playing Past the Break reset` also burned cast 16 as a blank reset instead of playing M1.
   - *Fix*: Declared `remnant_ready_8` (`cap: 1`) on `remnant-next-movement`, added `remnant-m1-restart` (`remnant_movement >= 7`, `remnant_ready_8 == 0` -> plays M1 and sets `1`), removed `Playing Past the Break reset`, and gated `Playing Past the Break arm` on `break_tried == 0`. Verified all 3 paths (plain loop, `Never the Eighth` suppression, and `Playing Past the Break` cycle 1 + cycle 2 M1 restart with zero wasted casts).

7. **[FIXED] `perch-on-the-wutong` dropped Field immediately (`toggle: true`) and ate non-bark wards, starving `tang_ke_ti`'s `Thread of the Nest` & `Fire Down the Thread` (`arts/part-sect-phuong_minh.json`, `effects/phuong_minh.effects.json`)**
   - *Found*: `perch-release` used `toggle: true` (Trap #7) to end `wutong-perch` (`tags: ["field"]`) on the very first Fire art AND consumed any stance ward (destroying `Fire Down the Thread`, `The Five Marks Shine`, and `A Copy in Small` wards). As a result `tang_ke_ti` had `0` runs on both `Thread of the Nest` and `Fire Down the Thread` at gap 0. `Fire Down the Thread` also ignored `event.stacks` (missing the 2nd Fire buff from `five-colour-plumage`) and had artificial `per_pulse` caps.
   - *Fix*: Kept `wutong-perch` standing as a Field after `perch-release` (matching Băng Tâm's `lotus-seal-ground`), added `perch_bark` (`cap: 1`) so `perch-release` consumes only when bark was raised, scaled `Fire Down the Thread grow` by `event.stacks` (guarded by `own.qi_share >= 0.05`), and dropped artificial `per_pulse` caps. On `tang_ke_ti`'s real build: `Fire Down the Thread` jumped to `19` runs at gap 0 (`82 %` vs `77 %` HP left) and `14` at gap 1, and against a Fire foe both `Thread of the Nest` (`+1.0 %` HP left) and `Fire Down the Thread` (`+7.3 %` HP left, `-1.23 s`) showed clear deltas. On `trinh_hi_quang`, `A Copy in Small` jumped from `20` to `113` runs (`94 %` vs `82 %` HP left).

8. **[FIXED] `Playing Past the Break` failure `self_hit` scaled by foe offence (`effects/phuong_minh.effects.json`)**
   - *Found*: `self_hit` runs `hit(o, s, ...)` with **`o` (the foe) as attacker** (`engine.py:2115`, `effect_runner.gd:525`). At `c: 2.2`, backlash dealt 100–500 % max HP against `+1` realm or `top_end` foes instead of `−10 %` max HP.
   - *Fix*: Replaced `self_hit` + `gain_qi` with `break_hp_backlash` and `break_qi_backlash` (`cap: 10`, `upkeep: {"pool": "hp"|"qi", "per_stack": 0.01}`), set to `10` on failure and cleared on `pulse` right after `upkeep` runs (`engine.py:981-1005`, `fight.gd:501-536`). Pays exact 10 % own max HP (leaving `pay_keep_health`) and 10 % own max linh lực with 1 % granularity when low, invariant across every realm gap.

9. **[FIXED] `Birds Pay Court to the Phoenix` per-pulse cap bypassed by 2 birds & missing `plumage < 5` guard (`effects/phuong_minh.effects.json`)**
   - *Found*: `c5..c1` had separate `limit: {"per_pulse": 1}` buckets, letting `vu_ngo_dong`'s two birds (`xich_quan`, `tieu_vi`) land 2 colours in the same pulse, and lacked `plumage < 5` (risking `plumage == 6` with repeats).
   - *Fix*: Added shared `bird_pl_pulse` (`cap: 1`, reset on `pulse`) and `own.counter.plumage < 5` to all five colour records. Probe with 2 birds verified `45` pulses -> exactly `45` colours (`c1: 25, c2: 20`).

10. **[FIXED] `Eight of Nine` did not lay Shao stacks on movements (`effects/phuong_minh.effects.json`)**
    - *Found*: `eff:Eight of Nine open` only laid 1 Shao stack at `fight_start` instead of "each movement lays one Shao stack on the foe".
    - *Fix*: Replaced `fight_start` with `eff:Eight of Nine step` (`on: "art_fired"`, `filter: {"tags": ["song"]}`, `counter {id: "shao", side: "foe", add: 1}`). Probe with full Nine Shao kit showed `92.9 %` vs `67.9 %` HP left (`+25.0 %` delta, `step: 206, hold: 39`).

11. **[FIXED] `The Birds Fight First` bled `dmg_more` onto non-fan hits, wasted Wood on `wing-screen`, omitted `flint-volley`, and imposed caps (`effects/phuong_minh.effects.json`)**
    - *Found*: Unscoped `for: 1` `dmg_more` buffed basics, companions, and non-fan arts for 1 s; `wing-screen` (`c_art = 0`) consumed all Wood buffs; `flint-volley` was omitted; `per_pulse: 3` and `n: 50` imposed arbitrary caps (violating *Scale without caps*).
    - *Fix*: Removed `per_pulse: 3` and `n: 50` (unbounded consume), added `not_tags: ["ward"]` and `flint-volley`, and changed `mod` to `{"dmg_more": 0.06, "kind": "art", "stack": true}` with no `for` (strictly that fan art's sub-hits).

12. **[FIXED] `Two Wings Beat` `per_pulse: 1` broke `flint-volley` volley, `wing-screen` wasted echo, and `fan-gust` omitted (`effects/phuong_minh.effects.json`)**
    - *Found*: `limit: {"per_pulse": 1}` ignored charges 2–3 of `flint-volley`; `wing-screen` consumed the 3rd-art echo with `c_art = 0`; `fan-gust` was missing. Verified `fire_art` (`engine.py:1947`, `effect_runner.gd:633`) never emits `art_fired` (no recursion risk).
    - *Fix*: Removed `per_pulse: 1` on `count*`, added `not_tags: ["ward"]` to `echo`, and added `fan-gust`. Probe on `su_hoanh_duc` with Twin Wings verified `15.05 s` vs `15.90 s` (`echo: 9, echo flint: 20`).

---

### SHOULD (9 found: 6 fixed, 3 open)

13. **[FIXED] `phoenix-sings-high-ridge` (`arts/part-sect-phuong_minh.json`)**: replaced invented `foe.hp_missing_share` execute (not in depth text) with `own.counter.plumage` scaling (`dmg_more: 0.08` per plumage colour held, scoped `art_id: "phoenix-sings-high-ridge"`).
14. **[FIXED] `Never the Eighth` (`effects/phuong_minh.effects.json`)**: removed arbitrary `for: 8` cap on "+20 % faster soul arts" after the 7th movement; replaced with persistent `seven_restarted` (`cap: 1`) + `on: "always"` `mod: {"art_speed": 20, "tags": ["soul"]}`.
15. **[FIXED] `Burning Feathers` & `The Birds Bring the Fire` (`effects/phuong_minh.effects.json`)**: removed artificial `limit: {"per_pulse": 4}` and `limit: {"per_pulse": 2}` caps (*Scale without caps*; `phuong_minh.items.json` already dropped the cap on `pm-wutong-twig-ring`) and added `ash-feather-gale`/`fan-gust` crit triggers to `Burning Feathers`.
16. **[FIXED] `dawn-call-palm` (`arts/part-sect-phuong_minh.json`)**: omitted `"for": 1` and added `"kind": "art"` on `+25 %` Fire `dmg_more` so it buffs strictly the Fire art that spent the Wood buff.
17. **[FIXED] `wing-screen` (`arts/part-sect-phuong_minh.json`)**: raised `dampen_taken` from `25` (20 % cut) to `33` (~24.8 % cut, matching "cuts the next hit taken by 25 %").
18. **[FIXED] `pm-dawn-call-pipe` / `dawn-call` notes (`items/catalogue-sect-phuong_minh.json`)**: fixed `root_has ['quang']` -> `root_has ['light']` (matching `fight.py`/`build_file_compiler.gd` `root_gate`) and noted the `scope: ["soul"]` compiler behavior accurately.
19. **[OPEN] `art_speed_pct` `scope: ["soul"]` compiler mismatch (`pm-tieu-thieu-quan`, `pm-remnant-score-zither`, `pm-rites-drum`, `pm-dawn-call-pipe`)**: `scope: ["soul"]` matches `catalogue-soul-song-seal.json` and W budgets pending GDD `b2` (`"song"` scope), **but** both `fight.py:422` and `build_file_compiler.gd:446` compile `"soul"` via `scope_dtype` into `dtype: "soul"`. Because all Phượng Minh song-soul arts (`thorn-lullaby`, `dawn-clouds-take-the-colour`, `remnant-next-movement`, `dawn-call`, `nine-shao-*`) have `kind: "elem"` (with `"soul"` tag / `soul_part`), `art_speed_pct [soul]` currently matches 0 of them in both engines. Carry to GDD/serial pass: add `"song"` scope (`b2`) and/or allow `scope: ["soul"]` to match `tags: ["soul"]` / `soul_part > 0` for `art_speed_pct`.
20. **[OPEN] `foreign/market-folk/` `censer-smoke-manual` `names: ["hoa"]` vs `o_thiem_tu` (`thinh_vu`) & unpriced `pill_effect_pct`**: depth `market-folk.techniques.json` authored `censer-smoke-manual` element-free (`names: []`), but `lint_techniques.py:130` requires 1–3 elements on non-`body` techniques, so `names: ["hoa"]` was kept (passing `ke_chu_sa` and `phung_xich_kim`, blocking `o_thiem_tu` `moc`/`thuy` in `CongPhap.usable()`). Lint passes with 0 findings when `DEPTH_STAGE` is set to `foreign/market-folk` (`NOT_PRICED` note on `pill_effect_pct`). Carry to serial/GDD pass.
21. **[OPEN] Cast `CongPhap.usable()` root mismatches (24 living people)**: 20 outer disciples on `wutong-dawn-breath` (`["moc", "hoa"]`) lacking `moc` or `hoa`, and 4 elders (`su_hoanh_duc`, `vuu_cam_thu`, `phan_vong_hai`, `hach_chu_lang`) on `five-virtue-phoenix-canon` (`["hoa", "moc"]`) lacking `moc`. Carry to cast/technique reconciliation.

---

## 3. Pending Words (`pending.json`)

| Word | Kind | Decision | Scope / Reason |
| --- | --- | --- | --- |
| `technique-effects` | `field` | **`build`** | Matches `thien_xu` and `lac_ha`: export `techniques[].effects` and load in `fight.py` (`tech_layers`) and GDScript `FighterCompiler` for `Birds Pay Court to the Phoenix` (layer 5) and `Playing Past the Break` (layer 1). |
| `carried-meter` | `field` | **`build`** | Seed `build.meters["playing_past_the_break"] = {"start": saved, "p": (than_hon + khi_van) / 400}` in `FighterCompiler`, save-state persistence, and `fight.py`/`sect_fight.py` cast builders. Combat `meter` action and `build_file_compiler.gd` already exist. |

---

## 4. Verification & Holder Table (Post-Fix)

All linters, GDScript `EffectCompiler` parity checks, and `engine.validate()` checks passed with **0 errors / 0 findings** after the final edit:
- `lint_arts.py part-sect-phuong_minh.json`: **14 arts, 0 findings**.
- `lint_techniques.py catalogue-sect-phuong_minh.json`: **6 techniques, 0 findings**.
- `lint_items.py catalogue-sect-phuong_minh.json`: **28 items, 22 bases, 9 common arts, 0 findings**.
- `lint_arts.py foreign/market-folk/arts/part-sect-market-folk.json`: **1 art (`pill-smoke`), 0 findings**.
- `lint_techniques.py foreign/market-folk/techniques/catalogue-sect-market-folk.json` (with `DEPTH_STAGE=...\foreign\market-folk`): **1 technique, 0 findings** (`NOT_PRICED` note on `pill_effect_pct`).
- `depth_check.py --sect phuong_minh`: **findings: none**; `depth_gap.py --sect phuong_minh`: **stand_ins 0, unknown_ids 0, lines 135/135 runs, cross_owner 2**.
- `engine.validate()` + GDScript `EffectCompiler` parity across all 17 Effects & 15 arts: **0 errors**.

### Holder Table (`sect_fight.py phuong_minh --seeds 5` at `--gap 0` / `--gap 1` + Targeted Probes)

*(0 `REFUSED` across all 55 living authored NPCs; non-signature outer disciples omitted — all Luyện Khí outer disciples won 5/5 at gap 0 except 4 `hearth-ash-breath` sweepers [`bao_lac_hai`, `bi_thuan`, `nguu_dai_huu`, `luu_tu_nuong`: `48.6 s, 0W, 0 %`], and all lost 0/5 at gap 1.)*

| Holder | Realm | Gap 0 (`5 seeds`) | Gap 1 (`5 seeds`) | Key Effects (`sect_fight` + Targeted Probes) |
| --- | --- | --- | --- | --- |
| `hoa_trieu_duong` | `nguyen_anh` | `25.0 s`, 5W, `94 %` | `9.3 s`, 0W, `0 %` | `The Five Marks Shine`: `runs 20` (`25.0 s 94 %` vs `27.6 s 77 %` without at gap 0); `Embers Never Die`: `runs 5`. Full 3-pc Regalia (`+pm-wutong-seal`): `20.20 s 99.4 %` vs `22.72 s 98.4 %` (`Regalia 25`). Full Nine Shao 1..8 + `pm-tieu-thieu-quan` (`Eight of Nine`): `59.01 s 92.9 %` vs `61.39 s 67.9 %` (`m1..m8` all fire in order, 0 misses, `t_move=None`). |
| `nhiep_tan_sa` | `nguyen_anh` | `18.5 s`, 5W, `81 %` | `12.2 s`, 0W, `0 %` | `The Censer Remembers`: `runs 403` (gap 0) / `255` (gap 1). Probe with `ash-rebirth` (gap 1): preserves `ash_bank=7.92` past 25 % HP -> ward on `refused` (`12000 ms`) -> post-rebirth heal at `22.3 %` HP (`14000 ms`) + `leak` verified; without `ash-rebirth`: heals once at <=25 % HP. `Sit Beside`: `not_run` (breakthrough rule). |
| `su_hoanh_duc` | `nguyen_anh` | `15.4 s`, 5W, `99 %` | `12.0 s`, 0W, `0 %` | `Burning Feathers`: `runs 54` (`15.4 s` vs `15.7 s` without at gap 0) / `24` (gap 1). Split-set Twin Wings (`+pm-right-wing-fan` held by `co_da_lan`): `Two Wings Beat` probe `15.05 s` vs `15.90 s` (`echo: 9, echo flint: 20`). |
| `vu_ngo_dong` | `ket_dan` | `27.8 s`, 5W, `96 %` | `11.6 s`, 0W, `0 %` | `Fan the Pyre`: `runs 88` (gap 0) / `26` (gap 1). `The Birds Fight First` (`0` in `sect_fight`: beasts not compiled to companions): probe with 2 birds (`xich_quan`, `tieu_vi`) + `Birds Pay Court` verified `19.63 s` vs `19.70 s`, `Birds Pay Court` strictly <=1 colour/pulse (`45` pulses, `45` colours, `24` rewards), `Fight First` `90` stacks / `50` fan spends. |
| `tang_ke_ti` | `ket_dan` | `19.1 s`, 5W, `82 %` | `12.0 s`, 0W, `0 %` | `Fire Down the Thread`: `runs 19` (`19.1 s 82 %` vs `19.6 s 77 %` without at gap 0) / `runs 14` (`12.0 s` vs `11.8 s` at gap 1). `Thread of the Nest` (`on: "always"`, not counted by `Fight.do()` hook): probe vs Fire foe confirms `wutong-perch` Field active (`full 22.67 s 88.0 %`, `no_Thread 22.67 s 87.0 %`, `no_FireDown 23.90 s 80.7 %`). |
| `lien_thieu_nghi` | `ket_dan` | `27.2 s`, 5W, `100 %` | `10.5 s`, 0W, `0 %` | `Never the Eighth` (`0` in `sect_fight`: `remnant-next-movement` is 7th art past `MAX_ARTS=6`): probe with `remnant-next-movement` + `Playing Past the Break` verified `72` steps / `9` seventh restarts, permanent `seven_restarted=1` (`+20 %` soul speed), `Playing Past the Break` suppressed (`0` runs). |
| `lo_van_khanh` | `ket_dan` | `25.7 s`, 5W, `100 %` | `8.1 s`, 0W, `0 %` | `Playing Past the Break` (`tree_effects` + `meters`): probe verified 8th-cast firing (`22640 ms`), exact `10 %` own HP & qi upkeep backlash on `p=0.0` (cleanly cleared on pulse), 5 Slowed Time + `10 %` qi on `p=1.0`, and seamless cycle-2 M1 restart (`remnant-m1-restart`). Plain `remnant-next-movement` loops 1..7 indefinitely (`t_move=None`). |
| `trinh_hi_quang` | `ket_dan` | `15.6 s`, 5W, `94 %` | `9.8 s`, 0W, `0 %` | `A Copy in Small`: `runs 113` (`15.6 s 94 %` vs `15.6 s 82 %` without at gap 0) / `runs 31` (`9.8 s` vs `9.4 s` at gap 1). Multi-hit plumage probe with `hundred-plumes` confirmed `46` sub-hit heals across `21` activations (`clean_spends: 7`, `repeat_spends: 15`). |
| `an_thuy_vu` | `truc_co` | `18.8 s`, 5W, `68 %` | `8.0 s`, 0W, `0 %` | `The Birds Bring the Fire` (`0` in `sect_fight`: `ngu_cau` beast not compiled to companion): probe verified `40` stacks (`18.51 s 71.7 %` vs `18.59 s 71.2 %`). |
| `chuc_hieu_nghi` | `truc_co` | `14.1 s`, 5W, `89 %` | `8.0 s`, 0W, `0 %` | `Light on the Pipe` (`0` in `sect_fight`: `sect_fight.py` does not slot `item.arts`): probe with inline `dawn-call` verified `dawn-count: 20`, `dawn-exposed: 5`, `Light on the Pipe count: 20`. |
| `du_diem_ca` | `truc_co` | `12.4 s`, 5W, `94 %` | `8.0 s`, 0W, `0 %` | `Petal Feint`: `runs 12` (gap 0) / `7` (gap 1); 20-seed probe verified `12.06 s` vs `12.18 s` (`arm: 37, burn fan: 22, burn flint: 7`). |
| `ke_chu_sa` | `ket_dan` | `20.4 s`, 5W, `74 %` | `8.0 s`, 0W, `0 %` | `censer-smoke-manual` / `pill-smoke` (`foreign/market-folk/` not globbed by `sect_fight`): probe with prepared Fire grade-2 pill verified `smoke-burn-pill: 33`. |
| `chu_tri_am` | `ket_dan` | `16.7 s`, 5W, `66 %` | `8.0 s`, 0W, `0 %` | `hundred-blades-canon` (root `kim: 64` fits; `pm-tower-rain-chain-sword` equipped; all 3 arts fire at gap 0). |

---

## 5. Open Items (Carry to Serial / GDD / Cast Passes)

1. **Serial (`pending.json`)**: Build `technique-effects` (`export_combat_library.py`, `fight.py` `tech_layers`, GDScript `FighterCompiler`) and `carried-meter` (`FighterCompiler` + save persistence seeding `build.meters["playing_past_the_break"]`), then export `Birds Pay Court to the Phoenix` & `Playing Past the Break` into `combat_effects.json`.
2. **GDD & Compiler (`b2` / `scope: ["soul"]`)**: Add `"song"` to Modifier scope vocabulary (`combat_engine.json`, `modifiers.md`, `lint_techniques.py`) and restore `scope: ["song"]` on `pm-remnant-score-zither`, `pm-rites-drum`, `pm-dawn-call-pipe`, and `shao-remnant-score` passives; also fix `fight.py:422` / `build_file_compiler.gd:446` so `scope: ["soul"]` on `art_speed_pct` matches `"soul"`-tagged / `soul_part` arts (fixing `pm-tieu-thieu-quan` and `catalogue-soul-song-seal.json`).
3. **Cross-sect `foreign/market-folk/`**: Reconcile `censer-smoke-manual` element-free intent vs `names: ["hoa"]` blocking `o_thiem_tu` (`thinh_vu`) via a `lint_techniques.py` element-free `secret` exemption (or root adjustment); price `pill_effect_pct` in Formulas A; confirm post-merge lint via `stage6_merge.py`.
4. **Cast & build reconciliation**: Reconcile 24 living `phuong_minh` cast `CongPhap.usable()` root mismatches (`wutong-dawn-breath`, `five-virtue-phoenix-canon`); leave `nine-shao-ninth-movement` story-only (`unlock_layer: 15`) and `tieu_vi`/`xich_quan`/`ngu_cau` companion cards to their systems pass.
5. **Sim tool enhancements (non-blocking)**: `sect_fight.py` does not yet compile `items[named].arts`, `beasts` -> `companions`, `techniques[].effects`, or `foreign/` arts, does not count `on: "always"` Effects (`Thread of the Nest`) in `runs`, and caps slotted arts at `6` (dropping `remnant-next-movement`, `nine-shao-fifth/eighth-movement`, `ash-rebirth`, `pill-smoke` on multi-technique NPCs).

CHECKPOINT DONE
